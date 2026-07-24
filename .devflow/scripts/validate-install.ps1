# DevFlow 多模式验证脚本 v2.0
# VR-005 安装验证测试 P1
# 用法: .\validate-install.ps1 [-Mode <package|install|update|init|full>] [-ProjectPath <路径>]
#       [-PackagePath <路径>] [-ExpectedVersion <版本号>] [-Quiet]
# 说明: 支持 5 种验证模式，覆盖下载包完整性、安装验证、更新验证、初始化验证和全量验证

param(
    [ValidateSet("package", "install", "update", "init", "full")]
    [string]$Mode = "full",

    [string]$ProjectPath = "",

    [string]$PackagePath = "",

    [string]$ExpectedVersion = "",

    [switch]$Quiet
)

$ErrorActionPreference = "Continue"
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# ============================================================
# 路径解析
# ============================================================
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# PackagePath: DevFlow 包根目录（包含 version.json / skills/ / templates/ / config.json 等）
# 默认取脚本所在目录的上一级（scripts/ 的父目录即为 .devflow/ 包根目录）
if (-not $PackagePath) {
    $PackagePath = Split-Path -Parent $ScriptDir
}

# ProjectPath: 项目根目录（其下的 .devflow/ 目录存放项目级配置）
# 默认取 PackagePath 的父目录
if (-not $ProjectPath) {
    $ProjectPath = Split-Path -Parent $PackagePath
}

# 项目 .devflow 配置目录（project-config.json / state.json 所在位置）
$ProjectDevflowDir = Join-Path $ProjectPath ".devflow"

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

function Write-Info($text) {
    Write-Host "  [INFO] $text" -ForegroundColor Gray
}

function Test-JsonValid($filePath) {
    <#
    .SYNOPSIS 检测 JSON 文件语法是否有效
    #>
    try {
        $null = Get-Content -Path $filePath -Raw -Encoding UTF8 | ConvertFrom-Json
        return $true
    }
    catch {
        return $false
    }
}

function Test-FileHasBom($filePath) {
    <#
    .SYNOPSIS 检测文件是否包含 UTF-8 BOM
    #>
    if (-not (Test-Path $filePath)) { return $false }
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    return ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
}

function Get-JsonValue($filePath, $propertyPath) {
    <#
    .SYNOPSIS 从 JSON 文件中获取嵌套属性值
    .PARAMETER propertyPath 用点号分隔的属性路径，如 "layers.L1"
    #>
    if (-not (Test-Path $filePath)) { return $null }
    try {
        $obj = Get-Content -Path $filePath -Raw -Encoding UTF8 | ConvertFrom-Json
        $props = $propertyPath -split '\.'
        $current = $obj
        foreach ($p in $props) {
            if ($null -eq $current.$p) { return $null }
            $current = $current.$p
        }
        return $current
    }
    catch {
        return $null
    }
}

function New-CheckResult {
    <#
    .SYNOPSIS 创建检查结果对象
    #>
    param(
        [string]$Id,
        [string]$Category,
        [string]$Name,
        [ValidateSet("Pass", "Fail", "Warn", "Skip")]
        [string]$Status,
        [string]$Message = "",
        [string]$Detail = ""
    )
    return [PSCustomObject]@{
        Id       = $Id
        Category = $Category
        Name     = $Name
        Status   = $Status
        Message  = $Message
        Detail   = $Detail
    }
}

# ============================================================
# 检查项定义（16 项）
# ============================================================
# 每个检查项包含：
#   Id        - 检查编号 (C01-C16)
#   Category  - 大类
#   Name      - 名称
#   InModes   - 适用模式：required=必须检查, conditional=条件检查(文件存在才检查), none=不检查
#   Script    - 执行脚本，返回 CheckResult 对象

