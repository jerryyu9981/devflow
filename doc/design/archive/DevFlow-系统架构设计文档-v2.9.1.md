# DevFlow 系统架构设计文档 v2.9.1

> **文档类型**: 系统架构设计文档
> **版本**: v2.9.1
> **项目**: DevFlow
> **日期**: 2026-07-22
> **负责人**: PM-DevFlow-Dev
> **架构变更类型**: 架构精简 + 流程质量增强

---

## 1. 概述

### 1.1 架构定位

DevFlow 是一个**基于技能的开发流程框架**，不是传统软件应用。其"系统"由以下组件构成：

| 组件 | 说明 | 技术形态 |
|------|------|---------|
| 技能文件（Skills） | L1/L2/L3 分层技能定义 | Markdown (.md) + 内联指令 |
| 文档模板（Templates） | 标准化的文档产出模板 | Markdown (.md) |
| 状态管理（State） | 项目当前阶段、版本、审计记录 | JSON (.devflow/state.json) |
| 配置管理（Config） | 项目级配置：远程仓库、命名等 | JSON |
| 全局台账（Ledger） | 技术债务总表、候选需求池 | Markdown (.md) |
| 版本清单 | 版本号、元数据 | JSON (version.json) |
| 安装脚本 | 框架部署与更新 | PowerShell (.ps1) / Shell (.sh) |

DevFlow 的核心设计哲学是**"以技能驱动流程，以文档固化产出，以门禁保障质量"**。技能文件是框架的一等公民，所有流程规则、质量标准、操作指引均以技能文档形式承载，确保流程的可追溯性和可演进性。

### 1.2 v2.9.1 架构变更范围

v2.9.1 是 DevFlow 框架的**架构精简 + 流程质量增强**版本，包含三大需求族：

| 需求编号 | 需求名称 | 变更类别 | 影响范围 | 变更类型 |
|:-------:|---------|:-------:|---------|:--------:|
| V291-001 | JSON 配置文件精简合并 | 配置架构重构 | 6个JSON文件 → 3个核心文件 | 架构级重构 |
| V291-002 | 安装脚本精简 | 脚本架构重构 | 5个脚本 → 2个入口 + 2个内部模块 | 架构级重构 |
| V291-003 | 全阶段产出真实性验证门禁 | 流程质量增强 | 6个阶段技能 + 审计技能 | 规则新增 |

**架构变更总览**：

```text
v2.9.0 架构                     v2.9.1 架构
───────────                    ───────────
配置文件（6个）      →         配置文件（3个）
  version.json                   devflow-config.json（框架级）
  .devflow/config.json           project-config.json（项目级）
  .devflow/state.json            state.json（状态，保留）
  .devflow/version.json
  devflow-manifest.json
  plugin-config/version.json

安装脚本（5个）      →         安装脚本（2入口+2模块）
  install.ps1                    install.ps1（入口）
  setup.ps1                      update.ps1（入口，合并sync-skills）
  update.ps1                     ├── download-devflow.ps1（内部模块）
  sync-skills.ps1                └── validate-install.ps1（内部模块）
  download-devflow.ps1
  validate-install.ps1
```

---

## 2. 分层架构

### 2.1 DevFlow 技能分层架构

DevFlow 采用四层技能分层架构，各层职责清晰、依赖单向：

```text
┌───────────────────────────────────────────────────────────────────┐
│                      L1 Orchestrator（编排层）                      │
│                                                                   │
│  ┌──────────────┐  ┌──────────────────┐  ┌───────────────────┐  │
│  │ devflow-init │  │ devflow-phase-   │  │ devflow-project-  │  │
│  │  (项目初始化) │  │ manager(阶段管理) │  │ config(项目配置)  │  │
│  └──────────────┘  └──────────────────┘  └───────────────────┘  │
│                                                                   │
│  职责：流程入口、状态机管理、配置管理、跨阶段协调                     │
├───────────────────────────────────────────────────────────────────┤
│                    L2 Stage Execution（阶段执行层）                  │
│                                                                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐ │
│  │ Step 0   │ │ Step 1   │ │ Step 2   │ │ Step 3   │ │ Step 4  │ │
│  │ version- │ │require-  │ │design-   │ │coding-   │ │testing- │ │
│  │ planning │ │ments-    │ │stage-    │ │stage-    │ │stage-   │ │
│  │ -stage-  │ │-stage-   │ │execution │ │execution │ │execution│ │
│  │ execution│ │execution │ │          │ │          │ │         │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └─────────┘ │
│  ┌──────────┐                                                     │
│  │ Step 5   │                                                     │
│  │operations│                                                     │
│  │-stage-   │                                                     │
│  │execution │                                                     │
│  └──────────┘                                                     │
│                                                                   │
│  职责：各阶段流程执行、产出物生成、门禁检查                           │
├───────────────────────────────────────────────────────────────────┤
│                  L3 Specialty Reference（专项技能层）                │
│                                                                   │
│  质量保障类    工程规范类     基础设施类     文档模板类               │
│  ─────────    ─────────     ─────────     ─────────               │
│  code-logic-  project-      cicd-pipeline- project-document-      │
│  review       coding-       management    templates               │
│  code-static- conventions   container-    skill-md-writing-       │
│  quality-check              deployment    standards               │
│  prototype-   secure-       observability-                       │
│  coverage     coding-       standards                             │
│  backend-     practices     security-                            │
│  coverage                   design-review                         │
│               code-version-                                     │
│               backup-                                           │
│               management                                        │
│               api-contract-                                      │
│               management                                          │
│                                                                   │
│  职责：专业领域知识沉淀、最佳实践指导、专项检查规范                    │
├───────────────────────────────────────────────────────────────────┤
│                共享基础设施层（Shared Infrastructure）              │
│                                                                   │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────────────┐ │
│  │ 配置文件体系 │  │ 文档产出体系  │  │ 脚本工具体系              │ │
│  │ devflow-    │  │ doc/         │  │ install.ps1 / update.ps1 │ │
│  │ config.json │  │  ├ requirements/ │ │ download-devflow.ps1   │ │
│  │ project-    │  │  ├ design/       │ │ validate-install.ps1  │ │
│  │ config.json │  │  ├ development/  │ └──────────────────────────┘ │
│  │ state.json  │  │  ├ test/         │                              │
│  └─────────────┘  │  ├ operations/   │  ┌──────────────────────┐ │
│                    │  └ audit/        │  │ 模板与台账            │ │
│  ┌─────────────┐  └──────────────────┘  │ templates/           │ │
│  │ version.json│                        │ 技术债务总表          │ │
│  │ CHANGELOG.md│                        │ 候选需求池            │ │
│  └─────────────┘                        └──────────────────────┘ │
└───────────────────────────────────────────────────────────────────┘
```

**分层依赖原则**：
- L1 → L2 → L3：自上而下调用，上层依赖下层
- L1/L2/L3 → 共享基础设施层：所有技能层均可访问共享基础设施
- 禁止反向依赖：L3 不依赖 L2，L2 不依赖 L1
- 同层解耦：L2 各阶段技能之间通过 state.json 传递状态，不直接调用

### 2.2 v2.9.1 修改的技能文件矩阵

| 技能文件 | 层级 | 路径 | 修改类型 | 对应需求 | 修改幅度 |
|---------|:----:|------|:--------:|:-------:|:--------:|
| devflow-init / SKILL.md | L1 | .devflow/devflow-init/ | 重构：配置文件读取逻辑 + 迁移触发 | V291-001, F-03 | 中 |
| devflow-project-config / SKILL.md | L1 | .devflow/devflow-project-config/ | 重构：读写目标变更 + 字段映射 | V291-001 | 大 |
| devflow-phase-manager / SKILL.md | L1 | .devflow/devflow-phase-manager/ | 增量：新增产出验证门禁调用 | V291-003 | 中 |
| version-planning-stage-execution.md | L2 | skills/L2/ | 增量：新增 Step 0 产出验证点 | V291-003, F-07 | 中 |
| requirements-stage-execution.md | L2 | skills/L2/ | 增量：新增 Step 1 产出验证点 | V291-003, F-07 | 中 |
| design-stage-execution.md | L2 | skills/L2/ | 增量：新增 Step 2 产出验证点 | V291-003, F-07 | 中 |
| coding-stage-execution.md | L2 | skills/L2/ | 增量：新增 Step 3 产出验证点 | V291-003, F-07 | 中 |
| testing-stage-execution.md | L2 | skills/L2/ | 增量：新增 Step 4 产出验证点 | V291-003, F-07 | 中 |
| operations-stage-execution.md | L2 | skills/L2/ | 增量：新增 Step 5 全阶段盘点 | V291-003, F-08, F-09 | 大 |
| project-document-management.md | L3 | skills/L3/ | 修改：文档路径引用更新 | V291-001, F-06 | 小 |
| code-version-backup-management.md | L3 | skills/L3/ | 修改：备份配置字段引用更新 | V291-001 | 小 |
| install.ps1 | 脚本 | 根目录 | 重构：精简流程 + 调用内部模块 | V291-002, F-04 | 大 |
| update.ps1 | 脚本 | 根目录 | 重构：合并 sync-skills 功能 | V291-002, F-05 | 大 |
| download-devflow.ps1 | 脚本 | .devflow/scripts/ | 保留：内部模块定位 | V291-002 | 小 |
| validate-install.ps1 | 脚本 | .devflow/scripts/ | 保留：内部模块定位 | V291-002 | 小 |

---

## 3. 配置架构重构设计（对应 V291-001）

### 3.1 新配置文件体系

v2.9.1 将原有的 6 个 JSON 配置/元数据文件精简为 **3 个核心文件**，遵循单一职责和 Source of Truth 原则。

#### 3.1.1 文件体系总览

| 文件 | 位置 | 职责 | Source of Truth | 生命周期 |
|------|------|------|:---------------:|---------|
| `devflow-config.json` | 项目根目录 | 框架级元数据 + 技能清单 | 是（框架版本唯一真相源） | 框架安装/更新时写入，运行时只读 |
| `project-config.json` | `.devflow/` 目录 | 项目级配置：元数据、远程仓库、命名规范 | 是（项目配置唯一真相源） | 项目初始化时创建，可手动/自动更新 |
| `state.json` | `.devflow/` 目录 | 运行时状态：当前阶段、版本、审计记录 | 是（状态唯一真相源） | 各阶段流转时更新 |

