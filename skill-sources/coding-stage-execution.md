---
name: "coding-stage-execution"
description: "Guides coding-stage execution after requirements and design approval. Invoke for feature implementation, self-tests, DevLogReport, and testing handoff."
---

# Coding Stage Execution（编码阶段执行规范）

## 定位

本技能用于规范软件开发流程中的编码阶段，即需求和设计通过评审后，将需求、架构、接口、UI、数据模型和迭代计划转化为可运行、可测试、可审计的软件增量。

它是 `project-development-workflow` 中 Step 3 Development（开发）的专项执行技能。它不替代需求分析、架构设计、正式测试或部署运维，而是负责开发阶段内部的任务拆解、编码实现、开发自测、代码逻辑审查、问题修复、开发日志和测试移交。

## 触发条件

当用户提出以下需求时，调用本技能：

- 在需求和设计完成后开始编码
- 实现功能、模块、API、页面、后端服务、Agent、数据库变更或集成逻辑
- 将需求文档或设计文档转化为代码
- 组织某个版本或迭代的开发任务
- 判断开发阶段是否完成、是否可以进入测试
- 生成或更新 `DevLogReport`
- 梳理编码阶段需要调用哪些技能
- 对编码阶段流程、质量门禁、开发自测和移交进行规范化

如果用户只要求安全审查、UI 审查、数据库设计、正式测试或部署，应调用相应专项技能；只有当这些工作发生在编码阶段内部或影响开发移交时，才由本技能进行协调。

## 阶段位置

标准流程如下：

```text
需求分析 → 架构与设计 → 开发 / 编码 → 测试 → 部署与运维
```

本技能负责：

```text
Step 3 开发阶段
├── 编码准备
├── 任务拆解
├── 创建设计开发追溯矩阵（根据设计文档建立设计项→文件的映射）
├── 编码实现
├── 后端性能自测（CPU profile / 内存 profile / 接口响应时间 / 慢查询排查）
├── 代码静态质量检查
├── 开发自测
├── 代码逻辑审查
├── 问题修复与复审
├── DevLogReport 更新
└── 开发审计移交
```

其中，`code-static-quality-check` 必须放在“编码实现之后、开发自测之前”，`code-logic-review` 必须放在“开发自测之后、开发审计之前”，二者共同构成开发阶段内部的正式质量门禁。

## 输入要求

**本阶段负责人角色**：参考 `project-role-management` 技能定义的角色矩阵。

编码前应确认以下输入已经存在，或用户明确允许以草案形式推进：

| 输入 | 作用 |
|---|---|
| 需求文档 | 确认功能范围、优先级和验收标准 |
| 版本规划或 Phase 迭代计划 | 确认当前版本边界、P0/P1/P2 优先级和发布目标 |
| 系统架构设计文档 | 确认模块边界、服务关系和技术约束 |
| Agent 架构设计文档 | 涉及 Agent、工作流、工具调用或多智能体时使用 |
| 前端架构设计文档 | 涉及页面、组件、状态、路由和前端工程结构时使用 |
| UI 设计文档 | 涉及界面、交互、状态、视觉和可访问性时使用 |
| API 接口设计文档 | 确认接口路径、方法、参数、响应、错误码和鉴权 |
| 数据库或数据模型设计 | 确认表结构、集合、索引、迁移和数据一致性要求 |
| 非功能要求 | 确认性能、安全、可用性、兼容性、可观测性等要求 |
| 现有代码库 | 确认项目结构、命名、技术栈、测试方式和实现约定 |
| 设计开发追溯矩阵 | 设计项→文件映射，编码阶段的逐项指引 |

如果关键输入缺失，应暂停编码并请求补齐，或回退到需求/设计阶段。不得在缺失核心需求、接口契约或数据模型的情况下擅自扩大实现范围。

## 标准执行流程

### 1. 确认范围

确认当前编码任务的范围、优先级、完成标准和不包含内容。

