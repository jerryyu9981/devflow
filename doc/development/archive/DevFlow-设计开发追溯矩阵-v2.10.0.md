# DevFlow 设计开发追溯矩阵 v2.10.0

> **文档类型**: 设计开发追溯矩阵
> **版本**: v2.10.0
> **项目**: DevFlow
> **日期**: 2026-07-24

---

## 追溯矩阵

| TD-ID | 关联 DT-ID | 关联需求 | 设计项 | 涉及文件 | 操作 | 状态 |
|:-----:|:----------:|:--------:|:-------|:---------|:----:|:----:|
| TD-2100-001 | DT-2100-001 | V2100-001/TD-010 | 季度审计流程文档 | `doc/version/global/DevFlow-季度债务审计流程.md` | 新增 | 待开发 |
| TD-2100-002 | DT-2100-001 | V2100-001/TD-010 | 季度审计模板 | `doc/version/global/DevFlow-季度债务审计报告-v{季度}-v{年份}.md` | 新增 | 待开发 |
| TD-2100-003 | DT-2100-002 | V2100-002/TD-011 | 性能基线定义文档 | `doc/performance/DevFlow-性能基线-v{版本号}.md` | 新增 | 待开发 |
| TD-2100-004 | DT-2100-003 | V2100-003/TD-027 | Subtask CheckList 门禁 | `skills/L2/version-planning-stage-execution.md` §3.2 | 修改 | 待开发 |
| TD-2100-005 | DT-2100-003 | V2100-003/TD-027 | 命名一致性审查维度 | `skills/L3/code-logic-review.md` | 修改 | 待开发 |
| TD-2100-006 | DT-2100-003 | V2100-003/TD-027 | 全阶段盘点命名对齐 | `skills/L2/operations-stage-execution.md` | 修改 | 待开发 |
| TD-2100-007 | DT-2100-004 | TD-024 | 模板文件补全 9→24 | `devflow-plugin/templates/*.md`（15 份） | 新增 | 待开发 |
| TD-2100-008 | DT-2100-005 | TD-025 | 技能引用统一注册 | `devflow-plugin/devflow-config.json` | 修改 | 待开发 |
| TD-2100-009 | DT-2100-006 | TD-026 | 5 个 L2 风险归集章节 | `skills/L2/version-planning-stage-execution.md` | 修改 | 待开发 |
| TD-2100-010 | DT-2100-006 | TD-026 | 5 个 L2 风险归集章节 | `skills/L2/requirements-stage-execution.md` | 修改 | 待开发 |
| TD-2100-011 | DT-2100-006 | TD-026 | 5 个 L2 风险归集章节 | `skills/L2/design-stage-execution.md` | 修改 | 待开发 |
| TD-2100-012 | DT-2100-006 | TD-026 | 5 个 L2 风险归集章节 | `skills/L2/coding-stage-execution.md` | 修改 | 待开发 |
| TD-2100-013 | DT-2100-006 | TD-026 | 5 个 L2 风险归集章节 | `skills/L2/testing-stage-execution.md` | 修改 | 待开发 |
| TD-2100-014 | DT-2100-007 | V291-002 | sync 合并入 update | `devflow-plugin/scripts/update.ps1` | 修改 | 待开发 |
| TD-2100-015 | DT-2100-007 | V291-002 | 删除 sync-skills.ps1 | `devflow-plugin/scripts/sync-skills.ps1` | 删除 | 待开发 |

## 覆盖率

| 统计项 | 结果 |
|:-------|:----:|
| DT-ID → TD-ID 覆盖率 | 100%（7 DT → 15 TD）✅ |
| 需求 → TD 覆盖率 | 100%（7/7）✅ |
| 总设计项 | 15 |
| 新增文件 | 18 |
| 修改文件 | 8 |
| 删除文件 | 1 |

## 任务分解（按 Phase）

### Phase 1：流程门禁堵漏（7 项）

| 子任务 | TD-ID | 预计工时 |
|:-------|:-----:|:--------:|
| Subtask CheckList 章节追加 | TD-2100-004 | 0.5h |
| 命名一致性维度追加 | TD-2100-005 | 0.5h |
| 盘点命名对齐列追加 | TD-2100-006 | 0.25h |
| 5 个 L2 风险归集清单追加 | TD-2100-009~013 | 1h |

### Phase 2：脚本架构修复（2 项）

| 子任务 | TD-ID | 预计工时 |
|:-------|:-----:|:--------:|
| update.ps1 合并 sync 功能 | TD-2100-014 | 4h |
| 删除 sync-skills.ps1 | TD-2100-015 | 0.25h |

### Phase 3：基础设施完善（2 项）

| 子任务 | TD-ID | 预计工时 |
|:-------|:-----:|:--------:|
| 15 份模板文件 | TD-2100-007 | 8h |
| devflow-config.json 索引补全 | TD-2100-008 | 4h |

### Phase 4：长期机制建立（4 项）

| 子任务 | TD-ID | 预计工时 |
|:-------|:-----:|:--------:|
| 季度审计流程文档 | TD-2100-001 | 1h |
| 季度审计模板 | TD-2100-002 | 1h |
| 性能基线定义文档+首次数据 | TD-2100-003 | 3h |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| v1.0 | 2026-07-24 | 初始创建，15 项 TD-ID | PM-DevFlow-Dev |
