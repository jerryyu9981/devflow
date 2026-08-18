# DevFlow 回滚方案 — v2.18.0

> 文档类型：回滚方案
> 版本：v2.18.0
> 日期：2026-08-19
> 作者：DO-DevFlow-Dev（DevOps工程师）

---

## 1. 回滚概览

| 项 | 内容 |
|:---|:-----|
| 目标版本 | v2.18.0 |
| 回滚目标 | v2.17.0（上一发布版本 tag）|
| 部署策略 | 直接发布（文档型项目）|
| 回滚类型 | 代码回滚（Git）+ 文档回滚 + hook 回滚 |

## 2. 回滚路径

### 2.1 代码/文档回滚

```text
git revert <v2.18.0 commit hash>  # 推荐：保留历史
# 或
git checkout v2.17.0 -- doc/ devflow-plugin/skills/  # 恢复特定文件
```

### 2.2 版本号回滚

| 配置源 | 回滚值 |
|:-------|:-------|
| devflow-config.json devflowVersion | 2.17.0 |
| project-config.json project.version | v2.17.0 |
| state.json devflowVersion | 2.17.0 |

### 2.3 hook 回滚

```text
# 恢复 v2.17.0 版本 hook（含 mirror 无 --no-verify 的原始版本）
# 或从 Git 历史检出 .devflow/hooks/ + .git/hooks/pre-push
git checkout v2.17.0 -- .devflow/hooks/ .git/hooks/pre-push
```

> ⚠️ 注意：v2.18.0 已修复 hook 递归问题，回滚 hook 会恢复旧问题——如非必要不建议回滚 hook，仅回滚规范文档部分。

## 3. 回滚触发条件

| 触发类型 | 条件 |
|:---------|:-----|
| 自动触发 | 文档验证失败 / 三远程 tag 不一致（TAG-CHECK WARN）|
| 手动触发 | P0 缺陷 / 规范冲突 / 用户反馈严重问题 |

## 4. 审批流程

| 场景 | 审批 |
|:-----|:-----|
| 标准回滚 | 发布负责人 + PM 双签 |
| 紧急回滚（P0）| 跳过审批，2 小时补材料，24 小时输出 RCA |

## 5. 回滚后验证（15 分钟内）

| 验证项 | 命令 | 预期 |
|:-------|:-----|:-----|
| 版本号回滚确认 | grep devflowVersion devflow-config.json | 2.17.0 |
| 技能文档回滚确认 | Grep T3a v2.18.0 章节 | 回滚前内容 |
| tag 回滚确认 | git tag -l | v2.18.0 移除或 v2.17.0 存在 |

## 6. 数据回滚

> 本版本无数据库变更，无数据回滚需求（N/A）。

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-19 | 初始创建，Git 回滚 + 版本号回滚 + hook 回滚（含回滚警告）| DO-DevFlow-Dev |
