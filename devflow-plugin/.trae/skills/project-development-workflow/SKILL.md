---
name: "project-development-workflow"
description: "Implements Step 0 version planning plus 5-step development workflow with Dev/Test/Pro environments. Invoke for project workflow, version planning, or environment guidance."
---

# Project Development Workflow (项目开发 Step 0 + 五步流程)

## 技能三层架构说明

本流程体系采用三层技能架构，控制 LLM 执行深度不超过 2 层：

### 三层职责边界

| 层 | 名称 | 职责 | 加载策略 | 能否独立执行 |
|:--:|:-----|:-----|:---------|:-----------:|
| L1 | 总控调度层 | **定义流程框架、门禁条件、阶段间交接、产出矩阵**。不执行具体工作，只调度 L2 | 运行时预加载 | ❌ 不独立执行 |
| L2 | 阶段执行层 | **定义阶段内部工作流的每一步（输入→活动→产出→通过标准）**。是 LLM 执行时实际操作的"施工图纸" | 运行时预加载 | ✅ 可直接执行 |
| L3 | 专项参考层 | **提供某垂直领域的完整知识、阈值、工具链和最佳实践**。内容由 L2 内联速查引用，不定义执行步骤 | 按需加载 | ⚠️ 仅提供知识，不含执行流程 |

### 核心约束

1. **L2 是执行主体，L3 是知识来源**：L2 的工作流步骤是 LLM 执行时唯一遵循的施工图纸。L3 的内容（阈值、工具、规则）必须通过 L2 的工作流步骤转化为可执行的门禁，不能指望 LLM 自行跳转到 L3 文件执行。
2. **内联即承诺**：L2 中内联 L3 速查内容的每一块，都必须在 L2 的**内部工作流步骤表**中找到对应的显式步骤（输入→活动→产出→通过标准）。速查不是装饰，是承诺。
3. **内联≠执行**：仅仅是把 L3 的内容复制到 L2 的"速查"章节，但没有在 L2 的工作流中增加对应的步骤，等于没有执行。LLM 会跳过它。
4. **执行链深度恒为 2 层**：L1 调度 L2，L2 执行时读取自身内联的 L3 速查（不跳出文件查找 L3 技能）。所以 L3 内容必须出现在 L2 的工作流步骤中，否则永远不会被执行。
5. **L3 不可定义流程**：L3 技能只定义知识（阈值/工具/模板），不定义"先做什么再做什么"。执行顺序由 L2 的工作流负责编排。

> **运行时规则**：Layer 1→Layer 2→Layer 3 的执行链深度恒为 2 层。Layer 3 技能文件在运行时不被预加载，仅在必要场景下显式请求加载。

### 三层示例对照

| 场景 | L1 做的事 | L2 做的事 | L3 做的事 |
|:-----|:----------|:----------|:----------|
| 检查代码质量 | 定义"Step 3 必须经过代码质量门禁才进入 Step 4" | 3.4 步定义"执行静态质量检查"，产出"质量检查记录" | `code-static-quality-check` 提供 12 类检查项的具体阈值和工具命令 |
| 发布版本 | 定义"Step 5 必须经过发布入场检查才上线" | 5.1 步定义"版本号自动更新"，产出"更新后的 devflow-config.json" | `code-version-backup-management` 提供 tag/backup/回滚的具体命令 |
| UI 设计审查 | 定义"Step 2 设计评审覆盖率≥95%" | 2.8a 步定义"后端覆盖检查"，2.8b 定义"前端覆盖检查" | `prototype-coverage` 提供七步检查流程表格 |
| 安全审计 | 定义"Step 2 安全设计必须纳入审计" | 2.6a 步定义"安全设计评审"，产出"安全审查记录" | `security-design-review` 提供威胁建模方法和数据分类标准 |



This skill implements a standardized project development workflow with Step 0 version planning, the five-step delivery process, and three-tier environment management (Dev/Test/Pro).

## Step 0 + Five-Step Development Process

### Step 0: Version Planning (需求前置 / 版本规划)

