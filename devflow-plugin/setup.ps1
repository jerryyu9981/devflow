# DevFlow Setup Script (PowerShell)
# Usage: .\setup.ps1 [-InstallHook]

param(
    [switch]$InstallHook
)

$ErrorActionPreference = "Stop"

# Read version - prefer devflow-config.json (v2.9.1+), fallback to version.json (legacy)
$ScriptDir = $PSScriptRoot
$ConfigPath = Join-Path $ScriptDir "devflow-config.json"
$VersionJsonPath = Join-Path $ScriptDir "version.json"
$ConfigSource = "none"

if (Test-Path $ConfigPath) {
    $configInfo = Get-Content $ConfigPath -Encoding UTF8 | ConvertFrom-Json
    $DevFlowVersion = $configInfo.devflowVersion
    $ConfigSource = "devflow-config.json"
} elseif (Test-Path $VersionJsonPath) {
    $versionInfo = Get-Content $VersionJsonPath -Encoding UTF8 | ConvertFrom-Json
    $DevFlowVersion = $versionInfo.devflowVersion
    $ConfigSource = "version.json (legacy)"
    Write-Warn "Using legacy version.json — consider upgrading to devflow-config.json (v2.9.1+)"
} else {
    $DevFlowVersion = "unknown"
    Write-Warn "Neither devflow-config.json nor version.json found, version will be 'unknown'"
}

function Write-Header($text) {
    Write-Host "`n=== $text ===" -ForegroundColor Cyan
}

function Write-Success($text) {
    Write-Host "[OK] $text" -ForegroundColor Green
}

function Write-Warn($text) {
    Write-Host "[WARN] $text" -ForegroundColor Yellow
}

# ─── BOM Removal Helper (DT-03) ──────────────────────────────────
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

# 1. Detect Host
Write-Header "Detecting Host Environment"
$HostType = "unknown"
if ($env:TRAE_IDE -or (Test-Path "$env:USERPROFILE\.trae-cn")) {
    $HostType = "TRAE"
} elseif (Test-Path ".git") {
    $HostType = "generic"
}
Write-Success "Host detected: $HostType"

# DT-01: Load skill map - prefer devflow-config.json (v2.9.1+), fallback to devflow-manifest.json (legacy)
$ManifestPath = Join-Path $ScriptDir "devflow-manifest.json"
$skillMap = @{}
$ExpectedSkillCount = 0

if (Test-Path $ConfigPath) {
    $skillConfig = Get-Content $ConfigPath -Encoding UTF8 | ConvertFrom-Json
    foreach ($s in $skillConfig.skills) { $skillMap[$s.name] = $s.source }
    $ExpectedSkillCount = $skillConfig.skillCount
    if ($ConfigSource -ne "devflow-config.json") {
        $ConfigSource = "devflow-config.json"
    }
} elseif (Test-Path $ManifestPath) {
    $Manifest = Get-Content $ManifestPath -Encoding UTF8 | ConvertFrom-Json
    foreach ($s in $Manifest.skills) { $skillMap[$s.name] = $s.source }
    $ExpectedSkillCount = $Manifest.skillCount
    if ($ConfigSource -ne "devflow-config.json") {
        Write-Warn "Using legacy devflow-manifest.json — consider upgrading to devflow-config.json (v2.9.1+)"
    }
} else {
    Write-Error "Neither devflow-config.json nor devflow-manifest.json found — cannot proceed with skill installation"
    exit 1
}

