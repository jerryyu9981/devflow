# DevFlow Changelog

## v2.8.2

### Changed
- **install.ps1 下载步骤对齐 download-devflow.ps1**（V260-047）：删除约 100 行内联 git clone 逻辑，改为调用 `download-devflow.ps1 -Action Clone -TargetDir $EffectiveDir`
- **install.ps1 首次安装引导**（V260-048）：`version.json.repository` 为空时自动调用 `download-devflow.ps1 -Action SetRepo` 引导用户设置仓库 URL，设置完成后继续 Clone；新增 `-TargetDir` 参数
- **install.bat**：支持 TargetDir 参数透传

### Added
- **BOM 自动去除**（V260-050）：setup.ps1/sh、update.ps1/sh、sync-skills.ps1 在文件复制/同步后自动检测并去除 UTF-8 BOM（`EF BB BF`），新增 `Remove-Utf8Bom` / `remove_utf8_bom` 函数
- **IDE 系统目录可配置化**（V260-049）：5 个安装/更新/同步脚本支持 `DEVFLOW_SKILLS_DIR` 环境变量，优先级高于硬编码路径

### Fixed
- version.json 文件本身去除 UTF-8 BOM
- install.bat 修正 PowerShell 调用参数传递
- setup.ps1、update.ps1、update.sh 补齐 v2.5.0 遗漏的 6 个 L3 技能（skill-md-writing-standards、security-design-review、secure-coding-practices、container-deployment、performance-engineering、database-migration）
- update.sh 补齐 v2.8.0 遗漏的 devflow-plugin-download 条目
- setup.sh Bash 分支补齐 v2.5.0 的 6 个 L3 技能 + v2.8.0 的 devflow-plugin-download

## v2.8.1

### Changed
- `setup.ps1` 安装前新增交互确认：展示版本号、技能数量、目标目录，用户确认后执行（V260-045）
- `download-devflow.ps1` 新增版本比较与交互确认：Clone/Update 前通过 `git ls-remote` 获取远程版本，仅在有更新时执行下载，并展示源/目的地址（V260-044）
- `devflow-init/SKILL.md` `installed_newer` 分支增加配置模板同步逻辑，检测到新版本时将 TRAE 系统目录的 DevFlow 文件同步到项目 `.devflow/`（V260-046）

### Fixed
- 修复 `update.ps1` 中 SKILL.md 硬编码问题：对非 .md 文件保留原文件名，与 setup.ps1 逻辑一致（V260-038）

## v2.8.0

### Added
- 新增 `download-devflow.ps1` 脚本：支持 Clone/Update/SetRepo 三种模式，实现"三步走"架构中的下载阶段（V260-036-01）
- `devflow-init/SKILL.md` 新增 §1.5.5 版本差异检测，定义 versionCheck 写入逻辑（V260-036-07）

### Changed
- `version.json` 新增 `bugs` 字段（由 SetRepo 模式填充）（V260-036-08）
- `setup.ps1` / `sync-skills.ps1` / `update.ps1` skillMap 新增 `devflow-plugin-download` 条目
- 修复 `setup.ps1` 首次安装复制逻辑：非 .md 文件保留原文件名（V260-037）

## v2.7.5

### Fixed
- 修复 Install/Update/Sync 三组件的组件边界违规：`install.ps1` 改为直接调用 `setup.ps1`，移除项目目录操作代码（~70 行）
- 补齐 `setup.ps1` / `setup.sh` / `sync-skills.ps1` / `update.ps1` / `update.sh` 的 skillMap 遗漏项：新增 `devflow-plugin-config` 和 `devflow-plugin-sync`
- 修复 `update-devflow.bat` 标题硬编码版本号，改为通用名称 `DevFlow Updater`

## v2.7.4