- **0.1 版本规划阶段执行**：调用 `version-planning-stage-execution` 作为 Step 0 主控技能，完成版本目标、范围、优先级、路线图、Phase拆分、资源依赖、风险约束和高层验收目标。
- **0.2 全部版本规划**：维护版本规划总纲、版本迭代路线图、候选需求池、版本范围变更总记录、版本发布策略总则。
- **0.3 单版本规划**：为当前版本创建单版本规划文档、本版本Backlog、Phase迭代计划、版本规划评审记录、单版本范围变更记录、版本成功指标说明和版本发布策略草案。
- **0.4 版本规划评审**：确认当前版本是否允许进入 Step 1 需求分析；未确认版本目标、范围、优先级和风险时，不得进入需求阶段。
- **文档引用**：业务背景、用户反馈、线上问题、运营数据、竞品/市场信息、技术债和历史版本记录。
- **文档产出**：版本规划总纲、版本迭代路线图、候选需求池、版本范围变更总记录、版本发布策略总则、单版本规划文档、本版本Backlog、Phase迭代计划、版本规划评审记录、单版本范围变更记录、版本成功指标说明、版本发布策略草案、版本依赖清单、版本风险清单、版本优先级评估记录（详见 `project-document-management` 技能）。
- **Requires human approval before proceeding to Step 1**

### Step 1: Requirements Analysis (需求分析)

- **1.1 需求阶段执行**：调用 `requirements-stage-execution` 作为 Step 1 主控技能，完成需求入场检查、需求来源归档、干系人与用户角色分析、业务目标、用户场景、用户故事、业务流程、功能/非功能/数据/权限/UI/接口需求、验收标准、需求追溯、需求评审和设计移交。
- **1.2 需求规范矩阵**：需求矩阵、执行顺序、专项需求技能调用、需求产物和通过标准，统一由 `requirements-stage-execution` 执行。
- **1.3 需求评审**：评审需求完整性、一致性、范围合规性、可设计性和可测试性。
- **1.4 需求审计**：关联审计 → 需求评估报告（由审计师执行），审计输入必须包含需求追溯矩阵、验收标准清单和需求基线说明。
- **文档引用**：版本规划总纲、版本迭代路线图、单版本规划文档、本版本Backlog、Phase迭代计划、版本规划评审记录。
- **文档产出**：开发需求文档、需求入场检查记录、需求来源清单、干系人与用户角色表、业务目标说明、用户场景说明、用户故事清单、业务流程说明、功能需求清单、非功能需求说明、数据需求说明、权限与安全需求说明、UI/UX需求说明、原型草案、接口与集成需求说明、范围边界说明、验收标准清单、需求优先级表、需求追溯矩阵、需求评审记录、需求基线说明、设计移交材料（详见 `project-document-management` 技能）；关联审计 → 需求评估报告（固定存放于 `doc\audit\assessment`）；版本范围变更须回写 Step 0 文档。
- **Requires human approval before proceeding to Step 2**

#### Step 1 Requirements Control Boundary（需求阶段控制边界）

`project-development-workflow` 只定义 Step 1 的阶段门禁、输入输出、审计关系和是否允许进入 Step 2；需求规范矩阵、执行顺序、需求产物细则和专项技能调用，统一由 `requirements-stage-execution` 执行。

Step 1 的不可变门禁如下：

1. **必须调用 `requirements-stage-execution`**：所有正式需求阶段工作必须由该技能主控。
2. **不得扩大 Step 0 范围**：新增需求必须回写候选需求池或触发单版本范围变更记录。
3. **必须建立需求追溯矩阵**：版本目标、本版本 Backlog、需求和验收标准必须可追溯。
4. **P0/P1 需求必须有验收标准**：无验收标准不得进入 Step 2。
5. **必须完成需求评审**：P0/P1 需求缺口未闭环，不得进入 Step 2。
6. **Step 1 未通过不得进入 Step 2**：需求评审、需求追溯、需求基线和设计移交未通过时，不得进入设计阶段。

需求类别、通过标准和强制产出以 `requirements-stage-execution` 与 `project-document-management` 为准。

### Step 2: Architecture & Design (架构与设计)

