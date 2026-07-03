# DevFlow Skill Reference Checker v1.0
# VR-013 技能间交叉引用完整性检查
# 用法：.\check-references.ps1 [-PluginDir <路径>] [-Verbose]

param(
    [string]$PluginDir = "",
    [switch]$Verbose
)

# 自动检测插件目录（脚本位于 scripts/ 下，上级即为插件根目录）
if (-not $PluginDir) {
    $PluginDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

# 检查插件目录是否存在
if (-not (Test-Path -Path $PluginDir -PathType Container)) {
    Write-Host "错误：插件目录不存在: $PluginDir" -ForegroundColor Red
    exit 1
}

# 预定义正则表达式模式（避免反引号转义问题）
$BT = [char]0x60  # 反引号字符
$RE_BACKTICK_REF = "$BT([a-z][\w-]+)$BT"
$RE_PATH_REF = '(?:skills|orchestrator)/[\w/\-]+\.md'
$RE_INLINE_REF = '内联自\s+([\w-]+)\s*技能'

# ============================================================
# 函数: 获取所有技能信息
# ============================================================
function Get-AllSkills {
    param([string]$RootDir)

    $skills = @{}

    # 收集 skills/L1、skills/L2、skills/L3 下的 .md 文件
    $SkillsDir = Join-Path $RootDir "skills"
    if (Test-Path $SkillsDir) {
        $layers = @("L1", "L2", "L3")
        foreach ($layer in $layers) {
            $layerDir = Join-Path $SkillsDir $layer
            if (Test-Path $layerDir) {
                $files = Get-ChildItem -Path $layerDir -Filter "*.md" -File
                foreach ($file in $files) {
                    $skillName = $file.BaseName
                    $skills[$skillName] = @{
                        Name      = $skillName
                        Layer     = $layer
                        FilePath  = $file.FullName
                        RelPath   = "skills/$layer/$($file.Name)"
                    }
                }
            }
        }
    }

    # 收集 orchestrator 目录（devflow-*/SKILL.md）
    $devflowDirs = Get-ChildItem -Path $RootDir -Directory -Filter "devflow-*"
    foreach ($dir in $devflowDirs) {
        $skillFile = Join-Path $dir.FullName "SKILL.md"
        if (Test-Path $skillFile) {
            $skillName = $dir.Name
            $skills[$skillName] = @{
                Name      = $skillName
                Layer     = "Orchestrator"
                FilePath  = $skillFile
                RelPath   = "$skillName/SKILL.md"
            }
        }
    }

    return $skills
}

# ============================================================
# 函数: 从技能文件内容中提取引用的其他技能名称
# ============================================================
function Get-ReferencedSkills {
    param(
        [string]$Content,
        [string]$CurrentSkillName,
        [hashtable]$AllSkills
    )

    $referenced = @()

    # 匹配反引号中的技能名称
    $matchResults = [regex]::Matches($Content, $RE_BACKTICK_REF)
    foreach ($m in $matchResults) {
        $name = $m.Groups[1].Value
        if ($name -ne $CurrentSkillName -and $AllSkills.ContainsKey($name)) {
            $referenced += $name | Select-Object -Unique
        }
    }

    # 匹配路径引用（如 skills/L3/code-logic-review.md）
    $pathMatches = [regex]::Matches($Content, $RE_PATH_REF)
    foreach ($pm in $pathMatches) {
        $pathRef = $pm.Value
        $fileName = Split-Path $pathRef -Leaf
        $skillName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        if ($skillName -ne $CurrentSkillName -and $AllSkills.ContainsKey($skillName)) {
            $referenced += $skillName | Select-Object -Unique
        }
    }

    return $referenced | Select-Object -Unique
}

# ============================================================
# 函数: 从技能文件内容中提取路径引用
# ============================================================
function Get-PathReferences {
    param([string]$Content)

    $paths = @()
    $matchResults = [regex]::Matches($Content, $RE_PATH_REF)
    foreach ($m in $matchResults) {
        $paths += $m.Value | Select-Object -Unique
    }
    return $paths
}

# ============================================================
# 函数: 从 L2 文件中提取 L3 技能速查引用
# ============================================================
function Get-L3QuickRefReferences {
    param(
        [string]$Content,
        [hashtable]$AllSkills
    )

    $l3Refs = @()
    $matchResults = [regex]::Matches($Content, $RE_INLINE_REF)
    foreach ($m in $matchResults) {
        $skillName = $m.Groups[1].Value
        $l3Refs += $skillName
    }
    return $l3Refs | Select-Object -Unique
}

# ============================================================
# 函数: 检查引用目标存在性（检查项 1）
# ============================================================
function Test-ReferenceTarget {
    param(
        [hashtable]$AllSkills,
        [switch]$IsVerbose
    )

    Write-Host ""
    Write-Host "[1/4] 引用目标存在性检查..." -ForegroundColor Cyan

    $passCount = 0
    $failCount = 0
    $failures = @()

    foreach ($skillName in ($AllSkills.Keys | Sort-Object)) {
        $skill = $AllSkills[$skillName]
        $content = Get-Content -Path $skill.FilePath -Raw -Encoding UTF8

        # 提取所有被反引号包裹的名称（可能是技能名）
        $allBacktickNames = @()
        $matchResults = [regex]::Matches($content, $RE_BACKTICK_REF)
        foreach ($m in $matchResults) {
            $name = $m.Groups[1].Value
            if ($name -ne $skillName) {
                $allBacktickNames += $name | Select-Object -Unique
            }
        }

        foreach ($refName in ($allBacktickNames | Sort-Object -Unique)) {
            if ($AllSkills.ContainsKey($refName)) {
                $layer = $AllSkills[$refName].Layer
                $leafFile = Split-Path $skill.RelPath -Leaf
                if ($IsVerbose) {
                    $checkMark = [char]0x2713
                    Write-Host "  $checkMark $leafFile 引用 $refName ($layer) -> 存在" -ForegroundColor Green
                }
                $passCount++
            }
            else {
                # 只报告看起来像技能名称的引用（包含连字符，长度>=5）
                if ($refName -match '-' -and $refName.Length -ge 5) {
                    $leafFile = Split-Path $skill.RelPath -Leaf
                    $crossMark = [char]0x2717
                    Write-Host "  $crossMark $leafFile 引用 $refName -> 不存在" -ForegroundColor Red
                    $failCount++
                    $failures += @{ Source = $leafFile; Target = $refName }
                }
            }
        }
    }

    $color = if ($failCount -gt 0) { "Red" } else { "Green" }
    Write-Host "  通过: $passCount, 失败: $failCount" -ForegroundColor $color
    return @{ Pass = $passCount; Fail = $failCount; Failures = $failures }
}

# ============================================================
# 函数: 检查路径引用正确性（检查项 2）
# ============================================================
function Test-PathReference {
    param(
        [string]$PluginDir,
        [hashtable]$AllSkills,
        [switch]$IsVerbose
    )

    Write-Host ""
    Write-Host "[2/4] 路径引用正确性检查..." -ForegroundColor Cyan

    $passCount = 0
    $failCount = 0
    $failures = @()

    foreach ($skillName in ($AllSkills.Keys | Sort-Object)) {
        $skill = $AllSkills[$skillName]
        $content = Get-Content -Path $skill.FilePath -Raw -Encoding UTF8

        $pathRefs = Get-PathReferences -Content $content
        foreach ($pathRef in ($pathRefs | Sort-Object -Unique)) {
            $fullPath = Join-Path $PluginDir $pathRef
            $leafFile = Split-Path $skill.RelPath -Leaf
            if (Test-Path $fullPath) {
                if ($IsVerbose) {
                    $checkMark = [char]0x2713
                    Write-Host "  $checkMark $leafFile 引用路径 $pathRef -> 存在" -ForegroundColor Green
                }
                $passCount++
            }
            else {
                $crossMark = [char]0x2717
                Write-Host "  $crossMark $leafFile 引用路径 $pathRef -> 不存在" -ForegroundColor Red
                $failCount++
                $failures += @{ Source = $leafFile; Target = $pathRef }
            }
        }
    }

    if ($passCount -eq 0 -and $failCount -eq 0) {
        Write-Host "  未找到路径引用" -ForegroundColor Yellow
    }
    else {
        $color = if ($failCount -gt 0) { "Red" } else { "Green" }
        Write-Host "  通过: $passCount, 失败: $failCount" -ForegroundColor $color
    }

    return @{ Pass = $passCount; Fail = $failCount; Failures = $failures }
}

# ============================================================
# 函数: 检测循环引用（检查项 3）
# ============================================================
function Test-CircularReference {
    param([hashtable]$AllSkills)

    Write-Host ""
    Write-Host "[3/4] 循环引用检测..." -ForegroundColor Cyan

    # 构建邻接表
    $graph = @{}
    foreach ($skillName in $AllSkills.Keys) {
        $skill = $AllSkills[$skillName]
        $content = Get-Content -Path $skill.FilePath -Raw -Encoding UTF8
        $refs = Get-ReferencedSkills -Content $content -CurrentSkillName $skillName -AllSkills $AllSkills
        $graph[$skillName] = $refs
    }

    # DFS 检测循环
    $circles = @()
    $visited = @{}
    $stack = @{}

    function DFS-Check {
        param(
            [string]$Node,
            [string[]]$Path
        )

        if ($stack.ContainsKey($Node)) {
            # 找到环：提取从该节点到当前路径末尾的部分
            $cycleStartIdx = $Path.IndexOf($Node)
            $cycle = $Path[$cycleStartIdx..($Path.Length - 1)] + @($Node)
            # 仅报告包含 3 个或更多不同节点的环（排除双向引用 A<->B）
            $uniqueNodes = $cycle | Select-Object -Unique
            if ($uniqueNodes.Count -ge 3) {
                return $cycle
            }
            return $null
        }

        if ($visited.ContainsKey($Node)) {
            return $null
        }

        $visited[$Node] = $true
        $stack[$Node] = $true
        $newPath = $Path + @($Node)

        if ($graph.ContainsKey($Node)) {
            foreach ($neighbor in $graph[$Node]) {
                $result = DFS-Check -Node $neighbor -Path $newPath
                if ($null -ne $result) {
                    return $result
                }
            }
        }

        $stack.Remove($Node)
        return $null
    }

    foreach ($skillName in ($AllSkills.Keys | Sort-Object)) {
        if (-not $visited.ContainsKey($skillName)) {
            $cycle = DFS-Check -Node $skillName -Path @()
            if ($null -ne $cycle) {
                $circles += $cycle
            }
        }
    }

    if ($circles.Count -eq 0) {
        Write-Host "  未检测到循环引用" -ForegroundColor Green
        return @{ Pass = 1; Fail = 0; Circles = @() }
    }
    else {
        $crossMark = [char]0x2717
        foreach ($cycle in $circles) {
            $cycleStr = $cycle -join " -> "
            Write-Host "  $crossMark 循环引用: $cycleStr" -ForegroundColor Red
        }
        return @{ Pass = 0; Fail = $circles.Count; Circles = $circles }
    }
}

# ============================================================
# 函数: 检测孤立技能（检查项 4）
# ============================================================
function Find-OrphanSkills {
    param([hashtable]$AllSkills)

    Write-Host ""
    Write-Host "[4/4] 孤立技能检测..." -ForegroundColor Cyan

    # 构建反向引用表
    $reverseRefs = @{}
    foreach ($skillName in $AllSkills.Keys) {
        $reverseRefs[$skillName] = @()
    }

    foreach ($skillName in $AllSkills.Keys) {
        $skill = $AllSkills[$skillName]
        $content = Get-Content -Path $skill.FilePath -Raw -Encoding UTF8
        $refs = Get-ReferencedSkills -Content $content -CurrentSkillName $skillName -AllSkills $AllSkills

        foreach ($ref in $refs) {
            if ($reverseRefs.ContainsKey($ref)) {
                $reverseRefs[$ref] += $skillName
            }
        }
    }

    $orphans = @()
    $warnMark = [char]0x26A0
    foreach ($skillName in ($AllSkills.Keys | Sort-Object)) {
        $refCount = $reverseRefs[$skillName].Count
        if ($refCount -eq 0) {
            $layer = $AllSkills[$skillName].Layer
            Write-Host "  $warnMark $($AllSkills[$skillName].Name) ($layer) 未被任何技能引用（可能是新添加的）" -ForegroundColor Yellow
            $orphans += $skillName
        }
    }

    if ($orphans.Count -eq 0) {
        Write-Host "  所有技能均被至少一个其他技能引用" -ForegroundColor Green
    }

    return @{ Pass = ($AllSkills.Count - $orphans.Count); Warn = $orphans.Count; Orphans = $orphans }
}

# ============================================================
# 函数: 检查技能速查映射（附加检查项 5）
# ============================================================
function Test-L3QuickRefMapping {
    param([hashtable]$AllSkills)

    Write-Host ""
    Write-Host "[附加] 技能速查映射检查（L2 -> L3）..." -ForegroundColor Cyan

    $passCount = 0
    $failCount = 0
    $failures = @()

    foreach ($skillName in ($AllSkills.Keys | Sort-Object)) {
        $skill = $AllSkills[$skillName]
        if ($skill.Layer -ne "L2") { continue }

        $content = Get-Content -Path $skill.FilePath -Raw -Encoding UTF8
        $l3Refs = Get-L3QuickRefReferences -Content $content -AllSkills $AllSkills

        foreach ($refName in ($l3Refs | Sort-Object -Unique)) {
            $leafFile = Split-Path $skill.RelPath -Leaf
            if ($AllSkills.ContainsKey($refName)) {
                $layer = $AllSkills[$refName].Layer
                $checkMark = [char]0x2713
                Write-Host "  $checkMark $leafFile 速查引用 $refName ($layer) -> 存在" -ForegroundColor Green
                $passCount++
            }
            else {
                $crossMark = [char]0x2717
                Write-Host "  $crossMark $leafFile 速查引用 $refName -> 不存在" -ForegroundColor Red
                $failCount++
                $failures += @{ Source = $leafFile; Target = $refName }
            }
        }
    }

    if ($passCount -eq 0 -and $failCount -eq 0) {
        Write-Host "  未找到 L3 速查引用" -ForegroundColor Yellow
    }
    else {
        $color = if ($failCount -gt 0) { "Red" } else { "Green" }
        Write-Host "  通过: $passCount, 失败: $failCount" -ForegroundColor $color
    }

    return @{ Pass = $passCount; Fail = $failCount; Failures = $failures }
}

# ============================================================
# 主流程
# ============================================================
Write-Host "DevFlow Skill Reference Checker v1.0" -ForegroundColor Cyan
Write-Host "========================================"
Write-Host "插件目录: $PluginDir"

# 1. 扫描所有技能文件
$AllSkills = Get-AllSkills -RootDir $PluginDir
$skillCount = $AllSkills.Count

if ($skillCount -eq 0) {
    Write-Host "错误：未找到任何技能文件。" -ForegroundColor Red
    exit 1
}

Write-Host "扫描技能数: $skillCount" -ForegroundColor Green

# 按层统计
$l1Count = ($AllSkills.Values | Where-Object { $_.Layer -eq "L1" }).Count
$l2Count = ($AllSkills.Values | Where-Object { $_.Layer -eq "L2" }).Count
$l3Count = ($AllSkills.Values | Where-Object { $_.Layer -eq "L3" }).Count
$orchCount = ($AllSkills.Values | Where-Object { $_.Layer -eq "Orchestrator" }).Count
Write-Host "  L1 ($l1Count) | L2 ($l2Count) | L3 ($l3Count) | Orchestrator ($orchCount)"

# 2. 执行 4 项检查
$totalPass = 0
$totalFail = 0
$totalWarn = 0

# 检查项 1: 引用目标存在性
$result1 = Test-ReferenceTarget -AllSkills $AllSkills -IsVerbose:$Verbose
$totalPass += $result1.Pass
$totalFail += $result1.Fail

# 检查项 2: 路径引用正确性
$result2 = Test-PathReference -PluginDir $PluginDir -AllSkills $AllSkills -IsVerbose:$Verbose
$totalPass += $result2.Pass
$totalFail += $result2.Fail

# 检查项 3: 循环引用检测
$result3 = Test-CircularReference -AllSkills $AllSkills
$totalPass += $result3.Pass
$totalFail += $result3.Fail

# 检查项 4: 孤立技能检测
$result4 = Find-OrphanSkills -AllSkills $AllSkills
$totalPass += $result4.Pass
$totalWarn += $result4.Warn

# 附加检查项 5: 技能速查映射
$result5 = Test-L3QuickRefMapping -AllSkills $AllSkills
$totalPass += $result5.Pass
$totalFail += $result5.Fail

# 3. 输出汇总
Write-Host ""
Write-Host "========================================"
if ($totalFail -gt 0) {
    Write-Host "检查汇总: 通过 $totalPass, 警告 $totalWarn, 失败 $totalFail" -ForegroundColor Red
}
elseif ($totalWarn -gt 0) {
    Write-Host "检查汇总: 通过 $totalPass, 警告 $totalWarn, 失败 $totalFail" -ForegroundColor Yellow
}
else {
    Write-Host "检查汇总: 通过 $totalPass, 警告 $totalWarn, 失败 $totalFail" -ForegroundColor Green
}

# 退出码
$exitCode = 0
if ($totalFail -gt 0) {
    $exitCode = 1
}

if ($exitCode -eq 0) {
    Write-Host "退出码: $exitCode" -ForegroundColor Green
}
else {
    Write-Host "退出码: $exitCode" -ForegroundColor Red
}
exit $exitCode
