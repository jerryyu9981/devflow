---
name: "design-stage-execution"
description: "Guides Step 2 design execution after requirements approval. Invoke for system/API/UI/data/security/performance/deployment design, design review, and audit handoff."
---

# Design Stage Execution（Step 2 设计阶段执行规范）

## 定位

本技能用于软件开发流程中的 Step 2：架构与设计阶段。它发生在需求分析通过之后、编码阶段开始之前，负责把已批准的需求、版本范围、Backlog 和 Phase 计划转化为可开发、可测试、可审计的设计产物。

它是 Step 2 的主控技能。它不替代需求分析，不替代编码实现，也不替代设计审计；它负责组织系统架构、Agent 架构、前端架构、UI/UX、API、数据模型、安全、性能、部署、可观测性、设计评审和设计审计移交。

## 触发条件

当用户提出以下需求时，调用本技能：

- 需求评审通过后开始系统设计或架构设计
- 制定系统架构、Agent 架构、前端架构、API、数据库、UI/UX 或原型设计
- 将需求文档转化为技术设计文档
- 判断设计阶段是否完整、是否可以进入开发
- 组织设计评审、需求-设计追溯或需求架构对比审计
- 生成或补齐设计文档矩阵
- 梳理 Step 2 需要调用哪些专项设计技能

## 阶段位置

```text
Step 0 版本规划
→ Step 1 需求分析
→ Step 2 架构与设计
→ Step 3 开发 / 编码
→ Step 4 测试
→ Step 5 部署与运维
```

本技能负责：

```text
Step 2 架构与设计
├── 设计入场检查
├── 需求-设计追溯
├── 系统架构设计
├── Agent 架构设计
├── 前端架构设计
├── UI/UX 与原型设计
├── API 接口设计
├── 数据模型与数据库设计
├── 缓存与消息设计
├── 安全设计
├── 性能与容量设计
├── 可观测性设计
├── 部署与环境设计
├── 设计评审
└── 需求架构对比审计移交
```

## 入场门禁

进入 Step 2 前必须满足：

1. Step 0 版本规划已批准。
2. Step 1 需求文档和需求评审记录已批准。
3. 当前版本范围、本版本 Backlog、Phase 计划和高层验收目标已明确。
4. P0/P1 需求已具备可设计的业务流程、边界条件和验收标准。
5. 不存在未确认的重大版本范围变更。

如不满足，应回退 Step 0 或 Step 1，不得直接进入设计。

## 设计规范矩阵

正式设计阶段必须按以下矩阵执行。若某项不适用，必须在设计评审记录中说明原因。

| 设计类别 | 必须执行内容 | 通过标准 | 强制产出 / 证据 |
|---|---|---|---|
| 设计入场检查 | 确认需求文档、评审记录、单版本规划、本版本 Backlog、Phase 计划 | 输入材料齐备，需求可设计 | 设计入场检查记录 |
| 需求-设计追溯 | 建立需求、业务流程、验收标准与设计项映射 | P0/P1 需求均有设计覆盖 | 需求设计追溯矩阵 |
| 系统架构设计 | 系统边界、模块、服务、上下游、技术选型、部署形态 | 架构能覆盖核心需求和非功能约束 | 系统架构设计文档 |
| Agent 架构设计 | Agent 角色、工具、工作流、上下文、记忆、失败处理、多智能体关系 | Agent 流程可执行、可观测、可降级 | Agent 架构设计文档 |
| 前端架构设计 | 页面结构、路由、状态管理、组件层级、数据获取、构建策略 | 前端结构支持需求和后续开发 | 前端架构设计文档 |
| UI/UX 与原型 | 用户路径、线框图、交互状态、表单、错误态、空态、加载态；**生成设计总览首页（`prototype/index.html`）供审核人一键预览全部页面** | 关键用户路径和状态完整；**设计总览首页可从浏览器直接打开且所有页面链接有效** | UI 设计文档、原型、**设计总览首页** |
| Figma 交付 | 设计稿、组件、变量、切图、标注、设计上下文 | 可被前端实现和审计引用 | Figma 设计交付说明 |
| 设计系统 | 颜色、排版、组件规范、交互模式、状态规范 | UI 规范可复用、一致 | 设计系统说明 |
| API 接口设计 | 路径、方法、参数、响应、错误码、鉴权、分页、排序、版本 | API 契约清晰且可测试 | API 接口设计文档 |

> **API 契约管理**：对于前后端异构技术栈（如 Python + TypeScript）项目，API 接口设计应参考 `api-contract-management` 技能，该技能提供了从 OpenAPI 契约编写、统一响应格式、错误码体系、环境配置规范到代码生成工具链选型的完整方法论，确保 API 契约成为前后端开发的唯一事实源。

