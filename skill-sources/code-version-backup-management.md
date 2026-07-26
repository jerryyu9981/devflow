---
name: "code-version-backup-management"
description: "代码版本控制与备份管理规范。管理 Git 工作流、分支策略、提交约定、版本号和备份策略。被 coding-stage-execution / testing-stage-execution / operations-stage-execution 调用。"
---

# 代码版本与备份管理

## 定位

本技能定义项目的代码版本控制与备份管理规范，包括 Git 工作流、分支策略、提交约定和备份策略。它是 Step 3 编码阶段、Step 4 测试阶段和 Step 5 部署运维阶段的版本管理依据。

应用 `version-planning` 中定义的版本规则，与 `cicd-pipeline-management` 中 CI/CD 流水线联动，实现代码版本的全生命周期管理。

---

## 一、项目配置驱动

### 1.1 配置方式

仓库路径、分支策略和远程仓库由 `{project_root}/.devflow/project-config.json` 定义，本技能读取该配置执行，不硬编码路径。

```json
{
  "project": "{项目名}",
  "branchStrategy": "git-flow",
  "remote": {
    "origin": "git@github.com:org/{项目名}.git",
    "backup": "git@backup-server:org/{项目名}-backup.git"
  },
  "backup": {
    "type": "git-mirror"
  }
}
```

### 1.2 项目根目录

`{project_root}` 代表项目根目录，由 DevFlow setup 脚本在安装时注入，**不硬编码为任何特定路径**（如 D:）。

---

## 二、分支策略（可配置）

### 2.1 配置选择

在 `.devflow/project-config.json` 中设置 `branchStrategy` 字段，支持三种模式：`trunk-based` / `github-flow` / `git-flow`。