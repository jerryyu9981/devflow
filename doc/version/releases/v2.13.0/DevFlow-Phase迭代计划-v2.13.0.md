# DevFlow Phase 迭代计划 — v2.13.0

> 文档类型：Phase 迭代计划
> 版本：v2.13.0
> 日期：2026-07-27

---

## Phase 划分

| Phase | 主题 | BL-ID | 工作量 | 里程碑 |
|:-----:|:-----|:-----:|:------:|:-------|
| Phase 1 | 产出物清单 + 命名核查 | BL-213-001, BL-213-002 | 中 | 6 阶段产出清单创建 + validate-naming 规则集 |
| Phase 2 | 用户文档 + Release Note + 路线图 | BL-213-003, BL-213-004, BL-213-005 | 小 | 用户指南模板 + 双文件对齐 + 路线图门禁 |
| Phase 3 | release.ps1 改进 | BL-213-006 | 小 | master 分支推送 + 三远程同步 |

## Phase 依赖关系

```text
Phase 1（清单+命名）→ Phase 2（文档+门禁）→ Phase 3（发布脚本）
```

## 验收重点

| Phase | 验收项 |
|:-----:|:-------|
| Phase 1 | audit-agent 输出包含"清单核对通过率"；validate-naming 规则脚本运行零违规 |
| Phase 2 | 存在用户指南模板；devflow-plugin/templates/ 包含 Release-Note-All 模板；Release Checklist 含路线图 |
| Phase 3 | release.ps1 执行后 master 分支推送到三远程 |

---
