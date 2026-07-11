# DevFlow Setup Script (PowerShell)
# Usage: .\setup.ps1 [-ProjectName <name>] [-BranchStrategy <strategy>]

param(
    [string]$ProjectName = "",
    [ValidateSet("trunk-based", "github-flow", "git-flow")]
    [string]$BranchStrategy = "git-flow",
    [switch]$InstallHook,
    [switch]$SkipConfig
)

$ErrorActionPreference = "Stop"

# Read version from version.json (same directory as this script)
$ScriptDir = $PSScriptRoot
$VersionJsonPath = Join-Path $ScriptDir "version.json"
if (Test-Path $VersionJsonPath) {
    $versionInfo = Get-Content $VersionJsonPath -Encoding UTF8 | ConvertFrom-Json
    $DevFlowVersion = $versionInfo.version
} else {
    $DevFlowVersion = "unknown"
    Write-Host "[WARN] version.json not found, version will be 'unknown'" -ForegroundColor Yellow
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

# 1. Detect Host
Write-Header "Detecting Host Environment"
$HostType = "unknown"
if ($env:TRAE_IDE -or (Test-Path "$env:USERPROFILE\.trae-cn")) {
    $HostType = "TRAE"
} elseif (Test-Path ".git") {
    $HostType = "generic"
}
Write-Success "Host detected: $HostType"

# 2. Install skills to TRAE (if TRAE detected)
if ($HostType -eq "TRAE") {
    $TraeSkillsDir = "$env:USERPROFILE\.trae-cn\skills"

    # Skill definitions: Name -> SourcePath (relative to plugin root)
    $skillMap = @{
        "devflow-init"                  = "devflow-init\SKILL.md"
        "devflow-phase-manager"         = "devflow-phase-manager\SKILL.md"
        "devflow-project-config"         = "devflow-project-config\SKILL.md"
        "project-development-workflow"   = "skills\L1\project-development-workflow.md"
        "project-document-management"    = "skills\L1\project-document-management.md"
        "project-role-management"        = "skills\L1\project-role-management.md"
        "version-planning-stage-execution" = "skills\L2\version-planning-stage-execution.md"
        "requirements-stage-execution"  = "skills\L2\requirements-stage-execution.md"
        "design-stage-execution"        = "skills\L2\design-stage-execution.md"
        "coding-stage-execution"        = "skills\L2\coding-stage-execution.md"
        "testing-stage-execution"        = "skills\L2\testing-stage-execution.md"
        "operations-stage-execution"     = "skills\L2\operations-stage-execution.md"
        "project-coding-conventions"     = "skills\L3\project-coding-conventions.md"
        "code-static-quality-check"      = "skills\L3\code-static-quality-check.md"
        "code-logic-review"              = "skills\L3\code-logic-review.md"
        "cicd-pipeline-management"      = "skills\L3\cicd-pipeline-management.md"
        "observability-standards"        = "skills\L3\observability-standards.md"
        "api-contract-management"       = "skills\L3\api-contract-management.md"
        "prototype-coverage"            = "skills\L3\prototype-coverage.md"
        "backend-coverage"              = "skills\L3\backend-coverage.md"
        "project-document-templates"     = "skills\L3\project-document-templates.md"
        "code-version-backup-management" = "skills\L3\code-version-backup-management.md"
    }

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

    # Phase 2: Install DevFlow skills from plugin source
    Write-Header "Installing DevFlow Skills to TRAE"
    $instCount = 0
    $failCount = 0
    foreach ($skillName in $skillMap.Keys | Sort-Object) {
        $src = Join-Path $PSScriptRoot $skillMap[$skillName]
        $dstDir = Join-Path $TraeSkillsDir $skillName
        $dstFile = Join-Path $dstDir "SKILL.md"

        if (Test-Path $src) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
            Copy-Item -Path $src -Destination $dstFile -Force
            Write-Success "Installed: $skillName"
            $instCount++
        } else {
            Write-Warn "Skill source not found: $skillName ($src)"
            $failCount++
        }
    }
    Write-Host ""
    Write-Host "Skills install result: $instCount installed, $failCount failed" -ForegroundColor $(if ($failCount -gt 0) { "Yellow" } else { "Green" })
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
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Open your project in TRAE and invoke devflow-init to initialize project configuration"
Write-Host "  2. Run '.\update.ps1' to update skills when new versions are available"
