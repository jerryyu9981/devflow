# DevFlow v2.4.0 — Cursor 兼容性验证清单

## 文档信息

| 属性 | 内容 |
|------|------|
| 文档编号 | VR-016 |
| 关联版本 | v2.4.0 |
| 编写日期 | YYYY-MM-DD |
| 验证平台 | Cursor（Agent 模式 / Composer 模式 / Tab 模式） |
| 兼容性等级 | ✅ 完全支持 |

## 1. 环境前置检查

| 检查项 | 验证方法 | 预期结果 | 实际结果 |
|--------|----------|----------|----------|
| Cursor 版本 | Cursor → 设置 → 关于 | ≥ 0.40.x | — |
| Agent 模式可用 | Ctrl+K 切换 Agent 模式 | 可正常切换 | — |
| Composer 模式可用 | Ctrl+Shift+I 打开 Composer | 可正常打开 | — |
| 项目目录结构 | 文件浏览器查看 `.devflow/` | 包含 config.json, state.json | — |
| 技能文件可见 | 文件浏览器查看 `skills/` | 26 个技能文件完整 | — |
| 模板文件可见 | 文件浏览器查看 `templates/` | 24 个模板文件完整 | — |

## 2. Agent 模式兼容性验证

Cursor Agent 模式是 DevFlow 的主要交互入口，需要验证 Agent 模式下技能文件的加载和执行。

| 检查项 | 验证方法 | 预期结果 | 实际结果 |
|--------|----------|----------|----------|
| @Skill 语法识别 | 输入 `Use Skill: version-planning-stage-execution` | Cursor 自动识别 skill 引用 | — |
| 技能文件上下文注入 | 在 Agent 模式下提问"DevFlow 的版本是多少" | 正确回答 v2.4.0 | — |
| 多技能协同 | 要求"使用 version-planning-stage-execution 做规划" | 技能被正确加载引用 | — |
| 技能文件搜索 | Ctrl+P 搜索 "coding-stage-execution.md" | 可以定位到技能文件 | — |
| L3 速查表可读 | Agent 模式下询问"编码约定的安全规则" | 可正确引用 project-coding-conventions 内容 | — |

## 3. Composer 模式兼容性验证

Composer 模式用于多文件编辑，验证 DevFlow 在 Composer 模式下的使用体验。

| 检查项 | 验证方法 | 预期结果 | 实际结果 |
|--------|----------|----------|----------|
| Composer 打开 | Ctrl+Shift+I | 正常打开 Composer 面板 | — |
| 技能引用 | 在 Composer 中引用技能文件 | 技能文件内容被正确包含 | — |
| 多文件编辑 | 按 DevFlow 规范编辑多个文件 | 编辑结果符合规范 | — |

## 4. Tab 模式兼容性验证

| 检查项 | 验证方法 | 预期结果 | 实际结果 |
|--------|----------|----------|----------|
| 代码补全 | 在符合规范的位置输入代码 | Tab 正常提供补全 | — |
| 模板补全 | 编辑模板文件时 | 模板内容正常显示 | — |

## 5. 技能文件加载完整性

### 5.1 编排层（Orchestrator）

| 技能 | 文件路径 | 加载状态 | 备注 |
|------|----------|----------|------|
| devflow-init | skills/orchestrator/devflow-init/SKILL.md | — | — |
| devflow-phase-manager | skills/orchestrator/devflow-phase-manager/SKILL.md | — | — |
| devflow-project-config | skills/orchestrator/devflow-project-config/SKILL.md | — | — |

### 5.2 L1 编排层

| 技能 | 文件路径 | 加载状态 | 备注 |
|------|----------|----------|------|
| project-development-workflow | skills/L1/project-development-workflow.md | — | — |
| project-document-management | skills/L1/project-document-management.md | — | — |
| project-role-management | skills/L1/project-role-management.md | — | — |

### 5.3 L2 阶段执行层

