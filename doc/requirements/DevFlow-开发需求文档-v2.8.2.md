# DevFlow 开发需求文档 v2.8.2

> **文档状态**: [Draft]
> **版本**: 1.0.0
> **项目**: DevFlow
> **目标版本**: v2.8.2
> **作者**: RA-DevFlow-Dev
> **创建日期**: 2026-07-18

---

## 1. 项目概述

### 1.1 项目定位

v2.8.2 为安装流程修复 + 健壮性增强版本，围绕"安装流程三步走对齐"主题，修复 install.ps1 与 download-devflow.ps1 的功能重复、补齐首次安装引导缺失、修复 UTF-8 BOM 导致技能无法加载的 P0 故障，并提升 IDE 目录配置的灵活性。

### 1.2 核心目标

1. **install.ps1 下载步骤对齐**：消除约 100 行内联 git clone 逻辑，统一调用 download-devflow.ps1
2. **首次安装仓库引导**：repository 为空时自动引导用户设置，支持 `-TargetDir` 参数
3. **BOM 自动去除**：安装/更新/同步后自动检测并去除 UTF-8 BOM，防止技能无法加载
4. **IDE 目录可配置化**：通过 `DEVFLOW_SKILLS_DIR` 环境变量支持非标准 TRAE 安装路径

### 1.3 需求优先级

| 优先级 | 定义 | 本版本数量 |
|:------:|------|:---------:|
| 🔴 P0 | 必须完成，blocking | 3 项 |
| 🟡 P1 | 应该完成，高优先级 | 1 项 |

---

## 2. 入场检查

| 检查项 | 状态 | 证据 |
|--------|:----:|------|
| 单版本规划文档已批准 | ✅ | `doc/version/releases/v2.8.2/DevFlow-单版本规划文档-v2.8.2.md`，评审结论 Approved |
| 本版本 Backlog 已形成 | ✅ | 4 项需求（V260-047/048/049/050），P0×3 + P1×1 |
| Phase 迭代计划已确认 | ✅ | 3 个 Phase，预估 2.3h |
| P0 项 100% 有 Backlog 条目 | ✅ | V260-047/048/050 均已映射 |

---

## 3. 核心功能需求

### 3.1 V260-047：install.ps1 下载步骤对齐 download-devflow.ps1

**用户故事**：作为 DevFlow 安装用户，我希望 install.ps1 的下载步骤直接调用 download-devflow.ps1 而非内联一套简化的 git clone 逻辑，以便下载行为与独立使用 download-devflow.ps1 时一致（版本比较、语义版本排序等），且减少重复代码的维护负担。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-01 | install.ps1 的 Step 1 调用 `download-devflow.ps1 -Action Clone -TargetDir $PluginDir`，不再内联 git clone 逻辑 | 代码审查：install.ps1 中无 `git clone` / `git ls-remote` 调用 |
| AC-01b | install.bat 正确传递参数给 install.ps1 | 代码审查 |

**功能点**：

| 功能点 | 描述 |
|--------|------|
| 删除内联逻辑 | 删除 install.ps1 第 65-212 行的内联 git clone 逻辑（约 100 行） |
| 调用 download-devflow.ps1 | Step 1 改为：检测 `.git` 目录（已下载则跳过）→ 调用 `& download-devflow.ps1 -Action Clone -TargetDir $PluginDir` |
| 保留 .devflow 自检 | 保留第 48-63 行的 `.devflow` 目录安全检测逻辑 |
| 保留错误处理 | 下载失败时提示并继续 Step 2（使用本地文件） |
| install.bat 同步 | install.bat 确保 PowerShell 调用路径正确 |

**业务规则**：

| 规则 ID | 规则描述 |
|:-------:|---------|
| BR-01 | 若插件根目录已存在 `.git` 子目录，跳过下载步骤，提示"已下载，请使用 update-devflow.bat 更新" |
| BR-02 | download-devflow.ps1 调用失败时，不中断安装流程，提示"使用本地文件"后继续 Step 2 |
| BR-03 | install.ps1 的 `$ErrorActionPreference` 保持 `"Continue"`（非 `"Stop"`），确保下载失败不中断 |

---

### 3.2 V260-048：install.ps1 首次安装时引导设置下载仓库地址

**用户故事**：作为首次安装 DevFlow 的用户，当 `version.json.repository` 为空时，我希望 install.ps1 能自动引导我设置仓库 URL，设置完成后继续 Clone 流程，而不是直接跳过下载步骤。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-02 | `version.json.repository` 为空时，install.ps1 自动调用 `download-devflow.ps1 -Action SetRepo` 引导用户输入仓库 URL | 手动测试：清空 repository 字段后运行 install.ps1 |
| AC-03 | install.ps1 支持 `-TargetDir` 参数，允许用户指定本地副本下载目录 | 手动测试：`.\install.ps1 -TargetDir D:\MyDevFlow` |