必须明确：

- 本次实现哪些需求项
- 哪些需求不在本次范围
- 哪些接口、页面、服务、数据表或配置会被修改
- 是否存在兼容性要求
- 是否存在安全、性能、合规或可观测性要求

如果范围不清，应先澄清，不要直接编码。

### 2. 读取设计与现有代码

编码前必须理解现有代码结构和约定。

重点检查：

- 目录结构和模块边界
- 命名规则
- API 路由模式
- 前端组件和状态管理模式
- 后端分层方式
- 数据访问模式
- 错误处理和日志方式
- 测试框架和测试命令
- 构建、Lint、类型检查和静态质量检查命令

已有清晰约定时，应优先遵循项目现有模式，不要引入无必要的新架构。

### 3. 拆解开发任务

将需求和设计拆成可执行的编码任务。

典型任务包括：

- 前端页面或组件实现
- 路由、菜单、权限和状态管理实现
- 后端 API、Controller、Service、Repository 实现
- Agent 工作流、工具调用或任务调度实现
- 数据库迁移、索引、模型和初始化数据实现
- 缓存、消息队列、异步任务或外部服务集成
- 配置、环境变量、依赖和构建脚本更新
- 单元测试、组件测试、接口自测或本地联调
- 开发日志和移交说明更新

多步骤任务应调用 `writing-plans` 生成实现计划；已有实现计划时，应调用 `executing-plans` 按计划执行。

### 4. 准备开发环境

编码阶段默认只使用开发环境。除非用户明确要求并符合流程，不得直接修改测试环境或生产环境。

检查项：

- 运行时版本
- 包管理器和依赖
- 环境变量
- 本地配置
- 数据库、缓存、消息队列连接
- Mock 服务和外部依赖
- 端口占用
- 启动命令
- 构建命令
- 测试命令

环境阻塞应先修复或记录，不应跳过。

### 5. 编码实现

按任务拆解逐步实现最小可验证增量。

实现要求：

- 保持模块职责清晰
- 遵守需求和设计约束
- 不混入无关重构
- 不硬编码密钥或环境特定值
- 不绕过鉴权、校验和错误处理
- 不擅自改变 API 契约
- 不做破坏性数据库变更，除非有明确批准
- 对重要业务逻辑保留必要的日志和错误信息

如果实现过程中发现需求或设计存在问题，应记录偏差并反馈，而不是在代码中隐式改变方案。

### 6. 代码静态质量检查

编码实现完成后、开发自测和 `code-logic-review` 之前，应调用 `code-static-quality-check` 或执行等效检查。

重点检查：

- 语法错误、Lint 错误和类型错误
- 构建失败、依赖解析失败和 import/export 错误
- 未定义变量、常量、函数、类型、枚举或死引用
- 参数数量、参数类型、默认值和返回值结构一致性
- API 请求参数、响应字段、错误结构和前后端字段映射一致性
- 环境变量、配置键、Feature Flag、端口和密钥占位符一致性
- 数据模型字段、DTO、Schema、迁移字段和枚举状态一致性

检查结果必须写入 `DevLogReport` 的“静态质量检查”章节。发现 P0/P1 静态质量问题时，不得进入 `code-logic-review`。

### 7. 开发自测

编码阶段必须做开发自测，但开发自测不能替代正式测试阶段。

根据项目实际情况执行：

- 单元测试
- 组件测试
- 静态质量检查结果引用（如已由 `code-static-quality-check` 执行，可引用结果，不必重复执行）
- API smoke test
- 本地集成验证
- 数据库迁移验证
- 核心用户流程验证
- 异常路径验证

自测结果必须写入 `DevLogReport`。

### 8. 代码逻辑审查

编码实现、静态质量检查和开发自测完成后，必须调用 `code-logic-review` 进行正式代码逻辑审查。

审查位置：