#### 3.1.2 精简映射表

| v2.9.0 文件 | v2.9.1 归宿 | 处置方式 |
|:-----------:|:-----------:|:--------:|
| `version.json`（根目录） | `devflow-config.json` | 合并 + 迁移 |
| `.devflow/version.json` | `devflow-config.json` | 合并 + 迁移（删除重复） |
| `devflow-plugin/version.json` | `devflow-config.json` | 合并 + 迁移 |
| `.trae/skills/devflow-plugin-config/version.json` | `devflow-config.json` | 合并 + 迁移 |
| `devflow-plugin/devflow-manifest.json` | `devflow-config.json` | 合并 + 迁移 |
| `.devflow/config.json` | `project-config.json` | 重命名 + 字段重组 |
| `.devflow/state.json` | `state.json` | 保留，位置不变 |

### 3.2 devflow-config.json 字段设计

**文件位置**：`{project_root}/devflow-config.json`

**设计原则**：
- 框架级只读配置，项目运行时不修改
- 作为 DevFlow 框架版本和技能清单的唯一真相源
- IDE/编辑器插件副本用于离线场景同步

```json
{
  "schemaVersion": "1.0",
  "devflowVersion": "2.9.1",
  "metadata": {
    "name": "DevFlow",
    "description": "基于技能的软件开发流程框架",
    "releaseDate": "2026-07-22",
    "repository": {
      "type": "git",
      "url": "https://github.com/example/devflow.git"
    },
    "homepage": "https://devflow.example.com",
    "license": "MIT"
  },
  "skills": {
    "L1": [
      { "id": "devflow-init", "name": "项目初始化技能", "version": "2.9.1" },
      { "id": "devflow-phase-manager", "name": "阶段管理技能", "version": "2.9.1" },
      { "id": "devflow-project-config", "name": "项目配置技能", "version": "2.9.1" }
    ],
    "L2": [
      { "id": "version-planning-stage-execution", "name": "版本规划阶段执行", "version": "2.9.1" },
      { "id": "requirements-stage-execution", "name": "需求阶段执行", "version": "2.9.1" },
      { "id": "design-stage-execution", "name": "设计阶段执行", "version": "2.9.1" },
      { "id": "coding-stage-execution", "name": "编码阶段执行", "version": "2.9.1" },
      { "id": "testing-stage-execution", "name": "测试阶段执行", "version": "2.9.1" },
      { "id": "operations-stage-execution", "name": "运维阶段执行", "version": "2.9.1" }
    ],
    "L3": [
      { "id": "project-document-templates", "name": "项目文档模板", "version": "2.9.1" },
      { "id": "project-coding-conventions", "name": "项目编码规范", "version": "2.9.1" },
      { "id": "code-logic-review", "name": "代码逻辑审查", "version": "2.9.1" },
      { "id": "code-static-quality-check", "name": "代码静态质量检查", "version": "2.9.1" },
      { "id": "code-version-backup-management", "name": "代码版本备份管理", "version": "2.9.1" },
      { "id": "api-contract-management", "name": "API契约管理", "version": "2.9.1" },
      { "id": "prototype-coverage", "name": "原型覆盖率检查", "version": "2.9.1" },
      { "id": "backend-coverage", "name": "后端设计覆盖率检查", "version": "2.9.1" },
      { "id": "secure-coding-practices", "name": "安全编码实践", "version": "2.9.1" },
      { "id": "security-design-review", "name": "安全设计评审", "version": "2.9.1" },
      { "id": "observability-standards", "name": "可观测性标准", "version": "2.9.1" },
      { "id": "cicd-pipeline-management", "name": "CI/CD流水线管理", "version": "2.9.1" },
      { "id": "container-deployment", "name": "容器化部署", "version": "2.9.1" },
      { "id": "skill-md-writing-standards", "name": "技能文档编写规范", "version": "2.9.1" }
    ]
  },
  "framework": {
    "minTrAIVersion": "3.0.0",
    "supportedPlatforms": ["windows", "macos", "linux"],
    "configSchemaVersion": "1.0"
  }
}
```

**字段说明**：

| 字段 | 类型 | 必填 | 说明 |
|------|:----:|:----:|------|
| `schemaVersion` | string | 是 | 配置文件 Schema 版本，用于未来结构演进 |
| `devflowVersion` | string | 是 | DevFlow 框架语义化版本号，唯一真相源 |
| `metadata` | object | 是 | 框架元数据：名称、描述、发布日期、仓库地址等 |
| `skills.L1/L2/L3` | array | 是 | 各层级技能清单，含 id、name、version |
| `framework` | object | 是 | 框架运行要求：最低 IDE 版本、支持平台等 |

### 3.3 project-config.json 字段设计

**文件位置**：`{project_root}/.devflow/project-config.json`

**设计原则**：
- 项目级可写配置，每个项目独立维护
- 替代原 `.devflow/config.json`
- 作为项目元数据、远程仓库、命名规范的唯一真相源

```json
{
  "schemaVersion": "1.0",
  "project": {
    "name": "my-project",
    "code": "MP",
    "description": "项目描述",
    "version": "1.0.0",
    "owner": "PM-Project-Dev",
    "createdDate": "2026-01-01"
  },
  "remote": {
    "origin": "https://github.com/example/my-project.git",
    "defaultBranch": "main",
    "provider": "github"
  },
  "naming": {
    "projectPrefix": "MP",
    "docVersionFormat": "v{major}.{minor}.{patch}",
    "docNamePattern": "{ProjectName}-{DocType}-{DocSubject}-v{version}.{ext}",
    "branchNamePattern": "feature/{ticket-id}-{description}",
    "commitMessagePattern": "{type}({scope}): {description}"
  },
  "workflow": {
    "devflowVersion": "2.9.1",
    "startingStep": 0,
    "autoAdvance": false,
    "qualityGates": {
      "testCoverageThreshold": 80,
      "enableVerificationGate": true
    }
  },
  "environments": {
    "dev": { "name": "开发环境", "url": "" },
    "test": { "name": "测试环境", "url": "" },
    "staging": { "name": "预发布环境", "url": "" },
    "prod": { "name": "生产环境", "url": "" }
  }
}
```

**字段说明**：

| 字段 | 类型 | 必填 | 来源（v2.9.0） | 说明 |
|------|:----:|:----:|:-------------:|------|
| `schemaVersion` | string | 是 | 新增 | 配置 Schema 版本 |
| `project` | object | 是 | config.json + version.json | 项目元数据：名称、代号、版本、负责人 |
| `remote` | object | 是 | config.json.remote | 远程仓库配置 |
| `naming` | object | 是 | config.json.naming | 命名规范配置 |
| `workflow` | object | 是 | config.json.workflow | 工作流配置 |
| `environments` | object | 否 | config.json.environments | 环境配置 |

### 3.4 IDE 副本机制

为支持 IDE 插件在无项目上下文时读取框架信息，v2.9.1 引入 IDE 全局副本机制：

| 副本文件 | 位置 | 用途 | 同步时机 |
|---------|------|------|---------|
| `devflow-config.json`（IDE 副本） | `~/.trae-cn/skills/devflow-plugin-config/devflow-config.json` | IDE 全局框架信息、技能索引 | install / update 时同步写入 |

**同步规则**：
1. `install.ps1` 执行成功后，将 `devflow-config.json` 复制到 IDE 全局目录
2. `update.ps1` 执行成功后，更新 IDE 全局目录副本
3. 项目内 `devflow-config.json` 为项目级真相源，IDE 副本为全局缓存
4. 若项目级版本 > IDE 副本版本，以项目级为准并触发 IDE 副本更新

### 3.5 Source of Truth 原则

配置架构重构严格遵循 **Source of Truth（单一真相源）** 原则：

```text
                    ┌──────────────────────┐
                    │   devflow-config.json│
                    │   (框架级配置)        │
                    │   项目根目录          │
                    └──────────┬───────────┘
                               │ 唯一真相源
             ┌─────────────────┼─────────────────┐
             ▼                 ▼                 ▼
    IDE 全局副本         state.json      各技能文件引用
    (只读缓存)         (状态管理)        (只读引用)
```

| 数据类别 | 真相源 | 引用方 | 更新时机 |
|---------|:------:|--------|---------|
| 框架版本号 | `devflow-config.json` | state.json、IDE 副本、技能文档 | 框架更新时 |
| 项目元数据 | `project-config.json` | 文档生成器、命名检查工具 | 项目配置变更时 |
| 运行时状态 | `state.json` | phase-manager、各阶段技能 | 阶段流转时 |
| 远程仓库配置 | `project-config.json` | backup-management、release 脚本 | 手动修改 / init 时 |
| 命名规范 | `project-config.json` | document-management、commit 检查 | 手动修改时 |

---

## 4. 向后兼容迁移机制设计（对应 V291-001）

### 4.1 迁移触发条件

迁移机制在 **devflow-init** 技能中实现，每次项目初始化时自动检测并执行。

**触发条件矩阵**：

| 场景 | 检测条件 | 动作 |
|------|:--------:|:----:|
| 全新项目 | 无任何旧配置文件 | 直接创建新配置体系 |
| v2.9.0 项目升级 | 存在 `.devflow/config.json` 且无 `project-config.json` | 执行自动迁移 |
| 混合状态 | 新旧文件同时存在 | 以新文件为准，输出警告 |
| 损坏状态 | 旧文件存在但格式错误 | 尝试修复 + 手动确认 |

**检测流程**：

```text
devflow-init 启动
  ↓
[1] 检查 devflow-config.json 是否存在
  ├── 存在 → 检查 schemaVersion → 一致 → 跳过迁移
  └── 不存在 → 进入迁移检测
      ↓
[2] 检查旧配置文件（.devflow/config.json / version.json 等）
  ├── 存在 → 执行迁移流程
  └── 不存在 → 全新初始化，创建默认配置
```

### 4.2 迁移流程

**自动迁移五步法**：