$CheckDefinitions = @(

    # ---- C01: devflow-config.json 存在性 ----
    @{
        Id      = "C01"
        Category = "配置文件存在性"
        Name    = "devflow-config.json"
        InModes = @{
            package = "required"
            install = "required"
            update  = "required"
            init    = "none"
            full    = "required"
        }
        Script  = {
            # v2.9.1: 优先检查 devflow-config.json，兼容旧版 config.json
            $newConfigPath = Join-Path $PackagePath "devflow-config.json"
            $oldConfigPath = Join-Path $PackagePath "config.json"
            if (Test-Path $newConfigPath) {
                return New-CheckResult -Id "C01" -Category "配置文件存在性" -Name "devflow-config.json" `
                    -Status "Pass" -Message "devflow-config.json 存在" -Detail $newConfigPath
            }
            elseif (Test-Path $oldConfigPath) {
                return New-CheckResult -Id "C01" -Category "配置文件存在性" -Name "devflow-config.json" `
                    -Status "Pass" -Message "config.json 存在（旧版，建议迁移到 devflow-config.json）" -Detail $oldConfigPath
            }
            else {
                return New-CheckResult -Id "C01" -Category "配置文件存在性" -Name "devflow-config.json" `
                    -Status "Fail" -Message "devflow-config.json 和 config.json 均未找到" -Detail $PackagePath
            }
        }
    },

    # ---- C02: project-config.json 存在性 ----
    @{
        Id      = "C02"
        Category = "配置文件存在性"
        Name    = "project-config.json"
        InModes = @{
            package = "none"
            install = "conditional"
            update  = "conditional"
            init    = "required"
            full    = "required"
        }
        Script  = {
            $pcPath = Join-Path $ProjectDevflowDir "project-config.json"
            if (Test-Path $pcPath) {
                return New-CheckResult -Id "C02" -Category "配置文件存在性" -Name "project-config.json" `
                    -Status "Pass" -Message "project-config.json 存在" -Detail $pcPath
            }
            else {
                return New-CheckResult -Id "C02" -Category "配置文件存在性" -Name "project-config.json" `
                    -Status "Fail" -Message "project-config.json 未找到" -Detail $pcPath
            }
        }
    },

    # ---- C03: state.json 存在性 ----
    @{
        Id      = "C03"
        Category = "配置文件存在性"
        Name    = "state.json"
        InModes = @{
            package = "none"
            install = "none"
            update  = "conditional"
            init    = "required"
            full    = "required"
        }
        Script  = {
            $statePath = Join-Path $ProjectDevflowDir "state.json"
            if (Test-Path $statePath) {
                return New-CheckResult -Id "C03" -Category "配置文件存在性" -Name "state.json" `
                    -Status "Pass" -Message "state.json 存在" -Detail $statePath
            }
            else {
                return New-CheckResult -Id "C03" -Category "配置文件存在性" -Name "state.json" `
                    -Status "Fail" -Message "state.json 未找到" -Detail $statePath
            }
        }
    },

    # ---- C04: JSON 语法校验 ----
    @{
        Id      = "C04"
        Category = "配置文件语法"
        Name    = "JSON语法校验"
        InModes = @{
            package = "required"
            install = "required"
            update  = "required"
            init    = "required"
            full    = "required"
        }
        Script  = {
            $failFiles = @()
            $passFiles = @()

            # 收集需要检查的 JSON 文件列表（根据模式决定检查哪些）
            $jsonFiles = @()

            # package 级 JSON 文件: version.json, config.json
            # 适用于 package/install/update/full 模式
            if ($Mode -ne "init") {
                $verPath = Join-Path $PackagePath "version.json"
                if (Test-Path $verPath) { $jsonFiles += $verPath }

                $cfgPath = Join-Path $PackagePath "config.json"
                if (Test-Path $cfgPath) { $jsonFiles += $cfgPath }
            }

            # project 级 JSON 文件: project-config.json, state.json
            # 适用于 init/update/full 模式（install 模式为条件检查）
            if ($Mode -eq "init" -or $Mode -eq "update" -or $Mode -eq "full") {
                $pcPath = Join-Path $ProjectDevflowDir "project-config.json"
                if (Test-Path $pcPath) { $jsonFiles += $pcPath }

                $statePath = Join-Path $ProjectDevflowDir "state.json"
                if (Test-Path $statePath) { $jsonFiles += $statePath }
            }
            elseif ($Mode -eq "install") {
                # install 模式：project-config 为条件检查，存在则检查
                $pcPath = Join-Path $ProjectDevflowDir "project-config.json"
                if (Test-Path $pcPath) { $jsonFiles += $pcPath }
            }

            foreach ($f in $jsonFiles) {
                if (Test-JsonValid $f) {
                    $passFiles += (Split-Path $f -Leaf)
                }
                else {
                    $failFiles += (Split-Path $f -Leaf)
                }
            }

            if ($failFiles.Count -eq 0) {
                return New-CheckResult -Id "C04" -Category "配置文件语法" -Name "JSON语法校验" `
                    -Status "Pass" -Message "全部 JSON 文件语法有效 ($($passFiles.Count) 个文件)" `
                    -Detail ($passFiles -join ", ")
            }
            else {
                return New-CheckResult -Id "C04" -Category "配置文件语法" -Name "JSON语法校验" `
                    -Status "Fail" -Message "JSON 语法无效的文件: $($failFiles.Count) 个" `
                    -Detail ($failFiles -join ", ")
            }
        }
    },

    # ---- C05: 关键字段完整性 ----
    @{
        Id      = "C05"
        Category = "配置文件Schema"
        Name    = "关键字段完整性"
        InModes = @{
            package = "required"
            install = "required"
            update  = "required"
            init    = "required"
            full    = "required"
        }
        Script  = {
            $missingFields = @()
            $hasPackageLevel = ($Mode -ne "init")
            $hasProjectLevel = ($Mode -eq "init" -or $Mode -eq "update" -or $Mode -eq "full" -or $Mode -eq "install")

            # --- devflow-config.json 关键字段（v2.9.1 新配置）---
            if ($hasPackageLevel) {
                $dfcPath = Join-Path $PackagePath "devflow-config.json"
                if (Test-Path $dfcPath) {
                    $dfcFields = @("name", "devflowVersion", "skills")
                    foreach ($f in $dfcFields) {
                        if ($null -eq (Get-JsonValue $dfcPath $f)) {
                            $missingFields += "devflow-config.json.$f"
                        }
                    }
                }
            }

            # v2.9.1: 检查是否有新配置（devflow-config.json），有则旧配置字段检查变为可选
            $hasNewConfig = $false
            if ($hasPackageLevel) {
                $hasNewConfig = Test-Path (Join-Path $PackagePath "devflow-config.json")
            }

            # --- version.json 关键字段（兼容旧版，仅当无 devflow-config.json 时为必填）---
            if ($hasPackageLevel) {
                $verPath = Join-Path $PackagePath "version.json"
                if (Test-Path $verPath) {
                    $verFields = @("name", "version", "layers")
                    foreach ($f in $verFields) {
                        if ($null -eq (Get-JsonValue $verPath $f)) {
                            if (-not $hasNewConfig) {
                                $missingFields += "version.json.$f"
                            }
                            # 有新配置时，旧配置字段缺失不视为错误
                        }
                    }
                }
            }

            # --- config.json 关键字段（devflow 框架配置，兼容旧版，仅当无 devflow-config.json 时为必填）---
            if ($hasPackageLevel) {
                $cfgPath = Join-Path $PackagePath "config.json"
                if (Test-Path $cfgPath) {
                    $cfgFields = @("project", "branchStrategy")
                    foreach ($f in $cfgFields) {
                        if ($null -eq (Get-JsonValue $cfgPath $f)) {
                            if (-not $hasNewConfig) {
                                $missingFields += "config.json.$f"
                            }
                            # 有新配置时，旧配置字段缺失不视为错误
                        }
                    }
                }
            }

            # --- project-config.json 关键字段 ---
            if ($hasProjectLevel) {
                $pcPath = Join-Path $ProjectDevflowDir "project-config.json"
                if (Test-Path $pcPath) {
                    $pcFields = @("_meta.schemaVersion", "project.name", "project.version")
                    foreach ($f in $pcFields) {
                        if ($null -eq (Get-JsonValue $pcPath $f)) {
                            $missingFields += "project-config.json.$f"
                        }
                    }
                }
            }

            # --- state.json 关键字段 ---
            if ($Mode -eq "init" -or $Mode -eq "update" -or $Mode -eq "full") {
                $statePath = Join-Path $ProjectDevflowDir "state.json"
                if (Test-Path $statePath) {
                    $stateFields = @("project", "devflowVersion", "currentPhase")
                    foreach ($f in $stateFields) {
                        if ($null -eq (Get-JsonValue $statePath $f)) {
                            $missingFields += "state.json.$f"
                        }
                    }
                }
            }

            # v2.9.1: 至少要有一个配置源（devflow-config.json 或 version.json + config.json）
            if ($hasPackageLevel) {
                $hasOldConfig = (Test-Path (Join-Path $PackagePath "version.json")) -or (Test-Path (Join-Path $PackagePath "config.json"))
                if (-not $hasNewConfig -and -not $hasOldConfig) {
                    $missingFields += "package-level-config (devflow-config.json 或 version.json+config.json 均不存在)"
                }
            }

            if ($missingFields.Count -eq 0) {
                return New-CheckResult -Id "C05" -Category "配置文件Schema" -Name "关键字段完整性" `
                    -Status "Pass" -Message "所有关键字段完整" -Detail ""
            }
            else {
                return New-CheckResult -Id "C05" -Category "配置文件Schema" -Name "关键字段完整性" `
                    -Status "Fail" -Message "缺少 $($missingFields.Count) 个关键字段" `
                    -Detail ($missingFields -join ", ")
            }
        }
    },

    # ---- C06: 所有技能 SKILL.md 存在 ----
    @{
        Id      = "C06"
        Category = "技能文件完整性"
        Name    = "所有技能SKILL.md存在"
        InModes = @{
            package = "required"
            install = "required"
            update  = "required"
            init    = "none"
            full    = "required"
        }
        Script  = {
            $verPath = Join-Path $PackagePath "version.json"
            if (-not (Test-Path $verPath)) {
                return New-CheckResult -Id "C06" -Category "技能文件完整性" -Name "所有技能SKILL.md存在" `
                    -Status "Fail" -Message "version.json 不存在，无法获取技能清单" -Detail $verPath
            }

            try {
                $ver = Get-Content -Path $verPath -Raw -Encoding UTF8 | ConvertFrom-Json
            }
            catch {
                return New-CheckResult -Id "C06" -Category "技能文件完整性" -Name "所有技能SKILL.md存在" `
                    -Status "Fail" -Message "version.json 解析失败" -Detail $verPath
            }

            $allSkills = @()
            foreach ($layer in @("L1", "L2", "L3", "orchestrator")) {
                if ($ver.layers.$layer) {
                    $allSkills += $ver.layers.$layer
                }
            }

            $missing = @()
            $found = 0

            foreach ($skill in $allSkills) {
                # L1/L2/L3 技能在 skills/ 目录下
                $isOrchestrator = ($skill -like "devflow-*")
                if ($isOrchestrator) {
                    $skillFile = Join-Path $PackagePath "$skill\SKILL.md"
                }
                else {
                    # 搜索 skills/ 下所有子目录
                    $skillFile = $null
                    $skillDirs = Get-ChildItem -Path (Join-Path $PackagePath "skills") -Directory -ErrorAction SilentlyContinue
                    foreach ($d in $skillDirs) {
                        $candidate = Join-Path $d.FullName "$skill.md"
                        if (Test-Path $candidate) {
                            $skillFile = $candidate
                            break
                        }
                    }
                }

                if ($skillFile -and (Test-Path $skillFile)) {
                    $found++
                }
                else {
                    $missing += $skill
                }
            }

            if ($missing.Count -eq 0) {
                return New-CheckResult -Id "C06" -Category "技能文件完整性" -Name "所有技能SKILL.md存在" `
                    -Status "Pass" -Message "全部 $found 个技能文件存在" -Detail ""
            }
            else {
                return New-CheckResult -Id "C06" -Category "技能文件完整性" -Name "所有技能SKILL.md存在" `
                    -Status "Fail" -Message "缺少 $($missing.Count) 个技能文件" `
                    -Detail ($missing -join ", ")
            }
        }
    },

    # ---- C07: 技能数量与清单匹配 ----
    @{
        Id      = "C07"
        Category = "技能文件完整性"
        Name    = "技能数量与清单匹配"
        InModes = @{
            package = "required"
            install = "required"
            update  = "required"
            init    = "none"
            full    = "required"
        }
        Script  = {
            $verPath = Join-Path $PackagePath "version.json"
            if (-not (Test-Path $verPath)) {
                return New-CheckResult -Id "C07" -Category "技能文件完整性" -Name "技能数量与清单匹配" `
                    -Status "Fail" -Message "version.json 不存在" -Detail $verPath
            }

            try {
                $ver = Get-Content -Path $verPath -Raw -Encoding UTF8 | ConvertFrom-Json
            }
            catch {
                return New-CheckResult -Id "C07" -Category "技能文件完整性" -Name "技能数量与清单匹配" `
                    -Status "Fail" -Message "version.json 解析失败" -Detail $verPath
            }

            # 统计清单中的技能总数
            $manifestCount = 0
            foreach ($layer in @("L1", "L2", "L3", "orchestrator")) {
                if ($ver.layers.$layer) {
                    $manifestCount += @($ver.layers.$layer).Count
                }
            }

            # 统计实际技能文件数
            $actualCount = 0

            # skills/ 目录下的 .md 文件
            $skillsDir = Join-Path $PackagePath "skills"
            if (Test-Path $skillsDir) {
                $mdFiles = Get-ChildItem -Path $skillsDir -Filter "*.md" -Recurse -File -ErrorAction SilentlyContinue
                $actualCount += @($mdFiles).Count
            }

            # devflow-* 编排器目录下的 SKILL.md
            $orchDirs = Get-ChildItem -Path $PackagePath -Directory -Filter "devflow-*" -ErrorAction SilentlyContinue
            foreach ($d in $orchDirs) {
                $skillMd = Join-Path $d.FullName "SKILL.md"
                if (Test-Path $skillMd) {
                    $actualCount++
                }
            }

            if ($actualCount -eq $manifestCount) {
                return New-CheckResult -Id "C07" -Category "技能文件完整性" -Name "技能数量与清单匹配" `
                    -Status "Pass" -Message "技能数量匹配 ($actualCount/$manifestCount)" -Detail ""
            }
            else {
                $diff = $actualCount - $manifestCount
                return New-CheckResult -Id "C07" -Category "技能文件完整性" -Name "技能数量与清单匹配" `
                    -Status "Warn" -Message "技能数量不匹配 (实际=$actualCount, 清单=$manifestCount, 差值=$diff)" `
                    -Detail "实际文件数与 version.json 清单不一致"
            }
        }
    },

    # ---- C08: 简化版引用检查 ----
    @{
        Id      = "C08"
        Category = "技能间引用关系"
        Name    = "简化版引用检查"
        InModes = @{
            package = "none"
            install = "required"
            update  = "required"
            init    = "none"
            full    = "required"
        }
        Script  = {
            $verPath = Join-Path $PackagePath "version.json"
            if (-not (Test-Path $verPath)) {
                return New-CheckResult -Id "C08" -Category "技能间引用关系" -Name "简化版引用检查" `
                    -Status "Fail" -Message "version.json 不存在" -Detail $verPath
            }

            try {
                $ver = Get-Content -Path $verPath -Raw -Encoding UTF8 | ConvertFrom-Json
            }
            catch {
                return New-CheckResult -Id "C08" -Category "技能间引用关系" -Name "简化版引用检查" `
                    -Status "Fail" -Message "version.json 解析失败" -Detail $verPath
            }

            # 收集所有技能名称
            $allSkills = @()
            foreach ($layer in @("L1", "L2", "L3", "orchestrator")) {
                if ($ver.layers.$layer) {
                    $allSkills += $ver.layers.$layer
                }
            }

            if ($allSkills.Count -eq 0) {
                return New-CheckResult -Id "C08" -Category "技能间引用关系" -Name "简化版引用检查" `
                    -Status "Warn" -Message "技能清单为空，跳过引用检查" -Detail ""
            }

            # 收集所有技能文件路径
            $skillFiles = @{}
            foreach ($skill in $allSkills) {
                $isOrchestrator = ($skill -like "devflow-*")
                if ($isOrchestrator) {
                    $path = Join-Path $PackagePath "$skill\SKILL.md"
                }
                else {
                    $path = $null
                    $skillDirs = Get-ChildItem -Path (Join-Path $PackagePath "skills") -Directory -ErrorAction SilentlyContinue
                    foreach ($d in $skillDirs) {
                        $candidate = Join-Path $d.FullName "$skill.md"
                        if (Test-Path $candidate) {
                            $path = $candidate
                            break
                        }
                    }
                }
                if ($path -and (Test-Path $path)) {
                    $skillFiles[$skill] = $path
                }
            }

            # 反引号引用正则
            $BT = [char]0x60
            $RE_BACKTICK_REF = "$BT([a-z][\w-]+)$BT"

            $validRefs = 0
            $unknownRefs = @()

            foreach ($skill in $allSkills) {
                if (-not $skillFiles.ContainsKey($skill)) { continue }

                $content = Get-Content -Path $skillFiles[$skill] -Raw -Encoding UTF8
                $matchResults = [regex]::Matches($content, $RE_BACKTICK_REF)

                foreach ($m in $matchResults) {
                    $refName = $m.Groups[1].Value
                    if ($refName -eq $skill) { continue }
                    # 只检查含连字符且长度>=5的引用（看起来像技能名）
                    if ($refName -match '-' -and $refName.Length -ge 5) {
                        if ($allSkills -contains $refName) {
                            $validRefs++
                        }
                        else {
                            if ($unknownRefs -notcontains "$skill -> $refName") {
                                $unknownRefs += "$skill -> $refName"
                            }
                        }
                    }
                }
            }

            if ($unknownRefs.Count -eq 0) {
                return New-CheckResult -Id "C08" -Category "技能间引用关系" -Name "简化版引用检查" `
                    -Status "Pass" -Message "引用关系正常（$validRefs 条有效引用）" -Detail ""
            }
            else {
                return New-CheckResult -Id "C08" -Category "技能间引用关系" -Name "简化版引用检查" `
                    -Status "Warn" -Message "检测到 $($unknownRefs.Count) 个未注册引用" `
                    -Detail ($unknownRefs -join "; ")
            }
        }
    },

    # ---- C09: templates 目录存在 ----
    @{
        Id      = "C09"
        Category = "模板文件可用性"
        Name    = "templates目录存在"
        InModes = @{
            package = "required"
            install = "required"
            update  = "required"
            init    = "none"
            full    = "required"
        }
        Script  = {
            $templatesDir = Join-Path $PackagePath "templates"
            if (Test-Path $templatesDir) {
                $templateFiles = Get-ChildItem -Path $templatesDir -File -ErrorAction SilentlyContinue
                $count = @($templateFiles).Count

                # 与 version.json 中的 templates 数量对比
                $verPath = Join-Path $PackagePath "version.json"
                $detail = "模板文件数: $count"
                $status = "Pass"
                $msg = "templates 目录存在，共 $count 个文件"

                if (Test-Path $verPath) {
                    try {
                        $ver = Get-Content -Path $verPath -Raw -Encoding UTF8 | ConvertFrom-Json
                        if ($ver.templates) {
                            $expected = $ver.templates
                            if ($count -ne $expected) {
                                $status = "Warn"
                                $msg = "模板文件数量不匹配 (实际=$count, 期望=$expected)"
                                $detail = "version.json 声明模板数: $expected, 实际文件数: $count"
                            }
                            else {
                                $detail = "数量与 version.json 匹配 ($count/$expected)"
                            }
                        }
                    }
                    catch { }
                }

                return New-CheckResult -Id "C09" -Category "模板文件可用性" -Name "templates目录存在" `
                    -Status $status -Message $msg -Detail $detail
            }
            else {
                return New-CheckResult -Id "C09" -Category "模板文件可用性" -Name "templates目录存在" `
                    -Status "Fail" -Message "templates 目录未找到" -Detail $templatesDir
            }
        }
    },

    # ---- C10: L1 编排器格式完整 ----
    @{
        Id      = "C10"
        Category = "编排器加载检查"
        Name    = "L1编排器格式完整"
        InModes = @{
            package = "none"
            install = "required"
            update  = "required"
            init    = "none"
            full    = "required"
        }
        Script  = {
            $verPath = Join-Path $PackagePath "version.json"
            $orchestrators = @()

            if (Test-Path $verPath) {
                try {
                    $ver = Get-Content -Path $verPath -Raw -Encoding UTF8 | ConvertFrom-Json
                    if ($ver.layers.orchestrator) {
                        $orchestrators = $ver.layers.orchestrator
                    }
                }
                catch { }
            }

            if ($orchestrators.Count -eq 0) {
                $orchestrators = @("devflow-init", "devflow-phase-manager", "devflow-project-config")
            }

            $passCount = 0
            $failItems = @()
            $warnItems = @()

            foreach ($orch in $orchestrators) {
                $orchPath = Join-Path $PackagePath "$orch\SKILL.md"
                if (-not (Test-Path $orchPath)) {
                    $failItems += "$orch - 文件不存在"
                    continue
                }

                $content = Get-Content -Path $orchPath -Raw -Encoding UTF8

                $hasFrontmatter = ($content -match '(?m)^---\s*$')
                $hasPositioning = ($content -match '## 定位')
                $hasTrigger = ($content -match '## 触发条件')

                if ($hasFrontmatter -and $hasPositioning -and $hasTrigger) {
                    $passCount++
                }
                elseif ($hasPositioning -and $hasTrigger) {
                    $warnItems += "$orch - 缺少 YAML frontmatter"
                }
                else {
                    $missing = @()
                    if (-not $hasFrontmatter) { $missing += "frontmatter" }
                    if (-not $hasPositioning) { $missing += "定位章节" }
                    if (-not $hasTrigger) { $missing += "触发条件章节" }
                    $failItems += "$orch - 缺少: $($missing -join ', ')"
                }
            }

            if ($failItems.Count -eq 0 -and $warnItems.Count -eq 0) {
                return New-CheckResult -Id "C10" -Category "编排器加载检查" -Name "L1编排器格式完整" `
                    -Status "Pass" -Message "全部 $passCount 个编排器格式完整" -Detail ""
            }
            elseif ($failItems.Count -eq 0) {
                return New-CheckResult -Id "C10" -Category "编排器加载检查" -Name "L1编排器格式完整" `
                    -Status "Warn" -Message "$($warnItems.Count) 个编排器存在警告" `
                    -Detail ($warnItems -join "; ")
            }
            else {
                return New-CheckResult -Id "C10" -Category "编排器加载检查" -Name "L1编排器格式完整" `
                    -Status "Fail" -Message "$($failItems.Count) 个编排器格式不完整" `
                    -Detail ($failItems -join "; ")
            }
        }
    },

    # ---- C11: install.ps1 存在 ----
    @{
        Id      = "C11"
        Category = "脚本文件完整性"
        Name    = "install.ps1存在"
        InModes = @{
            package = "required"
            install = "required"
            update  = "required"
            init    = "none"
            full    = "required"
        }
        Script  = {
            $installPs1 = Join-Path $PackagePath "install.ps1"
            $setupPs1 = Join-Path $PackagePath "setup.ps1"
            if (Test-Path $installPs1) {
                return New-CheckResult -Id "C11" -Category "脚本文件完整性" -Name "install.ps1存在" `
                    -Status "Pass" -Message "install.ps1 存在" -Detail $installPs1
            }
            elseif (Test-Path $setupPs1) {
                return New-CheckResult -Id "C11" -Category "脚本文件完整性" -Name "install.ps1存在" `
                    -Status "Pass" -Message "setup.ps1 存在（作为 install 脚本）" -Detail $setupPs1
            }
            else {
                return New-CheckResult -Id "C11" -Category "脚本文件完整性" -Name "install.ps1存在" `
                    -Status "Fail" -Message "install.ps1 / setup.ps1 均未找到" -Detail $PackagePath
            }
        }
    },

    # ---- C12: update.ps1 存在 ----
    @{
        Id      = "C12"
        Category = "脚本文件完整性"
        Name    = "update.ps1存在"
        InModes = @{
            package = "required"
            install = "required"
            update  = "required"
            init    = "none"
            full    = "required"
        }
        Script  = {
            $updatePs1 = Join-Path $PackagePath "update.ps1"
            if (Test-Path $updatePs1) {
                return New-CheckResult -Id "C12" -Category "脚本文件完整性" -Name "update.ps1存在" `
                    -Status "Pass" -Message "update.ps1 存在" -Detail $updatePs1
            }
            else {
                return New-CheckResult -Id "C12" -Category "脚本文件完整性" -Name "update.ps1存在" `
                    -Status "Fail" -Message "update.ps1 未找到" -Detail $updatePs1
            }
        }
    },

    # ---- C13: 内部脚本存在 ----
    @{
        Id      = "C13"
        Category = "脚本文件完整性"
        Name    = "内部脚本存在（download/setup/validate）"
        InModes = @{
            package = "required"
            install = "required"
            update  = "required"
            init    = "none"
            full    = "required"
        }
        Script  = {
            # v2.9.1: 脚本分布在多个位置
            # - PackagePath 根目录: setup.ps1, download-devflow.ps1 (package 级，仅 package 模式检查)
            # - .devflow/scripts/: validate-install.ps1 (project 级，install/update/full 模式检查)
            $found = @()
            $missing = @()

            # package 级脚本（仅 package 模式检查，因为安装后这些脚本在 TRAE 插件目录，不在项目目录）
            if ($Mode -eq "package") {
                $pkgScripts = @("setup.ps1", "download-devflow.ps1")
                foreach ($s in $pkgScripts) {
                    $path = Join-Path $PackagePath $s
                    if (Test-Path $path) {
                        $found += $s
                    } else {
                        $missing += $s
                    }
                }
            }

            # project 级脚本（在 .devflow/scripts/，install/update/full 模式检查）
            if ($Mode -eq "install" -or $Mode -eq "update" -or $Mode -eq "full") {
                $projScriptsDir = Join-Path $ProjectDevflowDir "scripts"
                $projScripts = @("validate-install.ps1")
                foreach ($s in $projScripts) {
                    $path = Join-Path $projScriptsDir $s
                    if (Test-Path $path) {
                        $found += $s
                    } else {
                        $missing += $s
                    }
                }
            }

            if ($missing.Count -eq 0) {
                return New-CheckResult -Id "C13" -Category "脚本文件完整性" -Name "内部脚本存在（download/setup/validate）" `
                    -Status "Pass" -Message "内部脚本完整（共 $($found.Count) 个）" `
                    -Detail ($found -join ", ")
            }
            else {
                return New-CheckResult -Id "C13" -Category "脚本文件完整性" -Name "内部脚本存在（download/setup/validate）" `
                    -Status "Fail" -Message "缺少内部脚本: $($missing -join ', ')" `
                    -Detail "PackagePath: $PackagePath; ProjectScripts: $(Join-Path $ProjectDevflowDir 'scripts')"
            }
        }
    },

    # ---- C14: BOM 检查 ----
    @{
        Id      = "C14"
        Category = "BOM检查"
        Name    = ".md/.json无UTF-8 BOM"
        InModes = @{
            package = "required"
            install = "required"
            update  = "required"
            init    = "required"
            full    = "required"
        }
        Script  = {
            $bomFiles = @()
            $checkedCount = 0

            # 检查 package 下的 .md 和 .json 文件（非递归顶层 + 关键目录）
            $targetDirs = @()
            if ($Mode -ne "init") {
                $targetDirs += $PackagePath
                $skillsDir = Join-Path $PackagePath "skills"
                if (Test-Path $skillsDir) { $targetDirs += $skillsDir }
                $templatesDir = Join-Path $PackagePath "templates"
                if (Test-Path $templatesDir) { $targetDirs += $templatesDir }
            }

            # init 模式下检查项目配置文件
            if ($Mode -eq "init" -or $Mode -eq "full") {
                if (Test-Path $ProjectDevflowDir) {
                    $targetDirs += $ProjectDevflowDir
                }
            }

            foreach ($dir in $targetDirs) {
                if (-not (Test-Path $dir)) { continue }
                $files = Get-ChildItem -Path $dir -Include "*.md", "*.json" -Recurse -File -ErrorAction SilentlyContinue
                foreach ($f in $files) {
                    $checkedCount++
                    if (Test-FileHasBom $f.FullName) {
                        $bomFiles += $f.FullName.Substring($PackagePath.Length + 1)
                    }
                }
            }

            if ($bomFiles.Count -eq 0) {
                return New-CheckResult -Id "C14" -Category "BOM检查" -Name ".md/.json无UTF-8 BOM" `
                    -Status "Pass" -Message "无 UTF-8 BOM（检查 $checkedCount 个文件）" -Detail ""
            }
            else {
                $sample = ($bomFiles | Select-Object -First 5) -join ", "
                if ($bomFiles.Count -gt 5) { $sample += " 等 $($bomFiles.Count) 个" }
                return New-CheckResult -Id "C14" -Category "BOM检查" -Name ".md/.json无UTF-8 BOM" `
                    -Status "Warn" -Message "$($bomFiles.Count) 个文件包含 UTF-8 BOM" -Detail $sample
            }
        }
    },

    # ---- C15: 版本一致性 ----
    @{
        Id      = "C15"
        Category = "版本一致性"
        Name    = "各文件版本号一致"
        InModes = @{
            package = "required"
            install = "required"
            update  = "required"
            init    = "required"
            full    = "required"
        }
        Script  = {
            $newGenVersions = @{}  # 新一代配置：devflow-config.json, project-config.json, state.json
            $oldGenVersions = @{}  # 旧一代配置：version.json, config.json
            $hasPackageLevel = ($Mode -ne "init")
            $hasProjectLevel = ($Mode -eq "init" -or $Mode -eq "update" -or $Mode -eq "full" -or $Mode -eq "install")

            # --- 新一代配置版本 ---
            # devflow-config.json（package 级）
            if ($hasPackageLevel) {
                $configPath = Join-Path $PackagePath "devflow-config.json"
                if (Test-Path $configPath) {
                    $v = Get-JsonValue $configPath "devflowVersion"
                    if ($v) { $newGenVersions["devflow-config.json"] = $v }
                }
            }
            # project-config.json（project 级）
            if ($hasProjectLevel) {
                $pcPath = Join-Path $ProjectDevflowDir "project-config.json"
                if (Test-Path $pcPath) {
                    $v = Get-JsonValue $pcPath "project.version"
                    if ($v) { $newGenVersions["project-config.json"] = $v }
                }
            }
            # state.json（project 级）
            if ($Mode -eq "init" -or $Mode -eq "update" -or $Mode -eq "full") {
                $statePath = Join-Path $ProjectDevflowDir "state.json"
                if (Test-Path $statePath) {
                    $v = Get-JsonValue $statePath "devflowVersion"
                    if ($v) { $newGenVersions["state.json"] = $v }
                }
            }

            # --- 旧一代配置版本（兼容）---
            # version.json（package 级）
            if ($hasPackageLevel) {
                $verPath = Join-Path $PackagePath "version.json"
                if (Test-Path $verPath) {
                    $v = Get-JsonValue $verPath "version"
                    if ($v) { $oldGenVersions["version.json"] = $v }
                }
            }
            # .devflow/config.json（project 级）
            if ($hasProjectLevel) {
                $oldConfigPath = Join-Path $ProjectDevflowDir "config.json"
                if (Test-Path $oldConfigPath) {
                    $v = Get-JsonValue $oldConfigPath "project.version"
                    if (-not $v) { $v = Get-JsonValue $oldConfigPath "version" }
                    if ($v) { $oldGenVersions["config.json(旧)"] = $v }
                }
            }

            # 合并所有版本用于详情展示
            $allVersions = @{}
            foreach ($k in $newGenVersions.Keys) { $allVersions[$k] = $newGenVersions[$k] }
            foreach ($k in $oldGenVersions.Keys) { $allVersions[$k] = $oldGenVersions[$k] }

            if ($allVersions.Count -eq 0) {
                return New-CheckResult -Id "C15" -Category "版本一致性" -Name "各文件版本号一致" `
                    -Status "Warn" -Message "未找到任何版本信息" -Detail ""
            }

            $detailParts = @()
            foreach ($k in $allVersions.Keys) {
                $detailParts += "$k=$($allVersions[$k])"
            }

            # v2.9.1: 分代比对逻辑
            # 1. 同一代配置内版本必须一致（Fail）
            # 2. 新旧两代之间版本不一致为警告（Warn，过渡期允许）
            # 3. 只有新一代配置时：内部一致即 Pass
            # 4. 只有旧一代配置时：内部一致即 Pass（兼容旧版）

            $newGenUnique = $newGenVersions.Values | Select-Object -Unique
            $oldGenUnique = $oldGenVersions.Values | Select-Object -Unique

            # 检查同一代内部一致性
            $newGenInconsistent = ($newGenVersions.Count -gt 1 -and $newGenUnique.Count -gt 1)
            $oldGenInconsistent = ($oldGenVersions.Count -gt 1 -and $oldGenUnique.Count -gt 1)

            if ($newGenInconsistent -or $oldGenInconsistent) {
                $inconsistentParts = @()
                if ($newGenInconsistent) { $inconsistentParts += "新一代配置有 $($newGenUnique.Count) 个不同版本" }
                if ($oldGenInconsistent) { $inconsistentParts += "旧一代配置有 $($oldGenUnique.Count) 个不同版本" }
                return New-CheckResult -Id "C15" -Category "版本一致性" -Name "各文件版本号一致" `
                    -Status "Fail" -Message ($inconsistentParts -join "；") `
                    -Detail ($detailParts -join "; ")
            }

            # 检查跨代一致性（过渡期为 Warn）
            if ($newGenVersions.Count -gt 0 -and $oldGenVersions.Count -gt 0) {
                $newVer = $newGenVersions.Values | Select-Object -First 1
                $oldVer = $oldGenVersions.Values | Select-Object -First 1
                if ($newVer -ne $oldVer) {
                    return New-CheckResult -Id "C15" -Category "版本一致性" -Name "各文件版本号一致" `
                        -Status "Warn" -Message "新旧配置版本不同（过渡期允许）：新一代=$newVer, 旧一代=$oldVer" `
                        -Detail ($detailParts -join "; ")
                }
            }

            # 全部一致
            $unifiedVersion = if ($newGenVersions.Count -gt 0) {
                $newGenVersions.Values | Select-Object -First 1
            } else {
                $oldGenVersions.Values | Select-Object -First 1
            }
            return New-CheckResult -Id "C15" -Category "版本一致性" -Name "各文件版本号一致" `
                -Status "Pass" -Message "所有文件版本一致 ($unifiedVersion)" `
                -Detail ($detailParts -join "; ")
        }
    },

    # ---- C16: 迁移验证 ----
    @{
        Id      = "C16"
        Category = "迁移验证"
        Name    = "旧配置文件已正确迁移"
        InModes = @{
            package = "none"
            install = "none"
            update  = "required"
            init    = "none"
            full    = "required"
        }
        Script  = {
            $pcPath = Join-Path $ProjectDevflowDir "project-config.json"
            $oldCfgPath = Join-Path $PackagePath "config.json"

            # 检查 project-config.json 是否存在
            if (-not (Test-Path $pcPath)) {
                return New-CheckResult -Id "C16" -Category "迁移验证" -Name "旧配置文件已正确迁移" `
                    -Status "Fail" -Message "project-config.json 不存在，无法验证迁移" -Detail $pcPath
            }

            # 检查是否有迁移标记
            $migrationInfo = Get-JsonValue $pcPath "migration"
            if ($null -eq $migrationInfo) {
                # 没有迁移信息，但 project-config.json 存在 — 可能是全新初始化的
                return New-CheckResult -Id "C16" -Category "迁移验证" -Name "旧配置文件已正确迁移" `
                    -Status "Warn" -Message "未检测到迁移标记（可能为全新初始化）" `
                    -Detail "project-config.json 中缺少 migration 字段"
            }

            # 验证迁移来源
            $migratedFrom = Get-JsonValue $pcPath "migration.migratedFrom"
            $migratedAt = Get-JsonValue $pcPath "migration.migratedAt"
            $originalVersion = Get-JsonValue $pcPath "migration.originalVersion"

            $detail = "migratedFrom=$migratedFrom, migratedAt=$migratedAt, originalVersion=$originalVersion"

            if ($migratedFrom -and $migratedAt) {
                # 检查关键字段是否已迁移（project, branchStrategy, backup, remote）
                $missingMigrated = @()
                $fieldsToCheck = @("project.name", "branchStrategy", "backup.type", "remote.origin")
                foreach ($f in $fieldsToCheck) {
                    if ($null -eq (Get-JsonValue $pcPath $f)) {
                        $missingMigrated += $f
                    }
                }

                if ($missingMigrated.Count -eq 0) {
                    return New-CheckResult -Id "C16" -Category "迁移验证" -Name "旧配置文件已正确迁移" `
                        -Status "Pass" -Message "配置迁移完整（来源: $migratedFrom）" -Detail $detail
                }
                else {
                    return New-CheckResult -Id "C16" -Category "迁移验证" -Name "旧配置文件已正确迁移" `
                        -Status "Warn" -Message "部分迁移字段缺失" `
                        -Detail "$detail; 缺失字段: $($missingMigrated -join ', ')"
                }
            }
            else {
                return New-CheckResult -Id "C16" -Category "迁移验证" -Name "旧配置文件已正确迁移" `
                    -Status "Fail" -Message "迁移信息不完整" -Detail $detail
            }
        }
    }
)

# ============================================================
# 获取当前模式的活动检查项
# ============================================================
function Get-ActiveChecks {
    <#
    .SYNOPSIS 根据当前模式返回活动检查项列表
    .DESCRIPTION 返回值包含每个检查的定义及其参与类型（required/conditional）
    #>
    $active = @()
    foreach ($check in $CheckDefinitions) {
        $modeStatus = $check.InModes[$Mode]
        if ($modeStatus -eq "none" -or $null -eq $modeStatus) { continue }

        $active += [PSCustomObject]@{
            Definition = $check
            Participation = $modeStatus  # required 或 conditional
        }
    }
    return $active
}

# ============================================================
# 执行单个检查
# ============================================================
function Invoke-Check {
    param($CheckDef, [string]$Participation)

    $result = & $CheckDef.Script

    # 对于 conditional 检查：如果结果为 Fail 且是因为文件不存在，改为 Skip
    if ($Participation -eq "conditional" -and $result.Status -eq "Fail") {
        # 判断是否是"文件不存在"类型的失败
        if ($result.Message -match "未找到" -or $result.Message -match "不存在") {
            $result.Status = "Skip"
            $result.Message = "文件不存在，跳过（条件检查）"
        }
    }

    return $result
}

# ============================================================
# 主执行流程
# ============================================================

if (-not $Quiet) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " DevFlow 验证脚本 v2.0" -ForegroundColor Cyan
    Write-Host " 模式: $Mode" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "包路径:    $PackagePath"
    Write-Host "项目路径:  $ProjectPath"
    if ($ExpectedVersion) {
        Write-Host "期望版本:  $ExpectedVersion"
    }
}

