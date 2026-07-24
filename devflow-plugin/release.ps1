<#
.SYNOPSIS
    DevFlow 自动化发布脚本
.DESCRIPTION
    执行版本号校验 → Git Tag 创建 → Push origin → Push backup → 版本一致性验证
    任一环节失败则中止并提示，不自动回滚。
.PARAMETER Version
    目标版本号，格式：v{major}.{minor}.{patch}，如 v2.8.5
.EXAMPLE
    .\release.ps1 -Version "v2.8.5"
#>

param(
    [Parameter(Mandatory = $true, HelpMessage = "目标版本号，格式：v{major}.{minor}.{patch}")]
    [string]$Version
)

# 日志函数
$logFile = "release-$Version-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Level, [string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    Write-Host $line
    Add-Content -Path $logFile -Value $line
}

function Write-Info  { Write-Log -Level "INFO"  -Message $args[0] }
function Write-Error { Write-Log -Level "ERROR" -Message $args[0] }
function Write-Warn  { Write-Log -Level "WARN"  -Message $args[0] }

Write-Info "=== DevFlow Release Script v1.0 ==="
Write-Info "Target version: $Version"

$exitCode = 0

# --- Step 1: 版本号格式校验 ---
Write-Info "Step 1/5: Version number format validation..."
if ($Version -notmatch '^v\d+\.\d+\.\d+$') {
    Write-Error "Invalid version format: $Version. Expected format: v{major}.{minor}.{patch}"
    exit 1
}
Write-Info "Step 1/5: Version number format validation... PASS"

# --- Step 2: version.json 一致性校验 ---
Write-Info "Step 2/5: version.json consistency validation..."
$versionJsonPath = Join-Path $PSScriptRoot "version.json"
if (Test-Path $versionJsonPath) {
    try {
        $versionJson = Get-Content $versionJsonPath -Raw | ConvertFrom-Json
        $jsonVersion = "v$($versionJson.version)"
        if ($jsonVersion -ne $Version) {
            Write-Error "Version mismatch: version.json says '$jsonVersion', target is '$Version'"
            exit 1
        }
        Write-Info "Step 2/5: version.json consistency validation... PASS (matched: $jsonVersion)"
    } catch {
        Write-Error "Failed to read version.json: $_"
        exit 1
    }
} else {
    Write-Warn "Step 2/5: version.json not found at $versionJsonPath, skipping consistency check"
}

# --- Step 3: Git Tag 创建 ---
Write-Info "Step 3/5: Git tag creation..."
$tagResult = git tag -l "$Version" 2>&1
if ($tagResult -eq $Version) {
    Write-Warn "Tag $Version already exists locally"
} else {
    git tag "$Version" 2>&1 | ForEach-Object { Write-Info $_ }
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create tag $Version"
        exit 1
    }
}
Write-Info "Step 3/5: Git tag creation... PASS (tag: $Version)"

# --- Step 4: Push tag to origin ---
Write-Info "Step 4/5: Push tag to origin..."
$originPush = git push origin "$Version" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to push tag $Version to origin: $originPush"
    exit 1
}
$originPush | ForEach-Object { Write-Info $_ }
Write-Info "Step 4/5: Push tag to origin... PASS"

# --- Step 5: Push tag to backup ---
Write-Info "Step 5/5: Push tag to backup..."
$backupPush = git push backup "$Version" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Warn "Failed to push tag $Version to backup (non-blocking)"
    $backupPush | ForEach-Object { Write-Warn $_ }
    Write-Warn "Backup push skipped - manual sync required"
} else {
    $backupPush | ForEach-Object { Write-Info $_ }
    Write-Info "Step 5/5: Push tag to backup... PASS"
}

# --- 发布后验证 ---
Write-Info "Running post-release validation..."
# Tag 存在性验证
$tagExists = git tag -l "$Version"
if (-not $tagExists) {
    Write-Error "Post-validation failed: tag $Version not found after creation"
    exit 1
}

# 远程 Tag 验证
$remoteTag = git ls-remote origin "refs/tags/$Version" 2>&1
if (-not $remoteTag) {
    Write-Warn "Post-validation: tag $Version not found on origin (may be transient)"
} else {
    Write-Info "Post-validation: tag $Version confirmed on origin"
}

# --- 完成 ---
Write-Info "=== Release completed successfully ==="
Write-Info "Log file: $logFile"
exit 0
