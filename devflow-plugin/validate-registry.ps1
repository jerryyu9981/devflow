<#
.SYNOPSIS
    DevFlow 技能引用注册验证脚本
.DESCRIPTION
    扫描所有技能文件中的引用，与 devflow-config.json 中的注册清单对比，
    输出未注册的引用清单。零未注册引用为通过标准。
.EXAMPLE
    .\validate-registry.ps1
#>

$ErrorActionPreference = "Continue"

# 配置路径
$ScriptDir = $PSScriptRoot
$PluginSkillsDir = Join-Path $ScriptDir "skills"
$ConfigPath = Join-Path $ScriptDir "devflow-config.json"

if (-not (Test-Path $ConfigPath)) {
    Write-Host "[ERROR] devflow-config.json not found at $ConfigPath" -ForegroundColor Red
    exit 1
}

# 读取注册清单
$config = Get-Content $ConfigPath -Encoding UTF8 | ConvertFrom-Json
$registeredSkills = @{}
foreach ($s in $config.skills) {
    $registeredSkills[$s.name] = $s.source
}

Write-Host "=== DevFlow 技能引用注册验证 ===" -ForegroundColor Cyan
Write-Host "注册技能数: $($registeredSkills.Count)"

$unregisteredRefs = @{}
$totalRefs = 0

# 扫描 L2 和 L3 技能文件
$skillFiles = Get-ChildItem -Path $PluginSkillsDir -Recurse -Filter "*.md"
foreach ($file in $skillFiles) {
    $content = Get-Content $file.FullName -Encoding UTF8
    $relativePath = $file.FullName.Substring($ScriptDir.Length + 1)
    
    foreach ($line in $content) {
        # 匹配技能引用模式：反引号中的技能名 + .md 或 SKILL.md
        $matches = [regex]::Matches($line, '`([a-z][a-z0-9-]+)`')
        foreach ($m in $matches) {
            $skillName = $m.Groups[1].Value
            $totalRefs++
            
            if (-not $registeredSkills.ContainsKey($skillName)) {
                if (-not $unregisteredRefs.ContainsKey($skillName)) {
                    $unregisteredRefs[$skillName] = @()
                }
                $unregisteredRefs[$skillName] += "$relativePath`: $line"
            }
        }
    }
}

Write-Host "`n总引用数: $totalRefs"
Write-Host "未注册引用数: $($unregisteredRefs.Count)"

if ($unregisteredRefs.Count -eq 0) {
    Write-Host "`n✅ 验证通过！所有引用均已注册。" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ 未注册引用清单:" -ForegroundColor Yellow
    foreach ($key in ($unregisteredRefs.Keys | Sort-Object)) {
        Write-Host "  `"$key`"" -ForegroundColor Yellow
        foreach ($ref in $unregisteredRefs[$key]) {
            Write-Host "    - $ref" -ForegroundColor DarkGray
        }
    }
    Write-Host "`n请将以上技能引用注册到 devflow-config.json 的 skills 数组中。" -ForegroundColor Yellow
    exit 1
}
