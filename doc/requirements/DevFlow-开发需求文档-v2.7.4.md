# DevFlow 开发需求文档 v2.7.4

> 文档类型：开发需求文档
> 文档状态：[Draft]
> 版本：v1.0.0
> 日期：2026-07-12
> 项目名称：DevFlow
> 当前版本：2.7.4
> 关联需求：V260-035

---

## 1. 需求入场检查

| 检查项 | 结果 |
|--------|:----:|
| Step 0 版本规划已批准 | ✅ |
| 单版本规划文档已产出 | ✅ |
| 本版本 Backlog 已形成 | ✅ |
| Phase 计划已确认 | ✅ |
| 版本规划评审已通过 | ✅ |
| 关键干系人已明确 | ✅ |

---

## 2. 业务目标

消除 DevFlow 配置文件中 `version` 字段的语义歧义，所有版本字段明确区分为：
- **`devflowVersion`** — DevFlow 插件自身版本号
- **`projectVersion`** — 项目自身的开发迭代版本号

并修复 `update.ps1/sh` 将 `config.json.projectVersion`（项目版本）误读为 DevFlow 版本号的语义错误。

## 3. 功能需求

### FR-035-1：version 字段重命名

**描述**：将以下 JSON 数据文件中的 `version` 字段重命名为 `devflowVersion`：

| 文件 | 当前字段 | 修改后 |
|------|---------|--------|
| `devflow-plugin/version.json` | `"version": "2.7.3"` | `"devflowVersion": "2.7.3"` |
| 项目根 `version.json` | `"version": "2.7.3"` | `"devflowVersion": "2.7.3"` |
| `.devflow/state.json` | `"version": "2.7.3"` | `"devflowVersion": "2.7.3"` |
| `.devflow/version.json`（遗留） | — | **删除** |

### FR-035-2：脚本字段读取同步

**描述**：同步更新以下脚本中的字段读取：

| 文件 | 行 | 当前 | 修改后 |
|------|:--:|------|--------|
| `setup.ps1` | 14 | `$versionInfo.version` | `$versionInfo.devflowVersion` |
| `setup.sh` | 11 | `json.load(...)['version']` | `json.load(...)['devflowVersion']` |
| `sync-skills.ps1` | 40 | `$verInfo.version` | `$verInfo.devflowVersion` |

### FR-035-3：update 语义修复

**描述**：修复 `update.ps1` 和 `update.sh` 中 `$CurrentVersion` 的来源语义错误：

| 文件 | 当前（错误） | 修改后（正确） |
|------|-------------|---------------|
| `update.ps1` L44-49 | `$config.projectVersion`（项目版本）当作"Current DevFlow version" | 读取 `state.json.deflowVersion`（项目使用的 DevFlow 版本） |
| `update.sh` L39 | `json.load(...)['projectVersion']` 同上 | 同上 |

### FR-035-4：技能模板同步

**描述**：更新以下 SKILL.md 中引用的 `version` 字段：

| 文件 | 修改数量 | 说明 |
|------|:--------:|------|
| `devflow-init/SKILL.md` | 6 处 | 读取说明、JSON 模板、state.json 模板中的字段名 |
| `devflow-phase-manager/SKILL.md` | 1 处 | state.json 示例模板中的字段名 |
| `devflow-project-config/SKILL.md` | 1 处 | 版本说明中的字段引用 |

---

## 4. 验收标准

| AC ID | 验收内容 | 验证方法 |
|:-----:|:---------|:---------|
| AC-035-1 | `devflow-plugin/version.json` 中字段为 `devflowVersion` | 文件内容检查 |
| AC-035-2 | 项目根 `version.json` 中字段为 `devflowVersion` | 文件内容检查 |
| AC-035-3 | `.devflow/state.json` 中字段为 `devflowVersion` | 文件内容检查 |
| AC-035-4 | `.devflow/version.json` 遗留文件已删除 | 文件不存在检查 |
| AC-035-5 | `setup.ps1`、`setup.sh`、`sync-skills.ps1` 中读取 `devflowVersion` 字段 | 代码行确认 |
| AC-035-6 | `update.ps1` 中 `$CurrentVersion` 读取 `state.json.devflowVersion` | 代码行确认 |
| AC-035-7 | `update.sh` 中 `$CurrentVersion` 读取 `state.json.devflowVersion` | 代码行确认 |
| AC-035-8 | `update.ps1` 中 `$LatestVersion` 仍读取 `devflow-plugin/version.json.devflowVersion` | 代码行确认 |
| AC-035-9 | `devflow-init/SKILL.md` 中所有 6 处 `version` → `devflowVersion` 已更新 | 全文搜索确认 |
| AC-035-10 | `devflow-phase-manager/SKILL.md` 中 state.json 模板字段已更新 | 全文搜索确认 |
| AC-035-11 | `devflow-project-config/SKILL.md` 版本说明引用已更新 | 全文搜索确认 |

---

## 5. 约束和排除项

| 约束/排除 | 说明 |
|-----------|------|
| 不修改 `config.json.projectVersion` 字段名 | v2.7.2 已改为正确命名 |
| 不修改 L1/L2/L3 技能文件内容 | 超出本次命名规范化范围 |
| 历史文档中的版本字段不修改 | 只读归档 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| v1.0.0 | 2026-07-12 | 初始创建 | DevFlow 维护团队 |