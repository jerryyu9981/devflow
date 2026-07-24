# DevFlow Release Note v2.9.2

> **发布日期**: 2026-07-23
> **版本**: v2.9.2
> **项目**: DevFlow

---

## 概述

v2.9.2 为配置一致性修复补丁版本，解决 v2.9.0 → v2.9.1 升级后遗留的配置文件版本号不一致问题，并清理已弃用文件、增强运维技能模板。

## 变更清单

### 配置一致性修复

| 变更 | 文件 | 需求ID |
|:-----|:-----|:------:|
| version.json version 2.8.5→2.9.2 | `version.json` | V292-001 |
| 补全 repository/homepage 字段 | `version.json` | V292-001 |
| devflow-config.json devflowVersion 2.9.1→2.9.2 | `devflow-plugin/devflow-config.json` | V292-001/002 |
| .devflow/config.json projectVersion 2.9.0→2.9.2 | `.devflow/config.json` | V292-002 |

### 弃用文件清理

| 操作 | 文件 | 备份位置 | 需求ID |
|:-----|:-----|:---------|:------:|
| 备份+删除 | `devflow-plugin/version.json` | `.devflow/backup/devflow-plugin_version.json.bak.20260723` | V292-003 |
| 备份+删除 | `devflow-plugin/devflow-manifest.json` | `.devflow/backup/devflow-plugin_devflow-manifest.json.bak.20260723` | V292-003 |

### 模板增强

| 变更 | 文件 | 需求ID |
|:-----|:-----|:------:|
| 问题跟踪记录新增"风险归集检查"必填章节 | `devflow-plugin/skills/L2/operations-stage-execution.md` | V292-004 |

## 修复问题

- 项目根 version.json（2.8.5）与 devflow-config.json 版本不一致（v2.9.1 遗留问题）
- devflow-plugin/ 下残留弃用配置文件（v2.9.1 Release Note 标记待处理）

## 已知问题

无。

## 向后兼容性

- 所有 API/Skill 接口保持兼容，无破坏性变更。
- 弃用文件备份至 `.devflow/backup/`，可随时恢复。

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-23 | v2.9.2 Release Note 初始创建 | PM-DevFlow-Release |
