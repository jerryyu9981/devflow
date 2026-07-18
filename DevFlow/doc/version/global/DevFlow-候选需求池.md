# DevFlow 候选需求池

> 文档类型：候选需求池
> 文档状态：[Draft]
<<<<<<< HEAD
> 版本：v1.8
> 日期：2026-07-15
=======
> 版本：v1.0
> 日期：2026-07-07
>>>>>>> origin/master
> 维护者：DevFlow 维护团队

---

## 范围说明

本候选需求池记录 DevFlow 项目全部已识别但尚未分配至具体版本的候选需求。每个版本发布时从本池筛选需求纳入该版本 Backlog，已纳入的需求标记目标版本后移至对应版本的 Backlog。

---

## 候选需求列表

### v2.6.0 已纳入

| ID | 需求描述 | 优先级 | 来源 | 技术可行性 | 状态 | 目标版本 |
|:--:|:---------|:------:|:-----|:----------:|:----:|:--------:|
| V260-006 | 发布时自动强制更新版本号：每次发布操作必须自动检测并更新 `version.json` 版本号，作为发布流程的原子步骤，不允许手动跳过 | 🔴 P0 | 版本治理 | ✅ 可行（现有框架内增强） | ✅ 已纳入 | v2.6.0 |
| V260-007 | devflow-init 初始化强制设置项目仓库地址：初始化交互流程中，项目 Git 远程仓库地址输入步骤虽可留空，但必须展示该设置界面，用户必须主动确认后方可进入下一步 | 🔴 P0 | 初始化完善 | ✅ 可行（交互流程增强） | ✅ 已纳入 | v2.6.0 |
| V260-008 | 增强 `code-static-quality-check`：新增 3 类检查维度 — 圈复杂度（函数≤15 P0阻断）、代码重复率（新代码≤3% P0阻断）、架构合规（禁止跨层依赖 P0阻断） | 🔴 P0 | 代码质量 | ✅ 可行（已有规范文件，维度扩展） | ✅ 已纳入 | v2.6.0 |
| V260-009 | 增强 `code-logic-review`：将 AI Code Review 从推荐升级为强制，建立三层人机协同过滤模式（AI初筛→人工架构Review→AI二次校验） | 🔴 P0 | 代码质量 | ✅ 可行（流程规则增强） | ✅ 已纳入 | v2.6.0 |
| V260-010 | 增强 `cicd-pipeline-management`：新增 3 道质量门禁 — 圈复杂度（>20阻断/>10%函数>15阻断）、代码重复率（新代码>3% P1阻断）、技术债比例（>10% P1阻断/ >20% P0阻断） | 🟡 P1 | 代码质量 | ✅ 可行（门禁配置扩展） | ✅ 已纳入 | v2.6.0 |
| V260-011 | 增强 `project-coding-conventions`：新增本地质量配置章节 — Husky + lint-staged 标准化模板、VS Code/WebStorm IDE 配置、.editorconfig 通用配置 | 🟡 P1 | 代码质量 | ✅ 可行（模板章节追加） | ✅ 已纳入 | v2.6.0 |
| V260-012 | 在 `DevFlow-软件开发工程规范.md` 主文档中新增"质量门禁指标集中速查表"章节，汇总所有技能的质量门禁阈值 | 🟡 P1 | 代码质量 | ✅ 可行（文档集中整理） | ✅ 已纳入 | v2.6.0 |
| V260-013 | 增强 `version-planning-stage-execution`：新增"内部工作流"章节，包含 0.0→0.5 六步标准化子步骤 | 🟡 P1 | 技术评估 | ✅ 可行（技能文件章节追加） | ✅ 已纳入 | v2.6.0 |
| V260-014 | 增强 `design-stage-execution`：新增四轨并行设计工作流，含 ADR、轨道选择、覆盖率≥95%及5%缺口处置规则 | 🟡 P1 | 技术评估 | ✅ 可行（复杂但属流程规则增强） | ✅ 已纳入 | v2.6.0 |
| V260-015 | 增强 `requirements-stage-execution`：新增 1.0→1.10 十步内部工作流 | 🟡 P1 | 工作流标准化 | ✅ 可行（技能文件章节追加） | ✅ 已纳入 | v2.6.0 |
| V260-016 | 增强 `coding-stage-execution`：重构为四轨并行开发流程 | 🟡 P1 | 工作流标准化 | ⚠️ 需注意（L1/L2 联动复杂度高，需确保向后兼容） | ✅ 已纳入 | v2.6.0 |
| V260-017 | 增强 `testing-stage-execution`：新增 TT-ID 及四轨并行测试流程 | 🟡 P1 | 工作流标准化 | ✅ 可行（技能文件追加+重构） | ✅ 已纳入 | v2.6.0 |
| V260-018 | 增强 `operations-stage-execution`：新增 5.0→5.11 内部工作流 | 🟡 P1 | 工作流标准化 | ✅ 可行（技能文件章节追加） | ✅ 已纳入 | v2.6.0 |
| V260-019 | 增强 `devflow-phase-manager`：state.json 双模式扩展 + LLM 决策逻辑 | 🟡 P1 | 工作流标准化 | ⚠️ 需注意（影响 state.json 结构，需考虑向后兼容） | ✅ 已纳入 | v2.6.0 |
| V260-020 | 增强 `project-development-workflow`：交接箱+追溯链+Integration 压缩 | 🟡 P1 | 工作流标准化 | ✅ 可行（文档增强+全文格式优化） | ✅ 已纳入 | v2.6.0 |