```text
┌─────────────────────────────────────────────────────────────┐
│                     自动迁移流程                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Step 1: 备份保护                                            │
│  ─────────────                                               │
│  创建 .devflow/backup/before-v291-migration/ 目录            │
│  复制所有旧配置文件到备份目录                                  │
│                                                             │
│  Step 2: 数据收集                                            │
│  ─────────────                                               │
│  读取所有旧配置文件                                          │
│  解析并提取各字段值                                          │
│  处理冲突（多文件同字段时优先级规则）                          │
│                                                             │
│  Step 3: 生成新配置                                          │
│  ─────────────                                               │
│  生成 devflow-config.json（根目录）                          │
│  生成 project-config.json（.devflow/）                       │
│  保留 state.json（位置不变，字段兼容）                        │
│                                                             │
│  Step 4: 写入与验证                                          │
│  ─────────────                                               │
│  写入新文件到临时路径                                         │
│  JSON Schema 校验                                            │
│  原子性替换（重命名临时文件）                                  │
│                                                             │
│  Step 5: 旧文件归档                                          │
│  ─────────────                                               │
│  将旧文件移动到 .devflow/backup/legacy-configs/              │
│  记录迁移日志到 state.json                                   │
│  输出迁移结果摘要                                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**字段映射优先级规则**（当多个旧文件存在相同语义字段时）：

| 字段 | 优先级（高→低） | 说明 |
|------|:---------------:|------|
| 项目名称 | .devflow/config.json > version.json | 项目配置优先 |
| 项目版本 | .devflow/config.json > version.json | 项目配置优先 |
| 仓库地址 | .devflow/config.json > version.json | 项目配置优先 |
| 框架版本 | version.json(根) > devflow-manifest.json | 根目录优先 |

### 4.3 迁移失败保护

**失败回滚机制**：

```text
迁移失败检测点：
  ├── 备份失败 → 终止迁移，输出错误，不改动任何文件
  ├── 旧文件解析失败 → 回滚到备份状态，输出解析错误详情
  ├── 新文件 Schema 校验失败 → 回滚，输出校验错误
  ├── 写入失败 → 回滚，输出 IO 错误
  └── 迁移后自检失败 → 自动回滚 + 输出详细错误报告
```

**保护措施**：

| 保护层级 | 措施 | 触发条件 |
|:-------:|------|---------|
| L1 备份保护 | 迁移前全量备份所有旧配置 | 迁移开始前自动执行 |
| L2 原子写入 | 新文件先写临时文件，校验通过后原子替换 | 所有写入操作 |
| L3 回滚机制 | 迁移失败自动从备份恢复 | 任意步骤失败 |
| L4 手动确认 | 迁移涉及破坏性操作时要求用户确认 | 检测到字段冲突无法自动解决 |
| L5 迁移日志 | 完整记录迁移过程到 state.json.migrationLog | 每次迁移 |

### 4.4 新旧文件共存策略

**共存周期**：v2.9.1 - v2.10.0（至少一个版本周期）

**共存期间行为**：

| 场景 | 行为 |
|------|------|
| 新文件存在，旧文件也存在 | 以新文件为准，输出 warning 提示旧文件将被废弃 |
| 仅旧文件存在 | 触发自动迁移 |
| 仅新文件存在 | 正常运行，无迁移 |
| 新旧文件字段不一致 | 以新文件为准，输出不一致警告 |

**废弃计划**：

| 版本 | 动作 |
|:----:|------|
| v2.9.1 | 引入新配置体系，自动迁移，旧文件归档保留 |
| v2.9.x | 持续支持共存，迁移逻辑保留 |
| v2.10.0 | 移除旧文件读取代码，仅保留迁移提示 |
| v2.11.0 | 完全移除迁移逻辑 |

---

## 5. 脚本架构重构设计（对应 V291-002）

### 5.1 新脚本架构

v2.9.1 将原有的 5 个用户可见脚本精简为 **2 个入口脚本 + 2 个内部模块 + 1 个强制验证门禁**，明确职责边界。

#### 5.1.1 脚本体系总览

```text
┌─────────────────────────────────────────────────────────┐
│                    用户入口脚本（2个）                     │
│                                                         │
│  ┌──────────────┐         ┌──────────────┐              │
│  │ install.ps1  │         │ update.ps1   │              │
│  │ 全新安装      │         │ 版本更新      │              │
│  │ (首次部署)    │         │ (增量升级)    │              │
│  └──────┬───────┘         └──────┬───────┘              │
└─────────┼────────────────────────┼──────────────────────┘
          │                        │
          ▼                        ▼
┌─────────────────────────────────────────────────────────┐
│                   内部模块脚本（2个）                      │
│                                                         │
│  ┌──────────────────────┐  ┌──────────────────────┐    │
│  │ download-devflow.ps1 │  │   setup.ps1          │    │
│  │ 下载 DevFlow 框架包  │  │ 技能部署与IDE集成    │    │
│  │ (内部工具模块)        │  │ (内部工具模块)        │    │
│  └──────────────────────┘  └──────────────────────┘    │
└─────────────────────────────────────────────────────────┘
          │                        │
          ▼                        ▼
┌─────────────────────────────────────────────────────────┐
│              强制验证门禁（1个）—— 必走流程                  │
│                                                         │
│            ┌──────────────────────────┐                 │
│            │   validate-install.ps1   │                 │
│            │   安装/更新有效性验证     │                 │
│            │   (强制门禁，不通过则失败)│                 │
│            └──────────────────────────┘                 │
└─────────────────────────────────────────────────────────┘
```

#### 5.1.2 精简映射表

| v2.9.0 脚本 | v2.9.1 归宿 | 处置方式 | 性质 |
|:-----------:|:-----------:|:--------:|:----:|
| `install.ps1` | `install.ps1` | 重构精简，保留入口 | 用户入口 |
| `setup.ps1` | `.devflow/scripts/setup.ps1` | 内部模块，位置调整 | 内部模块 |
| `update.ps1` | `update.ps1` | 重构增强，合并 sync-skills | 用户入口 |
| `sync-skills.ps1` | `update.ps1` | 功能合并，删除文件 | （合并） |
| `download-devflow.ps1` | `.devflow/scripts/download-devflow.ps1` | 内部模块，位置调整 | 内部模块 |
| `validate-install.ps1` | `.devflow/scripts/validate-install.ps1` | **升级为强制验证门禁**，检查内容同步更新 | 强制门禁 |

### 5.2 install.ps1 流程设计

**定位**：全新项目 DevFlow 框架安装入口

**调用场景**：用户首次在项目中使用 DevFlow 时执行

```text
install.ps1 主流程
==================

[参数]
  -ProjectPath    项目路径（默认当前目录）
  -Version        指定版本（默认 latest）
  -Force          强制覆盖已存在的安装

[流程]
  ↓
┌─ Step 1: 环境检测 ───────────────────────────────────┐
│  1.1 检测 PowerShell 版本 >= 5.1                      │
│  1.2 检测操作系统平台                                 │
│  1.3 检测 Git 是否可用                                │
│  1.4 检测 TRAE IDE 环境是否存在                       │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 2: 前置检查 ───────────────────────────────────┐
│  2.1 检查项目路径是否存在                             │
│  2.2 检查是否已有 DevFlow 安装                        │
│      ├── 已有安装且非 -Force → 提示后退出             │
│      └── 无安装 / -Force → 继续                      │
│  2.3 检查磁盘空间（>= 50MB）                          │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 3: 下载框架 ───────────────────────────────────┐
│  3.1 调用 download-devflow.ps1 -Version $Version     │
│  3.2 下载到临时目录                                   │
│  3.3 校验文件完整性（SHA256）                        │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 4: 部署文件 ───────────────────────────────────┐
│  4.1 创建 .devflow/ 目录结构                          │
│  4.2 部署技能文件到 .devflow/skills/                  │
│  4.3 部署模板文件到 .devflow/templates/               │
│  4.4 部署脚本到 .devflow/scripts/                     │
│  4.5 创建 devflow-config.json（项目根目录）           │
│  4.6 创建 project-config.json（默认模板）             │
│  4.7 初始化 state.json                                │
│  4.8 部署文档到 doc/ 目录                             │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 5: IDE 集成 ───────────────────────────────────┐
│  5.1 调用 setup.ps1 执行技能部署与IDE集成             │
│  5.2 复制 devflow-config.json 到 IDE 全局目录         │
│  5.3 注册技能到 TRAE 技能系统                         │
│  5.4 配置 IDE 插件参数                                │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 6: 安装验证【强制门禁】─────────────────────────┐
│  6.1 调用 validate-install.ps1 -Mode install         │
│  6.2 验证所有必需文件存在（11 项检查）                │
│  6.3 验证 JSON 配置格式正确                          │
│  6.4 验证技能文件完整性                               │
│  6.5 验证脚本文件完整性                               │
│      ├── 验证通过 → 继续 Step 7                       │
│      └── 验证失败 → 回滚 + 输出错误 + 退出码 1        │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 7: 收尾输出 ───────────────────────────────────┐
│  7.1 清理临时文件                                     │
│  7.2 输出安装成功摘要                                 │
│  7.3 输出下一步操作指引                               │
└───────────────────────────────────────────────────────┘
```

### 5.3 update.ps1 流程设计

**定位**：DevFlow 框架版本更新入口（合并原 sync-skills 功能）

**调用场景**：已有 DevFlow 安装的项目升级框架版本

```text
update.ps1 主流程
=================

[参数]
  -ProjectPath    项目路径（默认当前目录）
  -TargetVersion  目标版本（默认 latest）
  -DryRun         预览模式，仅显示变更
  -SkipBackup     跳过备份

[流程]
  ↓
