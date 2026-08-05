# DevFlow Agent 架构设计文档 — v2.12.0

> 文档类型：Agent 架构设计文档（版本设计）
> 版本：v2.12.0
> 日期：2026-07-27

---

## 1. Agent 角色

v2.12.0 不引入新 Agent 角色。审计职责继续由 `audit-agent` 承担。

## 2. 工作流

本版本的编码实现由主控 Agent 按 Phase 计划顺序执行，变更类型为技能文档规则增强：

| Phase | 变更类型 | 说明 |
|:-----:|:---------|:------|
| Phase 1 | 规则增强 + 文件重命名 | Subtask CheckList 命名对齐 + code-logic-review 第14维度 + config.json 改名 |
| Phase 2 | 模板追加 | 6 个 L2 风险归集检查清单 + 性能基线文档 + 设计评审模板增强 |
| Phase 3 | 脚本 + 配置 | validate-registry.ps1 + devflow-config.json 引用补全 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-07-27 | 初始创建 | PM-DevFlow-Dev |
