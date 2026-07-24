# DevFlow 单版本规划文档 v2.7.4

> 文档类型：单版本规划文档
> 文档状态：[Draft]
> 版本：v1.0.0
> 日期：2026-07-12
> 项目名称：DevFlow
> 当前版本：2.7.4

---

## 1. 版本目标

### 1.1 业务目标
消除 DevFlow 配置文件中 `version` 字段的语义歧义，所有版本字段明确区分为 `devflowVersion`（DevFlow 插件版本）和 `projectVersion`（项目版本），避免字段混淆导致的运维事故。

### 1.2 用户目标
用户在任何文件中看到 `devflowVersion` 能立即知道这是 DevFlow 插件版本号；看到 `projectVersion` 能立即知道这是项目自身的迭代版本号。

### 1.3 成功指标
- 所有涉及版本字段的 JSON 文件和数据模板中不再出现无前缀的 `version` 字段
- `update.ps1/sh` 不再将 `projectVersion` 误读为 DevFlow 版本号

---

## 2. 版本范围

### 2.1 包含范围

| 类别 | 内容 |
|------|------|
| **数据文件重命名** | `devflow-plugin/version.json`: `version` → `devflowVersion` |
| | 项目根 `version.json`: `version` → `devflowVersion` |
| | `.devflow/state.json`: `version` → `devflowVersion` |
| | 删除 `.devflow/version.json`（遗留旧版备份 v2.4.1） |
| **脚本字段读取修正** | `setup.ps1` 第 14 行: `$versionInfo.version` → `$versionInfo.devflowVersion` |
| | `setup.sh` 第 11 行: 同字段名修正 |
| | `sync-skills.ps1` 第 40 行: `$verInfo.version` → `$verInfo.devflowVersion` |
| | `update.ps1` 第 44-49 行: `$CurrentVersion` 来源从 `config.json.projectVersion` 改为 `state.json.devflowVersion` |
| | `update.ps1` 第 60 行: `$localVer.version` → `$localVer.devflowVersion` |
| | `update.sh` 第 39 行: 读取来源改为 `state.json.devflowVersion` |
| | `update.sh` 第 47 行: `(open(...))['version']` → `['devflowVersion']` |
| **技能模板修正** | `devflow-init/SKILL.md` 所有 `version` 字段引用（共 6 处） |
| | `devflow-phase-manager/SKILL.md` 模板字段（共 1 处） |
| | `devflow-project-config/SKILL.md` 版本说明（共 1 处） |

### 2.2 不包含范围

| 不包含 | 原因 |
|--------|------|
| `config.json.projectVersion` 字段名修改 | v2.7.2 已改为 `projectVersion`，命名正确无需修改 |
| 其他 L1/L2/L3 技能文件内容修改 | 超出本次命名规范化范围 |
| 代码逻辑变更（除字段名读取外） | 本次为纯命名修正 |
| 文档目录中旧版 `.md` 文件中的版本字段（如 `doc/version/global/` 中的历史文档） | 历史文档只读，不修改 |

---

## 3. 版本依赖清单

| 依赖项 | 类型 | 状态 |
|--------|------|------|
| 无外部依赖 | — | ✅ 无需依赖 |

## 4. 版本风险清单

| 风险 | 级别 | 缓解措施 |
|------|------|---------|
| 字段名修改后旧脚本与新字段不兼容 | P1 | 同步修改所有引用处；devflow-init 有降级规则处理旧字段不存在的情况 |
| 其他项目引用旧字段名 | P1 | 仅影响 DevFlow 自身配置，不涉及用户项目业务代码 |

## 5. 高层验收目标

1. 所有 JSON 数据文件中无歧义 `version` 字段
2. `update.ps1` 执行后不再出现语义错配

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| v1.0.0 | 2026-07-12 | 初始创建 | DevFlow 维护团队 |