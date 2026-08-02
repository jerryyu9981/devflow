<#
.SYNOPSIS
    DevFlow 文件头版本号一致性验证脚本
.DESCRIPTION
    双重验证：
    [Phase 1] JSON 配置文件版本号一致性校验
      验证 devflow-config.json / project-config.json / state.json
      三份配置文件的版本号必须一致（devflow-config.json 的 devflowVersion 为唯一事实源）
    [Phase 2] .md 文件头版本号一致性（原有）
      扫描 doc/ 目录下所有 .md 文件，检查文件头声明的版本号
      与修订历史底部最新版本号是否一致
#>

$RootDir = Split-Path $PSScriptRoot -Parent
$violations = @()
$exitCode = 0

# ============================================================
# Phase 1: JSON 配置文件版本号一致性校验
# ============================================================
Write-Host "--- Phase 1: JSON version consistency ---" -ForegroundColor Cyan

$jsonChecks = @(
    @{ Path = "devflow-plugin/devflow-config.json"; Field = "devflowVersion"; Label = "devflow-config (authoritative)" },
    @{ Path = ".devflow/project-config.json";        Field = "project.version";  Label = "project-config (project.version)" },
    @{ Path = ".devflow/project-config.json";        Field = "project.lastRelease.version"; Label = "project-config (lastRelease)" },
    @{ Path = ".devflow/state.json";                 Field = "devflowVersion";   Label = "state.json" }
)

$jsonVersions = @{}
$firstVersion = $null
$firstLabel = ""

foreach ($check in $jsonChecks) {
    $fullPath = Join-Path $RootDir $check.Path
    $label = $check.Label
    $fieldPath = $check.Field

    if (-not (Test-Path $fullPath)) {
        Write-Host "  [SKIP] $label -- file not found" -ForegroundColor DarkGray
        continue
    }

    try {
        $json = Get-Content $fullPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $value = $json
        foreach ($key in $fieldPath.Split('.')) {
            $value = $value.$key
        }
        if ($null -eq $value) { throw "field not found" }

        $clean = "$value" -replace '^v', ''
        $jsonVersions[$label] = $clean

        if ($null -eq $firstVersion) {
            $firstVersion = $clean
            $firstLabel = $label
        } elseif ($clean -ne $firstVersion) {
            $violations += [PSCustomObject]@{
                File = $check.Path
                Type = "JSON version mismatch"
                Expected = "v$firstVersion ($firstLabel)"
                Actual = "v$clean ($label)"
            }
            $exitCode = 1
        }
    } catch {
        $violations += [PSCustomObject]@{
            File = $check.Path
            Type = "JSON read error"
            Expected = "-"
            Actual = "$_"
        }
        $exitCode = 1
    }
}

if ($jsonVersions.Count -gt 0) {
    $consistent = ($jsonVersions.Values | Select-Object -Unique).Count -eq 1
    foreach ($entry in $jsonVersions.GetEnumerator()) {
        $icon = if ($consistent) { "[OK]" } else { "[ERR]" }
        Write-Host "  $icon $($entry.Key): v$($entry.Value)"
    }
    if ($consistent) {
        Write-Host "  [PASS] All JSON configs consistent" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] JSON configs inconsistent" -ForegroundColor Yellow
    }
}

# ============================================================
# Phase 2: .md 文件头版本号一致性（原有逻辑保留）
# ============================================================
Write-Host ""
Write-Host "--- Phase 2: .md header consistency ---" -ForegroundColor Cyan

$DocDir = Join-Path $RootDir "doc"
$excludePatterns = @('node_modules', 'archive', '.trae', '_shared', 'README')

if (-not (Test-Path $DocDir)) {
    Write-Host "[ERROR] doc/ not found: $DocDir" -ForegroundColor Red
    $exitCode = 1
} else {
    $files = Get-ChildItem -Path $DocDir -Recurse -Filter "*.md" -File
    $mdViolations = @()

    foreach ($file in $files) {
        $skip = $false
        foreach ($pat in $excludePatterns) {
            if ($file.FullName -match [regex]::Escape($pat)) { $skip = $true; break }
        }
        if ($skip) { continue }

        $content = Get-Content $file.FullName -Raw
        if (-not $content) { continue }

        $headerVersion = if ($content -match '(?m)^>\s*版本：v(\d+\.\d+\.\d+)') { $matches[1] } else { $null }
        $historyVersion = if ($content -match '(?m)^\| v(\d+\.\d+\.\d+) \|') { $matches[1] } else { $null }

        if ($headerVersion -and $historyVersion -and ($headerVersion -ne $historyVersion)) {
            $mdViolations += [PSCustomObject]@{
                File = $file.FullName
                HeaderVersion = "v$headerVersion"
                HistoryVersion = "v$historyVersion"
            }
        }
    }

    if ($mdViolations.Count -eq 0) {
        Write-Host "  [PASS] All .md files consistent ($($files.Count) scanned)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $($mdViolations.Count) .md file(s) inconsistent:" -ForegroundColor Yellow
        $mdViolations | Format-Table File, HeaderVersion, HistoryVersion -AutoSize
        $exitCode = 1
        $violations += $mdViolations
    }
}

# ============================================================
# Summary
# ============================================================
Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "[PASS] validate-version-header: zero violations" -ForegroundColor Green
} else {
    Write-Host "[FAIL] validate-version-header: $($violations.Count) issue(s) found" -ForegroundColor Yellow
}
exit $exitCode
