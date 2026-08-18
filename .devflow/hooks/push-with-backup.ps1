<#
.SYNOPSIS
    DevFlow Push-with-Backup (PowerShell alternative to Git pre-push hook)
.DESCRIPTION
    Wraps 'git push' with automatic mirror to backup and github remotes.
    Use this when you want explicit control over the backup process,
    or when the Git pre-push hook's background process is unreliable.
.EXAMPLE
    .\.devflow\hooks\push-with-backup.ps1 origin master
    Pushes to origin, then mirrors to backup and github.
.EXAMPLE
    .\.devflow\hooks\push-with-backup.ps1
    Pushes to origin (default), then mirrors to backup and github.
.NOTES
    Log file: .devflow/logs/backup-hook.log
#>

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$PushArgs
)

$ErrorActionPreference = "Continue"
$LogFile = ".devflow\logs\backup-hook.log"
$Ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

# Ensure log directory exists
$logDir = Split-Path $LogFile -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message)
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
    Write-Host $line
}

# Default args
if ($PushArgs.Count -eq 0) {
    $PushArgs = @('origin')
}

Write-Log "========================================"
Write-Log "[POWERSHELL] push-with-backup started. Args: $($PushArgs -join ' ')"

# Get pre-push SHA
$PreSha = git rev-parse HEAD 2>$null
Write-Log "[PRE-PUSH] HEAD SHA: $PreSha"

# --- Phase 1: Main push ---
& git push @PushArgs
$pushExit = $LASTEXITCODE

if ($pushExit -ne 0) {
    Write-Log "[PUSH-FAIL] Main push failed (exit: $pushExit). Skipping backup."
    Write-Log "========================================"
    exit $pushExit
}

Write-Log "[PUSH-OK] Main push succeeded."

# --- Phase 2: Mirror to backup ---
if (git remote | Select-String -Pattern '^backup$' -Quiet) {
    Write-Log "[BACKUP-START] Mirroring to backup remote..."

    $mirrorOutput = & git push --no-verify --mirror backup 2>&1  # --no-verify: 防止 mirror push 递归触发 pre-push hook（F-217-501）
    $mirrorExit = $LASTEXITCODE

    if ($mirrorExit -eq 0) {
        Write-Log "[BACKUP-OK] Mirror to backup succeeded."

        # SHA verification
        $backupSha = (git ls-remote backup HEAD 2>$null) -split '\s+' | Select-Object -First 1
        if ($PreSha -and $backupSha -and ($PreSha -eq $backupSha)) {
            Write-Log "[SHA-VERIFY] PASS - backup HEAD matches local HEAD ($backupSha)"
        } else {
            Write-Log "[SHA-VERIFY] WARN - local: $PreSha, backup: $backupSha"
        }
    } else {
        Write-Log "[BACKUP-FAIL] Mirror to backup FAILED (exit: $mirrorExit)"
        Write-Log "[BACKUP-ERROR] $mirrorOutput"
    }
} else {
    Write-Log "[WARN] 'backup' remote not configured. Skipping backup mirror."
}

# --- Phase 3: Mirror to github (optional) ---
if (git remote | Select-String -Pattern '^github$' -Quiet) {
    Write-Log "[GITHUB-START] Mirroring to github remote..."

    $ghOutput = & git push --no-verify --mirror github 2>&1  # --no-verify: 防止 mirror push 递归触发 pre-push hook（F-217-501）
    $ghExit = $LASTEXITCODE

    if ($ghExit -eq 0) {
        Write-Log "[GITHUB-OK] Mirror to github succeeded."
    } else {
        Write-Log "[GITHUB-FAIL] Mirror to github FAILED (exit: $ghExit)"
        Write-Log "[GITHUB-ERROR] $ghOutput"
    }
}

Write-Log "[DONE] push-with-backup finished."

# --- Phase 4: Remote tag consistency check (v2.18.0+ / F-217-501) ---
# 比较 origin/backup/github 三远程的 tag 解引用一致性，防止 mirror 漂移
$tagToCheck = git describe --tags --abbrev=0 2>$null
if ($tagToCheck) {
    Write-Log "[TAG-CHECK] Checking tag consistency for: $tagToCheck"
    $tagRefs = @{}
    foreach ($remote in @('origin', 'backup', 'github')) {
        if (git remote | Select-String -Pattern "^$remote$" -Quiet) {
            $tagSha = (git ls-remote $remote "refs/tags/$tagToCheck^{}" 2>$null) -split '\s+' | Select-Object -First 1
            if (-not $tagSha) { $tagSha = (git ls-remote $remote "refs/tags/$tagToCheck" 2>$null) -split '\s+' | Select-Object -First 1 }
            $tagRefs[$remote] = $tagSha
        }
    }
    $uniqueShas = ($tagRefs.Values | Sort-Object -Unique).Count
    if ($uniqueShas -eq 1 -and $tagRefs.Count -ge 2) {
        Write-Log "[TAG-CHECK] PASS - all remotes have identical tag ($($tagRefs.Values | Select-Object -First 1))"
    } else {
        Write-Log "[TAG-CHECK] WARN - tag mismatch across remotes: $($tagRefs | ConvertTo-Json -Compress)"
    }
}

Write-Log "========================================"
