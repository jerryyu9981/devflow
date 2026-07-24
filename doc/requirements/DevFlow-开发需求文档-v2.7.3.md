# DevFlow-开发需求文档-v2.7.3

> 文档类型：开发需求文档
> 文档状态：[Draft]
> 版本：v1.0
> 日期：2026-07-11
> 所属版本：v2.7.3
> 负责人：DevFlow 维护团队

---

## 1. 版本概述

| 项目 | 内容 |
|:-----|:------|
| 版本 | v2.7.3（修订版本 Patch） |
| 版本主题 | Install/Update/Init 三组件职责边界清理 |
| 前提 | Step 0 版本规划已批准 |
| 范围 | 不扩大 Step 0 已批准的范围 |

## 2. 需求入场检查

| 检查项 | 状态 | 说明 |
|:-------|:----:|:------|
| Step 0 版本规划已批准 | ✅ | 用户已批准 |
| Backlog 齐备 | ✅ | V260-030~034 共 5 项 |
| Phase 计划明确 | ✅ | Phase 1（脚本清理）+ Phase 2（devflow-init 增强）|
| 版本风险已识别 | ✅ | 2 个低风险项 |
| 版本成功指标明确 | ✅ | 5 项可验证指标 |

## 3. 需求来源与干系人

### 3.1 需求来源

| 来源 | 说明 |
|:-----|:------|
| 代码审计 | 发现 OpenRAG 等已有项目显示版本号 2.6.1，根源为三组件职责交叉 |
| 职责分析 | Install/Update/Init 三组件实际行为与应有定位不符 |
| 用户讨论 | 逐项澄清各组件的全局 vs 项目操作边界 |

### 3.2 干系人与角色

| 角色 | 职责 |
|:-----|:------|
| 需求分析师（RA） | 编写需求文档、追溯矩阵、评审记录 |
| 审计师（AU） | 需求评估审计 |
| 用户 | 需求评审批准 |

## 4. 功能需求

### V260-030：Install DevFlow 职责清理

**用户故事**：
> 作为 DevFlow 维护者，我希望 `setup.ps1` 和 `setup.sh` 只做全局技能安装，不做项目初始化，这样项目和 TRAE 全局的职责边界清晰，避免项目根目录被意外污染。

**功能需求**：

| 需求项 | 详细描述 |
|:-------|:---------|
| FR-030-1 | `setup.ps1` 移除第 49-62 行项目名检测逻辑 |
| FR-030-2 | `setup.ps1` 移除第 66-68 行 `.devflow/` 目录创建 |
| FR-030-3 | `setup.ps1` 移除第 71-126 行 `config.json` 生成逻辑（含交互式仓库地址设置） |
| FR-030-4 | `setup.ps1` 移除第 130-140 行 `state.json` 生成逻辑 |
| FR-030-5 | `setup.ps1` 保留第 143-207 行 TRAE 技能安装逻辑 |
| FR-030-6 | `setup.ps1` 保留第 210-253 行可选 Git hook 安装逻辑 |
| FR-030-7 | `setup.sh` 执行同等逻辑剥离 |

**验收标准**：

| 验收项 | 验证方式 |
|:-------|:---------|
| AC-030-1 | setup.ps1 执行后不创建 `.devflow/` 目录 |
| AC-030-2 | setup.ps1 执行后不创建 `config.json` |
| AC-030-3 | setup.ps1 执行后不创建 `state.json` |
| AC-030-4 | setup.ps1 执行后 TRAE 技能目录 `~/.trae-cn/skills/` 下所有 DevFlow 技能文件正确安装 |
| AC-030-5 | setup.ps1 执行后 `devflow-plugin-config/version.json` 版本号正确 |

---

### V260-031：Update DevFlow 修正

**用户故事**：
> 作为 DevFlow 维护者，我希望 `update.ps1` 和 `update.sh` 只做 TRAE 技能同步，不修改项目的 `projectVersion`，因为 `projectVersion` 是项目自身的版本号，不应该被 DevFlow 升级自动覆盖。

**功能需求**：

| 需求项 | 详细描述 |
|:-------|:---------|
| FR-031-1 | `update.ps1` 移除第 193-199 行 `config.projectVersion = $LatestVersion` 写入逻辑 |
| FR-031-2 | `update.sh` 移除第 162-172 行 projectVersion 修改逻辑 |
| FR-031-3 | update 脚本仍保留全部技能同步到 `~/.trae-cn/skills/` 的功能 |

**验收标准**：

| 验收项 | 验证方式 |
|:-------|:---------|
| AC-031-1 | update.ps1 执行后 `.devflow/config.json` 的 `projectVersion` 保持不变 |
| AC-031-2 | update.ps1 执行后 TRAE 技能目录技能文件被正确更新 |
| AC-031-3 | update.sh 执行后同样不修改 projectVersion |

---

### V260-032：devflow-init DevFlow 版本号读取与写入

**用户故事**：
> 作为 DevFlow 用户，我希望新项目初始化时自动记录本项目使用的 DevFlow 版本号，这样项目根目录的 `version.json` 真实反映 DevFlow 版本，`state.json.version` 字段也有实际值，而不是留空。

**功能需求**：

