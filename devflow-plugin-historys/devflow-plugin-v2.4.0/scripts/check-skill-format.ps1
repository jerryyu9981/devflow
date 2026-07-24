# DevFlow SKILL.md Format Checker v1.1
# 用途：批量检查 DevFlow 技能文件是否符合 SKILL.md 编写规范
# 用法：.\check-skill-format.ps1 [-SkillDir <路径>] [-Fix] [-AutoFill] [-Verbose]

param(
    [string]$SkillDir = "",
    [switch]$Fix,
    [switch]$AutoFill,
    [switch]$Verbose
)

# 脚本所在目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 默认检查插件根目录下的 skills/ 和 devflow-*/ 目录
if (-not $SkillDir) {
    $SkillDir = Split-Path -Parent $ScriptDir
}

# 检查目录是否存在
if (-not (Test-Path -Path $SkillDir)) {
    Write-Host "错误：目录不存在: $SkillDir" -ForegroundColor Red
    exit 1
}

Write-Host "======================================" -ForegroundColor Cyan
Write-Host " DevFlow SKILL.md Format Checker v1.0" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "检查目录: $SkillDir"
Write-Host ""

# 定义检查结果容器
$Results = @()
$TotalFiles = 0
$PassFiles = 0
$FailFiles = 0
$WarningFiles = 0

# 查找所有 SKILL.md 和 skills/ 下的 .md 文件
$SkillFiles = @()

# 收集 skills/ 下的 .md 文件
$SkillsPath = Join-Path $SkillDir "skills"
if (Test-Path $SkillsPath) {
    $SkillFiles += Get-ChildItem -Path $SkillsPath -Filter "*.md" -Recurse -File
}

# 收集 devflow-*/SKILL.md 文件
$DevflowDirs = Get-ChildItem -Path $SkillDir -Directory -Filter "devflow-*"
foreach ($dir in $DevflowDirs) {
    $SkillFile = Join-Path $dir.FullName "SKILL.md"
    if (Test-Path $SkillFile) {
        $SkillFiles += Get-Item -Path $SkillFile
    }
}

if ($SkillFiles.Count -eq 0) {
    Write-Host "未找到任何技能文件。" -ForegroundColor Yellow
    exit 0
}

Write-Host "找到 $($SkillFiles.Count) 个技能文件，开始检查..." -ForegroundColor Green
Write-Host ""

