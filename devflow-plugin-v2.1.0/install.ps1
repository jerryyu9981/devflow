# DevFlow Plugin Installer for Windows
# Usage: Right-click -> "Run with PowerShell" or double-click install.bat

$ErrorActionPreference = "Stop"

# Get the directory where this script is located (plugin bundle root)
$PluginDir = $PSScriptRoot

# Read version
$VersionJsonPath = Join-Path $PluginDir "version.json"
$Version = "unknown"
if (Test-Path $VersionJsonPath) {
    $verInfo = Get-Content $VersionJsonPath | ConvertFrom-Json
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

# Welcome
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DevFlow Plugin Installer v$Version" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This wizard will install DevFlow into your project directory."
Write-Host ""

# Ask for project path
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

# Copy plugin files
Write-Header "Installing DevFlow"

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

Write-Success "DevFlow installed to: $devflowDir"

# Run setup.ps1
Write-Header "Running Setup"
$setupScript = Join-Path $devflowDir "setup.ps1"
if (Test-Path $setupScript) {
    Write-Host "Launching setup.ps1...`n" -ForegroundColor White
    & $setupScript
} else {
    Write-Warn "setup.ps1 not found. Please run it manually:"
    Write-Host "  cd '$devflowDir'"
    Write-Host "  .\setup.ps1"
}

# Summary
Write-Header "Installation Complete"
Write-Host "DevFlow v$Version has been installed to your project." -ForegroundColor Green
Write-Host ""
Write-Host "Project:  $projectPath"
Write-Host "DevFlow:  $devflowDir"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Open TRAE and invoke: 璋冪敤 devflow-init 鎶€鑳?
Write-Host "  2. Or run '.\update.ps1' in $devflowDir to update skills"
Write-Host ""
Read-Host "Press Enter to exit"