**功能点**：

| 功能点 | 描述 |
|--------|------|
| repository 空值检测 | Step 1 读取 `version.json.repository`，为空时进入引导流程 |
| 调用 SetRepo | 调用 `& download-devflow.ps1 -Action SetRepo`，由 download-devflow.ps1 的 SetRepo 模式完成 URL 输入和写入 |
| SetRepo 后继续 Clone | SetRepo 完成后自动继续 `download-devflow.ps1 -Action Clone -TargetDir $PluginDir` |
| `-TargetDir` 参数 | install.ps1 新增 `param([string]$TargetDir = "")` ，传递给 download-devflow.ps1 的 `-TargetDir` |
| install.bat 同步 | install.bat 支持传递 TargetDir 参数：`powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1" -TargetDir "%~1"` |

**业务规则**：

| 规则 ID | 规则描述 |
|:-------:|---------|
| BR-04 | `-TargetDir` 默认值为空，空值时使用 `$PSScriptRoot`（install.ps1 所在目录） |
| BR-05 | SetRepo 引导失败（用户取消）时，不中断安装流程，使用本地文件继续 |
| BR-06 | download-devflow.ps1 的 `-TargetDir` 参数优先级高于 `$PSScriptRoot` |

---

### 3.3 V260-050：安装后自动去除 SKILL.md 的 UTF-8 BOM 头

**用户故事**：作为 DevFlow 维护者，我希望 setup/update/sync 脚本在安装技能文件后自动检测并去除 UTF-8 BOM，防止 TRAE 的 Write 工具在编辑过程中引入的 BOM 导致技能无法被 TRAE 扫描器识别。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-04 | setup.ps1/sh 安装完成后，所有已安装的 `.md` 文件首三字节不为 `EF BB BF` | 手动测试：安装后用 hex dump 检查 .md 文件首字节 |
| AC-04b | update.ps1/sh 更新完成后，所有已更新的 `.md` 文件无 UTF-8 BOM | 手动测试 |
| AC-04c | sync-skills.ps1 同步完成后，所有已同步的 `.md` 文件无 UTF-8 BOM | 手动测试 |

**功能点**：

| 功能点 | 描述 |
|--------|------|
| BOM 检测函数 | 读取文件首 3 字节，判断是否为 `EF BB BF`（UTF-8 BOM） |
| BOM 去除函数 | 用 `[UTF8Encoding]::new($false)`（PowerShell）或 `sed`/`printf`（Bash）重写文件，去除 BOM |
| 安装后批量处理 | 文件复制完成后，遍历所有已安装的 `.md` 文件执行 BOM 检测 + 去除 |
| 日志输出 | 检测到 BOM 时输出 `[BOM Fixed]` 提示，无 BOM 时静默 |

**业务规则**：

| 规则 ID | 规则描述 |
|:-------:|---------|
| BR-07 | BOM 检测仅针对 UTF-8 BOM（`EF BB BF`），不处理 UTF-16 BOM 或其他编码 |
| BR-08 | BOM 去除在文件复制完成后、安装统计输出前执行 |
| BR-09 | 非 `.md` 文件不执行 BOM 检测（version.json、.ps1、.sh 等不受影响） |

**涉及文件**：`setup.ps1`、`setup.sh`、`update.ps1`、`update.sh`、`sync-skills.ps1`

---

### 3.4 V260-049：IDE 系统目录可配置化

**用户故事**：作为使用非标准 TRAE 安装路径的用户，我希望能通过 `DEVFLOW_SKILLS_DIR` 环境变量指定技能安装目录，而不必修改脚本源码。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-05 | 设置 `DEVFLOW_SKILLS_DIR` 环境变量后，setup.ps1 将技能安装到该变量指定的目录 | 手动测试：`$env:DEVFLOW_SKILLS_DIR = "D:\CustomSkills"; .\setup.ps1` |
| AC-05b | 未设置 `DEVFLOW_SKILLS_DIR` 时，行为与 v2.8.1 一致（使用 `$env:USERPROFILE\.trae-cn\skills`） | 手动测试 |

**功能点**：

| 功能点 | 描述 |
|--------|------|
| 环境变量读取 | 优先读取 `$env:DEVFLOW_SKILLS_DIR`（PowerShell）/ `$DEVFLOW_SKILLS_DIR`（Bash） |
| 硬编码回退 | 环境变量未设置时，使用 `$env:USERPROFILE\.trae-cn\skills`（PowerShell）/ `$HOME/.trae-cn/skills`（Bash） |
| 安装确认展示 | 在安装确认步骤中展示实际使用的目录路径 |
| 目录存在性检查 | 若目标目录不存在则自动创建 |

**业务规则**：

