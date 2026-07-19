---
name: "code-static-quality-check"
description: "Runs syntax, lint, type, build, symbol, parameter, return, import/export, env and API consistency checks. Invoke during coding before code-logic-review."
---

# Code Static Quality Check（代码静态质量检查）

## 定位

> **编码阶段三技能关系**：本技能与 project-coding-conventions（编码约定）、code-logic-review（代码逻辑审查）共同组成 Step 3 编码阶段的质量保障体系。编码阶段串联执行路径：编码实现 → project-coding-conventions（编码标准）→ 本技能（静态质量检查）→ 开发自测 → code-logic-review（逻辑审查）→ 修复复审 → DevLogReport → 开发审计。
> - project-coding-conventions 定义编码执行时的项目级约定（分层/错误处理/日志/API等），编码实现时必须遵循
> - 本技能在编码之后执行，检查语法/Lint/类型/构建/符号/参数/返回值等 12 类静态问题
> - code-logic-review 在前两者通过后执行，审查需求覆盖/设计一致性/业务逻辑等 11 个维度

本技能用于软件开发流程 Step 3 Coding 阶段的静态质量门禁。它发生在编码实现之后、`code-logic-review` 之前，负责用项目已有工具链检查语法、Lint、类型、构建、符号、参数、返回值、导入导出、环境变量和接口字段一致性。

本技能不替代 `coding-stage-execution`、`code-logic-review`、正式测试或开发审计。它只负责证明代码具备进入逻辑审查和开发审计的基础静态质量，不判断 Step 3 是否完成；Step 3 是否完成由 `coding-stage-execution` 统一判断。

## 触发条件

当用户提出以下需求时，调用本技能：

- 编码完成后检查语法、Lint、类型或构建。
- 检查变量、常量、函数、参数、返回值是否一致。
- 检查 import/export、模块引用、未定义符号或死引用。
- 检查前后端 API 字段、参数、响应结构是否匹配。
- 检查环境变量、配置键、常量枚举、状态码是否一致。
- 在 `code-logic-review`、开发审计、提交、合并或移交测试前做静态质量门禁。

## 阶段位置

```text
编码实现
→ 代码静态质量检查
→ 开发自测
→ code-logic-review
→ 修复复审
→ 更新 DevLogReport
→ 开发审计
→ Step 4 测试
```

小型任务可将静态质量检查和开发自测合并执行，但检查结果必须记录。

## 检查矩阵

| 检查类别 | 必须检查内容 | 通过标准 | 证据 |
|---|---|---|---|
| 语法检查 | 语言解析、语法错误、格式破坏 | 无语法错误 | 命令和结果 |
| Lint 检查 | 代码风格、未使用变量、危险写法、规则违规 | 无阻塞 Lint 错误 | Lint 输出 |
| 类型检查 | TypeScript、Python、Go、Java 等类型约束 | 无阻塞类型错误 | 类型检查输出 |
| 构建检查 | 编译、打包、依赖解析、资源引用 | 构建通过或失败原因已修复 | 构建命令和结果 |
| 符号一致性 | 变量、常量、函数、类、类型、枚举是否定义和引用一致 | 无未定义符号、拼写漂移或死引用 | 检查结果 |
| 参数一致性 | 参数数量、顺序、必填/可选、默认值、类型 | 调用方和被调用方一致 | 类型检查或测试证据 |
| 返回值一致性 | 返回结构、字段、状态、错误对象 | 消费方和提供方一致 | 类型检查或接口自测 |
| import/export | 模块路径、默认导出、命名导出、循环依赖 | 引用可解析，无错误导出 | 构建或 Lint 结果 |
| API 字段映射 | 前后端字段名、请求参数、响应字段、错误码 | 与 API 设计一致，无破坏性漂移 | API 契约检查 |
| 环境和配置 | `.env`、配置键、Feature Flag、端口、密钥占位符 | 命名一致，无真实密钥泄露 | 配置检查记录 |
| 数据字段 | DTO、Schema、数据库字段、迁移字段 | 字段命名和类型一致 | 数据模型检查 |
| 状态与枚举 | 状态码、业务状态、枚举值、分支处理 | 枚举完整，非法状态可拦截 | 代码检查或单测 |
| **圈复杂度检查** | `lizard` 或 `radon cc` | 函数圈复杂度 ≤ 15 | 每个函数独立检查 | P0：>15 阻断 |
| **代码重复率检查** | `jscpd` 或 `pylint --duplicate-code` | 新代码重复率 ≤ 3% | 按新增文件统计 | P0：>3% 阻断 |
| **架构合规检查** | 自定义 lint 规则 | 禁止跨层依赖（Controller→Repository 直接调用等） | 按层关系检查 | P0：违规阻断 |

## 工具选择

根据项目实际技术栈优先使用已有脚本，不强行引入新工具。

