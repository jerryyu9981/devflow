# DevFlow 设计开发追溯矩阵 v2.8.5

> **文档类型**: 设计开发追溯矩阵
> **版本**: v2.8.5
> **项目**: DevFlow
> **日期**: 2026-07-20
> **编码阶段创建**

---

## 追溯矩阵

| TD-ID | 设计项 | 涉及文件 | 修改类型 | 对应需求 | 操作说明 |
|:-----:|:------:|---------|:--------:|:-------:|---------|
| TD-285-001 | 风险归集门禁 | `devflow-plugin/skills/L2/coding-stage-execution.md` | 增量修改 | R-01 | 在"完成标准"前插入风险归集门禁模板文本（规则 1~6），规则 6：修改后的债务总表列入阶段产出 |
| TD-285-002 | 风险归集门禁 | `devflow-plugin/skills/L2/testing-stage-execution.md` | 增量修改 | R-01 | 在"阶段移交"前插入风险归集门禁模板文本（规则 1~6），规则 6：修改后的债务总表列入阶段产出 |
| TD-285-003 | 风险归集门禁 | `devflow-plugin/skills/L2/design-stage-execution.md` | 增量修改 | R-01 | 在"设计移交"前插入风险归集门禁模板文本（规则 1~6），规则 6：修改后的债务总表列入阶段产出 |
| TD-285-004 | 风险归集门禁 + Release Checklist + Release Note | `devflow-plugin/skills/L2/operations-stage-execution.md` | 增量修改 | R-01,R-02,R-05 | 在发布流程中插入风险归集门禁（规则 1~6）+ Release Checklist + Release Note 必出声明 |
| TD-285-005 | 0.0a 债务审查节点 | `devflow-plugin/skills/L2/version-planning-stage-execution.md` | 增量修改 | R-01 | 步骤序列增加 0.0a 节点，新增子步骤定义表（产出含更新后的债务总表）|
| TD-285-006 | 一致性审计维度 | `devflow-plugin/skills/L3/code-logic-review.md` | 增量修改 | R-04 | 新增"技能间委托关系一致性审查"章节 |
| TD-285-007 | Release Note 模板 | `devflow-plugin/skills/L3/project-document-templates.md` | 增量修改 | R-02 | 新增 Release Note 模板章节 |
| TD-285-008 | release.ps1 脚本 | `devflow-plugin/release.ps1` | 新建 | R-06 | 新建 PowerShell 发布脚本 |
| TD-285-009 | devflow-init 交互输入 | `devflow-plugin/devflow-init` | 增量修改 | R-03 | 增加远程仓库地址交互输入逻辑 |

---

## 覆盖率统计

| 统计项 | 结果 |
|--------|:----:|
| 总设计项数 | 9 |
| 全部编码实现 | 9/9 |
| 覆盖率 | 100% ✅ |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-20 | 初始创建 | PM-DevFlow-Dev |
