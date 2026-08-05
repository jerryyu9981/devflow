# DevFlow 系统架构设计文档 v2.9.0

> **文档类型**: 系统架构设计文档
> **版本**: v2.9.0
> **项目**: DevFlow
> **日期**: 2026-07-21
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
| 版本清单 | 版本号、元数据 | JSON (version.json) |

### 1.2 v2.9.0 架构变更范围

本版本不改变 DevFlow 整体分层架构，仅在**流程规范和规则定义**层面做增量完善：

| 变更类别 | 影响范围 | 变更类型 |
|---------|---------|:--------:|
| 技能文件流程规则新增 | 2 个 L2 技能 + 1 个 L1 技能 | 增量修改/新增规则 |
| 全局文档内容更新 | 债务总表关联 BL-ID 补全 | 内容更新 |
| devflow-init 增强 | 版本检测 + version.json 补全 | 逻辑新增 |

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
│  project-document-templates · ...30+ 专项技能           │
├─────────────────────────────────────────────────────────┤
│              共享基础设施（文档 + 配置 + 台账）           │
│  doc/ · .devflow/ · version.json                        │
└─────────────────────────────────────────────────────────┘
```

### 2.2 v2.9.0 修改的技能文件矩阵

| 技能文件 | 层级 | 路径 | 修改类型 | 对应需求 |
|---------|:----:|------|:--------:|:-------:|
| version-planning-stage-execution.md | L2 | devflow-plugin/skills/L2/ | 增量：新增还债配额规则 + 债务老化流程 + 来源检查清单 | R-01, R-02, R-05 |
| testing-stage-execution.md | L2 | devflow-plugin/skills/L2/ | 增量：新增覆盖率门禁 + E2E 验证规则 | R-03, R-04 |
| devflow-init SKILL.md | L1 | devflow-plugin/ | 增量：新增版本差异检测 + version.json 补全 | R-06, R-07 |

---

## 3. Step 0 流程设计（R-01, R-02, R-05）

### 3.1 0.0a 跨版本债务审查节点增强

当前 `version-planning-stage-execution.md` 已有 0.0a 节点定义。v2.9.0 增强以下内容：

**新增规则**（插入 0.0a 活动表）：

| 规则 | 内容 |
|:----:|------|
| 还债配额检查 | 计算还债占比 = 本版本还债项/总需求项，<15% 输出警告 + PM 批准理由 |
| 还债门禁 | >=15% → 通过；<15% → 记录 PM 理由 + 不阻断但需评审确认 |
| 连续 2 版本 <15% | 触发技术债务专项评审 |
| 老化升级确认 | 待偿还/挂起中条目遍历：P3>2→P2, P2>2→P1, P1>2→P0 |

**设计规格**：在 0.0a 活动表的"活动"列中追加第 5-6 行规则描述。

### 3.2 0.0 需求来源规范节点（R-05）

**新增子步骤设计**：在 0.0 活动表"活动"列追加来源检查清单描述。

**设计规格**：

```text
0.0 阶段新增"来源检查清单"确认步骤：
[0.0a] 输出来源检查清单（6 标准通道）
  ① 历史技术债（债务总表）
  ② 用户反馈（候选需求池）
  ③ 业务输入（用户直接输入）
  ④ 线上问题（候选需求池）
  ⑤ 竞品变化（用户直接输入）
  ⑥ 上版本遗留（前版本 Backlog 未完成项）
[0.0b] 逐一确认每个通道 → 输出"全部通道已检查"结论
```

---

## 4. Step 4 测试流程设计（R-03, R-04）

### 4.1 覆盖率门禁

在 `testing-stage-execution.md` 的"门禁检查"相关章节新增：

| 门禁项 | 规则 | 阻塞条件 | 通过条件 |
|:------:|:----:|:--------:|:--------:|
| 新代码行覆盖率 | Step 4 启动时检查 | <80% | >=80% |
| 门禁阻塞处理 | 输出未覆盖代码清单 → 要求补充测试 → 重测通过 | 覆盖率 <80% 且未补充 | 覆盖率 >=80% |

**设计规格**：在 testing-stage-execution.md 的 4.0 测试门禁阶段新增子节点。

### 4.2 E2E 集成验证

在 `testing-stage-execution.md` 新增 E2E 验证流程：

```text
E2E 验证流程（Step 4 测试阶段）
  ↓
[1] 读取本版本 E2E 验证场景列表
[2] 每个场景按定义执行
[3] 全部通过 → 输出验证通过报告
[4] 存在失败 → 记录失败场景 + 要求修复重测
```

**设计规格**：在 testing-stage-execution.md 中新增独立章节。

---

## 5. devflow-init 设计（R-06, R-07）

### 5.1 版本差异检测（R-07）

在 devflow-init 的"初始化流程"中新增步骤 1.5.5：

```text
1.5.5 版本差异检测
  ↓
[1] 读取 TRAE ~/.trae-cn/skills/devflow-plugin-config/version.json → installedVersion
[2] 读取 .devflow/state.json devflowVersion → projectVersion
[3] 语义版本比较
  ├── installed == project → consistent, no_action
  ├── installed > project  → auto_updated + 提示
  └── installed < project  → user_prompted + 警告
[4] versionCheck 写入 state.json
```

**ADR-001：自动更新 vs 询问用户**

| 维度 | 内容 |
|:----|:------|
| 上下文 | TRAE 已安装版本 > 项目记录版本时如何处理 |
| 备选方案 A | 自动更新 state.json（选此方案）— 降低用户操作成本，版本已安装只差记录 |
| 备选方案 B | 询问用户是否更新 — 更谨慎但增加交互步骤 |
| 备选方案 C | 不做任何处理 — 导致下次启动仍提示差异 |
| 决策 | 选 A，因为 installed > project 意味着 TRAE 端的版本已经就绪，记录落后是正常的 |
| 后果 | 用户可能不知已更新 → 需在提示中说明变更 |

### 5.2 version.json 字段补全（R-06）

在 devflow-init 的初始化流程中新增步骤 1.6 之后：

```text
1.6.1 version.json 字段补全
  ↓
[1] 检查 version.json 的 repository 和 homepage 字段是否为空
[2] 若为空 → 从 .devflow/config.json remote.origin 读取仓库地址
[3] repository.url = remote.origin
[4] repository.type = "git"
[5] homepage = remote.origin (去掉 .git 后缀)
[6] 写入更新后的 version.json
```

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-21 | 初始创建，v2.9.0 系统架构设计 | PM-DevFlow-Dev |
