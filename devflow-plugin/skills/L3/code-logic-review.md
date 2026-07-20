---
name: "code-logic-review"
description: "Reviews implemented code logic against requirements, design, APIs, data flow, edge cases, and tests. Invoke after coding before development audit."
---

# Code Logic Review（代码逻辑审查）

## 定位

> **编码阶段三技能关系**：本技能与 project-coding-conventions（编码约定）、code-static-quality-check（静态质量检查）共同组成 Step 3 编码阶段的质量保障体系。编码阶段串联执行路径：编码实现 → project-coding-conventions（编码标准）→ code-static-quality-check（静态质量检查）→ 开发自测 → **AI 初筛** → 本技能（逻辑审查）→ 修复复审 → DevLogReport → 开发审计。
> - project-coding-conventions 定义编码执行时的项目级约定（分层/错误处理/日志/API等），编码实现时必须遵循
> - code-static-quality-check 在前者通过后执行，检查语法/Lint/类型/构建等 12 类静态问题
> - 本技能在前两者通过后执行，审查需求覆盖/设计一致性/业务流程/状态流转/API契约/可维护性/数据一致性/权限安全/异常处理/可测试性/静态质量证据等 11 个维度

本技能用于在编码完成后、开发审计之前，对实现代码进行正式逻辑审查。它是开发阶段内部的质量门禁，输出作为 `DevLogReport` 和开发审计的重要输入。

本技能不替代正式测试阶段，也不替代开发审计。它负责发现开发阶段内应由开发团队先修复的问题，降低审计和测试阶段返工成本。

推荐位置：

```text
编码实现 → 代码静态质量检查 → 开发自测 → AI 初筛 → code-logic-review → 修复复审 → 更新 DevLogReport → 开发审计
```

## 触发条件

当用户提出以下需求时，调用本技能：

- 编码完成后检查代码逻辑
- 功能实现后判断是否可以进入开发审计或测试
- 审查代码是否符合需求、设计、API 契约和数据流
- 审查业务逻辑、状态流转、异常路径、权限边界或数据一致性
- 生成代码审查记录或更新 `DevLogReport`
- 在提交 PR、合并分支、移交测试前做逻辑门禁
- 对开发阶段产出进行“需求-设计-代码-自测”一致性检查

如果用户只要求安全审查，应调用 `security-best-practices`；如果只要求 UI/UX 审查，应调用 `web-design-guidelines`；如果只要求 React/Next.js 性能审查，应调用 `react-best-practices`。本技能可协调这些专项审查，但不替代它们的细则。

## 输入材料

执行审查前，应尽量收集以下材料：

| 输入 | 用途 |
|---|---|
| 需求文档 | 判断需求覆盖和验收标准 |
| 版本规划或 Phase 迭代计划 | 判断当前版本范围和优先级 |
| 系统架构设计文档 | 判断模块边界和架构一致性 |
| 前端架构 / UI 设计文档 | 判断页面、组件、路由、状态、交互是否一致 |
| API 接口设计文档 | 判断接口契约、错误码、鉴权和响应格式 |
| 数据库或数据模型设计 | 判断数据结构、迁移、事务和一致性 |
| 代码变更或 diff | 审查实际实现 |
| 静态质量检查结果 | 判断语法、Lint、类型、构建、符号、参数、返回值、import/export、配置和 API 字段一致性是否已通过 |
| 自测结果 | 判断实现是否具备基本验证证据 |
| `DevLogReport` 草稿 | 检查开发记录是否完整 |

如果材料缺失，应在审查结论中明确标记“证据不足”，并说明缺失材料对结论的影响。

## 审查原则

1. 先对照需求和设计，再评价代码风格。
2. 先审查 P0/P1 主链路，再审查边界和优化项。
3. 先找会阻塞测试或上线的问题，再找可维护性改进。
4. 发现问题必须说明影响、证据和建议修复方式。
5. 不把静态质量检查责任后移到本技能；若缺少 `code-static-quality-check` 或等效结果，应标记证据不足。
6. 不把正式测试责任前移到本技能，但必须检查开发自测证据是否足够。
7. 不因局部自测通过就认为代码可进入测试，必须检查需求、设计、数据流和异常路径。
8. 对安全、性能、UI/UX、React 架构等专项问题，应调用对应专项技能补充审查。

## 审查维度

### 1. 需求覆盖

检查：

- P0/P1 需求是否全部实现
- 是否有需求项未对应到代码
- 是否实现了不在当前范围内的功能
- 验收标准是否具备代码或自测证据
- 是否存在需求理解偏差

结论应说明需求覆盖率、遗漏项和影响。

### 2. 设计一致性

检查：

- 实现是否符合系统架构设计
- 模块边界是否被破坏
- 前端、后端、Agent、数据库职责是否清晰
- 是否存在未经记录的设计偏差
- 是否引入未批准的新技术、新依赖或新架构

重大设计偏差必须要求回退设计确认，或在 `DevLogReport` 中记录批准依据。

### 3. 业务流程

检查：

