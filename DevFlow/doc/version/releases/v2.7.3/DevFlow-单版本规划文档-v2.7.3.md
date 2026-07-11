# DevFlow-单版本规划文档-v2.7.3

> 文档类型：单版本规划文档（Patch）
> 文档状态：[Draft]
> 版本：v2.7.3（文档修订 v1.0）
> 日期：2026-07-11
> 所属版本：v2.7.3
> 负责人：DevFlow 维护团队

---

## 版本主题

Install/Update/Init 三组件职责边界清理

## 版本目标

v2.7.3 是修订版本（Patch），核心目标为**清理 Install/Update/Init 三组件的职责边界**：

1. **Install DevFlow（setup.ps1/sh）**：回归纯全局操作，剥离所有项目初始化逻辑
2. **Update DevFlow（update.ps1/sh）**：回归纯全局操作，移除越界修改项目配置的行为
3. **devflow-init（SKILL.md）**：补齐项目初始化职责——读取 DevFlow 版本号、自动扫描+交互获取 projectVersion、推断并写入 currentPhase

## 背景

通过深入分析发现，当前 Install/Update/Init 三组件存在严重的职责交叉问题：

- `setup.ps1` 将"全局技能安装"与"项目初始化"混在一起，既创建 `.devflow/` 又安装技能
- `update.ps1` 错误地将 DevFlow 插件版本号写入了本应是项目版本号的 `projectVersion` 字段
- `devflow-init` SKILL.md 的规则文本描述了从 version.json 读取版本号等行为，但实际 LLM 执行时缺乏可执行步骤

修正后的定位：
- **Install/Update**：纯全局操作，只操作 `~/.trae-cn/skills/`
- **devflow-init**：纯项目操作，从 TRAE 读版本、获取项目信息、写入项目配置

## Backlog

| ID | 需求描述 | 优先级 | 修改范围 |
|:--:|:---------|:------:|:---------|
| V260-030 | **Install DevFlow 职责清理**——`setup.ps1/sh` 移除项目初始化逻辑（项目名检测、`.devflow/` 创建、config.json/state.json 生成），仅保留全局技能安装至 `~/.trae-cn/skills/` 和可选 Git hook 安装 | P0 | `setup.ps1`、`setup.sh` |
| V260-031 | **Update DevFlow 修正**——`update.ps1/sh` 移除修改 `.devflow/config.json` 中 `projectVersion` 的逻辑，只做 TRAE 技能目录增量同步 | P0 | `update.ps1`、`update.sh` |
| V260-032 | **devflow-init 增强：DevFlow 版本号读取与写入**——从 `~/.trae-cn/skills/devflow-plugin-config/version.json` 读取 DevFlow 版本号；写入项目根目录 `version.json`；写入 `.devflow/state.json` 的 `version` 字段 | P0 | `devflow-init/SKILL.md` |
| V260-033 | **devflow-init 增强：projectVersion 自动扫描+交互补充**——按照优先级链自动检测项目版本号：① 已有 `.devflow/config.json.projectVersion`（非空）→ 保留 ② 最新 Git tag ③ `package.json` version ④ `pyproject.toml` version ⑤ 其他项目配置文件；以上均无法获取时交互询问用户输入 | P0 | `devflow-init/SKILL.md` |
| V260-034 | **devflow-init 增强：currentPhase 推断并写入 state.json**——完善文档扫描推断逻辑，实际将 `currentPhase` 写入 `.devflow/state.json` | P1 | `devflow-init/SKILL.md` |

## Phase 划分

本版本不拆分多 Phase，一次性完成全部 5 项需求。

| Phase | 需求 | 预计负载 |
|:-----:|:-----|:--------:|
| Phase 1 | V260-030 Install 清理 + V260-031 Update 修正 | 2 脚本文件 |
| Phase 2 | V260-032 devflow-init 版本号读写 + V260-033 projectVersion 自动扫描+交互 + V260-034 currentPhase 写入 | 1 SKILL.md 文件 |

## 版本依赖清单

| 依赖项 | 版本 | 说明 |
|:-------|:----:|:------|
| TRAE IDE | ≥1.0.0 | 技能文件需 TRAE 加载 |
| PowerShell 5.1+ | — | `sync-skills.ps1` 运行所需 |
| bash | — | `setup.sh` 运行所需（Linux/Mac） |

## 版本风险清单

| 风险 | 概率 | 影响 | 缓解措施 |
|:-----|:----:|:----:|:---------|
| 移除 setup.ps1 项目初始化逻辑后，旧版 setup 用户仍可能看到未初始化配置 | 低 | 中 | devflow-init 会检测并覆盖写入 |
| update.ps1 不再更新 projectVersion 后，用户概念混淆 | 低 | 低 | 版本说明文档澄清 |

## 版本成功指标说明

| 指标 | 目标 | 验证方式 |
|:-----|:----:|:---------|
| setup.ps1 不再创建 .devflow/ | 通过 | 代码审查确认移除 |
| update.ps1 不再修改 projectVersion | 通过 | 代码审查确认移除 |
| devflow-init 可读取 TRAE 版本号 | 通过 | SKILL.md 规则确认 |
| devflow-init 写入 projectVersion（自动扫描或交互） | 通过 | SKILL.md 规则确认 |
| devflow-init 写入 currentPhase | 通过 | SKILL.md 规则确认 |

## 技术债务清单

| 债务项 | 说明 | 目标处理版本 |
|:-------|:-----|:------------:|
| — | 无新增技术债务 | — |