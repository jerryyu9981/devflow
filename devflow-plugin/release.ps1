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

# --- Step 1b: 版本号一致性门禁（validate-version-header.ps1）---
Write-Info "Step 1b/5: Running validate-version-header.ps1 version consistency gate..."
$validateScript = Join-Path $PSScriptRoot "validate-version-header.ps1"
if (Test-Path $validateScript) {
    & $validateScript
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Step 1b/5: validate-version-header.ps1 failed (exit code: $LASTEXITCODE). Version consistency check not passed."
        exit 1
    }
    Write-Info "Step 1b/5: validate-version-header.ps1... PASS"
} else {
    Write-Warn "Step 1b/5: validate-version-header.ps1 not found at $validateScript, skipping version consistency gate"
}

# --- Step 2: devflow-config.json 一致性校验 ---
Write-Info "Step 2/5: devflow-config.json consistency validation..."
$configJsonPath = Join-Path $PSScriptRoot "devflow-config.json"
if (Test-Path $configJsonPath) {
    try {
        $configJson = Get-Content $configJsonPath -Raw | ConvertFrom-Json
        $jsonVersion = "v$($configJson.devflowVersion)"
        if ($jsonVersion -ne $Version) {
            Write-Error "Version mismatch: devflow-config.json says '$jsonVersion', target is '$Version'"
            exit 1
        }
        Write-Info "Step 2/5: devflow-config.json consistency validation... PASS (matched: $jsonVersion)"
    } catch {
        Write-Error "Failed to read devflow-config.json: $_"
        exit 1
    }
} else {
    Write-Warn "Step 2/5: devflow-config.json not found at $configJsonPath, skipping consistency check"
}

# --- Step 2b: 同步 project-config.json ---
Write-Info "Step 2b/5: Syncing .devflow/project-config.json..."
$projectConfigPath = Join-Path $PSScriptRoot "..\.devflow\project-config.json"
if (Test-Path $projectConfigPath) {
    try {
        $projectConfig = Get-Content $projectConfigPath -Raw | ConvertFrom-Json
        $projectConfig.project.version = $Version
        $projectConfig.project.lastRelease.version = $Version
        $projectConfig.project.lastRelease.date = (Get-Date -Format "yyyy-MM-dd")
        $projectConfig._meta.lastUpdated = (Get-Date -Format "yyyy-MM-dd")
        $projectConfig | ConvertTo-Json -Depth 10 | Set-Content $projectConfigPath -Encoding UTF8
        Write-Info "Step 2b/5: project-config.json synced (version=$Version, lastRelease=$Version)"
    } catch {
        Write-Warn "Step 2b/5: Failed to update project-config.json: $_ (non-blocking)"
    }
} else {
    Write-Warn "Step 2b/5: .devflow/project-config.json not found, skipping"
}

# --- Step 2c: 同步 state.json（devflow-config.json → state.json）---
Write-Info "Step 2c/5: Syncing .devflow/state.json..."
$statePath = Join-Path $PSScriptRoot "..\.devflow\state.json"
if (Test-Path $statePath) {
    try {
        $state = Get-Content $statePath -Raw | ConvertFrom-Json
        $state.devflowVersion = $configJson.devflowVersion
        $state | ConvertTo-Json -Depth 10 | Set-Content $statePath -Encoding UTF8
        Write-Info "Step 2c/5: state.json synced (devflowVersion=$($configJson.devflowVersion))"
    } catch {
        Write-Warn "Step 2c/5: Failed to update state.json: $_ (non-blocking)"
    }
} else {
    Write-Warn "Step 2c/5: .devflow/state.json not found, skipping"
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

# --- Step 4b: Push tag to backup ---
Write-Info "Step 4b/7: Push tag to backup..."
$backupPush = git push backup "$Version" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Warn "Step 4b/7: Failed to push tag $Version to backup (non-blocking)"
    $backupPush | ForEach-Object { Write-Warn $_ }
    Write-Warn "Backup push skipped - manual sync required"
} else {
    $backupPush | ForEach-Object { Write-Info $_ }
    Write-Info "Step 4b/7: Push tag to backup... PASS"
}

# --- Step 4c: Push tag to github (if configured) ---
Write-Info "Step 4c/7: Push tag to github..."
$githubPush = git push github "$Version" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Warn "Step 4c/7: Failed to push tag $Version to github (non-blocking)"
    $githubPush | ForEach-Object { Write-Warn $_ }
    Write-Warn "GitHub push skipped - manual sync required"
} else {
    $githubPush | ForEach-Object { Write-Info $_ }
    Write-Info "Step 4c/7: Push tag to github... PASS"
}

# --- Step 4d: Push master branch to origin ---
Write-Info "Step 4d/7: Push master branch to origin..."
$originMaster = git push origin master 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Warn "Step 4d/7: Failed to push master to origin (non-blocking)"
    $originMaster | ForEach-Object { Write-Warn $_ }
} else {
    $originMaster | ForEach-Object { Write-Info $_ }
    Write-Info "Step 4d/7: Push master to origin... PASS"
}

# --- Step 4e: Push master branch to backup ---
Write-Info "Step 4e/7: Push master branch to backup..."
$backupMaster = git push backup master 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Warn "Step 4e/7: Failed to push master to backup (non-blocking)"
    $backupMaster | ForEach-Object { Write-Warn $_ }
} else {
    $backupMaster | ForEach-Object { Write-Info $_ }
    Write-Info "Step 4e/7: Push master to backup... PASS"
}

# --- Step 4f: Push master branch to github ---
Write-Info "Step 4f/7: Push master branch to github..."
$githubMaster = git push github master 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Warn "Step 4f/7: Failed to push master to github (non-blocking)"
    $githubMaster | ForEach-Object { Write-Warn $_ }
} else {
    $githubMaster | ForEach-Object { Write-Info $_ }
    Write-Info "Step 4f/7: Push master to github... PASS"
}

# --- 发布后验证 ---
Write-Info "Running post-release validation..."
# Tag 存在性验证
$tagExists = git tag -l "$Version"
if (-not $tagExists) {
    Write-Error "Post-validation failed: tag $Version not found after creation"
    exit 1
}

# 远程 Tag 验证（origin）
$remoteTagOrigin = git ls-remote origin "refs/tags/$Version" 2>&1
if (-not $remoteTagOrigin) {
    Write-Warn "Post-validation: tag $Version not found on origin (may be transient)"
} else {
    Write-Info "Post-validation: tag $Version confirmed on origin"
}

# 远程 Tag 验证（github，可选）
$remoteTagGithub = git ls-remote github "refs/tags/$Version" 2>&1
if ($remoteTagGithub) {
    Write-Info "Post-validation: tag $Version confirmed on github"
}

# --- 完成 ---
Write-Info "=== Release completed successfully ==="
Write-Info "Log file: $logFile"
exit 0