- **2.1 设计阶段执行**：调用 `design-stage-execution` 作为 Step 2 主控技能，完成设计入场检查、需求-设计追溯、系统/Agent/前端/UI/API/数据/安全/性能/部署/可观测性设计、设计评审和审计移交。
- **2.2 设计规范矩阵**：设计矩阵、执行顺序、专项设计技能调用、设计产物和通过标准，统一由 `design-stage-execution` 执行。
- **2.3 设计评审**：评审设计完整性、可开发性、可测试性、风险和偏差。
- **2.4 设计审计**：关联审计 → 需求架构对比审计报告（由审计师执行），审计输入必须包含需求设计追溯矩阵和完整设计文档矩阵。
- **文档引用**：需求文档、需求评审记录、单版本规划文档、本版本Backlog、Phase迭代计划、版本规划评审记录。
- **文档产出**：设计入场检查记录、系统架构设计文档、Agent架构设计文档、前端架构设计文档、UI设计文档、原型设计说明、Figma设计交付说明、设计系统说明、API接口设计文档、数据库设计文档、数据字典、缓存与消息设计说明、安全设计说明、性能与容量设计说明、可观测性设计说明、部署架构草案、设计评审记录、需求设计追溯矩阵、需求架构对比审计移交材料、开发测试移交说明（详见 `project-document-management` 技能）。
- **Requires human approval before proceeding to Step 3**

#### Step 2 Design Control Boundary（设计阶段控制边界）

`project-development-workflow` 只定义 Step 2 的阶段门禁、输入输出、审计关系和是否允许进入 Step 3；设计规范矩阵、执行顺序、设计产物细则和专项技能调用，统一由 `design-stage-execution` 执行。

Step 2 的不可变门禁如下：

1. **必须调用 `design-stage-execution`**：所有正式设计阶段工作必须由该技能主控。
2. **不得以单项设计替代完整设计矩阵**：UI、API、数据库或系统架构任一专项设计都不能单独代表 Step 2 完成。
3. **必须建立需求-设计追溯**：P0/P1 需求必须映射到明确设计项。
4. **必须完成设计评审**：P0/P1 设计缺口未闭环，不得进入 Step 3。
5. **必须完成设计审计移交**：需求架构对比审计所需材料必须齐备。
6. **Step 2 未通过不得进入 Step 3**：设计评审、需求设计追溯和需求架构对比审计未通过时，不得进入开发阶段。

设计类别、通过标准和强制产出以 `design-stage-execution` 与 `project-document-management` 为准。

### Step 3: Development (开发)

- **3.1 编码阶段执行**：调用 `coding-stage-execution` 作为开发阶段主控技能，完成编码准备、任务拆解、环境确认、实现计划、编码实现、代码静态质量检查、开发自测、代码逻辑审查、修复复审、DevLogReport 更新和测试移交准备。
- **3.2 编码实现**：后端Agent开发、前端开发、API实现、数据库变更、配置更新、集成逻辑和必要的最小可验证增量。
- **3.3 代码静态质量检查**：编码实现完成后，必须调用 `code-static-quality-check` 或执行等效检查，完成语法、Lint、类型、构建、符号、参数、返回值、import/export、环境变量、配置键和 API 字段一致性检查；未解决 P0/P1 静态质量问题不得进入 `code-logic-review`、开发审计或 Step 4。
- **3.4 开发自测**：静态质量检查通过后，执行单元、组件、API smoke、本地联调、核心流程、异常路径和迁移验证；开发自测不能替代正式 Step 4 测试。
- **3.5 代码逻辑审查**：静态质量检查和开发自测完成后，必须调用 `code-logic-review`，在开发审计前完成需求覆盖、设计一致性、业务逻辑、API契约、数据一致性、异常路径、权限边界、静态质量证据和自测证据审查。
- **3.6 问题修复与复审**：`code-static-quality-check` 或 `code-logic-review` 发现的 P0/P1 问题必须在开发阶段内修复并复审；未解决的 P0/P1 问题不得进入开发审计或 Step 4。
- **3.7 开发审计**：关联审计 → 开发设计对比审计报告、UI需求对比审计报告（由审计师执行），审计输入必须包含 DevLogReport、静态质量检查记录、代码逻辑审查记录和修复复审记录。
- **文档引用**：需求文档、系统架构设计文档、Agent架构设计文档、前端架构设计文档、UI设计文档、API接口设计文档、Phase迭代计划、静态质量检查记录、代码逻辑审查记录。
- **3.8 版本控制**：开发阶段的分支管理、提交规范、版本号和备份由 `code-version-backup-management` 技能定义，`coding-stage-execution` 负责执行。
- **文档产出**：DevLogReport（强制性，详见 `project-document-management` 技能；静态质量检查记录和代码逻辑审查记录应作为 DevLogReport 强制章节，必要时可独立成文档）
- **Requires human approval before proceeding to Step 4**

#### Step 3 Development Control Boundary（开发阶段控制边界）

