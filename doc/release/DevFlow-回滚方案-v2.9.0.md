# DevFlow 回滚方案 v2.9.0

> **文档类型**: 回滚方案（含回滚预案 + 回滚演练记录）
> **版本**: v2.9.0
> **项目**: DevFlow

---

## 1. 回滚预案

### 1.1 基本策略

| 项目 | 内容 |
|:-----|:------|
| 部署策略 | Git Tag 发布（双远程仓库同步） |
| 回滚目标版本 | v2.8.5 |
| 回滚路径 | git revert / git checkout |
| 数据回滚 | 🚫 不涉及数据库变更 |
| 审批人 | PM-DevFlow-Dev |

### 1.2 回滚触发条件

| 级别 | 触发条件 | 处理方式 |
|:----|:---------|:---------|
| P0 | Git Tag 创建失败 / 推送失败 / 验证失败 | Git reset + 重新 Tag |
| P0 | 发布后发现 P0 缺陷影响现有流程 | git revert |
| P1 | Release Note 或 Changelog 内容错误 | 直接修正并重新提交 |
| P1 | 版本号不一致 | 修正 version.json / config.json 并重新提交 |

### 1.3 回滚步骤

```bash
# 标准回滚（保留历史）
git revert v2.9.0
git push origin main
git push backup main

# 硬回滚（仅本地，紧急情况）
git tag -d v2.9.0
git push origin :refs/tags/v2.9.0
git push backup :refs/tags/v2.9.0
git checkout v2.8.5
# 重新打 tag
git tag v2.9.0
git push origin v2.9.0
git push backup v2.9.0
```

### 1.4 回滚后验证

| 验证项 | 方式 |
|:-------|:-----|
| 版本号检查 | `cat .devflow/config.json` → projectVersion 2.8.3（恢复后） |
| Tag 存在性 | `git tag -l v2.8.5` |
| 远程同步 | `git push origin --dry-run` |

---

## 2. 回滚演练记录

| 演练项目 | 结果 | 说明 |
|:---------|:----:|:------|
| 演练类型 | — | 文档型项目，无代码回滚需要启动验证 |
| 默认回滚策略 | ✅ 就绪 | git revert 保留历史，git reset 紧急处理 |
| 数据回滚 | 🚫 不适用 | 无数据库变更 |

---

## 3. 审批流程

| 场景 | 审批 | 说明 |
|:-----|:----:|:------|
| 标准回滚 (非 P0) | PM-DevFlow-Dev | 发布负责人自审 |
| 紧急回滚 (P0) | PM-DevFlow-Dev | 2 小时内补录材料，24 小时内输出 RCA |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-21 | v2.9.0 回滚方案 | PM-DevFlow-Dev |