┌─ Step 1: 当前状态检测 ───────────────────────────────┐
│  1.1 读取 devflow-config.json 获取当前版本           │
│  1.2 检查是否有未完成的迁移                           │
│  1.3 检查工作区是否干净（Git 检测）                   │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 2: 版本信息获取 ───────────────────────────────┐
│  2.1 查询可用版本列表                                │
│  2.2 解析目标版本号                                  │
│  2.3 计算版本差异（新增/修改/删除的技能）             │
│  2.4 若 -DryRun → 输出差异后退出                      │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 3: 备份保护 ───────────────────────────────────┐
│  3.1 若非 -SkipBackup → 备份当前 .devflow/ 目录      │
│  3.2 备份 devflow-config.json                        │
│  3.3 备份版本号写入备份目录名                         │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 4: 下载新版本 ─────────────────────────────────┐
│  4.1 调用 download-devflow.ps1 -Version $TargetVersion│
│  4.2 下载到临时目录                                   │
│  4.3 校验文件完整性                                   │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 5: 技能同步（原 sync-skills.ps1 功能）─────────┐
│  5.1 对比新旧版本技能清单                             │
│  5.2 新增技能 → 复制到 .devflow/skills/              │
│  5.3 修改技能 → 备份旧版本 + 替换新文件               │
│  5.4 删除技能 → 移至 .devflow/backup/skills/         │
│  5.5 更新模板文件                                    │
│  5.6 更新内部脚本                                    │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 6: 配置迁移 ───────────────────────────────────┐
│  6.1 检查配置 Schema 版本                            │
│  6.2 如需迁移 → 执行配置迁移流程                      │
│  6.3 更新 devflow-config.json                        │
│  6.4 更新 state.json 中的 devflowVersion             │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 7: IDE 同步 ───────────────────────────────────┐
│  7.1 更新 IDE 全局目录 devflow-config.json           │
│  7.2 刷新 TRAE 技能注册                               │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 8: 更新验证【强制门禁】─────────────────────────┐
│  8.1 调用 validate-install.ps1 -Mode update          │
│  8.2 验证版本号一致性（13 项检查）                    │
│  8.3 验证技能文件完整性                               │
│  8.4 验证配置文件格式                                 │
│  8.5 验证脚本文件完整性 + 迁移结果                     │
│      ├── 验证通过 → 继续 Step 9                       │
│      └── 验证失败 → 自动回滚 + 输出错误 + 退出码 1    │
└───────────────────────────────────────────────────────┘
  ↓
┌─ Step 9: 收尾输出 ───────────────────────────────────┐
│  9.1 清理临时文件                                     │
│  9.2 输出更新成功摘要                                 │
│  9.3 输出版本变更说明（CHANGELOG）                    │
└───────────────────────────────────────────────────────┘
```

### 5.4 内部模块设计

#### 5.4.1 download-devflow.ps1

**定位**：DevFlow 框架包下载内部工具模块

**位置**：`.devflow/scripts/download-devflow.ps1`

**功能**：
- 根据版本号下载 DevFlow 框架包
- 支持 latest / 指定版本 / 预发布版本
- 下载完成后自动校验 SHA256
- **下载完成后自动执行 package 模式验证（强制门禁）**
- 返回下载文件路径和版本信息

**下载流程**：

```text
Step 1: 解析版本号（latest → 实际版本）
    ↓
Step 2: 检查本地缓存（已下载则复用）
    ↓
Step 3: 下载框架包（official / mirror / local）
    ↓
Step 4: SHA256 校验
    ↓
Step 5: 解压到临时目录
    ↓
Step 6: package 模式验证【强制门禁】
    ├── 调用 validate-install.ps1 -Mode package
    ├── 验证通过 → 返回成功
    └── 验证失败 → 删除下载包 + 报错 + exit 1
```

**接口**：

```powershell
# 参数
param(
  [string]$Version = "latest",      # 目标版本
  [string]$OutputPath,              # 输出目录
  [string]$Source = "official",     # 下载源：official / mirror / local
  [switch]$Force,                   # 强制重新下载
  [switch]$SkipValidation           # 跳过验证（不推荐，仅调试用）
)

# 返回值（对象）
# @{
#   Success = $true/$false
#   Version = "2.9.1"
#   PackagePath = "C:\temp\devflow-2.9.1"
#   Sha256 = "..."
#   ValidationPassed = $true/$false
#   ErrorMessage = "..."
# }
```

#### 5.4.2 setup.ps1（内部模块）

**定位**：DevFlow 技能部署与 IDE 集成内部工具模块

**位置**：`.devflow/scripts/setup.ps1`

**功能**：
- 技能文件安装到 IDE 系统目录
- BOM 清理（DT-03）
- IDE 技能注册与配置
- Git Hook 安装（可选）

**接口**：

```powershell
# 参数
param(
  [string]$PluginSourceDir,       # 插件源目录
  [string]$TargetSkillsDir,       # 目标技能目录
  [switch]$InstallHook,            # 是否安装 Git Hook
  [switch]$Silent                  # 静默模式（跳过交互确认）
)

# 返回值（对象）
# @{
#   Success = $true/$false
#   InstalledCount = 30
#   FailedCount = 0
#   BomFixedCount = 5
# }
```

#### 5.4.3 validate-install.ps1（强制验证门禁，多模式）

**定位**：DevFlow 全流程有效性验证——**多场景强制门禁，不通过则失败回滚**

**位置**：`.devflow/scripts/validate-install.ps1`

**性质**：覆盖 download → install → update → init 全流程的验证工具，每个阶段完成后必须通过对应模式的验证才算成功。

---

##### 5.4.3.1 五模式验证体系

validate-install.ps1 支持 5 种验证模式，分别对应不同的生命周期阶段：

| 模式 | 触发时机 | 验证对象 | 检查项数 | 失败处置 |
|:----:|---------|---------|:-------:|---------|
| `package` | download-devflow.ps1 下载后 | 下载包目录 | 8 项 | 删除下载包 + exit 1 |
| `install` | install.ps1 安装后 | IDE 系统目录 + 项目根目录 | 11 项 | 回滚安装 + exit 1 |
| `update` | update.ps1 更新后 | IDE 系统目录 + 项目根目录 | 13 项 | 自动从备份恢复 + exit 1 |
| `init` | devflow-init 初始化后 | 项目 .devflow/ 目录 | 6 项 | 清理已创建文件 + exit 1 |
| `full` | 手动调用 / Step 5 盘点 | 全部 | 16 项 | 报告结果，不自动回滚 |

**模式间关系**：

```text
package（下载包完整性）
    ↓
install（安装完整性）—— 包含 package 全部检查 + 安装结果验证
    ↓
update（更新完整性）—— 包含 install 全部检查 + 迁移/版本一致性验证
    ↓
init（项目初始化完整性）—— 独立子集，验证项目配置
    ↓
full（全量验证）—— 包含所有模式全部检查
```

---

##### 5.4.3.2 各模式检查项详解

**检查项总表（16 项）**：

| # | 检查大类 | 检查项 | package | install | update | init | full |
|:-:|:-------|:-------|:-------:|:-------:|:------:|:----:|:----:|
| 1 | 配置文件存在性 | devflow-config.json 存在 | ✅ | ✅ | ✅ | — | ✅ |
| 2 | 配置文件存在性 | project-config.json 存在 | — | ⚠️ | ⚠️ | ✅ | ✅ |
| 3 | 配置文件存在性 | state.json 存在 | — | — | ⚠️ | ✅ | ✅ |
| 4 | 配置文件语法 | JSON 语法校验（所有存在的配置文件） | ✅ | ✅ | ✅ | ✅ | ✅ |
| 5 | 配置文件 Schema | 关键字段完整性检查 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 6 | 技能文件完整性 | 所有技能 SKILL.md 存在 | ✅ | ✅ | ✅ | — | ✅ |
| 7 | 技能文件完整性 | 技能数量与清单匹配 | ✅ | ✅ | ✅ | — | ✅ |
| 8 | 技能间引用关系 | 简化版引用检查 | — | ✅ | ✅ | — | ✅ |
| 9 | 模板文件可用性 | templates/ 目录存在且文件匹配 | ✅ | ✅ | ✅ | — | ✅ |
| 10 | 编排器加载检查 | L1 编排器格式完整 | — | ✅ | ✅ | — | ✅ |
| 11 | 脚本文件完整性 | install.ps1 存在 | ✅ | ✅ | ✅ | — | ✅ |
| 12 | 脚本文件完整性 | update.ps1 存在 | ✅ | ✅ | ✅ | — | ✅ |
| 13 | 脚本文件完整性 | 内部脚本存在（download/setup/validate） | ✅ | ✅ | ✅ | — | ✅ |
| 14 | BOM 检查 | 所有 .md/.json 文件无 UTF-8 BOM | ✅ | ✅ | ✅ | ✅ | ✅ |
| 15 | 版本一致性 | 各文件中的版本号一致 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 16 | 迁移验证 | 旧配置文件已正确迁移（旧文件不存在/已备份） | — | — | ✅ | — | ✅ |

> 说明：⚠️ = 仅当文件存在时检查（不强制要求存在，但存在则必须正确）；— = 不检查

---

##### 5.4.3.3 各模式详细说明

###### 模式一：package（下载包完整性验证）

**触发**：download-devflow.ps1 的 Clone / Update 模式完成后

**验证对象**：下载到本地的 DevFlow 代码包目录

**检查目的**：确保下载的代码包完整、可用，避免"下载了残缺代码还继续安装"

**检查项（8项）**：

| # | 检查项 | 通过标准 |
|:-:|:-------|:---------|
| 1 | devflow-config.json 存在且语法正确 | 文件存在，JSON 可解析 |
| 2 | devflow-manifest.json 存在且语法正确 | 文件存在，JSON 可解析（过渡期保留） |
| 3 | 技能源文件完整性 | 按 manifest 清单逐一检查源文件存在 |
| 4 | 脚本文件存在 | install.ps1 / update.ps1 / setup.ps1 / validate-install.ps1 都存在 |
| 5 | 模板文件存在 | templates/ 目录及关键模板文件存在 |
| 6 | BOM 检查 | 所有 .md / .json 文件无 UTF-8 BOM |
| 7 | 版本号一致性 | devflow-config.json 与 version.json 版本号匹配 |
| 8 | 关键字段校验 | devflowVersion / skills / name 等关键字段非空 |

**失败处置**：
- Clone 模式 → 删除下载的临时目录 + 报错 + exit 1
- Update 模式 → 提示更新包损坏，建议重新拉取 + exit 1

---

###### 模式二：install（安装完整性验证）

**触发**：install.ps1 安装完成后

**验证对象**：IDE 系统目录（已安装的技能） + 项目根目录（配置文件）

**检查目的**：确保 DevFlow 已正确安装到 IDE，配置文件就位

**检查项（11项）**：package 全部 8 项 + 以下 3 项

| # | 检查项 | 通过标准 |
|:-:|:-------|:---------|
| 9 | 技能间引用关系 | 技能文档中引用的其他技能都已安装 |
| 10 | 编排器加载检查 | L1 编排器（devflow-init / phase-manager / project-config）格式完整 |
| 11 | project-config.json 存在性校验 | 若文件已存在则语法必须正确（不强制要求存在，因为项目可能还未初始化） |

**失败处置**：
- 回滚安装（删除已部署到 IDE 系统目录的技能文件）
- 清理项目根目录已创建的配置文件
- 输出错误详情 + exit 1

---

###### 模式三：update（更新完整性验证）

**触发**：update.ps1 更新完成后

**验证对象**：IDE 系统目录 + 项目根目录 + 迁移结果

**检查目的**：确保版本更新成功，旧配置正确迁移，版本号一致

**检查项（13项）**：install 全部 11 项 + 以下 2 项

| # | 检查项 | 通过标准 |
|:-:|:-------|:---------|
| 12 | state.json 存在性校验 | 若文件已存在则语法必须正确且版本号匹配 |
| 13 | 迁移验证 | 旧配置文件（version.json / config.json / devflow-manifest.json）已正确处理（已迁移并备份，或不存在） |

**失败处置**：
- 自动从更新前的备份恢复
- 输出回滚日志 + 错误详情 + exit 1

---

###### 模式四：init（项目初始化验证）

**触发**：devflow-init 初始化完成后

**验证对象**：项目 `.devflow/` 目录下的配置文件

**检查目的**：确保项目初始化配置正确，版本同步，状态一致

**检查项（6项）**：

| # | 检查项 | 通过标准 |
|:-:|:-------|:---------|
| 1 | project-config.json 存在且语法正确 | 文件存在，JSON 可解析 |
| 2 | state.json 存在且语法正确 | 文件存在，JSON 可解析 |
| 3 | 配置文件 Schema | project.name / devflowVersion 等关键字段非空 |
| 4 | BOM 检查 | 配置文件无 UTF-8 BOM |
| 5 | 版本一致性 | state.json 中的 devflowVersion 与 IDE 系统目录版本一致 |
| 6 | 目录结构 | .devflow/ 目录结构完整（logs / backups / templates） |

**失败处置**：
- 清理已创建的 .devflow/ 目录
- 输出错误详情 + exit 1

---

###### 模式五：full（全量验证）

**触发**：手动调用 / Step 5 全流程闭环审计

**验证对象**：全部（IDE 系统目录 + 项目目录 + 所有配置）

**检查目的**：全面体检，用于发布前审计或问题排查

**检查项（16项）**：全部检查项

**失败处置**：
- 输出完整验证报告
- 不自动回滚（由人工判断处置方式）
- 退出码反映验证结果

---

##### 5.4.3.4 接口规范

```powershell
# 参数
param(
  [Parameter(Mandatory=$false)]
  [ValidateSet("package", "install", "update", "init", "full")]
  [string]$Mode = "full",          # 验证模式

  [Parameter(Mandatory=$false)]
  [string]$ProjectPath,            # 项目路径（默认当前目录）

  [Parameter(Mandatory=$false)]
  [string]$PackagePath,            # 下载包路径（package 模式专用）

  [Parameter(Mandatory=$false)]
  [string]$ExpectedVersion,        # 期望版本号（可选）

  [Parameter(Mandatory=$false)]
  [switch]$Quiet                   # 静默模式，只输出结果对象
)