### v2.7.0 已纳入（架构修复版本）

| ID | 需求描述 | 优先级 | 来源 | 技术可行性 | 状态 | 目标版本 |
|:--:|:---------|:------:|:-----|:----------:|:----:|:--------:|
| V260-021 | L2→L3 内联执行步骤补齐：将 L2 中内联的 L3 速查内容全部转化为 L2 内部工作流的显式执行步骤，消除 18 个执行缺口；新增"L2 内联审计报告"作为 L2 修改完成门禁 | 🔴 P0 | 架构修复 | ✅ 可行（工作流步骤表追加） | ✅ 已纳入 | v2.7.0 |
| V260-022 | L1 三层架构职责边界正式定义：将"内联即承诺""内联≠执行"等约束写入 project-development-workflow.md；增加三层示例对照表 | 🔴 P0 | 架构修复 | ✅ 可行（文档正式化） | ✅ 已纳入 | v2.7.0 |
| V260-023 | 撰写工作流加强版执行方案文档（`DevFlow-v2.7.0-L2-L3-内联修复执行方案.md`），详细规划 18 个 GAP 的逐项修复步骤 | 🟡 P1 | 架构修复 | ✅ 可行（执行方案文档） | ✅ 已纳入 | v2.7.0 |

### v2.8.0 候选（功能增强版本）

| ID | 需求描述 | 优先级 | 来源 | 技术可行性 | 状态 | 目标版本 |
|:--:|:---------|:------:|:-----|:----------:|:----:|:--------:|
| V260-001 | Agent 协作协议与自动编排：定义多 Agent 协作时的通信协议、任务分解与编排机制、上下文传递规则 | 🟡 P1 | Agent 协作 | ⚠️ 需预研（需定义协作协议标准） | 📋 候选 | v2.8.0 |
| V260-002 | 自动化审计回溯能力：开发自动化审计工具，减少人工审计工作量，提供审计报告自动生成 | 🟡 P1 | 自动化审计 | ⚠️ 需预研（需评估工具选型） | 📋 候选 | v2.8.0 |
| V260-003 | 追溯链可视化：实现从需求→设计→开发→测试→部署的全链路可视化追溯看板 | 🟢 P2 | 追溯链 | ⚠️ 需预研（需评估前端看板方案） | 📋 候选 | v2.8.0 |
| V260-004 | 并行阶段执行支持：允许多个阶段（如设计+开发、开发+测试）在受控条件下并行推进 | 🟢 P2 | 流程优化 | ⚠️ 需预研（需定义并行阶段协调机制） | 📋 候选 | v2.8.0 |
| V260-005 | 国际化文档模板：提供多语言项目文档模板支持（英文/繁体中文等） | 🟢 P2 | 国际化 | ✅ 可行（模板翻译+多语系方案） | 📋 候选 | v2.8.0 |
| V260-036-01 | **新增 download-devflow.ps1 脚本**：实现从云端仓库下载最新 DevFlow 到本地副本的功能，支持 Clone（首次克隆）、Update（拉取更新）、SetRepo（设置仓库地址）三种模式；仓库地址从 version.json.repository 读取 | 🟡 P1 | 三阶段架构 | ✅ 可行（新增 PowerShell 脚本） | 📋 候选 | v2.8.0 |
| V260-036-07 | **devflow-init 版本差异检测增强**：在步骤 1.5 之后插入版本差异检测步骤；读取 TRAE 系统目录版本 vs 项目记录版本；根据差异结果执行不同操作；将检测结果写入 state.json.versionCheck 字段 | 🔴 P0 | 三阶段架构 | ✅ 可行（SKILL.md 流程增强） | 📋 候选 | v2.8.0 |
| V260-036-08 | **填充 version.json 仓库地址字段**：填充 repository 和 homepage 字段；用户在首次使用时通过 download-devflow.ps1 -Action SetRepo 设置 | 🟢 P2 | 三阶段架构 | ✅ 可行（字段填写） | 📋 候选 | v2.8.0 |
| V260-037 | **修复 setup.ps1 复制逻辑：对非 .md 文件保留原文件名**——setup.ps1 第 98 行写死 `$dstFile = Join-Path $dstDir "SKILL.md"`，导致 `version.json` 和 `sync-skills.ps1` 被错误复制为 `SKILL.md`。增加文件扩展名判断逻辑：.md 文件→SKILL.md，非 .md 文件→保留原文件名，与 sync-skills.ps1 的 `$preserveFileName` 机制一致 | 🔴 P0 | 架构修复（v2.7.5 衍生） | ✅ 可行（复制逻辑增强） | 📋 候选 | v2.8.0 |

