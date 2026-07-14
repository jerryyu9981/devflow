---
name: "testing-stage-execution"
description: "Guides formal testing-stage execution after development audit. Invoke for test planning, environment validation, API/integration/E2E/regression/coverage/compliance/UAT testing, reports, and audit handoff."
---

# Testing Stage Execution（测试阶段执行规范）

## 定位

本技能用于规范软件开发流程中的正式测试阶段。它在开发阶段完成、`code-logic-review` 通过、开发审计通过之后触发，负责组织完整测试矩阵、测试报告、缺陷闭环、覆盖率、UAT 和测试回溯审计移交。

它是 `project-development-workflow` 中 Step 4 Testing（测试）的专项执行技能。它不替代开发自测，也不替代部署验证；它负责证明当前版本是否具备进入部署与运维阶段的质量证据。

## 触发条件

当用户提出以下需求时，调用本技能：

- 进入正式测试阶段
- 制定测试计划或测试用例
- 执行 API、集成、E2E、回归、覆盖率、合规或 UAT 测试
- 判断测试是否完整、是否可以进入部署与运维
- 生成测试报告、覆盖率报告、UAT 报告或测试回溯审计材料
- 复测上一版本失败项、跳过项或本版本缺陷修复项
- 检查测试环境、Mock 服务、外部依赖或端口配置
- 编排 `e2e-test-gen`、`webapp-testing`、`dogfood`、`browser-devtools` 等测试技能

## 阶段位置

**本阶段负责人角色**：参考 `project-role-management` 技能定义的角色矩阵。

标准流程如下：

```text
需求分析 → 架构与设计 → 开发 / 编码 → 测试 → 部署与运维
```

本技能负责：

```text
Step 4 测试阶段
├── 测试入场检查
├── 测试计划与用例准备
├── 测试环境验证
├── API 测试
├── 集成测试
├── E2E 测试
├── Mock / 外部依赖测试
├── 回归测试
├── 覆盖率测试
├── 合规 / 安全 / 性能 / 可访问性专项测试
├── UAT 验收测试
├── 缺陷修复回归
├── 测试报告汇总
└── 测试回溯审计移交
```


## 与项目流程技能的边界

`project-development-workflow` 只保留 Step 4 的阶段门禁、人工审批、审计关系和跨阶段回退规则；本技能是测试阶段矩阵、执行顺序、证据记录、测试报告、缺陷复测、覆盖率、UAT 和测试回溯审计移交的权威执行规范。

如果两者描述存在细节差异，以本技能的测试执行细则为准；以 `project-development-workflow` 的阶段准入、阶段退出和人工审批规则为准。

## 入场门禁

进入测试阶段前必须满足：

1. `coding-stage-execution` 已完成编码阶段移交。
2. `code-logic-review` 已通过或有条件通过，且无未解决 P0/P1 问题。
3. 开发审计已通过。
4. `DevLogReport` 已更新。
5. 待测版本、分支、构建命令、启动命令、环境变量、端口、数据库和 Mock 信息已明确。
6. 已知问题和风险已记录。

如任一条件不满足，应回退 Step 3 修复或补充材料，不得直接执行正式测试。

## 输入材料

| 输入 | 用途 |
|---|---|
| 需求文档 | 生成测试用例（按需求追溯矩阵RT-ID逐项覆盖），使用已有的需求追溯矩阵检查测试覆盖率 |
| 架构/API/UI/数据库设计文档 | 确认测试基准和契约 |
| Phase 迭代计划 | 确认测试范围和版本边界 |
| `DevLogReport` | 确认变更范围、配置、依赖和自测证据 |
| `code-logic-review` 记录 | 确认代码逻辑审查结论和剩余风险 |
| 开发设计对比审计报告 | 确认可进入测试阶段 |
| 待测代码、构建或环境 | 执行测试 |
| 测试账号、测试数据和 Mock 配置 | 准备测试条件 |

## 强制测试矩阵

除非需求文档明确标记“不适用”，否则不得跳过以下测试类型。跳过项必须在测试报告和测试回溯审计报告中说明原因、影响和补救计划。

| 测试类别 | 必须执行内容 | 通过标准 | 强制产出 |
|---|---|---|---|
| 测试准备 | 测试计划、测试用例、测试数据、测试矩阵、环境信息 | 用例可追溯到需求 | 测试计划、测试用例 |
| 环境验证 | 端口、进程、容器、环境变量、数据库、Mock、外部依赖 | 所有服务均为当前待测版本 | 测试报告环境记录 |
| API 测试 | 健康检查、核心 API、错误响应、认证、权限、参数校验 | P0/P1 API 全部通过，无非预期 5xx | API 测试报告 |
| 集成测试 | 前后端、服务间调用、数据库、缓存、队列、外部依赖 | 关键链路全部有效执行 | 集成测试报告 |
| E2E 测试 | 关键端到端业务流程和数据闭环 | 关键流程全部通过 | 测试报告、E2E 证据 |
| Mock / 外部依赖测试 | Mock 启动、健康检查、契约、端口冲突处理 | 无静默跳过、无错误 Mock 契约 | 测试报告 |