# 返回值（对象）
# @{
#   Valid = $true/$false          # 验证是否通过
#   Mode = "install"              # 当前验证模式
#   Version = "2.9.1"             # 检测到的版本号
#   TotalChecks = 11              # 总检查项数（对应模式）
#   PassCount = 11                # 通过数
#   FailCount = 0                 # 失败数
#   WarnCount = 0                 # 警告数
#   Checks = @(                   # 各检查项详细结果
#     @{
#       Id = "C01"
#       Category = "配置文件存在性"
#       Name = "devflow-config.json"
#       Status = "pass"          # pass / fail / warn / skip
#       Message = ""
#       Detail = ""
#     }
#   )
#   Errors = @(...)               # 错误列表
#   Warnings = @(...)             # 警告列表
#   Duration = "2.3s"             # 验证耗时
# }
```

---

##### 5.4.3.5 失败处置总表

| 模式 | 调用方 | 失败处置 | 退出码 |
|:----:|:------|:---------|:------:|
| package | download-devflow.ps1 | Clone: 删除临时目录<br>Update: 不修改本地 | 1 |
| install | install.ps1 | 回滚安装 + 清理已部署文件 | 1 |
| update | update.ps1 | 自动从备份恢复 | 1 |
| init | devflow-init | 清理 .devflow/ 目录 | 1 |
| full | 手动 / Step 5 | 报告结果，不自动处置 | 1（失败）/ 0（通过） |

---

##### 5.4.3.6 设计原则

1. **分层验证**：越早发现问题，回滚成本越低。download 阶段就验证包完整性，避免带着问题进入安装。
2. **模式复用**：高一级模式包含低一级模式的全部检查，避免重复定义。
3. **渐进严格**：越靠后的阶段验证越严格（package 只查包内，update 还要查迁移结果）。
4. **失败即回滚**：除 full 模式外，所有自动调用的验证失败都自动回滚，不留下半成品。
5. **自验证**：validate-install.ps1 自身也在检查范围内，防止验证脚本本身缺失。

---

## 6. 技能文档路径引用更新设计（对应 V291-001）

### 6.1 需更新的技能文件清单

配置文件精简后，所有引用旧配置文件路径的技能文档均需更新。以下为需更新的技能文件清单：

| 技能文件 | 层级 | 引用内容 | 更新类型 |
|---------|:----:|---------|:--------:|
| devflow-init / SKILL.md | L1 | 读取 version.json、config.json | 路径变更 + 字段重组 |
| devflow-phase-manager / SKILL.md | L1 | 读取 state.json、config.json | 部分路径变更 |
| devflow-project-config / SKILL.md | L1 | 读写 config.json | 重命名为 project-config.json |
| version-planning-stage-execution.md | L2 | 读取项目版本、命名规范 | 字段来源变更 |
| requirements-stage-execution.md | L2 | 读取项目代号、命名规范 | 字段来源变更 |
| design-stage-execution.md | L2 | 读取项目元数据、命名规范 | 字段来源变更 |
| coding-stage-execution.md | L2 | 读取命名规范、远程仓库 | 字段来源变更 |
| testing-stage-execution.md | L2 | 读取项目配置 | 字段来源变更 |
| operations-stage-execution.md | L2 | 读取远程仓库、环境配置 | 字段来源变更 |
| project-document-management.md | L3 | 读取命名规范、项目元数据 | 字段来源变更 |
| code-version-backup-management.md | L3 | 读取远程仓库、备份配置 | 字段来源变更 |
| project-coding-conventions.md | L3 | 读取命名规范 | 字段来源变更 |
| cicd-pipeline-management.md | L3 | 读取远程仓库、环境配置 | 字段来源变更 |

### 6.2 路径映射表

| v2.9.0 路径/字段 | v2.9.1 路径/字段 | 说明 |
|:----------------:|:----------------:|------|
| `version.json`（根目录）`.version` | `devflow-config.json` `.devflowVersion` | 框架版本号 |
| `version.json`（根目录）`.name` | `devflow-config.json` `.metadata.name` | 框架名称 |
| `version.json`（根目录）`.repository` | `devflow-config.json` `.metadata.repository` | 框架仓库地址 |
| `.devflow/version.json` | （删除） | 重复版本记录，统一到 devflow-config.json |
| `devflow-manifest.json` | `devflow-config.json` `.skills` | 技能清单位置 |
| `.devflow/config.json` `.project.name` | `.devflow/project-config.json` `.project.name` | 项目名称 |
| `.devflow/config.json` `.project.version` | `.devflow/project-config.json` `.project.version` | 项目版本 |
| `.devflow/config.json` `.remote.origin` | `.devflow/project-config.json` `.remote.origin` | 远程仓库地址 |
| `.devflow/config.json` `.naming.projectPrefix` | `.devflow/project-config.json` `.naming.projectPrefix` | 项目前缀 |
| `.devflow/config.json` `.naming.docVersionFormat` | `.devflow/project-config.json` `.naming.docVersionFormat` | 文档版本格式 |
| `.devflow/config.json` `.workflow.startingStep` | `.devflow/project-config.json` `.workflow.startingStep` | 起始步骤 |
| `.devflow/config.json` `.environments` | `.devflow/project-config.json` `.environments` | 环境配置 |
| `.devflow/state.json` | `.devflow/state.json` | 状态文件位置不变 |
| `.trae/skills/devflow-plugin-config/version.json` | `~/.trae-cn/skills/devflow-plugin-config/devflow-config.json` | IDE 全局配置路径 |

### 6.3 引用更新原则

1. **向前兼容**：技能文档中应优先读取新路径，旧路径作为 fallback（共存周期内）
2. **统一封装**：配置读取逻辑统一封装到 devflow-project-config 技能，其他技能通过该技能间接读取
3. **渐进更新**：L1 技能先更新，L2/L3 技能后续版本逐步更新
4. **文档同步**：所有引用路径的代码片段和示例同步更新

---

## 7. 全阶段产出真实性验证门禁设计（对应 V291-003）

### 7.1 验证门禁总体架构

全阶段产出真实性验证门禁（Output Authenticity Verification Gate，简称 OAV-Gate）是 v2.9.1 新增的质量保障机制，旨在确保每个阶段的产出文档真实存在、内容完整、符合规范。

**设计目标**：
- 防止"有流程记录无实际产出"的纸面流程
- 确保各阶段交付物真实可追溯
- 为审计环节提供客观证据基础

**总体架构**：

```text
┌───────────────────────────────────────────────────────────────────┐
│                   OAV-Gate 验证门禁体系                            │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ 标准化验证模板（Verification Template）                    │  │
│  │  统一格式、统一检查项、统一判定规则                         │  │
│  └──────────────────────┬────────────────────────────────────┘  │
│                         │                                         │
│  ┌──────────────────────▼────────────────────────────────────┐  │
│  │ 6 个阶段验证点（Stage Verification Points）                │  │
│  │                                                            │  │
│  │  Step 0 验证点 ──→ 版本规划产出验证                         │  │
│  │  Step 1 验证点 ──→ 需求阶段产出验证                         │  │
│  │  Step 2 验证点 ──→ 设计阶段产出验证                         │  │
│  │  Step 3 验证点 ──→ 编码阶段产出验证                         │  │
│  │  Step 4 验证点 ──→ 测试阶段产出验证                         │  │
│  │  Step 5 验证点 ──→ 运维阶段产出验证 + 全阶段盘点            │  │
│  └──────────────────────┬────────────────────────────────────┘  │
│                         │                                         │
│  ┌──────────────────────▼────────────────────────────────────┐  │
│  │ 审计环节核查（Audit Review Integration）                   │  │
│  │  设计评审、开发审计、测试回溯、综合审计 接入验证结果          │  │
│  └──────────────────────┬────────────────────────────────────┘  │
│                         │                                         │
│  ┌──────────────────────▼────────────────────────────────────┐  │
│  │ 证据要求与不通过处置（Evidence & Disposition）             │  │
│  │  证据链管理、不通过分级、阻断/警告/通过规则                 │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

