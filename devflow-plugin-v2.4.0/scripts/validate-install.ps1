# DevFlow 安装验证脚本 v1.0
# VR-005 安装验证测试 P1
# 用法: .\validate-install.ps1 [-PluginDir <插件目录>] [-SkillsDir <技能目录>]
# 说明: 安装完成后自动运行验证测试，检查技能文件完整性、引用关系、模板文件、编排器加载和配置文件语法

param(
    [string]$PluginDir = "",
    [string]$SkillsDir = ""
)

$ErrorActionPreference = "Continue"

# ============================================================
# 自动检测路径
# ============================================================
if (-not $PluginDir) {
    # 脚本位于 scripts/ 下，上上级即为插件根目录
    $PluginDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}
if (-not $SkillsDir) {
    $SkillsDir = Join-Path $env:USERPROFILE ".trae-cn\skills"
}

# ============================================================
# 工具函数
# ============================================================
function Write-Header($text) {
    Write-Host ""
    Write-Host "=== $text ===" -ForegroundColor Cyan
}

function Write-Pass($text) {
    Write-Host "  [PASS] $text" -ForegroundColor Green
}

function Write-Fail($text) {
    Write-Host "  [FAIL] $text" -ForegroundColor Red
}

function Write-Warn($text) {
    Write-Host "  [WARN] $text" -ForegroundColor Yellow
}

function Write-Skip($text) {
    Write-Host "  [SKIP] $text" -ForegroundColor DarkGray
}

function Test-JsonValid($filePath) {
    try {
        $null = Get-Content -Path $filePath -Raw -Encoding UTF8 | ConvertFrom-Json
        return $true
    }
    catch {
        return $false
    }
}

# 计数器初始化
$passCount = 0
$failCount = 0
$warnCount = 0
$skipCount = 0

# ============================================================
# 主流程
# ============================================================
Write-Host "DevFlow 安装验证脚本 v1.0"
Write-Host "========================================"
Write-Host "插件目录:  $PluginDir"
Write-Host "技能目录:  $SkillsDir"
Write-Host ""

# ============================================================
# [1/5] 技能文件完整性检查
# ============================================================
Write-Header "1/5 技能文件完整性"

$versionJson = Join-Path $PluginDir "version.json"
$allSkills = @()

if (Test-Path $versionJson) {
    if (Test-JsonValid $versionJson) {
        Write-Pass "version.json 格式有效"
        $passCount++
    }
    else {
        Write-Fail "version.json 格式无效"
        $failCount++
        # 无法继续解析，终止
        Write-Host ""
        Write-Host "========================================"
        Write-Host "验证汇总: 通过=$passCount 失败=$failCount 警告=$warnCount 跳过=$skipCount"
        Write-Host "结果: 验证失败（version.json 无法解析）" -ForegroundColor Red
        exit 1
    }

    $ver = Get-Content -Path $versionJson -Raw -Encoding UTF8 | ConvertFrom-Json

    # 收集所有层级的技能名称
    foreach ($layer in @("L1", "L2", "L3", "orchestrator")) {
        if ($ver.layers.$layer) {
            $allSkills += $ver.layers.$layer
        }
    }

    # 检查每个技能文件是否存在
    foreach ($skill in $allSkills) {
        # 编排器技能存放在插件根目录下的子目录中
        $skillFile = Join-Path $SkillsDir "$skill\SKILL.md"
        if (Test-Path $skillFile) {
            Write-Pass "$skill"
            $passCount++
        }
        else {
            Write-Fail "$skill - SKILL.md 未找到: $skillFile"
            $failCount++
        }
    }

    Write-Host "  技能总数: $($allSkills.Count)"
}
else {
    Write-Fail "version.json 未找到: $versionJson"
    $failCount++
}

# ============================================================
# [2/5] 技能间引用关系检查（简化版）
# ============================================================
Write-Header "2/5 技能间引用关系"

# 简化版引用检查：从 version.json 中收集技能名，在技能文件中扫描反引号引用
# BUG-001 修复：拆分 Test-Path 与 -and 条件，确保 PS5.1 兼容性
$versionJsonExists = Test-Path $versionJson
if ($versionJsonExists -and $allSkills.Count -gt 0) {
    # 预定义正则表达式
    $BT = [char]0x60
    $RE_BACKTICK_REF = "$BT([a-z][\w-]+)$BT"

    $refCheckPass = 0
    $refCheckFail = 0

    # 检查每个已安装技能文件中的引用
    foreach ($skill in $allSkills) {
        $skillFile = Join-Path $SkillsDir "$skill\SKILL.md"
        if (-not (Test-Path $skillFile)) { continue }

        $content = Get-Content -Path $skillFile -Raw -Encoding UTF8
        $matchResults = [regex]::Matches($content, $RE_BACKTICK_REF)

        foreach ($m in $matchResults) {
            $refName = $m.Groups[1].Value
            # 跳过自身引用和非技能名称的引用
            if ($refName -eq $skill) { continue }
            # 只检查看起来像 DevFlow 技能名称的引用（含连字符且长度>=5）
            if ($refName -match '-' -and $refName.Length -ge 5) {
                # 检查该引用是否在 allSkills 列表中
                if ($allSkills -contains $refName) {
                    $refCheckPass++
                }
                else {
                    # 可能是外部技能引用，仅警告
                    Write-Warn "$skill 引用了未在 version.json 中注册的技能: $refName"
                    $warnCount++
                }
            }
        }
    }

    if ($refCheckPass -gt 0) {
        Write-Pass "引用关系检查完成（检查到 $refCheckPass 条有效引用）"
        $passCount++
    }
    else {
        Write-Warn "未检测到技能间引用"
        $warnCount++
    }
}
else {
    Write-Skip "version.json 不可用，跳过引用检查"
    $skipCount++
}

