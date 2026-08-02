---
name: devflow-init
description: "DevFlow 初始化 orchestrator。检测项目当前状态，推断所处开发阶段，引导用户进入正确的 DevFlow 阶段。每个项目首次使用 DevFlow 时调用。"
---

# DevFlow 初始化（devflow-init）

## 定位

本技能是 DevFlow 框架的入口 orchestrator。它不执行具体编码、设计或测试工作，而是：

> **版本来源规则**：DevFlow 插件版本号以 `devflow-plugin/devflow-config.json` 的 `devflowVersion` 字段为唯一事实源（Single Source of Truth）。该文件由 Install/Update 脚本同步至 TRAE 系统目录（`~/.trae-cn/skills/devflow-config/devflow-config.json`）。`version.json` 已自 v2.15.0 起彻底弃用并删除，不再作为版本来源。

1. **检测项目状态**：通过检查项目目录中的已有文档，推断项目当前处于 DevFlow 哪个阶段
2. **生成初始配置**：创建 `.devflow/project-config.json` 和 `.devflow/state.json`
3. **引导进入正确阶段**：告诉用户当前应该执行 Step 0-5 中的哪一个

## 触发条件

- 项目首次安装 DevFlow 插件时
- 用户说"开始使用 DevFlow"或"初始化 DevFlow"
- 项目目录结构发生显著变化（如突然出现了 design/ 目录）
- `.devflow/state.json` 丢失或损坏

## 初始化流程

### 1. 扫描项目目录

检查以下文件/目录的存在性：

| 检查项 | 存在 = 该阶段已完成 | 路径模式 |
|--------|-------------------|---------|
| `doc/version/releases/` 下有版本规划文档 | Step 0 完成 | `doc/version/releases/v*/` |
| `doc/requirements/` 下有需求文档 | Step 1 完成 | `doc/requirements/*-开发需求文档-*.md` |
| `doc/design/` 下有架构设计文档 | Step 2 完成 | `doc/design/*-系统架构设计文档-*.md` |
| `doc/development/` 下有 DevLogReport | Step 3 进行中或完成 | `doc/development/*-DevLogReport-*.md` |
| `doc/test/` 下有测试报告 | Step 4 完成 | `doc/test/*-测试报告-*.md` |
| `doc/operation/` 下有部署执行记录 | Step 5 完成 | `doc/operation/*-部署执行记录-*.md` |

### 1.5 获取 DevFlow 版本号

从 `~/.trae-cn/skills/devflow-config/devflow-config.json` 读取 `devflowVersion` 字段作为 DevFlow 插件版本号。

```bash
# 读取方式示例
cat ~/.trae-cn/skills/devflow-config/devflow-config.json
# → { "name": "DevFlow", "devflowVersion": "2.9.1", ... }
```

**降级规则**：
- 若 TRAE 技能目录 `devflow-config.json` 不存在（如未安装或同步），则读取项目内 `devflow-plugin/devflow-config.json` 的 `devflowVersion` 字段
- 若仍无法读取，标记为 `"unknown"`

### 1.5.5 版本差异检测

比较 TRAE 系统目录中已安装的 DevFlow 版本与项目 `.devflow/state.json` 中记录的版本，发现差异时提示用户。

**读取来源**：

| 版本 | 来源路径 | 字段 |
|:----|:--------|:----|
| `devflowVersionInTrae`（TRAE 已安装版本） | `~/.trae-cn/skills/devflow-config/devflow-config.json` | `devflowVersion` |
| `devflowVersionInProject`（项目记录版本） | `.devflow/state.json` | `devflowVersion` |

**比较逻辑**：

```
if devflowVersionInTrae == devflowVersionInProject:
    → 版本一致，无需操作
    → versionCheck.result = "consistent"
    → versionCheck.action = "no_action"

elif devflowVersionInTrae > devflowVersionInProject（语义版本比较）:
    → TRAE 已安装版本更新
    → 自动更新 .devflow/state.json.devflowVersion = devflowVersionInTrae
    → 提示用户："TRAE 已安装 DevFlow {devflowVersionInTrae}，项目记录已自动更新"
    → versionCheck.result = "installed_newer"
    → versionCheck.action = "auto_updated"

elif devflowVersionInTrae < devflowVersionInProject（语义版本比较）:
    → 项目记录版本更高（异常情况）
    → 提示用户，不自动修改
    → versionCheck.result = "project_newer"
    → versionCheck.action = "user_prompted"
```

