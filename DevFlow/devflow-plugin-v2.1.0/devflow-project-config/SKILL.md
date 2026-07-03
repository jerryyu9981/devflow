---
name: devflow-project-config
description: "DevFlow 项目配置管理。生成和维护 .devflow/config.json，管理项目级设置（分支策略、备份配置、远程仓库）。被 devflow-init 和 setup 脚本调用。"
---

# DevFlow 项目配置（devflow-project-config）

## 定位

本技能管理项目的 DevFlow 配置。所有项目级设置都存储在 `.devflow/config.json` 中，技能文件本身**不硬编码任何路径或项目名**。

> **版本来源规则**：`devflowVersion` 的值必须与插件根目录 `version.json` 中的 `version` 字段保持完全一致。`version.json` 是 DevFlow 的唯一权威版本来源（Single Source of Truth）。更新版本时，先修改 `version.json`，再同步至本技能及所有引用位置。

## 触发条件

- 项目首次初始化（由 devflow-init 调用）
- 用户需要修改分支策略
- 用户需要配置备份远程仓库
- 用户需要更新 DevFlow 版本

## 配置项说明

### config.json 完整结构

```json
{
  "project": "项目名称",
  "devflowVersion": "2.4.1",
  "branchStrategy": "git-flow",
  "remote": {
    "origin": "git@github.com:org/project.git",
    "backup": "git@backup-server:org/project-backup.git"
  },
  "backup": {
    "type": "git-mirror",
    "environments": {
      "dev": {
        "backup": "git@backup-server:org/project-dev-backup.git"
      },
      "test": {
        "backup": "git@backup-server:org/project-test-backup.git"
      },
      "pro": {
        "backup": "git@backup-server:org/project-pro-backup.git",
        "disaster": "git@backup-server:org/project-disaster-backup.git"
      }
    },
    "schedule": {
      "type": "post-push",
      "weeklyArchive": "sunday-02:00",
      "retentionDays": 90
    }
  }
}
```

### 配置项详解

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `project` | string | 自动检测 | 项目名称，用于文档命名 |
| `devflowVersion` | string | "2.4.1" | 当前使用的 DevFlow 版本 |
| `branchStrategy` | enum | "git-flow" | 分支策略：`trunk-based` / `github-flow` / `git-flow` |
| `remote.origin` | string | "" | 主 Git 仓库地址 |
| `remote.backup` | string | "" | 备份 Git 仓库地址 |
| `backup.type` | enum | "git-mirror" | 备份方式：`git-mirror` / `git-bundle` |
| `backup.environments.dev.backup` | string | "" | 开发环境备份仓库地址 |
| `backup.environments.test.backup` | string | "" | 测试环境备份仓库地址 |
| `backup.environments.pro.backup` | string | "" | 生产环境备份仓库地址 |
| `backup.environments.pro.disaster` | string | "" | 容灾备份仓库地址（异地） |
| `backup.schedule.type` | enum | "post-push" | 备份触发方式：`post-push` / `cron` |
| `backup.schedule.weeklyArchive` | string | "sunday-02:00" | 每周归档时间 |
| `backup.schedule.retentionDays` | int | 90 | 备份保留天数 |

### 分支策略选择向导

| 场景 | 推荐策略 | 说明 |
|------|---------|------|
| 团队 <= 3 人，迭代快 | `trunk-based` | 主干开发，feature 分支生命周期 < 1 天 |
| 团队 3-10 人，CI/CD 完善 | `github-flow` | feature → main，合入即触发发布 |
| 团队 >= 5 人，多版本并行 | `git-flow` | feature → develop → release → main |

## 配置变更流程

```
1. 用户请求变更配置（如"切换为 GitHub Flow"）
2. 本技能读取当前 .devflow/config.json
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
- 本技能**只管理 .devflow/config.json 文件**
- 配置验证失败时，保留原配置并提示错误
