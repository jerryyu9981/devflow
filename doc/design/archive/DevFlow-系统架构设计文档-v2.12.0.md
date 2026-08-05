# DevFlow 系统架构设计文档 — v2.12.0

> 文档类型：系统架构设计文档（版本设计）
> 版本：v2.12.0
> 日期：2026-07-27

---

## 1. 系统边界

| 维度 | 内容 |
|:-----|:------|
| **系统** | DevFlow 工程规范框架 |
| **本版本变更** | 6 项技能文档规则增强 + 1 个脚本 + 1 个文件重命名 |
| **影响范围** | 不影响现有 6 阶段流程；变更集中在 `devflow-plugin/skills/` 技能文档层和 `.devflow/` 配置文件 |

## 2. 模块架构

本版本不引入新模块，只对现有模块做规则增强。

```text
变更模块清单：
┌─ devflow-plugin/skills/L2/ ──────────────────────┐
│  coding-stage-execution.md      ← TD-027 命名门禁 │
│  design-stage-execution.md      ← 6 处模板追加    │
│  operations-stage-execution.md  ← 风险归集检查   │
│  testing-stage-execution.md     ← 风险归集检查   │
│  requirements-stage-execution.md ← 风险归集检查  │
│  version-planning-stage-execution.md ← 风险归集  │
└──────────────────────────────────────────────────┘
┌─ devflow-plugin/skills/L3/ ──────────────────────┐
│  code-logic-review.md          ← TD-027 第14维度 │
│  audit-agent.md                 ← 不修改         │
└──────────────────────────────────────────────────┘
┌─ devflow-plugin/ ─────────────────────────────────┐
│  devflow-config.json     ← TD-025 补全注册引用    │
│  validate-registry.ps1   ← TD-025 新增脚本        │
│  templates/D-设计评审记录.md ← IMP-001 新增维度   │
└──────────────────────────────────────────────────┘
┌─ .devflow/ ───────────────────────────────────────┐
│  config.json → project-config.json   ← TD-029 改名│
└──────────────────────────────────────────────────┘
```

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-07-27 | 初始创建 | PM-DevFlow-Dev |
