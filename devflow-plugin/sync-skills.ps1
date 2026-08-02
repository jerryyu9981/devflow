# DevFlow Skills Sync Script (PowerShell)
# Usage: .\sync-skills.ps1 [-Target <IDE|Work|All>] [-Action <Install|Uninstall|Sync>] [-DryRun]
#
# Description:
#   Batch sync DevFlow skills between plugin source and TRAE installation directories.
#   Supports both TRAE IDE and TRAE Work desktop, which share the same global skills directory.
#
# Target:
#   - IDE  : Only update ~/.trae-cn/skills (global, shared by IDE & Work desktop)
#   - Work : Only update project-level .trae/skills/ (for Work-specific project skills)
#   - All  : Update both (default)
#
# Action:
#   - Install : Copy all DevFlow skills to target directories (default)
#   - Uninstall: Remove all DevFlow skills from target directories
#   - Sync    : Uninstall then Install (full refresh, recommended for version upgrades)

param(
    [ValidateSet("IDE", "Work", "All")]
    [string]$Target = "All",

    [ValidateSet("Install", "Uninstall", "Sync")]
    [string]$Action = "Sync",

    [switch]$DryRun,

    [string]$ProjectPath = ""
)

$ErrorActionPreference = "Continue"

# ─── Plugin Source Directory ─────────────────────────────────────
$PluginDir = $PSScriptRoot

# Read version from devflow-config.json (single source of truth)
$Version = "unknown"
$ConfigJsonPath = Join-Path $PluginDir "devflow-config.json"
if (Test-Path $ConfigJsonPath) {
    $configInfo = Get-Content $ConfigJsonPath -Encoding UTF8 | ConvertFrom-Json
    $Version = $configInfo.devflowVersion
}

# DT-01: Load skill definitions — prefer devflow-config.json, fallback to devflow-manifest.json (legacy)
$ManifestPath = Join-Path $PluginDir "devflow-manifest.json"
if (Test-Path $ConfigJsonPath) {
    $configData = Get-Content $ConfigJsonPath -Encoding UTF8 | ConvertFrom-Json
    $DevFlowSkills = $configData.skills | ForEach-Object { @{ Name = $_.name; SourceDir = $_.source } }
    $ExpectedSkillCount = $configData.skillCount
} elseif (Test-Path $ManifestPath) {
    $manifestData = Get-Content $ManifestPath -Encoding UTF8 | ConvertFrom-Json
    $DevFlowSkills = $manifestData.skills | ForEach-Object { @{ Name = $_.name; SourceDir = $_.source } }
    $ExpectedSkillCount = $manifestData.skillCount
    Write-Warn "Using legacy devflow-manifest.json — consider upgrading to devflow-config.json (v2.10.1+)"
} else {
    Write-Err "devflow-config.json not found at $ConfigJsonPath"
    exit 1
}

$SkillNames = $DevFlowSkills | ForEach-Object { $_.Name }

# ─── Helper Functions ────────────────────────────────────────────

function Write-Header($text) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function Write-OK($text) {
    Write-Host "  [OK] $text" -ForegroundColor Green
}

function Write-Warn($text) {
    Write-Host "  [WARN] $text" -ForegroundColor Yellow
}

function Write-Err($text) {
    Write-Host "  [ERR] $text" -ForegroundColor Red
}

function Write-Dry($text) {
    Write-Host "  [DRY] $text" -ForegroundColor DarkGray
}

function Remove-Utf8Bom {
    param([string]$FilePath)
    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $content = [System.IO.File]::ReadAllText($FilePath, [System.Text.UTF8Encoding]::new($true))
        [System.IO.File]::WriteAllText($FilePath, $content, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "[BOM Fixed] $(Split-Path $FilePath -Leaf)" -ForegroundColor Yellow
        return $true
    }
    return $false
}

