# DevFlow Download Script (PowerShell)
# Usage: .\download-devflow.ps1 [-Action <Clone|Update|SetRepo>] [-RepoUrl <string>] [-TargetDir <string>]
#
# Description:
#   Download DevFlow plugin from cloud repository to local copy.
#   This is Step 1 of the "三步走" workflow (Download + Install + Init).
#
# Boundary:
#   - ✅ Only git operations (clone/pull/fetch)
#   - ❌ Does NOT call install.ps1 or setup.ps1
#   - ❌ Does NOT write to TRAE system directory
#   - ❌ Does NOT touch project directory
#
# Modes:
#   - Clone  : First-time git clone from cloud repo
#   - Update : (Default) git pull latest code
#   - SetRepo: Interactive repo URL setting, writes to devflow-config.json

param(
    [ValidateSet("Clone", "Update", "SetRepo")]
    [string]$Action = "Update",

    [string]$RepoUrl = "",

    [string]$TargetDir = ""
)

$ErrorActionPreference = "Stop"

# ─── Script Location ─────────────────────────────────────────────
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) {
    $ScriptDir = (Get-Location).Path
}

# ─── Read devflow-config.json (single source of truth) ──────────
$ConfigPath = Join-Path $ScriptDir "devflow-config.json"

function Read-DevflowConfig {
    if (Test-Path $ConfigPath) {
        $content = Get-Content $ConfigPath -Encoding UTF8 | ConvertFrom-Json
        return $content
    }
    return $null
}

function Write-DevflowConfig($jsonObj) {
    $jsonStr = $jsonObj | ConvertTo-Json -Depth 10
    # ConvertTo-Json doesn't preserve formatting, so we write with proper indentation
    $jsonStr | Set-Content $ConfigPath -Encoding UTF8
}

# ─── Helper Functions ────────────────────────────────────────────

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
    Write-Host "[ERR] $text" -ForegroundColor Red
}

function Write-Info($text) {
    Write-Host "[INFO] $text" -ForegroundColor DarkGray
}

# ─── Check Git Availability ──────────────────────────────────────

function Test-GitAvailable {
    try {
        $null = git --version
        return $true
    } catch {
        return $false
    }
}

# ─── SetRepo Mode ────────────────────────────────────────────────

