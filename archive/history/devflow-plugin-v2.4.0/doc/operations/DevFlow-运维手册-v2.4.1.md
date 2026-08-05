# DevFlow v2.4.1 — 运维手册

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| 项目名 | DevFlow |
| 版本号 | v2.4.1 |
| 状态 | 草稿 |
| 日期 | 2026-07-03 |
| 负责人 | jerry.yu |
| 版本类型 | Hotfix |

## 2. 版本信息

| 项目 | 内容 |
|------|------|
| 基准版本 | v2.4.0 |
| 修复类型 | 技能文件格式标准化 + 脚本 BOM 修复 |
| 影响范围 | 7 个文件 |

## 3. 修改文件清单

| 序号 | 文件路径 | 类型 | 变更说明 |
|------|----------|------|----------|
| 1 | skills/L3/secure-coding-practices.md | 技能文件 | 格式标准化 |
| 2 | skills/L3/security-design-review.md | 技能文件 | 格式标准化 |
| 3 | skills/L3/skill-md-writing-standards.md | 技能文件 | 格式标准化 |
| 4 | skills/L3/container-deployment.md | 技能文件 | 格式标准化 |
| 5 | scripts/check-skill-format.ps1 | 脚本 | 双 BOM 修复 |
| 6 | scripts/check-references.ps1 | 脚本 | 双 BOM 修复 |
| 7 | .devflow/state.json | 状态文件 | 阶段状态更新 |

## 4. 质量检查脚本

| 脚本 | 用途 | 命令 |
|------|------|------|
| check-skill-format.ps1 | 10 项格式检查（已修复双 BOM） | `powershell -File scripts/check-skill-format.ps1 [-Fix]` |
| check-references.ps1 | 5 项引用检查（已修复双 BOM） | `powershell -File scripts/check-references.ps1` |
| validate-install.ps1 | 6 项安装验证 | `powershell -File scripts/validate-install.ps1` |

## 5. 验证命令

部署 v2.4.1 后，建议执行以下验证命令确认修复生效：

```bash
# 验证技能文件格式
powershell -File scripts/check-skill-format.ps1

# 验证引用完整性
powershell -File scripts/check-references.ps1

# 验证安装完整性
powershell -File scripts/validate-install.ps1
```

## 6. 常见问题排查

| 问题 | 排查方法 | 解决方案 |
|------|----------|----------|
| 技能缓存未更新 | 检查当前会话加载的技能版本 | **需开启新会话加载**。技能文件由 AI 平台在会话启动时加载，修改后需新会话才能生效 |
| check-skill-format.ps1 报 BOM 错误 | 检查文件编码 | v2.4.1 已修复双 BOM 问题，重新执行即可 |
| check-references.ps1 报 BOM 错误 | 检查文件编码 | v2.4.1 已修复双 BOM 问题，重新执行即可 |
| 技能文件格式检查仍有 FAIL | 运行 check-skill-format.ps1 -Fix | 自动修复尾随空格等格式问题 |

## 7. 不适用项说明

DevFlow v2.4.1 为 Hotfix 版本（技能文件 + 脚本修改），以下运维类别不适用：
- 数据库迁移 / 缓存与消息运维 / CI/CD 流水线
- 容器部署 / 性能检查 / 安全检查 / 监控日志告警

## 8. 联系方式

| 角色 | 联系方式 |
|------|----------|
| 项目负责人 | jerry.yu |
| 反馈渠道 | CHANGELOG.md + 快速入门 |

## 9. 变更记录

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| 1.0 | 2026-07-03 | v2.4.1 运维手册初始版本 |