# 获取活动检查项
$activeChecks = Get-ActiveChecks
$totalChecks = $activeChecks.Count

if (-not $Quiet) {
    Write-Host "检查项数:  $totalChecks"
    Write-Host ""
}

# 按大类分组输出
$results = @()
$categories = $activeChecks | ForEach-Object { $_.Definition.Category } | Select-Object -Unique

foreach ($cat in $categories) {
    if (-not $Quiet) {
        Write-Header $cat
    }

    $catChecks = $activeChecks | Where-Object { $_.Definition.Category -eq $cat }

    foreach ($item in $catChecks) {
        $result = Invoke-Check -CheckDef $item.Definition -Participation $item.Participation
        $results += $result

        if (-not $Quiet) {
            $statusLabel = switch ($result.Status) {
                "Pass" { "[PASS]" }
                "Fail" { "[FAIL]" }
                "Warn" { "[WARN]" }
                "Skip" { "[SKIP]" }
                default { "[$($result.Status)]" }
            }
            $statusColor = switch ($result.Status) {
                "Pass" { "Green" }
                "Fail" { "Red" }
                "Warn" { "Yellow" }
                "Skip" { "DarkGray" }
                default { "White" }
            }
            Write-Host "  $statusLabel $($result.Id) - $($result.Name): $($result.Message)" -ForegroundColor $statusColor
            if ($result.Detail -and $result.Status -ne "Pass") {
                Write-Host "         详情: $($result.Detail)" -ForegroundColor DarkGray
            }
        }
    }
}