### 7.2 标准化验证模板设计

每个验证点均使用统一的验证模板，确保检查标准一致、结果可对比。

#### 7.2.1 验证模板结构

```markdown
## {阶段名称} 产出验证报告
- **验证时间**: {timestamp}
- **验证触发**: {阶段完成门禁 / 审计抽查 / 手动触发}
- **验证版本**: {project-version}
- **验证人**: {verifier}

### 验证清单

| 序号 | 检查项 | 预期产出 | 验证方式 | 结果 | 证据路径 | 备注 |
|:----:|--------|---------|:--------:|:----:|---------|------|
| 1 | {检查项1} | {文件路径/内容} | 文件存在/内容检查/大小校验 | ✅/❌/⚠️ | {实际路径} | {说明} |
| 2 | {检查项2} | ... | ... | ... | ... | ... |
| ... | ... | ... | ... | ... | ... | ... |

### 验证统计
- 总检查项: {n}
- 通过: {n}
- 警告: {n}
- 不通过: {n}
- 通过率: {xx.x}%

### 验证结论
- **结论**: 通过 / 有条件通过 / 不通过
- **阻断等级**: 无 / 警告 / 阻断
- **后续动作**: {说明}
```

#### 7.2.2 验证方式定义

| 验证方式 | 代码 | 说明 | 实现工具 |
|---------|:----:|------|---------|
| 文件存在性检查 | F-EXIST | 检查文件/目录是否存在 | LS / Glob |
| 文件非空检查 | F-NOTEMPTY | 检查文件大小 > 0 且行数 > 0 | LS + 行数统计 |
| 内容关键字检查 | F-KEYWORD | 检查文件包含指定关键字段 | Grep |
| 格式合规检查 | F-FORMAT | 检查文件格式（JSON/Markdown） | Schema 校验 / 解析 |
| 命名规范检查 | F-NAMING | 检查文件名是否符合命名规范 | 正则匹配 |
| 版本一致性检查 | F-VERSION | 检查版本号与当前版本一致 | 字段对比 |
| 关联追溯检查 | F-TRACE | 检查上下游产出物的追溯关系 | 交叉引用检查 |

### 7.3 6 个阶段验证点设计

#### 7.3.1 Step 0：版本规划阶段验证点

**触发时机**：Step 0 完成门禁检查时

**验证清单**：

| 序号 | 检查项 | 预期产出 | 验证方式 | 阻断等级 |
|:----:|--------|---------|:--------:|:--------:|
| 1 | 版本规划文档存在 | `doc/requirements/DevFlow-版本规划-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 2 | 版本规划文档版本号正确 | 文档标题含当前版本号 | F-KEYWORD + F-VERSION | 警告 |
| 3 | 需求清单完整 | 文档包含需求条目列表 | F-KEYWORD | 阻断 |
| 4 | 技术债务总表存在 | `doc/development/技术债务总表.md` | F-EXIST | 警告 |
| 5 | 候选需求池存在 | `doc/requirements/候选需求池.md` | F-EXIST | 警告 |
| 6 | 还债配额检查记录 | 文档包含还债占比计算 | F-KEYWORD | 警告 |
| 7 | 来源检查清单 | 文档包含 6 个通道检查记录 | F-KEYWORD | 警告 |
| 8 | state.json 状态正确 | currentStep = 0, stepStatus = "completed" | F-FORMAT + F-KEYWORD | 阻断 |

#### 7.3.2 Step 1：需求阶段验证点

**触发时机**：Step 1 完成门禁检查时

**验证清单**：

| 序号 | 检查项 | 预期产出 | 验证方式 | 阻断等级 |
|:----:|--------|---------|:--------:|:--------:|
| 1 | 需求规格说明书 | `doc/requirements/...-PRD-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 2 | 需求追溯矩阵 | `doc/requirements/...-RT-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 3 | 需求条目数量匹配 | PRD 中需求数 = RT 中需求数 | F-TRACE | 警告 |
| 4 | 验收标准定义 | 每个需求均有验收标准 | F-KEYWORD | 阻断 |
| 5 | 需求评审记录 | `doc/design/...-设计评审记录-v{ver}.md` 含 Step1 评审 | F-EXIST + F-KEYWORD | 警告 |
| 6 | state.json 状态正确 | currentStep = 1, stepStatus = "completed" | F-FORMAT + F-KEYWORD | 阻断 |

#### 7.3.3 Step 2：设计阶段验证点

**触发时机**：Step 2 完成门禁检查时

**验证清单**：

| 序号 | 检查项 | 预期产出 | 验证方式 | 阻断等级 |
|:----:|--------|---------|:--------:|:--------:|
| 1 | 系统架构设计文档 | `doc/design/...-系统架构设计文档-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 2 | 设计开发追溯矩阵 | `doc/design/...-设计开发追溯矩阵-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 3 | 原型覆盖率检查报告 | 原型覆盖率 >= 阈值 | F-EXIST + F-KEYWORD | 警告 |
| 4 | 后端覆盖率检查报告 | 后端设计覆盖率 >= 阈值 | F-EXIST + F-KEYWORD | 警告 |
| 5 | 安全设计评审记录 | 包含安全设计章节或独立评审记录 | F-KEYWORD | 警告 |
| 6 | 设计评审记录 | `doc/design/...-设计评审记录-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 7 | 需求-设计追溯 | RT 中的需求在设计文档中均有对应 | F-TRACE | 警告 |
| 8 | state.json 状态正确 | currentStep = 2, stepStatus = "completed" | F-FORMAT + F-KEYWORD | 阻断 |

#### 7.3.4 Step 3：编码阶段验证点

**触发时机**：Step 3 完成门禁检查时

**验证清单**：

| 序号 | 检查项 | 预期产出 | 验证方式 | 阻断等级 |
|:----:|--------|---------|:--------:|:--------:|
| 1 | 核心代码文件存在 | `src/` 目录下代码文件非空 | F-EXIST + F-NOTEMPTY | 阻断 |
| 2 | DevLogReport | `doc/development/...-DevLogReport-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 3 | 代码逻辑审查记录 | `doc/development/...-代码逻辑审查记录-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 4 | 静态质量检查报告 | 包含静态检查结果 | F-KEYWORD | 警告 |
| 5 | 设计-代码追溯 | 设计追溯矩阵中的项在代码中均有实现 | F-TRACE | 警告 |
| 6 | 编码规范遵循 | 代码符合项目编码规范 | F-KEYWORD（抽样） | 警告 |
| 7 | 开发审计移交材料 | `doc/development/...-开发审计移交材料-v{ver}.md` | F-EXIST | 警告 |
| 8 | state.json 状态正确 | currentStep = 3, stepStatus = "completed" | F-FORMAT + F-KEYWORD | 阻断 |

#### 7.3.5 Step 4：测试阶段验证点

**触发时机**：Step 4 完成门禁检查时

**验证清单**：

| 序号 | 检查项 | 预期产出 | 验证方式 | 阻断等级 |
|:----:|--------|---------|:--------:|:--------:|
| 1 | 测试用例文档 | `doc/test/...-测试用例-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 2 | 测试报告 | `doc/test/...-测试报告-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 3 | 测试覆盖率 | 新代码行覆盖率 >= 80% | F-KEYWORD | 阻断 |
| 4 | E2E 验证报告 | 包含 E2E 验证结果 | F-EXIST / F-KEYWORD | 警告 |
| 5 | 测试追溯矩阵 | 需求-用例追溯完整 | F-EXIST + F-TRACE | 警告 |
| 6 | 测试回溯对比审计报告 | `doc/audit/verification/...-测试回溯对比审计报告-v{ver}.md` | F-EXIST | 警告 |
| 7 | state.json 状态正确 | currentStep = 4, stepStatus = "completed" | F-FORMAT + F-KEYWORD | 阻断 |

#### 7.3.6 Step 5：运维阶段验证点

**触发时机**：Step 5 完成门禁检查时（同时执行全阶段盘点）

**验证清单**：