function Invoke-SetRepoMode {
    Write-Header "SetRepo Mode: Set DevFlow Repository URL"

    # Read current devflow-config.json
    $config = Read-DevflowConfig
    if (-not $config) {
        Write-Err "devflow-config.json not found at $ConfigPath"
        return $false
    }

    # Show current values
    $currentRepo = if ($config.repository) { $config.repository } else { "" }
    $currentHomepage = if ($config.homepage) { $config.homepage } else { "" }
    Write-Host "Current repository: $(if ($currentRepo) { $currentRepo } else { '(empty)' })"
    Write-Host "Current homepage:   $(if ($currentHomepage) { $currentHomepage } else { '(empty)' })"
    Write-Host ""

    # Prompt for new repo URL (default to current value if exists)
    if ($currentRepo) {
        $newRepo = Read-Host "Enter DevFlow repository URL (default: $currentRepo)"
        if (-not $newRepo) {
            $newRepo = $currentRepo
            Write-Host "  Keeping current value: $currentRepo" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "No repository URL configured." -ForegroundColor Yellow
        Write-Host "Enter the Git repository URL where DevFlow plugin is hosted."
        Write-Host "Example: http://192.168.0.14/jerry.yu/devflow.git"
        Write-Host ""
        $newRepo = Read-Host "Enter DevFlow repository URL"
        if (-not $newRepo) {
            Write-Warn "Repository URL cannot be empty"
            return $false
        }
    }

    # Auto-generate homepage and bugs URL
    $newHomepage = $newRepo.TrimEnd('/')
    $newBugs = "$newHomepage/issues"

    # Update devflow-config.json
    $config | Add-Member -MemberType NoteProperty -Name "repository" -Value $newRepo -Force
    $config | Add-Member -MemberType NoteProperty -Name "homepage" -Value $newHomepage -Force
    $config | Add-Member -MemberType NoteProperty -Name "bugs" -Value $newBugs -Force

    Write-DevflowConfig $config

    Write-Success "Repository URL updated: $newRepo"
    Write-Success "Homepage URL updated:   $newHomepage"
    Write-Success "Bugs URL updated:       $newBugs"

    Write-Host ""
    Write-Host "Next step: Run '.\download-devflow.ps1 -Action Clone' to download DevFlow" -ForegroundColor Yellow
    return $true
}

# ─── Clone Mode ──────────────────────────────────────────────────

function Invoke-CloneMode {
    Write-Header "Clone Mode: Download DevFlow from Cloud Repository"

    # Read repo URL from devflow-config.json
    $config = Read-DevflowConfig
    $repoUrl = if ($config -and $config.repository) { $config.repository } else { "" }

    if (-not $repoUrl) {
        Write-Err "Repository URL not set in devflow-config.json"
        Write-Host "  Run '.\download-devflow.ps1 -Action SetRepo' first to set the repository URL" -ForegroundColor Yellow
        return $false
    }

    # Determine target directory
    if (-not $TargetDir) {
        $TargetDir = $ScriptDir
    }
    Write-Host "Repository: $repoUrl"
    Write-Host "Target directory: $TargetDir (default: current script directory)"
    Write-Host ""

    # Interactive confirmation for target directory
    $confirmDir = Read-Host "Clone to this directory? (Y/n)"
    if ($confirmDir -eq "n" -or $confirmDir -eq "N") {
        $customDir = Read-Host "Enter custom target directory"
        if ($customDir) {
            $TargetDir = $customDir
            Write-Host "  Target directory set to: $TargetDir" -ForegroundColor DarkGray
        } else {
            Write-Info "Clone cancelled"
            return $false
        }
    }

    # Check if target directory already has a git repo
    $gitDir = Join-Path $TargetDir ".git"
    if (Test-Path $gitDir) {
        Write-Warn "Target directory already has a Git repository: $TargetDir"
        Write-Host "  Use '.\download-devflow.ps1 -Action Update' to pull latest code instead" -ForegroundColor Yellow
        return $false
    }

    # Check if target directory is empty (or has only devflow-config.json)
    $existingItems = Get-ChildItem -Path $TargetDir -Force | Where-Object { $_.Name -ne "download-devflow.ps1" -and $_.Name -ne "devflow-config.json" }
    if ($existingItems) {
        Write-Warn "Target directory is not empty: $TargetDir"
        $confirm = Read-Host "Clone into this directory? It may overwrite existing files (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Info "Clone cancelled"
            return $false
        }
    }

    # Perform git clone
    Write-Host "Cloning from $repoUrl ..." -ForegroundColor Yellow
    try {
        $parentDir = Split-Path $TargetDir -Parent
        $dirName = Split-Path $TargetDir -Leaf

        # Clone into a temp directory first, then move contents
        $tempDir = Join-Path $env:TEMP "devflow-clone-$(Get-Random)"
        git clone $repoUrl $tempDir 2>&1 | ForEach-Object { Write-Host $_ }

        if ($LASTEXITCODE -ne 0) {
            Write-Err "Git clone failed (exit code: $LASTEXITCODE)"
            if (Test-Path $tempDir) { Remove-Item -Path $tempDir -Recurse -Force }
            return $false
        }

        # Copy cloned contents to target directory
        Write-Host "Copying to target directory: $TargetDir" -ForegroundColor Yellow
        Get-ChildItem -Path $tempDir -Force | ForEach-Object {
            $dest = Join-Path $TargetDir $_.Name
            if ($_.PSIsContainer) {
                Copy-Item -Path $_.FullName -Destination $dest -Recurse -Force
            } else {
                Copy-Item -Path $_.FullName -Destination $dest -Force
            }
        }

        # Clean up temp directory
        Remove-Item -Path $tempDir -Recurse -Force

        # DT-05: Verify manifest integrity after clone
        $manifestPath = Join-Path $TargetDir "devflow-manifest.json"
        if (Test-Path $manifestPath) {
            try {
                $manifest = Get-Content $manifestPath -Encoding UTF8 | ConvertFrom-Json
                $missingFiles = @()
                foreach ($s in $manifest.skills) {
                    if ($s.required) {
                        $f = Join-Path $TargetDir $s.source
                        if (-not (Test-Path $f)) { $missingFiles += "$($s.name): $($s.source)" }
                    }
                }
                if ($missingFiles.Count -gt 0) {
                    Write-Warn "MANIFEST CHECK: $($missingFiles.Count) required file(s) missing"
                    $missingFiles | ForEach-Object { Write-Warn "  missing: $_" }
                } else {
                    Write-Success "Manifest integrity: $($manifest.skills.Count) files OK"
                }
            } catch {
                Write-Warn "Manifest check skipped (parse error): $_"
            }
        } else {
            Write-Warn "devflow-manifest.json not found, skipping integrity check"
        }

        Write-Success "DevFlow downloaded successfully to $TargetDir"
        Write-Host ""
        Write-Host "Next step: Run 'install.bat' to install DevFlow to TRAE" -ForegroundColor Yellow
        return $true
    } catch {
        Write-Err "Clone failed: $_"
        return $false
    }
}