`project-development-workflow` 只定义 Step 3 的阶段门禁、输入输出、审计关系和是否允许进入 Step 4；开发规范矩阵、执行顺序、静态质量检查、开发自测、代码逻辑审查、DevLogReport 和测试移交细则，统一由 `coding-stage-execution` 执行。

Step 3 的不可变门禁如下：

1. **必须调用 `coding-stage-execution`**：所有正式开发阶段工作必须由该技能主控。
2. **Step 2 未通过不得进入 Step 3**：设计评审、需求设计追溯和需求架构对比审计未通过时，不得开始正式编码。
3. **必须执行 `code-static-quality-check`**：语法、Lint、类型、构建、符号、参数、返回值、import/export、环境变量、配置键和 API 字段一致性必须有检查证据。
4. **P0/P1 静态质量问题必须关闭**：未解决的 P0/P1 静态质量问题不得进入 `code-logic-review`、开发审计或 Step 4。
5. **必须执行 `code-logic-review`**：代码逻辑审查必须覆盖需求、设计、业务逻辑、API、数据、权限、异常、静态质量证据和自测证据。
6. **P0/P1 代码逻辑问题必须关闭**：未解决的 P0/P1 代码逻辑问题不得进入开发审计或 Step 4。
7. **必须完成开发审计移交**：DevLogReport、静态质量检查记录、代码逻辑审查记录、修复复审记录和开发审计材料不完整时，不得进入 Step 4。

开发类别、通过标准和强制产出以 `coding-stage-execution`、`code-static-quality-check`、`code-logic-review` 与 `project-document-management` 为准。

### Step 4: Testing (测试)

- **4.1 测试阶段执行**：调用 `testing-stage-execution` 作为测试阶段主控技能，完成测试入场检查、测试计划、测试用例、环境验证、完整测试矩阵执行、缺陷闭环、报告汇总和测试回溯审计移交。
- **4.2 测试入场门禁**：必须确认 `coding-stage-execution`、`code-static-quality-check`、`code-logic-review`、DevLogReport 和开发审计均已完成；未解决 P0/P1 静态质量问题或代码逻辑问题不得进入 Step 4。
- **4.3 测试执行**：API测试、Agent集成测试、合规测试、端到端测试、Mock/外部依赖测试、回归测试、覆盖率测试、UAT验收和专项测试。
- **4.4 全面测试门禁**：所有测试环节必须执行完整测试矩阵，不得只运行局部测试或以单项验证替代全量验证。
- **4.5 测试审计**：关联审计 → 测试回溯对比审计报告（由审计师执行），审计输入必须包含需求追溯矩阵、完整测试子报告、覆盖率报告、UAT报告、缺陷闭环和跳过项说明（审计时按需求追溯矩阵RT-ID逐项核对测试覆盖）。
- **文档引用**：需求文档、系统架构设计文档、API接口设计文档、DevLogReport、静态质量检查记录、代码逻辑审查记录、开发审计报告、Phase迭代计划。
- **文档产出**：测试计划、测试用例、测试报告、用户验收测试报告、API测试报告、集成测试报告、合规测试报告、覆盖率报告、缺陷闭环记录、测试跳过项说明、E2E测试证据、性能测试记录、可访问性测试记录；测试回溯对比审计报告固定存放于 `doc\audit\verification`（详见 `project-document-management` 技能）
- **Requires human approval before proceeding to Step 5**

#### Step 4 Testing Control Boundary（测试阶段控制边界）

`project-development-workflow` 只定义 Step 4 的阶段门禁、输入输出、审计关系和是否允许进入 Step 5；测试矩阵、执行顺序、测试命令记录、缺陷复测、覆盖率细则、UAT 和测试回溯审计材料准备，统一由 `testing-stage-execution` 执行。

Step 4 的不可变门禁如下：

1. **必须调用 `testing-stage-execution`**：所有正式测试阶段工作必须由该技能主控。
2. **不得以局部测试替代完整测试矩阵**：局部测试只能作为诊断或回归补充。
3. **必须验证当前待测版本**：如命中旧进程、旧容器或旧配置，必须重启或替换后复测。
4. **必须记录测试证据**：测试报告必须包含实际命令、执行结果、通过数、失败数、跳过数、覆盖率和关键失败原因。
5. **必须闭环 P0/P1 问题**：发现阻塞问题时回退 Step 3 修复，更新 `DevLogReport` 和开发审计证据，再重新进入 Step 4。
6. **Step 4 未通过不得进入 Step 5**：测试报告、覆盖率报告、UAT 报告和测试回溯审计未通过时，不得部署上线。