```text
编码实现 → 代码静态质量检查 → 开发自测 → code-logic-review → 修复复审 → 更新 DevLogReport → 开发审计
```

`code-logic-review` 的结论是开发审计的重要输入。若存在 P0/P1 逻辑问题、设计不一致、测试证据不足或安全阻塞风险，不得进入开发审计。

### 9. 问题修复与复审

对 `code-logic-review` 发现的问题进行修复。

处理规则：

- P0/P1 问题必须修复并复审
- P2/P3 问题可视版本范围记录风险和后续计划
- 涉及需求或设计变更的问题必须回退对应阶段确认
- 涉及 API 契约变更的问题必须更新 API 设计或记录批准偏差
- 涉及安全问题时调用 `security-best-practices`
- 涉及 UI/UX 问题时调用 `web-design-guidelines`
- 涉及 React/Next.js 性能问题时调用 `react-best-practices`

### 10. 更新 DevLogReport

开发阶段必须更新 `DevLogReport`。文档命名、路径、版本规则遵循 `project-document-management`。

至少记录：

- 实现范围
- 修改文件或模块
- API 变更
- 数据库变更
- 配置和依赖变更
- 自测命令和结果
- 静态质量检查命令、结果和修复记录
- 代码逻辑审查结论
- 问题修复记录
- 设计偏差
- 已知风险
- 测试移交说明

### 11. 移交开发审计

编码阶段完成后，进入开发审计前必须准备：

- 代码分支或变更集
- `DevLogReport`
- 静态质量检查记录
- 代码逻辑审查记录
- 修复复审记录
- 开发审计移交材料
- 测试移交说明
- 自测结果
- 已知问题和风险说明
- API、数据库、配置变更说明
- 测试阶段启动和验证说明


## 开发规范矩阵

正式编码阶段必须按以下矩阵执行。除非当前需求明确不涉及某项，否则不得跳过；如跳过，必须在 `DevLogReport` 中说明原因、影响和后续处理。

