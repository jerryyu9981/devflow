# DevFlow 需求基线及设计移交说明 v2.9.0

> **文档类型**: 需求基线及设计移交说明
> **版本**: v2.9.0
> **项目**: DevFlow
> **日期**: 2026-07-21

---

## 1. 需求基线

### 1.1 基线版本

| 基线项 | 值 |
|--------|-----|
| 基线版本号 | v2.9.0-baseline-1 |
| 需求文档版本 | 1.0.0 |
| 建立日期 | 2026-07-21 |
| 基线范围 | 7 项需求（R-01~R-07）|

### 1.2 基线变更规则

| 规则 | 说明 |
|:----|:------|
| 变更触发 | Step 2 及之后发现需求遗漏或调整 |
| 变更流程 | (1) 更新需求源文档 → (2) 更新追溯矩阵 → (3) 记录范围变更总记录 → (4) 通知下游 |
| 变更记录 | 写入 `doc/version/global/DevFlow-版本范围变更总记录.md` |
| 审批要求 | 新增需求需 PM 批准，延续 Step 0 变更流程 |

---

## 2. 设计移交材料

### 2.1 移交清单

| 编号 | 移交物 | 路径 |
|:----:|:-------|:-----|
| 1 | 开发需求文档 | `doc/requirements/DevFlow-开发需求文档-v2.9.0.md` |
| 2 | 需求来源与干系人 | `doc/requirements/DevFlow-需求来源与干系人-v2.9.0.md` |
| 3 | 需求追溯矩阵 | `doc/requirements/DevFlow-需求追溯矩阵-v2.9.0.md` |
| 4 | 需求评审记录 | `doc/requirements/DevFlow-需求评审记录-v2.9.0.md` |
| 5 | 需求评估报告 | `doc/audit/assessment/DevFlow-需求评估报告-v2.9.0.md` |
| 6 | 本版本 Backlog | `doc/version/releases/v2.9.0/DevFlow-本版本Backlog-v2.9.0.md` |
| 7 | 单版本规划文档 | `doc/version/releases/v2.9.0/DevFlow-单版本规划文档-v2.9.0.md` |
| 8 | Phase 迭代计划 | `doc/version/releases/v2.9.0/DevFlow-Phase迭代计划-v2.9.0.md` |

### 2.2 移交需求基线

| 需求 ID | 需求名称 | 优先级 | 涉及技能文件 | 实现说明 |
|:-------:|---------|:------:|-------------|---------|
| R-01 | 还债配额机制 | P0 | `version-planning-stage-execution.md` | 0.0a 阶段新增还债配额检查规则和门禁 |
| R-02 | 跨版本债务流转 | P0 | `version-planning-stage-execution.md` | 0.0a 阶段完善债务老化升级和流转规则 |
| R-03 | 测试覆盖率门禁 | P1 | `testing-stage-execution.md` | Step 4 门禁检查新增覆盖率门禁规则 |
| R-04 | 端到端集成验证 | P1 | `testing-stage-execution.md` | Step 4 新增 E2E 集成验证规则 |
| R-05 | Step 0 来源规范化 | P1 | `version-planning-stage-execution.md` | 0.0 阶段新增 6 来源检查清单 |
| R-06 | version.json 字段补全 | P1 | `devflow-init` SKILL.md | devflow-init 启动时补全仓库地址字段 |
| R-07 | devflow-init 版本差异 | P1 | `devflow-init` SKILL.md | devflow-init 新增版本差异检测流程 |

### 2.3 移交材料清单

| 交付物 | 说明 |
|--------|------|
| 开发需求文档 | 13 章完整需求定义 |
| 需求来源与干系人 | 入场检查 + 来源 + 角色 |
| 需求追溯矩阵 | 7 条 RT-ID，100% 可追溯 |
| 需求评审记录 | 完整性/一致性/可设计性/可测试性/范围合规性全部通过 |

### 2.4 风险提示

| 风险 | 说明 |
|:----|:------|
| 技能文件需跨 L2 层修改 | version-planning / testing / devflow-init 三份技能文件需修改 |
| 覆盖率和 E2E 流程有依赖性 | 需在 Step 2 设计时明确覆盖率工具和 E2E 场景定义方式 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-21 | 初始创建，v2.9.0 需求基线及设计移交 | PM-DevFlow-Dev |