<<<<<<< HEAD
### v2.8.1 已纳入（三步走交互完善 + 技术债务修复版本）

| ID | 需求描述 | 优先级 | 来源 | 技术可行性 | 状态 | 目标版本 |
|:--:|:---------|:------:|:-----|:----------:|:----:|:--------:|
| V260-038 | **修复 update.ps1 复制逻辑中 SKILL.md 硬编码**——update.ps1 第 153 行 `$dst = Join-Path $dstDir "SKILL.md"` 对所有技能使用固定文件名，导致 `version.json`、`sync-skills.ps1`、`download-devflow.ps1` 等非 .md 文件被错误命名为 `SKILL.md`。修复方式参照 setup.ps1 的 V260-037 方案，增加文件扩展名判断：.md 文件→SKILL.md，非 .md 文件→保留原文件名。影响范围：推荐更新路径 `update-devflow.bat`（调用 sync-skills.ps1）不受影响，仅直接影响用户直接运行 `update.ps1` 的场景 | 🟡 P1 | 技术债务 | ✅ 可行（参照 V260-037 方案，约 10 行代码修改） | ✅ 已纳入 | v2.8.1 |
| V260-044 | **download-devflow.ps1 增加版本比较+交互确认**——Download 步骤增强：① Clone/Update 前交互确认源地址（从 version.json.repository 读取并展示，用户可修改或确认）和目的地址（默认当前目录，用户可修改）；② 通过 `git ls-remote --tags` 获取远程仓库最新 tag 的版本号，与本地 version.json.devflowVersion 比较；③ 仅当远程版本更新时才执行 clone/pull，否则提示"已是最新版本"并跳过 | 🔴 P0 | 三步走交互完善 | ✅ 可行（git ls-remote + 语义版本比较 + Read-Host 确认） | ✅ 已纳入 | v2.8.1 |
| V260-045 | **setup.ps1 增加交互确认步骤**——Setup 步骤增强：在执行文件复制到 TRAE 系统目录之前，展示将要从本地副本（Download 目的地址）安装的版本号和文件数量，交互确认"是否安装到 TRAE 系统目录？"，用户输入 y/Y 后才执行复制；展示安装后的目标路径（`~/.trae-cn/skills/`） | 🔴 P0 | 三步走交互完善 | ✅ 可行（版本号展示 + 文件计数 + Read-Host 确认） | ✅ 已纳入 | v2.8.1 |
| V260-046 | **devflow-init 版本更新时同步项目 devflow 文件**——Init 步骤增强：当检测到 `installed_newer`（TRAE 版本比项目版本更新）时，不仅更新 `state.json.devflowVersion` 字段，还需将 TRAE 系统目录（`~/.trae-cn/skills/`）中的 DevFlow 相关文件同步到项目的 `.devflow/` 目录（如有），包括更新 config.json 和 state.json 的模板结构。确保项目目录的 DevFlow 配置与 TRAE 系统目录保持一致 | 🔴 P0 | 三步走交互完善 | ✅ 可行（从 TRAE 目录复制到项目 .devflow/） | ✅ 已纳入 | v2.8.1 |

