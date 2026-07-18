# DevFlow 本版本 Backlog v2.7.4

> 文档类型：本版本 Backlog
> 文档状态：[Draft]
> 版本：v1.0.0
> 日期：2026-07-12
> 项目名称：DevFlow
> 当前版本：2.7.4

---

| ID | 需求描述 | 优先级 | 验收标准 | 目标文件 |
|:--:|:---------|:------:|:---------|:---------|
| V260-035 | **所有 version 字段统一命名规范化**——消除 `version` 字段歧义：`devflow-plugin/version.json` 的 `version` → `devflowVersion`、项目根 `version.json` 的 `version` → `devflowVersion`、`.devflow/state.json` 的 `version` → `devflowVersion`；同步更新所有技能模板中的字段引用（devflow-init、devflow-phase-manager、devflow-project-config）；删除 `.devflow/version.json` 旧版备份遗留文件；同步更新 setup.ps1/sh、sync-skills.ps1、update.ps1/sh 中的字段读取。**修复 update.ps1/sh 语义错误**：`$CurrentVersion` 来源从 `config.json.projectVersion`（项目版本）改为读取 `state.json.devflowVersion`（项目使用的 DevFlow 版本），与 `$LatestVersion`（来自 `devflow-plugin/version.json.devflowVersion`，插件源版本）形成正确的"已安装 vs 最新"比较。 | 🔴 P0 | AC-035-1~7 | 见详细文件清单 |

---

## 验收标准明细

| AC ID | 验收标准 | 验证方法 |
|:-----:|:---------|:---------|
| AC-035-1 | `devflow-plugin/version.json` 中字段为 `devflowVersion` 而非 `version` | 文件内容检查 |
| AC-035-2 | 项目根 `version.json` 中字段为 `devflowVersion` | 文件内容检查 |
| AC-035-3 | `.devflow/state.json` 中字段为 `devflowVersion` | 文件内容检查 |
| AC-035-4 | `setup.ps1`、`setup.sh`、`sync-skills.ps1` 中读取 `devflowVersion` 字段 | 代码行确认 |
| AC-035-5 | `update.ps1` 中 `$CurrentVersion` 读取 `state.json.devflowVersion` 而非 `config.json.projectVersion` | 代码行确认 |
| AC-035-6 | `update.sh` 中 `$CurrentVersion` 读取 `state.json.devflowVersion` 而非 `config.json.projectVersion` | 代码行确认 |
| AC-035-7 | `devflow-init`、`devflow-phase-manager`、`devflow-project-config` 三个 SKILL.md 中所有模板和引用已同步更新 | 全文搜索确认 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| v1.0.0 | 2026-07-12 | 初始创建 | DevFlow 维护团队 |