# ============================================================
# 统计汇总
# ============================================================
$Stopwatch.Stop()
$duration = $Stopwatch.Elapsed.ToString("mm\:ss\.fff")

$passCount = @($results | Where-Object { $_.Status -eq "Pass" }).Count
$failCount = @($results | Where-Object { $_.Status -eq "Fail" }).Count
$warnCount = @($results | Where-Object { $_.Status -eq "Warn" }).Count
$skipCount = @($results | Where-Object { $_.Status -eq "Skip" }).Count

# Valid 判定：无 Fail 即为通过（Warn 不影响有效性）
$isValid = ($failCount -eq 0)

# 获取版本号（v2.9.1: 优先从 devflow-config.json 读取，兼容旧版 version.json）
$detectedVersion = ""
$configPath = Join-Path $PackagePath "devflow-config.json"
if (Test-Path $configPath) {
    $detectedVersion = Get-JsonValue $configPath "devflowVersion"
}
if (-not $detectedVersion) {
    $verPath = Join-Path $PackagePath "version.json"
    if (Test-Path $verPath) {
        $detectedVersion = Get-JsonValue $verPath "version"
    }
}

# 收集错误和警告列表
$errors = @($results | Where-Object { $_.Status -eq "Fail" } | ForEach-Object { "$($_.Id) $($_.Name): $($_.Message)" })
$warnings = @($results | Where-Object { $_.Status -eq "Warn" } | ForEach-Object { "$($_.Id) $($_.Name): $($_.Message)" })