> **API 契约测试**：如果项目使用 OpenAPI 契约管理（参考 `api-contract-management` 技能），Mock / 外部依赖测试应使用 MSW 进行前端 Mock 联调，并使用 Schemathesis 等工具进行后端契约合规性测试。`api-contract-management` 的 Step 4 测试指南提供了 MSW 配置、Schemathesis 契约测试和前后端字段一致性校验的完整实现。

> **设计-测试预映射验证**：如果项目在前端/后端设计阶段执行了 `prototype-coverage` 和 `backend-coverage`，测试阶段应验证测试用例是否覆盖了设计阶段预埋的测试关注点（前端 UI 测试关注点 + 后端接口测试关注点）。P0 预映射关注点的覆盖率应达到 100%。
| 回归测试 | 当前版本全量回归，复测上一版本失败项和跳过项 | 全量回归通过率 ≥95%，P0/P1 全闭环 | 测试报告 |
| 覆盖率测试 | 修改文件白盒覆盖率，说明黑盒覆盖差异 | 修改文件覆盖率 ≥80%，或记录不适用原因 | 覆盖率报告 |
| 合规测试 | 文档、版本范围、API 契约、认证、敏感配置、依赖风险 | 无阻塞合规问题 | 合规测试报告 |
| 安全测试 | 输入校验、鉴权、越权、敏感信息、依赖安全 | 无阻塞安全问题 | 合规/安全记录 |
| 性能测试 | 关键接口压测 / 并发用户模拟 / 吞吐量测量 / 响应时间分布 / 资源使用监控 / 前端加载渲染瓶颈 | P50<目标值 / P99<目标值 / 吞吐量不低于基线80% / 无内存泄漏 / CPU<80% / 无阻塞性能退化 | 测试报告或性能记录 |
| 可访问性 / UI 测试 | 表单、焦点、键盘、语义、错误提示、UX 问题 | 关键流程无阻塞可用性问题 | 测试报告或专项记录 |
| 用户验收测试 | 验收目标、验收项、人工审批 | 验收项全部通过或有明确审批结论 | UAT 报告 |
| 测试回溯审计 | 需求追溯矩阵逐项检查/设计/开发记录/测试结果回溯/测试用例RT-ID覆盖率 | 需求测试覆盖 100%（按RT-ID逐项核对），P0/P1 全关闭 | 测试回溯对比审计报告 |

## 后段性能测试指引
后端压测推荐工具：k6（脚本化压测）/ Locust（Python）/ wrk（轻量HTTP）/ ab（快速基准）
压测场景设计流程：基准测试（单用户）→ 负载测试（预期并发）→ 压力测试（极限）→ 稳定性测试（持续运行）
基线建立方法：首个版本在生产环境运行压测3次取中位数作为基线

## 执行规则

1. 不得用局部测试替代完整测试矩阵。
2. 不得因依赖未启动、旧服务占用或 Mock 异常而静默跳过测试。
3. 必须证明测试命中当前版本代码。
4. 必须复测上一版本失败项和跳过项。
5. 必须区分黑盒流程覆盖和白盒代码覆盖。
6. 必须记录实际命令、结果、通过数、失败数、跳过数、覆盖率和关键失败原因。
7. 发现 P0/P1 缺陷时，应回退 Step 3 修复，更新 `DevLogReport` 和开发审计后重新执行相关测试，必要时重新执行完整 Step 4。
8. Step 4 未通过不得进入 Step 5。

## 测试技能速查

