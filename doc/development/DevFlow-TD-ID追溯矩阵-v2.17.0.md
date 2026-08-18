# DevFlow TD-ID 追溯矩阵 — v2.17.0

> 文档类型：TD-ID 追溯矩阵（设计开发追溯矩阵）
> 版本：v2.17.0
> 状态：[Draft]
> 日期：2026-08-18
> 作者：AD-DevFlow-Dev（开发工程师）

---

## 1. 追溯矩阵

| TD-ID | DT-ID | RT-ID | 开发任务 | 涉及文件 | 完成状态 | 验证证据 |
|:-----:|:-----:|:-----:|:---------|:---------|:--------:|:---------|
| TD-217-001 | DT-217-001 | RT-217-001 | 新增"原型设计 IN/OUT 衔接规范"章节（3 场景导入协议 + OUT 移交 + 交互状态模板）| devflow-plugin/skills/L2/design-stage-execution.md | ✅ 完成 | 章节存在（L292-329）|
| TD-217-002 | DT-217-001 | RT-217-001 | 新增 Figma 链接类原型编码对照方式 | devflow-plugin/skills/L2/coding-stage-execution.md | ✅ 完成 | 小节存在（L354）|
| TD-217-003 | DT-217-001 | RT-217-001 | E2E 用例引用原型状态断言基线 | devflow-plugin/skills/L2/testing-stage-execution.md | ✅ 完成 | 小节存在（4.5 前）|
| TD-217-004 | DT-217-002 | RT-217-002 | T3a 标记修正（工作流图/步骤表/通过标准/L4 断言/定义 5 处）| devflow-plugin/skills/L2/testing-stage-execution.md | ✅ 完成 | Grep 5 处均验证 |
| TD-217-005 | DT-217-003 | RT-217-003 | prototype/index.html 标记统一（L140/L146/L254 3 处）| devflow-plugin/skills/L2/design-stage-execution.md | ✅ 完成 | Grep 3 处均验证 |
| TD-217-006 | DT-217-004 | RT-217-004 | 网络层巡检自动化演进预研报告 | doc/analysis/DevFlow-网络层巡检自动化演进-预研报告-v1.0.md | ✅ 完成 | 文件存在，结论✅可行 |
| TD-217-007 | DT-217-005 | RT-217-005 | 测试计划/用例/报告模板网络层巡检纳入（3 处）| devflow-plugin/skills/L3/project-document-templates.md | ✅ 完成 | Grep 3 处均验证 |
| TD-217-008 | DT-217-006 | RT-217-006 | 原型设计说明章节模板新增（5 项最小内容）| devflow-plugin/skills/L3/project-document-templates.md | ✅ 完成 | 模板存在（L519）|

## 2. 覆盖统计

| 统计项 | 数值 |
|--------|:----:|
| 设计项总数（DT-ID）| 6 |
| 有开发任务对应（TD-ID）| 6 |
| 开发任务总数 | 8 |
| 开发设计对比覆盖率 | 8/8 = 100%（目标 ≥95%）✅ |
| 未完成项 | 0 |

## 3. Subtask CheckList（子任务状态表）

| 设计规划的文件操作 | 实际完成 | 命名一致 | 说明 |
|:-------------------|:--------:|:--------:|:-----|
| design-stage-execution.md 新增章节 | ✅ | ✅ | "原型设计 IN/OUT 衔接规范（v2.17.0+）" |
| design-stage-execution.md 标记修正 3 处 | ✅ | ✅ | L140/L146/L254 |
| coding-stage-execution.md 新增小节 | ✅ | ✅ | "Figma 链接类原型编码对照方式" |
| testing-stage-execution.md 标记修正 5 处 | ✅ | ✅ | L890/L931/L477/L173/L308 |
| testing-stage-execution.md 新增小节 | ✅ | ✅ | "E2E 原型状态断言基线" |
| project-document-templates.md 新增模板 2 处 | ✅ | ✅ | 原型设计说明 + 测试用例模板 |
| project-document-templates.md 模板增强 2 处 | ✅ | ✅ | 测试计划 + 测试报告 |
| doc/analysis/ 预研报告 | ✅ | ✅ | DevFlow-网络层巡检自动化演进-预研报告-v1.0.md |

## 4. 版本控制记录

| 项 | 内容 |
|:---|:-----|
| 分支策略 | Git Flow（.devflow/project-config.json 配置）|
| 提交约定 | `type(scope): subject` + footer 引用 RT-ID |
| RT-ID footer 约定 | `Refs: RT-217-XXX` |
| 建议提交拆分 | TD-217-004/005（Phase 1 标记修正）→ feat(skill); TD-217-001/002/003/008（Phase 2 衔接规范）→ feat(skill); TD-217-006/007（Phase 3）→ docs(test) |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-18 | 初始创建，8 TD-ID 全覆盖，开发设计对比覆盖率 100% | AD-DevFlow-Dev |