> **前端/后端设计覆盖检查**：设计评审前，应分别调用 `prototype-coverage`（前端原型覆盖检查：页面清单 → 状态覆盖 → 原型走查 → 用例演练 → 交互标注 → 测试预映射 → 报告）和 `backend-coverage`（后端设计覆盖检查：API 契约 → 数据模型对齐 → 状态机 → 安全设计 → 测试预映射 → 报告）执行系统化覆盖检查。两个技能的检查通过是设计评审的准入条件。覆盖检查完成后，应调用 `api-contract-management` 执行 API 契约对齐检查（前端页面清单 ↔ 后端 API 交叉验证）。
| 数据模型设计 | ER、表、字段、索引、约束、迁移、数据字典 | 数据模型支持业务流程和一致性要求 | 数据库设计文档、数据字典 |
| 缓存与消息设计 | Redis 键、缓存策略、失效策略、队列、事件、幂等、重试 | 异步和缓存链路边界清晰 | 缓存与消息设计说明 |
| 安全设计 | 鉴权、授权、敏感数据、输入校验、审计日志、威胁建模 | 无阻塞安全设计缺口 | 安全设计说明 |
| 性能与容量设计 | 性能目标、瓶颈路径、缓存、并发、限流、资源预算 | 性能目标可验证 | 性能与容量设计说明 |
| 可观测性设计 | 日志、指标、追踪、告警、错误码、排障上下文 | 关键路径可定位和追踪 | 可观测性设计说明 |
| 部署与环境设计 | Dev/Test/Pro 环境、端口、容器、配置、依赖、回滚 | 部署路径和环境边界清晰 | 部署架构草案 |
| 设计评审 | 评审设计完整性、可开发性、可测试性、风险和偏差 | P0/P1 设计问题闭环 | 设计评审记录 |
| 设计审计移交 | 准备需求架构对比审计材料 | 审计材料完整，可进入门禁审计 | 审计移交材料 |

## 强制规则

1. **不得跳过需求-设计追溯**：P0/P1 需求必须有明确设计覆盖。
2. **不得用 UI 原型替代技术设计**：UI 原型只覆盖交互，不覆盖系统/API/数据/安全/部署设计。
3. **不得用 API 文档替代系统架构**：API 是契约，不是完整架构。
4. **不得让专项设计替代 Step 2 评审**：任何专项技能通过都不能替代设计评审和需求架构对比审计。
5. **P0/P1 设计缺口必须闭环**：未解决的核心设计问题不得进入 Step 3。
6. **所有设计决策必须可追溯**：关键决策、替代方案、风险和偏差必须写入对应设计文档。
7. **影响开发和测试的事项必须移交**：API、数据库、配置、Mock、外部依赖、安全、性能和已知风险必须写入开发/测试移交说明。

## 设计技能速查

流程/门禁→workflow | 文档→doc-management | 角色→role-management | API设计→api-design | UI/UX→ui-ux-pro-max/frontend-design/prototyping | Figma→figma/figma-integration | 设计系统→design-system | 前端架构→react-skills/vue-skills | 后端→nodejs-backend/python-backend | Agent→llm-integration/agent-framework-* | MCP→mcp-builder | 数据→sql-database/mongodb | 缓存消息→redis/rabbitmq/kafka | 安全→security-best-practices | 性能→frontend-performance | 可访问性→accessibility/web-design-guidelines | 部署→docker | 命名→universal-naming-conventions
| 角色协调 | `project-role-management` |
| API 设计 | `api-design` |
| UI/UX、原型和界面设计 | `ui-ux-pro-max`、`frontend-design`、`prototyping` |
| Figma 设计交付 | `figma`、`figma-integration` |
| 设计系统 | `design-system` |
| 前端架构 | `react-skills`、`vue-skills`、`composition-patterns` |
| 后端架构 | `nodejs-backend`、`python-backend` |
| Agent / LLM 架构 | `llm-integration`、`agent-framework-langchain`、`agent-framework-autogen`、`agent-framework-crewai` |
| MCP 服务设计 | `mcp-builder` |
| 数据模型和数据库设计 | `sql-database`、`mongodb` |
| 缓存和消息设计 | `redis`、`redis-development`、`rabbitmq`、`kafka` |
| 安全设计 | `security-best-practices` |
| 性能设计 | `frontend-performance`、`sql-database`、`redis-development` |
| 可访问性和 Web 界面规范 | `accessibility`、`web-design-guidelines` |
| 部署和环境设计 | `docker` |
| 命名规范 | `universal-naming-conventions` |

## 输出要求

设计阶段完成后，至少应具备：

