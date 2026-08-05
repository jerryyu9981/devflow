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
    $raw = [System.IO.File]::ReadAllText($VersionJsonPath, [System.Text.Encoding]::UTF8)
    $versionInfo = $raw | ConvertFrom-Json
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

# 2. Detect Project Name
Write-Header "Detecting Project Name"
if (-not $ProjectName) {
    if (Test-Path "package.json") {
        $pkg = Get-Content "package.json" | ConvertFrom-Json
        $ProjectName = $pkg.name
    } elseif (Test-Path ".git") {
        $remote = git remote get-url origin 2>$null
        if ($remote) {
            $ProjectName = ($remote -split '/')[-1] -replace '\.git$', ''
        }
    }
    if (-not $ProjectName) {
        $ProjectName = (Get-Item .).Name
    }
}
Write-Success "Project name: $ProjectName"

# 3. Create .devflow directory
Write-Header "Creating .devflow Configuration"
$DevFlowDir = ".devflow"
New-Item -ItemType Directory -Path $DevFlowDir -Force | Out-Null

# 4. Generate config.json
if (-not $SkipConfig) {
    $config = @{
        project = $ProjectName
        devflowVersion = $DevFlowVersion
        branchStrategy = $BranchStrategy
        remote = @{
            origin = ""
            backup = ""
        }
        backup = @{
            type = "git-mirror"
            schedule = @{
                bundle = "weekly"
                bundleRetention = 4
                dbDump = "daily"
                dbRetention = 90
            }
        }
    }

    # Interactive prompts
    $originUrl = Read-Host "Enter your Git origin remote URL (press Enter to skip)"
    if ($originUrl) { $config.remote.origin = $originUrl }

    $backupUrl = Read-Host "Enter your Git backup remote URL (press Enter to skip)"
    if ($backupUrl) { $config.remote.backup = $backupUrl }

    $configPath = Join-Path $DevFlowDir "config.json"
    $config | ConvertTo-Json -Depth 4 | Set-Content $configPath -Encoding UTF8
    Write-Success "Created: $configPath"
}

# 5. Generate state.json
$state = @{
    project = $ProjectName
    version = ""
    currentPhase = "step_0_planning"
    completedPhases = @()
    currentDocuments = @{}
    auditResults = @{}
}
$statePath = Join-Path $DevFlowDir "state.json"
$state | ConvertTo-Json -Depth 4 | Set-Content $statePath -Encoding UTF8
Write-Success "Created: $statePath"

# 6. Install skills to TRAE (if TRAE detected)
if ($HostType -eq "TRAE") {
    Write-Header "Installing DevFlow Skills to TRAE"
    $TraeSkillsDir = "$env:USERPROFILE\.trae-cn\skills"

    $skills = @(
        "devflow-init", "devflow-phase-manager", "devflow-project-config",
        "project-development-workflow", "project-document-management", "project-role-management",
        "version-planning-stage-execution", "requirements-stage-execution", "design-stage-execution",
        "coding-stage-execution", "testing-stage-execution", "operations-stage-execution",
        "project-coding-conventions", "code-static-quality-check", "code-logic-review",
        "cicd-pipeline-management", "observability-standards", "project-document-templates",
        "code-version-backup-management"
    )

    foreach ($skill in $skills) {
        $src = "skills\*\$skill.md"
        $dst = Join-Path $TraeSkillsDir $skill
        if (-not (Test-Path $dst)) {
            New-Item -ItemType Directory -Path $dst -Force | Out-Null
        }
        # Copy from plugin bundle
        $found = Get-ChildItem -Path "skills" -Recurse -Filter "$skill.md" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            Copy-Item $found.FullName (Join-Path $dst "SKILL.md") -Force
            Write-Success "Installed: $skill"
        } else {
            Write-Warn "Skill file not found: $skill"
        }
    }
}

# 7. Install Git Hook (optional)
if ($InstallHook -and (Test-Path ".git")) {
    Write-Header "Installing Git Post-Push Hook"
    $hookDir = ".git\hooks"
    $hookPath = Join-Path $hookDir "post-push"
    $hookContent = @'
#!/bin/bash
# DevFlow auto-backup hook
if git remote | grep -q backup; then
    echo "[DevFlow] Pushing mirror to backup remote..."
    git push --mirror backup
    git push --tags backup
fi
'@
    Set-Content $hookPath $hookContent -Encoding UTF8
    Write-Success "Installed: $hookPath"
}

# 8. Summary
Write-Header "DevFlow Setup Complete"
Write-Host "Project:        $ProjectName"
Write-Host "Branch Strategy: $BranchStrategy"
Write-Host "DevFlow Version: $DevFlowVersion"
Write-Host "Config:         .devflow/config.json"
Write-Host "State:          .devflow/state.json"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Run '.\update.ps1' to update skills when new versions are available"
Write-Host "  2. Edit .devflow/config.json to set your backup remote URL"
Write-Host "  3. Start with: Invoke devflow-init skill to detect your current phase"
