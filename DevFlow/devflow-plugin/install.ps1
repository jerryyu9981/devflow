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
    $Version = $verInfo.devflowVersion
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
# 更新欢迎文字
Write-Host "This wizard will install DevFlow skills into your TRAE environment."
Write-Host ""

# 保留 .devflow 目录自检（安全检测）
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

# ─── Run setup.ps1 directly from current directory ─────────────

Write-Host ""
Write-Header "Installing DevFlow Skills to TRAE"

$setupScript = Join-Path $PluginDir "setup.ps1"
if (Test-Path $setupScript) {
    Write-Host "Launching setup.ps1...`n" -ForegroundColor White
    & $setupScript
} else {
    Write-Err "setup.ps1 not found alongside this installer."
    Write-Host "  Expected at: $setupScript"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# ─── Summary ────────────────────────────────────────────────────

Write-Header "Installation Complete"
Write-Host "DevFlow v$Version has been installed to TRAE." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Restart TRAE IDE to load new skills"
Write-Host "  2. Open your project in TRAE and invoke: devflow-init"
Write-Host ""
Read-Host "Press Enter to exit"