| 开发类别 | 必须执行内容 | 通过标准 | 强制产出 / 证据 |
|---|---|---|---|
| 入场确认 | 确认需求、版本计划、架构、API、UI、数据库、非功能要求和开发审计前置条件 | 关键输入齐备，缺失项已澄清或明确批准以草案推进 | 入场检查记录、范围说明 |
| 范围确认 | 明确本次实现项、排除项、P0/P1/P2 优先级、验收标准和影响模块 | 范围可追溯到需求和设计，不存在隐式扩项 | 任务范围说明 |
| 代码库理解 | 阅读现有目录结构、模块边界、命名、分层、测试命令和构建方式 | 实现方案遵循现有约定，无无必要的新架构 | 代码库理解记录或计划说明 |
| 任务拆解 | 拆解前端、后端、API、Agent、数据库、配置、测试和文档任务 | 每个任务可对应需求、设计或技术变更 | 实现计划或任务清单 |
| 开发环境 | 检查运行时、依赖、环境变量、端口、数据库、缓存、队列、Mock 和启动命令 | 开发环境可稳定运行，阻塞项已修复或记录 | 环境记录、启动命令 |
| 语法与一致性检查 | 执行语法检查、Lint、类型检查、构建检查，核对变量、常量、函数、类型、参数、返回值、import/export、环境变量、配置键、API 字段和数据字段一致性 | 无语法错误、无阻塞 Lint/类型/构建错误、无未定义符号、无关键参数或返回值不匹配 | 静态质量检查记录、命令和结果 |
| 前端实现 | 页面、组件、路由、状态、表单、权限、错误态、空态、加载态和响应式行为 | UI/交互符合设计，关键状态完整 | 前端代码、组件自测记录 |
| 后端实现 | Controller、Service、Repository、业务规则、鉴权、异常、日志和外部调用 | 分层清晰，业务逻辑符合设计，错误可追踪 | 后端代码、接口自测记录 |
| API 实现 | 路径、方法、参数、响应、错误码、鉴权、分页、过滤和排序 | API 契约与设计一致，破坏性变更已批准 | API 变更记录、Smoke Test |
| Agent / 工作流实现 | Agent 流程、工具调用、状态、上下文、重试、失败处理和输出格式 | 工作流可执行，失败路径可解释 | Agent 实现记录、调用样例 |
| 数据库变更 | Schema、迁移、索引、种子数据、事务、回滚和兼容性 | 迁移可执行，风险和回滚策略已记录 | 迁移文件、数据库变更说明 |
| 配置与依赖 | 环境变量、配置模板、依赖版本、构建脚本和 Feature Flag | 无真实密钥，依赖必要且兼容 | 配置说明、依赖说明 |
| 安全编码 | 输入校验、鉴权、授权、敏感数据、日志脱敏、注入/XSS/CSRF 风险 | 无明显阻塞安全风险，高风险已专项审查 | 安全检查记录 |
| 性能与资源 | 查询效率、缓存、异步处理、渲染成本、资源加载和循环复杂度 | 无明显性能退化或资源风险 | 性能风险说明 |
| 可观测性 | 日志、错误上下文、追踪信息、关键业务事件和排障线索 | 关键失败路径可定位 | 日志和错误处理说明 |
| 开发自测 | 单元、组件、API smoke、本地联调和异常路径；静态质量检查已先完成或同步记录 | 自测命令已执行，失败项已处理或记录 | 自测命令和结果 |
| 系统化调试 | 遵循四阶段调试流程：Phase 1 根因调查（读错误/复现/查diff）→ Phase 2 模式分析（对比工作代码）→ Phase 3 假设验证（一次只改一个变量）→ Phase 4 实施修复（先写失败测试再修bug）| 连续 3 次修复失败时，必须停下来质疑架构本身而非继续假设；每阶段有命令和结果证据 | 调试记录、根本原因分析 |
| 代码逻辑审查 | 调用 `code-logic-review` 审查需求覆盖、设计一致性、业务逻辑、数据流和测试证据 | 无未解决 P0/P1 问题 | 代码逻辑审查记录 |
| 修复复审 | 修复 P0/P1 问题，记录 P2/P3 风险和后续计划 | 阻塞问题闭环，复审结论明确 | 修复记录、复审记录 |
| DevLogReport | 更新实现范围、文件模块、API、数据库、配置、依赖、自测、审查、风险和移交说明 | `DevLogReport` 可支持开发审计和测试入场 | `DevLogReport` |
| 开发审计移交 | 准备代码分支、变更集、静态质量检查记录、代码逻辑审查记录、修复复审记录、自测结果、已知风险和测试移交说明 | 审计材料齐备，可进入开发审计 | 开发审计移交材料、测试移交说明 |

## 开发阶段强制执行规则

