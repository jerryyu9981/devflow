# DevFlow Changelog

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