测试类别、通过标准和强制产出以 `testing-stage-execution` 与 `project-document-management` 为准。

### Step 5: Deployment & Operations (部署与运维)

- **5.1 部署运维阶段执行**：调用 `operations-stage-execution` 作为 Step 5 主控技能，参考 `cicd-pipeline-management` 定义的标准流水线和部署策略，完成发布入场检查、发布计划、版本与制品确认、环境配置核验、数据迁移、部署执行、上线验证、监控日志告警、性能安全检查、回滚预案、运维移交、发布复盘和运维审计移交。版本与分支管理、tag 创建、备份和回滚操作由 `code-version-backup-management` 技能定义。
- **5.2 部署运维矩阵**：部署运维矩阵、执行顺序、专项运维技能调用、发布产物和通过标准，统一由 `operations-stage-execution` 执行。
- **5.3 全流程闭环审计**：关联审计 → 全流程闭环审计报告 / 运维审计报告（由审计师执行），审计输入必须包含发布入场、部署执行、上线验证、监控告警、回滚、运维移交和发布复盘证据。
- **文档引用**：测试报告、覆盖率报告、UAT报告、测试回溯审计报告、DevLogReport、部署架构草案、环境配置说明、单版本规划文档、Phase迭代计划。
- **文档产出**：发布入场检查记录、发布计划、部署文档、环境配置说明、部署执行记录、CICD记录、构建与制品记录、发布版本记录、数据库迁移计划、缓存与消息运维说明、回滚预案、回滚演练记录、上线验证报告、监控与日志检查记录、告警配置记录、上线安全检查记录、上线性能检查报告、运维手册、运维移交清单、发布复盘报告、运维审计输入清单；正式运维审计报告和全流程闭环审计报告固定存放于 `doc\audit\comprehensive`（详见 `project-document-management` 技能）。
- **Completes the workflow闭环**

#### Step 5 Operations Control Boundary（部署运维阶段控制边界）

`project-development-workflow` 只定义 Step 5 的阶段门禁、输入输出、审计关系和是否关闭全流程；部署运维矩阵、执行顺序、发布验证、回滚、监控告警和运维移交细则，统一由 `operations-stage-execution` 执行。

Step 5 的不可变门禁如下：

1. **必须调用 `operations-stage-execution`**：所有正式部署运维阶段工作必须由该技能主控。
2. **不得跳过发布入场检查**：Step 4 未通过、P0/P1 未关闭或测试回溯审计未通过，不得部署上线。
3. **不得用部署成功替代上线验证**：部署命令成功不等于业务可用。
4. **不得无回滚上线**：回滚预案、回滚验证或风险批准缺失时，不得生产发布。
5. **不得无监控上线**：生产服务必须具备日志、监控或告警检查记录。
6. **必须完成运维审计移交**：发布、验证、回滚、安全、监控和移交证据必须齐备。
7. **Step 5 未通过不得关闭全流程**：运维审计未通过时，流程回退到受影响阶段修复。

部署运维类别、通过标准和强制产出以 `operations-stage-execution` 与 `project-document-management` 为准。

## 阶段间交接箱

每个阶段完成后向下一阶段传递的标准化交接包。

### 交接包定义

| 交接方向 | 交接内容 | 接收方门禁检查 |
|---------|---------|---------------|
| Step 0 → Step 1 | 单版本规划 + 本版本 Backlog + Phase 计划 + 评审结论 + 候选需求池 | 1.0 入场检查确认 Step 0 输入齐备 |
| Step 1 → Step 2 | 需求基线 + 需求追溯矩阵(RT-ID) + 验收标准清单 + 需求评估报告 + 风险清单 | 2.0 入场检查确认追溯矩阵齐全 |
| Step 2 → Step 3 | 全量设计文档 + 需求设计追溯矩阵(DT-ID) + 设计评审记录 + 审计报告 + 移交说明 | 3.0 入场确认 TD-ID 需创建 |
| Step 3 → Step 4 | DevLogReport + 静态质量记录 + code-logic-review + 修复复审 + 开发审计报告 + 移交说明 | 4.0 入场检查确认 code-logic-review 通过 |
| Step 4 → Step 5 | 测试报告 + 覆盖率报告 + UAT + 测试回溯审计报告 + 缺陷闭环记录 | 5.0 入场检查确认 P0/P1 关闭 |