| 序号 | 检查项 | 预期产出 | 验证方式 | 阻断等级 |
|:----:|--------|---------|:--------:|:--------:|
| 1 | 发布计划 | `doc/operations/...-发布计划-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 2 | 部署执行报告 | `doc/operations/...-部署执行报告-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 3 | 运维手册 | `doc/operations/...-运维手册-v{ver}.md` | F-EXIST + F-NOTEMPTY | 警告 |
| 4 | 回滚方案 | `doc/operations/...-回滚方案-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 5 | 发布复盘报告 | `doc/operations/...-发布复盘报告-v{ver}.md` | F-EXIST + F-NOTEMPTY | 警告 |
| 6 | 全流程闭环审计报告 | `doc/audit/comprehensive/...-全流程闭环审计报告-v{ver}.md` | F-EXIST + F-NOTEMPTY | 阻断 |
| 7 | 运维审计报告 | `doc/audit/comprehensive/...-运维审计报告-v{ver}.md` | F-EXIST | 警告 |
| 8 | state.json 状态正确 | currentStep = 5, stepStatus = "completed" | F-FORMAT + F-KEYWORD | 阻断 |

### 7.4 审计环节核查设计

验证门禁不仅在阶段结束时触发，还嵌入到各审计环节中，作为审计的客观证据基础。

#### 7.4.1 审计环节嵌入点

| 审计环节 | 触发时机 | 验证范围 | 验证深度 |
|---------|---------|---------|:--------:|
| 设计评审（Design Review） | Step 2 → Step 3 移交前 | Step 0 + Step 1 + Step 2 产出 | 完整验证 |
| 开发审计（Dev Audit） | Step 3 → Step 4 移交前 | Step 0-3 全部产出 | 完整验证 + 代码抽样 |
| 测试回溯审计（Test Audit） | Step 4 → Step 5 移交前 | Step 0-4 全部产出 | 完整验证 + 追溯检查 |
| 综合审计（Comprehensive Audit） | Step 5 发布后 | 全阶段所有产出 | 完整验证 + 全量追溯 |

#### 7.4.2 审计验证增量

审计环节在阶段验证基础上，增加以下深度验证：

| 验证维度 | 阶段验证 | 审计验证 |
|---------|:--------:|:--------:|
| 文件存在性 | ✅ | ✅ |
| 文件非空 | ✅ | ✅ |
| 关键字段存在 | ✅ | ✅ |
| 内容完整性 | 基础检查 | 深度检查 |
| 上下游追溯 | 单点检查 | 全链路检查 |
| 版本一致性 | 单文件 | 跨文件全局检查 |
| 命名规范 | 文件名 | 文件名 + 内容标题 |
| 证据链完整性 | - | ✅ 新增 |

### 7.5 Step 5 全阶段盘点设计

Step 5 运维阶段结束时，执行 **全阶段产出盘点**（Full-Stage Output Inventory），对从 Step 0 到 Step 5 的所有产出物进行一次性全面核查。

#### 7.5.1 盘点目的

- 确认整个版本周期所有预期产出物均已生成
- 发现遗漏的交付物并补全
- 为版本归档和复盘提供完整清单
- 为综合审计提供证据清单

#### 7.5.2 盘点流程

```text
Step 5 全阶段盘点流程
======================

  ↓
[1] 加载盘点清单模板
  └── 从 ops-stage-execution 技能加载全阶段产出清单
  ↓
[2] 按阶段逐项验证
  ├── Step 0 产出验证（8项）
  ├── Step 1 产出验证（6项）
  ├── Step 2 产出验证（8项）
  ├── Step 3 产出验证（8项）
  ├── Step 4 产出验证（7项）
  └── Step 5 产出验证（8项）
  ↓
[3] 跨阶段追溯验证
  ├── 需求追溯：版本规划 → PRD → RT → 设计 → 代码 → 测试
  ├── 版本号一致性：所有文档版本号 == 当前版本
  └── 命名规范一致性：所有文档符合命名规范
  ↓
[4] 生成盘点报告
  ├── 总产出物数量统计
  ├── 各阶段通过率统计
  ├── 遗漏产出物清单
  ├── 不一致项清单
  └── 总体结论
  ↓
[5] 不通过项处置
  ├── 阻断级遗漏 → 阻止版本关闭，要求补全
  ├── 警告级遗漏 → 记录并纳入技术债务
  └── 全部通过 → 版本正常关闭
```

#### 7.5.3 盘点报告产出

- **报告位置**：`doc/audit/comprehensive/DevFlow-全阶段产出盘点报告-v{ver}.md`
- **归档位置**：纳入全流程闭环审计报告作为附件
- **状态记录**：盘点结果写入 state.json `outputInventory` 字段

### 7.6 证据要求与不通过处置

#### 7.6.1 证据链要求

每个验证不通过项必须提供以下证据，确保可追溯、可复核：

| 证据类型 | 说明 | 形式 |
|---------|------|------|
| 文件路径 | 缺失文件的预期路径 | 相对路径字符串 |
| 错误详情 | 验证失败的具体原因 | 文本描述 |
| 截图/日志 | 验证工具输出的原始信息 | 文本/截图引用 |
| 上下文 | 相关的阶段记录或说明 | 引用链接 |

#### 7.6.2 不通过分级与处置

| 阻断等级 | 标识 | 判定标准 | 处置方式 | 阶段流转影响 |
|:-------:|:----:|---------|---------|:------------:|
| 阻断 | 🔴 | 核心产出物缺失或严重不合格 | 1. 阻止阶段流转<br>2. 输出缺失清单<br>3. 要求补全后重验证 | 阻断 |
| 警告 | 🟡 | 非核心产出物缺失或轻微不合格 | 1. 记录警告<br>2. 给出补全建议<br>3. 可带警告进入下一阶段 | 不阻断，但记录 |
| 通过 | 🟢 | 所有检查项均通过 | 正常流转 | 无影响 |

#### 7.6.3 重新验证机制

```text
验证不通过
  ↓
[1] 用户补全缺失产出物
  ↓
[2] 手动触发重新验证
  ├── 仅验证失败项（快速模式）
  └── 全量重新验证（完整模式）
  ↓
[3] 验证结果更新
  ├── 通过 → 清除阻断/警告，更新验证报告
  └── 仍不通过 → 累计失败次数，输出改进建议
  ↓
[4] 累计 3 次不通过
  └── 触发专项评审，分析根本原因
```

---

## 8. 技术选型与 ADR

### 8.1 ADR-001：配置文件命名方案选择

**状态**：已采纳
**日期**：2026-07-22

#### 上下文

配置文件精简合并后，需要为新的配置文件确定命名方案。命名需要清晰表达文件用途，同时与现有文件体系协调。

#### 备选方案

| 方案 | 命名 | 优点 | 缺点 |
|:----:|------|------|------|
| A | `devflow-config.json` + `project-config.json` | 前缀明确，区分框架/项目，语义清晰 | 文件名稍长 |
| B | `config.json`（根目录）+ `project.json`（.devflow/） | 简洁 | 与旧 `.devflow/config.json` 易混淆，根目录 config.json 太泛 |
| C | `devflow.json` + `project.json` | 简洁 | devflow.json 语义不明确（配置？清单？） |
| D | `framework.json` + `project.json` | 简洁专业 | framework 不如 devflow 辨识度高 |

#### 决策

**选择方案 A**：`devflow-config.json` + `project-config.json`

理由：
1. 前缀 `devflow-` 明确标识 DevFlow 框架文件，避免与项目自身配置混淆
2. `devflow-config` vs `project-config` 清晰区分框架级和项目级
3. 与 DevFlow 其他文件命名风格一致（如 `devflow-init`、`devflow-phase-manager`）
4. 搜索和识别方便，grep "devflow-" 可列出所有 DevFlow 框架文件

#### 后果

- 文件路径变化，需要所有引用方更新
- 与旧文件名称完全不同，减少混淆，迁移检测更清晰
- 文件名较长，但语义明确，可接受

### 8.2 ADR-002：脚本合并策略选择

**状态**：已采纳（更新后）
**日期**：2026-07-22

#### 上下文

v2.9.0 有多个脚本（install.ps1、setup.ps1、update.ps1、sync-skills.ps1、validate-install.ps1），职责重叠且用户入口不清晰。需要确定合并策略。

#### 备选方案

| 方案 | 策略 | 优点 | 缺点 |
|:----:|------|------|------|
| A | 2入口 + 2内部模块 + 1强制验证门禁（install/update + download/setup + validate） | 用户入口清晰，内部复用性好，验证为强制门禁保障质量 | 需要重构脚本结构 |
| B | 单入口多命令（devflow.ps1 install/update/sync） | 最精简，统一 CLI 风格 | 改变用户使用习惯，迁移成本高 |
| C | 保留3入口（install/update/setup），合并 sync 到 update | 改动最小 | setup 与 install 功能重叠问题未解决 |
| D | 全部合并为1个大脚本（devflow-installer.ps1） | 文件最少 | 职责不清，维护困难 |

#### 决策

**选择方案 A**：2个入口脚本 + 2个内部模块 + 1个强制验证门禁

理由：
1. `install` 和 `update` 是用户最核心的两个操作场景，语义差异大，分开更清晰
2. `setup.ps1` 作为内部模块保留，专注技能部署和 IDE 集成，被 install/update 共同调用
3. `sync-skills.ps1` 是 update 的子集操作，合并到 update.ps1 更合理
4. `validate-install.ps1` **升级为强制验证门禁**，是 install/update 都必须经过的最后一关，不通过则失败回滚——确保安装/更新质量
5. 内部模块（download/setup）抽离复用，避免代码重复
6. 改动幅度适中，用户学习成本低

#### 后果

- 需要将 setup.ps1 调整为内部模块（位置移至 .devflow/scripts/）
- 需要删除 sync-skills.ps1，功能合并到 update.ps1
- validate-install.ps1 升级为强制门禁，检查内容需同步更新
- 需要更新文档中的脚本引用
- install.ps1 和 update.ps1 需要重构以调用内部模块
- 内部模块需明确接口规范，便于未来扩展

### 8.3 ADR-003：产出验证工具选择

**状态**：已采纳
**日期**：2026-07-22

#### 上下文

全阶段产出真实性验证门禁需要选择合适的验证工具实现方式。验证的核心是检查文件存在、内容关键字、格式合规等。

#### 备选方案

| 方案 | 实现方式 | 优点 | 缺点 |
|:----:|---------|------|------|
| A | LS / Glob + Grep（基于 TRAE 内置工具） | 无需额外依赖，与 TRAE 生态集成好，性能高 | 复杂验证逻辑表达能力有限 |
| B | 自定义 PowerShell 脚本 | 灵活，可实现复杂验证逻辑，跨平台 | 需维护脚本，依赖 PowerShell 环境 |
| C | 专用 Node.js 验证工具 | 生态丰富，异步能力强 | 依赖 Node.js，增加安装体积 |
| D | 混合方案：基础检查用 LS/Glob，复杂验证用脚本 | 兼顾效率和灵活性 | 实现稍复杂 |

#### 决策

**选择方案 D**：混合方案（LS/Glob + PowerShell 脚本）

理由：
1. 文件存在性检查等基础验证使用 LS/Glob 即可，简单高效
2. 内容关键字检查、格式校验使用 Grep
3. 复杂的跨文件追溯验证、批量报告生成使用 PowerShell 脚本
4. 验证脚本放在 `.devflow/scripts/verify-outputs.ps1`，作为内部工具
5. 技能文档中定义验证规则，具体执行由技能调用工具完成

#### 后果

- 验证逻辑分布在技能文档（规则定义）和脚本（执行实现）中
- 需确保规则和实现的一致性
- 性能和灵活性兼顾
- 未来可逐步将更多验证逻辑下沉到脚本中

---

## 9. 非功能设计

### 9.1 向后兼容性

| 维度 | 设计措施 | 兼容周期 |
|------|---------|:--------:|
| 配置文件格式 | 自动迁移机制 + 旧文件 fallback 读取 | v2.9.1 - v2.10.0 |
| 脚本入口 | install.ps1 / update.ps1 保留，setup.ps1 重定向警告 | v2.9.1 - v2.10.0 |
| 技能接口 | 配置读取封装到 project-config 技能，对外接口不变 | 永久 |
| state.json | 位置和核心字段不变，仅新增字段 | 永久 |
| 文档路径 | doc/ 目录结构不变 | 永久 |

**兼容性保障机制**：
1. 版本检测：每次 init 时检测版本差异
2. 自动迁移：旧版本自动升级到新格式
3. 回滚能力：迁移失败自动回滚
4. 共存周期：新旧格式至少共存一个版本周期
5. 废弃预告：提前一个版本预告废弃计划

### 9.2 可靠性

| 维度 | 设计措施 |
|------|---------|
| 配置写入 | 临时文件 + 原子替换，避免写入中断损坏 |
| 迁移失败 | 全量备份 + 自动回滚 |
| 验证门禁 | 阻断级错误阻止阶段流转，防止问题扩散 |
| 脚本容错 | 每步检查返回值，异常时输出清晰错误信息 |
| 文件完整性 | 下载后 SHA256 校验 |
| 幂等性 | install/update 支持重复执行，结果一致 |

### 9.3 可维护性

| 维度 | 设计措施 |
|------|---------|
| 配置分层 | 框架配置 vs 项目配置分离，各有明确职责 |
| 脚本模块化 | 公共功能抽离为内部模块，入口脚本只做流程编排 |
| 验证模板化 | 统一验证模板，新增验证点只需填清单 |
| 版本化 Schema | 配置文件自带 schemaVersion，支持演进 |
| 变更日志 | CHANGELOG.md 记录每个版本的架构变更 |
| 文档自描述 | 配置文件和技能文档均含字段说明 |

### 9.4 性能

| 维度 | 指标 | 设计措施 |
|------|------|---------|
| 配置读取 | < 10ms | JSON 文件直接读取，无额外解析开销 |
| 配置迁移 | < 5s | 仅涉及少量小文件读写 |
| 产出验证 | < 30s（单阶段） | LS/Glob 批量检查 + 按需深度检查 |
| 全阶段盘点 | < 2min | 并行执行各阶段检查 |
| 脚本启动 | < 1s | 脚本尽量轻量，延迟加载重型模块 |

### 9.5 可观测性

| 维度 | 设计措施 |
|------|---------|
| 迁移日志 | 每次迁移完整记录到 state.json.migrationLog |
| 验证日志 | 每次验证生成验证报告，存放到 doc/audit/ |
| 操作审计 | 阶段流转、配置变更均记录到 state.json.history |
| 错误报告 | 脚本失败时输出结构化错误信息，包含定位指引 |
| 版本追踪 | devflow-config.json 记录框架版本，IDE 副本同步 |

---

## 10. 部署与发布影响

### 10.1 发布包变更

| 项目 | v2.9.0 | v2.9.1 | 变更说明 |
|------|:------:|:------:|---------|
| 根目录 JSON 文件 | version.json | devflow-config.json | 重命名 + 内容重组 |
| .devflow/ 配置文件 | config.json | project-config.json | 重命名 + 字段重组 |
| 根目录脚本 | install.ps1, setup.ps1, update.ps1 | install.ps1, update.ps1 | 删除 setup.ps1 |
| 技能脚本 | sync-skills.ps1, download-devflow.ps1 | download-devflow.ps1 | sync-skills 合并到 update.ps1 |
| 验证脚本 | validate-install.ps1 | validate-install.ps1, verify-outputs.ps1 | 新增产出验证脚本 |

### 10.2 升级路径

#### 10.2.1 从 v2.9.0 升级到 v2.9.1

```text
升级步骤：
  [1] 在项目根目录执行 .\update.ps1 -TargetVersion 2.9.1
  [2] 脚本自动检测旧配置，执行自动迁移
  [3] 迁移完成后输出迁移报告
  [4] 验证安装有效性
  [5] 旧文件归档到 .devflow/backup/legacy-configs/