**语义版本比较说明**：版本号格式为 `major.minor.patch`（如 `2.8.0`），逐段比较数字。例如 `2.8.0` > `2.7.5`，`2.7.10` > `2.7.9`。

**降级处理**：
- 若 `.devflow/state.json` 不存在（首次初始化），跳过版本检测，`versionCheck.result = "first_check"`
- 若 TRAE 系统目录 `devflow-config.json` 不存在，跳过版本检测，`versionCheck.result = "error"`

**写入 state.json**：

```json
{
  "devflowVersion": "{比较后确定的版本号}",
  "versionCheck": {
    "lastCheck": "{当前时间}",
    "installedDevflowVersion": "{devflowVersionInTrae}",
    "recordedDevflowVersion": "{devflowVersionInProject}",
    "result": "{比较结果}",
    "action": "{执行动作}"
  }
}
```

### 1.5.5 技能数量一致性检测（DT-07）

在版本检测之后执行技能数量一致性检查：

```powershell
# 从 TRAE 系统目录读取 devflow-config.json（v2.9.1+），降级到 devflow-manifest.json
$configPath = "$env:USERPROFILE\.trae-cn\skills\devflow-config\devflow-config.json"
$manifestPath = "$env:USERPROFILE\.trae-cn\skills\devflow-plugin-config\devflow-manifest.json"

$skillConfig = $null
$configSource = ""
if (Test-Path $configPath) {
    $skillConfig = Get-Content $configPath -Encoding UTF8 | ConvertFrom-Json
    $configSource = "devflow-config.json"
} elseif (Test-Path $manifestPath) {
    $skillConfig = Get-Content $manifestPath -Encoding UTF8 | ConvertFrom-Json
    $configSource = "devflow-manifest.json (legacy)"
}

if ($skillConfig) {
    try {
        $installedSkills = Get-ChildItem "$env:USERPROFILE\.trae-cn\skills" -Directory |
            Where-Object { $skillConfig.skills.name -contains $_.Name }
        if ($installedSkills.Count -ne $skillConfig.skillCount) {
            Write-Warn "[WARN] DevFlow skill count mismatch: installed=$($installedSkills.Count), expected=$($skillConfig.skillCount) ($configSource)"
            Write-Warn "[WARN] Run 'sync-skills.ps1 -Action Sync -Target IDE' to reinstall"
        }
    } catch {
        Write-Warn "[WARN] Skill count check skipped: $_"
    }
} else {
    Write-Warn "[WARN] Neither devflow-config.json nor devflow-manifest.json found, skill count check skipped"
}
```

---

### 1.6 版本号事实源确认（version.json 已弃用）

> **v2.15.0 变更**：`version.json` 已彻底弃用并删除。版本号唯一事实源为 `devflow-plugin/devflow-config.json` 的 `devflowVersion` 字段。初始化时不再创建 `version.json`，不再执行 version.json 字段补全逻辑。项目使用的 DevFlow 版本通过 `.devflow/state.json` 的 `devflowVersion` 字段记录（由 1.5 版本检测步骤写入），该字段是 `devflow-config.json` 的同步副本，非独立事实源。

### 1.7 检测项目版本号

按照优先级链自动检测项目自身版本号，写入 `.devflow/project-config.json` 的 `projectVersion` 字段：

```
检测优先级链：
① .devflow/project-config.json 已有非空 projectVersion     → 保留，不修改
② git describe --tags --abbrev=0                   → 取 tag 值（去掉前缀 v）
③ package.json 的 version 字段                      → 取该值
④ pyproject.toml 的 version 字段                    → 取该值
⑤ 其他项目配置文件中的 version 字段                  → 取该值
⑥ 以上均无法获取                                    → 交互询问用户输入
```

### 2. 推断当前阶段

```
扫描文档目录，按以下优先级判断：
if 有部署执行记录:
    currentPhase = "step_5_deployed"
elif 有测试报告:
    currentPhase = "step_4_testing"
elif 有 DevLogReport:
    currentPhase = "step_3_coding"
elif 有架构设计文档:
    currentPhase = "step_2_design"
elif 有需求文档:
    currentPhase = "step_1_requirements"
else:
    currentPhase = "step_0_planning"
```

**推断完成后，将结果写入 `.devflow/state.json` 的 `currentPhase` 字段和 `completedPhases` 字段**（而非仅提示用户）。`completedPhases` 基于 `currentPhase` 倒推：
- `currentPhase = step_4_testing` → `completedPhases = [step_0_planning, step_1_requirements, step_2_design, step_3_coding]`
- 当前阶段本身不包含在 `completedPhases` 中

