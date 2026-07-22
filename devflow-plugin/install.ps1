# DevFlow Plugin Installer for Windows
# Usage: Right-click -> "Run with PowerShell" or double-click install.bat
#
# 三步走架构 - 首次安装流程：Download + Setup
#   Step 1 (Download): 调用 download-devflow.ps1 从云端仓库下载
#   Step 2 (Setup):    从本地副本安装 DevFlow 技能到 TRAE 系统目录

param(
    [string]$TargetDir = ""
)

$ErrorActionPreference = "Continue"

# Get the directory where this script is located (plugin bundle root)
$PluginDir = $PSScriptRoot

# Resolve effective target directory
$EffectiveDir = if ($TargetDir) { $TargetDir } else { $PluginDir }

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
Write-Host "This wizard will:" -ForegroundColor White
Write-Host "  Step 1: Download DevFlow from cloud repository (via download-devflow.ps1)"
Write-Host "  Step 2: Install DevFlow skills to TRAE system directory"
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

# ─── Step 1: Download (via download-devflow.ps1) ──────────────────
$DownloadScript = Join-Path $PluginDir "download-devflow.ps1"

if (Test-Path $DownloadScript) {
    # Read repository URL from version.json
    $RepoUrl = ""
    if (Test-Path $VersionJsonPath) {
        $verInfo = Get-Content $VersionJsonPath -Encoding UTF8 | ConvertFrom-Json
        $RepoUrl = if ($verInfo.repository) { $verInfo.repository } else { "" }
    }

    # Check if already a git repo (already downloaded)
    $gitDir = Join-Path $EffectiveDir ".git"
    if (Test-Path $gitDir) {
        Write-Header "Step 1/2: Download (Skipped)"
        Write-Success "Local copy already exists (git repository detected)"
        Write-Host "  To update: run update-devflow.bat instead"
        Write-Host ""
    } elseif ($RepoUrl) {
        # Repository configured → Clone
        Write-Header "Step 1/2: Download DevFlow from Cloud Repository"
        Write-Host "Calling download-devflow.ps1 -Action Clone..."
        & $DownloadScript -Action Clone -TargetDir $EffectiveDir
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "Download failed. Using local files only."
        } else {
            # Re-read version after download
            if (Test-Path $VersionJsonPath) {
                $verInfo = Get-Content $VersionJsonPath -Encoding UTF8 | ConvertFrom-Json
                $Version = $verInfo.devflowVersion
            }
        }
        Write-Host ""
    } else {
        # Repository not configured → Guide user to SetRepo
        Write-Header "Step 1/2: Configure Cloud Repository"
        Write-Warn "No repository URL configured in version.json"
        Write-Host ""
        Write-Host "DevFlow supports downloading from a cloud Git repository." -ForegroundColor White
        Write-Host "Let's set up the repository URL now." -ForegroundColor White
        Write-Host ""

        & $DownloadScript -Action SetRepo
        if ($LASTEXITCODE -eq 0) {
            # Re-read repository after SetRepo
            if (Test-Path $VersionJsonPath) {
                $verInfo = Get-Content $VersionJsonPath -Encoding UTF8 | ConvertFrom-Json
                $RepoUrl = if ($verInfo.repository) { $verInfo.repository } else { "" }
            }

            if ($RepoUrl) {
                Write-Host ""
                Write-Host "Repository configured. Starting download..." -ForegroundColor White
                & $DownloadScript -Action Clone -TargetDir $EffectiveDir
                if ($LASTEXITCODE -ne 0) {
                    Write-Warn "Download failed. Using local files only."
                } else {
                    if (Test-Path $VersionJsonPath) {
                        $verInfo = Get-Content $VersionJsonPath -Encoding UTF8 | ConvertFrom-Json
                        $Version = $verInfo.devflowVersion
                    }
                }
            }
        } else {
            Write-Warn "Repository setup cancelled. Using local files only."
        }
        Write-Host ""
    }
} else {
    Write-Header "Step 1/2: Download (Skipped)"
    Write-Warn "download-devflow.ps1 not found. Using local files only."
    Write-Host ""
}

# ─── Step 2: Setup - Install skills to TRAE ─────────────────────

Write-Header "Step 2/2: Install DevFlow Skills to TRAE"
$setupScript = Join-Path $PluginDir "setup.ps1"
if (Test-Path $setupScript) {
    Write-Host "Launching setup.ps1...`n" -ForegroundColor White
    & $setupScript
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Setup failed with exit code $LASTEXITCODE"
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
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
Write-Host "To update DevFlow in the future:"
Write-Host "  - Run update-devflow.bat (download + setup in one step)"
Write-Host ""
Read-Host "Press Enter to exit"

exit 0