### v2.8.2 已纳入（安装流程三步走对齐版本）

| ID | 需求描述 | 优先级 | 来源 | 技术可行性 | 状态 | 目标版本 |
|:--:|:---------|:------:|:-----|:----------:|:----:|:--------:|
| V260-047 | **install.ps1 下载步骤对齐 download-devflow.ps1**——当前 install.ps1 的 Step 1 内联了一套简化版 git clone 逻辑（约 100 行），与 download-devflow.ps1 功能重复且不完整（缺少版本比较、语义版本排序等）。改为：Step 1 直接调用 `download-devflow.ps1 -Action Clone`，将下载职责统一收敛到 download-devflow.ps1；install.ps1 只保留流程编排和错误处理。同步修改 `install.bat` 确保路径传递正确 | 🔴 P0 | 三步走对齐 | ✅ 可行（替换内联逻辑为脚本调用，约 80 行净删减） | ✅ 已纳入 | v2.8.2 |
| V260-048 | **install.ps1 首次安装时引导设置下载仓库地址**——当 `version.json.repository` 为空时，install.ps1 的 Step 1 不应直接跳过下载，而应自动调用 `download-devflow.ps1 -Action SetRepo` 引导用户输入仓库 URL（交互式 Read-Host），设置完成后再继续 Clone 流程。同时 install.ps1 应支持 `-TargetDir` 参数，允许用户指定本地副本下载目录，替代当前的"使用脚本所在目录"的隐式行为 | 🔴 P0 | 三步走交互完善 | ✅ 可行（检测空字段 + 调用 SetRepo + 参数透传） | ✅ 已纳入 | v2.8.2 |
| V260-049 | **setup.ps1/sh IDE 系统目录可配置化**——当前 `setup.ps1` 中 `$TraeSkillsDir = "$env:USERPROFILE\.trae-cn\skills"` 为硬编码，不支持非标准安装路径的 TRAE（如自定义 `TRAE_SKILLS_DIR` 环境变量）。改为：优先读取环境变量 `DEVFLOW_SKILLS_DIR`（如已设置则使用），其次读取 `$env:USERPROFILE\.trae-cn\skills`，并在安装确认步骤中展示该目录供用户确认。同步修改 `setup.sh`、`update.ps1`、`update.sh`、`sync-skills.ps1` 保持一致 | 🟡 P1 | 安装健壮性 | ✅ 可行（环境变量读取 + 硬编码回退，5 个脚本同步修改） | ✅ 已纳入 | v2.8.2 |
| V260-050 | **setup.ps1/sh 安装后自动去除 SKILL.md 的 UTF-8 BOM 头**——TRAE 的 Write/SearchReplace 工具在 Windows 上编辑文件时会自动添加 UTF-8 BOM（`EF BB BF`），而 TRAE 技能扫描器无法正确解析 BOM 开头的 YAML frontmatter，导致技能无法加载。v2.7.3~v2.8.1 开发过程中三个 orchestrator 技能（devflow-init、devflow-phase-manager、devflow-project-config）因此无法被识别。修复：在 setup.ps1/sh 的 Phase 2 文件复制完成后，对所有已安装的 `.md` 文件执行 BOM 检测并自动去除（读取 UTF-8 BOM → 写入无 BOM）。同步修改 `update.ps1`、`update.sh`、`sync-skills.ps1` 保持一致 | 🔴 P0 | 安装修复 | ✅ 可行（约 10 行 PowerShell 代码，检测首三字节并重写） | ✅ 已纳入 | v2.8.2 |
=======
### v2.8.1 候选（技术债务修复版本）

| ID | 需求描述 | 优先级 | 来源 | 技术可行性 | 状态 | 目标版本 |
|:--:|:---------|:------:|:-----|:----------:|:----:|:--------:|
| V260-038 | **修复 update.ps1 复制逻辑中 SKILL.md 硬编码**——update.ps1 第 153 行 `$dst = Join-Path $dstDir "SKILL.md"` 对所有技能使用固定文件名，导致 `version.json`、`sync-skills.ps1`、`download-devflow.ps1` 等非 .md 文件被错误命名为 `SKILL.md`。修复方式参照 setup.ps1 的 V260-037 方案，增加文件扩展名判断：.md 文件→SKILL.md，非 .md 文件→保留原文件名。影响范围：推荐更新路径 `update-devflow.bat`（调用 sync-skills.ps1）不受影响，仅直接影响用户直接运行 `update.ps1` 的场景 | 🟡 P1 | 技术债务 | ✅ 可行（参照 V260-037 方案，约 10 行代码修改） | 📋 候选 | v2.8.1 |
>>>>>>> origin/master