1. **不得跳过入场确认**：需求、设计、API、数据模型或验收标准缺失时，应先澄清或回退对应阶段。
2. **不得以代码实现替代设计确认**：发现设计不合理时，应记录偏差并反馈，不得在代码中隐式改变方案。
3. **文件范围保护：AI 操作必须限于任务涉及的文件**：编码实现时默认只允许修改本次任务涉及的文件。发现 AI 试图修改非本次任务范围的文件时，必须请求确认。所有文件修改必须在 `设计开发追溯矩阵` 的"涉及文件"列中有对应记录。高危操作（删除、批量替换、密钥写入）执行前必须告警确认。
4. **不得以开发自测替代正式测试**：开发自测只证明代码具备进入审计和测试的基础条件。
5. **TDD 铁律：测试未先行即不写生产代码**：必须先在测试中定义预期行为（RED），再编写最小可通过的代码（GREEN），最后重构（REFACTOR）。发现先写生产代码再补测试的情况，必须删除生产代码从测试开始重新实现。自测不能仅验证代码能运行，必须验证功能语义正确。
6. **完成前必须强制验证**：没有新鲜的验证证据不得声称实现完成。"应该能通过""我很有信心"等声明性陈述不能替代实际运行命令、查看输出、然后报告结果的过程。
7. **必须执行静态质量检查**：编码实现完成后，应先完成语法、Lint、类型、构建、符号、参数和配置一致性检查。
8. **必须执行 `code-logic-review`**：编码实现、静态质量检查和开发自测完成后，必须完成代码逻辑审查。
9. **必须闭环 P0/P1 问题**：未解决 P0/P1 逻辑、设计、安全或测试证据问题，不得进入开发审计或 Step 4。
10. **必须更新 `DevLogReport`**：开发阶段所有关键变更、命令、结果、偏差和风险必须可追溯。
11. **必须保护环境边界**：编码阶段默认只使用开发环境，不得直接污染测试或生产环境。
12. **必须记录破坏性变更**：API 破坏性变更、数据库破坏性变更和依赖重大变更必须有批准和回退说明。
13. **必须准备测试移交**：开发完成时必须说明测试环境、启动命令、测试数据、Mock、已知风险和建议回归范围。

## 完成标准

只有满足以下条件，编码阶段才可视为完成：

1. 当前版本范围内的 P0/P1 功能已实现。
2. 代码可以在开发环境稳定启动。
3. 核心业务流程已完成开发自测。
4. 必要的语法检查、Lint、类型检查、构建检查和静态一致性检查已执行。
5. 无未解决的 P0/P1 静态质量问题，包括未定义符号、关键参数不匹配、返回值结构漂移、import/export 错误和配置键不一致。
6. API、UI、数据库和配置变更均已记录。
7. 没有未处理的 P0/P1 代码逻辑审查问题。
8. `code-logic-review` 已完成并给出明确结论。
9. `DevLogReport` 已更新。
10. 设计偏差和已知风险已记录。
11. 已准备好提交开发审计。

## 编码技能速查

流程/门禁→workflow | 文档→doc-management | 规划→writing-plans/executing-plans/tdd | 静态检查→code-static-quality-check | 逻辑审查→code-logic-review | 版本/提交→code-version-backup-management/git-commit | 命名→universal-naming-conventions | API→api-design | React→react-skills/react-best-practices | 前端→frontend-design | Vue→vue-skills | Node→nodejs-backend | Python→python-backend | Agent→llm-integration/agent-framework-* | 数据库→sql-database/mongodb | Redis→redis/redis-development | 消息→rabbitmq/kafka | 安全→security-best-practices | UI/UX可访问→web-design-guidelines/accessibility | 性能→frontend-performance/browser-devtools | Web验证→webapp-testing | Docker→docker
| 多步骤开发任务规划 | `writing-plans` |
| 按已有计划执行 | `executing-plans` |
| 功能、缺陷或行为变更实现 | `test-driven-development` |
| 语法、Lint、类型、构建和一致性检查 | `code-static-quality-check` |
| 编码完成后的逻辑审查 | `code-logic-review` |
| 分支、提交、版本和备份 | `code-version-backup-management`、`git-commit` |
| 命名一致性 | `universal-naming-conventions` |
| API 实现或变更 | `api-design` |
| React / Next.js 开发 | `react-skills`、`react-best-practices`、`composition-patterns` |
| 前端界面实现和视觉设计 | `frontend-design` |
| Vue 开发 | `vue-skills` |
| Node.js 后端 |  `nodejs-backend` |
| Python 后端 | `python-backend` |
| Agent / LLM 工作流实现 | `llm-integration`、`agent-framework-langchain`、`agent-framework-autogen`、`agent-framework-crewai` |
| SQL 数据库 | `sql-database` |
| MongoDB | `mongodb` |
| Redis | `redis`、`redis-development` |
| RabbitMQ / Kafka | `rabbitmq`、`kafka` |
| 安全编码或安全审查 | `security-best-practices` |
| UI/UX 或可访问性审查 | `web-design-guidelines`、`accessibility` |
| 前端性能 | `frontend-performance`、`browser-devtools` |
| Web 应用本地验证 | `webapp-testing`、`browser-devtools` |
| Docker 开发环境和依赖服务 | `docker` |


