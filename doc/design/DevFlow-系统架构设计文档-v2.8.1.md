# DevFlow 系统架构设计文档

| 属性 | 值 |
|------|-----|
| 版本 | v2.8.1 |
| 状态 | [Approved] |
| 日期 | 2026-07-15 |
| 作者 | AA-DevFlow-Dev |
| 适用范围 | DevFlow 脚本优化版本 |

---

## 修订历史

| 版本 | 日期 | 作者 | 变更说明 | 状态 |
|------|------|------|----------|------|
| v2.8.1 | 2026-07-15 | AA-DevFlow-Dev | 初始版本：update.ps1 硬编码修复、download 版本比较+交互确认、setup 交互确认、init 文件同步 | [Approved] |

---

## 1. 设计入场检查

### 1.1 前置依赖检查

| 检查项 | 结果 | 说明 |
|--------|------|------|
| 需求文档已批准 | 通过 | 《DevFlow-需求文档-v2.8.1.md》状态 [Approved] |
| 上一版本设计文档 | 通过 | v2.8.0 设计文档已归档 |
| 架构变更评估 | 通过 | **本版本为脚本修改版本，无系统架构/UI/API/数据模型变更，设计大幅简化** |
| 兼容性评估 | 通过 | 仅修改 PowerShell 脚本交互逻辑，不影响现有系统行为 |

### 1.2 设计范围声明

本版本（v2.8.1）为脚本级优化版本，设计范围限定如下：

- **不涉及** 系统架构变更
- **不涉及** UI/UX 设计变更
- **不涉及** API 接口设计变更
- **不涉及** 数据模型设计变更
- **仅涉及** 4 个 PowerShell 脚本文件的交互逻辑与文件处理优化

---

## 2. 需求-设计追溯矩阵

| DT-ID | 设计项 | 关联 RT-ID | 覆盖需求 | 状态 |
|:------|:-------|:----------|:---------|:-----|
| DT-038 | update.ps1 扩展名判断 | RT-038 | V260-038 | 已设计 |
| DT-044-1 | download 源/目的地址确认 | RT-044-1 | V260-044 (AC-01) | 已设计 |
| DT-044-2 | download 远程版本比较 | RT-044-2 | V260-044 (AC-02) | 已设计 |
| DT-045 | setup 安装前交互确认 | RT-045 | V260-045 (AC-03/AC-06) | 已设计 |
| DT-046 | init 配置同步 | RT-046 | V260-046 (AC-05) | 已设计 |

**覆盖率：5/5 = 100%**

---

## 3. 设计项详细说明

### 3.1 DT-038：update.ps1 扩展名判断

**修改文件**：`update.ps1`

**代码位置**：第 153 行

**现有代码**：

```powershell
$dst = Join-Path $dstDir "SKILL.md"
```

**设计修改**：

在第 153 行增加扩展名判断逻辑，参照 setup.ps1 的 V260-037 方案：

```powershell
# 获取源文件扩展名
$ext = [System.IO.Path]::GetExtension($_.Name).ToLower()
if ($ext -eq ".md") {
    $dst = Join-Path $dstDir "SKILL.md"
} else {
    $dst = Join-Path $dstDir $_.Name
}
```

**设计要点**：

1. 使用 `[System.IO.Path]::GetExtension()` 获取源文件扩展名
2. 转换为小写后进行比较，确保大小写不敏感
3. `.md` 扩展名 → 目标文件名固定为 `SKILL.md`
4. 其他扩展名 → 保留原文件名
5. 该逻辑与 setup.ps1 的 V260-037 方案保持一致

---

### 3.2 DT-044-1：download 源/目的地址确认

**修改文件**：`download-devflow.ps1`

**代码位置**：Clone/Update 模式开头

**设计修改**：

在 Clone 模式和 Update 模式的开头增加交互确认逻辑：

```powershell
# 读取 version.json 获取仓库地址
$versionJsonPath = Join-Path $PSScriptRoot "version.json"
$versionData = Get-Content $versionJsonPath -Raw | ConvertFrom-Json
$repoUrl = $versionData.repository

# 展示源地址和目的地址
Write-Host "========================================"
Write-Host "  DevFlow 下载/更新确认"
Write-Host "========================================"
Write-Host "源地址：$repoUrl"
Write-Host "目的地址：$PWD"
Write-Host "========================================"

# 交互确认
$confirm = Read-Host "确认执行? (y/N)"
if ($confirm -notmatch "^[yY]$") {
    Write-Host "操作已取消。" -ForegroundColor Yellow
    exit 0
}
```

**设计要点**：

1. 从 `version.json` 中读取 `repository` 字段作为源地址
2. 默认目的地址为当前工作目录 `$PWD`
3. 清晰展示源地址和目的地址
4. 使用 `Read-Host` 获取用户输入
5. 仅输入 `y` 或 `Y` 时继续执行，其他输入均取消操作并退出

---

### 3.3 DT-044-2：download 远程版本比较

**修改文件**：`download-devflow.ps1`

**新增函数**：`Get-RemoteVersion`

**设计修改**：

