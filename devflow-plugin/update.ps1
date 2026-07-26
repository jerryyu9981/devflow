# DevFlow Update Script (PowerShell)
# Usage: .\update.ps1 [-Version <version>] [-DryRun] [-Target <IDE|Work|All>] [-Action <Update|Install|Uninstall|Sync>]
#
# Note: This script merges the legacy sync-skills.ps1 functionality.
# sync-skills.ps1 is deprecated; all operations consolidated here.

param(
    [string]$Version = "",
    [switch]$DryRun,

    [ValidateSet("IDE", "Work", "All")]
    [string]$Target = "IDE",

    [ValidateSet("Update", "Install", "Uninstall", "Sync")]
    [string]$Action = "Update",

    [string]$ProjectPath = ""
)

$ErrorActionPreference = "Continue"

# Repository URL - reads from env var first, then config.json
# Supports authenticated URLs: http://user:pass@host/path/repo.git
# Git Credential Manager is recommended over embedding credentials in URLs
$RepoUrl = $env:DEVFLOW_REPO_URL
if (-not $RepoUrl) {
    # Read from .devflow/project-config.json if available
    $ConfigPath = ".devflow\project-config.json"
    if (Test-Path $ConfigPath) {
        $config = Get-Content $ConfigPath -Encoding UTF8 | ConvertFrom-Json
        if ($config.remote.origin) {
            $RepoUrl = $config.remote.origin
        }
    }
    if (-not $RepoUrl) {
        Write-Host "[WARN] No repository URL configured. Set DEVFLOW_REPO_URL env var or add remote.origin in .devflow/project-config.json" -ForegroundColor Yellow
        Write-Host "       Falling back to manual file-based update." -ForegroundColor Yellow
        $RepoUrl = ""
    }
}

# ─── Target Directory Resolution ───────────────────────────────
# (from sync-skills.ps1 — supports IDE / Work / All targets)

$GlobalSkillsDir = if ($env:DEVFLOW_SKILLS_DIR) { $env:DEVFLOW_SKILLS_DIR } else { "$env:USERPROFILE\.trae-cn\skills" }