### v2.9.0 候选（全自动循环架构版本）

| ID | 需求描述 | 优先级 | 来源 | 技术可行性 | 状态 | 目标版本 |
|:--:|:---------|:------:|:-----|:----------:|:----:|:--------:|
| V260-039 | **重试管理器（retry-manager）**——嵌入到 devflow-phase-manager 的阶段切换门禁中，为每个 Step 增加重试计数（retryCount）和上限（maxRetries=3）。单步超过上限后自动诊断：部分失败→通过项标记 passed，失败项移入 deferredItems；全部失败→本版本所有未完成项移入 deferredItems，强制进入下一步。用于防止"测试-修复循环""审计门禁循环""覆盖率循环"等死锁场景 | 🔴 P0 | 全自动循环 | ⚠️ 需预研（需定义各阶段的超限策略） | 📋 候选 | v2.9.0 |
| V260-040 | **空池检测器（empty-pool-detector）**——在 Step 5 闭环后检测候选需求池状态。候选池为空→终止循环（completed）；仅剩 P2→暂停循环等待用户确认（paused）；有 P0/P1→执行滞留检测后启动下一版本。绑定额度检测：滞留 3 版的需求自动移入 blockedItems。用于防止"空版本循环"死锁 | 🔴 P0 | 全自动循环 | ✅ 可行（文件读取+JSON 解析逻辑） | 📋 候选 | v2.9.0 |
| V260-041 | **自动降级机制（auto-degrade）**——嵌入到 testing-stage-execution 等 L2 技能中，为测试覆盖率略低（≥90% <95%）、非 P0 测试失败（P1/P2）、代码审查 warnings 等"灰色地带"提供自动通过逻辑。降级结果：pass_with_note（记录缺口项）、partial_pass（记录 knownIssues）、pass_with_warnings。P0 失败和覆盖率<90%永不自动降级，确保质量底线 | 🟡 P1 | 全自动循环 | ⚠️ 需预研（需定义降级判断矩阵） | 📋 候选 | v2.9.0 |
| V260-042 | **致命错误处理器（fatal-error-handler）**——贯穿所有 Step，捕获不可恢复的错误（state.json 损坏、TRAE 目录不可写、磁盘空间不足、候选池文件损坏、版本号无意义）。检测到致命错误时：设置 cycleState.status=aborted，立即终止循环，输出错误报告。非致命错误（外部依赖超时、部署非核心技能失败）自动降级。连续 3 次 fatal 后永久 abort | 🟡 P1 | 全自动循环 | ✅ 可行（错误捕获+状态设置逻辑） | 📋 候选 | v2.9.0 |
| V260-043 | **循环状态机（cycle-state-machine）**——新增 orchestrator 技能，位于 devflow-phase-manager 上层，管理"版本间循环"生命周期。状态：idle→planning→version_executing→cycle_checking→idle（循环）或 paused（等待）或 completed（终止）。在 Step 5 闭环后触发空池检测+滞留检测，决定是否启动下一版本。版本号自动递增策略：热修复→修订号，新功能→次版本号 | 🟡 P1 | 全自动循环 | ⚠️ 需预研（需定义状态机切换逻辑+版本号递增策略） | 📋 候选 | v2.9.0 |

### v2.7.1 已纳入（修订版本）