| 技能 | 文件路径 | 加载状态 | 备注 |
|------|----------|----------|------|
| version-planning-stage-execution | skills/L2/version-planning-stage-execution.md | — | — |
| requirements-stage-execution | skills/L2/requirements-stage-execution.md | — | — |
| design-stage-execution | skills/L2/design-stage-execution.md | — | — |
| coding-stage-execution | skills/L2/coding-stage-execution.md | — | — |
| testing-stage-execution | skills/L2/testing-stage-execution.md | — | — |
| operations-stage-execution | skills/L2/operations-stage-execution.md | — | — |

### 5.4 L3 专项参考层

| 技能 | 文件路径 | 加载状态 | 备注 |
|------|----------|----------|------|
| project-coding-conventions | skills/L3/project-coding-conventions.md | — | — |
| code-static-quality-check | skills/L3/code-static-quality-check.md | — | — |
| code-logic-review | skills/L3/code-logic-review.md | — | — |
| cicd-pipeline-management | skills/L3/cicd-pipeline-management.md | — | — |
| observability-standards | skills/L3/observability-standards.md | — | — |
| project-document-templates | skills/L3/project-document-templates.md | — | — |
| code-version-backup-management | skills/L3/code-version-backup-management.md | — | — |
| skill-md-writing-standards | skills/L3/skill-md-writing-standards.md | — | — |
| prototype-coverage | skills/L3/prototype-coverage.md | — | — |
| backend-coverage | skills/L3/backend-coverage.md | — | — |
| api-contract-management | skills/L3/api-contract-management.md | — | — |
| security-design-review | skills/L3/security-design-review.md | — | — |
| secure-coding-practices | skills/L3/secure-coding-practices.md | — | — |
| container-deployment | skills/L3/container-deployment.md | — | — |

## 6. 脚本兼容性验证

| 检查项 | 验证方法 | 预期结果 | 实际结果 |
|--------|----------|----------|----------|
| 终端集成 | Cursor 内置终端运行 `powershell -File install.ps1` | 正常执行 | — |
| 终端集成（bash） | Cursor 内置终端运行 `bash install.sh` | 正常执行（WSL/Git Bash） | — |
| 格式检查 | `powershell -File scripts/check-skill-format.ps1` | 正常输出检查结果 | — |
| 引用检查 | `powershell -File scripts/check-references.ps1` | 正常输出检查结果 | — |

## 7. UTF-8 编码验证

| 检查项 | 验证方法 | 预期结果 | 实际结果 |
|--------|----------|----------|----------|
| 中文字符渲染 | Cursor 中打开含中文的技能文件 | 中文正常显示 | — |
| 无 BOM 头 | 文件 → 编码查看 | 均为 UTF-8 无 BOM | — |

## 8. 已知限制与风险

| 风险编号 | 描述 | 严重程度 | 缓解措施 |
|----------|------|----------|----------|
| CUR-001 | Cursor Agent 模式对 `Use Skill:` 的 `Rules` 文件引用方式可能因版本变更而变化 | P2 | 保持 Rules 配置与 Cursor 版本同步 |
| CUR-002 | Cursor Composer 模式在处理大量技能文件时可能响应变慢 | P2 | 优先使用 Agent 模式进行 DevFlow 操作 |
| CUR-003 | `.ps1` 脚本在 macOS/Linux 上需要 PowerShell Core 才能运行 | P1 | 提供对应的 `.sh` 等价脚本（已实现） |
| CUR-004 | Cursor 内置终端可能无法正确渲染彩色 ASCII 图形 | P2 | 已安装脚本使用 `Write-Host -ForegroundColor` 确保兼容 |

---

## 验证结论

| 项目 | 内容 |
|------|------|
| 验证日期 | YYYY-MM-DD |
| 验证人 | — |
| 总体结论 | □ 完全兼容 □ 有条件兼容 □ 不兼容 |
| 阻塞问题 | — |
| 备注 | — |