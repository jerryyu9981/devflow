# DevFlow Phase 迭代计划 v2.9.2

> **文档类型**: Phase 迭代计划
> **版本**: v2.9.2
> **项目**: DevFlow
> **创建日期**: 2026-07-23
> **维护者**: PM-DevFlow-Dev

---

## Phase 概览

| Phase | 名称 | 需求 | 交付物 | 验收重点 |
|:-----:|:-----|:-----|:-------|:---------|
| Phase 1 | 配置一致性修复 | BL-292-001, BL-292-002 | 更新后的 version.json + config.json | devflow-init 检测 consistent |
| Phase 2 | 旧文件清理 | BL-292-003 | 备份文件 + 删除确认 | LS/Glob 验证文件不存在 + 备份存在 |
| Phase 3 | 门禁增强 | BL-292-004 | operations-stage-execution SKILL.md 更新 | 风险归集章节模板存在且含 4 必填项 |

---

## Phase 1: 配置一致性修复

| 项目 | 内容 |
|:-----|:------|
| 需求 | BL-292-001, BL-292-002 |
| 预估工时 | 0.75h |
| 前置条件 | Git for Windows 可用，devflow-config.json v2.9.1 已读取 |
| 交付物 | 更新后的 `version.json`（项目根）、更新后的 `.devflow/config.json` |
| 验收标准 | devflow-init 检测 versionCheck.result = "consistent" |
| 完成标志 | devflow-init 运行无版本不一致告警 |

---

## Phase 2: 旧文件清理

| 项目 | 内容 |
|:-----|:------|
| 需求 | BL-292-003 |
| 预估工时 | 0.5h |
| 前置条件 | Phase 1 完成 |
| 交付物 | `.devflow/backup/deprecated-version.json`、`.devflow/backup/deprecated-devflow-manifest.json` |
| 验收标准 | 1. 备份文件存在; 2. 原路径文件不存在; 3. validate-install 不报 Fail |
| 完成标志 | `devflow-plugin/version.json` 和 `devflow-plugin/devflow-manifest.json` 已删除 |

---

## Phase 3: 门禁增强

| 项目 | 内容 |
|:-----|:------|
| 需求 | BL-292-004 |
| 预估工时 | 1h |
| 前置条件 | Phase 2 完成 |
| 交付物 | 更新后的 `operations-stage-execution/SKILL.md` |
| 验收标准 | 问题跟踪记录模板包含风险归集检查章节，含 4 个必填项 |
| 完成标志 | SKILL.md 中问题跟踪记录输出要求含"风险归集检查"章节 |

---

## 里程碑

| 里程碑 | 时间节点 | 通过标准 |
|:-------|:---------|:---------|
| M1: 配置一致 | Phase 1 完成 | devflow-init consistent |
| M2: 清理完成 | Phase 2 完成 | 旧文件已备份+删除 |
| M3: 门禁增强完成 | Phase 3 完成 | SKILL.md 更新 + TD-026 前置就绪 |
| M4: 版本发布 | Step 5 完成 | Git Tag v2.9.2 已推送 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-23 | v2.9.2 Phase 迭代计划 | PM-DevFlow-Dev |
