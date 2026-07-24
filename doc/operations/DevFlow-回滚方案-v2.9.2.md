# DevFlow 回滚方案 v2.9.2

> **文档类型**: 回滚方案（含回滚预案/回滚演练记录）
> **版本**: v2.9.2
> **项目**: DevFlow
> **日期**: 2026-07-23

---

## 1. 回滚预案

### 1.1 回滚触发条件

| 触发条件 | 说明 |
|:---------|:------|
| 配置错误 | 发布后发现配置文件格式错误或字段值错误 |
| 模板问题 | operations-stage-execution.md 模板章节导致技能加载异常 |
| 自动触发 | 健康检查失败（如 version.json 无法解析） |

### 1.2 回滚步骤

| 步骤 | 操作 | 命令 |
|:----:|:-----|:-----|
| 1 | 从备份恢复 version.json | 从 `.devflow/backup/devflow-plugin_version.json.bak.20260723` 复制回 `devflow-plugin/version.json` |
| 2 | 从备份恢复 devflow-manifest.json | 从 `.devflow/backup/devflow-plugin_devflow-manifest.json.bak.20260723` 复制回 `devflow-plugin/devflow-manifest.json` |
| 3 | 恢复 version.json 原始版本 | `git checkout HEAD~1 -- version.json` |
| 4 | 恢复 devflow-config.json | `git checkout HEAD~1 -- devflow-plugin/devflow-config.json` |
| 5 | 恢复 .devflow/config.json | `git checkout HEAD~1 -- .devflow/config.json` |
| 6 | 恢复 operations-stage-execution.md | `git checkout HEAD~1 -- devflow-plugin/skills/L2/operations-stage-execution.md` |
| 7 | 回滚后验证 | 执行全部 8 个 TT 测试用例确认 |

### 1.3 部署策略对应回滚路径

| 部署策略 | 回滚路径 |
|:---------|:---------|
| 直接部署（文档型） | Git revert + 文件恢复 |

### 1.4 审批流程

| 回滚类型 | 审批人 |
|:---------|:-------|
| 标准回滚（非紧急） | PM-DevFlow-Release |
| 紧急回滚（P0 故障） | 无需审批，24 小时内补录 RCA |

## 2. 回滚演练记录

| 演练场景 | 步骤 | 结果 | 备注 |
|:---------|:-----|:----:|:-----|
| version.json 损坏回滚 | 从备份文件恢复并验证版本号 | ✅ 成功 | 备份文件可直接复制恢复 |
| 模板章节回退 | Git revert 恢复原始 operations-stage-execution.md | ✅ 成功 | 验证通过 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-23 | v2.9.2 回滚方案初始创建 | PM-DevFlow-Release |
