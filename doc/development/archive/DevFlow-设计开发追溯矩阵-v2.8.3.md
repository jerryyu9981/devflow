# DevFlow 设计开发追溯矩阵 v2.8.3

> **文档状态**: [Draft]
> **版本**: 1.0.0
> **项目**: DevFlow
> **目标版本**: v2.8.3
> **创建日期**: 2026-07-18

---

## 追溯矩阵

| TD-ID | 关联 DT-ID | 关联 FR-ID | 实现描述 | 涉及文件 | 状态 |
|:-----:|:----------:|:----------:|---------|---------|:----:|
| TD-001 | DT-01 | FR-01 | 创建 devflow-manifest.json | `devflow-plugin/devflow-manifest.json` | 📋 |
| TD-002 | DT-02 | FR-02 | setup.ps1 改为从 manifest 加载 skillMap | `devflow-plugin/setup.ps1` | 📋 |
| TD-003 | DT-03 | FR-03 | setup.sh 两个分支改为从 manifest 加载 skillMap | `devflow-plugin/setup.sh` | 📋 |
| TD-004 | DT-02/04 | FR-02/04 | update.ps1 改为从 manifest 加载 skillMap | `devflow-plugin/update.ps1` | 📋 |
| TD-005 | DT-03/04 | FR-03/04 | update.sh 改为从 manifest 加载 skillMap | `devflow-plugin/update.sh` | 📋 |
| TD-006 | DT-02/04 | FR-02/04 | sync-skills.ps1 改为从 manifest 加载 skillMap | `devflow-plugin/sync-skills.ps1` | 📋 |
| TD-007 | DT-05 | FR-05 | download-devflow.ps1 增加 manifest 文件完整性校验 | `devflow-plugin/download-devflow.ps1` | 📋 |
| TD-008 | DT-06 | FR-06 | setup.ps1/sh 增加安装后数量校验 | `devflow-plugin/setup.ps1`, `devflow-plugin/setup.sh` | 📋 |
| TD-009 | DT-07 | FR-07 | devflow-init 增加 init 时技能数量一致性告警 | `devflow-plugin/devflow-init/SKILL.md` | 📋 |
| TD-010 | — | V260-052 | sync-skills.ps1 的 DevFlowSkills 改为 manifest 动态构建 | `devflow-plugin/sync-skills.ps1` | 📋 |

## 覆盖统计

| 维度 | 覆盖 |
|:----:|:----:|
| DT-ID → TD-ID | 7/7 DT → 10 TD（含 1 个 V260-052 独立项） |
| FR → TD | 7/7 FR 全部有对应 TD |
| TD → 涉及文件 | 10 TD 覆盖 9 个文件 |