### Changed
- 消除版本字段语义歧义：所有配置文件中 `version` 统一重命名为 `devflowVersion`（插件版本）和 `projectVersion`（项目版本），涉及 3 个 JSON 文件
- 修正 5 个安装/同步脚本（setup.ps1/sh、sync-skills.ps1、update.ps1/sh）中的版本字段读取逻辑
- 修正 3 个技能模板（devflow-init、phase-manager、project-config）中的版本字段引用
- 删除遗留文件 `.devflow/version.json`（旧版 v2.4.1 备份）

## v2.7.3

### Changed
- `setup.ps1` / `setup.sh` 剥离项目初始化逻辑（项目名检测、`.devflow/` 创建、config.json 生成、state.json 生成），回归纯全局技能安装职责（V260-030）
- `update.ps1` / `update.sh` 移除修改 `.devflow/config.json` 中 `projectVersion` 的越界行为（V260-031）
- `devflow-init/SKILL.md` 增强：新增从 `version.json` 读取 DevFlow 版本号并写入项目配置的逻辑（V260-032）
- `devflow-init/SKILL.md` 增强：新增 `projectVersion` 自动扫描+交互补充链（Git tag → package.json → pyproject.toml → 其他配置文件 → 交互询问）（V260-033）
- `devflow-init/SKILL.md` 增强：完善 `currentPhase` 文档扫描推断逻辑并写入 state.json（V260-034）

## v2.6.0

### Changed
- 增强 8 个技能文件（4 个增强 + 4 个重构），涉及 L1/L2/L3 层
- 修复 5 个 P1 缺陷（阈值不一致问题）
- 修复 `devflow-init` 初始化未强制填写仓库地址问题（V260-007）
- 优化审计流程一致性，修复 L1 文档残留 ≥90% 阈值问题

### Note
- 本版本规划了 V260-001~005（Agent 协作、自动化审计、追溯链可视化、并行阶段、模板国际化），因需预研已延后至后续版本

## v2.5.0

### Added
- 新增 L3 技能：`skill-md-writing-standards`（SKILL.md 编写标准）— 统一全部技能文件的格式、结构、内容和编码规范
- 新增 L3 技能：`security-design-review`（安全设计评审）— 架构设计阶段威胁建模、安全架构评审、数据分类分级
- 新增 L3 技能：`secure-coding-practices`（安全编码实践）— 通用安全准则 + JS/TS/Python/Go 语言特定规范，映射 OWASP Top 10
- 新增 L3 技能：`container-deployment`（容器化部署）— Dockerfile 最佳实践、Docker Compose 编排、K8s 部署规范
- 新增 L3 技能：`performance-engineering`（性能工程）— 性能基线管理、容量规划、负载测试、性能回归门禁
- 新增 L3 技能：`database-migration`（数据库迁移）— 迁移策略、版本控制、回滚方案、数据校验
- 新增模板：DR-备份完整性校验规范、DR-备份策略配置指南、DR-多地域备份方案、DR-数据恢复演练流程、DR-灾难恢复预案
- 新增脚本：check-references.ps1/sh（技能引用校验）、check-skill-format.ps1（技能格式校验）、validate-install.ps1/sh（安装验证）
- 新增安装方式：install.bat / install.ps1 / install.sh（跨平台一键安装）
- 新增快速启动文档：quickstart.md / quickstart.html

### Changed
- 技能总数：22 → 28（+6 L3 技能）
- 文档模板：19 → 24（+5 DR 灾备模板）
- 总行数：5600 → 7800 | 总字节：340KB → 480KB
- 版本号：v2.4.1 → v2.5.0（所有引用位置同步更新）

## v2.4.1

### Changed
- 统一版本号：所有文件从 v2.3.1 同步更新至 v2.4.1
- 建立单一版本来源机制：`version.json` 为唯一权威版本源，所有技能和配置通过运行时读取或文档引用保持一致

## v2.3.1

