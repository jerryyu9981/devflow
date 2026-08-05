# DevFlow v2.4.1 — 回滚方案

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| 项目名 | DevFlow |
| 版本号 | v2.4.1 |
| 状态 | 草稿 |
| 日期 | 2026-07-03 |
| 负责人 | jerry.yu |
| 回滚目标版本 | v2.4.0（上一个稳定版本） |

## 2. 回滚触发条件

| 条件 | 级别 | 处理方式 |
|------|------|----------|
| 发现 P0 缺陷（技能加载失败、脚本执行异常） | 立即回滚 | 停止使用，执行 git revert |
| 发现 P1 缺陷（关键格式问题、兼容性问题） | 24 小时内评估 | 评估修复或回滚 |
| P2/P3 缺陷 | 记录 | 纳入后续版本修复 |

## 3. 回滚步骤

### 方式一：Git Revert（推荐，保留历史）

```bash
git revert cf122e0
git push origin master
```

### 方式二：Git Reset（仅本地，不推荐）

```bash
git reset --hard v2.4.0
git push origin master --force
```

### 方式三：分支恢复

```bash
git checkout -b hotfix/v2.4.1-rollback v2.4.0
git checkout master
git merge hotfix/v2.4.1-rollback
git push origin master
```

## 4. 数据回滚

DevFlow v2.4.1 为 Hotfix 版本，仅修改技能文件和脚本，无数据库、无运行时状态变更。

**数据回滚：不适用（无数据变更）**

用户已安装到运行时目录的技能文件需重新安装 v2.4.0 以恢复：
```bash
# 重新安装 v2.4.0
cd devflow-plugin-v2.4.0
bash install.sh  # 或 powershell -File install.ps1
```

## 5. 回滚验证

| 验证项 | 方法 | 预期 |
|--------|------|------|
| Git 日志确认 | git log --oneline -3 | revert commit 在最前 |
| 修改文件恢复 | git diff v2.4.0 HEAD --stat | 7 个文件恢复到 v2.4.0 状态 |
| version.json 版本 | cat version.json | 显示 2.4.0 |
| 脚本执行正常 | 运行 check-skill-format.ps1 | 无 BOM 相关错误 |

## 6. 回滚演练

| 演练项 | 状态 | 说明 |
|--------|------|------|
| Git revert 可行性 | ✅ 已验证 | v2.4.0 tag 存在，revert 路径可行 |
| 运行时恢复步骤 | 📋 已记录 | 用户需重新安装 v2.4.0 |
| 数据一致性 | N/A | 无数据变更 |

## 7. 变更记录

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| 1.0 | 2026-07-03 | v2.4.1 回滚方案初始版本 |
