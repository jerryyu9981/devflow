# DevFlow — 软件开发工程规范

> 文档类型：工程规范 / 技术培训文档
> 文档状态：持续维护
> 负责人：DevFlow 维护团队

## 修订历史

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|---------|
| v2.3.1 | 2026-07-01 | DevFlow 维护团队 | 完整回滚设计体系落地：code-version-backup-management 第六章扩展为 10 小节；cicd-pipeline-management 新增"回滚自动化"章节；operations-stage-execution 部署矩阵/强制规则增强；设计总览首页规范：prototype-coverage 新增 Step 1.5，design-stage-execution 矩阵增强；多环境备份配置（dev/test/pro/disaster）；setup.ps1/sh 自动推断 backup URL + 增强 Hook；版本号 v2.3.0→v2.3.1 |
| v2.3 | 2026-06-29 | DevFlow 维护团队 | 新增 L3 技能 `prototype-coverage`（前端原型覆盖检查：七步流程）和 `backend-coverage`（后端设计覆盖检查：五步流程）；`api-contract-management` 增加 API 契约对齐检查环节（前端页面清单↔后端 API 设计交叉验证）；L2 四个阶段技能集成引用；总技能 20→22 |
| v2.2 | 2026-06-29 | DevFlow 维护团队 | 新增 L3 技能 `api-contract-management`（API 契约管理）：覆盖前后端异构技术栈的 API 一致性全流程管控（FastAPI + Orval + Zod + MSW + Schemathesis + CI 校验）；L2 四个阶段技能集成引用；技能总数 15→20；安装脚本统一"先卸载后安装"两阶段模式；补齐 `code-version-backup-management` 注册；新增 `sync-skills.ps1` 独立同步工具 |
| v2.1 | 2026-06-26 | DevFlow 维护团队 | 统一命名 DevFlow；架构模板重构（单体/微服务/Agent/混合）；整合Superpowers+Gstack 5项能力（TDD铁律/完成前强制验证/文件范围保护/系统化调试/跨模型审查）；设计开发追溯矩阵归属修正；code-version-backup-management 重构（中文化/路径去硬编码/3种分支策略可配置/Git原生备份/TDD对齐/CI/CD集成）；cicd-pipeline-management 增加 backup-mirror job（GitHub Actions/GitLab CI）；Core Web Vitals FID→INP 更新；6 项 code-version-backup-management 内联修复（P0-P3）；L3 行数/字节数统计校准；5 个 L3 技能增加反向声明；version-planning-stage-execution 补充强制规则；6 个 L2 技能引用 project-role-management |
| v2.0 | 2026-06-24 | DevFlow 维护团队 | 全面更新：文档精简108→49（-55.6%）、角色管理去冗余（-41%）、新增设计开发追溯矩阵/需求设计追溯矩阵模板、性能工程补全至★★★★☆、追溯链闭环修复、需求来源扩展为12种、编译层模式优化 |
| v1.0 | 2026-06-22 | DevFlow 维护团队 | 初始版本：三层技能架构框架、15个核心技能定义、全流程覆盖16个工程领域 |

---

## 目录