### 追溯链贯通说明
```text
全流程追溯链（从 Step 0 到 Step 5）：
Step 0 Backlog ─→ Step 1 RT-ID ─→ Step 2 DT-ID ─→ Step 3 TD-ID ─→ Step 4 TT-ID ─→ Step 5 部署验证项

编号规则：
  RT-ID: RT-{版本号}-{序号}    (Step 1 产生)
  DT-ID: DT-{版本号}-{序号}    (Step 2 产生，关联 RT-ID)
  TD-ID: TD-{版本号}-{序号}    (Step 3 产生，关联 DT-ID)
  TT-ID: TT-{版本号}-{序号}    (Step 4 产生，关联 RT-ID + TD-ID)

独立模式时使用 EXT 代替版本号：RT-EXT-001, DT-EXT-001, TD-EXT-001, TT-EXT-001
```

## Audit Framework (审计框架)

每个阶段均包含审计子步骤，由审计师（Auditor Agent）负责执行。审计未通过时，流程回退至对应阶段修改。

| 阶段 | 审计类型 | 触发时机 | 审计引用文档 | 审计通过条件 | 未通过处理 |
|------|---------|---------|-------------|------------|----------|
| Step 0 | 版本规划评审 | 进入需求分析前 | 版本规划总纲 + 版本迭代路线图 + 单版本规划文档 + 本版本Backlog + Phase迭代计划 | 版本目标、范围、优先级、风险、资源和高层验收目标已确认 | 退回版本规划修改 |
| Step 1 | 需求评估 | 阶段1批准前 | 需求文档 + 需求追溯矩阵 + 验收标准清单 + 需求基线说明 | P0/P1 需求来源、场景、业务规则、验收标准完整，范围合规 | 退回 Step 0 修改范围或退回 Step 1 修改需求 |
| Step 2 | 需求架构对比 | 阶段2批准前 | 需求文档（已批准）+ 需求设计追溯矩阵 + 完整设计文档矩阵 | 覆盖率≥95%，无重大偏差，P0/P1 设计缺口已闭环 | 退回阶段1修改需求或退回 Step 2 修改设计 |
| Step 3 | 开发设计对比 | 阶段3完成后 | 架构设计文档 + DevLogReport + 静态质量检查记录 + 代码逻辑审查记录 | 覆盖率≥95%，静态质量和代码逻辑 P0/P1 已闭环，偏差有记录 | 退回 Step 2 修改设计或退回 Step 3 修复 |
| Step 4 | 测试回溯对比 | 阶段4完成后 | 需求文档 + 测试报告 + 覆盖率报告 + 全部测试子报告 | 全量回归通过率≥95%，修改文件覆盖率≥80%，所有P0/P1问题有闭环 | 退回阶段3修复并重新执行完整Step 4 |
| Step 5 | 全流程闭环 / 运维审计 | 阶段5部署后 | 全部文档 + 发布入场检查 + 部署执行记录 + 上线验证报告 + 监控日志检查 + 回滚证据 + 运维移交材料 | 所有审计问题已关闭，发布可验证、可回滚、可监控、可运维 | 按影响范围回退至 Step 0-5 对应阶段 |

## Three-Tier Environment Management

### Development Environment (开发环境)

- **Port Range**: 3000 series (e.g., 3000, 31086)
- **Location**: `D:\Trae CN\myproject\Dev\`
- **Purpose**: Daily development and debugging
- **Characteristics**: Latest code, frequent changes

### Test Environment (测试环境)

- **Port Range**: 4100 series (e.g., 4100, 4186)
- **Location**: `D:\Trae CN\myproject\Test\`
- **Purpose**: QA testing, integration verification
- **Characteristics**: Stable code, controlled testing

### Production Environment (生产环境)

- **Port Range**: 5000 series (e.g., 5000, 5186)
- **Location**: `D:\Trae CN\myproject\Pro\`
- **Purpose**: Live production services
- **Characteristics**: Fully tested, stable releases

## Workflow Loop

```
[Step 0: Version Planning] → [Step 1: Requirements] → [Step 2: Design] → [Step 3: Development] → [Step 4: Testing] → [Step 5: Deployment]
        ↑                                                                                              |
        └──────────────────────────────────────────────────────────────────────────────────────────────┘
                                                                                              Issues Found