### Added
- 完整回滚设计体系：code-version-backup-management 第六章扩展为 10 小节（策略/触发/审批/路径/数据/验证/CI Job/审计/门禁/清单）
- CI/CD 回滚自动化：cicd-pipeline-management 新增"回滚自动化"独立章节（触发条件/rollback.yml/金丝雀自动回滚/路径表）
- 设计总览首页规范：prototype-coverage 新增 Step 1.5，design-stage-execution 矩阵和输出要求增强
- 多环境备份配置：config.json 新增 `backup.environments`（dev/test/pro/disaster）
- 自动推断备份 URL：setup.ps1/sh 安装时基于 origin URL 自动生成建议 backup URL
- 增强 Hook 脚本：post-push 增加日志记录、错误处理、备份验证

### Changed
- operations-stage-execution 部署矩阵/强制规则/L3速查增强回滚相关内容
- devflow-project-config/devflow-init config.json 模板同步增强
- 版本号：v2.3.0 → v2.3.1（所有硬编码位置同步更新）

## v2.3.0

### Added
- 新增 L3 技能：`prototype-coverage`（前端原型覆盖检查）— 七步流程：页面清单 → 状态覆盖 → 原型走查 → 用例演练 → 交互标注 → 测试预映射 → 覆盖报告
- 新增 L3 技能：`backend-coverage`（后端设计覆盖检查）— 五步流程：API 契约覆盖 → 数据模型对齐 → 状态机覆盖 → 安全设计 → 测试预映射
- `api-contract-management` 新增"API 契约对齐检查"环节，支持前端页面清单 ↔ 后端 API 设计交叉验证
- L2 阶段执行技能集成引用：design-stage-execution 新增前端/后端覆盖检查引用；coding-stage-execution 新增前后端编码规范区分引用；testing-stage-execution 新增设计-测试预映射验证引用

### Changed
- 所有安装脚本技能数量从 20 更新为 22
- L3 技能数量 8→10，总技能数量 20→22

## v2.2.0

### Added
- 新增 L3 技能：`api-contract-management`（API 契约管理）— 覆盖前后端异构技术栈（Python + TypeScript）的 API 一致性全流程管控
- L2 阶段执行技能集成引用：design/coding/testing/operations 四个阶段均增加了对 `api-contract-management` 的引用指引
- 新增独立同步工具 `sync-skills.ps1`，支持一键批量卸载+安装所有 DevFlow 技能

### Changed
- 所有安装脚本（setup.ps1/update.ps1/setup.sh/update.sh/sync-skills.ps1）技能数量从 19 更新为 20
- 安装逻辑统一改为"先卸载后安装"两阶段模式，确保版本升级时旧技能完全清理
- 补齐 L3 层遗漏的 `code-version-backup-management` 技能注册

## v2.1.0

### Added
- 插件化架构：orchestrator 层（devflow-init / devflow-phase-manager / devflow-project-config）
- 三层技能分层：L1 总控调度 / L2 阶段执行 / L3 专项参考
- 编译层模式：L2 内联 L3 核心规则速查表，运行时深度控制在 2 层
- 18 个标准文档模板
- setup.ps1 / setup.sh 安装脚本（支持 TRAE / Claude Code / Cursor / Codex CLI）
- update.ps1 / update.sh 更新脚本
- Git post-push hook 自动备份
- 可配置分支策略（trunk-based / github-flow / git-flow）

### Skills
- L1: project-development-workflow, project-document-management, project-role-management
- L2: version-planning-stage-execution, requirements-stage-execution, design-stage-execution, coding-stage-execution, testing-stage-execution, operations-stage-execution
- L3: project-coding-conventions, code-static-quality-check, code-logic-review, cicd-pipeline-management, observability-standards, project-document-templates
- Orchestrator: devflow-init, devflow-phase-manager, devflow-project-config

## v2.0.0

### 初始版本
- 6 阶段工程管控流程（Step 0-5）
- 需求→设计→开发→测试全链路追溯（RT-ID / DT-ID / TD-ID）
- 审计门禁机制
- TDD 铁律