### 3. 创建 .devflow/project-config.json

```json
{
  "project": {
    "name": "",
    "version": "",
    "description": "",
    "lastRelease": null
  },
  "remote": {
    "origin": "",
    "backup": "",
    "github": ""
  },
  "branchStrategy": "git-flow"
}
```

**项目名检测顺序**：
1. 如果项目有 `package.json`，读取 `name` 字段
2. 如果项目有 Git 仓库，读取 `git remote get-url origin` 中的仓库名
3. 否则使用当前目录名

**如果 `.devflow/project-config.json` 已存在**，则只更新 `projectVersion` 字段，保留其他字段不变。

### 3.1 远程仓库地址交互输入

> 如果 config 已存在且 remote.origin/backup 已有值，则跳过此步骤（向后兼容）。

在创建/更新 config.json 后，执行交互确认：

1. 提示输出：`当前配置中远程仓库地址：origin="{current_origin}", backup="{current_backup}"`
2. 询问：`是否更新远程仓库地址？(Y/N) [默认 N]：`
3. 如果回答 Y：
   - 提示：`请输入远程仓库地址（origin）：`
   - 输入后显示：`远程仓库地址为：{url}，确认？(Y/N)`
   - Y → 写入 config.json 的 remote.origin 字段
   - N → 重新输入或跳过
   - 继续提示：`请输入备份仓库地址（backup，可选，留空跳过）：`
   - 输入后按同样逻辑确认
4. 如果回答 N → 跳过，保持现有配置

### 4. 创建 .devflow/state.json

```json
{
  "project": "{项目名称}",
  "devflowVersion": "{1.5 获取到的 DevFlow 版本号}",
  "currentPhase": "{2. 推断的阶段}",
  "completedPhases": ["{基于 currentPhase 倒推的已完成阶段}"],
  "currentDocuments": {},
  "auditResults": {}
}
```

**注意**：`devflowVersion` 字段填入 DevFlow 插件版本号（来自步骤 1.5），`currentPhase` 和 `completedPhases` 填入步骤 2 的推断结果。

**如果 `.devflow/state.json` 已存在**，则合并更新 `devflowVersion`、`currentPhase`、`completedPhases` 字段，保留 `currentDocuments` 和 `auditResults` 中的已有值。

### 5. 输出初始化报告

报告内容：
- 检测到的 DevFlow 版本号
- 检测到的项目名称和项目版本号
- 检测到的项目文档结构
- 推断的当前阶段
- 建议的下一步操作
- 远程仓库地址配置状态（已配置/已跳过/未配置）
- 生成的配置文件路径

## 安装 Git Hook（可选）

如果用户同意，安装 post-push hook 实现自动备份：

```bash
#!/bin/bash
# DevFlow 自动备份 Hook
# 安装方式：cp .devflow/hooks/post-push .git/hooks/post-push && chmod +x .git/hooks/post-push

REMOTE_NAME="${1:-backup}"
LOG_DIR=".devflow/logs"
mkdir -p "$LOG_DIR"

if git remote | grep -q "$REMOTE_NAME"; then
    echo "[DevFlow Backup] $(date '+%Y-%m-%d %H:%M:%S') 开始备份到 $REMOTE_NAME ..."
    git push --mirror "$REMOTE_NAME" 2>&1
    git push --tags "$REMOTE_NAME" 2>&1

    if [ $? -eq 0 ]; then
        echo "[DevFlow Backup] 备份完成"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),git-mirror,成功,$(git rev-parse HEAD)" >> "$LOG_DIR/backup-history.csv"
    else
        echo "[DevFlow Backup] 备份失败"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),git-mirror,失败,$(git rev-parse HEAD)" >> "$LOG_DIR/backup-error.csv"
    fi
else
    echo "[DevFlow Backup] 未找到远程仓库 '$REMOTE_NAME'，跳过备份"
fi
```

## 与其他技能的协作

| 调用关系 | 说明 |
|---------|------|
| `devflow-project-config` | 生成 config.json 的具体逻辑委托给此技能 |
| `devflow-phase-manager` | 状态持久化委托给此技能 |
| `version-planning-stage-execution` | 如果推断当前在 Step 0，引导调用此技能 |

## 约束

- 本技能**不修改任何业务代码**
- 本技能**不创建实际的需求/设计/测试文档**
- 本技能只做**状态检测和配置生成**
