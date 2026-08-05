# DevFlow 系统架构设计文档 v2.8.5

> **文档类型**: 系统架构设计文档
> **版本**: v2.8.5
> **项目**: DevFlow
> **日期**: 2026-07-20
> **负责人**: PM-DevFlow-Dev

---

## 1. 概述

### 1.1 架构定位

DevFlow 是一个**基于技能的开发流程框架**，不是传统软件应用。其"系统"由以下组件构成：

| 组件 | 说明 | 技术形态 |
|------|------|---------|
| 技能文件（Skills） | L1/L2/L3 分层技能定义 | Markdown (.md) + 内联指令 |
| 文档模板（Templates） | 标准化的文档产出模板 | Markdown (.md) |
| 状态管理（State） | 项目当前阶段、版本、审计记录 | JSON (.devflow/state.json) |
| 配置管理（Config） | 项目级配置：远程仓库、命名等 | JSON (.devflow/config.json) |
| 全局台账（Ledger） | 技术债务总表、候选需求池 | Markdown (.md) |
| 自动化脚本 | 发布/备份等自动化工具 | PowerShell (.ps1) |
| 版本清单 | 版本号、元数据 | JSON (version.json) |

### 1.2 v2.8.5 架构变更范围

本版本不改变 DevFlow 整体分层架构，仅在**流程规范和工具**层面做增量完善：

| 变更类别 | 影响范围 | 变更类型 |
|---------|---------|:--------:|
| 技能文件流程修改 | 4 个 L2 技能 + 1 个 L3 技能 + 1 个模板技能 | 增量修改 |
| 全局文档新增 | 债务总表老化升级规则 | 内容补充 |
| 新脚本 | release.ps1 | 新文件 |
| 交互流程 | devflow-init 交互输入 | 逻辑修改 |

---

## 2. 分层架构

### 2.1 DevFlow 技能分层架构

```text
┌─────────────────────────────────────────────────────────┐
│                    L1 Orchestrator                      │
│     devflow-init · devflow-phase-manager                │
│     项目初始化 + 阶段状态机管理                          │
├─────────────────────────────────────────────────────────┤
│                    L2 Stage Execution                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │ Step 0   │ │ Step 1   │ │ Step 2   │ │ Step 3   │  │
│  │ version- │ │require-  │ │design-   │ │coding-   │  │
│  │ planning │ │ments-    │ │stage-    │ │stage-    │  │
│  │ -stage-  │ │-stage-   │ │-execution│ │-execution│  │
│  │ execution│ │execution │ │          │ │          │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
│  ┌──────────┐ ┌──────────┐                              │
│  │ Step 4   │ │ Step 5   │                              │
│  │ testing- │ │operations│                              │
│  │ -stage-  │ │-stage-   │                              │
│  │ execution│ │execution │                              │
│  └──────────┘ └──────────┘                              │
├─────────────────────────────────────────────────────────┤
│                 L3 Specialty Reference                  │
│  design-system · api-design · sql-database · redis ·    │
│  react-skills · vue-skills · ...30+ 专项技能            │
├─────────────────────────────────────────────────────────┤
│              共享基础设施（文档 + 配置 + 台账）           │
│  doc/ · .devflow/ · version.json                        │
└─────────────────────────────────────────────────────────┘
```

### 2.2 v2.8.5 修改的技能文件矩阵

| 技能文件 | 层级 | 当前路径 | 修改类型 | 对应需求 |
|---------|:----:|---------|:--------:|:-------:|
| coding-stage-execution.md | L2 | devflow-plugin/skills/L2/ | 增量：增加风险归集门禁 | R-01 |
| testing-stage-execution.md | L2 | devflow-plugin/skills/L2/ | 增量：增加风险归集门禁 | R-01 |
| design-stage-execution.md | L2 | devflow-plugin/skills/L2/ | 增量：增加风险归集门禁 | R-01 |
| operations-stage-execution.md | L2 | devflow-plugin/skills/L2/ | 增量：风险归集 + Release Checklist + Release Note 必出 | R-01, R-02, R-05 |
| version-planning-stage-execution.md | L2 | devflow-plugin/skills/L2/ | 增量：新增 0.0a 债务审查节点 | R-01 |
| code-logic-review.md | L3 | devflow-plugin/skills/L3/ | 增量：增加一致性审计维度 | R-04 |
| project-document-templates.md | L3 | devflow-plugin/skills/L3/ | 增量：Release Note 模板 | R-02 |
| devflow-init | L1 | devflow-plugin/ | 增量：交互输入逻辑 | R-03 |

---

## 3. 债务生命周期架构

### 3.1 核心数据流

