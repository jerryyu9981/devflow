# DevFlow v2.4.0 系统架构设计文档

| 项目信息 | |
|---|---|
| **项目名称** | DevFlow — 软件开发工程规范插件 |
| **目标版本** | v2.4.0 |
| **基准版本** | v2.3.2 |
| **文档版本** | 1.0 |
| **创建日期** | 2026-07-02 |
| **文档状态** | 编制中 |
| **文档 owner** | jerry.yu |
| **所属阶段** | Step 2 — 架构与设计 |

---

## 目录

1. [文档概述](#1-文档概述)
2. [设计入场检查记录](#2-设计入场检查记录)
3. [架构设计原则](#3-架构设计原则)
4. [系统架构总览](#4-系统架构总览)
5. [模块设计](#5-模块设计)
6. [技术选型](#6-技术选型)
7. [数据流设计](#7-数据流设计)
8. [关键设计决策](#8-关键设计决策)
9. [风险与缓解](#9-风险与缓解)
10. [开放问题](#10-开放问题)
11. [变更记录](#11-变更记录)

---

## 1. 文档概述

### 1.1 文档目的

本文档是 DevFlow v2.4.0 版本的**系统架构设计文档**，是 Step 2 架构与设计阶段的核心交付物。本文档基于 Step 1 需求分析阶段的基线输出，从架构层面定义 v2.4.0 的系统分层、目录结构、模块划分、数据流、技术选型和关键设计决策，为后续 Step 3 编码实现提供完整的技术蓝图。

### 1.2 读者对象

| 角色 | 阅读目的 |
|---|---|
| 项目负责人 / 架构师 | 审核架构方案合理性，确认技术选型 |
| 内容架构师 | 理解技能体系变更，设计新技能内容结构 |
| 开发负责人 | 基于模块设计和技术选型制定开发计划 |
| 质量负责人 | 基于架构约束制定测试策略和质量标准 |
| 文档负责人 | 理解系统变更范围，规划用户文档更新 |

### 1.3 术语定义

| 术语 | 定义 |
|---|---|
| DevFlow | 一套软件开发工程规范插件，通过 SKILL.md 文件安装在 AI 编程助手（TRAE Work、Claude Code、Cursor、Codex CLI）中 |
| SKILL.md | DevFlow 技能文件的标准格式，用于向 AI 编程助手声明可用技能及其使用方式 |
| L1 / L2 / L3 | DevFlow 三层技能体系：L1=编排层、L2=阶段执行层、L3=专项参考层 |
| Orchestrator | DevFlow 编排器，负责 L1/L2/L3 三层技能的协调调度，当前有 3 个 |
| 编译层模式 | L2 文件末尾内联 L3 速查表章节，使 AI 平台运行时加载深度始终为 2 层（L2->速查->L3） |
| 6 阶段开发流程 | 版本规划 -> 需求分析 -> 设计 -> 编码 -> 测试 -> 部署 |
| version.json | DevFlow 插件的版本信息文件，作为版本号的单一来源（Single Source of Truth） |
| config.json | DevFlow 项目级配置文件，存储分支策略、备份配置、远程仓库等设置 |
| state.json | DevFlow 项目状态文件，记录当前开发阶段和已完成阶段 |

### 1.4 参考文档

| 文档名称 | 文档路径 |
|---|---|
| 需求基线及设计移交说明 | `doc/requirements/DevFlow-v2.4.0-需求基线及设计移交说明.md` |
| 开发需求文档 | `doc/requirements/DevFlow-v2.4.0-开发需求文档.md` |
| 用户需求说明书 | `doc/requirements/DevFlow-v2.4.0-用户需求说明书.md` |
| UIUX 需求说明 | `doc/requirements/DevFlow-v2.4.0-UIUX需求说明.md` |
| 单版本规划文档 | `doc/version/releases/v2.4.0/DevFlow-v2.4.0-单版本规划文档.md` |
| 本版本 Backlog | `doc/version/releases/v2.4.0/DevFlow-v2.4.0-本版本Backlog.md` |
| Phase 迭代计划 | `doc/version/releases/v2.4.0/DevFlow-v2.4.0-Phase迭代计划.md` |
| 版本依赖清单 | `doc/version/releases/v2.4.0/DevFlow-v2.4.0-版本依赖清单.md` |
| 版本风险清单 | `doc/version/releases/v2.4.0/DevFlow-v2.4.0-版本风险清单.md` |
| 版本成功指标说明 | `doc/version/releases/v2.4.0/DevFlow-v2.4.0-版本成功指标说明.md` |
| 需求追溯矩阵 | `doc/requirements/DevFlow-v2.4.0-需求追溯矩阵.md` |

---

## 2. 设计入场检查记录

本文档编制前，确认 Step 2 架构与设计阶段的全部入场条件满足情况如下：

| 序号 | 入场条件 | 满足状态 | 验证依据 | 备注 |
|---|---|---|---|---|
| 1 | 需求基线已建立并冻结 | 已满足 | `DevFlow-v2.4.0-需求基线及设计移交说明.md` 状态为"待审批" | 基线版本 v2.4.0-requirements-baseline-1.0，含 15 项需求 + 8 项技术债务 |
| 2 | 开发需求文档已发布 | 已满足 | `DevFlow-v2.4.0-开发需求文档.md` 状态为"正式发布" | 含功能需求、非功能需求、数据需求、验收标准 |
| 3 | 设计移交材料完整 | 已满足 | 移交说明第 4 节列出 12 项移交材料，全部就绪 | 含版本目标、Backlog、功能需求、UIUX、风险清单等 |
| 4 | Phase 迭代计划已批准 | 已满足 | `DevFlow-v2.4.0-Phase迭代计划.md` 状态为"正式发布" | 4 Phase、10 周总周期、周粒度排期 |
| 5 | 架构一致性约束已确认 | 已满足 | 移交说明第 4.3 节明确 4 项设计约束 | 保持 3 层技能架构不变，不引入破坏性变更 |

**入场检查结论**：全部 5 项入场条件均满足，可以进入 Step 2 架构与设计阶段。

---

## 3. 架构设计原则

### 3.1 架构稳定性原则

**保持 3 层技能体系不变**。v2.4.0 的所有变更均须在现有 L1（编排层）/ L2（阶段执行层）/ L3（专项参考层）+ Orchestrator 的架构框架内进行。不引入新的层级、不修改层间调用关系的基本模式。新增的 L3 技能（VR-006/007/009）通过现有的 L2 编译层模式集成。

### 3.2 单一来源原则

**version.json 作为版本号单一来源**。所有版本号读取、比较、展示均须从 `devflow-plugin/version.json` 文件获取，不得在脚本中硬编码版本号。安装脚本、更新脚本、初始化脚本均通过读取该文件获取当前版本信息。

### 3.3 格式标准化原则

**SKILL.md 作为技能声明标准格式**。v2.4.0 新增和修改的所有技能文件须遵循 VR-012 定义的编写规范，使用统一的前置元数据格式、章节结构和速查表格式。四套标准模板（L1/L2/L3/Orchestrator）作为新技能创建的起点。

### 3.4 跨平台一致性原则

**脚本跨平台一致性（Windows/macOS/Linux）**。v2.4.0 引入的安装脚本、检查脚本、验证脚本均须同时提供 PowerShell 5.1+（Windows）和 bash 3.2+（macOS/Linux）两个实现，功能行为完全一致。脚本接口（参数、退出码、输出格式）须统一抽象。

### 3.5 编译层模式原则

**L2 内联 L3 速查表，运行时深度始终 2 层**。每个 L2 技能文件末尾包含关联 L3 技能的速查表章节（VR-014 负责补全）。AI 平台在运行时只需加载 L2 层，通过速查表即可定位和调用 L3 技能，避免 3 层递归加载。新增的 L3 技能（security-design-review、secure-coding-standards、container-deployment）须同步内联到对应 L2 技能的速查表中。

### 3.6 零依赖原则

**不引入运行时依赖**。DevFlow 作为轻量级插件，所有脚本和工具不依赖 Node.js、Python 等运行时环境。检查脚本、验证脚本均使用 PowerShell（Windows）和 bash（macOS/Linux）原生能力实现。HTML 文档为纯静态文件，无构建工具依赖。

---

## 4. 系统架构总览

### 4.1 插件体系架构

DevFlow 的核心架构分为 4 层，自下而上分别为运行时层、工具链层、内容资源层和技能声明层：

```
┌─────────────────────────────────────────────────────────────┐
│                     运行时层（AI 平台）                       │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ TRAE Work │ │Claude Code│ │  Cursor  │ │Codex CLI │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
├─────────────────────────────────────────────────────────────┤
│                    技能声明层（SKILL.md）                      │
│  ┌─────────────────────────────────────────────────┐        │
│  │ L1 编排层（3 个）                               │        │
│  │  · project-development-workflow                 │        │
│  │  · project-document-management                  │        │
│  │  · project-role-management                      │        │
│  ├─────────────────────────────────────────────────┤        │
│  │ L2 阶段执行层（6 个）                            │        │
│  │  · version-planning-stage-execution             │        │
│  │  · requirements-stage-execution                 │        │
│  │  · design-stage-execution (+ VR-006/007/009)   │        │
│  │  · coding-stage-execution (+ VR-007 速查)       │        │
│  │  · testing-stage-execution                      │        │
│  │  · operations-stage-execution (+ VR-009 速查)   │        │
│  ├─────────────────────────────────────────────────┤        │
│  │ L3 专项参考层（10 -> 13 个，+3 新技能）           │        │
│  │  · 已有 10 个                                   │        │
│  │  · + security-design-review    （VR-007）       │        │
│  │  · + secure-coding-standards   （VR-007）       │        │
│  │  · + container-deployment      （VR-009）       │        │
│  ├─────────────────────────────────────────────────┤        │
│  │ 编排器（3 个）                                   │        │
│  │  · devflow-init                                 │        │
│  │  · devflow-phase-manager                        │        │
│  │  · devflow-project-config                       │        │
│  └─────────────────────────────────────────────────┘        │
├─────────────────────────────────────────────────────────────┤
│                       内容资源层                              │
│  ┌────────────────────────┐ ┌────────────────────┐         │
│  │ 文档模板（19 -> 25+ 个） │ │ 规范/指南           │         │
│  │  · 已有 19 个模板        │ │  · SKILL.md 编写规范│         │
│  │  · + DR 容灾恢复计划     │ │    （VR-012）       │         │
│  │  · + BK 备份策略指南     │ │                    │         │
│  │  · + BK 多区域备份       │ │                    │         │
│  │  · + BK 恢复演练         │ │                    │         │
│  │  · + 其他安全/容器模板   │ │                    │         │
│  └────────────────────────┘ └────────────────────┘         │
├─────────────────────────────────────────────────────────────┤
│                        工具链层                              │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌──────────┐│
│  │ 安装向导    │ │ 配置管理    │ │ 质量检查    │ │版本管理  ││
│  │ (VR-001)   │ │ (VR-002)   │ │(VR-011/012 │ │(Git +   ││
│  │            │ │            │ │ /013/005)  │ │version.) ││
│  │            │ │            │ │            │ │json     ││
│  └────────────┘ └────────────┘ └────────────┘ └──────────┘│
└─────────────────────────────────────────────────────────────┘
```

### 4.2 目录结构设计（v2.4.0）

v2.4.0 版本在 v2.3.2 目录结构基础上进行扩展，反映新增的技能、模板、脚本和文档：

```
devflow-plugin/
│
├── version.json                          # 版本信息（单一来源），v2.4.0
│
├── install.ps1                            # Windows 安装脚本（增强：VR-001 交互式）
├── install.bat                            # Windows 入口
├── install.sh                             # macOS/Linux 安装脚本（新增：VR-018）
├── setup.ps1                              # Windows 安装后配置脚本（增强：VR-002）
├── setup.sh                               # macOS/Linux 配置脚本（新增：VR-018）
├── update.ps1                             # Windows 版本更新脚本
├── update.sh                              # macOS/Linux 更新脚本（新增：VR-018）
│
├── skills/
│   ├── L1/                                # 3 个编排层技能（不变）
│   │   ├── project-development-workflow.md
│   │   ├── project-document-management.md
│   │   └── project-role-management.md
│   │
│   ├── L2/                                # 6 个阶段执行层技能（内容更新）
│   │   ├── version-planning-stage-execution.md
│   │   ├── requirements-stage-execution.md
│   │   ├── design-stage-execution.md      # 新增 VR-006/007/009 速查表
│   │   ├── coding-stage-execution.md      # 新增 VR-007 安全编码速查表
│   │   ├── testing-stage-execution.md
│   │   └── operations-stage-execution.md  # 新增 VR-009 容器化部署速查表
│   │
│   ├── L3/                                # 10 -> 13 个专项参考层技能（+3 新技能）
│   │   ├── project-coding-conventions.md      # 已有
│   │   ├── code-static-quality-check.md       # 已有
│   │   ├── code-logic-review.md               # 已有
│   │   ├── code-version-backup-management.md  # 已有（增强：VR-006）
│   │   ├── cicd-pipeline-management.md        # 已有
│   │   ├── observability-standards.md         # 已有
│   │   ├── project-document-templates.md      # 已有
│   │   ├── prototype-coverage.md              # 已有（v2.3.1 新增）
│   │   ├── backend-coverage.md                # 已有（v2.3.1 新增）
│   │   ├── api-contract-management.md         # 已有（v2.3.1 新增）
│   │   ├── security-design-review.md          # VR-007 新增
│   │   ├── secure-coding-standards.md          # VR-007 新增
│   │   └── container-deployment.md            # VR-009 新增
│   │
│   └── orchestrator/                        # 3 个编排器（内容更新）
│       ├── devflow-init/
│       │   └── SKILL.md                      # 增强：VR-002 交互问答 + 阶段推断
│       ├── devflow-phase-manager/
│       │   └── SKILL.md                      # 更新：适配新技能
│       └── devflow-project-config/
│           └── SKILL.md                      # 更新：新增配置项
│
├── templates/                              # 19 -> 25+ 个模板
│   ├── README.md                            # 模板索引
│   ├── DT-需求设计追溯矩阵.md                 # 已有
│   ├── RT-需求追溯矩阵.md                    # 已有
│   ├── TD-设计开发追溯矩阵.md                 # 已有
│   ├── dr-disaster-recovery-plan.md         # VR-006 新增：容灾恢复计划
│   ├── bk-backup-strategy-guide.md          # VR-006 新增：备份策略指南
│   ├── bk-multi-region-backup.md            # VR-006 新增：多区域备份方案
│   ├── bk-recovery-drill.md                 # VR-006 新增：恢复演练规程
│   ├── sd-security-design-checklist.md      # VR-007 新增：安全设计检查清单
│   ├── sc-secure-coding-checklist.md        # VR-007 新增：安全编码检查清单
│   └── cd-container-deployment-guide.md     # VR-009 新增：容器化部署指南
│
├── scripts/                                # 辅助脚本（v2.4.0 扩展）
│   ├── build.ps1                            # 已有：构建脚本
│   ├── validate-install.ps1                 # VR-005 新增：安装验证（Windows）
│   ├── validate-install.sh                  # VR-005 新增：安装验证（macOS/Linux）
│   ├── check-references.ps1                 # VR-013 新增：引用完整性检查（Windows）
│   ├── check-references.sh                  # VR-013 新增：引用完整性检查（macOS/Linux）
│   ├── check-format.ps1                    # VR-012 新增：格式检查（Windows）
│   ├── check-format.sh                     # VR-012 新增：格式检查（macOS/Linux）
│   └── detect-environment.ps1/sh            # VR-001 新增：环境检测
│
└── docs/                                   # 用户文档（v2.4.0 新增目录）
    ├── quick-start.md                      # VR-003 新增：快速入门指南
    └── quick-start.html                     # VR-003 新增：快速入门指南（HTML 版本）
```

**目录结构变更说明**：

| 变更类型 | 路径 | 关联需求 | 说明 |
|---|---|---|---|
| 新增 | `install.sh` | VR-018 | macOS/Linux 安装脚本 |
| 新增 | `setup.sh` | VR-018 | macOS/Linux 配置脚本 |
| 新增 | `update.sh` | VR-018 | macOS/Linux 更新脚本 |
| 新增 | `skills/L3/security-design-review.md` | VR-007 | 安全设计审查 L3 技能 |
| 新增 | `skills/L3/secure-coding-standards.md` | VR-007 | 安全编码规范 L3 技能 |
| 新增 | `skills/L3/container-deployment.md` | VR-009 | 容器化部署 L3 技能 |
| 新增 | `templates/dr-*.md` (1 个) | VR-006 | 容灾恢复计划模板 |
| 新增 | `templates/bk-*.md` (3 个) | VR-006 | 备份相关模板 |
| 新增 | `templates/sd-*.md` (1 个) | VR-007 | 安全设计检查清单模板 |
| 新增 | `templates/sc-*.md` (1 个) | VR-007 | 安全编码检查清单模板 |
| 新增 | `templates/cd-*.md` (1 个) | VR-009 | 容器化部署指南模板 |
| 新增 | `scripts/validate-install.ps1/sh` | VR-005 | 安装验证脚本 |
| 新增 | `scripts/check-references.ps1/sh` | VR-013 | 引用完整性检查脚本 |
| 新增 | `scripts/check-format.ps1/sh` | VR-012 | 格式检查脚本 |
| 新增 | `scripts/detect-environment.ps1/sh` | VR-001 | 环境检测脚本 |
| 新增 | `docs/quick-start.md` | VR-003 | 快速入门指南 |
| 新增 | `docs/quick-start.html` | VR-003 | 快速入门指南 HTML 版 |
| 修改 | `install.ps1` | VR-001 | 增强为交互式安装向导 |
| 修改 | `setup.ps1` | VR-002 | 增强初始化引导 |
| 修改 | `skills/L2/*.md` (6 个) | VR-011, VR-014 | 质量审查 + 速查表补全 |
| 修改 | `skills/L3/code-version-backup-management.md` | VR-006 | 增强容灾备份内容 |
| 修改 | `skills/orchestrator/*/SKILL.md` (3 个) | VR-002 | 适配新技能和增强功能 |

### 4.3 技能内容架构（L2 编译层模式）

DevFlow 采用 L2 编译层模式，确保 AI 平台在运行时的技能加载深度始终为 2 层，避免深层递归导致的上下文溢出。

#### 4.3.1 模式说明

```
编译时（技能文件编写阶段）：
  L2 技能文件
    ├── 章节 1：阶段概述
    ├── 章节 2：执行流程
    ├── 章节 3：质量闸门
    ├── ...
    └── 附录：L3 速查表（编译层内联）
        ├── L3 技能 A：名称 + 用途 + 适用条件
        ├── L3 技能 B：名称 + 用途 + 适用条件
        └── L3 技能 C：名称 + 用途 + 适用条件

运行时（AI 平台调用阶段）：
  Step 1: AI 平台加载 L2 技能文件（1 层深度）
  Step 2: L2 速查表提供 L3 技能索引（2 层深度）
  Step 3: 按需加载 L3 技能详细内容（仍是 2 层，非递归）
```

#### 4.3.2 v2.4.0 速查表更新

v2.4.0 需要更新以下 L2 技能的 L3 速查表（VR-014）：

| L2 技能 | 已有 L3 速查项 | v2.4.0 新增速查项 | 关联需求 |
|---|---|---|---|
| version-planning-stage-execution | 现有速查表 | 无新增 | — |
| requirements-stage-execution | 现有速查表 | 无新增 | — |
| design-stage-execution | 现有速查表 | + security-design-review | VR-007 |
| coding-stage-execution | 现有速查表 | + secure-coding-standards | VR-007 |
| testing-stage-execution | 现有速查表 | 无新增 | — |
| operations-stage-execution | 现有速查表 | + container-deployment | VR-009 |

#### 4.3.3 速查表格式规范

每个速查条目遵循统一格式：

```markdown
### [L3 技能名称]

- **用途**：一句话描述
- **适用条件**：何时调用此技能
- **关键输出**：调用后产生的交付物
- **调用方式**：AI 平台加载 L3 文件路径
```

---

## 5. 模块设计

### 5.1 安装向导模块（VR-001）

#### 5.1.1 模块概述

| 属性 | 值 |
|---|---|
| 模块 ID | M-INSTALL |
| 关联需求 | VR-001（P0）、VR-018（P1） |
| 实现形式 | install.ps1（Windows）+ install.sh（macOS/Linux） |
| 依赖 | version.json、skills/、templates/、scripts/detect-environment.* |

#### 5.1.2 子模块设计

**（1）环境检测子模块**

| 功能点 | 说明 |
|---|---|
| 操作系统检测 | 识别 Windows 10/11、macOS 12+、Ubuntu 20.04+/CentOS 7+，输出 OS 类型和版本 |
| Git 检测 | 检查 `git` 是否可用，获取版本号，检查全局配置（user.name、user.email） |
| Shell 版本检测 | Windows 检测 PowerShell 5.1+；macOS/Linux 检测 bash 3.2+ |
| 网络连通性 | 尝试访问 GitHub/GitLab 远程仓库（可选），超时 5 秒 |
| 已有安装检测 | 检查目标目录是否已存在 `.devflow/` 目录和 `version.json`，识别已安装版本 |

脚本入口：`scripts/detect-environment.ps1`（Windows）/ `scripts/detect-environment.sh`（macOS/Linux）

输出格式：结构化 JSON，便于后续步骤解析

```json
{
  "os": { "type": "windows", "version": "10.0.19045" },
  "git": { "installed": true, "version": "2.41.0" },
  "shell": { "type": "powershell", "version": "5.1.19041" },
  "network": { "reachable": true },
  "existing_install": { "found": false }
}
```

**（2）配置引导子模块**

| 功能点 | 说明 |
|---|---|
| 仓库地址输入 | 引导用户输入远程仓库 URL（GitHub/GitLab），支持从 Git remote 自动推断 |
| 分支策略选择 | 提供预设分支策略模板（GitFlow/Trunk-based/Custom），默认 GitFlow |
| 项目信息 | 项目名称、项目描述、默认开发分支名 |

交互方式：逐项问答，每项提供默认值，用户可跳过（使用默认值）

**（3）安装执行子模块**

| 功能点 | 说明 |
|---|---|
| 技能文件复制 | 将 skills/ 目录下所有技能文件复制到目标项目的 `.devflow/skills/` |
| 模板文件复制 | 将 templates/ 目录下所有模板文件复制到目标项目的 `.devflow/templates/` |
| 配置生成 | 基于用户输入生成 `.devflow/config.json` 和 `.devflow/state.json` |
| 版本写入 | 将 version.json 复制到 `.devflow/version.json` |

**（4）进度反馈子模块**

| 功能点 | 说明 |
|---|---|
| 步骤进度 | 显示当前执行步骤（如 `[3/5] 复制技能文件...`） |
| 百分比 | 整体安装进度百分比 |
| 当前操作 | 显示当前正在执行的具体操作 |

**（5）错误恢复子模块**

| 功能点 | 说明 |
|---|---|
| 备份已存在文件 | 安装前检测目标文件是否已存在，若存在则备份为 `.bak` 后缀 |
| 网络失败回退 | 网络不可达时跳过远程仓库验证步骤，使用本地文件安装 |
| 检测失败处理 | Git 未安装时提示安装但不阻塞（标记为警告），PowerShell/bash 版本不满足时报错终止 |
| 部分回滚 | 安装中断时清理已复制的文件，恢复到安装前状态 |

### 5.2 初始化增强模块（VR-002）

#### 5.2.1 模块概述

| 属性 | 值 |
|---|---|
| 模块 ID | M-INIT |
| 关联需求 | VR-002（P0） |
| 实现形式 | setup.ps1（Windows）+ setup.sh（macOS/Linux）+ devflow-init/SKILL.md 更新 |
| 依赖 | .devflow/config.json、.devflow/state.json、项目目录结构 |

#### 5.2.2 子模块设计

**（1）交互问答子模块**

| 功能点 | 说明 |
|---|---|
| 项目类型选择 | Web 应用 / API 服务 / 桌面应用 / 库/SDK / 其他 |
| 开发模式选择 | 瀑布式 / 敏捷 Scrum / 看板 / 其他 |
| 团队规模选择 | 个人 / 小团队（2-5）/ 中团队（6-15）/ 大团队（15+） |
| 编程语言选择 | 主要开发语言和框架 |

**（2）阶段推断子模块**

推断算法按以下信号源综合判断：

| 信号源 | 检测内容 | 阶段推断映射 |
|---|---|---|
| 目录结构 | 存在 `doc/requirements/` | 已进入或超过需求阶段 |
| 目录结构 | 存在 `doc/design/` | 已进入或超过设计阶段 |
| 目录结构 | 存在 `src/` 且有源代码 | 已进入或超过编码阶段 |
| 目录结构 | 存在 `tests/` | 已进入或超过测试阶段 |
| Git 分支 | 存在 `release/` 或 `main` 有 tag | 已进入或超过部署阶段 |
| 配置文件 | `.devflow/state.json` 存在且 current_stage 有值 | 直接读取 |
| 配置文件 | `package.json` / `pom.xml` / `go.mod` 存在 | 项目已初始化，推断最小阶段 |

推断优先级：`.devflow/state.json` > 目录结构 > Git 分支 > 默认值（Step 0）

**（3）配置生成子模块**

| 产出文件 | 内容 |
|---|---|
| `.devflow/config.json` | 分支策略、项目信息、编码约定、文档路径模板等 |
| `.devflow/state.json` | current_stage（推断结果）、completed_stages（已完成阶段数组）、last_updated |

### 5.3 质量检查模块（VR-011/012/013/005）

#### 5.3.1 模块概述

| 属性 | 值 |
|---|---|
| 模块 ID | M-QUALITY |
| 关联需求 | VR-011（P0）、VR-012（P0）、VR-013（P1）、VR-005（P1） |
| 实现形式 | scripts/ 下的 4 组 PowerShell/bash 脚本 |
| 依赖 | skills/、templates/、.devflow/config.json |

#### 5.3.2 子模块设计

**（1）格式检查子模块（VR-012）**

脚本：`scripts/check-format.ps1` / `scripts/check-format.sh`

| 检查项 | 规则 | 严重级别 |
|---|---|---|
| 文件编码 | UTF-8（无 BOM） | Error |
| 标题层级 | H1 唯一，H2/H3 层级正确 | Warning |
| 前置元数据 | 包含技能名称、版本、描述、适用阶段等字段 | Error |
| 章节结构 | 按 VR-012 规范要求的章节顺序排列 | Warning |
| 速查表格式 | L2 文件末尾包含 L3 速查表且格式符合规范 | Error |
| Markdown 语法 | 无裸 HTML、无断裂链接、表格格式正确 | Warning |

输出：JSON 格式的检查报告，包含 pass/warn/error 统计和每项检查的详情。

**（2）内容审查子模块（VR-011）**

脚本：作为 `check-format.ps1/sh` 的扩展模块

| 检查项 | 规则 | 严重级别 |
|---|---|---|
| 重复内容检测 | 多个技能文件中出现相同或高度相似的章节内容 | Warning |
| 矛盾内容检测 | 不同技能中对同一流程/规则/标准的描述冲突 | Error |
| 引用准确性 | 技能间引用的 L3 技能名称与实际文件名一致 | Error |
| 时效性检测 | 检测模板文件中是否有过时的技术栈引用或已弃用的工具 | Warning |

**（3）引用检查子模块（VR-013）**

脚本：`scripts/check-references.ps1` / `scripts/check-references.sh`

| 检查项 | 规则 | 严重级别 |
|---|---|---|
| 引用目标存在性 | L2 速查表中引用的 L3 技能文件实际存在 | Error |
| 引用路径正确性 | 技能文件中的相对路径引用可正确解析 | Error |
| 循环引用检测 | 不存在 L2 <-> L3 或 L3 <-> L3 的循环引用 | Error |
| 孤立技能检测 | 所有 L3 技能至少被一个 L2 速查表引用，无孤立技能 | Warning |
| 模板引用完整性 | 技能中引用的模板文件在 templates/ 中实际存在 | Error |

**（4）安装验证子模块（VR-005）**

脚本：`scripts/validate-install.ps1` / `scripts/validate-install.sh`

| 检查项 | 规则 | 严重级别 |
|---|---|---|
| 技能完整性 | L1（3 个）、L2（6 个）、L3（13 个）、Orchestrator（3 个）文件均存在 | Error |
| 模板可用性 | templates/ 下所有模板文件可读取且非空 | Error |
| 配置语法 | .devflow/config.json 为合法 JSON 且包含必要字段 | Error |
| 状态一致性 | .devflow/state.json 中 current_stage 为有效阶段值 | Warning |
| 脚本可执行性 | 安装/配置/更新脚本文件存在且非空 | Warning |
| version.json 一致性 | version.json 可解析且版本号格式正确 | Error |

### 5.4 新技能模块（VR-006/007/009）

#### 5.4.1 容灾备份技能增强（VR-006）

| 属性 | 值 |
|---|---|
| 关联需求 | VR-006（P1） |
| 技能文件修改 | `skills/L3/code-version-backup-management.md`（增强） |
| 新增模板 | `templates/dr-disaster-recovery-plan.md`、`templates/bk-backup-strategy-guide.md`、`templates/bk-multi-region-backup.md`、`templates/bk-recovery-drill.md`（共 4 个） |
| 集成方式 | 在 `code-version-backup-management.md` 中新增容灾备份章节，引用新增模板 |

技能内容增强方向：

- 新增多区域备份策略（跨可用区/跨地域）
- 新增灾难恢复计划模板（RTO/RPO 定义、恢复优先级）
- 新增恢复演练规程（定期演练流程、演练记录模板）
- 与现有 Git 备份策略互补，形成完整的备份与恢复体系

#### 5.4.2 安全开发全流程技能（VR-007）

| 属性 | 值 |
|---|---|
| 关联需求 | VR-007（P1） |
| 新增 L3 技能 | `security-design-review.md`、`secure-coding-standards.md`（共 2 个） |
| 新增模板 | `templates/sd-security-design-checklist.md`、`templates/sc-secure-coding-checklist.md`（共 2 个） |
| L2 速查表集成 | 内联到 `design-stage-execution.md`（安全设计审查）和 `coding-stage-execution.md`（安全编码规范） |
| 覆盖阶段 | Step 2 设计阶段 + Step 3 编码阶段 |

技能内容设计：

**security-design-review.md**：
- 安全架构设计原则（最小权限、纵深防御、零信任）
- 威胁建模方法（STRIDE 模型）
- 安全设计检查清单（认证、授权、数据保护、日志审计）
- 安全评审流程和交付物

**secure-coding-standards.md**：
- 通用安全编码规范（输入验证、输出编码、加密使用）
- 语言特定安全指南（涵盖主流编程语言）
- 安全编码检查清单（代码审查时的安全关注点）
- 安全测试集成（单元测试中的安全用例）

#### 5.4.3 容器化部署技能（VR-009）

| 属性 | 值 |
|---|---|
| 关联需求 | VR-009（P1） |
| 新增 L3 技能 | `container-deployment.md`（共 1 个） |
| 新增模板 | `templates/cd-container-deployment-guide.md`（共 1 个） |
| L2 速查表集成 | 内联到 `operations-stage-execution.md`（容器化部署） |
| 覆盖阶段 | Step 5 部署阶段 |

技能内容设计：

**container-deployment.md**：
- Docker 容器化最佳实践（镜像构建、多阶段构建、镜像优化）
- Kubernetes 部署规范（Deployment/Service/ConfigMap/Secret 编写规范）
- 容器安全配置（镜像扫描、非 root 用户、资源限制）
- 部署流水线集成（CI/CD 中的容器构建和推送流程）
- 与现有 `cicd-pipeline-management.md` 和 `observability-standards.md` 的协作关系

### 5.5 跨平台兼容模块（VR-015/016/017/018）

#### 5.5.1 模块概述

| 属性 | 值 |
|---|---|
| 模块 ID | M-PLATFORM |
| 关联需求 | VR-015（P1）、VR-016（P1）、VR-017（P2）、VR-018（P1） |
| 实现形式 | 脚本双平台实现 + 兼容性测试套件 |

#### 5.5.2 平台适配层设计

**抽象统一脚本接口**：

所有跨平台脚本遵循统一的接口规范：

| 接口要素 | 规范 |
|---|---|
| 命名 | 功能名称统一（如 `install.ps1` / `install.sh`） |
| 参数 | 位置参数和命名参数在两平台间保持语义一致 |
| 退出码 | 0 = 成功，1 = 一般错误，2 = 配置错误，3 = 环境不满足 |
| 输出格式 | stdout 为用户友好信息，结构化数据输出到 stderr（JSON 格式） |
| 日志级别 | 支持 `--verbose` / `--quiet` 参数控制输出详细程度 |

**平台差异处理策略**：

| 差异点 | Windows (PowerShell) | macOS/Linux (bash) | 统一策略 |
|---|---|---|---|
| 文件编码 | 默认 UTF-8 with BOM | UTF-8 without BOM | 检测并转换为 UTF-8 without BOM |
| 路径分隔符 | `\` | `/` | 脚本内部统一使用 `/`，输出时适配平台 |
| 环境变量 | `$env:VAR_NAME` | `$VAR_NAME` | 各自使用原生语法 |
| 文件操作 | `Copy-Item`、`New-Item` | `cp`、`mkdir` | 各自使用原生命令 |
| JSON 处理 | `ConvertFrom-Json` / `ConvertTo-Json` | `jq` 或原生解析 | bash 版不依赖 jq，使用原生字符串处理 |

#### 5.5.3 兼容性测试套件

针对 4 个 AI 编程平台的兼容性验证（VR-015/016/017）：

| 平台 | 验证范围 | 关联需求 | 优先级 |
|---|---|---|---|
| TRAE Work | 全流程验证（基准平台，已在 v2.3.2 验证） | — | — |
| Claude Code | 安装 -> 初始化 -> 版本规划 -> 需求分析 -> 设计 -> 编码 -> 测试 | VR-015 | P1 |
| Cursor | 安装 -> 初始化 -> 版本规划 -> 需求分析 -> 设计 -> 编码 -> 测试 | VR-016 | P1 |
| Codex CLI | 安装 -> 初始化 -> 基础功能验证 | VR-017 | P2 |

测试用例覆盖：

- 安装向导在各平台下的环境检测准确性
- 技能文件在各平台下的加载和解析正确性
- L2 编译层模式在各平台下的运行时行为一致性
- 脚本在各平台操作系统下的执行正确性（Windows/macOS/Linux）

---

## 6. 技术选型

### 6.1 技术选型总览

| 技术领域 | 选型 | 版本要求 | 选型理由 |
|---|---|---|---|
| 技能文件格式 | Markdown (SKILL.md) | — | 零依赖，AI 平台原生支持，人类可读可编辑 |
| Windows 安装/配置脚本 | PowerShell | 5.1+ | Windows 系统内置，无需安装额外工具 |
| macOS/Linux 安装/配置脚本 | bash | 3.2+ | Unix 系统内置，macOS 默认 shell |
| 检查/验证脚本 | PowerShell + bash | 同上 | 保持工具链一致性，零运行时依赖 |
| HTML 文档 | 纯静态 HTML + CSS | HTML5/CSS3 | 无构建工具依赖，浏览器直接打开 |
| 版本管理 | Git | 2.30+ | 行业标准，version.json 配合 Git tag |
| 版本信息存储 | JSON (version.json) | — | 机器可读可解析，单一来源原则 |

### 6.2 未选方案及理由

| 领域 | 未选方案 | 排除理由 |
|---|---|---|
| 安装脚本 | Node.js CLI | 需要用户预装 Node.js，增加安装前置条件 |
| 安装脚本 | Python 脚本 | 需要用户预装 Python，增加安装前置条件 |
| 检查脚本 | 专用 lint 工具 | 引入额外依赖，维护成本高 |
| 技能格式 | 结构化 YAML | 与现有 22 个 Markdown 技能不一致，迁移成本高 |
| HTML 文档 | 框架生成（React/Vue） | 需要构建工具，违反零依赖原则 |

---

## 7. 数据流设计

### 7.1 安装数据流

描述从用户触发安装到技能文件部署完成的完整数据流：

```
用户触发安装
    │
    ▼
version.json ──读取──> install.ps1 / install.sh
    │                        │
    │                   ┌────┴────┐
    │                   ▼         ▼
    │            环境检测     用户交互
    │           (detect-       (配置引导)
    │           environment)        │
    │                   │         │
    │                   ▼         ▼
    │              环境报告    用户配置
    │                   │         │
    │                   └────┬────┘
    │                        │
    ▼                   安装执行
skills/ ──────────────> 技能文件复制 ──> .devflow/skills/
templates/ ───────────> 模板文件复制 ──> .devflow/templates/
version.json ─────────> 版本文件复制 ──> .devflow/version.json
                        │
                        ▼
                   配置文件生成
                        │
                        ▼
              .devflow/config.json + state.json
                        │
                        ▼
                   安装验证 (validate-install)
                        │
                        ▼
                   安装完成报告
```

### 7.2 初始化数据流

描述用户触发项目初始化到配置文件生成的数据流：

```
用户触发初始化 (setup.ps1 / setup.sh 或 devflow-init 技能)
    │
    ▼
用户交互问答
    │
    ├──> 项目类型 (Web/API/桌面/库)
    ├──> 开发模式 (瀑布/敏捷/看板)
    ├──> 团队规模 (个人/小/中/大)
    └──> 编程语言
    │
    ▼
阶段推断
    │
    ├──> 检测 .devflow/state.json ──有值──> 直接读取
    ├──> 检测 doc/requirements/ ──存在──> 已过需求阶段
    ├──> 检测 doc/design/ ──存在──> 已过设计阶段
    ├──> 检测 src/ ──存在──> 已过编码阶段
    ├──> 检测 .devflow/config.json ──存在──> 读取配置
    └──> 默认值 ──无信号──> Step 0
    │
    ▼
配置生成
    │
    ├──> .devflow/config.json（分支策略、项目信息、编码约定）
    └──> .devflow/state.json（current_stage、completed_stages）
    │
    ▼
初始化完成
```

### 7.3 质量检查数据流

描述质量检查脚本扫描技能文件并输出报告的数据流：

```
触发检查（手动执行或 CI 集成）
    │
    ├──> check-format.ps1/sh     (VR-012)
    ├──> check-references.ps1/sh (VR-013)
    └──> validate-install.ps1/sh (VR-005)
    │
    ▼
扫描源数据
    │
    ├──> skills/L1/*.md       (3 个文件)
    ├──> skills/L2/*.md       (6 个文件)
    ├──> skills/L3/*.md       (10-13 个文件)
    ├──> skills/orchestrator/  (3 个 SKILL.md)
    ├──> templates/*.md        (19-25+ 个文件)
    └──> .devflow/config.json
    │
    ▼
执行检查规则
    │
    ├──> 格式检查（编码、标题、元数据、章节结构）
    ├──> 引用检查（目标存在、路径正确、循环引用、孤立技能）
    ├──> 内容审查（重复、矛盾、引用准确性）
    └──> 安装验证（完整性、可用性、配置语法）
    │
    ▼
检查报告（JSON 格式）
    │
    ├──> 总览（pass/warn/error 计数）
    ├──> 错误详情（文件路径、行号、问题描述、修复建议）
    └──> 修复优先级排序
```

### 7.4 版本更新数据流

描述用户触发版本更新时的数据流：

```
用户触发更新 (update.ps1 / update.sh)
    │
    ▼
读取当前版本
    │
    ├──> 本地 .devflow/version.json ──> current_version
    └──> 远程仓库 version.json ──> latest_version
    │
    ▼
版本比较
    │
    ├──> current == latest ──> 已是最新版本，退出
    └──> current < latest ──> 需要更新
    │
    ▼
备份当前安装
    │
    └──> .devflow/ 备份为 .devflow-backup-{version}/
    │
    ▼
执行更新
    │
    ├──> 技能文件更新（增量：仅覆盖变更文件）
    ├──> 模板文件更新（增量）
    ├──> 脚本文件更新（增量）
    └──> version.json 更新
    │
    ▼
更新验证 (validate-install)
    │
    ├──> 验证通过 ──> 更新成功，清理备份
    └──> 验证失败 ──> 自动回滚，恢复备份
    │
    ▼
更新完成报告
```

---

## 8. 关键设计决策

| 决策 ID | 决策内容 | 选项 | 选择 | 理由 |
|---|---|---|---|---|
| **D1** | 安装脚本语言 | A. PowerShell + bash（双平台原生脚本）<br>B. Node.js CLI<br>C. Python 脚本 | **A. PowerShell + bash** | 零运行时依赖，用户无需安装额外工具。PowerShell 5.1+ 为 Windows 10 内置，bash 3.2+ 为 macOS/Linux 内置。虽然需要维护两套脚本，但脚本逻辑简单，维护成本可控 |
| **D2** | 引用检查实现方式 | A. PowerShell/bash 脚本<br>B. Node.js 脚本<br>C. 专用 lint 工具<br>D. AI 辅助审查 | **A. PowerShell/bash 脚本** | 保持工具链一致性，不引入 Node.js 等外部依赖。引用检查逻辑（文件存在性、路径解析、循环检测）使用原生脚本能力即可实现 |
| **D3** | 新技能内容格式 | A. 沿用现有 Markdown 格式<br>B. 结构化 YAML 头 + Markdown 正文<br>C. 纯结构化 YAML | **A. 沿用现有 Markdown** | 保持与现有 22 个技能的格式一致性。VR-012 已制定统一的编写规范和模板，新技能遵循该规范即可。引入新格式会增加迁移成本和学习成本 |
| **D4** | L3 速查表维护方式 | A. 手动编写在 L2 文件末尾<br>B. 脚本自动从 L3 生成<br>C. 独立速查表文件，L2 引用 | **A. 手动编写在 L2 文件末尾** | 速查表不仅包含 L3 技能名称，还需包含适用条件、调用时机等上下文信息，这些需要人工编写。自动化生成无法提供有意义的上下文摘要。独立文件会增加加载层数，违反编译层模式 |
| **D5** | 快速入门指南格式 | A. 纯 Markdown<br>B. Markdown + HTML 双版本<br>C. 仅 HTML | **B. Markdown + HTML 双版本** | Markdown 版本方便在 AI 编程助手中直接阅读和引用；HTML 版本方便用户在浏览器中独立查看，提供更好的排版和视觉体验。HTML 为纯静态，无构建依赖 |
| **D6** | 配置文件格式 | A. JSON<br>B. YAML<br>C. TOML | **A. JSON** | JSON 为 PowerShell 和 bash 均原生支持的格式（PowerShell 有 ConvertFrom-Json，bash 可通过原生字符串处理解析），且与 version.json 格式保持一致 |
| **D7** | 跨平台脚本差异处理 | A. 单一脚本 + 平台判断分支<br>B. 独立脚本文件（.ps1 + .sh） | **B. 独立脚本文件** | 避免复杂的平台判断逻辑，PowerShell 和 bash 语法差异过大，混合编写降低可读性。独立文件便于各自平台的开发者独立维护和调试 |

---

## 9. 风险与缓解

### 9.1 设计阶段识别的技术风险

| 风险 ID | 风险描述 | 可能性 | 影响程度 | 关联需求 | 缓解措施 |
|---|---|---|---|---|---|
| R-ARCH-01 | 新增 3 个 L3 技能的速查表内联可能导致部分 L2 文件过长 | 中 | 低 | VR-006/007/009 | 控制 L3 速查条目在 5-8 行以内；超长速查表仅保留核心信息，详细内容引导至 L3 文件 |
| R-ARCH-02 | PowerShell 5.1 与 PowerShell 7.x 的兼容性差异导致脚本行为不一致 | 中 | 中 | VR-001/018 | 脚本仅在 PowerShell 5.1+ 兼容语法范围内编写，不使用 7.x 独有特性 |
| R-ARCH-03 | 不同 AI 平台（Claude Code/Cursor）的 SKILL.md 解析行为差异 | 中 | 中 | VR-015/016 | Phase 4 兼容性验证阶段逐平台测试；技能文件避免使用平台特有的 Markdown 扩展语法 |
| R-ARCH-04 | 引用检查脚本的循环引用检测算法在大规模技能集下的性能 | 低 | 低 | VR-013 | 当前技能集规模（25 个文件）下不存在性能问题；算法复杂度为 O(n)，即使扩展到 50+ 技能仍可接受 |
| R-ARCH-05 | 容灾备份技能内容的专业性不足（需要实际的灾备经验） | 中 | 中 | VR-006 | 参考 AWS/Azure/GCP 官方灾备文档作为内容基础；邀请有灾备经验的干系人评审 |
| R-ARCH-06 | 安全开发技能内容覆盖不全（OWASP Top 10 持续更新） | 中 | 中 | VR-007 | 基于 OWASP Top 10 和 CWE Top 25 编写；在文档中注明参考标准和版本，便于后续更新 |
| R-ARCH-07 | bash 脚本在 macOS（bash 3.2）和 Linux（bash 4+/5+）间的兼容性 | 中 | 低 | VR-018 | 限定使用 POSIX sh 兼容语法，不使用 bash 4+ 独有特性（如关联数组）；在 macOS 和 Linux 上分别测试 |

---

## 10. 开放问题

| 问题 ID | 问题描述 | 提出日期 | 关联需求 | 状态 | 计划解决时间 |
|---|---|---|---|---|---|
| O-ARCH-01 | Claude Code 的 SKILL.md 加载机制是否支持速查表模式？是否存在文件大小限制？ | 2026-07-02 | VR-015 | 待调研 | Phase 4 前 |
| O-ARCH-02 | Codex CLI 对 SKILL.md 的支持程度如何？是否需要降级适配？ | 2026-07-02 | VR-017 | 待调研 | Phase 4 前 |
| O-ARCH-03 | 快速入门指南 HTML 版本是否需要适配移动端（响应式设计）？ | 2026-07-02 | VR-003 | 待确认 | Phase 4 |
| O-ARCH-04 | version.json 是否需要增加 `compatiblePlatforms` 字段来显式标记各平台兼容性？ | 2026-07-02 | VR-015/016/017 | 待讨论 | Phase 2 |
| O-ARCH-05 | 安装向导是否需要支持"静默安装"模式（非交互式，通过配置文件传入参数）？ | 2026-07-02 | VR-001 | 待讨论 | Phase 2 |
| O-ARCH-06 | 安全开发技能是否需要按编程语言维度拆分为多个 L3 文件（如 `secure-coding-python.md`、`secure-coding-java.md`）？ | 2026-07-02 | VR-007 | 待讨论 | Phase 3 |

---

## 11. 变更记录

| 版本 | 日期 | 变更人 | 变更内容 | 变更类型 |
|---|---|---|---|---|
| 1.0 | 2026-07-02 | jerry.yu | 初始版本，创建系统架构设计文档 | 新建 |