流程/门禁→workflow | 文档→doc-management | 入场移交→coding-stage-execution/logic-review | E2E→e2e-test-gen | Web验证→webapp-testing | 探索测试→dogfood | 浏览器诊断→browser-devtools | API契约→api-design | 安全→security-best-practices | 可访问性→accessibility/web-design-guidelines | 前端性能→frontend-performance/react-best-practices | React→react-skills/react-best-practices | 后端→nodejs-backend/python-backend | Vue→vue-skills | 导航→code-review-navigation | TDD→test-driven-development | SQL/Mongo→sql-database/mongodb | Redis→redis/redis-development | 消息→rabbitmq/kafka | 容器→docker | 版本/分支→code-version-backup-management/git-commit
| 测试入场检查和开发移交核对 | `coding-stage-execution`、`code-logic-review` |
| E2E 测试生成 | `e2e-test-gen` |
| 本地 Web 应用功能验证、截图、浏览器日志 | `webapp-testing` |
| 探索式测试、Bug 复现、UX 问题报告 | `dogfood` |
| 浏览器控制台、网络、性能、运行时错误诊断 | `browser-devtools` |
| API 契约和接口行为测试基准 | `api-design` |
| 安全专项测试 | `security-best-practices` |
| 可访问性专项测试 | `accessibility`、`web-design-guidelines` |
| 前端性能专项测试 | `frontend-performance`、`react-best-practices` |
| React 组件架构和渲染风险 | `react-skills`、`react-best-practices`、`composition-patterns` |
| 后端测试和服务诊断 | `nodejs-backend`、`python-backend` |
| Vue 组件和前端状态测试 | `vue-skills` |
| 导航、路由和跳转回归测试 | `code-review-navigation` |
| 缺陷修复后的测试补充 | `test-driven-development` |
| SQL / MongoDB 数据一致性测试 | `sql-database`、`mongodb` |
| Redis、缓存、会话、限流测试 | `redis`、`redis-development` |
| RabbitMQ / Kafka 消息链路测试 | `rabbitmq`、`kafka` |
| 容器、多服务和测试环境验证 | `docker` |
| 性能工程和容量规划基准 | `performance-engineering` |
| 版本、分支、测试基线和缺陷修复记录 | `code-version-backup-management`、`git-commit` |

## 输出要求

测试阶段完成后必须具备：

- {项目名}-测试报告-v{版本号}.md（主文件：含测试计划/API测试/集成测试/合规测试/UAT测试/覆盖率/缺陷闭环/跳过项/E2E证据；性能测试和可访问性测试专项时独立）
- {项目名}-测试用例-v{版本号}.md（独立，需追溯到需求）
- {项目名}-测试回溯对比审计报告-v{版本号}.md（固定存放于 doc\audit\verification）

文档命名、路径和版本规则遵循 `project-document-management`。
文档内容结构和章节模板参考 `project-document-templates` 技能。

## 测试报告最小结构

```markdown
# 测试报告

## 基本信息

- 项目：
- 版本 / 迭代：
- 测试环境：
- 待测分支 / Commit：
- 测试时间：
- 测试结论：通过 / 有条件通过 / 不通过

## 入场检查

说明 `DevLogReport`、`code-logic-review`、开发审计和待测环境是否满足要求。

## 测试矩阵执行结果

| 测试类别 | 命令或方式 | 通过 | 失败 | 跳过 | 结论 | 证据 |
|---|---|---:|---:|---:|---|---|

## 缺陷与闭环

| 缺陷 ID | 级别 | 来源 | 问题 | 修复状态 | 复测结果 |
|---|---|---|---|---|---|

## 覆盖率

说明白盒覆盖率、黑盒覆盖差异、未覆盖原因和是否达标。

## 遗留风险

列出允许遗留的问题、批准依据和后续计划。

## 结论

说明是否允许进入测试回溯审计和 Step 5。
```

## 通过标准

Step 4 可通过的最低条件：

1. 测试矩阵全部执行，或不适用项有明确说明。
2. P0/P1 问题全部关闭。
3. 全量回归通过率 ≥95%。
4. 修改文件白盒覆盖率 ≥80%，或有明确不适用说明。
5. UAT 通过或有明确人工审批结论。
6. 测试报告、覆盖率报告、UAT 报告和测试回溯审计材料齐备。
7. 测试回溯审计允许进入 Step 5。

## 测试追溯 ID 规范

### TT-ID 格式

TT-ID 使用统一格式：`TT-{版本号}-{序号}`

| 模式 | 格式示例 | 说明 |
|------|---------|------|
| 全流程模式 | TT-v2.6.0-001 | 继承 Step 3 的版本号 |
| 独立模式 | TT-EXT-001 | EXT 表示外部来源 |

### TD-ID→TT-ID 映射

测试用例必须同时关联 RT-ID（需求）和 TD-ID（代码）：

```text
测试用例 ID: TT-v2.6.0-001
关联需求: RT-v2.6.0-003
关联代码: TD-v2.6.0-005, TD-v2.6.0-012
测试类型: API 测试
前置条件: ...
测试步骤: ...
预期结果: ...
```

**强制规则**：所有 P0/P1 需求的测试用例必须至少关联一个 TD-ID。

## 内部工作流

Step 4 测试验证采用四轨并行模型。

### 步骤序列