```text
┌──────────────────────────────────────────────────────────────────┐
│                        债务生命周期闭环                           │
│                                                                  │
│  ┌───────────┐   方向一：流入    ┌──────────────┐                │
│  │ Step 0~5  │ ──────────────►  │  全局债务总表  │               │
│  │ 各阶段执行 │                  │ (22 条债务)    │               │
│  │ 发现风险   │ ◄──── 写入 ──── │  15字段标准   │               │
│  └───────────┘                  └──────┬───────┘                │
│                                        │                        │
│                              方向二：流出                        │
│                                        ▼                        │
│                               ┌──────────────┐                  │
│                               │  Step 0.0a   │                  │
│                               │  债务审查节点  │                  │
│                               ├──────────────┤                  │
│                               │ 1. 读取待偿还  │                 │
│                               │ 2. 老化升级    │                 │
│                               │ 3. 写入Backlog│                 │
│                               └──────────────┘                  │
└──────────────────────────────────────────────────────────────────┘
```

### 3.2 方向一：风险归集流入架构

**触发时机**：每个 L2 阶段技能的"审计移交"子步骤

**设计要点**：
1. 每个 L2 技能文件的"完成标准"或"阶段移交"章节插入门禁检查
2. 门禁逻辑：检查当前阶段是否发现 P1+ 风险 → 如有则检查债务总表是否有对应条目 → 未录入则退回补录
3. 写入格式：遵循债务总表 15 字段标准
4. 各阶段修改后的债务总表必须列入阶段输出文档清单，确保人工可审查增量变更

**涉及修改的文件**：
- `coding-stage-execution.md`：在"3.x 完成标准"前插入风险归集门禁
- `testing-stage-execution.md`：在"阶段移交"章节插入
- `design-stage-execution.md`：在"设计移交"章节插入
- `operations-stage-execution.md`：在"发布前检查"章节插入

### 3.3 方向二：债务审查流出架构

**触发时机**：Step 0 版本规划阶段的新的子步骤 0.0a

**设计要点**：
1. 在 `version-planning-stage-execution.md` 的"内部工作流"步骤序列中，在 0.0 之前插入 0.0a 节点
2. 0.0a 工作流：读取 `doc/version/global/DevFlow-技术债务总表.md` → 筛选"待偿还"和"挂起中"条目 → 执行老化升级 → 确定还债计划 → 写入本版本 Backlog
3. 老化升级规则：嵌入式规则定义（P3 挂起 >2 版本→P2, P2>2→P1, P1>2→P0）

---

## 4. 发布机制架构

### 4.1 Release Note + Changelog 架构

```text
doc/release/
├── DevFlow-Release-Note-v2.8.4.md    ← 单版本发布说明（Step 5 必出）
├── DevFlow-Release-Note-v2.8.5.md    ← 新版本追加（R-02 实现后）
└── README.md                          ← Changelog 汇总页
    └── 所有版本列表 + 链接
```

**设计要点**：
- Release Note 存放在 `doc/release/`，命名格式 `DevFlow-Release-Note-v{版本号}.md`
- Changelog 汇总页为 `doc/release/README.md`，列出所有版本及一句话摘要
- operations-stage-execution 的 Step 5 发布流程中增加"生成 Release Note"和"更新 Changelog"两个步骤

### 4.2 发布自动化架构

```text
发布流程（Step 5 内部）
├── 发布前检查（Release Checklist）
│   ├── 版本号确认
│   ├── Backlog 完成度
│   ├── 测试报告确认
│   └── 审计报告确认
├── 发布执行（release.ps1）
│   ├── 版本号校验
│   ├── Git Tag 创建
│   ├── Push origin
│   ├── Push backup
│   └── 版本一致性验证
├── 发布后验证（CI/CD 门禁）
│   ├── Tag 存在性校验
│   ├── 远程同步校验
│   ├── 备份同步校验
│   └── 版本号一致性校验
└── 发布后发布
    ├── 生成 Release Note
    └── 更新 Changelog
```

---

## 5. 文件系统架构

### 5.1 v2.8.5 新增/修改文件清单

```
新增文件：
  devflow-plugin/release.ps1                                ← R-06 发布脚本
  
修改文件（技能）：
  devflow-plugin/skills/L2/coding-stage-execution.md        ← R-01 风险归集门禁
  devflow-plugin/skills/L2/testing-stage-execution.md       ← R-01 风险归集门禁
  devflow-plugin/skills/L2/design-stage-execution.md        ← R-01 风险归集门禁
  devflow-plugin/skills/L2/operations-stage-execution.md    ← R-01+R-02+R-05
  devflow-plugin/skills/L2/version-planning-stage-execution.md ← R-01 0.0a 节点
  devflow-plugin/skills/L3/code-logic-review.md             ← R-04 一致性审计
  devflow-plugin/skills/L3/project-document-templates.md    ← R-02 Release Note 模板
  
修改文件（文档）：
  doc/version/global/DevFlow-技术债务总表.md               ← R-01 老化升级规则

修改文件（代码）：
  devflow-init                                              ← R-03 交互输入
```

