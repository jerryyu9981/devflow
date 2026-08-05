# DevFlow Update Script (PowerShell)
# Usage: .\update.ps1 [-Version <version>] [-DryRun]

param(
    [string]$Version = "",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Repository URL 鈥?reads from env var first, then config.json
# Supports authenticated URLs: http://user:pass@host/path/repo.git
# Git Credential Manager is recommended over embedding credentials in URLs
$RepoUrl = $env:DEVFLOW_REPO_URL
if (-not $RepoUrl) {
    # Read from .devflow/config.json if available
    $ConfigPath = ".devflow\config.json"
    if (Test-Path $ConfigPath) {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        if ($config.remote.origin) {
            $RepoUrl = $config.remote.origin
        }
    }
    if (-not $RepoUrl) {
        Write-Host "[WARN] No repository URL configured. Set DEVFLOW_REPO_URL env var or add remote.origin in .devflow/config.json" -ForegroundColor Yellow
        Write-Host "       Falling back to manual file-based update." -ForegroundColor Yellow
        $RepoUrl = ""
    }
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

# 1. Check current version
$ConfigPath = ".devflow\config.json"
$CurrentVersion = "unknown"
if (Test-Path $ConfigPath) {
    $config = Get-Content $ConfigPath | ConvertFrom-Json
    $CurrentVersion = $config.devflowVersion
}
Write-Host "Current DevFlow version: $CurrentVersion"

# 2. Determine latest version
$LatestVersion = $Version
if (-not $LatestVersion) {
    # Read from local version.json (same directory as this script)
    $ScriptDir = $PSScriptRoot
    $LocalVersionJson = Join-Path $ScriptDir "version.json"
    if (Test-Path $LocalVersionJson) {
        $localVer = Get-Content $LocalVersionJson | ConvertFrom-Json
        $LatestVersion = $localVer.version
    }
    # If repo URL is configured, also try remote check
    if ($RepoUrl -and (-not $LatestVersion)) {
        try {
            $response = Invoke-WebRequest -Uri "$RepoUrl/raw/main/version.json" -UseBasicParsing -TimeoutSec 10
            $latest = $response.Content | ConvertFrom-Json
            $LatestVersion = $latest.version
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

# 3. Download and update skills
Write-Header "Updating DevFlow to v$LatestVersion"

$TraeSkillsDir = "$env:USERPROFILE\.trae-cn\skills"
$ScriptDir = $PSScriptRoot

# Skill name 鈫?source path mapping (relative to plugin root)
# Orchestrator skills: plugin-root/orchestrator/{name}/SKILL.md
# L1 skills: plugin-root/skills/L1/{name}.md
# L2 skills: plugin-root/skills/L2/{name}.md
# L3 skills: plugin-root/skills/L3/{name}.md
$skillMap = @{
    "devflow-init"                = "devflow-init\SKILL.md"
    "devflow-phase-manager"       = "devflow-phase-manager\SKILL.md"
    "devflow-project-config"      = "devflow-project-config\SKILL.md"
    "project-development-workflow" = "skills\L1\project-development-workflow.md"
    "project-document-management"  = "skills\L1\project-document-management.md"
    "project-role-management"      = "skills\L1\project-role-management.md"
    "version-planning-stage-execution" = "skills\L2\version-planning-stage-execution.md"
    "requirements-stage-execution" = "skills\L2\requirements-stage-execution.md"
    "design-stage-execution"       = "skills\L2\design-stage-execution.md"
    "coding-stage-execution"       = "skills\L2\coding-stage-execution.md"
    "testing-stage-execution"      = "skills\L2\testing-stage-execution.md"
    "operations-stage-execution"  = "skills\L2\operations-stage-execution.md"
    "project-coding-conventions"  = "skills\L3\project-coding-conventions.md"
    "code-static-quality-check"   = "skills\L3\code-static-quality-check.md"
    "code-logic-review"           = "skills\L3\code-logic-review.md"
    "cicd-pipeline-management"    = "skills\L3\cicd-pipeline-management.md"
    "observability-standards"     = "skills\L3\observability-standards.md"
    "project-document-templates"  = "skills\L3\project-document-templates.md"
}

$updateCount = 0
$failCount = 0

foreach ($skill in $skillMap.Keys | Sort-Object) {
    $src = Join-Path $ScriptDir $skillMap[$skill]
    $dst = Join-Path $TraeSkillsDir "$skill\SKILL.md"

    if (Test-Path $src) {
        # Create backup of existing skill
        if (Test-Path $dst) {
            $timestamp = Get-Date -Format "yyyyMMddHHmmss"
            $bakPath = "$dst.bak-$timestamp"
            Copy-Item $dst $bakPath -Force
        }
        # Ensure destination directory exists
        $dstDir = Split-Path $dst -Parent
        if (-not (Test-Path $dstDir)) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }
        Copy-Item $src $dst -Force
        Write-Success "Updated: $skill"
        $updateCount++
    } elseif ($RepoUrl) {
        # Try download from remote repo
        $remotePaths = @(
            "orchestrator/$skill/SKILL.md",
            "skills/L1/$skill.md",
            "skills/L2/$skill.md",
            "skills/L3/$skill.md"
        )
        $downloaded = $false
        foreach ($remotePath in $remotePaths) {
            $url = "$RepoUrl/raw/main/$remotePath"
            try {
                $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 15
                $dstDir = Split-Path $dst -Parent
                if (-not (Test-Path $dstDir)) {
                    New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
                }
                # Create backup
                if (Test-Path $dst) {
                    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
                    Copy-Item $dst "$dst.bak-$timestamp" -Force
                }
                $response.Content | Set-Content $dst -Encoding UTF8
                Write-Success "Downloaded: $skill (from $remotePath)"
                $updateCount++
                $downloaded = $true
                break
            } catch {
                # Try next path
            }
        }
        if (-not $downloaded) {
            Write-Warn "Failed to update: $skill (not found locally or remotely)"
            $failCount++
        }
    } else {
        Write-Warn "Skipped: $skill (source not found: $src)"
        $failCount++
    }
}

Write-Host ""
Write-Host "Update summary: $updateCount updated, $failCount failed" -ForegroundColor $(if ($failCount -gt 0) { "Yellow" } else { "Green" })

# 4. Update config version
if (Test-Path $ConfigPath) {
    $config = Get-Content $ConfigPath | ConvertFrom-Json
    $config.devflowVersion = $LatestVersion
    $config | ConvertTo-Json -Depth 4 | Set-Content $ConfigPath -Encoding UTF8
    Write-Success "Updated config.devflowVersion to v$LatestVersion"
}

Write-Success "DevFlow update to v$LatestVersion complete"