function Copy-SkillToTarget($skillName, $sourceDir, $targetDir, [ref]$counter, [ref]$failCounter) {
    # Source: the entire source directory (contains SKILL.md or a single .md file)
    $srcFullPath = Join-Path $PluginDir $sourceDir
    $dstSkillDir = Join-Path $targetDir $skillName

    if (-not (Test-Path $srcFullPath)) {
        Write-Err "$skillName : source not found at $srcFullPath"
        $failCounter.Value++
        return
    }

    # If source is a single file:
    # - .md files (L1/L2/L3 skills) → wrap into SKILL.md
    # - Other files (e.g. devflow-config.json) → keep original filename
    $isSingleFile = $false
    $singleFileSrc = ""
    $preserveFileName = $false
    if (Test-Path $srcFullPath -PathType Leaf) {
        $isSingleFile = $true
        $singleFileSrc = $srcFullPath
        $ext = [System.IO.Path]::GetExtension($srcFullPath)
        if ($ext -ne '.md') {
            $preserveFileName = $true
        }
    }

    # Remove existing destination (full directory replace)
    if (Test-Path $dstSkillDir) {
        if ($DryRun) {
            Write-Dry "$skillName : would remove $dstSkillDir"
        } else {
            try {
                Remove-Item -Path $dstSkillDir -Recurse -Force -ErrorAction Stop
            } catch {
                Write-Err "$skillName : failed to remove existing dir - $_"
                $failCounter.Value++
                return
            }
        }
    }

    # Create destination and copy
    if ($DryRun) {
        if ($isSingleFile) {
            $targetName = if ($preserveFileName) { [System.IO.Path]::GetFileName($singleFileSrc) } else { "SKILL.md" }
            Write-Dry "$skillName : would create $dstSkillDir\$targetName from $singleFileSrc"
        } else {
            Write-Dry "$skillName : would copy directory $srcFullPath -> $dstSkillDir"
        }
    } else {
        New-Item -ItemType Directory -Path $dstSkillDir -Force | Out-Null

        if ($isSingleFile) {
            $targetName = if ($preserveFileName) { [System.IO.Path]::GetFileName($singleFileSrc) } else { "SKILL.md" }
            Copy-Item -Path $singleFileSrc -Destination (Join-Path $dstSkillDir $targetName) -Force
        } else {
            Copy-Item -Path "$srcFullPath\*" -Destination $dstSkillDir -Recurse -Force
        }
        Write-OK "$skillName"
    }
    $counter.Value++
}

function Remove-SkillFromTarget($skillName, $targetDir, [ref]$counter, [ref]$failCounter) {
    $dstSkillDir = Join-Path $targetDir $skillName

    if (-not (Test-Path $dstSkillDir)) {
        Write-Warn "$skillName : not found, skip"
        return
    }

    if ($DryRun) {
        Write-Dry "$skillName : would remove $dstSkillDir"
    } else {
        try {
            Remove-Item -Path $dstSkillDir -Recurse -Force -ErrorAction Stop
            Write-OK "$skillName : removed"
        } catch {
            Write-Err "$skillName : failed to remove - $_"
            $failCounter.Value++
            return
        }
    }
    $counter.Value++
}

# ─── Banner ──────────────────────────────────────────────────────

Write-Host ""
Write-Host "  DevFlow Skills Sync v$Version" -ForegroundColor Cyan
Write-Host "  Target: $Target | Action: $Action | DryRun: $DryRun" -ForegroundColor DarkGray
Write-Host "  Total DevFlow skills: $($SkillNames.Count)" -ForegroundColor DarkGray
Write-Host ""

if ($DryRun) {
    Write-Warn "*** DRY RUN MODE - No actual changes will be made ***"
}

# ─── Determine Target Directories ───────────────────────────────

if ($env:DEVFLOW_SKILLS_DIR) {
    $GlobalSkillsDir = $env:DEVFLOW_SKILLS_DIR
} else {
    $GlobalSkillsDir = Join-Path $env:USERPROFILE ".trae-cn\skills"
}
$ProjectSkillsDir = ""

if ($ProjectPath) {
    $ProjectSkillsDir = Join-Path (Resolve-Path $ProjectPath).Path ".trae\skills"
} else {
    # Try to detect current project's .trae/skills
    $cwd = (Get-Location).Path
    $candidate = Join-Path $cwd ".trae\skills"
    if (Test-Path (Join-Path $cwd ".devflow")) {
        $ProjectSkillsDir = $candidate
    }
}

