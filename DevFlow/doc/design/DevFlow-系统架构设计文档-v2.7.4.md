# DevFlow 系统架构设计文档 v2.7.4

> 文档类型：系统架构设计文档（版本设计）
> 文档状态：[Draft]
> 版本：v1.0.0
> 日期：2026-07-12
> 项目名称：DevFlow
> 当前版本：2.7.4

---

## 1. 设计入场检查

| 检查项 | 结果 |
|--------|:----:|
| Step 0 版本规划已批准 | ✅ |
| Step 1 需求文档已批准 | ✅ |
| 需求追溯矩阵齐备 | ✅ |
| 验收标准清单已确认 | ✅ |

## 2. 激活轨道

| 轨道 | 状态 | 原因 |
|:----:|:----:|------|
| 🎯 整体 | ✅ 始终激活 | 必须 |
| ⚙️ 后端 | ✅ 始终激活 | 脚本和配置文件修改 |
| 🎨 前端 | ❌ 未激活 | 本次不涉及前端代码 |
| 🔗 第三方集成 | ❌ 未激活 | 无外部依赖变更 |

## 3. 设计范围

本次 v2.7.4 纯属字段命名规范化，不涉及系统架构变更。涉及的文件均为 JSON 数据文件、PowerShell/Bash 脚本和 SKILL.md 技能模板。

### 3.1 需求-设计追溯

| DT-ID | 关联 RT-ID | 设计项描述 | 涉及文件 |
|:-----:|:----------:|:-----------|:---------|
| DT-001 | RT-001 | JSON 数据文件 `version` → `devflowVersion` 字段重命名 | `devflow-plugin/version.json`、`DevFlow/version.json`、`.devflow/state.json` |
| DT-002 | RT-001 | 删除旧版备份遗留文件 `.devflow/version.json` | `.devflow/version.json` |
| DT-003 | RT-002 | 同步更新脚本中的字段读取 | `setup.ps1`、`setup.sh`、`sync-skills.ps1` |
| DT-004 | RT-003 | 修复 update 脚本中 `$CurrentVersion` 的读取来源语义 | `update.ps1`、`update.sh` |
| DT-005 | RT-004 | 同步更新技能模板中的字段引用 | `devflow-init/SKILL.md`、`devflow-phase-manager/SKILL.md`、`devflow-project-config/SKILL.md` |

> **覆盖率**：5 个 DT-ID 覆盖全部 4 个 RT-ID，覆盖率 **100%**。

## 4. 设计规范

### 4.1 字段命名规范

| 字段名 | 含义 | 使用位置 |
|--------|------|---------|
| `devflowVersion` | DevFlow 插件自身版本号 | `devflow-plugin/version.json`、项目根 `version.json`、`.devflow/state.json` |
| `projectVersion` | 项目自身的开发迭代版本号 | `.devflow/config.json`（已正确，本次不修改） |

### 4.2 update 语义设计

```text
update 执行流程（修正后）：
  $CurrentVersion = state.json.devflowVersion       ← 项目当前使用的 DevFlow 版本
  $LatestVersion  = devflow-plugin/version.json.devflowVersion  ← 插件源最新版本
  if ($CurrentVersion -eq $LatestVersion) { exit 0 }  ← 已最新
  执行技能同步...                                       ← 版本不一致时更新
```

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| v1.0.0 | 2026-07-12 | 初始创建 | DevFlow 维护团队 |