## 专项技能反向声明规则

所有被开发规范矩阵调用的专项技能，都必须承认 `coding-stage-execution` 是 Step 3 的开发阶段主控技能。

专项技能在开发阶段被调用时必须遵守：

1. **只负责专项领域**：专项技能只处理自身领域的设计、实现、检查或优化，不直接判定开发阶段完成。
2. **证据必须归档**：实现决策、修改文件、命令、测试结果、风险和剩余问题必须写入 `DevLogReport` 或开发移交说明。
3. **不能替代 `code-logic-review`**：任何专项技能通过，都不能替代编码完成后的代码逻辑审查。
4. **不能替代开发审计**：专项技能结论只是开发审计输入，不是阶段通过结论。
5. **P0/P1 必须回到 Step 3 闭环**：发现阻塞问题时，应在开发阶段修复、复审并更新 `DevLogReport`。
6. **影响测试时必须移交**：涉及 API、数据库、配置、Mock、外部依赖、性能、安全或已知风险时，必须写入测试移交说明，供 `testing-stage-execution` 使用。

专项技能建议加入如下声明：

```markdown
## Coding Stage Integration

When this skill is used during the formal coding stage, coordinate with `coding-stage-execution`.

- Treat `coding-stage-execution` as the Step 3 coding-stage controller.
- Use this skill only for its specialty area; do not use it to declare the whole development stage complete.
- Record implementation decisions, changed files, static quality commands, self-test evidence, risks, and remaining issues in `DevLogReport`.
- Do not let a successful specialty check replace `code-logic-review` or development audit.
- If a P0/P1 issue is found, fix it within Step 3, rerun relevant checks, update `DevLogReport`, and run `code-logic-review` before handoff.
```

## L3 编码约定速查

以下规则内联自 project-coding-conventions 技能：
- API响应格式：{code:0, data, traceId}（成功）；{code, message, details[], traceId}（错误）
- 错误码前缀：BIZ/业务 SYS/系统 AUTH/鉴权 PERM/权限 RATE/限流 DB/数据库 EXT/外部依赖
- 日志级别：DEBUG(生产关闭) INFO(业务节点) WARN(可恢复) ERROR(不可恢复)
- 禁止记录：密码/令牌/密钥/完整请求体/个人隐私
- 三层约束：Controller(请求校验+调用Service) Service(业务编排) Repository(数据访问) — 禁止跨层
- SQL：参数化查询/禁止SELECT*/禁止全表操作/迁移有up+down
- 并发：共享可变状态须加锁/关键操作须幂等/定时任务须分布式锁

以下规则内联自 code-static-quality-check 技能：
- 检查项(12类)：语法/Lint/类型/构建/符号一致/参数/返回值/import-export/API字段/环境配置/数据字段/状态枚举
- 严重级别：P0(构建失败/密钥泄露)必须修复 P1(API不匹配)必须修复 P2记录 P3可优化

以下规则内联自 code-logic-review 技能：
- 审查维度(11维)：需求覆盖/设计一致/业务流程/状态流转/API契约/数据一致/权限安全/异常日志/可测试性/静态证据/可维护性
- 结论：通过/有条件通过/不通过/证据不足 — P0/P1必须修复

以下规则内联自 code-version-backup-management 技能：
- 提交约定：type(scope): subject，footer 引用 RT-ID
- 提交类型：feat/fix/docs/style/refactor/test/chore
- TDD 合规：feat 和 fix 提交必须包含对应的测试文件变更；测试代码先于生产代码提交
- 分支策略：git-flow（推荐）/ github-flow / trunk-based（由 .devflow/project-config.json 配置）
- Git Flow 分支：main(生产) ← release(发布准备) ← develop(日常集成) ← feature(功能)
- 版本号：语义化 MAJOR.MINOR.PATCH（破坏性变更/新功能/Bug修复）

