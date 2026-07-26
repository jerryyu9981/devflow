# DevFlow Phase 迭代计划 — v2.12.0

> 文档类型：Phase 迭代计划
> 版本：v2.12.0
> 日期：2026-07-27

---

## Phase 划分

| Phase | 主题 | BL-ID | 工作量 | 里程碑 |
|:-----:|:-----|:-----:|:------:|:-------|
| Phase 1 | 文件结构一致性 + config.json 改名 | BL-212-001, BL-212-005 | 中 | Subtask CheckList + code-logic-review 第14维度补全；config.json→project-config.json 改名执行 |
| Phase 2 | 风险归集 + 性能基线 + 设计评审改进 | BL-212-002, BL-212-003, BL-212-006 | 中 | 6 个 L2 风险归集检查清单集成；性能基线模板 + 文档 |
| Phase 3 | 技能注册 + 全流程验证 | BL-212-004 | 中 | validate-registry.ps1 脚本 + 138 引用补全 + audit-agent 全流程审计 |

## Phase 依赖关系

```text
Phase 1（结构+改名）→ Phase 2（门禁+基线）→ Phase 3（注册+验证）
```

## 验收重点

| Phase | 验收项 |
|:-----:|:-------|
| Phase 1 | Subtask CheckList 增加命名对齐检查；code-logic-review 第14维度生效；`.devflow/config.json` 已重命名为 `project-config.json` |
| Phase 2 | 6 个 L2 技能均包含风险归集检查清单；性能基线模板存在 doc/performance/ |
| Phase 3 | validate-registry.ps1 运行零未注册引用；audit-agent 全流程审计通过 |

---
