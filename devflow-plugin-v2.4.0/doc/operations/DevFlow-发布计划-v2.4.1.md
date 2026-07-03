# DevFlow v2.4.1 — 发布计划

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| 项目名 | DevFlow |
| 版本号 | v2.4.1 |
| 状态 | 草稿 |
| 日期 | 2026-07-03 |
| 负责人 | jerry.yu |
| 基准版本 | v2.4.0 |
| 发布类型 | Hotfix（技能文件 + 脚本修改） |
| 发布方式 | Git 提交 + Tag + Push to master |
| 影响范围 | 7 个文件（4 个技能 .md + 2 个脚本 .ps1 + 1 个 state.json） |

## 2. 发布入场检查

| 检查项 | 状态 | 说明 |
|--------|------|------|
| v2.4.0 遗留 P0/P1 缺陷已确认 | ✅ 通过 | BUG-001（check-skill-format.ps1 双 BOM）待修复 |
| 修复范围已明确 | ✅ 通过 | 4 个技能文件 + 2 个脚本 + 1 个 state.json |
| 回归影响评估 | ✅ 通过 | 修改仅涉及格式和脚本逻辑，无功能变更 |
| 文档齐备性 | ✅ 通过 | Step 5 运维文档 7 份 |
| 回滚方案就绪 | ✅ 通过 | git revert cf122e0 |

**入场结论：全部通过，允许执行发布。**

## 3. 版本与制品确认

| 项目 | 内容 |
|------|------|
| 发布分支 | master |
| 待创建 Tag | v2.4.1 |
| 制品内容 | devflow-plugin-v2.4.0/ 目录（Hotfix 修复） |
| 变更摘要 | 修复技能文件格式、脚本 BOM 问题、state.json 状态更新 |

## 4. 变更清单

### 修改文件（7 个）

| 序号 | 文件 | 类型 | 变更说明 |
|------|------|------|----------|
| 1 | skills/L3/secure-coding-practices.md | 技能文件 | 格式标准化 |
| 2 | skills/L3/security-design-review.md | 技能文件 | 格式标准化 |
| 3 | skills/L3/skill-md-writing-standards.md | 技能文件 | 格式标准化 |
| 4 | skills/L3/container-deployment.md | 技能文件 | 格式标准化 |
| 5 | scripts/check-skill-format.ps1 | 脚本 | 双 BOM 修复 |
| 6 | scripts/check-references.ps1 | 脚本 | 双 BOM 修复 |
| 7 | .devflow/state.json | 状态文件 | 阶段状态更新 |

## 5. 不适用项说明

DevFlow v2.4.1 为 Hotfix 版本（技能文件 + 脚本修改），以下运维类别不适用：
- 数据库迁移：无数据库
- 缓存与消息运维：无缓存/消息队列
- CI/CD 流水线：当前为手动 Git 发布
- 容器部署：无容器化需求
- 性能检查：无运行时性能指标
- 安全检查：无网络服务
- 监控日志告警：无运行时服务

## 6. 发布窗口

| 项目 | 内容 |
|------|------|
| 发布开始时间 | 2026-07-03 |
| 预计完成时间 | 2026-07-03（同日完成） |
| 发布步骤 | git add → git commit → git tag v2.4.1 → git push origin master |
| 回滚触发条件 | Tag 创建后发现 P0/P1 问题 |
| 回滚方式 | git revert cf122e0 |

## 7. 变更记录

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| 1.0 | 2026-07-03 | v2.4.1 发布计划初始版本 |