# 2. Install skills to TRAE (if TRAE detected)
if ($HostType -eq "TRAE") {
    # DT-04: IDE system directory configurable via environment variable
    $TraeSkillsDir = if ($env:DEVFLOW_SKILLS_DIR) { $env:DEVFLOW_SKILLS_DIR } else { "$env:USERPROFILE\.trae-cn\skills" }

    # Ensure target directory exists
    if (-not (Test-Path $TraeSkillsDir)) {
        New-Item -ItemType Directory -Path $TraeSkillsDir -Force | Out-Null
        Write-Host "[INFO] Created skills directory: $TraeSkillsDir" -ForegroundColor Cyan
    }

    # Skill definitions loaded from devflow-config.json (or devflow-manifest.json fallback) via DT-01 above

    # Phase 1: Uninstall existing DevFlow skills (clean slate)
    Write-Header "Uninstalling existing DevFlow Skills"
    foreach ($skillName in $skillMap.Keys) {
        $dstDir = Join-Path $TraeSkillsDir $skillName
        if (Test-Path $dstDir) {
            try {
                Remove-Item -Path $dstDir -Recurse -Force -ErrorAction Stop
                Write-Success "Removed: $skillName"
            } catch {
                Write-Warn "Failed to remove: $skillName - $_"
            }
        }
    }

    # Phase 1.5: Interactive confirmation before installation
    Write-Header "Installation Confirmation"
    Write-Host "DevFlow Version: $DevFlowVersion"
    Write-Host "Skills to install: $($skillMap.Count)"
    Write-Host "Target directory: $TraeSkillsDir"
    Write-Host ""
    $confirm = Read-Host "Proceed with installing DevFlow skills to TRAE? (Y/n)"
    if ($confirm -eq "n" -or $confirm -eq "N") {
        Write-Host "Installation cancelled by user." -ForegroundColor Yellow
        exit 0
    }

    # Phase 2: Install DevFlow skills from plugin source
    Write-Header "Installing DevFlow Skills to TRAE"
    $instCount = 0
    $failCount = 0
    foreach ($skillName in $skillMap.Keys | Sort-Object) {
        $src = Join-Path $PSScriptRoot $skillMap[$skillName]
        $dstDir = Join-Path $TraeSkillsDir $skillName

        if (Test-Path $src) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
            # v2.7.5 fix: preserve original filename for non-.md files (e.g. version.json, sync-skills.ps1)
            $ext = [System.IO.Path]::GetExtension($src)
            if ($ext -eq '.md') {
                $dstFile = Join-Path $dstDir "SKILL.md"
            } else {
                $dstFile = Join-Path $dstDir (Split-Path $skillMap[$skillName] -Leaf)
            }
            Copy-Item -Path $src -Destination $dstFile -Force
            Write-Success "Installed: $skillName"
            $instCount++
        } else {
            Write-Warn "Skill source not found: $skillName ($src)"
            $failCount++
        }
    }

    # DT-03: Remove UTF-8 BOM from all installed .md files
    $bomFixedCount = 0
    Get-ChildItem -Path $TraeSkillsDir -Recurse -Filter "*.md" | ForEach-Object {
        if (Remove-Utf8Bom -FilePath $_.FullName) {
            $bomFixedCount++
        }
    }
    if ($bomFixedCount -gt 0) {
        Write-Host ""
        Write-Host "BOM fix: $bomFixedCount file(s) cleaned" -ForegroundColor Yellow
    }

    # DT-07: Copy devflow-config.json to TRAE skills dir as single source of truth
    $configDir = Join-Path $TraeSkillsDir "devflow-config"
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
    if (Test-Path $ConfigPath) {
        Copy-Item -Path $ConfigPath -Destination (Join-Path $configDir "devflow-config.json") -Force
        Write-Success "Config synced: devflow-config.json"
    } else {
        Write-Warn "devflow-config.json not found, skipping config sync"
    }

    Write-Host ""
    Write-Host "Skills install result: $instCount installed, $failCount failed" -ForegroundColor $(if ($failCount -gt 0) { "Yellow" } else { "Green" })

    # DT-06: Verify installed skill count
    if ($instCount -eq $ExpectedSkillCount) {
        Write-Success "Installed: $instCount/$ExpectedSkillCount skills"
    } else {
        Write-Warn "Skill count mismatch: installed=$instCount, expected=$ExpectedSkillCount"
    }
}

# 3. Install Git Hook (optional)
if ($InstallHook -and (Test-Path ".git")) {
    Write-Header "Installing Git Post-Push Hook"

    # Create log directory
    $logDir = ".devflow\logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    }

    # Create backup history CSV header
    $historyFile = Join-Path $logDir "backup-history.csv"
    if (-not (Test-Path $historyFile)) {
        "时间,备份类型,状态,Commit SHA" | Set-Content $historyFile -Encoding UTF8
    }

    $hookDir = ".git\hooks"
    $hookPath = Join-Path $hookDir "post-push"
    $hookContent = @'
#!/bin/bash
# DevFlow 自动备份 Hook
REMOTE_NAME="${1:-backup}"
LOG_DIR=".devflow/logs"
mkdir -p "$LOG_DIR"

if git remote | grep -q "$REMOTE_NAME"; then
    echo "[DevFlow Backup] $(date '+%Y-%m-%d %H:%M:%S') 开始备份到 $REMOTE_NAME ..."
    git push --mirror "$REMOTE_NAME" 2>&1
    git push --tags "$REMOTE_NAME" 2>&1

    if [ $? -eq 0 ]; then
        echo "[DevFlow Backup] 备份完成"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),git-mirror,成功,$(git rev-parse HEAD)" >> "$LOG_DIR/backup-history.csv"
    else
        echo "[DevFlow Backup] 备份失败"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),git-mirror,失败,$(git rev-parse HEAD)" >> "$LOG_DIR/backup-error.csv"
    fi
else
    echo "[DevFlow Backup] 未找到远程仓库 '$REMOTE_NAME'，跳过备份"
fi
'@
    Set-Content $hookPath $hookContent -Encoding UTF8
    Write-Success "Installed: $hookPath"
    Write-Success "Created: $logDir"
}

# 4. Summary
Write-Header "DevFlow Setup Complete"
Write-Host "DevFlow Version: $DevFlowVersion"
Write-Host "Config Source:   $ConfigSource"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Open your project in TRAE and invoke devflow-init to initialize .devflow/devflow-config.json"
Write-Host "  2. Run '.\update.ps1' to update skills when new versions are available"

exit 0