$targets = @()
if ($Target -eq "IDE" -or $Target -eq "All") {
    $targets += @{ Label = "Global (IDE + Work desktop)"; Dir = $GlobalSkillsDir }
}
if (($Target -eq "Work" -or $Target -eq "All") -and $ProjectSkillsDir) {
    $targets += @{ Label = "Project (.trae/skills)"; Dir = $ProjectSkillsDir }
} elseif ($Target -eq "Work" -and -not $ProjectSkillsDir) {
    Write-Warn "Work target requested but no project path detected."
    Write-Host "  Use -ProjectPath to specify, or run from a project root with .devflow/ folder."
}

# ─── Execute Action ─────────────────────────────────────────────

$totalInstalled = 0
$totalRemoved = 0
$totalFailed = 0

foreach ($t in $targets) {
    Write-Header "$($t.Label): $($t.Dir)"

    if (-not (Test-Path $t.Dir)) {
        Write-Warn "Directory does not exist, creating: $($t.Dir)"
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $t.Dir -Force | Out-Null
        }
    }

    if ($Action -eq "Sync" -or $Action -eq "Uninstall") {
        # Uninstall phase
        Write-Host "`n  Phase 1: Uninstall existing DevFlow skills..." -ForegroundColor Yellow
        $remCount = 0
        $remFail = 0
        foreach ($skill in $DevFlowSkills) {
            Remove-SkillFromTarget -skillName $skill.Name -targetDir $t.Dir -counter ([ref]$remCount) -failCounter ([ref]$remFail)
        }
        $totalRemoved += $remCount
        $totalFailed += $remFail
        Write-Host "`n  Removed: $remCount, Failed: $remFail" -ForegroundColor $(if ($remFail -gt 0) { "Yellow" } else { "Green" })
    }

    if ($Action -eq "Sync" -or $Action -eq "Install") {
        # Install phase
        Write-Host "`n  Phase 2: Install DevFlow skills..." -ForegroundColor Yellow
        $instCount = 0
        $instFail = 0
        foreach ($skill in $DevFlowSkills) {
            Copy-SkillToTarget -skillName $skill.Name -sourceDir $skill.SourceDir -targetDir $t.Dir -counter ([ref]$instCount) -failCounter ([ref]$instFail)
        }
        $totalInstalled += $instCount
        $totalFailed += $instFail
        Write-Host "`n  Installed: $instCount, Failed: $instFail" -ForegroundColor $(if ($instFail -gt 0) { "Yellow" } else { "Green" })
    }
}

# DT-03: Remove UTF-8 BOM from all synced .md files
$bomFixedCount = 0
foreach ($t in $targets) {
    if (Test-Path $t.Dir) {
        Get-ChildItem -Path $t.Dir -Recurse -Filter "*.md" | ForEach-Object {
            if (Remove-Utf8Bom -FilePath $_.FullName) {
                $bomFixedCount++
            }
        }
    }
}
if ($bomFixedCount -gt 0) {
    Write-Host ""
    Write-Host "BOM fix: $bomFixedCount file(s) cleaned" -ForegroundColor Yellow
}

# ─── Summary ──────────────────────────────────────────────────────

Write-Header "Summary"
Write-Host "  Action:    $Action" -ForegroundColor White
Write-Host "  Installed: $totalInstalled" -ForegroundColor Green
Write-Host "  Removed:   $totalRemoved" -ForegroundColor Yellow
if ($totalFailed -gt 0) {
    Write-Host "  Failed:    $totalFailed" -ForegroundColor Red
} else {
    Write-Host "  Failed:    0" -ForegroundColor Green
}

Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "  1. Restart TRAE IDE / TRAE Work to reload skills" -ForegroundColor DarkGray
Write-Host "  2. Verify skills are loaded: check Skill panel in TRAE" -ForegroundColor DarkGray
Write-Host ""