---

## 6. 设计决策记录（ADR）

### ADR-001：债务生命周期规范实现方式

| 维度 | 内容 |
|------|------|
| **上下文** | 需要在 4 个 L2 技能文件中增加风险归集门禁，存在"集中式规范"和"分散式嵌入"两种方案 |
| **备选方案** | A：创建独立的 L3 "风险归集规范"技能文件，各 L2 统一引用<br>B：在 4 个 L2 技能文件中分别嵌入风险归集步骤（文本一致） |
| **决策** | 选择方案 B |
| **理由** | DevFlow 技能链深度限制为 2 层（L1→L2 直接执行，不额外链式调用 L3）。新创建 L3 风险归集规范会被深度规则限制，且跨版本债务审查是 L2 version-planning 的内在职责，不适合抽离。 |
| **后果** | 4 个 L2 技能文件需保持文本一致性，通过统一模板确保 |

### ADR-002：0.0a 节点位置

| 维度 | 内容 |
|------|------|
| **上下文** | 债务审查节点应放在 Step 0 的内部工作流何处 |
| **备选方案** | A：放在 0.0 收集候选需求之前<br>B：放在 0.0 与 0.1 之间（收集候选需求后、技术可行性粗筛前） |
| **决策** | 选择方案 A |
| **理由** | 债务审查是版本规划的"前置输入"——先知道必须还哪些债，再收集新的候选需求。这样还债计划可以与新需求统一做优先级排序。 |
| **后果** | version-planning-stage-execution 的内部工作流需新增 0.0a 节点，步骤序列变为 0.0a→0.0→0.1→0.2→0.3→0.4→0.5 |

### ADR-003：Release Note 模板位置

| 维度 | 内容 |
|------|------|
| **上下文** | Release Note 模板应该放在哪个技能文件中 |
| **备选方案** | A：放在 project-document-templates.md 中<br>B：放在 operations-stage-execution.md 中 |
| **决策** | 选择方案 A（模板） + B（必出声明） |
| **理由** | 模板内容和结构属于文档规范（project-document-templates 的职责），而"Step 5 必须输出 Release Note"属于流程门禁（operations-stage-execution 的职责）。两个文件各司其职。 |
| **后果** | 需要同时修改两个文件，保持模板结构和必出声明一致 |

### ADR-004：release.ps1 错误处理策略

| 维度 | 内容 |
|------|------|
| **上下文** | 自动化发布脚本发现错误时的行为 |
| **备选方案** | A：遇到错误自动回滚已执行的操作<br>B：遇到错误中止执行并提示，不自动回滚 |
| **决策** | 选择方案 B |
| **理由** | 发布操作不可逆（git push 后无法撤回），自动回滚可能造成更大问题。中止 + 提示 + 人工介入更安全。 |
| **后果** | 脚本需详细记录执行日志，便于人工排查失败点 |

---

## 7. 非功能设计说明

### 7.1 兼容性

| 设计项 | 策略 |
|--------|------|
| devflow-init | 检测已存在配置文件时跳过交互，保持向后兼容 |
| 技能文件修改 | 仅增量增加门禁步骤，不修改已有流程的执行顺序 |

### 7.2 可维护性

| 设计项 | 策略 |
|--------|------|
| 4 个 L2 风险归集 | 使用统一文本模板（见设计详细规格），确保修改一致性 |
| 老化升级规则 | 嵌入到 version-planning-stage-execution 中，作为内联业务规则 |

### 7.3 可观测性

| 设计项 | 策略 |
|--------|------|
| release.ps1 | 输出详细执行日志到控制台和日志文件 |
| 债务审查 | 0.0a 执行结果写入版本规划文档的"技术债务评估"章节 |

---

## 8. 部署与环境设计

| 设计项 | 内容 |
|--------|------|
| 部署方式 | Git tag + push（与现有流程一致） |
| 目标环境 | origin + backup 双仓库 |
| 兼容策略 | 完全向后兼容 |
| 回滚策略 | git revert tag + 重新发布 |
| 发布窗口 | Step 5 部署当天 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-20 | 初始创建，v2.8.5 系统架构设计 | PM-DevFlow-Dev |