#### 3.3.1 新增函数 `Get-RemoteVersion`

```powershell
function Get-RemoteVersion {
    param(
        [string]$RepoUrl
    )

    try {
        # 使用 git ls-remote 获取远程最新 tag
        $output = git ls-remote --tags $RepoUrl 2>$null
        if (-not $output) {
            return $null
        }

        # 解析所有 tag，提取版本号
        $versions = $output | ForEach-Object {
            if ($_ -match "refs/tags/v?(\d+\.\d+\.\d+)") {
                [System.Version]$matches[1]
            }
        } | Sort-Object -Descending

        if ($versions.Count -eq 0) {
            return $null
        }

        return $versions[0]
    }
    catch {
        Write-Warning "获取远程版本失败：$($_.Exception.Message)"
        return $null
    }
}
```

#### 3.3.2 版本比较与执行逻辑

```powershell
# 获取本地版本
$localVersionStr = $versionData.devflowVersion
$localVersion = [System.Version]$localVersionStr

# 获取远程版本
$remoteVersion = Get-RemoteVersion -RepoUrl $repoUrl

if ($remoteVersion) {
    Write-Host "本地版本：v$localVersion"
    Write-Host "远程版本：v$remoteVersion"

    if ($remoteVersion -gt $localVersion) {
        Write-Host "发现新版本，开始更新..." -ForegroundColor Green
        # 执行 git clone / git pull
    } else {
        Write-Host "已是最新版本，无需更新。" -ForegroundColor Cyan
        exit 0
    }
} else {
    Write-Warning "无法获取远程版本，跳过版本比较。"
    # 继续执行 git clone / git pull
}
```

**设计要点**：

1. 使用 `git ls-remote --tags origin` 获取远程所有 tag
2. 使用正则表达式解析语义版本号（支持 `v` 前缀可选）
3. 将版本字符串转换为 `[System.Version]` 对象进行语义比较
4. 远程版本 > 本地版本时才执行 git 操作
5. 远程版本 <= 本地版本时输出提示并退出
6. 获取远程版本失败时输出警告但继续执行（容错处理）

---

### 3.4 DT-045：setup 安装前交互确认

**修改文件**：`setup.ps1`

**代码位置**：`foreach ($skillName in $skillMap.Keys)` 循环前

**设计修改**：

```powershell
# 读取版本信息
$versionJsonPath = Join-Path $PSScriptRoot "version.json"
$versionData = Get-Content $versionJsonPath -Raw | ConvertFrom-Json
$devflowVersion = $versionData.devflowVersion

# 统计技能数量
$skillCount = $skillMap.Keys.Count

# 获取 TRAE 路径（假设 $traePath 已定义）
$traePath = $env:TRAE_PATH  # 或从配置中读取的实际路径

# 展示安装信息
Write-Host "========================================"
Write-Host "  DevFlow 技能安装确认"
Write-Host "========================================"
Write-Host "版本：DevFlow v$devflowVersion"
Write-Host "技能数量：$skillCount 个"
Write-Host "目标路径：$traePath"
Write-Host "========================================"

# 交互确认
$confirm = Read-Host "确认安装? (y/N)"
if ($confirm -notmatch "^[yY]$") {
    Write-Host "安装已取消。" -ForegroundColor Yellow
    exit 0
}

# 继续执行原有循环
foreach ($skillName in $skillMap.Keys) {
    # ... 原有逻辑
}
```

**设计要点**：

1. 读取 `version.json` 的 `devflowVersion` 字段
2. 统计 `$skillMap.Keys.Count` 获取技能数量
3. 展示版本号、技能数量和目标 TRAE 路径
4. 使用 `Read-Host` 获取用户确认
5. 仅输入 `y` 或 `Y` 时继续执行循环
6. 输入 `N` 或其他字符时退出脚本

---

### 3.5 DT-046：init 文件同步

**修改文件**：`devflow-init/SKILL.md`

**代码位置**：§1.5.5 "installed_newer" 分支中

**新增函数**：`Sync-DevFlowConfig`

**设计修改**：

#### 3.5.1 新增函数 `Sync-DevFlowConfig`