- {项目名}-系统架构设计文档-v{版本号}.md（总体设计不带版本号）
- {项目名}-Agent架构设计文档-v{版本号}.md（涉及Agent/LLM时）
- {项目名}-前端架构设计文档-v{版本号}.md（涉及前端时）
- {项目名}-UI设计文档-v{版本号}.md（含：原型设计说明/设计系统说明）
- `prototype/index.html`（设计总览首页，含页面导航、覆盖率一览、用户路径走查入口；审核人可直接从浏览器打开预览全部页面）
- {项目名}-Figma设计交付说明-v{版本号}.md（使用Figma时）
- {项目名}-API接口设计文档-v{版本号}.md（涉及接口时）
- {项目名}-数据库设计文档-v{版本号}.md（含：数据字典；涉及持久化数据时）
- {项目名}-非功能设计说明-v{版本号}.md（代替原安全/性能/可观测性设计说明，3合1；建议章节：性能目标P50/P99/容量规划/缓存策略/并发设计/数据性能）
- {项目名}-缓存与消息设计说明-v{版本号}.md（涉及缓存/队列/事件流时）
- {项目名}-部署架构草案-v{版本号}.md
- {项目名}-设计评审记录-v{版本号}.md（主文件：含入场检查/需求设计追溯矩阵/审计移交/测试移交）

文档命名、路径和版本规则遵循 project-document-management。

> 设计阶段结束时，开发者将在 Step 3 开头根据设计文档创建 {项目名}-设计开发追溯矩阵-v{版本号}.md，作为编码实现的逐项指引。该矩阵不属于设计阶段产出，不在本阶段输出要求中列出。

## 专项技能反向声明规则

所有被设计规范矩阵调用的专项技能，都必须承认 `design-stage-execution` 是 Step 2 的设计阶段主控技能。

专项技能在设计阶段被调用时必须遵守：

- 只负责自身专项领域，不直接宣布整个设计阶段完成。
- 设计决策、假设、替代方案、风险、开放问题和下游影响必须写入相关设计文档。
- 专项设计评审通过不能替代 Step 2 设计评审或需求架构对比审计。
- 发现 P0/P1 设计缺口时，必须在 Step 2 内修复并重新评审。

## 完成标准

Step 2 可完成的最低条件：

1. 需求设计追溯矩阵覆盖所有 P0/P1 需求。
2. 必要设计文档已齐备并通过评审。
3. API、数据、安全、性能、部署和可观测性影响已说明。
4. 设计风险、偏差和开放问题已记录。
5. 设计评审已通过。
6. 需求架构对比审计材料已准备好。
7. 已明确允许进入 Step 3。

## 内部工作流

Step 2 架构设计采用四轨并行模型，按以下自适应步骤执行。

### 轨道选择机制

四条轨道中：

| 轨道 | 图标 | 特性 | 激活规则 |
|------|------|------|---------|
| 整体 | 🎯 | 永恒轨道 | 始终激活 |
| 后端 | ⚙️ | 永恒轨道 | 始终激活 |
| 前端 | 🎨 | 可选轨道 | 项目中存在前端页面/组件需求时激活 |
| 第三方集成 | 🔗 | 可选轨道 | 项目存在外部依赖集成时激活 |

**轨道确定时机**：2.0 入场检查时正式确定，写入入场检查记录。轨道一旦确定该版本内不得增减（变更需回退 Step 0）。

### 2.0 设计入场检查 + 轨道选择确认

| 维度 | 独立模式 | 全流程模式 |
|------|---------|-----------|
| **检查内容** | 需求基线至少存在 | Step 1 移交齐备 + 需求追溯矩阵齐全 + 需求评估审计通过 |
| **产出** | 入场检查记录 + 激活轨道清单 |

### 2.1~2.2 整体设计

| 步骤 | 活动 | 产出 |
|------|------|------|
| 2.1 需求-设计追溯 | 建立 DT-ID，每个设计项关联 RT-ID | 需求设计追溯矩阵 |
| 2.2 系统架构设计 | 分层架构、模块划分、部署拓扑 | 系统架构设计文档 |

### 2.3 并行技术选型（三选一或三选多）
| 步骤 | 轨道 | 活动 | 产出 |
|------|------|------|------|
| 2.3a 后端技术选型+ADR | ⚙️ | 后端技术栈决策 + ADR 记录 | 后端 ADR + 技术选型报告 |
| 2.3b 前端技术选型+ADR | 🎨 [按需] | 前端框架/UI库决策 + ADR 记录 | 前端 ADR + 技术选型报告 |
| 2.3c 第三方集成设计 | 🔗 [按需] | 外部依赖盘点、版本兼容矩阵、Adapter 接口设计 | 第三方集成设计文档 |

**ADR 要求**：每个关键决策必须记录 ADR，包含决策标题、上下文、备选方案（≥2 个）、决策与理由、已知后果与风险。

