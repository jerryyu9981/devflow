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

### 3. 创建 .devflow/config.json

```json
{
  "project": "{项目名称}",
  "devflowVersion": "2.1.0",
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
