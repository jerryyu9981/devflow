# DevFlow Update Script (PowerShell)
# Usage: .\update.ps1 [-Version <version>] [-DryRun]

param(
    [string]$Version = "",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Repository URL - reads from env var first, then config.json
# Supports authenticated URLs: http://user:pass@host/path/repo.git
# Git Credential Manager is recommended over embedding credentials in URLs
$RepoUrl = $env:DEVFLOW_REPO_URL
if (-not $RepoUrl) {
    # Read from .devflow/config.json if available
    $ConfigPath = ".devflow\config.json"
    if (Test-Path $ConfigPath) {
        $config = Get-Content $ConfigPath -Encoding UTF8 | ConvertFrom-Json
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

# 1. Check current version
$StatePath = ".devflow\state.json"
$CurrentVersion = "unknown"
if (Test-Path $StatePath) {
    $state = Get-Content $StatePath -Encoding UTF8 | ConvertFrom-Json
    $CurrentVersion = $state.devflowVersion
}
Write-Host "Current DevFlow version: $CurrentVersion"

# 2. Determine latest version
$LatestVersion = $Version
if (-not $LatestVersion) {
    # Read from local version.json (same directory as this script)
    $ScriptDir = $PSScriptRoot
    $LocalVersionJson = Join-Path $ScriptDir "version.json"
    if (Test-Path $LocalVersionJson) {
        $localVer = Get-Content $LocalVersionJson -Encoding UTF8 | ConvertFrom-Json
        $LatestVersion = $localVer.devflowVersion
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

# 3. Download and update skills
Write-Header "Updating DevFlow to v$LatestVersion"

$TraeSkillsDir = if ($env:DEVFLOW_SKILLS_DIR) { $env:DEVFLOW_SKILLS_DIR } else { "$env:USERPROFILE\.trae-cn\skills" }
if (-not (Test-Path $TraeSkillsDir)) {
    New-Item -ItemType Directory -Path $TraeSkillsDir -Force | Out-Null
    Write-Host "[INFO] Created skills directory: $TraeSkillsDir" -ForegroundColor Cyan
}
$ScriptDir = $PSScriptRoot

# Skill name -> source path mapping (relative to plugin root)
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
    "api-contract-management"     = "skills\L3\api-contract-management.md"
    "prototype-coverage"          = "skills\L3\prototype-coverage.md"
    "backend-coverage"            = "skills\L3\backend-coverage.md"
    "project-document-templates"  = "skills\L3\project-document-templates.md"
    "code-version-backup-management" = "skills\L3\code-version-backup-management.md"

    # v2.7.5: Plugin configuration (version.json) and sync tool
    "devflow-plugin-config"         = "version.json"
    "devflow-plugin-sync"           = "sync-skills.ps1"

    # v2.8.0: Plugin download tool (git clone/pull for cloud repository)
    "devflow-plugin-download"       = "download-devflow.ps1"
}

# Phase 1: Uninstall existing DevFlow skills (clean slate)
Write-Header "Uninstalling existing DevFlow Skills"
$remCount = 0
foreach ($skill in $skillMap.Keys | Sort-Object) {
    $dstDir = Join-Path $TraeSkillsDir $skill
    if (Test-Path $dstDir) {
        try {
            Remove-Item -Path $dstDir -Recurse -Force -ErrorAction Stop
            Write-Success "Removed: $skill"
            $remCount++
        } catch {
            Write-Warn "Failed to remove: $skill - $_"
            $failCount++
        }
    }
}
Write-Host "Removed: $remCount skills" -ForegroundColor Green

# Phase 2: Install DevFlow skills from plugin source
Write-Header "Installing DevFlow Skills"

$updateCount = 0
$failCount = 0

foreach ($skill in $skillMap.Keys | Sort-Object) {
    $src = Join-Path $ScriptDir $skillMap[$skill]
    $dstDir = Join-Path $TraeSkillsDir $skill
    # v2.8.1 fix: preserve original filename for non-.md files (e.g. version.json, sync-skills.ps1, download-devflow.ps1)
    $ext = [System.IO.Path]::GetExtension($src)
    if ($ext -eq '.md') {
        $dst = Join-Path $dstDir "SKILL.md"
    } else {
        $dst = Join-Path $dstDir (Split-Path $skillMap[$skill] -Leaf)
    }

    if (Test-Path $src) {
        # Ensure destination directory exists (already cleaned by Phase 1)
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        Copy-Item $src $dst -Force
        Write-Success "Installed: $skill"
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
                New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
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
            Write-Warn "Failed to install: $skill (not found locally or remotely)"
            $failCount++
        }
    } else {
        Write-Warn "Skipped: $skill (source not found: $src)"
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

Write-Host ""
Write-Host "Update summary: $updateCount updated, $failCount failed" -ForegroundColor $(if ($failCount -gt 0) { "Yellow" } else { "Green" })

Write-Success "DevFlow update to v$LatestVersion complete"