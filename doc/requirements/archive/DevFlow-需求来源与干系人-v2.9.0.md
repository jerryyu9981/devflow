# DevFlow 需求来源与干系人 v2.9.0

> **文档类型**: 需求来源与干系人分析
> **版本**: v2.9.0
> **项目**: DevFlow
> **日期**: 2026-07-21

---

## 1. 入场检查记录

### 1.1 Step 0 输入验证

| 检查项 | 输入文档 | 状态 | 说明 |
|--------|---------|:----:|------|
| 单版本规划文档 | `doc/version/releases/v2.9.0/DevFlow-单版本规划文档-v2.9.0.md` | ✅ | 9 章完整版，范围/目标/风险/依赖/债务清单齐全 |
| 本版本 Backlog | `doc/version/releases/v2.9.0/DevFlow-本版本Backlog-v2.9.0.md` | ✅ | 7 条 BL-ID，P0/P1 优先级明确 |
| Phase 迭代计划 | `doc/version/releases/v2.9.0/DevFlow-Phase迭代计划-v2.9.0.md` | ✅ | 2-Phase 拆分 + 风险/依赖/债务清单补充 |
| 版本规划评审记录 | `doc/version/releases/v2.9.0/DevFlow-版本规划评审记录-v2.9.0.md` | ✅ | 15 项评审全部通过，结论"批准" |
| 版本规划总纲 | `doc/version/global/DevFlow-版本规划总纲.md` | ✅ | 已创建（版本节奏/命名/治理原则） |
| 版本发布策略总则 | `doc/version/global/DevFlow-版本发布策略总则.md` | ✅ | 已创建（发布节奏/Tag/回滚/验证） |
| state.json 批准状态 | `.devflow/state.json` | ✅ | currentPhase 为 step_0_planning，审计通过 |

**结论**：Step 0 输入齐备，可进入 Step 1 需求细化。

### 1.2 范围合规确认

| 检查项 | 结果 |
|--------|:----:|
| 是否扩大 Step 0 批准范围 | ❌ 否 — 严格按 7 项需求细化（R-01~R-07） |
| P0 项是否全部有对应 BL | ✅ BL-290-001 对应 R-01，BL-290-002 对应 R-02 |
| 新增需求是否触发范围变更 | ❌ 不涉及 |

---

## 2. 需求来源清单

| 来源编号 | 来源类别 | 来源描述 | 对应需求 | 优先级 | 提出者 |
|:--------:|---------|---------|:-------:|:------:|--------|
| SRC-01 | 技术债务 | TD-006：缺少还债配额机制，跨 3 版本未处理 | R-01 | P0 | PM-DevFlow-Dev |
| SRC-02 | 技术债务 | TD-007：缺少跨版本债务流转机制，债务易遗忘 | R-02 | P0 | PM-DevFlow-Dev |
| SRC-03 | 技术债务 | TD-008：缺少测试覆盖率门禁，边界条件无保障 | R-03 | P1 | PM-DevFlow-Dev |
| SRC-04 | 技术债务 | TD-009：缺少端到端集成验证，多模块协同问题难发现 | R-04 | P1 | PM-DevFlow-Dev |
| SRC-05 | 用户反馈 | Step 0 需求收集缺少规范化来源检查清单，可能遗漏重要需求 | R-05 | P1 | 用户 |
| SRC-06 | 技术债务 | TD-013：version.json repository/homepage 字段为空（P2→P1 老化升级） | R-06 | P1 | PM-DevFlow-Dev |
| SRC-07 | 候选需求池 | V260-036-07：devflow-init 版本差异检测增强 | R-07 | P1 | 候选需求池 |

---

## 3. 干系人与用户角色表

| 角色 | 姓名/角色名 | 职责 | 参与阶段 | 审批权限 |
|------|-----------|------|---------|---------|
| 版本负责人 | PM-DevFlow-Dev | 统筹版本规划、需求、设计、开发、测试、发布全流程 | Step 0~5 | Step 0 审批、Step 1 审批 |
| 用户 | 最终用户 | 使用 DevFlow 框架进行项目开发，提供反馈 | 持续 | Step 0 规划审批 |
| 需求分析人 | PM-DevFlow-Dev | 细化需求、编写需求文档、建立追溯矩阵 | Step 1 | Step 1 产出 |
| 设计师 | PM-DevFlow-Dev | 技能文件规范设计、流程设计 | Step 2 | Step 2 |
| 开发者 | PM-DevFlow-Dev | 技能文件修改、version.json 字段填充 | Step 3 | Step 3 |
| 测试者 | PM-DevFlow-Dev | 测试用例编写、执行和验证 | Step 4 | Step 4 |
| 发布经理 | PM-DevFlow-Dev | 发布执行、版本交付 | Step 5 | Step 5 |
| 审计师 | PM-DevFlow-Dev | 需求评估审计、全流程审计 | Step 1.9, Step 5 | 审计报告 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-21 | 初始创建，v2.9.0 需求来源与干系人 | PM-DevFlow-Dev |