| 技术栈 | 优先命令示例 |
|---|---|
| TypeScript / JavaScript |  `npm run lint`、 `npm run typecheck`、`tsc --noEmit`、 `npm run build`、 `npm test` |
| React / Next.js |  `npm run lint`、 `npm run typecheck`、 `npm run build`、组件测试、关键页面 smoke test |
| Vue / Vite |  `npm run lint`、`vue-tsc --noEmit`、 `npm run build`、`vitest run` |
| Node.js 后端 |  `npm run lint`、 `npm run test`、 `npm run build`、API smoke test |
| Python | `ruff check`、`mypy` 或 `pyright`、`pytest`、启动检查 |
| Go | `go test ./...`、`go vet ./...`、`gofmt` 检查 |
| Java | `mvn test` / `gradle test`、编译检查、静态分析插件 |

如果项目没有对应脚本，应先读取 `package.json`、`pyproject.toml`、`Makefile`、CI 配置或 README，优先执行项目已有约定。

## 执行规则

1. **不得跳过静态门禁**：除非用户明确批准，编码完成后必须做语法、Lint、类型或构建检查中的适用项。
2. **不得新增不必要工具链**：项目已有脚本优先；缺少脚本时先记录缺口，不擅自重构工程。
3. **不得掩盖失败**：失败命令、错误摘要、影响范围和修复状态必须记录。
4. **不得用静态检查替代逻辑审查**：静态检查通过后仍需执行 `code-logic-review`。
5. **不得用静态检查替代测试阶段**：它只证明基础质量，不证明业务行为完整正确。
6. **P0/P1 静态问题必须在 Step 3 修复**：例如无法构建、未定义符号、关键参数不匹配、真实密钥泄露。
7. **检查结果必须写入 `DevLogReport`**：至少包含命令、结果、失败项、修复方式和剩余风险。
8. **圈复杂度门禁**：任何函数圈复杂度 > 15 的提交必须重构后方可通过，不可跳过
9. **代码重复率门禁**：新代码重复率 > 3% 必须消除重复后方可通过

## 严重级别

| 级别 | 示例 | 处理 |
|---|---|---|
| P0 | 无法启动、无法构建、真实密钥泄露、核心模块 import 失败 | 必须修复，不得进入 `code-logic-review` |
| P1 | 核心 API 参数不匹配、返回结构漂移、关键类型错误、数据库字段不一致 | 必须修复或获得明确批准 |
| P2 | 非核心 Lint 问题、局部命名不一致、低风险死代码 | 记录风险，可视版本目标修复 |
| P3 | 格式、注释、轻微风格建议 | 可后续优化 |

## 输出模板

静态质量检查结果应写入 `DevLogReport` 的“静态质量检查”章节。

```markdown
## 静态质量检查

| 检查项 | 命令或方式 | 结果 | 失败摘要 | 处理 |
|---|---|---|---|---|
| 语法 / Lint |  | 通过 / 失败 / 不适用 |  |  |
| 类型检查 |  | 通过 / 失败 / 不适用 |  |  |
| 构建检查 |  | 通过 / 失败 / 不适用 |  |  |
| 符号与参数一致性 |  | 通过 / 失败 / 不适用 |  |  |
| API / 配置字段一致性 |  | 通过 / 失败 / 不适用 |  |  |

结论：通过 / 有条件通过 / 不通过
剩余风险：
是否允许进入 code-logic-review：是 / 否
```

## 技能协作

| 场景 | 应调用技能 |
|---|---|
| Coding 阶段主控 | `coding-stage-execution` |
| 后续代码逻辑审查 | `code-logic-review` |
| 命名规范 | `universal-naming-conventions` |
| API 参数和响应一致性 | `api-design` |
| TypeScript / React / Next.js | `react-skills`、`react-best-practices`、`composition-patterns` |
| Vue / Vite | `vue-skills` |
| Node.js 后端 |  `nodejs-backend` |
| Python 后端 | `python-backend` |
| 数据字段和迁移一致性 | `sql-database`、`mongodb` |
| 安全和密钥泄露 | `security-best-practices` |
| 本地 Web 验证 | `webapp-testing`、`browser-devtools` |
| 文档和版本记录 | `project-document-management` |

## Coding Stage Integration

When this skill is used during the formal coding stage, coordinate with `coding-stage-execution`.

- Treat `coding-stage-execution` as the Step 3 coding-stage controller.
- Run this skill after implementation and before `code-logic-review` whenever syntax, lint, type, build, symbol, parameter, return, import/export, env, or API consistency is relevant.
- Record actual commands, results, failure summaries, fixes, skipped items, and remaining risks in `DevLogReport`.
- Do not let this skill replace `code-logic-review`, development audit, or the formal Step 4 testing matrix.
- If a P0/P1 static quality issue is found, fix it within Step 3, rerun the relevant checks, update `DevLogReport`, then proceed to `code-logic-review`.
