# DevFlow v2.5.0 — 运维手册

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| 项目名 | DevFlow |
| 版本号 | v2.5.0 |
| 状态 | 草稿 |
| 日期 | 2026-07-04 |
| 负责人 | jerry.yu |
| 版本类型 | Feature Release |
| 远程仓库 | http://192.168.0.14/jerry.yu/devflow.git |
| 目标分支 | master |

## 2. 版本信息

| 项目 | 内容 |
|------|------|
| 版本号 | v2.5.0 |
| 前一版本 | v2.4.1 |
| 新增文件 | 2 个 L3 技能 + 1 个编排器增强 |
| 修改文件 | 2 个 L2 技能速查表 |

## 3. 文件清单

### 3.1 新增文件（2 个 L3 技能）

| 文件路径 | 说明 |
|----------|------|
| skills/L3/performance-engineering.md | 性能工程全流程技能 |
| skills/L3/database-migration.md | 数据库迁移管理技能 |

### 3.2 修改文件（3 个）

| 文件路径 | 变更说明 |
|----------|----------|
| devflow-init/SKILL.md | 新增远程仓库交互式配置（§2.5 章节） |
| skills/L2/coding-stage-execution.md | 新增 L3 速查表引用 |
| skills/L2/testing-stage-execution.md | 新增 L3 速查表引用 |

## 4. 安装与更新

| 操作 | 方法 |
|------|------|
| 安装 | 运行 install.ps1 |
| 更新 | 运行 update.ps1 |
| 初始化 | 运行 devflow-init |

## 5. 常见操作

| 操作 | 方法 |
|------|------|
| 查看版本 | 读取 .devflow/config.json |
| 查看阶段状态 | 读取 .devflow/state.json |
| 运行技能格式检查 | check-skill-format.ps1 |

## 6. 质量检查脚本

| 脚本 | 用途 | 命令 |
|------|------|------|
| check-skill-format.ps1 | 10 项格式检查 | `powershell -File scripts/check-skill-format.ps1 [-Fix]` |
| check-references.ps1 | 5 项引用检查 | `powershell -File scripts/check-references.ps1` |
| validate-install.ps1 | 6 项安装验证 | `powershell -File scripts/validate-install.ps1` |

## 7. 已知问题

| 缺陷 ID | 描述 | 级别 | 阻塞状态 |
|---------|------|------|----------|
| BUG-001 | devflow-init 示例地址使用内网 IP | P2 | 非阻塞 |

## 8. 不适用项说明

DevFlow v2.5.0 为技能插件 Feature Release，以下运维类别不适用：
- 数据库迁移 / 缓存与消息运维 / CI/CD 流水线
- 容器部署 / 性能检查 / 安全检查 / 监控日志告警

## 9. 联系方式

| 角色 | 联系方式 |
|------|----------|
| 项目负责人 | jerry.yu |
| 反馈渠道 | CHANGELOG.md + 快速入门 |

## 10. 变更记录

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| 1.0 | 2026-07-04 | v2.5.0 运维手册初始版本 |