# 检查单个技能文件
function Check-SkillFile {
    param([string]$FilePath)

    $FileName = Split-Path -Leaf $FilePath
    $RelativePath = $FilePath.Substring($SkillDir.Length + 1)
    $Issues = @()
    $Warnings = @()

    # 读取文件内容
    $Content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $Lines = $Content -split "`n"

    # ---- 检查 1：文件是否有 # 一级标题 ----
    $HasH1 = $false
    foreach ($line in $Lines) {
        $trimmed = $line.TrimStart()
        if ($trimmed -match '^#\s+.+') {
            $HasH1 = $true
            break
        }
    }
    if (-not $HasH1) {
        $Issues += "[FAIL] 缺少一级标题 (# {英文名}（{中文名}）)"
    }

    # ---- 检查 2：是否有 ## 定位 章节 ----
    $HasPositioning = $false
    foreach ($line in $Lines) {
        if ($line -match '^\s*##\s+定位') {
            $HasPositioning = $true
            break
        }
    }
    if (-not $HasPositioning) {
        $Issues += "[FAIL] 缺少 ## 定位 章节"
    }

    # ---- 检查 3：是否有 ## 触发条件 章节 ----
    $HasTrigger = $false
    foreach ($line in $Lines) {
        if ($line -match '^\s*##\s+触发条件') {
            $HasTrigger = $true
            break
        }
    }
    if (-not $HasTrigger) {
        $Issues += "[FAIL] 缺少 ## 触发条件 章节"
    }

    # ---- 检查 4：是否有 ## 变更记录 章节 ----
    $HasChangelog = $false
    foreach ($line in $Lines) {
        if ($line -match '^\s*##\s+变更记录') {
            $HasChangelog = $true
            break
        }
    }
    if (-not $HasChangelog) {
        $Issues += "[FAIL] 缺少 ## 变更记录 章节"
    }

    # ---- 检查 5：文件编码是否为 UTF-8 ----
    $Bytes = [System.IO.File]::ReadAllBytes($FilePath)
    $IsUtf8WithBom = ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF)
    if ($IsUtf8WithBom) {
        $Warnings += "[WARN] 文件包含 UTF-8 BOM，建议移除"
    }

    # ---- 检查 6：是否有尾随空格 ----
    $TrailingSpaceLines = @()
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '\s+$') {
            $TrailingSpaceLines += ($i + 1)
        }
    }
    if ($TrailingSpaceLines.Count -gt 0) {
        $sampleLines = ($TrailingSpaceLines | Select-Object -First 5) -join ", "
        $suffix = ""
        if ($TrailingSpaceLines.Count -gt 5) {
            $suffix = " 等 $($TrailingSpaceLines.Count) 行"
        }
        $Issues += "[FAIL] 存在尾随空格（行: $sampleLines$suffix）"
    }

    # ---- 检查 7：是否有 YAML Front Matter ----
    $HasFrontMatter = $false
    if ($Content -match '^(?s)---\r?\n\s*name:') {
        $HasFrontMatter = $true
    }
    if (-not $HasFrontMatter) {
        $Warnings += "[WARN] 缺少 YAML Front Matter"
    }

    # ---- 检查 8：是否有 ## 反模式 章节 ----
    $HasAntiPattern = $false
    foreach ($line in $Lines) {
        if ($line -match '^\s*##\s+反模式') {
            $HasAntiPattern = $true
            break
        }
    }
    if (-not $HasAntiPattern) {
        $Warnings += "[WARN] 缺少 ## 反模式 章节"
    }

    # ---- 检查 9：代码块是否标注语言类型 ----
    $BareCodeBlocks = @()
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '^\s*```\s*$') {
            $BareCodeBlocks += ($i + 1)
        }
    }
    if ($BareCodeBlocks.Count -gt 0) {
        $sampleBlocks = ($BareCodeBlocks | Select-Object -First 5) -join ", "
        $suffix = ""
        if ($BareCodeBlocks.Count -gt 5) {
            $suffix = " 等 $($BareCodeBlocks.Count) 处"
        }
        $Warnings += "[WARN] 代码块未标注语言类型（行: $sampleBlocks$suffix）"
    }

    # ---- 检查 10：行尾是否为 CRLF（警告，建议 LF） ----
    $CrlfCount = 0
    foreach ($line in $Lines) {
        if ($line -match '\r$') {
            $CrlfCount++
        }
    }
    if ($CrlfCount -gt 0 -and -not $FilePath.EndsWith(".ps1")) {
        $pct = [math]::Round(($CrlfCount / $Lines.Count) * 100)
        $Warnings += "[WARN] 文件使用 CRLF 行尾（$CrlfCount/$($Lines.Count) 行，$pct%），建议统一为 LF"
    }

    # 返回检查结果
    return @{
        FileName      = $FileName
        RelativePath  = $RelativePath
        FilePath      = $FilePath
        Issues        = $Issues
        Warnings      = $Warnings
        LineCount     = $Lines.Count
    }
}

