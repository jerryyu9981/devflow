# DevFlow v2.5.0 — 回滚方案

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| 项目名 | DevFlow |
| 版本号 | v2.5.0 |
| 状态 | 草稿 |
| 日期 | 2026-07-04 |
| 负责人 | jerry.yu |
| 回滚目标版本 | v2.4.1（上一个稳定版本） |

## 2. 回滚策略

| 策略 | 说明 | 推荐度 |
|------|------|--------|
| 主策略：git revert | 推荐使用，保留完整提交历史 | 推荐 |
| 备选策略：git checkout v2.4.1 -- {files} | 恢复特定文件到 v2.4.1 状态 | 备选 |

## 3. 回滚触发条件

| 条件 | 级别 | 处理方式 |
|------|------|----------|
| devflow-init 远程仓库配置功能异常 | 立即回滚 | 停止使用，执行 git revert |
| 新增技能文件格式错误导致技能系统无法加载 | 立即回滚 | 停止使用，执行 git revert |
| L2 速查表引用错误 | 24 小时内评估 | 评估修复或回滚 |
| P2/P3 缺陷 | 记录 | 纳入后续版本修复 |

## 4. 回滚步骤

### 主策略：Git Revert（推荐，保留历史）

```bash
git revert {v2.5.0 commit hash}
git push origin master
```

### 备选策略：恢复特定文件

```bash
git checkout v2.4.1 -- devflow-init/SKILL.md
git checkout v2.4.1 -- skills/L3/performance-engineering.md
git checkout v2.4.1 -- skills/L3/database-migration.md
git checkout v2.4.1 -- skills/L2/coding-stage-execution.md
git checkout v2.4.1 -- skills/L2/testing-stage-execution.md
git add -A
git commit -m "revert: rollback v2.5.0 to v2.4.1"
git push origin master
```

### 回滚后验证

1. 验证 devflow-init/SKILL.md 不包含 §2.5 章节
2. 验证 skills/L3/ 目录不含 performance-engineering.md 和 database-migration.md
3. 验证 L2 速查表不含 performance-engineering 引用

## 5. 回滚验证清单

| 验证项 | 方法 | 预期结果 |
|--------|------|----------|
| Git 日志确认 | git log --oneline -3 | revert commit 在最前 |
| devflow-init/SKILL.md | 搜索 §2.5 章节 | 不包含远程仓库配置章节 |
| skills/L3/performance-engineering.md | 检查文件存在性 | 文件不存在 |
| skills/L3/database-migration.md | 检查文件存在性 | 文件不存在 |
| L2 速查表引用 | 检查 coding-stage-execution.md 和 testing-stage-execution.md | 不包含 performance-engineering 引用 |

## 6. 回滚演练

| 演练项 | 状态 | 说明 |
|--------|------|------|
| Git revert 可行性 | 已验证 | v2.4.1 tag 存在，revert 路径可行 |
| 运行时恢复步骤 | 已记录 | 用户需重新安装 v2.4.1 |
| 数据一致性 | N/A | 无数据变更 |

## 7. 变更记录

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| 1.0 | 2026-07-04 | v2.5.0 回滚方案初始版本 |