| ID | 需求描述 | 优先级 | 来源 | 技术可行性 | 状态 | 目标版本 |
|:--:|:---------|:------:|:-----|:----------:|:----:|:--------:|
| V260-024 | 补齐 `security-design-review` 和 `secure-coding-practices` 在 L2 技能速查表中的技能名引用（内容已在 v2.7.0 新增，仅缺技能名标记） | 🟡 P1 | L3 引用审计 | ✅ 可行（速查表追加技能名） | ✅ 已纳入 | v2.7.1 |
| V260-025 | 补齐 `database-migration` 在 L2 中的引用：在 `operations-stage-execution` 5.2 步追加"数据库迁移检查"步骤及速查表引用 | 🟡 P1 | L3 引用审计 | ✅ 可行（步骤表追加） | ✅ 已纳入 | v2.7.1 |
| V260-026 | 补齐 `container-deployment` 在 L2 中的引用：在 `operations-stage-execution` 5.4 部署执行说明中追加容器部署参考 | 🟡 P1 | L3 引用审计 | ✅ 可行（说明文案追加） | ✅ 已纳入 | v2.7.1 |
| V260-027 | 补齐 `performance-engineering` 在 L2 中的引用：在 `testing-stage-execution` 4.7b-1 后追加性能工程参考 | 🟡 P1 | L3 引用审计 | ✅ 可行（速查表追加） | ✅ 已纳入 | v2.7.1 |
| V260-028 | 补齐 `project-document-templates` 在 L2 中的引用：在每个 L2 输出要求章节追加"参照模板"注释 | 🟢 P2 | L3 引用审计 | ✅ 可行（注释追加） | ✅ 已纳入 | v2.7.1 |

### v2.7.2 已纳入（修订版本）

| ID | 需求描述 | 优先级 | 来源 | 技术可行性 | 状态 | 目标版本 |
|:--:|:---------|:------:|:-----|:----------:|:----:|:--------:|
| V260-029 | `config.json` 字段重命名：`devflowVersion` → `projectVersion`。涉及 devflow-init/SKILL.md 模板、devflow-project-config/SKILL.md 说明和字段表、setup.ps1、update.ps1 共 4 处代码修改。向后兼容：读 `projectVersion`，不存在时回退读 `devflowVersion` | 🟡 P1 | 配置治理 | ✅ 可行（字段改名+兼容逻辑） | ✅ 已纳入 | v2.7.2 |

### v2.7.3 候选（职责边界清理版本）

| ID | 需求描述 | 优先级 | 来源 | 技术可行性 | 状态 | 目标版本 |
|:--:|:---------|:------:|:-----|:----------:|:----:|:--------:|
| V260-030 | **Install DevFlow 职责清理**——`setup.ps1/sh` 移除项目初始化逻辑（项目名检测、`.devflow/` 创建、config.json/state.json 生成），仅保留全局技能安装到 `~/.trae-cn/skills/` 和可选 Git hook 安装 | 🔴 P0 | 职责边界清理 | ✅ 可行（代码剥离） | 📋 候选 | v2.7.3 |
| V260-031 | **Update DevFlow 修正**——`update.ps1/sh` 移除修改 `.devflow/config.json` 中 `projectVersion` 的逻辑，只做 TRAE 技能目录 `~/.trae-cn/skills/` 的增量同步（含 `devflow-plugin-config/version.json` 版本更新） | 🔴 P0 | 职责边界清理 | ✅ 可行（移除越界逻辑） | 📋 候选 | v2.7.3 |
| V260-032 | **devflow-init 增强：DevFlow 版本号读取与写入**——新增从 `~/.trae-cn/skills/devflow-plugin-config/version.json` 读取 DevFlow 版本号的能力；写入项目根目录 `version.json` 记录"本项目使用的 DevFlow 版本"；写入 `.devflow/state.json` 的 `version` 字段 | 🔴 P0 | 职责边界清理 | ✅ 可行（SKILL.md 规则实现） | 📋 候选 | v2.7.3 |
| V260-033 | **devflow-init 增强：projectVersion 自动扫描+交互补充**——按照优先级链自动检测项目版本号：① 已有 `.devflow/config.json.projectVersion`（非空）→ 保留 ② 最新 Git tag ③ `package.json` version ④ `pyproject.toml` version ⑤ 其他项目配置文件；以上均无法获取时交互询问用户输入。写入 `.devflow/config.json` 的 `projectVersion` 字段 | 🔴 P0 | 职责边界清理 | ✅ 可行（自动检测链+交互补充） | 📋 候选 | v2.7.3 |
| V260-034 | **devflow-init 增强：currentPhase 推断并写入 state.json**——完善文档扫描推断逻辑，实际将推断得出的 `currentPhase` 写入 `.devflow/state.json`，而非仅提示用户；确保 state.json 反映真实项目状态 | 🟡 P1 | 职责边界清理 | ✅ 可行（状态写入增强） | 📋 候选 | v2.7.3 |

---

### v2.7.4 候选（版本字段命名规范化版本）