```text
整体: 4.0入场 → 4.1计划 → 4.2环境
后端: 4.3a API测试 → 4.4a 集成测试
前端: 4.3b 组件测试 → 4.4b 前端集成测试    [按需]
第三方: 4.3c 集成测试（Mock/Stub/升级回归） [按需]
汇合: 4.5 E2E测试 → 4.6 回归+覆盖率 → 4.7 专项测试
→ 4.8 UAT → 4.9 缺陷闭环 → 4.10 报告 → 4.11 审计移交
```

### 4.0 入场检查
| 独立模式 | 全流程模式 |
|---------|-----------|
| 可执行代码已存在 | Step 3 移交齐备 + code-logic-review 通过 + 开发审计通过 |

### 4.1~4.2 计划与准备
| 步骤 | 活动 | 产出 |
|------|------|------|
| 4.1 测试计划 + 测试用例 | 分出后端子计划/前端子计划/第三方测试计划，每用例关联 RT-ID+TD-ID | 测试计划 + 测试用例 |
| 4.2 环境验证 | 确认测试环境就绪 | 环境验证记录 |

### 4.3~4.4 并行测试执行
| 步骤 | 轨道 | 活动 |
|------|------|------|
| 4.3a 后端 API 测试 | ⚙️ | 接口功能/错误码/边界验证；**API 契约测试（Schemathesis 合规性校验 + MSW Mock 联调，参考 api-contract-management）** |
| 4.4a 后端集成测试 | ⚙️ | 服务间调用/数据流转验证 |
| 4.3b 前端组件测试 | 🎨 [按需] | 组件渲染/交互/状态验证 |
| 4.4b 前端集成测试 | 🎨 [按需] | 页面流程/路由/状态联调验证 |
| 4.3c 第三方集成测试 | 🔗 [按需] | 第三方接口功能验证 + Mock/Stub 测试 + 版本升级兼容性回归 |

### 4.5 E2E 测试（四轨贯通 — 关键衔接点）
| 条件 | 通过标准 |
|------|---------|
| 始终执行（至少后端+整体） | 全量 E2E 通过率 ≥ 95%；覆盖全部 P0/P1 核心流程 |

### 4.6~4.7 回归与专项
| 步骤 | 活动 |
|------|------|
| 4.6 回归测试 + 覆盖率检查 | 分端统计覆盖率，整体汇总 |
| 4.6b 探索式测试 | dogfood：人工/自动化探索未覆盖场景，记录边界行为和异常发现 |
| 4.7a 安全测试 | 安全渗透测试：输入校验/鉴权越权/敏感信息泄漏/依赖安全扫描全部通过（参考 security-best-practices） |
| 4.7b-1 后端性能测试 | k6/Locust，P50/P99/吞吐量 |
| 4.7b-2 前端性能测试 | Lighthouse/CWV |
| 4.7c 可访问性测试 | WCAG 关键流程检查 |

### 4.8~4.11 闭环与移交
| 步骤 | 活动 |
|------|------|
| 4.8 UAT 验收 | 用户验收确认 |
| 4.9 缺陷闭环 + 修复回归 | 缺陷按端记录（后端/前端/第三方）。P0/P1→回退 Step 3 对应端→修复→重新测试 |
| 4.10 测试报告汇总 | 整体报告 + 各激活轨道分报告 |
| 4.11 测试回溯审计移交 | 审计检查：RT-ID→TT-ID 覆盖 + TD-ID→TT-ID 覆盖 |

## 反模式

测试阶段应避免：

- 只跑冒烟测试就进入部署
- 只跑 E2E 而不做 API、集成、覆盖率和回归
- 用黑盒测试覆盖率替代白盒代码覆盖率
- 命中旧进程或旧容器后仍记录为通过
- 依赖未启动时静默跳过用例
- 不复测上一版本失败项和跳过项
- 不记录测试命令和失败原因
- P0/P1 未关闭就进入 Step 5
- 测试文档缺失仍通过审批

## Design Stage Integration

When called within Step 2: treat `design-stage-execution` as controller, use only for specialty area, record decisions in design doc, do not replace Step 2 review/audit. P0/P1 gap → fix within Step 2, update traceability, rerun review before handoff.

## Requirements Stage Integration

When called within Step 1: treat `requirements-stage-execution` as controller, use only for specialty area, record decisions & acceptance criteria in requirements doc, do not replace Step 1 review/audit. P0/P1 gap → fix within Step 1, update traceability matrix, rerun review before design handoff.

## Operations Stage Integration

When called within Step 5: treat `operations-stage-execution` as controller, record deployment/verification evidence in ops doc, do not replace Step 5 release verification or ops audit. P0/P1 issue → stop or rollback, update records, rerun verification.