$ProjectSkillsDir = ""
if ($ProjectPath) {
    try {
        $resolved = Resolve-Path $ProjectPath -ErrorAction Stop
        $ProjectSkillsDir = Join-Path $resolved.Path ".trae\skills"
    } catch {
        Write-Warn "ProjectPath '$ProjectPath' not found or not accessible"
    }
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

# ─── Helper Functions ────────────────────────────────────────────

function Write-Header($text) {
    Write-Host "`n=== $text ===" -ForegroundColor Cyan
}

function Write-Success($text) {
    Write-Host "[OK] $text" -ForegroundColor Green
}

function Write-Warn($text) {
    Write-Host "[WARN] $text" -ForegroundColor Yellow
}

function Write-OK($text) {
    Write-Host "  [OK] $text" -ForegroundColor Green
}

function Write-Err($text) {
    Write-Host "  [ERR] $text" -ForegroundColor Red
}

function Write-Dry($text) {
    Write-Host "  [DRY] $text" -ForegroundColor DarkGray
}

function Copy-SkillToTarget($skillName, $sourceDir, $targetDir, [ref]$counter, [ref]$failCounter) {
    # Source: the entire source directory (contains SKILL.md or a single .md file)
    $srcFullPath = Join-Path $PSScriptRoot $sourceDir
    $dstSkillDir = Join-Path $targetDir $skillName

    if (-not (Test-Path $srcFullPath)) {
        Write-Err "$skillName : source not found at $srcFullPath"
        $failCounter.Value++
        return
    }

    # If source is a single file:
    # - .md files (L1/L2/L3 skills) → wrap into SKILL.md
    # - Other files (e.g. version.json) → keep original filename
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

# ─── Version Check ──────────────────────────────────────────────

$StatePath = ".devflow\state.json"
$CurrentVersion = "unknown"
if (Test-Path $StatePath) {
    $state = Get-Content $StatePath -Encoding UTF8 | ConvertFrom-Json
    $CurrentVersion = $state.devflowVersion
}
Write-Host "Current DevFlow version: $CurrentVersion"

# Version resolution & comparison — only for Update action
if ($Action -eq "Update") {
    $LatestVersion = $Version
    if (-not $LatestVersion) {
        # Read from local devflow-config.json (same directory as this script)
        $ScriptDir = $PSScriptRoot
        $LocalConfigJson = Join-Path $ScriptDir "devflow-config.json"
        if (Test-Path $LocalConfigJson) {
            $localCfg = Get-Content $LocalConfigJson -Encoding UTF8 | ConvertFrom-Json
            $LatestVersion = $localCfg.devflowVersion
        }
        # If repo URL is configured, also try remote check
        if ($RepoUrl -and (-not $LatestVersion)) {
            try {
                $response = Invoke-WebRequest -Uri "$RepoUrl/raw/main/version.json" -UseBasicParsing -TimeoutSec 10
                $latest = $response.Content | ConvertFrom-Json
                $LatestVersion = $latest.devflowVersion
            } catch {
                Write-Warn "Could not fetch remote version.json: $_"
            }
        }
        if (-not $LatestVersion) {
            Write-Host "[ERROR] Cannot determine target version. Please specify -Version." -ForegroundColor Red
            exit 1
        }
    }

    if ($CurrentVersion -eq $LatestVersion) {
        Write-Success "Already up to date (v$CurrentVersion)"
        exit 0
    }

    Write-Host "Update available: v$CurrentVersion -> v$LatestVersion"

    if ($DryRun) {
        Write-Host "Dry run mode - no changes made."
        exit 0
    }

    Write-Header "Updating DevFlow to v$LatestVersion"
}

# ─── Load skill definitions ─────────────────────────────────────
# Prefer devflow-config.json (v2.9.1+), fallback to devflow-manifest.json (legacy)

$ScriptDir = $PSScriptRoot
$PluginConfigPath = Join-Path $ScriptDir "devflow-config.json"
$ManifestPath = Join-Path $ScriptDir "devflow-manifest.json"
$skillMap = @{}
$ExpectedSkillCount = 0

if (Test-Path $PluginConfigPath) {
    $skillConfig = Get-Content $PluginConfigPath -Encoding UTF8 | ConvertFrom-Json
    foreach ($s in $skillConfig.skills) { $skillMap[$s.name] = $s.source }
    $ExpectedSkillCount = $skillConfig.skillCount
} elseif (Test-Path $ManifestPath) {
    $Manifest = Get-Content $ManifestPath -Encoding UTF8 | ConvertFrom-Json
    foreach ($s in $Manifest.skills) { $skillMap[$s.name] = $s.source }
    $ExpectedSkillCount = $Manifest.skillCount
    Write-Warn "Using legacy devflow-manifest.json — consider upgrading to devflow-config.json (v2.9.1+)"
} else {
    Write-Error "Neither devflow-config.json nor devflow-manifest.json found — cannot proceed with skill operation"
    exit 1
}

# Build skill objects for multi-target processing
$PluginSkills = $skillMap.Keys | ForEach-Object {
    @{ Name = $_; SourceDir = $skillMap[$_] }
}

# ─── Execute per-target operations ─────────────────────────────

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

    # ── Uninstall Phase ──
    if ($Action -eq "Sync" -or $Action -eq "Uninstall") {
        Write-Host "  Phase 1: Uninstall existing DevFlow skills..." -ForegroundColor Yellow
        $remCount = 0
        $remFail = 0
        foreach ($skill in $PluginSkills) {
            Remove-SkillFromTarget -skillName $skill.Name -targetDir $t.Dir -counter ([ref]$remCount) -failCounter ([ref]$remFail)
        }
        $totalRemoved += $remCount
        $totalFailed += $remFail
        Write-Host "  Removed: $remCount, Failed: $remFail" -ForegroundColor $(if ($remFail -gt 0) { "Yellow" } else { "Green" })
    }

    # ── Install Phase ──
    if ($Action -eq "Sync" -or $Action -eq "Install" -or $Action -eq "Update") {
        Write-Host "  Phase 2: Install DevFlow skills..." -ForegroundColor Yellow
        $instCount = 0
        $instFail = 0

        foreach ($skill in $PluginSkills) {
            $src = Join-Path $ScriptDir $skill.SourceDir
            $dstDir = Join-Path $t.Dir $skill.Name

            if (Test-Path $src) {
                # Local copy via Copy-SkillToTarget (handles .md→SKILL.md wrapping and non-.md filename preservation)
                Copy-SkillToTarget -skillName $skill.Name -sourceDir $skill.SourceDir -targetDir $t.Dir -counter ([ref]$instCount) -failCounter ([ref]$instFail)

            } elseif ($Action -eq "Update" -and $RepoUrl) {
                # Remote download (only for Update action when local source is missing)
                $ext = [System.IO.Path]::GetExtension($src)
                if ($ext -eq '.md' -or -not $ext) {
                    $dst = Join-Path $dstDir "SKILL.md"
                } else {
                    $dst = Join-Path $dstDir (Split-Path $skill.SourceDir -Leaf)
                }

                $remotePaths = @(
                    "orchestrator/$($skill.Name)/SKILL.md",
                    "skills/L1/$($skill.Name).md",
                    "skills/L2/$($skill.Name).md",
                    "skills/L3/$($skill.Name).md"
                )
                $downloaded = $false
                foreach ($remotePath in $remotePaths) {
                    $url = "$RepoUrl/raw/main/$remotePath"
                    try {
                        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 15
                        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
                        $response.Content | Set-Content $dst -Encoding UTF8
                        Write-Success "Downloaded: $($skill.Name) (from $remotePath)"
                        $instCount++
                        $downloaded = $true
                        break
                    } catch {
                        # Try next path
                    }
                }
                if (-not $downloaded) {
                    Write-Warn "Failed to install: $($skill.Name) (not found locally or remotely)"
                    $instFail++
                    $totalFailed++
                }
            } else {
                Write-Warn "Skipped: $($skill.Name) (source not found: $src)"
                $instFail++
                $totalFailed++
            }
        }

        $totalInstalled += $instCount
        Write-Host "  Installed: $instCount, Failed: $instFail" -ForegroundColor $(if ($instFail -gt 0) { "Yellow" } else { "Green" })
    }
}

# ─── BOM Fix (all targets) ──────────────────────────────────────

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

# ─── Config Sync (only IDE/All targets) ─────────────────────────

if (($Target -eq "IDE" -or $Target -eq "All") -and ($Action -eq "Update" -or $Action -eq "Install" -or $Action -eq "Sync")) {
    $configDir = Join-Path $GlobalSkillsDir "devflow-config"
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
    if (Test-Path $PluginConfigPath) {
        Copy-Item -Path $PluginConfigPath -Destination (Join-Path $configDir "devflow-config.json") -Force
        Write-Success "Config synced: devflow-config.json"
    } else {
        Write-Warn "devflow-config.json not found, skipping config sync"
    }
}

# ─── Summary ──────────────────────────────────────────────────────

Write-Header "Summary"
if ($Action -eq "Update") {
    Write-Host "  Version:  v$CurrentVersion -> v$LatestVersion" -ForegroundColor White
}
Write-Host "  Action:   $Action" -ForegroundColor White
Write-Host "  Target:   $Target" -ForegroundColor White
Write-Host "  Installed: $totalInstalled" -ForegroundColor Green
Write-Host "  Removed:  $totalRemoved" -ForegroundColor Yellow
if ($totalFailed -gt 0) {
    Write-Host "  Failed:   $totalFailed" -ForegroundColor Red
} else {
    Write-Host "  Failed:   0" -ForegroundColor Green
}
Write-Host "  Targets:  $($targets.Count)" -ForegroundColor White

Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "  1. Restart TRAE IDE / TRAE Work to reload skills" -ForegroundColor DarkGray
Write-Host "  2. Verify skills are loaded: check Skill panel in TRAE" -ForegroundColor DarkGray

# Verify installed skill count (for Update action only)
if ($Action -eq "Update" -and $totalInstalled -eq $ExpectedSkillCount) {
    Write-Success "Installed: $totalInstalled/$ExpectedSkillCount skills"
} elseif ($Action -eq "Update") {
    Write-Warn "Skill count mismatch: installed=$totalInstalled, expected=$ExpectedSkillCount"
}

if ($Action -eq "Update") {
    Write-Success "DevFlow update to v$LatestVersion complete"
}
Write-Host ""
