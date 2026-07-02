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
- `install.bat` / `install.ps1` 安装向导脚本（交互式安装向导）
- `setup.ps1` 技能安装列表补充遗漏的 `code-version-backup-management`
- 发布新版本时的强制检查清单（grep 硬编码残留 + setup.ps1 验证）

## v2.3.1 (2026-07-01)

### Added
- **完整回滚设计体系**：`code-version-backup-management` 回滚流程从 2 节扩展为 10 节
  - 回滚策略总览（代码/数据/配置/服务四类）
  - 回滚触发条件（自动触发：健康检查失败、错误率飙升、P99 延迟等）
  - 回滚审批流程（审批级别矩阵、标准审批、P0 紧急回滚）
  - 按部署策略的回滚路径（直接部署/蓝绿部署/金丝雀发布/滚动更新 K8s）
  - 数据回滚策略（数据库回滚、缓存与消息回滚）
  - 回滚验证（验证清单 + 回滚失败处理）
  - CI/CD 自动回滚 Job 设计（GitHub Actions 回滚 Job + 金丝雀自动回滚）
  - 回滚记录与审计（回滚历史 CSV + 增强版回滚门禁 6 条规则）
  - 与现有技能的衔接
  - 执行检查清单（发布前/回滚时/回滚后）
- `cicd-pipeline-management.md`：新增"回滚自动化"章节（+111 行）
- `prototype-coverage.md`：新增 Step 1.5 设计总览首页
- `devflow-project-config` / `devflow-init`：config.json 增加 `backup.environments` 多环境备份配置

### Changed
- `operations-stage-execution.md`：部署矩阵/强制规则/L3 速查增强
- `design-stage-execution.md`：UI/UX 矩阵和输出增强
- `setup.ps1` / `setup.sh`：自动推断备份 URL + 增强 Hook

## v2.3.0 (2026-06-29)

### Added
- `prototype-coverage`：前端原型覆盖率（7 步流程）
- `backend-coverage`：后端设计覆盖率（5 步流程）
- `api-contract-management`：API 契约对齐检查
- 技能总数从 15 个增加到 22 个

### Changed
- 更新 design/coding/testing stage 技能交叉引用
- 更新 setup/update 脚本支持 22 个技能
- 归档旧版前端后端工程规范 v1.3.0

## v2.1.0 (2026-06-26)

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

## v2.0.0 (2026-06-24)

### 初始版本
- 6 阶段工程管控流程（Step 0-5）
- 需求→设计→开发→测试全链路追溯（RT-ID / DT-ID / TD-ID）
- 审计门禁机制
- TDD 铁律