| ID | 需求描述 | 优先级 | 来源 | 技术可行性 | 状态 | 目标版本 |
|:--:|:---------|:------:|:-----|:----------:|:----:|:--------:|
| V260-035 | **所有 version 字段统一命名规范化**——消除 `version` 字段歧义：`devflow-plugin/version.json` 的 `version` → `devflowVersion`、项目根 `version.json` 的 `version` → `devflowVersion`、`.devflow/state.json` 的 `version` → `devflowVersion`；同步更新所有技能模板中的字段引用（devflow-init、devflow-phase-manager、devflow-project-config）；删除 `.devflow/version.json` 旧版备份遗留文件；同步更新 setup.ps1/sh、sync-skills.ps1、update.ps1/sh 中的字段读取。**修复 update.ps1/sh 语义错误**：`$CurrentVersion` 来源从 `config.json.projectVersion`（项目版本）改为读取 `state.json.devflowVersion`（项目使用的 DevFlow 版本），与 `$LatestVersion`（来自 `devflow-plugin/version.json.devflowVersion`，插件源版本）形成正确的"已安装 vs 最新"比较。 | 🔴 P0 | 配置治理 | ✅ 可行（字段重命名+语义修正） | ✅ 已纳入 | v2.7.4 |

---

### v2.7.5 候选（三阶段版本管理架构修复）

| ID | 需求描述 | 优先级 | 来源 | 技术可行性 | 状态 | 目标版本 |
|:--:|:---------|:------:|:-----|:----------:|:----:|:--------:|
| V260-036 | **建立完整的三阶段版本管理流程**——修复 DevFlow 版本管理中"云端仓库→本地副本→TRAE 系统目录→项目目录"全链路的断裂问题，消除 6 个执行文件的职责边界模糊，实现项目初始化时的版本差异检测。包含 9 项子需求： | 🔴 P0 | 架构修复（v2.7.4 衍生） | ✅ 可行（已有完整设计文档） | ✅ 已纳入 | v2.7.5 |
| V260-036-01 | **新增 download-devflow.ps1 脚本**：实现从云端仓库下载最新 DevFlow 到本地副本的功能，支持 Clone（首次克隆）、Update（拉取更新）、SetRepo（设置仓库地址）三种模式；仓库地址从 version.json.repository 读取 | 🟡 P1 | 三阶段架构 | ✅ 可行（新增 PowerShell 脚本） | 📋 候选 | v2.8.0 |
| V260-036-02 | **修复 install.ps1 组件边界违规**：将 \$verInfo.version 改为 \$verInfo.devflowVersion；移除复制整个 devflow-plugin/ 到项目 .devflow/ 的代码；移除提示用户从 .devflow/ 运行 update.ps1 的代码 | 🔴 P0 | 三阶段架构 | ✅ 可行（代码剥离+字段修正） | ✅ 已纳入 | v2.7.5 |
| V260-036-03 | **修复 setup.ps1 skillMap 遗漏**：在 skillMap 中添加 devflow-plugin-config → version.json 和 devflow-plugin-sync → sync-skills.ps1 | 🔴 P0 | 三阶段架构 | ✅ 可行（skillMap 条目追加） | ✅ 已纳入 | v2.7.5 |
| V260-036-04 | **修复 sync-skills.ps1 缺少自身引用**：在 \$DevFlowSkills 列表中添加 devflow-plugin-sync → sync-skills.ps1 | 🔴 P0 | 三阶段架构 | ✅ 可行（列表条目追加） | ✅ 已纳入 | v2.7.5 |
| V260-036-05 | **修复 update.ps1 skillMap 遗漏**：在 skillMap 中添加 devflow-plugin-config → version.json 和 devflow-plugin-sync → sync-skills.ps1 | 🟡 P1 | 三阶段架构 | ✅ 可行（skillMap 条目追加） | ✅ 已纳入 | v2.7.5 |
| V260-036-06 | **修复 update-devflow.bat 硬编码版本号**：标题从 v2.6.0 改为通用标题 DevFlow Updater | 🟢 P2 | 三阶段架构 | ✅ 可行（字面量文本修改） | ✅ 已纳入 | v2.7.5 |
| V260-036-07 | **devflow-init 版本差异检测增强**：在步骤 1.5 之后插入版本差异检测步骤；读取 TRAE 系统目录版本 vs 项目记录版本；根据差异结果执行不同操作；将检测结果写入 state.json.versionCheck 字段 | 🔴 P0 | 三阶段架构 | ✅ 可行（SKILL.md 流程增强） | 📋 候选 | v2.8.0 |
| V260-036-08 | **填充 version.json 仓库地址字段**：填充 repository 和 homepage 字段；用户在首次使用时通过 download-devflow.ps1 -Action SetRepo 设置 | 🟢 P2 | 三阶段架构 | ✅ 可行（字段填写） | 📋 候选 | v2.8.0 |
| V260-036-09 | **同步修改 setup.sh / update.sh**：在 SKILL_MAP 中添加 devflow-plugin-config 和 devflow-plugin-sync 条目 | 🟡 P1 | 三阶段架构 | ✅ 可行（SKILL_MAP 条目追加） | ✅ 已纳入 | v2.7.5 |