```

**预计升级时间**：< 1 分钟

**风险**：低（自动迁移 + 自动回滚）

#### 10.2.2 从 v2.8.x 及更早版本升级

升级路径：先升级到 v2.9.0，再升级到 v2.9.1

或者：直接执行 v2.9.1 的 install.ps1 -Force（全新安装，保留项目配置）

### 10.3 对现有项目的影响

| 影响项 | 影响程度 | 说明 |
|-------|:--------:|------|
| 项目配置数据 | 无影响 | 自动迁移，数据完整保留 |
| 文档产出 | 无影响 | doc/ 目录结构不变 |
| 技能使用方式 | 无影响 | 技能调用方式不变 |
| 开发流程 | 增强 | 新增验证门禁，流程更严谨 |
| 脚本命令 | 轻微 | setup.ps1 废弃，改用 install.ps1 |
| 配置文件路径 | 中等 | 文件名和位置变更，但自动迁移 |

### 10.4 文档同步更新清单

发布 v2.9.1 时需同步更新的文档：

| 文档 | 更新内容 |
|------|---------|
| README.md | 更新配置文件说明、脚本使用说明 |
| quickstart.md | 更新安装/更新步骤 |
| CHANGELOG.md | 记录 v2.9.1 所有变更 |
| 技能文档 | 所有引用旧配置路径的技能文档更新 |
| 运维手册 | 更新配置管理章节 |

---

## 11. 风险与缓解

### 11.1 配置架构重构风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|:----:|:----:|---------|
| 自动迁移失败导致配置丢失 | 低 | 高 | 迁移前全量备份 + 自动回滚 + 迁移后验证 |
| 迁移后部分技能仍读取旧路径 | 中 | 中 | 共存周期内保留 fallback 读取 + 全面测试 + 逐步移除 |
| 第三方工具/脚本依赖旧配置路径 | 低 | 中 | 提供迁移指南 + 旧文件在备份目录可恢复 |
| 用户手动修改配置时混淆新旧文件 | 中 | 低 | 清晰的命名区分 + 文档说明 + 共存期警告提示 |

### 11.2 脚本架构重构风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|:----:|:----:|---------|
| 用户习惯 setup.ps1，删除后找不到入口 | 中 | 低 | install.ps1 兼容 setup.ps1 参数 + 文档更新 + 过渡期警告 |
| 合并后脚本逻辑复杂，引入 bug | 中 | 中 | 模块化设计 + 充分测试 + 版本回滚能力 |
| 内部模块接口不稳定 | 低 | 低 | 内部模块明确接口契约 + 版本化管理 |
| 跨平台兼容性问题 | 低 | 中 | PowerShell Core 兼容测试 + Shell 版本同步 |

### 11.3 验证门禁风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|:----:|:----:|---------|
| 验证门禁过于严格，影响开发效率 | 中 | 中 | 阻断/警告分级，核心项阻断、非核心项警告 + 可配置开关 |
| 验证结果不准确，误报或漏报 | 中 | 中 | 验证规则评审 + 抽样人工复核 + 持续优化规则 |
| 验证报告过多，信息过载 | 低 | 低 | 分级展示 + 摘要视图 + 详细报告按需查看 |
| 验证执行耗时过长 | 低 | 低 | 基础检查快速执行 + 深度检查按需触发 + 并行优化 |

### 11.4 总体风险评估

| 风险类别 | 整体风险等级 | 可控性 |
|---------|:------------:|:------:|
| 配置架构重构 | 🟡 中等 | 高（迁移机制完善） |
| 脚本架构重构 | 🟢 低 | 高（模块化 + 回滚） |
| 验证门禁新增 | 🟡 中等 | 中（需持续优化规则） |
| **总体** | **🟡 中等偏低** | **高** |

---

## 12. 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-22 | 初始创建，v2.9.1 系统架构设计<br>• 配置架构重构：6文件→3文件 + 迁移机制<br>• 脚本架构重构：5脚本→2入口+2模块<br>• 新增全阶段产出真实性验证门禁 | PM-DevFlow-Dev |
| 1.1.0 | 2026-07-22 | 修正 validate-install.ps1 定位：从可选内部模块升级为**强制验证门禁**<br>• 新增 setup.ps1 为内部模块（原以为合并，实际保留为内部模块）<br>• install.ps1 和 update.ps1 均移除 -SkipValidation 参数，验证为必走流程<br>• validate-install.ps1 检查项从 5 大类扩展为 6 大类 16 项（新增脚本完整性、BOM检查、版本一致性）<br>• 验证失败自动回滚机制<br>• 更新 ADR-002 脚本合并策略 | PM-DevFlow-Dev |
| 1.2.0 | 2026-07-22 | validate-install.ps1 **多模式验证体系**完整设计<br>• 新增 5 种模式：package / install / update / init / full<br>• package 模式：download 后验证下载包完整性（8项）<br>• install 模式：安装后验证（11项，含 package 全部）<br>• update 模式：更新后验证（13项，含 install 全部 + 迁移验证）<br>• init 模式：devflow-init 后验证项目配置（6项）<br>• full 模式：全量验证（16项，手动/Step5用）<br>• download-devflow.ps1 增加 package 模式强制验证门禁<br>• 分层验证 + 模式复用 + 渐进严格设计原则 | PM-DevFlow-Dev |

---

> **文档结束**
>
> 本文档为 DevFlow v2.9.1 系统架构设计的完整描述，涵盖配置架构重构、脚本架构重构和全阶段产出验证门禁三大变更。所有设计均遵循 DevFlow 框架的核心原则：以技能驱动流程，以文档固化产出，以门禁保障质量。