```

## Key Principles

1. **Human Approval Required**: Step 0 and each delivery step require human approval before proceeding to the next
2. **Environment Isolation**: Each environment is independent with its own configuration
3. **Port Standardization**: Use standardized port ranges for each environment
4. **Loop闭环**: Issues found in deployment restart from the impacted stage; scope or version boundary issues return to Step 0
5. **Document Standardization**: 每个阶段的文档产出、命名规范、存储路径、版本控制和权限管理，统一遵循 `project-document-management` 技能规范
6. **Audit Gate**: 每个阶段包含审计子步骤，审计通过后方可进入下一阶段
7. **Mandatory Comprehensive Testing**: Step 4 必须执行完整测试矩阵，任何局部测试不得替代全量测试门禁
8. **Coding Stage Gate**: Step 3 必须调用 `coding-stage-execution` 组织开发过程，调用 `code-static-quality-check` 完成静态质量门禁，并在开发审计前调用 `code-logic-review` 完成代码逻辑审查；未解决 P0/P1 静态质量或代码逻辑问题不得进入 Step 4
9. **Testing Stage Gate**: Step 4 必须调用 `testing-stage-execution` 组织完整测试矩阵；测试报告、覆盖率报告、UAT报告和测试回溯审计未通过不得进入 Step 5
10. **Version Planning Gate**: Step 0 必须调用 `version-planning-stage-execution`；未确认版本目标、范围、优先级和评审结论，不得进入 Step 1
11. **Design Stage Gate**: Step 2 必须调用 `design-stage-execution`；需求设计追溯、设计评审和需求架构对比审计未通过，不得进入 Step 3
12. **Requirements Stage Gate**: Step 1 必须调用 `requirements-stage-execution`；需求追溯、验收标准、需求评审和需求基线未通过，不得进入 Step 2
13. **Operations Stage Gate**: Step 5 必须调用 `operations-stage-execution`；发布入场、上线验证、回滚、监控、运维移交和运维审计未通过，不得关闭全流程
14. **Self-Verification Gate**: 修改任何流程主控、阶段规范、专项技能、角色矩阵或文档矩阵后，必须通过读取、搜索或统计核实实际文件，再报告完成；不得只依据计划、记忆或上一轮摘要判断已完成。

## Usage

When the user asks to:
- Set up a new project workflow
- Configure development environments
- Guide through the development process
- Handle environment-related questions

Invoke this skill to provide standardized project management guidance.
## Coding Stage Integration

When called within Step 3: treat `coding-stage-execution` as controller, use only for static quality or logic review specialty, record decisions in DevLogReport, do not replace Step 3 development gate or audit. P0/P1 gap → fix within Step 3, update DevLogReport and rerun relevant review before handoff.

## Version Planning Stage Integration

When called within Step 0: treat `version-planning-stage-execution` as controller, use only for specialty area, record decisions in version planning documents, do not replace Step 0 review. P0/P1 gap → fix within Step 0, update version planning documents, rerun review before handoff.

## Design Stage Integration

When called within Step 2: treat `design-stage-execution` as controller, use only for specialty area, record decisions in design documents, do not replace Step 2 design review or requirements-architecture audit. P0/P1 gap → fix within Step 2, update design document and traceability matrix, rerun design review before handoff.

## Requirements Stage Integration

When called within Step 1: treat `requirements-stage-execution` as controller, use only for specialty area, record decisions in requirements documents, do not replace Step 1 requirements review or audit. P0/P1 gap → fix within Step 1, update requirements baseline and traceability matrix, rerun requirements review before handoff.

## Operations Stage Integration

When called within Step 5: treat `operations-stage-execution` as controller, use only for specialty area, record commands, environment, release version, verification evidence, and risks in operations documents, do not replace Step 5 release verification or operations audit. P0/P1 gap → stop rollout or trigger rollback, update release records, rerun required verification before handoff.

## Coding Conventions Integration

Step 3 编码实现阶段必须遵循 `project-coding-conventions` 技能中定义的项目级编码约定。

## Document Templates Integration

各阶段文档产出时参考 `project-document-templates` 技能中的对应模板，确保文档内容完整性。

## CI/CD Pipeline Integration

Step 5 部署运维阶段自动化的 CI/CD 流水线标准由 `cicd-pipeline-management` 技能定义。项目初始化、流水线配置、质量闸门设置和部署策略选择时调用该技能。