### 2.4~2.6 并行详细设计
| 步骤 | 轨道 | 活动 |
|------|------|------|
| 2.4a 后端数据模型设计 | ⚙️ | 核心实体定义、属性类型、约束、关系 |
| 2.5a 后端 API 接口设计 | ⚙️ | API 路径、方法、请求/响应格式、错误码 |
| 2.5b 前端 UI/组件/状态设计 | 🎨 [按需] | 页面布局、组件树、状态管理、路由设计；**原型覆盖率检查（页面清单 + 状态覆盖 + 交互标注 vs prototype-coverage 七步流程）** |
| 2.6a 后端专项设计 | ⚙️ | 缓存、消息队列、安全方案；**安全设计评审（威胁建模 + 数据分类分级 + 安全需求追溯）** |

> 2.6a 产出：安全设计审查记录

### 2.7 整体专项设计
| 步骤 | 活动 | 产出 |
|------|------|------|
| 2.7 整体专项 | 性能指标、可观测性、部署方案、CI/CD 策略 | 整体专项设计文档；**可观测性覆盖检查表（日志格式/14 种关键指标/OTLP 追踪/6 种 Dashboard 逐项核对）** |

### 2.8 覆盖检查（分轨）
| 步骤 | 轨道 | 产出 |
|------|------|------|
| 2.8a 后端覆盖检查 | ⚙️ | **后端设计覆盖检查（API 契约/数据模型/状态机/安全设计覆盖率逐项核对，参考 backend-coverage 五步流程）** |
| 2.8b 前端覆盖检查 | 🎨 [按需] | 前端覆盖率报告 |
| 2.8c 第三方集成专项检查 | 🔗 [按需] | 第三方集成检查报告（依赖漏洞、License 合规、升级策略） |

**覆盖率缺口处置规则**：覆盖率目标 ≥ 95%。剩余 ≤ 5% 必须标记为"已知设计缺口"并记录在设计评审记录中，Step 3 审计时检查缺口是否已关闭。

### 2.9 API 契约对齐（衔接点）
| 条件 | 活动 | 产出 |
|------|------|------|
| 前端+后端轨道均激活 | 前后端共同验证 API 路径、请求/响应格式、错误码一致性 | API 契约对齐记录 |
| 仅后端轨道激活 | 从略 | [N/A] |

### 2.10~2.12 评审与移交
| 步骤 | 活动 | 产出 |
|------|------|------|
| 2.10 设计评审 | 完整性、一致性、可行性、覆盖率评审 | 设计评审记录 |
| 2.11 需求架构对比审计 | DT-ID 全覆盖检查、设计响应需求无遗漏 | 需求架构对比审计报告 |
| 2.12 开发测试移交 | 向 Step 3 移交全量设计文档 + 追溯矩阵 + 测试移交说明 | 设计基线 + 移交说明 |

### 回退路径
- 设计评审退回 → 回到 **2.3** 或 **2.7** 修改
- 审计发现覆盖率缺口 → 回到 **2.8** 补检
- Step 3 发现设计偏差 → 评估后回到 **2.10** 重评

## Requirements Stage Integration

When called within Step 1: treat `requirements-stage-execution` as controller, use only for specialty area, record decisions & acceptance criteria in requirements doc, do not replace Step 1 review/audit. P0/P1 gap → fix within Step 1, update traceability matrix, rerun review before design handoff.

## Operations Stage Integration

When called within Step 5: treat `operations-stage-execution` as controller, use only for specialty area, record deployment/verification evidence in ops doc, do not replace Step 5 release verification or ops audit. P0/P1 deployment issue → stop or rollback, update records, rerun verification.

## L3 可观测性设计速查

以下规则内联自 observability-standards 技能：
- 日志结构：每个服务须输出结构化JSON日志(traceId/spanId/service/module/message)
- 关键指标(14种)：http_requests_total/http_request_duration_seconds/db_query_duration_seconds/cache_hit_total 等
- 链路追踪：OTLP协议/W3C TraceContext传播/生产默认采样10%/错误追踪100%
- 必备Dashboard(6个)：Service Overview/Resource/Dependencies/Business/Errors/Alert History
  ↑ 以上 4 条标准必须在 2.7 步逐一检查

## Observability Integration

Step 2 可观测性设计环节必须参考 `observability-standards` 技能定义的可观测性标准，包括：日志结构、指标类型与命名、链路追踪集成方案、告警规则和 Dashboard 布局。设计产出应明确标识各子模块的可观测性覆盖范围。

observability-standards 是本项目可观测性标准的单点事实来源；`design-stage-execution` 负责将其纳入系统设计。
- If a P0/P1 deployment or production issue is found, stop rollout or trigger rollback, update release records, and rerun the required verification.