- 主流程是否完整闭环
- 分支流程是否处理
- 失败流程是否处理
- 重试、取消、回滚、补偿逻辑是否合理
- 是否存在重复提交、重复执行、漏执行问题
- 是否有隐藏的顺序依赖或竞态条件

### 4. 状态流转

检查：

- 状态枚举是否完整
- 状态转换是否合法
- 非法状态是否被拦截
- 状态更新是否具备原子性
- 前端展示状态和后端业务状态是否一致
- 状态回退、取消、失败、超时是否处理

### 5. API 契约

检查：

- API 路径、方法、参数、响应是否符合设计
- 错误码和错误结构是否统一
- 鉴权和权限传播是否正确
- 前后端字段命名和类型是否一致
- 分页、排序、过滤是否符合约定
- 是否有破坏性变更未记录

涉及 API 设计问题时，应调用 `api-design`。

### 6. 可维护性

检查：

- 函数、类、组件是否职责清晰
- 是否存在重复代码
- 是否存在过长函数或过深嵌套
- 是否存在隐式耦合
- 命名是否清晰一致
- 新增依赖是否必要
- 是否混入无关重构
- 是否留下调试代码、临时代码或 TODO

**否决条件**（满足任一即审查不通过，必须修复）：
1. 高复杂度函数（圈复杂度 >15）数量 > 5 个
2. 代码重复率 > 5%

**证据关联要求**：可维护性审查结论必须引用静态质量检查的具体数据（复杂度统计、重复率报告），不得只写"可维护性良好"等主观判断，必须有数据支撑。

### 7. 数据一致性

检查：

- 数据库读写是否符合数据模型
- 事务边界是否合理
- 并发写入是否安全
- 幂等性是否满足业务要求
- 缓存和数据库是否可能不一致
- 迁移脚本是否可执行、可回滚或有风险说明
- 查询条件、索引、分页和排序是否合理

涉及 SQL 或数据库专项问题时，应调用 `sql-database`、`mongodb` 或相关数据技能。

### 8. 权限与安全边界

检查：

- 是否验证用户身份
- 是否检查角色和资源权限
- 是否存在越权访问
- 是否信任前端传入的敏感字段
- 是否泄露敏感信息到日志、响应或前端状态
- 是否存在明显注入、XSS、CSRF、命令执行等风险

发现安全风险时，应调用 `security-best-practices` 进行专项审查。

### 9. 异常处理与日志

检查：

- 错误是否被捕获
- 错误响应是否一致
- 用户提示是否友好
- 日志是否包含必要上下文
- 日志是否避免敏感信息
- 外部服务失败、超时、重试和降级是否处理
- 异常是否会导致数据半完成状态

### 10. 可测试性和测试证据

检查：

- 核心逻辑是否可单测
- 关键路径是否有测试或自测证据
- 测试是否覆盖成功、失败和边界场景
- 自测命令、结果、失败原因是否记录
- 是否存在跳过测试却未说明原因的情况
- 是否需要补充 E2E、集成或白盒覆盖率测试

需要生成 E2E 测试时，可调用 `e2e-test-gen`；需要本地 Web 验证时，可调用 `webapp-testing`。

### 11. 静态质量证据

检查：

- 是否已执行语法、Lint、类型和构建检查
- 是否存在未定义变量、常量、函数、类型、枚举或 import/export 错误
- 参数数量、参数类型、返回值结构是否有静态证据支持
- API 字段、配置键、环境变量和数据字段是否有一致性检查记录
- 静态检查失败项是否已修复并复跑

缺少静态质量证据时，应要求补齐 `code-static-quality-check` 结果，不能直接给出"通过"。

### 12. AI Code Review 门禁

检查：

- 是否已完成 AI 初筛审查
- AI 审查发现的 P0/P1 问题是否全部修复
- AI 审查工具名称和输出摘要是否记录
- AI 审查结论是否纳入最终审查结论

AI 初筛在人工审查之前执行，作为降低人工审查负荷的前置步骤。AI 初筛发现的 P0/P1 问题必须先修复，然后才能进入人工审查环节。

## 问题严重级别

| 级别 | 含义 | 处理规则 |
|---|---|---|
| P0 | 阻塞主流程、数据损坏、安全高危、无法启动或无法验证 | 必须修复，不得进入开发审计 |
| P1 | 影响核心需求、接口契约、权限、状态或关键异常路径 | 必须修复或获得明确批准，不得直接进入测试 |
| P2 | 影响次要流程、可维护性、边界场景或局部性能 | 记录风险，可视版本目标决定是否修复 |
| P3 | 代码风格、轻微优化、非阻塞建议 | 可记录为后续改进 |

## 跨模型交叉审查（推荐）

对于关键模块或安全敏感的代码逻辑审查，建议使用与编码时不同的 AI 模型进行独立二次审查（例如编码使用模型 A，审查使用模型 B）。不同模型对同一问题的视角差异可能发现单一模型忽略的问题，包括但不限于：
- 模型 A 视为正确的边界条件处理，模型 B 视为缺失
- 模型 A 的安全假设，模型 B 指出漏洞
- 模型 A 的性能取舍，模型 B 指出更优方案

交叉审查结论不替代本技能的正式审查结论，仅作为补充证据记录在审查记录中。