| 需求项 | 详细描述 |
|:-------|:---------|
| FR-032-1 | devflow-init 从 `~/.trae-cn/skills/devflow-plugin-config/version.json` 读取 DevFlow 版本号 |
| FR-032-2 | 将读取到的版本号写入项目根目录下的 `version.json`（如 `{ "name": "DevFlow", "version": "2.7.3" }`） |
| FR-032-3 | 将读取到的版本号写入 `.devflow/state.json` 的 `version` 字段 |
| FR-032-4 | 更新 devflow-init SKILL.md 中的"版本来源规则"段落 |

**验收标准**：

| 验收项 | 验证方式 |
|:-------|:---------|
| AC-032-1 | devflow-init 执行后项目根目录生成 `version.json`，内容包含正确版本号 |
| AC-032-2 | `.devflow/state.json` 的 `version` 字段非空，值与 TRAE 技能目录版本号一致 |

---

### V260-033：devflow-init projectVersion 自动扫描+交互补充

**用户故事**：
> 作为 DevFlow 用户，我希望项目初始化时自动检测项目的版本号，而不是只能手动输入。如果已有配置或 Git tag 能反映版本，我就不需要再输入了。

**功能需求**：

| 需求项 | 详细描述 |
|:-------|:---------|
| FR-033-1 | 定义 projectVersion 检测优先级链：① `.devflow/config.json` 已有非空值 → 保留 ② 最新 Git tag（`git describe --tags --abbrev=0`）③ `package.json` version ④ `pyproject.toml` version ⑤ 其他项目配置文件 |
| FR-033-2 | 以上均无法获取时，交互询问用户输入项目自身版本号（如 `0.1.0`） |
| FR-033-3 | 将检测或输入的版本号写入 `.devflow/config.json` 的 `projectVersion` 字段 |

**验收标准**：

| 验收项 | 验证方式 |
|:-------|:---------|
| AC-033-1 | 已有 `.devflow/config.json.projectVersion` 且非空 → 保留原值 |
| AC-033-2 | 项目有 Git tag `v0.2.0` → 检测到 `0.2.0` |
| AC-033-3 | 项目有 `package.json` 含 `"version": "1.0.0"` → 检测到 `1.0.0` |
| AC-033-4 | 以上均无 → 询问用户输入 |

---

### V260-034：devflow-init currentPhase 推断并写入

**用户故事**：
> 作为 DevFlow 用户，我希望 devflow-init 不仅提示我当前在哪个阶段，还实际把这个阶段写入 `state.json`，这样后续 skill 可以直接从文件读取状态，不需要再重复推断。

**功能需求**：

| 需求项 | 详细描述 |
|:-------|:---------|
| FR-034-1 | 完善 devflow-init SKILL.md 中的文档扫描规则（检查 `doc/version/releases/`、`doc/requirements/`、`doc/design/`、`doc/development/`、`doc/test/`、`doc/operation/`）|
| FR-034-2 | 扫描后将推断的 `currentPhase` 实际写入 `.devflow/state.json` 的 `currentPhase` 字段 |
| FR-034-3 | 同步更新 `completedPhases` 字段（根据文档推断已完成的阶段列表） |

**验收标准**：

| 验收项 | 验证方式 |
|:-------|:---------|
| AC-034-1 | 项目已有 `doc/version/releases/` 文档而无其他 → `state.json.currentPhase = "step_0_planning"`，`completedPhases = []` |
| AC-034-2 | 项目已有 `doc/test/` 测试报告 → `state.json.currentPhase = "step_4_testing"` |
| AC-034-3 | 项目已有 `doc/operation/` 部署记录 → `state.json.currentPhase = "step_5_deployed"` |

## 5. 非功能需求

| 需求项 | 指标 | 验证方式 |
|:-------|:-----|:---------|
| 向后兼容 | devflow-init 增强后，不支持读取 version.json 的旧版项目不受影响 | 检测到无 TRAE 技能目录时降级 |
| 幂等性 | update.ps1 多次执行结果一致 | 重复执行无副作用 |

## 6. 范围边界与排除项

| 维度 | 内容 |
|:-----|:------|
| 本版本范围 | 仅 Install/Update/Init 三组件职责边界清理 |
| 排除项 | 不修改任何 L1/L2/L3 技能文件内容 |
| 排除项 | 不修改 sync-skills.ps1 |
| 排除项 | 不修改 devflow-phase-manager |
| 排除项 | 不修改 devflow-project-config |

## 7. 约束

| 约束 | 说明 |
|:-----|:------|
| 向后兼容 | setup.ps1 剥离项目初始化后，已有项目的 `.devflow/` 配置不受影响 |
| 文件完整性 | 剥离后的 setup.ps1 仍必须能独立完成 TRAE 技能安装 |

## 8. 优先级表

| ID | 需求 | 优先级 |
|:--:|:-----|:------:|
| V260-030 | Install DevFlow 职责清理 | 🔴 P0 |
| V260-031 | Update DevFlow 修正 | 🔴 P0 |
| V260-032 | devflow-init 版本号读取与写入 | 🔴 P0 |
| V260-033 | devflow-init projectVersion 自动扫描 | 🔴 P0 |
| V260-034 | devflow-init currentPhase 写入 | 🟡 P1 |