1. [核心问题](#1-核心问题)
2. [三层架构总览](#2-三层架构总览)
3. [Layer 1：总控调度层](#3-layer-1总控调度层)
4. [Layer 2：阶段执行层](#4-layer-2阶段执行层)
5. [Layer 3：专项参考层](#5-layer-3专项参考层)
6. [专项技能的使用与扩展机制](#6-专项技能的使用与扩展机制)
7. [编译层模式：运行时如何工作](#7-编译层模式运行时如何工作)
8. [全流程输出文档清单](#8-全流程输出文档清单)
9. [完整工程能力覆盖总表](#9-完整工程能力覆盖总表)
10. [追溯链与闭环工程化机制](#10-追溯链与闭环工程化机制)
11. [维护责任矩阵](#11-维护责任矩阵)
12. [常见问题](#12-常见问题)

---

## 1. 核心问题

### 1.1 为什么需要三层架构？

AI 辅助开发面临三个核心矛盾：

| 矛盾 | 描述 | 三层架构的解决方案 |
|:----|:-----|:-----------------|
| **工程完整性 vs 上下文开销** | 15 个技能全部运行时加载需要 155KB+ 上下文 | 分层加载：L1+L2 约 112KB 覆盖全部执行规则，L3 按需加载 |
| **LLM 深度限制 vs 流程复杂度** | LLM 在超过 3 层嵌套调用时容易"失焦" | 编译层模式：运行时深度恒为 2 层（L1→L2） |
| **通用能力 vs 项目定制** | 内置技能覆盖通用场景，项目需要私有扩展 | L3 专项技能可自定义扩展，不影响 L1/L2 核心流程 |

### 1.2 设计原则

1. **运行时 2 层**：L1→L2 执行，L3 按需加载，LLM 推理深度不超过 2 层
2. **自包含执行单元**：L2 阶段技能内联 L3 核心规则速查表，运行时不依赖 L3 加载
3. **关注点分离**：L1 管流程调度，L2 管阶段执行，L3 管专项知识
4. **可维护性优先**：核心流程（L1+L2）不耦合具体技术栈，L3 可独立演进而不动流程

---

## 2. 三层架构总览

```
┌─────────────────────────────────────────────────────────────────┐
│                        Layer 1：总控调度                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │ development-    │  │ document-       │  │ role-           │  │
│  │ workflow        │  │ management      │  │ management      │  │
│  │ (流程总控)      │  │ (文档管理)      │  │ (角色管理)      │  │
│  └────────┬────────┘  └─────────────────┘  └─────────────────┘  │
│           │ 预加载（环境初始化时载入 L1+L2）                     │
├───────────┼─────────────────────────────────────────────────────┤
│           ▼                                                      │
│                        Layer 2：阶段执行                          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐ │
│  │Step 0    │ │Step 1    │ │Step 2    │ │Step 3    │ │Step 4  │ │
│  │版本规划  │→│需求分析  │→│架构设计  │→│编码开发  │→│测试    │→│
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └────────┘ │
│               ↓      ↓      ↓      ↓      ↓             ↓       │
│          ← 追溯闭环贯穿全流程 →                          ┌──────────┐│
│     RT-ID 需求←→设计←→开发←→测试←→审计               │Step 5    ││
│                                                       │部署运维  ││
│  ↑ 每个 L2 技能内部包含 L3 核心规则速查表（编译层    └──────────┘│
├─────────────────────────────────────────────────────────────────┤
│                        Layer 3：专项参考（按需加载）               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │ coding-      │  │ static-      │  │ logic-       │           │
│  │ conventions  │  │ quality-     │  │ review       │           │
│  │ (编码约定)   │  │ check        │  │ (逻辑审查)   │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │ cicd-        │  │ observability│  │ document-    │           │
│  │ pipeline     │  │ -standards   │  │ templates    │           │
│  │ (CI/CD)      │  │ (可观测性)   │  │ (文档模板)   │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │ api-contract │  │ version-     │  │ code-        │           │
│  │ -management  │  │ backup-mgmt  │  │ logic-       │           │
│  │ (API契约)    │  │ (版本备份)   │  │ review       │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

### 2.1 三层数据一览

| 层 | 角色 | 技能数 | 总行数 | 总字节 | 加载策略 |
|:--|:-----|:------:|:-----:|:-----:|:---------|
| **Layer 1** | 总控调度 | 3 | 1,134 | 98,083B | **运行时预加载** |
| **Layer 2** | 阶段执行 | 6 | 1,432 | 86,967B | **运行时预加载**（内联 L3 速查）|
| **Layer 3** | 专项参考 | 10 | 3,640 | 196,000B | **按需加载** |
| **合计** | — | **19** (22 含 orchestrator) | **6,206** | **381,050B** | — |

> 对比 v1.0（2026-06-22）：文档类型 108→49（-55.6%），角色管理 -41%。数据于 v2.3（2026-06-29）更新：新增 `prototype-coverage` + `backend-coverage` 注册，L3 技能数 8→10。

### 2.2 工程能力覆盖总图

```
18 个工程领域，18 个达到 ★★★★★ 完整覆盖

项目管理流程 ★★★★★    版本规划 ★★★★★    需求分析 ★★★★★
架构设计    ★★★★★    编码开发 ★★★★★    测试       ★★★★★
文档管理    ★★★★★    命名规范 ★★★★★    部署运维   ★★★★★
**CI/CD**   ★★★★★    **可观测性** ★★★★★  安全     ★★★★★
技术债务    ★★★★★    依赖管理 ★★★★★    角色管理   ★★★★★
**性能**    ★★★★☆    **API契约** ★★★★★  容灾备份 ☆☆☆☆☆
前端设计覆盖 ★★★★★    后端设计覆盖 ★★★★★
```

> API 契约领域 v2.2 新增 ★★★★★ 覆盖：FastAPI OpenAPI 自动生成、Orval 前端代码生成、Zod 运行时校验、MSW Mock 联调、Schemathesis 契约测试、CI 契约变更检测。前端设计覆盖/后端设计覆盖 v2.3 新增 ★★★★★：prototype-coverage 前端原型覆盖检查 + backend-coverage 后端设计覆盖检查

---

## 3. Layer 1：总控调度层

### 3.1 职责

Layer 1 是软件开发工程化的"操作系统内核"，不参与具体业务实现，只负责流程编排、文档规范和角色管理。

### 3.2 技能清单

| 技能 | 行数 | 核心定位 | 维护责任 |
|:----|:---:|:---------|:--------|
| `project-development-workflow` | 202 | 五步开发流程 + 三环境管理 + 14 条核心原则 + 6 阶段审计门禁 + Loop 闭环 | **不需要维护**（内置固定流程）|
| `project-document-management` | 686 | 49 种文档命名/存储/版本/权限/生命周期（v2.0精简版） | **需要维护**（文档类型可扩展）|
| `project-role-management` | 158 | 12 种角色定义 + 审批门禁 + 审计门禁 + Agent 命名规范（v2.0精简，-41%）| **不需要维护**（角色体系固定）|

### 3.3 核心流程

```
Step 0 (版本规划) → 评审通过 →
    ↓
Step 1 (需求分析) → 需求评审通过 → 需求评估审计 →
    ↓
Step 2 (架构设计) → 设计评审通过 → 需求架构对比审计（覆盖率≥95%） →
    ↓
Step 3 (编码开发) → 创建追溯矩阵 → 编码 → 静态检查 → 自测 → 逻辑审查 → 开发设计对比审计（覆盖率≥90%）→
    ↓
Step 4 (测试) → 14 类强制测试矩阵 → 测试回溯对比审计（按RT-ID逐项核对）→
    ↓
Step 5 (部署运维) → 19 类部署运维矩阵 → 性能回归门禁 → 运维审计 → 全流程闭环审计
    ↓
全流程完成 → 进入下一版本迭代
```

每个步骤之间有人工审批门禁，未通过退回上一阶段。

### 3.4 三环境管理（Dev/Test/Pro）

| 环境 | 端口范围 | 角色 | 文档特点 |
|:-----|:-------:|:-----|:---------|
| Dev | 3000 系列 | 开发创作 | 当前产出主目录 |
| Test | 4100 系列 | 验证测试 | 只读基线副本 |
| Pro | 5000 系列 | 生产运维 | 只读归档 + 运维操作 |

---

## 4. Layer 2：阶段执行层

### 4.1 职责

Layer 2 是软件开发工程化的"执行引擎"，每个阶段技能是一个自包含的执行单元，包含：
1. **入场门禁**：进入本阶段必须满足的前置条件
2. **规范矩阵**：本阶段必须覆盖的所有维度（表格形式）
3. **强制规则**：本阶段不可违反的约束
4. **输出要求**：本阶段必须产出的文档
5. **完成标准**：本阶段可以结束的条件
6. **L3 速查表**：内联的专项核心规则（编译层模式）

### 4.2 技能清单

| 技能 | 行数/字节 | 规范矩阵 | 强制规则 | 输出文档 | 维护责任 |
|:----|:--------:|:-------:|:-------:|:-------:|:--------|
| `version-planning-stage-execution` | 152/4,480B | 15 类规划 | 15 条内嵌 | 10 份 | **不需要维护** |
| `requirements-stage-execution` | 171/4,947B | **20** 类需求 | **8** 条 | **8** 份 | **不需要维护** |
| `design-stage-execution` | 195/7,079B | **17** 类设计 | **7** 条 | **11** 份 | **不需要维护** |
| `coding-stage-execution` | 455/13,554B | **20** 类开发 | **10** 条 | 2+4 子章节 | **不需要维护** |
| `testing-stage-execution` | 250/7,949B | **14** 类测试 | **8** 条 | **5** 份 | **不需要维护** |
| `operations-stage-execution` | 184/5,644B | **19** 类运维 | **8** 条 | **10** 份 | **不需要维护** |

> 合计：**1,407 行 / 43,653B** = 运行时核心上下文体量

### 4.3 编译层速查表详解

每个 L2 技能内部通过"编译层模式"内联了 L3 的核心规则。运行时只需加载 L2 即可获取足够信息。

#### 4.3.1 coding-stage-execution 内联的 L3 速查

| 来源 L3 | 内联规则 | 代表规则 |
|:--------|:---------|:---------|
| `project-coding-conventions` | API/错误码/日志/SQL/并发/配置 | API 响应格式、错误码 BIZ/SYS/AUTH/PERM/RATE/DB/EXT、三层约束禁止跨层 |
| `code-static-quality-check` | 12 类检查项 + P0-P3 分级 | P0=构建失败/密钥泄露须修复，P1=API不匹配须修复 |
| `code-logic-review` | 11 维审查 + 4 种结论 | 需求覆盖→设计一致→业务逻辑→...→可维护性 |
| `project-coding-conventions`（数据库性能）| 见下方新增 | EXPLAIN计划/N+1检测/批量操作/慢查询规则 |
| `frontend-performance`（速查引用）| Core Web Vitals + 加载策略 | FCP/LCP/CLS/INP（来自内置技能，注：Google 2024 年 3 月以 INP 替代 FID） |

> **数据库性能规则**为 v2.0 新增：禁止无索引全表扫描上线、禁止逐条INSERT大量数据、禁止长连接无超时、禁止不审查慢查询上线

#### 4.3.2 operations-stage-execution 内联的 L3 速查

| 来源 L3 | 内联规则 |
|:--------|:---------|
| `cicd-pipeline-management` | 五阶段流水线、质量闸门（覆盖/安全/性能）、部署策略、**性能基线管理（v2.0 新增）**|
| `observability-standards` | 结构化日志、RED 指标(Rate/Errors/Duration)、告警 P0-P3 级别 |

> **性能基线管理** v2.0 新增：新服务首个版本压测 3 次取中位数作为基线；P50 +20% 警告 / P99 +30% 阻断 / 吞吐-20% 阻断

#### 4.3.3 design-stage-execution 内联的 L3 速查

| 来源 L3 | 内联规则 |
|:--------|:---------|
| `observability-standards` | 14 种关键指标、OTLP + W3C TraceContext、生产采样 10%/错误 100%、6 个必备 Dashboard |

---

## 5. Layer 3：专项参考层

### 5.1 职责

Layer 3 是软件开发工程化的"知识库"，提供完整的专项知识、模板细节和最佳实践。运行时不被预加载，**仅在需要完整细节时显式请求加载**。

### 5.2 技能清单

| 技能 | 行数/字节 | 核心定位 | 维护责任 |
|:----|:--------:|:---------|:--------|
| `project-coding-conventions` | 337/7,260B | 后端分层 / 错误处理 / 日志 / API / 注释 / 数据库 / 前端 / 并发 / 配置 / 命名 + 依赖管理 + **数据库性能（v2.0 新增）**| **不需要维护** |
| `code-static-quality-check` | 142/5,066B | 12 类检查矩阵 + P0-P3 严重级别 + 工具选择 | **不需要维护** |
| `code-logic-review` | 344/7,331B | 11 个审查维度 + 4 种审查结论 + 7 条反模式 | **不需要维护** |
| `cicd-pipeline-management` | 275/6,018B | 五阶段流水线 + 8 个质量闸门 + **性能基线管理（v2.0）**+ 部署策略 | **不需要维护** |
| `observability-standards` | 295/8,642B | 三大支柱 + RED+USE + 14 种关键指标 + 6 个 Dashboard | **不需要维护** |
| `api-contract-management` | 684/16,500B | **（v2.2 新增）** API 契约全流程管控：OpenAPI 设计规范、Orval 代码生成、Zod 运行时校验、MSW Mock、Schemathesis 契约测试、CI 变更检测、7 种常见陷阱 | **不需要维护** |
| `prototype-coverage` | 270/7,800B | **（v2.3 新增）** 前端原型覆盖检查：页面清单→状态覆盖→原型走查→用例演练→交互标注→测试预映射→覆盖报告 | **不需要维护** |
| `backend-coverage` | 268/7,600B | **（v2.3 新增）** 后端设计覆盖检查：API契约→数据模型对齐→状态机→安全设计→测试预映射 | **不需要维护** |
| `project-document-templates` | 585/8,677B | **18 个**文档模板（v2.0 新增：需求追溯矩阵/需求设计追溯矩阵/设计开发追溯矩阵）| **需要维护**（模板可扩展）|
| `code-version-backup-management` | 200/5,300B | 分支策略可配置 / Git 原生备份 / TDD 对齐 / CI/CD 集成 | **不需要维护** |

> 合计：**3,400 行 / 77,628B** = 按需加载时全部加载的额外上下文（v2.3 更新：新增 prototype-coverage + backend-coverage）

### 5.3 文档模板覆盖（18 个模板）

| 阶段 | 模板文档 | 说明 |
|:-----|:---------|:-----|
| Step 0 | 单版本规划文档 | 10 章节结构 |
| Step 1 | 开发需求文档 | 12 章节结构 |
| Step 2 | 系统架构设计文档 | **按架构风格分支**：通用章节(8) + 单体附加(3)/微服务附加(6)/Agent附加(7)/混合附加(4) 按需选择；含架构风格决策矩阵 |
| Step 1 | **需求追溯矩阵**（v2.0 新增） | **10 列**：RT-ID/版本目标/Backlog/需求ID/描述/验收标准/优先级/来源(12种)/需求池项/技术债务ID |
| Step 2 | **需求设计追溯矩阵**（v2.0 新增） | 9 列 + 覆盖率统计 + FULL/PARTIAL/NOT-COVERED/NA 覆盖类型 |
| Step 3 | DevLogReport | 开发日志主文件 |
| Step 4 | 测试报告 | 含需求追溯覆盖检查（RT-ID逐行核对）|
| Step 3 | **设计开发追溯矩阵**（v2.0 新增） | 8 列 + 状态机 + 7 章节完整模板 |
| Step 5 | 发布计划 / 部署执行记录 / 回滚预案 / 运维手册 / 发布复盘报告 | 各 6-10 章节结构 |
| 审计 | 需求评审记录 / 设计评审记录 | 各 6-8 章节结构 |

---

## 6. 专项技能的使用与扩展机制

### 6.1 技能速查映射表

每个 L2 阶段技能内部包含一个技能速查映射表，以单行文本列出该阶段可能涉及的所有专项技能。这是编译层模式的核心——运行时 LLM 根据这条映射就知道遇到某类问题该调用哪个技能。

**6 个阶段技能速查映射一览：**

#### Step 1 需求阶段

```
流程/门禁 -> workflow
文档 -> doc-management
版本输入 -> version-planning
角色 -> role-management
发散调研 -> brainstorming / research / consulting
写作 -> doc-writing-guide / doc-coauthoring
原型 -> prototyping / ui-ux-pro-max
可访问性 -> accessibility
API -> api-design
数据 -> sql-database / mongodb
安全 -> security-best-practices
性能/前端体验 -> frontend-performance / web-design-guidelines
命名 -> universal-naming-conventions
衔接设计 -> design-stage-execution
衔接测试 -> testing-stage-execution
```

#### Step 2 设计阶段

```
流程/门禁 -> workflow
文档 -> doc-management
角色 -> role-management
API设计 -> api-design
API契约 -> api-contract-management
UI/UX -> ui-ux-pro-max / frontend-design / prototyping
Figma -> figma / figma-integration
设计系统 -> design-system
前端架构 -> react-skills / vue-skills
后端 -> nodejs-backend / python-backend
Agent -> llm-integration / agent-framework-*
MCP -> mcp-builder
数据 -> sql-database / mongodb
缓存消息 -> redis / rabbitmq / kafka
安全 -> security-best-practices
性能 -> frontend-performance
可访问性 -> accessibility / web-design-guidelines
部署 -> docker
命名 -> universal-naming-conventions
```

#### Step 3 编码阶段

```
流程/门禁 -> workflow
文档 -> doc-management
规划 -> writing-plans / executing-plans / tdd
静态检查 -> code-static-quality-check
逻辑审查 -> code-logic-review
版本/提交 -> code-version-backup-management / git-commit
命名 -> universal-naming-conventions
API -> api-design
API契约 -> api-contract-management
React -> react-skills / react-best-practices / composition-patterns
前端 -> frontend-design
Vue -> vue-skills
Node -> nodejs-backend
Python -> python-backend
Agent -> llm-integration / agent-framework-*
数据库 -> sql-database / mongodb
Redis -> redis / redis-development
消息 -> rabbitmq / kafka
安全 -> security-best-practices
UI/UX可访问 -> web-design-guidelines / accessibility
性能 -> frontend-performance / browser-devtools
Web验证 -> webapp-testing
Docker -> docker
```

#### Step 4 测试阶段

```
流程/门禁 -> workflow
文档 -> doc-management
入场移交 -> coding-stage-execution / logic-review
E2E -> e2e-test-gen
Web验证 -> webapp-testing
探索测试 -> dogfood
浏览器诊断 -> browser-devtools
API契约 -> api-contract-management
安全 -> security-best-practices
可访问性 -> accessibility / web-design-guidelines
前端性能 -> frontend-performance / react-best-practices
React -> react-skills / react-best-practices
后端 -> nodejs-backend / python-backend
Vue -> vue-skills
导航 -> code-review-navigation
TDD -> test-driven-development
SQL/Mongo -> sql-database / mongodb
Redis -> redis / redis-development
消息 -> rabbitmq / kafka
容器 -> docker
版本/分支 -> code-version-backup-management / git-commit
```

#### Step 5 部署运维阶段

```
流程/门禁 -> workflow
文档 -> doc-management
角色 -> role-management
测试入场 -> testing-stage-execution
设计输入 -> design-stage-execution
开发输入 -> coding-stage-execution
版本/回滚 -> code-version-backup-management / git-commit
GitHub -> gh-cli
容器 -> docker
Pages -> iga-pages / byted-bp-cdn-pagesdeploy
Web验证 -> webapp-testing / browser-devtools
API -> api-design
API契约 -> api-contract-management
数据 -> sql-database / mongodb
缓存消息 -> redis / rabbitmq / kafka
性能 -> frontend-performance
安全 -> security-best-practices
命名 -> universal-naming-conventions
```

### 6.2 运行时使用方式

当 LLM 在执行某个阶段时遇到特定领域的问题，运行时的处理流程：

```
1. LLM 读取 L2 技能内联的技能速查映射表
2. 看到 "API -> api-design" 或 "E2E -> e2e-test-gen" 等映射
3. 调用 Skill 工具，加载对应的专项技能
4. 专项技能提供该领域的最佳实践和规则
5. 领域任务完成后，LLM 回到 L2 主控流程继续执行
```

**专项技能被调用时的约束**（由专项技能反向声明规则强制）：

| 规则 | 说明 |
|:-----|:------|
| 只负责自身领域 | 专项技能不宣布整个阶段完成 |
| 专项审查不能替代阶段评审 | 通过专项审查不等同于通过 Step 2/3 的门禁 |
| P0/P1 缺口必须本阶段内修复 | 不能留给下一阶段 |
| 影响其他阶段的事项必须移交 | 记录在对应的移交文档中 |

### 6.3 如何新增项目自定义技能

```text
1. 创建技能目录
   c:\Users\zkja\.trae-cn\skills\my-custom-skill\

2. 编写 SKILL.md
   格式：YAML frontmatter（name + description）+ Markdown 正文
   内容：定位、触发条件、核心规则表格、使用说明
   参考：已有任何 SKILL.md 作为模板

3. 在对应的 L2 阶段技能的技能速查映射中增加引用
   例如在 coding-stage-execution 的速查行末尾追加：
   自定义API规范 -> my-custom-skill
   用空格与前一映射分隔

4. 在 project-document-management 中增加文档类型（如需要）
   在命名表、目录树、权限矩阵中增加新文档定义

5. 在 project-document-templates 中增加模板结构（如需要）
   补充新文档的最小章节结构定义
```

### 6.4 内置技能 vs 项目自定义技能

| 维度 | 内置技能 | 项目自定义技能 |
|:-----|:---------|:--------------|
| 维护责任 | 不需要团队维护（13个） | 团队自行维护 |
| 存储位置 | `c:\Users\zkja\.trae-cn\skills\` | 同上目录 |
| 速查映射 | 已预装在 L2 中 | 需手动在对应 L2 中追加 |
| 文档定义 | 已在 doc-management 中定义 | 需手动补充到命名表和权限矩阵 |
| 模板定义 | 已在 doc-templates 中定义 | 需手动补充章节结构 |
| 运行时加载 | 按需自动加载 | 按需自动加载（无区别） |

> **注意**：本报告中的 L3 专项技能（如 `react-skills`、`api-design`、`docker` 等）是 TRAE 平台内置的通用开发技能。15 个核心技能控制的是工程化流程；内置技能提供的是领域知识。两者在运行时通过技能速查映射无缝协作。

---

## 7. 编译层模式：运行时如何工作---

## 7. 编译层模式：运行时如何工作

### 6.1 核心概念

编译层（Compiled Layer）模式借鉴了编译器原理中的概念：L2 阶段技能在"编译时"将 L3 的核心规则"内联"到自身，运行时 L2 是自包含的执行单元。

```
传统模式（v0.x）：              编译层模式（v2.0）：

L1：总控                       L1：总控            
 ↓ 3层                         ↓ 2层（恒等深度）
L2：阶段主控                    L2：阶段主控（内联 L3 速查）
 ↓ 4层（伪嵌套）                     ↑ L3 核心规则已编译到 L2 内部
L3：专项技能（被反引号诱导加载）   │
 ↓ 反向引用                      L3：专项技能（按需加载）
L2 回引（5层回环）                   ↑ 仅在需要完整细节时加载
```

### 6.2 运行时执行示例（编码阶段）

```
用户：实现用户注册功能

→ 加载 workflow（L1 预加载）→ 确定当前在 Step 3 编码阶段
→ 加载 coding-stage-execution（L2 预加载）

┌──────────────────────────────────────────────────────────┐
│ coding-stage-execution 内联了：                           │
│   - API 响应格式：{code:0, data, traceId}                │
│   - 错误码前缀：BIZ/SYS/AUTH/PERM/RATE/DB/EXT           │
│   - 日志级别：DEBUG/INFO/WARN/ERROR                     │
│   - 三层约束：Controller→Service→Repository              │
│   - SQL：参数化查询/禁止 SELECT* / 索引检查 / N+1检测   │  ← v2.0 新增
│   - 静态检查 12 类 + P0-P3 分级                         │
│   - 逻辑审查 11 维 + 4 种结论                          │
│   → 以上信息足够完成编码任务，无需加载 L3               │
└──────────────────────────────────────────────────────────┘

→ LLM 根据内联规则生成代码
→ 执行后端性能自测（CPU profile / 内存 profile）           ← v2.0 新增
→ 本地运行静态检查
→ 完成编码，进入 code-logic-review
```

### 6.3 上下文节约效果

| 指标 | v1.0（改动前） | v2.0（改动后） | 变化 |
|:-----|:------|:------|:----:|
| L2 协作表体积 | 5,313B（15-34 行表格） | ~0B（1 行文本映射） | **-100%** |
| L3 被触发加载风险 | 高（反引号+表格诱导） | 低（纯文本映射） | **显著降低** |
| 运行时总深度 | 3-4 层 | **2 层**（恒等） | — |
| project-role-management | 294 行/10,375B | 158 行/6,082B | **-41%** |
| 输出文档类型 | 108 份 | **49 份**（精简优化） | **-55.6%** |

---

## 8. 全流程输出文档清单

> 所有文档均使用 `{项目名}-{文档名}[-v{版本号}].md` 格式，遵循 `project-document-management` 的命名/路径/权限规则

### Step 0 版本规划 — 10 份

**全部版本（5份，长期维护，无版本号）**：`版本规划总纲` / `版本迭代路线图` / `候选需求池` / `版本范围变更总记录` / `版本发布策略总则`

**单版本（5份独立）**：

| 文档 | 说明 |
|:-----|:------|
| `{项目名}-单版本规划文档-v{版本号}.md` | **主文件**。含子章节：版本依赖清单/版本风险清单/成功指标/发布策略草案/范围变更记录/技术债务清单 |
| `{项目名}-Phase迭代计划-v{版本号}.md` | 独立 |
| `{项目名}-本版本Backlog-v{版本号}.md` | 含子章节：版本优先级评估记录 |
| `{项目名}-版本规划评审记录-v{版本号}.md` | 独立 |

### Step 1 需求分析 — 8 份

| 文档 | 说明 |
|:-----|:------|
| `{项目名}-开发需求文档-v{版本号}.md` | **主文件**。10+ 类需求合入 |
| `{项目名}-用户需求说明书-v{版本号}.md` | 含：用户场景/用户故事/业务流程 |
| `{项目名}-UIUX需求说明-v{版本号}.md` | 含：原型草案 |
| `{项目名}-需求追溯矩阵-v{版本号}.md` | **10 列**：RT-ID/版本目标/Backlog/需求ID/描述/验收标准/优先级/来源/需求池项/技术债务ID |
| `{项目名}-需求评审记录-v{版本号}.md` | 独立 |
| `{项目名}-需求基线及设计移交说明-v{版本号}.md` | 代替原 2 份 |
| `{项目名}-需求来源与干系人-v{版本号}.md` | 代替原 2 份 |
| `{项目名}-需求评估报告-v{版本号}.md` | 固定存放 `doc/audit/assessment` |

### Step 2 架构设计 — 11 份

| 文档 | 说明 |
|:-----|:------|
| `系统架构设计文档`（总体无版本号/版本带版本号）| — |
| `Agent架构设计文档` | 涉及Agent时 |
| `前端架构设计文档` | 涉及前端时 |
| `UI设计文档` | 含：原型设计说明/设计系统说明 |
| `Figma设计交付说明` | 使用Figma时 |
| `API接口设计文档` | 涉及接口时 |
| `数据库设计文档` | 含：数据字典 |
| **`非功能设计说明`** | **v2.0 3合1**（安全+性能+可观测性）|
| `缓存与消息设计说明` | 涉及缓存/队列时 |
| `部署架构草案` | — |
| `设计评审记录` | **主文件**。含：入场检查/需求设计追溯矩阵/审计移交/测试移交 |
### Step 3 编码开发 — 2 份（含设计开发追溯矩阵） + 4 份可选子章节

| 文档 | 说明 |
|:-----|:------|
| `{项目名}-DevLogReport-v{版本号}.md` | **强制性主文件**。4 个子章节：静态质量检查/逻辑审查/审计移交/测试移交 |
| `{项目名}-设计开发追溯矩阵-v{版本号}.md` | **强制性**。编码前创建，编码中更新 |

### Step 4 测试 — 3 份 + 2 份专项可选

| 文档 | 说明 |
|:-----|:------|
| `{项目名}-测试报告-v{版本号}.md` | **主文件**。含：测试计划/API测试/集成测试/合规/UAT/覆盖率/缺陷/跳过/E2E/RT-ID需求覆盖检查 |
| `{项目名}-测试用例-v{版本号}.md` | 需标注 RT-ID |
| `{项目名}-测试回溯对比审计报告-v{版本号}.md` | 固定存放 `doc/audit/verification` |
| `{项目名}-性能测试记录-v{版本号}.md` | 专项时独立 |
| `{项目名}-可访问性测试记录-v{版本号}.md` | 专项时独立 |

### Step 5 部署运维 — 10 份

| 文档 | 说明 |
|:-----|:------|
| `发布计划` | 含：入场检查/发布版本记录 |
| **`部署执行报告`** | **v2.0 5合1**（部署+环境+执行+构建+CICD）|
| **`数据运维说明`** | **v2.0 2合1**（迁移+缓存运维）|
| **`回滚方案`** | **v2.0 2合1**（预案+演练记录）|
| **`上线检查报告`** | **v2.0 5合1**（验证+监控+告警+安全+性能）|
| `运维手册` | 含：运维移交清单 |
| `发布复盘报告` | — |
| `运维审计报告` | 固定 `doc/audit/comprehensive` |
| `全流程闭环审计报告` | 固定 `doc/audit/comprehensive` |
| `问题跟踪记录` | 含：变更请求；跨阶段 |

**汇总**：**49 份文档**（13 份主文件 + 36 份独立/可选文档，原 108 份精简合并后）

---

## 9. 完整工程能力覆盖总表

| # | 领域 | 覆盖度 | 核心技能 | 说明 |
|:-:|:-----|:-----:|:---------|:-----|
| 1 | 项目管理流程 | ★★★★★ | workflow | 5 步流程 + 三环境 + 14 条核心原则 + 6 阶段审计 + Key Principles |
| 2 | 版本规划 | ★★★★★ | version-planning | 15 类规划矩阵 + 全部/单版本分离 + 8 条反模式 + 9 条完成标准 |
| 3 | 需求分析 | ★★★★★ | requirements | 20 类需求规范矩阵 + 8 条强制规则 + 8 份输出 + 12 种来源定义 |
| 4 | 架构设计 | ★★★★★ | design + 追溯矩阵 | 17 类设计规范 + 7 条强制规则 + 需求设计追溯矩阵(覆盖率≥95%) |
| 5 | 编码开发 | ★★★★★ | coding + coding-conventions + static + logic-review | 20 类开发规范 + 10 条强制规则 + 11 条反模式 + 三层质量门禁 + 技术债务 |
| 6 | 测试 | ★★★★★ | testing | 14 类强制测试矩阵 + 8 条执行规则 + 9 条反模式 + **RT-ID逐项核对** |
| 7 | 部署运维 | ★★★★★ | operations + 部署执行报告 | 19 类部署运维矩阵 + 8 条强制规则 + 9 条完成标准 |
| 8 | **CI/CD** | ★★★★★ | cicd-pipeline-management | 五阶段流水线 + 8 个质量闸门 + **性能基线管理** + 部署策略 |
| 9 | **可观测性** | ★★★★★ | observability-standards | 三大支柱(日志/指标/追踪) + RED+USE + 14 种关键指标 + 6 个 Dashboard |
| 10 | 安全 | ★★★★★ | security-best-practices | 代码级审查 + 依赖漏洞扫描 + 密钥泄露检测 + SAST |
| 11 | 文档管理 | ★★★★★ | doc-management + doc-templates | 49 种文档命名 + 三环境目录 + 权限矩阵 + **18 个模板** |
| 12 | 命名规范 | ★★★★★ | universal-naming + coding-conventions | 多语言命名 + API/表名/环境变量/配置模板 |
| 13 | 角色管理 | ★★★★★ | role-management（v2.0精简） | 12 角色 + 审批门禁 + 审计门禁 + Agent 命名规范 |
| 14 | **技术债务** | ★★★★★ | version-planning + coding | 版本规划 15-20% 容量偿还 + 编码记录 + P0-P3 分类 |
| 15 | **依赖管理** | ★★★★★ | coding-conventions + cicd | 4 项引入检查 + 每次版本审计 + Critical 漏洞阻断 |
| 16 | **性能** | ★★★★☆ | **frontend-performance + 6 项增强（v2.0）** | **后端压测标准(P50/P99/基线80%) + 数据库性能规则(EXPLAIN/N+1/慢查询) + 性能基线管理 + CPU/memory profile** |
| 17 | **API 契约** | ★★★★★ | **api-contract-management（v2.2 新增）** | **OpenAPI 契约设计 + Orval 代码生成 + Zod 运行时校验 + MSW Mock + Schemathesis 契约测试 + CI 变更检测 + 5 种技术栈适配** |
| 18 | 容灾备份 | ☆☆☆☆☆ | — | P2 级缺口，待补充 |

> **v2.0 性能升级**：从 ★★★☆☆ 升至 ★★★★☆。覆盖需求阶段 SLA/SLO 推荐 → 设计阶段容量规划 → 编码阶段数据库性能规则 + CPU/memory profile → 测试阶段 P50<目标/P99<目标/吞吐≥基线80% → CI/CD 性能基线管理 → 部署阶段 Core Web Vitals + RED 指标

---

## 10. 追溯链与闭环工程化机制

### 9.1 全阶段追溯链

```
Step 1（需求阶段）
  └── 需求追溯矩阵 (RT-001 ~ RT-00N)
        版本目标 → Backlog → 需求ID → 验收标准
        10列：含需求池项(来源) + 技术债务ID
        12种来源：user/business/ops-data/prod-issue/competitive/compliance/security/tech-debt/tech-evolution/internal-improvement

Step 2（设计阶段）
  └── 需求设计追溯矩阵 (DT-ID 引用 RT-ID)
        审计门禁：覆盖率 ≥ 95%
        覆盖类型：FULL / PARTIAL / NOT-COVERED / NA

Step 3（编码阶段）
  └── 设计开发追溯矩阵 (TD-ID 引用设计项)
        状态机：PENDING → IN_PROGRESS → DONE → VERIFIED → BLOCKED/CANCELLED
        审计门禁：开发设计对比审计（事后偏差检测）

Step 4（测试阶段）
  ├── 测试用例标注 RT-ID → 按需求追溯矩阵逐项覆盖
  └── 测试回溯审计：输入需求追溯矩阵，按 RT-ID 逐项核对
        审计门禁：需求测试覆盖 100%

Step 5（部署阶段）
  └── 全流程闭环审计综合检查
```

> **追溯链完整性**：每个 RT-ID 从需求创建到测试验证的全路径可追踪，阶段衔接处都有事前指引（追溯矩阵）+ 事后审计（对比审计）双重保障。

### 9.2 审计闭环

| 阶段 | 审计类型 | 退回条件 |
|:-----|:---------|:---------|
| Step 0 | 版本规划评审 | 目标/范围/优先级/风险未明确 |
| Step 1 | 需求评审 + 需求评估 | P0/P1 需求缺失、追溯不完整 |
| Step 2 | 需求架构对比审计 | 覆盖率 < 95%，重大设计偏差 |
| Step 3 | 开发设计对比/UI需求对比 | 覆盖率 < 90%，P0/P1 未闭环 |
| Step 4 | **测试回溯对比审计（按RT-ID核对）** | P0/P1 问题未闭环 |
| Step 5 | 运维审计 + 全流程闭环审计 | 发布/验证/监控/回滚/移交/复盘证据不完整 |

### 9.3 质量门禁闭环

```
编码实现
  → 创建设计开发追溯矩阵（事前路标）                       ← v2.0 新增
  → project-coding-conventions（编码标准检查）
  → 后端性能自测（CPU profile / 内存 profile）             ← v2.0 新增
  → code-static-quality-check（12 类静态检查）
  → 开发自测
  → code-logic-review（11 维逻辑审查）
  → 修复复审
  → DevLogReport（记录变更/问题/风险）
  → 开发设计对比审计（事后偏差检测）
  → 测试阶段（14 类 + RT-ID 逐项核对）
```

### 9.4 性能闭环（v2.0 新增）

```
Step 0：版本规划 — 技术债务评估含性能债务
  ↓
Step 1：需求分析 — 推荐 P50<目标ms / P99<目标ms / 预期并发数 / 预期日活
  ↓
Step 2：架构设计 — 非功能设计说明含：容量规划/缓存策略/并发设计/数据性能
  ↓
Step 3：编码开发
  ├── 数据库性能规则（EXPLAIN/N+1/慢查询/批量操作/连接管理）
  └── 后端性能自测（CPU profile / 内存 profile / 接口响应时间 / 慢查询）
  ↓
Step 4：测试 — 性能测试通过标准：P50<目标 / P99<目标 / 吞吐≥基线80% / CPU<80%
  ↓
CI/CD：性能回归门禁 — P50+20%警告/P99+30%阻断/吞吐-20%阻断
       性能基线管理 — 首次压测3次取中位数作基线
  ↓
Step 5：部署 — 上线检查报告含性能检查（Core Web Vitals/接口延迟）
  ↓
运行时：RED指标（Rate/Errors/Duration）+ 14种关键指标 + 6个Dashboard
```

---

## 11. 维护责任矩阵

### 10.1 ❌ 不需要团队维护（22 个技能中的 19 个）

| 技能 | 原因 | 例外情况 |
|:-----|:-----|:---------|
| **project-development-workflow** | 五步流程是固定框架 | — |
| **project-role-management** | 12 种角色是标准化定义（v2.0精简）| 团队可新增自定义角色 |
| **version-planning-stage-execution** | 15 类规划矩阵是通用最佳实践 | — |
| **requirements-stage-execution** | 20 类需求规范矩阵是通用最佳实践 | — |
| **design-stage-execution** | 17 类设计规范矩阵是通用最佳实践 | 可观测性速查表按需扩展 |
| **coding-stage-execution** | 20 类开发规范矩阵是通用最佳实践 | — |
| **testing-stage-execution** | 14 类强制测试矩阵是通用最佳实践 | — |
| **operations-stage-execution** | 19 类部署运维矩阵是通用最佳实践 | — |
| **project-coding-conventions** | 10 大编码约定是内置标准 | 命名模板/错误码前缀可自定义；**数据库性能规则为v2.0新增** |
| **code-static-quality-check** | 12 类检查项是固定检查矩阵 | — |
| **code-logic-review** | 11 维审查维度是固定框架 | — |
| **cicd-pipeline-management** | 五阶段流水线是固定标准 | 平台模板可按需替换；**性能基线管理方法v2.0新增** |
| **observability-standards** | 三大支柱+告警规则是固定标准 | 技术栈选择可按团队偏好替换 |
| **api-contract-management** | API 契约方法论和工具链是固定标准 | **v2.2 新增**；技术栈适配矩阵按项目选择 |
| **code-version-backup-management** | 分支策略和备份流程是固定标准 | **v2.1 重构**；分支策略可配置 |
| **prototype-coverage** | 前端原型覆盖检查方法论是固定标准 | **v2.3 新增**；七步流程固定 |
| **backend-coverage** | 后端设计覆盖检查方法论是固定标准 | **v2.3 新增**；五步流程固定 |

### 10.2 ✅ 需要团队维护（22 个技能中的 3 个）

| 技能 | 维护内容 | 维护频率 | 维护示例 |
|:-----|:---------|:--------|:---------|
| **project-document-management** | 文档类型扩展；权限矩阵调整；文档模板新增 | 按需（新项目/新文档类型加入时） | 新增自定义文档类型到命名表和权限矩阵 |
| **project-document-templates** | 新增文档模板；补充章节结构 | 按需（新文档类型需要内容模板时） | 已有 18 个模板；新增追溯矩阵模板（v2.0）|
| **devflow-project-config** | 项目配置（分支策略、备份配置等） | 项目初始化时 | — |

### 10.3 需要团队关注的内容

| 内容 | 所在技能 | 说明 |
|:-----|:---------|:-----|
| **项目名** | 所有文档命名 | `{项目名}` 占位符在项目初始化时替换 |
| **团队特定编码规范** | `project-coding-conventions` | 命名模板中的 API 路径/数据库表名/环境变量前缀可自定义 |
| **CI/CD 平台选择** | `cicd-pipeline-management` | GitHub Actions / GitLab CI / Jenkins 按项目选择 |
| **可观测性技术栈** | `observability-standards` | Loki/ELK/Prometheus/Thanos/Jaeger/Tempo 按团队选型 |
| **性能基线初始值** | `cicd-pipeline-management` 基线管理 | 首个版本压测 3 次取中位数作为基线，后续版本自动对比 |

---

## 12. 常见问题

### Q1：运行时真的只有 2 层深度吗？

是的。根据引用类型分类分析，Layer 3 的引用中：
- **边界声明（B）**：如"我不替代 security-best-practices"——不产生执行
- **知识引用（K）**：如"详细内容参考 XX 技能"——按需查阅，不自动执行
- **反向引用（R）**：如"被 coding-stage-execution 调用"——逆流信息，不参与执行

只有**执行引用（E）**会产生实际的调用链。当前 L1→L2 的执行引用构成恒等 2 层深度。

### Q2：L3 技能在运行时会不会被自动加载？

**不会。** 只有显式调用 `Skill` 工具才能加载技能文件。编译层方案将技能协作表从三列表格压缩为一行文本映射，降低了 LLM 主动加载 L3 的"推理倾向"。

### Q3：v2.0 相比 v1.0 的主要变化？

| 变化 | v1.0 | v2.0 |
|:-----|:-----|:-----|
| 输出文档总数 | 108 份 | **49 份**（-55.6%）|
| 角色管理 | 294 行（含 12x12 矩阵）| **158 行**（-41%，去冗余）|
| 新增文档 | — | 设计开发追溯矩阵/需求设计追溯矩阵（2个）|
| 追溯链 | 需求→设计 | **需求→设计→开发→测试→审计**（全链路）|
| 性能 | ★★★☆☆ | **★★★★☆**（6 项增强）|
| 需求来源 | 5 种代码 | **12 种完整分类** |
| 模板 | 15 个 | **18 个**（+3 追溯矩阵）|
| 工程领域覆盖 | 14/17 ★★★★★ | **15/17 ★★★★★** |

### Q4：内置编码规范不符合团队习惯怎么办？

`project-coding-conventions` 的**命名模板**部分（API 路径/数据库表名/环境变量前缀/配置键）是可自定义的。其余部分（错误处理/日志/API响应格式/数据库操作/前端编码/并发安全/数据库性能）建议保持内置标准，因为它们基于业界最佳实践。

### Q5：性能测试的通过标准是什么？

v2.0 明确规定了量化的性能通过标准：

| 维度 | 通过标准 | 阻断条件 |
|:-----|:---------|:---------|
| P50 响应时间 | < 目标值（需求阶段定义）| 基线 +20% → 告警 |
| P99 响应时间 | < 目标值（需求阶段定义）| 基线 +30% → **阻断** |
| 吞吐量 | ≥ 基线 80% | 基线 -20% → **阻断** |
| CPU | < 80% | — |
| 内存泄漏 | 无 | — |
| 数据库查询 | EXPLAIN 计划检查 + 索引覆盖 | 无索引全表扫描 → **阻断** |

---

## 附录 A：技能全景图

```
┌─────────────────────────────────────────────────────────────────┐
│                     Layer 1 (3 skills)                          │
│                                                                  │
│  project-development-workflow (202L)                            │
│  ├── 5步流程: Step 0→1→2→3→4→5                                   │
│  ├── 14条核心原则 + 技能三层架构说明                              │
│  ├── 审计框架: 6阶段门禁                                          │
│  └── 三环境管理: Dev/Test/Pro                                    │
│                                                                  │
│  project-document-management (686L) [团队维护]                   │
│  ├── 49种文档命名表 (精简后)                                      │
│  ├── 三环境目录树 + 生命周期                                      │
│  ├── 6阶段审计门禁 + 权限矩阵                                    │
│  └── 版本控制 + 交付规则                                         │
│                                                                  │
│  project-role-management (158L)  [v2.0精简]                      │
│  ├── 12种核心角色 + Agent命名规范                                │
│  ├── Solo模式执行说明                                             │
│  └── 审批门禁 + 审计门禁                                         │
├─────────────────────────────────────────────────────────────────┤
│                     Layer 2 (6 skills)                           │
│                                                                  │
│  version-planning-stage-execution (152L)                         │
│  ├── 15类规划矩阵 + 全部/单版本边界                              │
│  ├── 8条反模式 + 9条完成标准                                     │
│  └── 输出: 版本总纲/路线图/候选池/单版本/Phase/Backlog           │
│                                                                  │
│  requirements-stage-execution (171L)                             │
│  ├── 20类需求规范矩阵 + 8条强制规则                              │
│  ├── 范围变更/来源记录/追溯矩阵/评审/基线 强制                   │
│  └── 输出: 需求文档/用户说明书/UIUX/RT/评审/基线/来源/评估       │
│                                                                  │
│  design-stage-execution (195L)                                   │
│  ├── 17类设计规范矩阵 + 7条强制规则                              │
│  ├── 需求设计追溯矩阵(覆盖率≥95%)                                │
│  ├── L3 可观测性速查                                             │
│  └── 输出: 架构/Agent/前端/UI/API/DB/非功能/缓存/部署/评审/DT    │
│                                                                  │
│  coding-stage-execution (455L) — 最大                            │
│  ├── 20类开发规范矩阵 + 10条强制规则 + 11条反模式                │
│  ├── 创建设计开发追溯矩阵(td) + 后端性能自测(profile)            │  ←v2
│  ├── L3 编码约定速查(含数据库性能)                               │
│  ├── L3 静态检查+逻辑审查速查                                    │
│  └── 输出: DevLogReport + 设计开发追溯矩阵                       │
│                                                                  │
│  testing-stage-execution (250L)                                  │
│  ├── 14类强制测试矩阵 + P50/P99性能标准                          │  ←v2
│  ├── 按RT-ID逐项核对测试覆盖                                     │  ←v2
│  ├── 8条执行规则 + 9条反模式                                     │
│  └── 输出: 测试报告/用例/回溯审计                                 │
│                                                                  │
│  operations-stage-execution (184L)                               │
│  ├── 19类部署运维矩阵 + 8条强制规则                              │
│  ├── 性能基线管理(3次中位数)                                     │  ←v2
│  ├── L3 CI/CD+可观测性速查                                       │
│  └── 输出: 发布计划/部署报告/数据运维/回滚/上线检查/运维手册     │
├─────────────────────────────────────────────────────────────────┤
│                     Layer 3 (10 skills) — 按需加载                 │
│                                                                  │
│  project-coding-conventions (337L)                               │
│  ├── 后端分层/错误处理/日志/API/注释/数据库/前端/并发/配置       │
│  ├── 依赖管理规则 + 命名模板                                     │
│  └── 数据库性能规则 (v2.0新增: EXPLAIN/N+1/慢查询/批量操作)      │
│                                                                  │
│  code-static-quality-check (142L)                                │
│  ├── 12类检查矩阵 + 工具选择                                     │
│  └── P0-P3严重级别 + 输出模板                                    │
│                                                                  │
│  code-logic-review (344L)                                        │
│  ├── 11个审查维度 + 8条审查原则                                  │
│  └── 4种审查结论 + 审查记录模板 + 7条反模式                      │
│                                                                  │
│  cicd-pipeline-management (275L)                                 │
│  ├── 五阶段流水线 + 8个质量闸门                                  │
│  ├── 性能回归门禁(P50/P99/吞吐) + 性能基线管理(v2.0)             │  ←v2
│  ├── 部署策略 + 平台模板                                         │
│  └── 触发器与分支策略 + 故障排查                                 │
│                                                                  │
│  observability-standards (295L)                                  │
│  ├── 三大支柱(日志/指标/追踪)                                    │
│  ├── RED+USE方法 + 14种关键指标                                  │
│  ├── OpenTelemetry集成 + 告警规则                                │
│  └── 6个必备Dashboard + 技术栈建议                               │
│                                                                  │
│  project-document-templates (585L) [团队维护]                    │
│  ├── 18个文档模板 (v2.0新增3个追溯矩阵模板)                      │  ←v2
│  ├── 需求追溯矩阵(10列/12来源/5行示例)                           │  ←v2
│  ├── 需求设计追溯矩阵(9列/覆盖率统计/FULL-PARTIAL分类)           │  ←v2
│  ├── 设计开发追溯矩阵(8列/状态机/7章节/5行示例)                  │  ←v2
│  └── 文档元信息统一格式(表格/列表双风格)                         │
│                                                                  │
│  api-contract-management (684L)  [v2.2新增]                     │
│  ├── 技术栈适配矩阵: Python/Java/Go/Node + Vue/React            │
│  ├── Step 2: OpenAPI 契约编写 + 统一响应/错误码 + 环境配置      │
│  ├── Step 3: Orval 代码生成 + Zod 校验 + React/Vue 示例        │
│  ├── Step 4: MSW Mock + Schemathesis 契约测试                   │
│  ├── Step 5: CI 契约变更检测 + Nginx 反向代理                   │
│  └── 7 种常见陷阱 + 工具链速查表                                │
│                                                                  │
│  code-version-backup-management (200L)  [v2.1重构]             │
│  ├── 3 种分支策略可配置(trunk/github-flow/git-flow)             │
│  ├── Git 原生备份(mirror/push) + TDD 对齐                       │
│  └── CI/CD 集成 + 变更请求管理                                   │
│                                                                  │
│  prototype-coverage (270L)  [v2.3新增]                         │
│  ├── 七步流程: 页面清单→状态覆盖→原型走查→用例演练              │
│  ├── 交互标注→测试预映射→覆盖报告                                │
│  └── 前端原型完整性检查                                          │
│                                                                  │
│  backend-coverage (268L)  [v2.3新增]                            │
│  ├── 五步流程: API契约覆盖→数据模型对齐→状态机覆盖             │
│  ├── 安全设计→测试预映射                                          │
│  └── 后端设计完整性检查                                          │
└─────────────────────────────────────────────────────────────────┘
```