## 技术债务跟踪

1. **记录新增债务**：编码过程中引入的临时方案、TODO 标记、未覆盖测试的代码、架构偏离，必须在 DevLogReport 中记录为新增技术债务。
2. **债务分类**：安全债务（P0）> 架构债务（P1）> 测试债务（P2）> 代码整洁债务（P3）。
3. **偿还规则**：引入新债务时必须评估是否在本版本内偿还；跨版本挂起的债务必须记录到版本规划阶段的技术债务清单。
4. **自测债务检查**：开发自测时必须检查是否有新增的 TODO 或废弃标记，记录到 DevLogReport 的已知问题章节。
5. **编码阶段三技能关系补充**：`code-static-quality-check` 将 TODO 标记、废弃代码等列为 P2/P3 级问题；`code-logic-review` 将可维护性（含技术债）作为独立审查维度。

## 反模式

编码阶段应避免：

- 未确认需求和设计就开始编码
- 将开发自测等同于正式测试
- 编码完成后跳过 `code-static-quality-check` 或 `code-logic-review`
- 把代码逻辑问题留给审计或测试阶段发现
- 未记录设计偏差
- 未更新 `DevLogReport`
- 混入无关重构
- 擅自修改 API 契约
- 提交真实密钥或敏感配置
- 未说明数据库迁移和回滚影响
- 测试证据不足仍进入开发审计

## 输出格式建议

向用户汇报编码阶段结果时，应包含：

- 已实现内容
- 主要修改范围
- 已执行检查
- `code-logic-review` 结论
- 剩余风险
- 是否可以进入开发审计或测试阶段
- 相关输出文件位置

## Testing Stage Integration

When this skill is used during the formal testing phase, coordinate with `testing-stage-execution`.

- Treat `testing-stage-execution` as the Step 4 testing-stage controller.
- Record actual commands, environment, evidence, pass/fail/skip counts, defects, and remaining risks in the appropriate test report.
- Do not let a successful partial or diagnostic check replace the complete Step 4 testing matrix.
- If a P0/P1 issue is found, route it back to Step 3 for repair, update `DevLogReport` and development audit evidence if needed, then retest through `testing-stage-execution`.
## Design Stage Integration

When this skill is used during the formal design stage, coordinate with design-stage-execution.

- Treat design-stage-execution as the Step 2 design-stage controller.
- Use this skill only for its specialty area; do not use it to declare the whole design stage complete.
- Record design decisions, assumptions, alternatives, risks, open questions, and downstream impacts in the relevant design document.
- Do not let a successful specialty design review replace the Step 2 design review or requirements-architecture audit.
- If a P0/P1 design gap is found, fix it within Step 2, update the relevant design document and traceability matrix, then rerun the relevant design review before development handoff.
## Operations Stage Integration

## Coding Conventions Integration

编码实现时必须遵循 `project-coding-conventions` 技能中定义的编码约定，包括：后端分层架构约束、错误处理规范、日志规范、API设计约定、注释规则、数据库操作规则、前端编码规则、并发安全规则、配置管理规则和命名模板。


When this skill is used during the formal deployment and operations stage, coordinate with operations-stage-execution.

- Treat operations-stage-execution as the Step 5 deployment-and-operations controller.
- Use this skill only for its specialty area; do not use it to declare the whole operations stage complete.
- Record commands, environment, release version, verification evidence, risks, rollback steps, and follow-up actions in the relevant operations document.
- Do not let a successful specialty deployment or check replace Step 5 release verification or operations audit.
- If a P0/P1 deployment or production issue is found, stop rollout or trigger rollback, update release records, and rerun the required verification.