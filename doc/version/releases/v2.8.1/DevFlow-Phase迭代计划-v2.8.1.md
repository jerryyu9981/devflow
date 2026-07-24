# DevFlow Phase 迭代计划 v2.8.1

> **文档状态**: [Draft]
> **版本**: 1.0.0
> **项目**: DevFlow
> **目标版本**: v2.8.1
> **作者**: PM-DevFlow-Dev
> **创建日期**: 2026-07-15

---

## Phase 划分

v2.8.1 按 3 个 Phase 迭代，按复杂度和依赖关系拆分。

### Phase 1：setup.ps1 交互确认 + update.ps1 硬编码修复（2 项需求）

> 两个都是脚本修改，逻辑简单，合并为一个 Phase 快速交付。

| 步骤 | 任务 | 涉及文件 | 预估工时 | 依赖 | 状态 |
|:----:|------|---------|:--------:|:----:|:----:|
| 1 | **setup.ps1 增加交互确认**（V260-045）：展示版本号+文件数+目标路径，用户 y/Y 确认后才执行 | `setup.ps1` | 20min | 无 | |
| 2 | **修复 update.ps1 SKILL.md 硬编码**（V260-038）：对非 .md 文件保留原文件名，参照 V260-037 方案 | `update.ps1` | 10min | 无 | |

**Phase 1 预估工时**：约 30 分钟

---

### Phase 2：download-devflow.ps1 版本比较 + 交互确认（1 项需求）

> 需要新增 git ls-remote 逻辑和版本比较逻辑，复杂度中等。

| 步骤 | 任务 | 涉及文件 | 预估工时 | 依赖 | 状态 |
|:----:|------|---------|:--------:|:----:|:----:|
| 1 | **download-devflow.ps1 增加版本比较+交互确认**（V260-044）：Clone/Update 前确认源/目的地址；git ls-remote --tags 获取远程版本 vs 本地版本比较；有更新才下载 | `download-devflow.ps1` | 45min | 无 | |

**Phase 2 预估工时**：约 45 分钟

---

### Phase 3：devflow-init 文件同步（1 项需求）

> 需要修改 SKILL.md 流程，增加从 TRAE 系统目录同步文件的逻辑，复杂度中等。

| 步骤 | 任务 | 涉及文件 | 预估工时 | 依赖 | 状态 |
|:----:|------|---------|:--------:|:----:|:----:|
| 1 | **devflow-init 版本更新时同步项目 devflow 文件**（V260-046）：installed_newer 时从 TRAE 系统目录同步文件到项目 .devflow/，保留用户自定义值 | `devflow-init/SKILL.md` | 30min | Phase 2 | |

**Phase 3 预估工时**：约 30 分钟

---

## 总体预估

| 项目 | 工时 |
|------|------|
| Phase 1 | 30min |
| Phase 2 | 45min |
| Phase 3 | 30min |
| **总计** | **约 1.75 小时** |

---

## Phase 里程碑

| 里程碑 | 条件 | 验收标准 |
|--------|------|---------|
| Phase 1 完成 | setup.ps1 交互确认 + update.ps1 修复 | AC-03: setup.ps1 展示版本号和文件数；AC-04: update.ps1 非 .md 文件保留原文件名 |
| Phase 2 完成 | download-devflow.ps1 版本比较+确认 | AC-01: 展示远程/本地版本，有更新才下载；AC-02: 展示源/目的地址供确认 |
| Phase 3 完成 | devflow-init 文件同步 | AC-05: installed_newer 时同步 TRAE 文件到项目 .devflow/ |
| 版本交付 | 技能同步到 TRAE 系统目录 | AC-06: 5 个脚本语法验证通过 |
