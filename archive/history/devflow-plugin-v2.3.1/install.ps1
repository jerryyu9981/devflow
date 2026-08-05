# DevFlow Plugin Installer for Windows (v2.3.1)
# Usage: Right-click -> "Run with PowerShell" or double-click install.bat

$ErrorActionPreference = "Stop"

# Get the directory where this script is located (plugin bundle root)
$PluginDir = $PSScriptRoot

# Read version from version.json
$VersionJsonPath = Join-Path $PluginDir "version.json"
$Version = "2.3.1"
if (Test-Path $VersionJsonPath) {
    $raw = [System.IO.File]::ReadAllText($VersionJsonPath, [System.Text.Encoding]::UTF8)
    $verInfo = $raw | ConvertFrom-Json
    $Version = $verInfo.version
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

# ========================================
# Welcome
# ========================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DevFlow Plugin Installer v$Version" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This wizard will install DevFlow into your project directory."
Write-Host ""

# ========================================
# Ask for project path
# ========================================
$defaultPath = (Get-Location).Path
Write-Host "Enter the path to your project directory (where .devflow will be created):" -ForegroundColor White
Write-Host "Default: $defaultPath" -ForegroundColor DarkGray
$projectPath = Read-Host "Project path (press Enter for default)"

if (-not $projectPath) {
    $projectPath = $defaultPath
}

# Validate path
if (-not (Test-Path $projectPath)) {
    Write-Host ""
    $create = Read-Host "Directory does not exist. Create it? (Y/n)"
    if ($create -eq "" -or $create -eq "Y" -or $create -eq "y") {
        New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
        Write-Success "Created directory: $projectPath"
    } else {
        Write-Host "Installation cancelled." -ForegroundColor Red
        exit 1
    }
}

$projectPath = Resolve-Path $projectPath
$devflowDir = Join-Path $projectPath ".devflow"

# Check if .devflow already exists
if (Test-Path $devflowDir) {
    Write-Host ""
    Write-Warn ".devflow already exists at: $devflowDir"
    $overwrite = Read-Host "Overwrite? (y/N)"
    if ($overwrite -eq "y" -or $overwrite -eq "Y") {
        Remove-Item -Path $devflowDir -Recurse -Force
        Write-Success "Removed existing .devflow"
    } else {
        Write-Host "Installation cancelled." -ForegroundColor Red
        exit 1
    }
}

# ========================================
# Copy plugin files to .devflow/
# ========================================
Write-Header "Step 1: Copying DevFlow plugin files"

$excludeFiles = @("install.ps1", "install.bat")
$items = Get-ChildItem -Path $PluginDir

foreach ($item in $items) {
    if ($excludeFiles -contains $item.Name) {
        continue
    }
    $dst = Join-Path $devflowDir $item.Name
    if ($item.PSIsContainer) {
        Copy-Item -Path $item.FullName -Destination $dst -Recurse -Force
    } else {
        Copy-Item -Path $item.FullName -Destination $dst -Force
    }
    Write-Success "Copied: $($item.Name)"
}

Write-Success "DevFlow plugin files installed to: $devflowDir"

# ========================================
# Step 2: Install skills to TRAE Work
# ========================================
Write-Header "Step 2: Installing DevFlow skills to TRAE Work"

$TraeSkillsDir = "$env:USERPROFILE\.trae-cn\skills"

$skillMap = @{
    "devflow-init"                       = "devflow-init\SKILL.md"
    "devflow-phase-manager"              = "devflow-phase-manager\SKILL.md"
    "devflow-project-config"             = "devflow-project-config\SKILL.md"
    "project-development-workflow"       = "skills\L1\project-development-workflow.md"
    "project-document-management"        = "skills\L1\project-document-management.md"
    "project-role-management"             = "skills\L1\project-role-management.md"
    "version-planning-stage-execution"   = "skills\L2\version-planning-stage-execution.md"
    "requirements-stage-execution"       = "skills\L2\requirements-stage-execution.md"
    "design-stage-execution"              = "skills\L2\design-stage-execution.md"
    "coding-stage-execution"              = "skills\L2\coding-stage-execution.md"
    "testing-stage-execution"             = "skills\L2\testing-stage-execution.md"
    "operations-stage-execution"          = "skills\L2\operations-stage-execution.md"
    "project-coding-conventions"         = "skills\L3\project-coding-conventions.md"
    "code-static-quality-check"          = "skills\L3\code-static-quality-check.md"
    "code-logic-review"                  = "skills\L3\code-logic-review.md"
    "cicd-pipeline-management"           = "skills\L3\cicd-pipeline-management.md"
    "observability-standards"            = "skills\L3\observability-standards.md"
    "project-document-templates"         = "skills\L3\project-document-templates.md"
    "code-version-backup-management"     = "skills\L3\code-version-backup-management.md"
}

$skillCount = 0
$skillFail = 0

foreach ($skill in $skillMap.Keys | Sort-Object) {
    $src = Join-Path $devflowDir $skillMap[$skill]
    $dst = Join-Path $TraeSkillsDir "$skill\SKILL.md"

    if (Test-Path $src) {
        # Create backup of existing skill
        if (Test-Path $dst) {
            $timestamp = Get-Date -Format "yyyyMMddHHmmss"
            Copy-Item $dst "$dst.bak-$timestamp" -Force
        }
        # Ensure destination directory exists
        $dstDir = Split-Path $dst -Parent
        if (-not (Test-Path $dstDir)) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }
        Copy-Item $src $dst -Force
        Write-Success "Installed skill: $skill"
        $skillCount++
    } else {
        Write-Warn "Skill source not found: $skill"
        $skillFail++
    }
}

Write-Host ""
if ($skillFail -gt 0) {
    Write-Host "Skills installed: $skillCount succeeded, $skillFail failed" -ForegroundColor Yellow
} else {
    Write-Host "Skills installed: $skillCount succeeded" -ForegroundColor Green
}

# ========================================
# Step 3: Run setup.ps1 (interactive config generation)
# ========================================
Write-Header "Step 3: Running Setup"
$setupScript = Join-Path $devflowDir "setup.ps1"
if (Test-Path $setupScript) {
    Write-Host "Launching setup.ps1 for configuration...`n" -ForegroundColor White
    & $setupScript
} else {
    Write-Warn "setup.ps1 not found. Please run it manually:"
    Write-Host "  cd '$devflowDir'"
    Write-Host "  .\setup.ps1"
}

# ========================================
# Summary
# ========================================
Write-Header "Installation Complete"
Write-Host "DevFlow v$Version has been installed to your project." -ForegroundColor Green
Write-Host ""
Write-Host "Project:     $projectPath"
Write-Host "Plugin:      $devflowDir"
Write-Host "TRAE Skills: $TraeSkillsDir"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Open TRAE and invoke: devflow-init"
Write-Host "  2. Or run '.\update.ps1' in $devflowDir to update skills later"
Write-Host ""
Read-Host "Press Enter to exit"