## 审查结论规则

| 结论 | 条件 | 后续处理 |
|---|---|---|
| 通过 | 无未解决 P0/P1，静态质量证据和开发自测证据足够，偏差已记录 | 可更新 `DevLogReport` 并进入开发审计 |
| 有条件通过 | 仅存在 P2/P3 或已批准偏差 | 记录风险和后续计划后进入开发审计 |
| 不通过 | 存在 P0/P1、设计重大偏差、静态质量证据不足、开发自测证据不足、安全阻塞或 AI Code Review 发现的 P0/P1 问题未全部修复 | 回到编码阶段修复并复审 |
| 证据不足 | 缺少需求、设计、代码变更、静态质量检查或自测结果 | 补齐材料后重新审查 |

## 输出要求

审查输出应写入 `DevLogReport` 的“代码逻辑审查”章节，或在需要独立文件时写为：

```text
{项目名}-代码逻辑审查记录-v{版本号}.md
```

文档命名、存放和版本规则遵循 `project-document-management`。

## 审查记录模板

```markdown
# 代码逻辑审查记录

## 基本信息

- 项目：
- 版本 / 迭代：
- 审查对象：
- 关联需求：
- 关联设计：
- 审查时间：
- 审查结论：通过 / 有条件通过 / 不通过 / 证据不足

## 审查范围

说明本次审查覆盖的代码、模块、接口、页面、数据库变更、静态质量证据和开发自测证据。

## 需求覆盖

| 需求项 | 实现位置 | 证据 | 结论 | 备注 |
|---|---|---|---|---|

## 设计一致性

| 设计项 | 实现情况 | 偏差 | 影响 | 处理建议 |
|---|---|---|---|---|

## 问题清单

| ID | 级别 | 类型 | 位置 | 问题 | 影响 | 建议 |
|---|---|---|---|---|---|---|

## 静态质量检查证据

| 检查项 | 命令或方式 | 结果 | 备注 |
|---|---|---|---|
| 语法 / Lint / 类型 / 构建 |  |  |  |
| 符号 / 参数 / 返回值 / 配置一致性 |  |  |  |

## 自测证据

| 检查项 | 命令或方式 | 结果 | 备注 |
|---|---|---|---|

## 修复与复审

| 问题 ID | 修复方式 | 复审结果 | 备注 |
|---|---|---|---|

## 剩余风险

列出允许保留的 P2/P3 问题、已批准偏差和测试阶段需要重点关注的风险。

## 最终结论

说明是否允许进入开发审计。
```

## 技能协作

| 场景 | 应调用技能 |
|---|---|
| 编码阶段主控 | `coding-stage-execution` |
| 语法、Lint、类型、构建和一致性检查 | `code-static-quality-check` |
| 五步流程和审计门禁 | `project-development-workflow` |
| 审查记录和 DevLogReport 管理 | `project-document-management` |
| API 契约问题 | `api-design` |
| 安全问题 | `security-best-practices` |
| React / Next.js 性能和渲染问题 | `react-best-practices` |
| React 组件架构问题 | `composition-patterns` |
| UI/UX 和可访问性问题 | `web-design-guidelines`、`accessibility` |
| 前端运行时和性能调试 | `browser-devtools`、`frontend-performance` |
| Web 应用行为验证 | `webapp-testing` |
| E2E 测试补充 | `e2e-test-gen` |
| 数据库逻辑问题 | `sql-database`、`mongodb` |
| 缓存和消息问题 | `redis`、`redis-development`、`rabbitmq`、`kafka` |
| 版本分支和提交前门禁 | `code-version-backup-management`、`git-commit` |

## 反模式

审查时避免：

- 只看代码风格，不对照需求和设计
- 用本地冒烟测试代替逻辑审查
- 发现 P0/P1 仍允许进入开发审计
- 缺少静态质量检查或测试证据却给出“通过”结论
- 将安全、性能、UI 专项问题混在普通建议中不分级
- 不记录设计偏差和剩余风险
- 把开发阶段应修复的问题留给测试阶段

## Testing Stage Integration

When this skill is used during the formal testing phase, coordinate with testing-stage-execution.

- Treat testing-stage-execution as the Step 4 testing-stage controller.
- Record actual commands, environment, evidence, pass/fail/skip counts, defects, and remaining risks in the appropriate test report.
- Do not let a successful partial or diagnostic check replace the complete Step 4 testing matrix.
- If a P0/P1 issue is found, route it back to Step 3 for repair, update DevLogReport and development audit evidence if needed, then retest through testing-stage-execution.

## Design Stage Integration

When this skill is used during the formal design stage, coordinate with design-stage-execution.

- Treat design-stage-execution as the Step 2 design-stage controller.
- Use this skill only for its specialty area; do not use it to declare the whole design stage complete.
- Record design decisions, assumptions, alternatives, risks, open questions, and downstream impacts in the relevant design document.
- Do not let a successful specialty design review replace the Step 2 design review or requirements-architecture audit.
- If a P0/P1 design gap is found, fix it within Step 2, update the relevant design document and traceability matrix, then rerun the relevant design review before development handoff.