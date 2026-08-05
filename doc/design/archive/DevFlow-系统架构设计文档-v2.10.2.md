# DevFlow 系统架构设计文档 — v2.10.2

> 文档类型：系统架构设计文档（数据结构变更 + 流程规则增强）
> 版本：v2.10.2
> 日期：2026-07-26

---

## 1. 设计概述

本版本为项目配置名片标准化，核心变更为 **project-config.json 数据结构补全** 和 **Step 5 发布复盘联动规则追加**。不涉及前端/后端代码或外部集成。

### 1.1 变更分类

| 变更类型 | 数量 | 说明 |
|:---------|:----:|:------|
| JSON 结构补充 | 2 个字段 | `project.lastRelease.{version,date}` + `remote.github` |
| 流程规则追加 | 1 条断言 | Step 5 发布复盘（5.10）追加更新 lastRelease |
| 技能文档修改 | 3 个 | `operations-stage-execution`、`devflow-init`、`devflow-project-config` |
| 框架引用更新 | 1 处 | `devflow-config.json` deprecatedFiles 字段 |

### 1.2 影响范围

| 文件 | 变更类型 |
|:-----|:---------|
| `.devflow/project-config.json` | 🔴 数据结构变更（加字段） |
| `devflow-plugin/skills/L2/operations-stage-execution.md` | 🟡 流程断言追加 |
| `devflow-plugin/.trae/skills/operations-stage-execution/SKILL.md` | 🟡 副本同步 |
| `devflow-plugin/devflow-init/SKILL.md` | 🟡 创建模板更新 |
| `devflow-plugin/.trae/skills/devflow-init/SKILL.md` | 🟡 副本同步 |
| `devflow-plugin/devflow-project-config/SKILL.md` | 🟡 技能模板更新 |
| `devflow-plugin/.trae/skills/devflow-project-config/SKILL.md` | 🟡 副本同步 |
| `devflow-plugin/devflow-config.json` | 🟢 deprecatedFiles 更新 |

---

## 2. 数据结构设计

### 2.1 project-config.json 新结构

```json
{
  "_meta": {
    "description": "项目级 DevFlow 配置文件。每个项目独立维护，包含项目元数据、远程仓库和发布记录。",
    "schemaVersion": "1.1.0",
    "lastUpdated": "2026-07-26"
  },
  "project": {
    "name": "DevFlow",
    "version": "v2.10.0",
    "description": "DevFlow 软件开发工程规范框架",
    "lastRelease": {
      "version": "v2.10.1",
      "date": "2026-07-26"
    }
  },
  "remote": {
    "origin": "http://192.168.0.14/jerry.yu/devflow.git",
    "backup": "http://192.168.0.14/jerry.yu/devflow-backup.git",
    "github": "git@github.com:jerryyu9981/devflow.git"
  },
  "branchStrategy": "git-flow"
}
```

### 2.2 字段对照（旧 → 新）

| 旧字段 | 新字段 | 变更类型 |
|:-------|:-------|:---------|
| `project.version` (string) | 不变 | 无 |
| `project.lastRelease` | ❌ 无 | **新增** `{ version, date }` |
| `remote.github` | ❌ 无 | **新增** |
| `naming.*` | **删除** | 精简（无人读） |
| `workflow.*` | **删除** | 精简（无人读） |
| `environments.*` | **删除** | 精简（无人读） |
| `backup.*` | **删除** | remote 已有，重复 |
| `migration.*` | **删除** | 一次性迁移记录 |

### 2.3 向后兼容

JSON 解析器会忽略未知字段，旧版读取新结构不会报错。新增字段仅影响新版本的写入方。

---

## 3. 流程规则设计

### 3.1 Step 5 发布复盘追加断言

**位置**：`operations-stage-execution.md` 5.10 发布复盘步骤

**现有内容**：
```
5.10 发布复盘 → 复盘记录
```

**增强后**：
```
5.10 发布复盘 → 复盘记录
    并更新 .devflow/project-config.json 的 lastRelease 字段：
      project.lastRelease.version = 当前发布版本号
      project.lastRelease.date    = 当前日期
```

### 3.2 devflow-init 创建逻辑对齐

初始化创建 `project-config.json` 时，`project.lastRelease` 初始化为空对象（`null`），`remote.github` 从用户交互输入。

### 3.3 devflow-project-config 技能适配

技能文档中的配置模板更新为新结构，去除已精简字段。

### 3.4 devflow-config.json deprecatedFiles

在 `deprecatedFiles` 数组中追加 `"version.json"` 和 `"devflow-manifest.json"`（v2.10.1 已清理）。