# ─── Update Mode ─────────────────────────────────────────────────

function Invoke-UpdateMode {
    Write-Header "Update Mode: Pull Latest DevFlow Code"

    # Determine target directory
    if (-not $TargetDir) {
        $TargetDir = $ScriptDir
    }

    # Check if target directory is a git repo
    $gitDir = Join-Path $TargetDir ".git"
    if (-not (Test-Path $gitDir)) {
        Write-Warn "Not a Git repository: $TargetDir"
        Write-Host "  Run '.\download-devflow.ps1 -Action Clone' first to download DevFlow" -ForegroundColor Yellow
        return $false
    }

    # Stash any local changes before pulling
    Write-Host "Stashing local changes (if any)..." -ForegroundColor DarkGray
    git -C $TargetDir stash 2>&1 | Out-Null

    # Perform git pull
    Write-Host "Pulling latest code from remote..." -ForegroundColor Yellow
    try {
        $pullOutput = git -C $TargetDir pull 2>&1
        $pullOutput | ForEach-Object { Write-Host $_ }

        if ($LASTEXITCODE -ne 0) {
            Write-Err "Git pull failed (exit code: $LASTEXITCODE)"
            return $false
        }

        # Check if already up to date
        $alreadyUpToDate = $pullOutput -match "Already up to date"
        if ($alreadyUpToDate) {
            Write-Success "DevFlow is already up to date"
        } else {
            Write-Success "DevFlow updated successfully"
        }

        # Restore stashed changes (if any)
        $stashList = git -C $TargetDir stash list 2>&1
        if ($stashList) {
            Write-Host "Restoring local changes..." -ForegroundColor DarkGray
            git -C $TargetDir stash pop 2>&1 | Out-Null
        }

        # Show current version
        $config = Read-DevflowConfig
        if ($config -and $config.devflowVersion) {
            Write-Host "Current DevFlow version: v$($config.devflowVersion)" -ForegroundColor Green
        }

        Write-Host ""
        Write-Host "Next step: Run 'update-devflow.bat' to install the updated version to TRAE" -ForegroundColor Yellow
        return $true
    } catch {
        Write-Err "Update failed: $_"
        return $false
    }
}

# ─── Main Execution ──────────────────────────────────────────────

Write-Host ""
Write-Host "  DevFlow Downloader v2.8.0" -ForegroundColor Cyan
Write-Host "  Action: $Action" -ForegroundColor DarkGray
Write-Host ""

# Check git availability (skip for SetRepo mode)
if ($Action -ne "SetRepo") {
    if (-not (Test-GitAvailable)) {
        Write-Err "Git is not installed or not in PATH"
        Write-Host "  Please install Git from https://git-scm.com/downloads" -ForegroundColor Yellow
        exit 1
    }
}

# Route to the appropriate mode
$success = $false
switch ($Action) {
    "SetRepo" { $success = Invoke-SetRepoMode }
    "Clone"   { $success = Invoke-CloneMode }
    "Update"  { $success = Invoke-UpdateMode }
}

# Final summary
Write-Header "Summary"
if ($success) {
    Write-Success "Action '$Action' completed successfully"
} else {
    Write-Err "Action '$Action' failed or was cancelled"
    exit 1
}