# 构建结果对象
$validationResult = [PSCustomObject]@{
    Valid        = $isValid
    Mode         = $Mode
    Version      = $detectedVersion
    TotalChecks  = $totalChecks
    PassCount    = $passCount
    FailCount    = $failCount
    WarnCount    = $warnCount
    SkipCount    = $skipCount
    Checks       = $results
    Errors       = $errors
    Warnings     = $warnings
    Duration     = $duration
    PackagePath  = $PackagePath
    ProjectPath  = $ProjectPath
}

# ============================================================
# 输出结果
# ============================================================

if ($Quiet) {
    # 静默模式：只输出结果对象
    Write-Output $validationResult
}
else {
    # 正常模式：输出汇总报告 + 对象
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " 验证汇总" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " 模式:     $Mode"
    Write-Host " 版本:     $detectedVersion"
    Write-Host " 总检查数: $totalChecks"
    Write-Host " 通过:     $passCount" -ForegroundColor Green
    Write-Host " 失败:     $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
    Write-Host " 警告:     $warnCount" -ForegroundColor $(if ($warnCount -gt 0) { "Yellow" } else { "Gray" })
    if ($skipCount -gt 0) {
        Write-Host " 跳过:     $skipCount" -ForegroundColor DarkGray
    }
    Write-Host " 耗时:     $duration"

    if ($errors.Count -gt 0) {
        Write-Host ""
        Write-Host "失败项:" -ForegroundColor Red
        foreach ($e in $errors) {
            Write-Host "  - $e" -ForegroundColor Red
        }
    }

    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "警告项:" -ForegroundColor Yellow
        foreach ($w in $warnings) {
            Write-Host "  - $w" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    if ($isValid) {
        Write-Host "结果: 验证通过" -ForegroundColor Green
    }
    else {
        Write-Host "结果: 验证失败" -ForegroundColor Red
    }
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # 输出结果对象供管道使用
    Write-Output $validationResult
}

# ============================================================
# 退出码
# ============================================================
# Valid 为 true 则退出码 0，否则 1
if ($isValid) {
    exit 0
}
else {
    exit 1
}