---

## 需求池流转规则

1. **新增候选需求**：来源包括用户反馈、业务输入、线上问题、技术债、竞品信息和内部改进建议，需填写来源、价值、初步成本和目标版本。
2. **纳入版本**：版本规划时通过 Step 0 技术可行性粗筛，从候选需求池筛选纳入版本 Backlog，标记状态为"✅ 已纳入"。
3. **延期处理**：当前版本未完成的需求回退候选需求池，标记为"📋 候选"，调整目标版本。
4. **废弃处理**：确认不再需要的需求标记为"❌ 废弃"，保留记录并注明原因。

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| v1.0 | 2026-07-07 | 初始创建，汇总 v2.6.0 全部 15 项需求（V260-006~020）及 v2.7.0 候选 5 项（V260-001~005） | DevFlow 维护团队 |
| v1.1 | 2026-07-07 | 新增"技术可行性"列，15 项 v2.6.0 + 5 项 v2.7.0 逐一标注可行性结论 | DevFlow 维护团队 |
| v1.2 | 2026-07-07 | 新增 V260-021~023（L2→L3 内联修复 + 架构修复需求），v2.7.0 候选需求增至 8 项 | DevFlow 维护团队 |
| v1.3 | 2026-07-11 | 清理 v2.7.1 重复候选条目；标记 v2.7.2 为已纳入；新增 V260-030~034（Install/Update/Init 三组件职责边界清理需求），v2.7.3 候选 | DevFlow 维护团队 |
| v1.4 | 2026-07-12 | 新增 V260-035（version 字段统一命名规范化+update 语义修复），v2.7.4 候选；新增 V260-036（devflow-init 跨项目版本检测），v2.7.5 候选 | DevFlow 维护团队 |
| v1.5 | 2026-07-12 | 新增 V260-038（update.ps1 SKILL.md 硬编码技术债务），v2.8.1 候选 | DevFlow 维护团队 |
<<<<<<< HEAD
| v1.6 | 2026-07-12 | 新增 V260-039~043（全自动版本循环执行架构），v2.9.0 候选；新增设计文档 `DevFlow-全自动版本循环执行架构设计文档.md` | DevFlow 维护团队 |
| v1.7 | 2026-07-15 | 新增 V260-044~046（三步走交互完善：Download 版本比较+确认、Setup 交互确认、Init 文件同步），v2.8.1 候选 | DevFlow 维护团队 |
| v1.8 | 2026-07-15 | V260-038、V260-044、V260-045、V260-046 标记为"已纳入 v2.8.1"；v2.8.1 候选区域更名为已纳入 | PM-DevFlow-Dev |
| v1.9 | 2026-07-17 | 新增 V260-047~049（install.ps1 下载步骤对齐、首次安装引导设置仓库地址、IDE 系统目录可配置化），v2.8.2 候选 | PM-DevFlow-Dev |
| v2.0 | 2026-07-17 | 新增 V260-050（setup/update/sync 脚本安装后自动去除 SKILL.md UTF-8 BOM 头），v2.8.2 候选 | PM-DevFlow-Dev |
| v2.1 | 2026-07-18 | V260-047~050 标记为"已纳入 v2.8.2"；v2.8.2 候选区域更名为已纳入 | PM-DevFlow-Dev |
=======
| v1.6 | 2026-07-12 | 新增 V260-039~043（全自动版本循环执行架构），v2.9.0 候选；新增设计文档 `DevFlow-全自动版本循环执行架构设计文档.md` | DevFlow 维护团队 |
>>>>>>> origin/master
