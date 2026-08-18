# DevFlow TD-ID 追溯矩阵 — v2.18.0

> 文档类型：TD-ID 追溯矩阵（设计开发追溯矩阵）
> 版本：v2.18.0
> 状态：[Draft]
> 日期：2026-08-19
> 作者：AD-DevFlow-Dev（开发工程师）

---

## 1. 追溯矩阵

| TD-ID | DT-ID | RT-ID | 开发任务 | 涉及文件 | 完成状态 | 验证证据 |
|:-----:|:-----:|:-----:|:---------|:---------|:--------:|:---------|
| TD-218-001 | DT-218-001 | RT-218-001 | 新增"T3a 网络层巡检 E2E 用例模板"章节 | devflow-plugin/skills/L2/testing-stage-execution.md | ✅ 完成 | Grep 命中"T3a 网络层巡检 E2E 用例模板（v2.18.0+）" |
| TD-218-002 | DT-218-001 | RT-218-001 | 新增"CI 回归集成示例"章节 | devflow-plugin/skills/L2/testing-stage-execution.md | ✅ 完成 | Grep 命中"CI 回归集成示例" + network-scan |
| TD-218-003 | DT-218-001 | RT-218-001 | 新增"巡检结果自动报告方案"章节 | devflow-plugin/skills/L2/testing-stage-execution.md | ✅ 完成 | Grep 命中"巡检结果自动报告方案" + pytest --html |
| TD-218-004 | DT-218-002 | RT-218-002 | push-with-backup.ps1 mirror 命令加 --no-verify + tag 一致性检查 | .devflow/hooks/push-with-backup.ps1 | ✅ 完成 | Grep 命中 --no-verify ×2 + TAG-CHECK |
| TD-218-005 | DT-218-002 | RT-218-002 | post-push/pre-push 显式备份调用 + 同步 .git/hooks | .devflow/hooks/post-push + .git/hooks/pre-push | ✅ 完成 | MD5 一致 + --no-verify |
| TD-218-006 | DT-218-003 | RT-218-003 | 用户指南/手册版本号更新至 v2.18.0 + 内容核对 | DevFlow-用户指南.html + DevFlow-用户手册.html | ✅ 完成 | Grep 命中 v2.18.0 ×2 文件 |

## 2. 覆盖统计

| 统计项 | 数值 |
|--------|:----:|
| 设计项总数（DT-ID）| 3 |
| 有开发任务对应（TD-ID）| 3 |
| 开发任务总数 | 6 |
| 开发设计对比覆盖率 | 6/6 映射 3/3 = 100%（目标 ≥95%）✅ |
| 未完成项 | 0（6/6 全部完成）|

## 3. Subtask CheckList（子任务状态表）

| 设计规划的文件操作 | 实际完成 | 命名一致 | 说明 |
|:-------------------|:--------:|:--------:|:-----|
| testing-stage-execution.md 新增 3 章节 | ⏳ | — | L946 之后插入 |
| push-with-backup.ps1 修改 2 处 | ⏳ | — | L68/L93 加 --no-verify |
| push-with-backup.ps1 新增 tag 检查 | ⏳ | — | 三远程 tag 解引用一致 |
| post-push/pre-push 显式调用 | ⏳ | — | 避免 push 触发递归 |
| 用户指南.html 版本号刷新 | ⏳ | — | v2.18.0 |
| 用户手册.html 版本号刷新 | ⏳ | — | v2.18.0 |

## 4. 版本控制记录

| 项 | 内容 |
|:---|:-----|
| 分支策略 | Git Flow（.devflow/project-config.json 配置）|
| 提交约定 | `type(scope): subject` + footer 引用 RT-ID |
| RT-ID footer 约定 | `Refs: RT-218-XXX` |
| 建议提交拆分 | Phase 1（TD-218-001~003）→ feat(skill); Phase 2（TD-218-004~006）→ fix(hooks) + docs(user) |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-19 | 初始创建，6 TD-ID 映射 3 DT-ID（覆盖率 100%）| AD-DevFlow-Dev |
