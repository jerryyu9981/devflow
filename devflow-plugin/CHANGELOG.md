# DevFlow Changelog

## v2.3.2 (2026-07-02)

### Fixed
- 修复 `version.json` 版本号从 `2.1.1` 更新为 `2.3.2`（远程仓库遗漏）
- 修复 `install.ps1` / `setup.ps1` / `update.ps1` 中 `Get-Content` 读取 UTF-8 文件乱码问题，改用 `[System.IO.File]::ReadAllText` 强制 UTF-8 编码
- 修复 `devflow-init` 和 `devflow-project-config` 中硬编码版本号问题

### Changed
- `devflow-init/SKILL.md`：config.json 模板中 `devflowVersion` 改为 `{从 version.json 动态读取}` 占位符，新增"版本号单一来源原则"章节
- `devflow-project-config/SKILL.md`：同步版本号动态读取规范，约束章节新增版本号单一来源规则
- `code-version-backup-management.md`：新增 4.3 节"DevFlow 插件自身版本管理（Single Source of Truth）"

### Added
- `setup.ps1` 技能安装列表补充遗漏的 `code-version-backup-management`
- 发布新版本时的强制检查清单（grep 硬编码残留 + setup.ps1 验证）

## v2.3.1

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
