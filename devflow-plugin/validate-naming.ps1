<#
.SYNOPSIS
    DevFlow 文档命名规范验证脚本
.DESCRIPTION
    扫描 doc/ 目录下所有 .md 文件，检查是否符合 {项目名}-{文档类型}-v{版本号}.md 命名格式
    输出违规文件名清单。
.EXAMPLE
    .\validate-naming.ps1
#>

$ProjectName = "DevFlow"
$DocDir = Join-Path (Split-Path $PSScriptRoot -Parent) "doc"
$violations = @()

if (-not (Test-Path $DocDir)) {
    Write-Host "[ERROR] doc/ 目录不存在: $DocDir" -ForegroundColor Red
    exit 1
}

$files = Get-ChildItem -Path $DocDir -Recurse -Filter "*.md" -File
$excludePatterns = @('node_modules', 'archive', '.trae', '_shared', 'README', 'DevFlow-阶段审计报告')

foreach ($file in $files) {
    $skip = $false
    foreach ($pat in $excludePatterns) {
        if ($file.FullName -match [regex]::Escape($pat)) { $skip = $true; break }
    }
    if ($skip) { continue }

    $name = $file.BaseName
    # 标准格式: DevFlow-{类型}-v{版本}.md
    if ($name -notmatch "^${ProjectName}-.+-v\d+\.\d+\.\d+$" -and
        $name -notmatch "^${ProjectName}-.+-\d+\.\d+\.\d+$" -and
        $name -notmatch "^DevFlow-技术债务总表$" -and
        $name -notmatch "^DevFlow-候选需求池$" -and
        $name -notmatch "^DevFlow-版本规划总纲$" -and
        $name -notmatch "^DevFlow-版本迭代路线图$" -and
        $name -notmatch "^DevFlow-版本范围变更总记录$" -and
        $name -notmatch "^DevFlow-版本发布策略总则$") {
        $violations += $file.FullName
    }
}

if ($violations.Count -eq 0) {
    Write-Host "✅ validate-naming: 零命名违规 ($($files.Count) 文件扫描)" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ validate-naming: $($violations.Count) 个命名违规:" -ForegroundColor Yellow
    foreach ($v in $violations) { Write-Host "  $v" -ForegroundColor DarkGray }
    exit 1
}
