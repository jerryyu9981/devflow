# DevFlow v2.4.0 — 回滚方案

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| 版本号 | v2.4.0 |
| 回滚目标版本 | v2.3.2（上一个稳定版本） |
| 编制日期 | 2026-07-03 |

## 2. 回滚触发条件

| 条件 | 级别 | 处理方式 |
|------|------|----------|
| 发现 P0 缺陷（技能加载失败、安装脚本崩溃） | 立即回滚 | 停止发布，revert commit |
| 发现 P1 缺陷（关键功能缺失、兼容性问题） | 24 小时内评估 | 评估修复或回滚 |
| P2/P3 缺陷 | 记录 | v2.4.1 修复 |

## 3. 回滚步骤

### 方式一：Git Revert（推荐，保留历史）

```bash
git revert <v2.4.0-commit-hash>
git push origin main
```

### 方式二：Git Reset（仅本地，不推荐）

```bash
git reset --hard v2.3.2
git push origin main --force
```

### 方式三：分支恢复

```bash
git checkout -b hotfix/v2.4.0-rollback v2.3.2
git checkout main
git merge hotfix/v2.4.0-rollback
git push origin main
```

## 4. 数据回滚

DevFlow 为技能插件，无数据库、无运行时状态。回滚仅需恢复 Git 仓库中的文件。

用户已安装到运行时目录（`~/.trae-cn/skills/`）的技能文件需手动删除或重新安装 v2.3.2：
```bash
# 删除 v2.4.0 新增技能
rm -rf ~/.trae-cn/skills/skill-md-writing-standards
rm -rf ~/.trae-cn/skills/security-design-review
rm -rf ~/.trae-cn/skills/secure-coding-practices
rm -rf ~/.trae-cn/skills/container-deployment

# 重新安装 v2.3.2
cd devflow-plugin-v2.3.2
bash install.sh  # 或 powershell -File install.ps1
```

## 5. 回滚验证

| 验证项 | 方法 | 预期 |
|--------|------|------|
| Git 日志确认 | git log --oneline -3 | 回滚 commit 在最前 |
| version.json 版本 | cat version.json | 显示 2.3.2 |
| 技能文件数量 | ls skills/ | 22 个（非 26 个） |
| 安装脚本功能 | 运行 install.ps1 | v2.3.2 功能正常 |

## 6. 回滚演练

| 演练项 | 状态 | 说明 |
|--------|------|------|
| Git revert 可行性 | ✅ 已验证 | v2.3.2 tag 存在，revert 路径可行 |
| 运行时恢复步骤 | 📋 已记录 | 用户需手动删除新技能 |
| 数据一致性 | N/A | 无数据库 |

## 7. 变更记录

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| 1.0 | 2026-07-03 | v2.4.0 回滚方案初始版本 |
