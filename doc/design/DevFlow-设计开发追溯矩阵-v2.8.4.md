# DevFlow 设计开发追溯矩阵 v2.8.4

> **文档状态**: [Draft]
> **版本**: 1.0.0
> **项目**: DevFlow
> **目标版本**: v2.8.4
> **创建日期**: 2026-07-20

---

## 1. 追溯矩阵

| TD-ID | DT-ID | 关联需求 ID | 设计项 | 涉及文件 | 修改类型 | 优先级 |
|:-----:|:-----:|:----------:|--------|---------|:--------:|:------:|
| TD-284-01 | DT-03 | V284-003 | 全局技术债务总表 | doc/version/global/DevFlow-技术债务总表.md | 新建 | 🔴 P0 |
| TD-284-02 | DT-01 | V284-001 | 技术债务增长率门禁 | devflow-plugin/skills/L2/coding-stage-execution.md | 章节新增 | 🔴 P0 |
| TD-284-03 | DT-02 | V284-002 | 实际运行验证三层模型 | devflow-plugin/skills/L2/coding-stage-execution.md | 章节新增+顺延 | 🔴 P0 |
| TD-284-04 | DT-05 | V284-005 | 可维护性权重升级 | devflow-plugin/skills/L3/code-logic-review.md | 章节重排+否决条件 | 🟡 P1 |
| TD-284-05 | DT-07 | V284-007 | version-planning 债务引用 | devflow-plugin/skills/L2/version-planning-stage-execution.md | 内容补充 | 🟡 P1 |
| TD-284-06 | DT-04 | V284-004 | 证据真实性强化 | devflow-plugin/skills/L2/coding-stage-execution.md + DevLogReport 模板 | 章节新增 | 🟡 P1 |
| TD-284-07 | DT-06 | V284-006 | DevLogReport 债务章节 | DevLogReport 模板 | 章节新增 | 🟡 P1 |

**统计**：7 个 TD-ID 覆盖 7 个 DT-ID，覆盖 30/30 FR（100%）。

---

## 2. 实施顺序

| 顺序 | TD-ID | 任务 | 依赖 | 预估工作量 |
|:----:|:-----:|------|:----:|:---------:|
| 1 | TD-284-01 | 新建全局技术债务总表 | 无 | 小 |
| 2 | TD-284-02 | coding-stage 新增 3.4.1 债务增长率检查 | 无 | 小 |
| 3 | TD-284-03 | coding-stage 新增 3.5 实际运行验证 + 顺延后续章节 | TD-284-02 | 中 |
| 4 | TD-284-04 | code-logic-review 可维护性重排 + 否决条件 | 无 | 小 |
| 5 | TD-284-05 | version-planning 债务引用补充 | TD-284-01 | 小 |
| 6 | TD-284-06 | 证据真实性强化（DevLogReport 模板 + coding-stage） | TD-284-03 | 小 |
| 7 | TD-284-07 | DevLogReport 债务章节 | TD-284-01 | 小 |

---

## 3. 修改文件汇总

| 文件路径 | 修改类型 | 关联 TD-ID | 说明 |
|---------|:--------:|:----------:|------|
| doc/version/global/DevFlow-技术债务总表.md | 新建 | TD-284-01 | 全局债务台账 |
| devflow-plugin/skills/L2/coding-stage-execution.md | 修改 | TD-284-02, TD-284-03, TD-284-06 | 新增 3.4.1 + 3.5 章节，后续顺延 |
| devflow-plugin/skills/L3/code-logic-review.md | 修改 | TD-284-04 | 可维护性从 11→6 位，加否决条件 |
| devflow-plugin/skills/L2/version-planning-stage-execution.md | 修改 | TD-284-05 | 技术债务评估章节增加引用 |

**总计**：1 个新建 + 3 个修改 = 4 个文件（DevLogReport 模板位置待确认）

---

## 4. 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-20 | 初始创建，v2.8.4 质量保障基础版设计开发追溯 | DEV-DevFlow-Dev |
