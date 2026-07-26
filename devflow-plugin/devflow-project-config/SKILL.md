---
name: devflow-project-config
description: "DevFlow 项目配置管理。生成和维护 .devflow/project-config.json，管理项目级设置（分支策略、备份配置、远程仓库）。被 devflow-init 和 setup 脚本调用。"
---

# DevFlow 项目配置（devflow-project-config）

## 定位

本技能管理项目的 DevFlow 配置。所有项目级设置都存储在 `.devflow/project-config.json` 中，技能文件本身**不硬编码任何路径或项目名**。

> **版本说明**：本技能生成的 `config.json` 中的 `projectVersion` 是项目当前开发版本号，由初始化时自动读取。插件自身版本号见插件根目录 `version.json`。

## 触发条件

- 项目首次初始化（由 devflow-init 调用）
- 用户需要修改分支策略
- 用户需要配置备份远程仓库
- 用户需要更新 DevFlow 版本

### 初始化仓库地址设置

初始化交互流程中必须包含以下步骤：

1. 展示仓库地址输入界面
2. 提示用户输入 Git 远程仓库地址（origin 和 backup）
3. 输入可留空，但必须显示强警告："未设置仓库地址将无法自动备份，建议在首次 commit 前设置"
4. 用户必须主动确认留空或填写后方可进入下一步
5. 确认后写入 config.json 的 remote.origin / remote.backup 字段

## 配置项说明

### config.json 完整结构

```json
{
  "_meta": {
    "description": "项目级 DevFlow 配置...",
    "schemaVersion": "1.1.0",
    "lastUpdated": "2026-07-26"
  },
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

### 配置项详解

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `_meta.schemaVersion` | string | "1.1.0" | 配置文件 schema 版本号 |
| `_meta.lastUpdated` | string | "2026-07-26" | 最后更新日期 |
| `project.name` | string | "" | 项目名称 |
| `project.version` | string | "" | 项目当前开发版本号 |
| `project.description` | string | "" | 项目描述 |
| `project.lastRelease` | null/object | null | 最近一次发布信息，初始为 null；填写格式: `{"version": "v2.10.0", "date": "2026-07-20"}` |
| `branchStrategy` | enum | "git-flow" | 分支策略：`trunk-based` / `github-flow` / `git-flow` |
| `remote.origin` | string | "" | 主 Git 仓库地址 |
| `remote.backup` | string | "" | 备份 Git 仓库地址 |
| `remote.github` | string | "" | GitHub 仓库地址 |

### 分支策略选择向导

| 场景 | 推荐策略 | 说明 |
|------|---------|------|
| 团队 <= 3 人，迭代快 | `trunk-based` | 主干开发，feature 分支生命周期 < 1 天 |
| 团队 3-10 人，CI/CD 完善 | `github-flow` | feature → main，合入即触发发布 |
| 团队 >= 5 人，多版本并行 | `git-flow` | feature → develop → release → main |

## 配置变更流程

```
1. 用户请求变更配置（如"切换为 GitHub Flow"）
2. 本技能读取当前 .devflow/project-config.json
3. 修改对应字段
4. 验证新配置的有效性（如 backup 地址是否为合法 Git URL）
5. 写回 config.json
6. 通知相关技能配置已变更
```

## 与环境变量的关系

| 环境变量 | 作用 | 优先级 |
|---------|------|--------|
| `DEVFLOW_PROJECT` | 覆盖 config.json 中的 project | 高于 config.json |
| `DEVFLOW_BRANCH_STRATEGY` | 覆盖分支策略 | 高于 config.json |
| `BACKUP_REMOTE_URL` | CI/CD 中的备份仓库地址 | 仅 CI/CD 环境使用 |

## 约束

- 本技能**不创建或修改 Git 仓库本身**
- 本技能**只管理 .devflow/project-config.json 文件**
- 配置验证失败时，保留原配置并提示错误
