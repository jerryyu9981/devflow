# DevFlow 回滚方案 v2.8.5

> **文档类型**: 回滚方案
> **版本**: v2.8.5
> **项目**: DevFlow
> **日期**: 2026-07-20

---

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| 部署方式 | Git Tag + 双远程推送 |
| 部署策略 | 直接部署（Git Tag）|
| 待回滚版本 | v2.8.5 |
| 目标回滚版本 | v2.8.4 |
| 数据变更 | 无（DevFlow 为技能框架项目，无数据库）|
| 回滚负责人 | PM-DevFlow-Dev |

## 2. 回滚触发条件

### 自动触发
- 健康检查/冒烟验证失败（不适用 — 无运行服务）
- 错误率 > 1%（不适用 — 无 API 服务）

### 手动触发
| 场景 | 级别 | 行动 |
|:----|:----:|:-----|
| 发布后发现 P0 缺陷 | P0 | 紧急回滚（跳过审批，2h 补材料）|
| 发布后发现 P1 缺陷 | P1 | 标准回滚（审批 + 验证）|
| 发布后技能文件格式/语法错误 | P1 | 标准回滚 |
| 发布文档/Release Note 重大错误 | P2 | 补发修正版本 |

## 3. 回滚步骤

### 代码回滚

```powershell
# 步骤 1: 确认当前版本
git tag -l 'v2.8.5'
git log --oneline -3

# 步骤 2: 回滚到 v2.8.4（保留历史）
git revert v2.8.4..v2.8.5 --no-edit

# 或：回滚到上一个安全提交
git revert HEAD~1 --no-edit

# 步骤 3: 推送回滚到远程
git push origin master
git push backup master

# 步骤 4: 删除异常 Tag
git tag -d v2.8.5
git push origin --delete v2.8.5
git push backup --delete v2.8.5

# 步骤 5: 验证
git log --oneline -3
git tag -l 'v2.8.5'  # 应不显示
```

### Tag 级别回滚（保留代码，仅修正 Tag）

```powershell
# 仅修正 Tag 位置
git tag -d v2.8.5
git tag v2.8.5 <正确-commit-hash>
git push origin v2.8.5 --force
git push backup v2.8.5 --force
```

## 4. 回滚后验证

| 验证项 | 验证方式 |
|--------|---------|
| version.json 版本号 | `git show HEAD:devflow-plugin/version.json` |
| 技能文件完整性 | `git diff v2.8.4..HEAD --stat` |
| Tag 清除验证 | `git tag -l 'v2.8.5'` 不应显示 |

## 5. 审批流程

| 场景 | 审批人 |
|:----|:-------|
| 标准回滚（非 P0） | PM-DevFlow |
| 紧急回滚（P0） | 跳过审批，2h 补材料 |
| 数据回滚（如有 DB） | 不适用（无 DB）|

## 6. 回滚后行动

| 时间 | 行动 |
|:----:|:-----|
| 回滚后 15min | 完成验证 |
| 回滚后 2h | 补录紧急回滚材料（如有）|
| 回滚后 24h | 输出 RCA 报告 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-20 | v2.8.5 回滚方案 | PM-DevFlow-Dev |