# 逐文件检查
foreach ($file in $SkillFiles) {
    $result = Check-SkillFile -FilePath $file.FullName
    $TotalFiles++

    Write-Host "--- $($result.RelativePath) ---" -ForegroundColor White

    if ($result.Issues.Count -eq 0 -and $result.Warnings.Count -eq 0) {
        Write-Host "  [PASS] 全部检查通过" -ForegroundColor Green
        $PassFiles++
    }
    else {
        $hasError = $false
        foreach ($issue in $result.Issues) {
            Write-Host "  $issue" -ForegroundColor Red
            $hasError = $true
        }
        foreach ($warn in $result.Warnings) {
            Write-Host "  $warn" -ForegroundColor Yellow
        }
        if ($hasError) {
            $FailFiles++
        }
        else {
            $WarningFiles++
        }
    }

    $Results += $result

    # 如果启用了 -Fix 且存在尾随空格问题，自动修复
    if ($Fix -and $result.Issues -match "尾随空格") {
        $Content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $fixedContent = $Content -replace '[ \t]+$', ''
        [System.IO.File]::WriteAllText($file.FullName, $fixedContent, [System.Text.UTF8Encoding]::new($false))
        Write-Host "  [FIX] 已自动清除尾随空格" -ForegroundColor Magenta
    }

    # 如果启用了 -Fix 且存在 UTF-8 BOM，自动移除
    if ($Fix -and $result.Warnings -match "UTF-8 BOM") {
        $Content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $contentBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Content)
        [System.IO.File]::WriteAllBytes($file.FullName, $contentBytes)
        Write-Host "  [FIX] 已自动移除 UTF-8 BOM" -ForegroundColor Magenta
    }

    # 如果启用了 -AutoFill，自动填充缺失的标准章节（VR-2.4.1-006）
    if ($AutoFill) {
        $afContent = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $afLines = $afContent -split "`n"
        $afChanged = $false

        # 提取技能名称用于模板
        $skillName = ""
        if ($afContent -match '(?s)^---\r?\n\s*name:\s*["'']?([^"''`\r\n]+)') {
            $skillName = $Matches[1]
        } elseif ($afContent -match '(?m)^#\s+(\S+)') {
            $skillName = $Matches[1]
        }

        # AutoFill: 缺少 ## 定位 章节时，在一级标题后插入
        if ($result.Issues -match "缺少 ## 定位") {
            $h1Idx = -1
            for ($i = 0; $i -lt $afLines.Count; $i++) {
                if ($afLines[$i].TrimStart() -match '^#\s+.+') {
                    $h1Idx = $i
                    break
                }
            }
            if ($h1Idx -ge 0) {
                $insertText = "`n## 定位`n`n> TODO: 请补充本技能的定位说明。`n"
                $afLines[$h1Idx] = $afLines[$h1Idx] + $insertText
                $afChanged = $true
                Write-Host "  [AUTOFILL] 已自动插入 ## 定位 章节模板" -ForegroundColor Magenta
            }
        }

        # AutoFill: 缺少 ## 触发条件 章节时，在 ## 定位 后插入
        if ($result.Issues -match "缺少 ## 触发条件") {
            $posIdx = -1
            for ($i = 0; $i -lt $afLines.Count; $i++) {
                if ($afLines[$i] -match '^\s*##\s+定位') {
                    $posIdx = $i
                    break
                }
            }
            if ($posIdx -ge 0) {
                # 找到定位章节结束位置（下一个 ## 或文件末尾）
                $insertIdx = $posIdx + 1
                for ($i = $posIdx + 1; $i -lt $afLines.Count; $i++) {
                    if ($afLines[$i] -match '^\s*##\s+') {
                        $insertIdx = $i
                        break
                    }
                    if ($i -eq $afLines.Count - 1) {
                        $insertIdx = $afLines.Count
                    }
                }
                $insertText = "## 触发条件`n`n- TODO: 请补充本技能的触发条件列表。`n"
                $afLines = $afLines[0..($insertIdx-1)] + @($insertText) + $afLines[$insertIdx..($afLines.Count-1)]
                $afChanged = $true
                Write-Host "  [AUTOFILL] 已自动插入 ## 触发条件 章节模板" -ForegroundColor Magenta
            }
        }

        # AutoFill: 缺少 ## 变更记录 章节时，在文件末尾追加
        if ($result.Issues -match "缺少 ## 变更记录") {
            $insertText = "`n## 变更记录`n`n| 日期 | 变更内容 | 变更人 |`n|---|---|---|`n"
            $afContent = $afLines -join "`n"
            $afContent = $afContent.TrimEnd() + $insertText
            $afLines = $afContent -split "`n"
            $afChanged = $true
            Write-Host "  [AUTOFILL] 已自动插入 ## 变更记录 章节模板" -ForegroundColor Magenta
        }

        # 写入修改后的内容
        if ($afChanged) {
            $afFinalContent = $afLines -join "`n"
            [System.IO.File]::WriteAllText($file.FullName, $afFinalContent, [System.Text.UTF8Encoding]::new($false))
        }
    }

    Write-Host ""
}

# ---- 汇总报告 ----
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " 检查报告汇总" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "总文件数:   $TotalFiles" -ForegroundColor White
Write-Host "通过:       $PassFiles" -ForegroundColor Green
Write-Host "警告:       $WarningFiles" -ForegroundColor Yellow
Write-Host "失败:       $FailFiles" -ForegroundColor Red
Write-Host ""

# 如果有失败的文件，列出文件清单
if ($FailFiles -gt 0) {
    Write-Host "失败文件清单:" -ForegroundColor Red
    foreach ($result in $Results) {
        if ($result.Issues.Count -gt 0) {
            Write-Host "  - $($result.RelativePath)" -ForegroundColor Red
        }
    }
    Write-Host ""
}

# 如果有警告的文件，列出文件清单
if ($WarningFiles -gt 0) {
    Write-Host "警告文件清单:" -ForegroundColor Yellow
    foreach ($result in $Results) {
        if ($result.Issues.Count -eq 0 -and $result.Warnings.Count -gt 0) {
            Write-Host "  - $($result.RelativePath)" -ForegroundColor Yellow
        }
    }
    Write-Host ""
}

# 退出码
if ($FailFiles -gt 0) {
    Write-Host "检查未通过。请修复上述问题后重新运行。" -ForegroundColor Red
    exit 1
}
elseif ($WarningFiles -gt 0) {
    Write-Host "检查通过（有警告）。建议处理警告项。" -ForegroundColor Yellow
    exit 0
}
else {
    Write-Host "全部检查通过！" -ForegroundColor Green
    exit 0
}