```powershell
function Sync-DevFlowConfig {
    param(
        [string]$TraeDir,
        [string]$ProjectDir
    )

    $syncReport = @{
        config = @{ added = @(); preserved = @(); modified = @() }
        state  = @{ added = @(); preserved = @(); modified = @() }
    }

    # === 同步 config.json ===
    $traeConfigPath = Join-Path $TraeDir ".devflow\config.json"
    $projectConfigPath = Join-Path $ProjectDir ".devflow\config.json"

    if (Test-Path $traeConfigPath) {
        $traeConfig = Get-Content $traeConfigPath -Raw | ConvertFrom-Json
        $projectConfig = @{}

        if (Test-Path $projectConfigPath) {
            $projectConfig = Get-Content $projectConfigPath -Raw | ConvertFrom-Json
        }

        # 合并：新增字段写入默认值，保留已有值
        foreach ($key in $traeConfig.PSObject.Properties.Name) {
            if (-not $projectConfig.PSObject.Properties[$key]) {
                $projectConfig | Add-Member -NotePropertyName $key -NotePropertyValue $traeConfig.$key
                $syncReport.config.added += $key
            } else {
                $syncReport.config.preserved += $key
            }
        }

        # 保存合并后的 config.json
        $projectConfig | ConvertTo-Json -Depth 10 | Set-Content $projectConfigPath -Encoding UTF8
    }

    # === 同步 state.json ===
    $traeStatePath = Join-Path $TraeDir ".devflow\state.json"
    $projectStatePath = Join-Path $ProjectDir ".devflow\state.json"

    if (Test-Path $traeStatePath) {
        $traeState = Get-Content $traeStatePath -Raw | ConvertFrom-Json
        $projectState = @{}

        if (Test-Path $projectStatePath) {
            $projectState = Get-Content $projectStatePath -Raw | ConvertFrom-Json
        }

        # 合并：新增字段写入默认值，保留已有值
        foreach ($key in $traeState.PSObject.Properties.Name) {
            if (-not $projectState.PSObject.Properties[$key]) {
                $projectState | Add-Member -NotePropertyName $key -NotePropertyValue $traeState.$key
                $syncReport.state.added += $key
            } else {
                $syncReport.state.preserved += $key
            }
        }

        # 保存合并后的 state.json
        $projectState | ConvertTo-Json -Depth 10 | Set-Content $projectStatePath -Encoding UTF8
    }

    # === 输出同步结果报告 ===
    Write-Host ""
    Write-Host "=== DevFlow 配置同步报告 ===" -ForegroundColor Cyan
    Write-Host "config.json："
    Write-Host "  新增字段：$($syncReport.config.added -join ', ')"
    Write-Host "  保留字段：$($syncReport.config.preserved -join ', ')"
    Write-Host "state.json："
    Write-Host "  新增字段：$($syncReport.state.added -join ', ')"
    Write-Host "  保留字段：$($syncReport.state.preserved -join ', ')"
    Write-Host "===========================" -ForegroundColor Cyan
    Write-Host ""

    return $syncReport
}
```

#### 3.5.2 在 installed_newer 分支中调用

```powershell
# 在 §1.5.5 "installed_newer" 分支中
"installed_newer" {
    # 更新 state.json 中的 devflowVersion
    $state.devflowVersion = $installedVersion
    Save-StateJson -Path $stateJsonPath -Data $state

    # 新增：同步配置文件
    Write-Host "检测到 DevFlow 新版本，正在同步配置文件..." -ForegroundColor Yellow
    $syncResult = Sync-DevFlowConfig -TraeDir $traeDir -ProjectDir $projectDir
    Write-Host "配置文件同步完成。" -ForegroundColor Green

    # 继续原有逻辑...
}
```

**设计要点**：

1. 定义 `Sync-DevFlowConfig` 函数，接收 TRAE 目录和项目目录两个参数
2. 读取 TRAE 目录的 `config.json` 模板作为基准
3. 与项目 `.devflow/config.json` 合并：
   - 模板中存在但项目中不存在的字段 → 新增并写入默认值
   - 项目中已存在的字段 → 保留原值不变
4. 对 `state.json` 执行同样的合并逻辑
5. 输出同步结果报告，包括新增字段和保留字段列表
6. 在 "installed_newer" 分支中，更新 `state.json.devflowVersion` 后调用同步函数

---

## 4. 覆盖率声明

本设计文档覆盖 v2.8.1 全部 4 项需求（V260-038、V260-044、V260-045、V260-046），共 5 个设计项（DT-038、DT-044-1、DT-044-2、DT-045、DT-046）。

**需求-设计覆盖率：5/5 = 100%**

所有设计项均包含：
- 明确的修改文件定位
- 具体的代码位置或函数定义
- 新增/修改的代码逻辑（伪代码/代码片段）
- 设计要点说明

---

## 5. 风险与约束

| 风险项 | 等级 | 说明 | 缓解措施 |
|--------|------|------|----------|
| 版本比较失败 | 低 | `git ls-remote` 可能因网络问题失败 | 已设计容错逻辑：失败时跳过比较继续执行 |
| 用户交互中断脚本 | 低 | `Read-Host` 在非交互环境可能阻塞 | 本脚本仅在交互式 PowerShell 环境中使用 |
| 配置合并冲突 | 低 | 同名字段类型不一致可能导致异常 | 模板与项目配置字段类型保持一致 |
| 文件名判断遗漏 | 低 | 其他大小写变体（如 .MD） | 已设计 `.ToLower()` 转换确保大小写不敏感 |

---

## 6. 附录

### 6.1 术语表

| 术语 | 说明 |
|------|------|
| SKILL.md | DevFlow 技能定义文件，Markdown 格式 |
| semantic version | 语义化版本号，格式：主版本.次版本.修订号 |
| git ls-remote | Git 命令，用于查看远程仓库引用而不下载 |

### 6.2 参考资料

- 《DevFlow-需求文档-v2.8.1.md》
- `setup.ps1` V260-037 方案实现
- PowerShell 官方文档：`Read-Host`、`Join-Path`、`ConvertFrom-Json`