# ============================================================
# [3/5] 模板文件可用性检查
# ============================================================
Write-Header "3/5 模板文件可用性"

$templatesDir = Join-Path $PluginDir "templates"
if (Test-Path $templatesDir) {
    $templateFiles = Get-ChildItem -Path $templatesDir -File -ErrorAction SilentlyContinue
    $templateCount = @($templateFiles).Count
    Write-Pass "模板目录存在: $templateCount 个文件"
    $passCount++

    # 与 version.json 中的 templates 数量对比
    if ($ver -and $ver.templates) {
        $expectedCount = $ver.templates
        if ($templateCount -eq $expectedCount) {
            Write-Pass "模板文件数量匹配 ($templateCount/$expectedCount)"
            $passCount++
        }
        else {
            Write-Warn "模板文件数量不匹配 (实际=$templateCount, 期望=$expectedCount)"
            $warnCount++
        }
    }
    else {
        Write-Skip "version.json 中未指定 templates 数量"
        $skipCount++
    }
}
else {
    Write-Fail "模板目录未找到: $templatesDir"
    $failCount++
}

# ============================================================
# [4/5] 编排器加载正常检查
# ============================================================
Write-Header "4/5 编排器加载正常"

# 编排器列表（从 version.json 的 orchestrator 层获取，或使用默认列表）
$orchestrators = @()
if ($ver -and $ver.layers.orchestrator) {
    $orchestrators = $ver.layers.orchestrator
}
else {
    $orchestrators = @("devflow-init", "devflow-phase-manager", "devflow-project-config")
}

foreach ($orch in $orchestrators) {
    # 编排器文件位于插件根目录下的对应子目录
    $orchPath = Join-Path $PluginDir "$orch\SKILL.md"
    if (Test-Path $orchPath) {
        $content = Get-Content -Path $orchPath -Raw -Encoding UTF8

        # 检查 YAML frontmatter（以 --- 开头）
        $hasFrontmatter = $content -match '(?m)^---\s*$'

        # 检查必要章节：定位、触发条件
        $hasPositioning = $content -match '## 定位'
        $hasTriggerCondition = $content -match '## 触发条件'

        if ($hasFrontmatter -and $hasPositioning -and $hasTriggerCondition) {
            Write-Pass "$orch - 格式完整（frontmatter + 定位 + 触发条件）"
            $passCount++
        }
        elseif ($hasPositioning -and $hasTriggerCondition) {
            Write-Warn "$orch - 缺少 YAML frontmatter，但包含必要章节"
            $warnCount++
        }
        else {
            $missing = @()
            if (-not $hasFrontmatter) { $missing += "YAML frontmatter" }
            if (-not $hasPositioning) { $missing += "定位章节" }
            if (-not $hasTriggerCondition) { $missing += "触发条件章节" }
            Write-Fail "$orch - 缺少: $($missing -join ', ')"
            $failCount++
        }
    }
    else {
        Write-Fail "$orch - SKILL.md 未找到: $orchPath"
        $failCount++
    }
}

# ============================================================
# [5/5] 配置文件语法检查
# ============================================================
Write-Header "5/5 配置文件语法"

# 检查 version.json
if (Test-Path $versionJson) {
    if (Test-JsonValid $versionJson) {
        Write-Pass "version.json - JSON 语法有效"
        $passCount++
    }
    else {
        Write-Fail "version.json - JSON 语法无效"
        $failCount++
    }
}
else {
    Write-Fail "version.json - 文件不存在"
    $failCount++
}

# 检查 .devflow/config.json
$configJson = Join-Path $PluginDir ".devflow\config.json"
if (Test-Path $configJson) {
    if (Test-JsonValid $configJson) {
        Write-Pass "config.json - JSON 语法有效"
        $passCount++
    }
    else {
        Write-Fail "config.json - JSON 语法无效"
        $failCount++
    }
}
else {
    Write-Warn "config.json - 文件不存在（首次安装后需通过 devflow-init 生成）"
    $warnCount++
}

# 检查 .devflow/state.json
$stateJson = Join-Path $PluginDir ".devflow\state.json"
if (Test-Path $stateJson) {
    if (Test-JsonValid $stateJson) {
        Write-Pass "state.json - JSON 语法有效"
        $passCount++
    }
    else {
        Write-Fail "state.json - JSON 语法无效"
        $failCount++
    }
}
else {
    Write-Warn "state.json - 文件不存在（首次安装后需通过 devflow-init 生成）"
    $warnCount++
}

# ============================================================
# 验证汇总
# ============================================================
Write-Host ""
Write-Host "========================================"
Write-Host "验证汇总: 通过=$passCount 失败=$failCount 警告=$warnCount 跳过=$skipCount"

if ($failCount -eq 0) {
    Write-Host "结果: 全部检查通过" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "结果: 存在失败项，请检查上述错误" -ForegroundColor Red
    exit 1
}
