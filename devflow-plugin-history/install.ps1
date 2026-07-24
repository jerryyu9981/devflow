# DevFlow Plugin Installer for Windows
# Usage: Right-click -> "Run with PowerShell" or double-click install.bat

$ErrorActionPreference = "Continue"

# Get the directory where this script is located (plugin bundle root)
$PluginDir = $PSScriptRoot

# Read version
$VersionJsonPath = Join-Path $PluginDir "version.json"
$Version = "unknown"
if (Test-Path $VersionJsonPath) {
    $verInfo = Get-Content $VersionJsonPath -Encoding UTF8 | ConvertFrom-Json
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

function Write-Err($text) {
    Write-Host "[ERROR] $text" -ForegroundColor Red
}

# Welcome
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DevFlow Plugin Installer v$Version" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This wizard will install DevFlow into your project directory."
Write-Host "DevFlow will be installed as a .devflow/ subfolder inside your project."
Write-Host ""

# Prevent running from inside a .devflow directory
$pluginDirName = Split-Path $PluginDir -Leaf
$cwd = (Get-Location).Path
if ($pluginDirName -eq ".devflow" -or $cwd -match "\.devflow[\\/]?$") {
    Write-Host ""
    Write-Err "You are running the installer from inside a .devflow directory."
    Write-Host ""
    Write-Host "Correct usage:" -ForegroundColor White
    Write-Host "  1. Copy or extract this folder to any location (e.g., Desktop)"
    Write-Host "  2. Run install.bat from that location"
    Write-Host "  3. Enter your PROJECT directory path when prompted (e.g., D:\MyProject)"
    Write-Host "  4. DevFlow will create .devflow/ inside that project directory"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Ask for project path
Write-Host "Enter the path to your project directory:" -ForegroundColor White
Write-Host "(A .devflow folder will be created inside it)"
Write-Host ""
$projectPath = Read-Host "Project path"

if (-not $projectPath) {
    Write-Err "Project path is required."
    Write-Host ""
    Write-Host "Example: D:\MyProject"
    Write-Host "DevFlow will create D:\MyProject\.devflow\"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Reject paths ending with .devflow
if ($projectPath -match "\.devflow[\\/]?$") {
    Write-Err "The project path should NOT end with .devflow"
    Write-Host "Enter the parent project directory instead."
    Write-Host "Example: D:\MyProject (not D:\MyProject\.devflow)"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
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

$projectPath = (Resolve-Path $projectPath).Path
$devflowDir = Join-Path $projectPath ".devflow"

# Check if .devflow already exists
if (Test-Path $devflowDir) {
    Write-Host ""
    Write-Warn ".devflow already exists at: $devflowDir"
    $overwrite = Read-Host "Overwrite? (y/N)"
    if ($overwrite -eq "y" -or $overwrite -eq "Y") {
        # Retry loop for file-in-use errors
        $maxRetries = 3
        for ($i = 1; $i -le $maxRetries; $i++) {
            try {
                Remove-Item -Path $devflowDir -Recurse -Force -ErrorAction Stop
                Write-Success "Removed existing .devflow"
                break
            } catch {
                if ($i -lt $maxRetries) {
                    Write-Warn "Retry $i/$maxRetries - some files are locked, closing handles..."
                    Start-Sleep -Seconds 2
                } else {
                    Write-Err "Cannot remove .devflow after $maxRetries attempts."
                    Write-Err "Please close any programs using files in $devflowDir and try again."
                    Write-Host ""
                    Read-Host "Press Enter to exit"
                    exit 1
                }
            }
        }
    } else {
        Write-Host "Installation cancelled." -ForegroundColor Red
        exit 1
    }
}

# Create .devflow directory
New-Item -ItemType Directory -Path $devflowDir -Force | Out-Null

# Copy plugin files
Write-Header "Installing DevFlow"

$excludeFiles = @("install.ps1", "install.bat")
$items = Get-ChildItem -Path $PluginDir

$copyCount = 0
foreach ($item in $items) {
    if ($excludeFiles -contains $item.Name) {
        continue
    }
    $dst = Join-Path $devflowDir $item.Name
    try {
        if ($item.PSIsContainer) {
            Copy-Item -Path $item.FullName -Destination $dst -Recurse -Force -ErrorAction Stop
        } else {
            Copy-Item -Path $item.FullName -Destination $dst -Force -ErrorAction Stop
        }
        Write-Success "Copied: $($item.Name)"
        $copyCount++
    } catch {
        Write-Warn "Failed to copy: $($item.Name) - $_"
    }
}

Write-Success "DevFlow installed to: $devflowDir ($copyCount items)"

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
Write-Host "  1. Open TRAE and invoke: devflow-init"
Write-Host "  2. Or run '.\update.ps1' in $devflowDir to update skills"
Write-Host ""
Read-Host "Press Enter to exit"
