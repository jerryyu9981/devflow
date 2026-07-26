# 项目配置名片方案

> 目的：了解一个项目只需两个文件——`project-config.json`（项目名片）+ `state.json`（运行状态）
> 日期：2026-07-26

---

## 一、两个文件的职责边界

### `.devflow/project-config.json` — 项目名片

记录"这个项目是谁"的**静态或低频变更信息**。任何人打开这个文件就能了解项目的基本面貌。

### `.devflow/state.json` — 运行状态

记录"这个项目当前走到哪了"的**高频动态状态**。每个阶段切换、每次版本检测都会更新。

---

## 二、project-config.json 标准结构

```json
{
  "_meta": {
    "description": "项目级 DevFlow 配置文件。每个项目独立维护，包含项目元数据、远程仓库、发布记录和分支策略。框架配置请参考 devflow-config.json。",
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

### 字段说明

| 字段 | 含义 | 更新时机 | 谁更新 |
|:-----|:------|:---------|:-------|
| `project.name` | 项目名称 | 初始化时 | `devflow-init` |
| `project.version` | 项目当前开发版本号 | 初始化 / 版本规划时 | `devflow-init` / 人工 |
| `project.description` | 一句话概要 | 初始化 / 项目重命名时 | `devflow-init` / 人工 |
| `project.lastRelease.version` | **最后发布的框架版本** | **每次 Step 5 发布完成** | **Step 5 发布复盘** |
| `project.lastRelease.date` | **最后发布时间** | **每次 Step 5 发布完成** | **Step 5 发布复盘** |
| `remote.{origin,backup,github}` | 三个远程仓库地址 | 初始化 / 仓库变更时 | `devflow-init` / `devflow-project-config` |
| `branchStrategy` | 分支策略 | 初始化时 | `devflow-init` |

> **关键新增**：`project.lastRelease` 两个字段，每次发布完成时 Step 5 必须同步更新。

---

## 三、更新触点一览

### 更新方 1：devflow-init（初始化）

| 触发时机 | 写入字段 | 说明 |
|:---------|:---------|:------|
| 项目首次初始化 | `project.name` | 交互输入或取文件夹名 |
| | `project.version` | 读 Git tag 或提示输入 |
| | `project.description` | 提示输入或留空 |
| | `remote.*` | 交互输入三个仓库地址 |
| | `branchStrategy` | 默认 git-flow |
| | `project.lastRelease` | 初始化时为空（未发布过） |

### 更新方 2：Step 5 发布复盘（新增长）

| 触发时机 | 写入字段 | 说明 |
|:---------|:---------|:------|
| **每个版本发布完成** | `project.lastRelease.version` | 设为刚发布版本号（v2.10.1） |
| | `project.lastRelease.date` | 设为发布当天日期 |
| | `_meta.lastUpdated` | 更新为当前日期 |

**具体操作**：release.ps1 或 operations-stage-execution 的发布复盘步骤（5.10）追加一条"更新 project-config.json 的 lastRelease 字段"。

### 更新方 3：devflow-project-config 技能

| 触发时机 | 写入字段 | 说明 |
|:---------|:---------|:------|
| 用户主动修改仓库地址 | `remote.*` | 交互更新 |
| 用户重命名项目 | `project.name` | 交互更新 |

---

## 四、谁读什么

| 读取方 | 读取的字段 | 用途 |
|:-------|:-----------|:-----|
| `update.ps1` / `update.sh` | `remote.origin` | **降级**获取仓库地址（优先取环境变量） |
| `devflow-init` | `remote.origin` | 补全 version.json 的 repository 字段 |
| `devflow-init` | `project.version` | 版本检测优先级链第 1 级 |
| 开发者/人工 | 全部字段 | 了解"这个项目是谁、最新发布了什么、仓库在哪" |

---

## 五、state.json 保持不变

不做合并，保持独立。两个文件加起来就能完整了解一个项目：

```
开 project-config.json → 知道项目名、最新版本、仓库地址
开 state.json         → 知道当前到哪个阶段、审计状态
```

---

## 六、后续执行清单

| 操作 | 位置 | 优先级 |
|:-----|:-----|:------|
| ① 更新 project-config.json 结构 | 实际文件 + `devflow-project-config/SKILL.md` 模板 | 🔴 立即 |
| ② Step 5 发布复盘追加 lastRelease 更新 | `operations-stage-execution.md` 5.10 步 | 🟡 下一版本 |
| ③ `devflow-init` 创建逻辑对齐新结构 | `devflow-init/SKILL.md` | 🟡 下一版本 |
| ④ `devflow-project-config` 技能适配 | `devflow-project-config/SKILL.md` | 🟡 下一版本 |
