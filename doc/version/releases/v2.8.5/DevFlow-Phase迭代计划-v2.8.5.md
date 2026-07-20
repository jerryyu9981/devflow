# DevFlow Phase 迭代计划 v2.8.5

> **文档类型**: Phase 迭代计划
> **版本**: v2.8.5
> **项目**: DevFlow
> **规划日期**: 2026-07-20

---

## 3-Phase 迭代计划

### Phase 1：体系规范完善（核心）

| 项 | 内容 |
|:----|------|
| **目标** | 建立债务生命周期管理规范（P0）：风险归集流入 + 跨版本接续流出双向闭环 + Release Note/Changelog 机制 |
| **BL-ID 范围** | BL-285-001 ~ BL-285-002 |
| **涉及技能文件** | `coding-stage-execution.md`, `testing-stage-execution.md`, `design-stage-execution.md`, `operations-stage-execution.md`, `version-planning-stage-execution.md`（新增 0.0a 债务审查节点）, `project-document-templates.md` |
| **涉及文档** | 全局债务总表、各阶段技能修改、Release Note / Changelog 模板 |
| **交付物** | 方向一流入：各阶段风险归集 → 写入总表；方向二流出：Step 0.0a 债务审查 → 老化升级 → 写入Backlog；Release Note 模板 + Changelog 汇总页 |
| **验证方式** | 模拟走查验证（1）各阶段风险归集全链路打通（2）Step 0 启动时债务审查自动触发 |
| **里程碑** | ✅ 债务生命周期闭环（流入+流出）+ 用户可见发布说明机制就绪 |

### Phase 2：配置缺口修复

| 项 | 内容 |
|:----|------|
| **目标** | 修复 devflow-init 远程仓库配置缺口 + 建立跨技能一致性审计 |
| **BL-ID 范围** | BL-285-003 ~ BL-285-004 |
| **涉及技能文件** | `devflow-init`（内联或独立代码）, `code-logic-review.md`, `design-stage-execution.md`（或其审计逻辑） |
| **涉及文档** | 修复后的 devflow-init 交互流程说明 |
| **交付物** | devflow-init 远程仓库交互配置 + 一致性审计维度 |
| **验证方式** | 执行 devflow-init 验证交互提示 + 审查技能间委托关系 |
| **里程碑** | ✅ 配置缺口修复 + 审计机制就位 |

### Phase 3：发布自动化

| 项 | 内容 |
|:----|------|
| **目标** | 标准化发布流程 + 脚本化 + 门禁化 |
| **BL-ID 范围** | BL-285-005 ~ BL-285-008 |
| **涉及技能文件** | `operations-stage-execution.md`, `code-version-backup-management.md`（引用） |
| **涉及文档** | release.ps1 脚本、发布检查清单模板 |
| **交付物** | Release Checklist 固化到 operations-stage-execution + release.ps1 脚本 |
| **验证方式** | 模拟发布走查 + release.ps1 执行测试 |
| **里程碑** | ✅ 发布自动化 + 季度审计就绪 |

---

## Phase 依赖关系

```text
Phase 1 体系规范完善
    ↓ 风险归集规范 + Release Note 模板是 Phase 2/3 的基础
Phase 2 配置缺口修复
    ↓ 技能审计是独立流程，与 Phase 3 无依赖
Phase 3 发布自动化
    ↑ 依赖 Phase 1 的 Release Note 模板（Changelog）
```

---

## 里程碑检查点

| 检查点 | Phase | 通过标准 | 交付物 |
|:------:|:----:|---------|--------|
| M-1 债务生命周期 | Ph1 | 各阶段技能已增加风险归集步骤 + version-planning 已增加 0.0a 债务审查节点 | 修改后的技能文件 |
| M-2 发布说明 | Ph1 | Release Note + Changelog 模板已定义 | project-document-templates.md 修改 |
| M-3 配置交互 | Ph2 | devflow-init 有交互确认流程 | 修改后的 devflow-init 流程 |
| M-4 技能审计 | Ph2 | code-logic-review 增加一致性维度 | code-logic-review.md 修改 |
| M-5 发布清单 | Ph3 | Release Checklist 在 operations-stage-execution 中 | operations-stage-execution.md 修改 |
| M-6 发布脚本 | Ph3 | release.ps1 可执行 | release.ps1 文件 |
| M-7 CI/CD 门禁 | Ph3 | 发布校验规则已定义 | operations-stage-execution.md 修改 |
| M-8 季度审计 | Ph3 | 季度版本审计流程已定义 | 审计流程文档 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-20 | 初始创建，v2.8.5 3-Phase 迭代计划 | PM-DevFlow-Dev |
