# DevFlow Changelog

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
