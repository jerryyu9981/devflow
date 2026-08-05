---
name: devflow-init
description: "DevFlow 初始化 orchestrator。检测项目当前状态，推断所处开发阶段，引导用户进入正确的 DevFlow 阶段。每个项目首次使用 DevFlow 时调用。"
---

# DevFlow 初始化（devflow-init）

## 定位

本技能是 DevFlow 框架的入口 orchestrator。它不执行具体编码、设计或测试工作，而是：

1. **检测项目状态**：通过检查项目目录中的已有文档，推断项目当前处于 DevFlow 哪个阶段
2. **生成初始配置**：创建 `.devflow/config.json` 和 `.devflow/state.json`
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

### 2. 推断当前阶段

```
if 有部署执行记录:
    currentPhase = "step_5_deployed"  → 提示进入运维审计
elif 有测试报告:
    currentPhase = "step_4_testing"   → 提示检查是否可进入部署
elif 有 DevLogReport:
    currentPhase = "step_3_coding"    → 提示继续编码或进入测试
elif 有架构设计文档:
    currentPhase = "step_2_design"    → 提示开始编码（创建设计开发追溯矩阵）
elif 有需求文档:
    currentPhase = "step_1_requirements" → 提示开始架构设计
else:
    currentPhase = "step_0_planning"  → 提示从版本规划开始
```

### 2.5 远程仓库配置引导（交互式）

在创建配置文件之前，引导用户输入远程仓库地址。

**重要区分说明**：

> ⚠️ **此处输入的是您当前项目的 Git 远程仓库地址，非 DevFlow 下载地址。**
>
> 两种地址的区别：
> | 地址类型 | 说明 | 示例 |
> |---------|------|------|
> | **DevFlow 下载地址** | DevFlow 工具链自身的 Git 仓库，用于安装或更新 DevFlow | `http://192.168.0.14/jerry.yu/devflow.git` |
> | **项目远程仓库地址** | 您当前要管理的业务项目的 Git 仓库，用于代码推送和备份 | `http://192.168.0.14/jerry.yu/myproject.git` |

**交互流程**：

**Step A — 输入 origin 远程仓库地址**

提示用户：
```
请输入您当前项目的 Git 远程仓库地址（origin）。
格式：https://host/org/repo.git 或 git@host:org/repo.git 或 ssh://host/org/repo.git
（可留空，后续通过 git remote add 手动配置）
```

校验规则：
- 允许空值（用户跳过）
- 非空值须为合法 Git URL 格式（http/https/ssh/git 协议）
- 不合法时提示格式错误并给出正确示例

**Step B — 输入 backup 远程仓库地址（可选）**

提示用户：
```
请输入备份仓库地址（backup，可选）。
格式同上，用于自动镜像备份。
（可留空）
```

校验规则：同 Step A，但始终可选。

**输出**：将用户输入的 origin 和 backup 地址写入 `.devflow/config.json` 的 `remote.origin` 和 `remote.backup` 字段。用户跳过时保持空字符串 `""`。

### 3. 创建 .devflow/config.json

```json
{
  "project": "{项目名称}",
  "devflowVersion": "{从 version.json 动态读取}",
  "branchStrategy": "git-flow",
  "remote": {
    "origin": "",
    "backup": ""
  },
  "backup": {
    "type": "git-mirror",
    "schedule": {
      "bundle": "weekly",
      "bundleRetention": 4,
      "dbDump": "daily",
      "dbRetention": 90
    }
  }
}
```

**远程仓库地址来源**：`remote.origin` 和 `remote.backup` 由步骤 2.5 的交互式引导填充。用户跳过时保持空字符串。

**已有项目的远程仓库地址**：如果用户已有 Git 仓库且已配置 remote，可读取 `git remote get-url origin` 作为默认值展示在交互引导中，用户确认或修改。

**版本号单一来源原则（Single Source of Truth）**：

> **严禁**在任何技能文件（包括本文件）中硬编码 DevFlow 版本号。版本号的唯一权威来源是插件根目录下的 `version.json` 文件。
>
> | 职责 | 行为 |
> >------|------|
> > `version.json` | **唯一**存放版本号的文件，格式为 `{"version": "x.y.z"}` |
> > `setup.ps1` / `install.ps1` | 从 `version.json` 读取版本号后写入 `config.json` 的 `devflowVersion` 字段 |
> > `devflow-init` 技能 | 从项目 `.devflow/config.json` 读取版本号用于显示，**不硬编码** |
> > `update.ps1` | 从目标版本的 `version.json` 读取新版本号，更新 `config.json` |
> > 所有 SKILL.md | 模板中使用 `{从 version.json 动态读取}` 占位，**不得出现具体版本号** |
>
> **发布新版本时的检查清单**：
> 1. 更新 `version.json` 中的版本号
> 2. 更新 `CHANGELOG.md`
> 3. 全局搜索所有 SKILL.md 确认无硬编码版本号残留：`grep -rn "2\.[0-9]\+\.[0-9]\+" skills/ devflow-init/ devflow-phase-manager/ devflow-project-config/`

**项目名检测顺序**：
1. 如果项目有 `package.json`，读取 `name` 字段
2. 如果项目有 Git 仓库，读取 `git remote get-url origin` 中的仓库名
3. 否则使用当前目录名

### 4. 创建 .devflow/state.json

```json
{
  "project": "{项目名称}",
  "version": "",
  "currentPhase": "{推断的阶段}",
  "completedPhases": [],
  "currentDocuments": {},
  "auditResults": {}
}
```

### 5. 输出初始化报告

报告内容：
- 检测到的项目结构
- 推断的当前阶段
- 建议的下一步操作
- 生成的配置文件路径

## 安装 Git Hook（可选）

如果用户同意，安装 post-push hook 实现自动备份：

```bash
#!/bin/bash
# DevFlow auto-backup hook
if git remote | grep -q backup; then
    git push --mirror backup 2>/dev/null
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

## 变更记录

| 日期 | 变更内容 | 变更人 |
|---|---|---|
| 2026-07-02 | 添加变更记录章节 | jerry.yu |
| 2026-07-04 | VR-019/DT-001: 新增远程仓库交互式配置引导步骤（§2.5），明确区分 DevFlow 下载地址与项目远程仓库地址 | jerry.yu |