| 规则 ID | 规则描述 |
|:-------:|---------|
| BR-10 | `DEVFLOW_SKILLS_DIR` 为空字符串时视为未设置，回退到硬编码路径 |
| BR-11 | 目标目录不存在时自动创建，不报错 |

**涉及文件**：`setup.ps1`、`setup.sh`、`update.ps1`、`update.sh`、`sync-skills.ps1`

---

## 4. 非功能需求

### 4.1 兼容性

| 需求 | 指标 |
|------|------|
| 向后兼容 | 未设置 `DEVFLOW_SKILLS_DIR` 时，行为与 v2.8.1 完全一致 |
| PowerShell 兼容 | 支持 PowerShell 5.1+（Windows 内置） |
| Bash 兼容 | 支持 Bash 4.0+（Linux/macOS） |

### 4.2 可维护性

| 需求 | 指标 |
|------|------|
| 代码净减少 | install.ps1 净减少约 80 行（删除内联逻辑） |
| BOM 处理可复用 | BOM 检测 + 去除封装为独立函数，5 个脚本复用 |

### 4.3 可靠性

| 需求 | 指标 |
|------|------|
| 下载失败不中断 | download-devflow.ps1 调用失败时，install.ps1 继续使用本地文件 |
| BOM 去除不损坏文件 | 仅处理 UTF-8 BOM，其他编码文件不受影响 |

---

## 5. 不适用项说明

| 需求类别 | 不适用原因 |
|---------|-----------|
| 数据需求 | 本版本不涉及数据库或数据模型变更 |
| 权限与安全需求 | 本版本不涉及用户认证、授权或敏感数据操作 |
| UI/UX 需求 | 本版本仅修改命令行脚本，不涉及图形界面 |
| 接口与集成需求 | 本版本不涉及 API 接口或外部系统集成 |

---

## 6. 约束与排除项

### 6.1 约束

| 约束 | 说明 |
|------|------|
| 不修改 SKILL.md 内容 | 本版本仅修改安装/更新/同步脚本，不改变任何技能的业务逻辑 |
| 不修改 download-devflow.ps1 核心逻辑 | V260-047/048 仅调用现有接口，不改变 download-devflow.ps1 内部实现 |
| BOM 去除仅限 UTF-8 | 不处理 UTF-16 BOM（`FF FE` / `FE FF`）或其他编码 |

### 6.2 排除项

| 排除项 | 原因 |
|--------|------|
| V260-039~043（全自动循环架构） | 目标 v2.9.0，需预研 |
| V260-001~005（Agent 协作/自动化审计等） | 需预研，已明确延后 |
| 其他编码的 BOM 处理 | 复杂度高且无实际需求 |
| setup.sh 的 BOM 去除在 Windows 上的测试 | Windows 无原生 Bash，仅验证逻辑正确性 |

---

## 7. 验收标准汇总

| 编号 | 对应需求 | 验收项 | 验证方法 |
|:----:|---------|--------|---------|
| AC-01 | V260-047 | install.ps1 Step 1 调用 download-devflow.ps1，无内联 git clone | 代码审查 |
| AC-01b | V260-047 | install.bat 正确传递参数 | 代码审查 |
| AC-02 | V260-048 | repository 为空时自动引导 SetRepo 交互 | 手动测试 |
| AC-03 | V260-048 | 支持 -TargetDir 参数 | 手动测试 |
| AC-04 | V260-050 | setup.ps1/sh 安装后 .md 文件无 UTF-8 BOM | 手动测试 + hex dump |
| AC-04b | V260-050 | update.ps1/sh 更新后 .md 文件无 UTF-8 BOM | 手动测试 |
| AC-04c | V260-050 | sync-skills.ps1 同步后 .md 文件无 UTF-8 BOM | 手动测试 |
| AC-05 | V260-049 | DEVFLOW_SKILLS_DIR 环境变量生效 | 手动测试 |
| AC-05b | V260-049 | 未设置时回退到硬编码路径 | 手动测试 |
| AC-06 | 全部 | 全部修改脚本语法验证通过 | 语法检查工具 |

---

## 8. 需求优先级表

| 需求 ID | 优先级 | 理由 |
|:--------:|:------:|------|
| V260-047 | 🔴 P0 | 架构对齐，消除 ~100 行重复代码，降低维护成本 |
| V260-048 | 🔴 P0 | 首次安装体验，补齐三步走流程的关键缺失环节 |
| V260-050 | 🔴 P0 | 已验证的实际故障（v2.7.3~v2.8.1 中 3 个 orchestrator 技能无法加载） |
| V260-049 | 🟡 P1 | 增强兼容性，但默认路径已覆盖大多数场景 |

---

## 9. 范围变更记录

| 日期 | 变更类型 | 变更内容 | 影响范围 | 审批人 |
|------|---------|---------|---------|--------|
| 2026-07-18 | 初始创建 | 基于 Step 0 Backlog 细化需求 | 4 项需求 | RA-DevFlow-Dev |