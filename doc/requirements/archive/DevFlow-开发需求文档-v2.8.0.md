# DevFlow 开发需求文档 v2.8.0

> **文档状态**: [Draft]  
> **版本**: 1.0.0  
> **项目**: DevFlow  
> **目标版本**: v2.8.0  
> **作者**: RA-DevFlow-Dev  
> **创建日期**: 2026-07-12

---

## 1. 项目概述

### 1.1 项目定位

v2.8.0 为功能增强版本，在 v2.7.5 架构修复基础上，进一步完善三阶段版本管理流程：修复 setup.ps1 首次安装复制逻辑、增强 devflow-init 项目初始化版本检测、新增云端下载脚本、填充仓库地址字段。

### 1.2 核心目标

1. **修复 setup.ps1 首次安装复制逻辑**：非 .md 文件保留原文件名
2. **devflow-init 版本差异检测**：比较 TRAE 版本与项目记录版本
3. **新增云端下载脚本**：从云端仓库下载 DevFlow 到本地副本
4. **填充仓库地址字段**：version.json 支持云端仓库地址

### 1.3 需求优先级

| 优先级 | 定义 | 本版本数量 |
|:------:|------|:---------:|
| 🔴 P0 | 必须完成，blocking | 2 项 |
| 🟡 P1 | 应该完成，高优先级 | 1 项 |
| 🟢 P2 | 可以完成，低优先级 | 1 项 |

---

## 2. 核心功能需求

### 2.1 V260-037：修复 setup.ps1 复制逻辑（已修复）

**用户故事**：作为首次安装用户，我希望 setup.ps1 将 `version.json` 和 `sync-skills.ps1` 以原文件名复制到 TRAE 系统目录，而非错误地存为 `SKILL.md`。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-12 | 运行 setup.ps1 后，TRAE 目录下 `devflow-plugin-config/version.json` 和 `devflow-plugin-sync/sync-skills.ps1` 文件名正确 | 文件存在性检查 |

**功能点**：

| 功能 | 描述 |
|------|------|
| 扩展名判断 | 在复制前判断源文件扩展名：.md → `SKILL.md`，非 .md → 保留原文件名 |
| 兼容性 | 不改变已有 .md 技能文件的安装行为 |

**状态**：✅ **已在 v2.8.0 启动时完成修复**

### 2.2 V260-036-07：devflow-init 版本差异检测增强

**用户故事**：作为 DevFlow 用户，当我在不同项目间切换时，我希望 devflow-init 能自动检测 TRAE 系统目录的 DevFlow 版本与项目记录的版本是否一致，差异时及时提示我。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-09 | 运行 devflow-init 后 state.json 中包含 versionCheck 字段 | 文件内容检查 |

**功能点**：

| 功能 | 描述 |
|------|------|
| 读取 TRAE 版本 | 从 `~/.trae-cn/skills/devflow-plugin-config/version.json` 读取 `devflowVersion` |
| 读取项目版本 | 从 `.devflow/state.json` 读取 `devflowVersion` |
| 版本比较 | 语义化版本比较（major.minor.patch 逐段比较数字） |
| 差异处理 | 版本一致→跳过；TRAE 更新→自动更新项目记录并提示；项目更新→提示用户决策 |
| 结果记录 | 将检测结果写入 state.json 的 versionCheck 字段 |

### 2.3 V260-036-01：新增 download-devflow.ps1 脚本

**用户故事**：作为 DevFlow 用户，我希望有一个专用脚本可以从云端仓库下载最新 DevFlow 到本地副本，无需手动执行 git 命令。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-13 | 运行 download-devflow.ps1 的三种模式（Clone/Update/SetRepo）均能正常运行 | 手动测试 |

**功能点**：

| 功能 | 描述 |
|------|------|
| Clone 模式 | 首次克隆：从云端仓库克隆到本地副本 |
| Update 模式 | 拉取更新：git pull 获取最新代码 |
| SetRepo 模式 | 设置仓库地址：交互式设置 version.json.repository |
| 地址读取 | 从 version.json.repository 读取仓库地址 |
| 首次引导 | 仓库地址为空时自动进入 SetRepo 模式 |

### 2.4 V260-036-08：填充 version.json 仓库地址字段

**用户故事**：作为 DevFlow 管理员，我希望 version.json 的 repository 和 homepage 字段可设置，以支持 download-devflow.ps1 读取云端仓库地址。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-14 | 通过 download-devflow.ps1 -Action SetRepo 可设置 repository 和 homepage 字段 | 手动测试 |

**功能点**：

| 功能 | 描述 |
|------|------|
| repository 字段 | 设置云端仓库地址（https 格式） |
| homepage 字段 | 设置项目主页 |
| bugs 字段 | 设置问题反馈地址 |

---

## 3. 非功能需求

| 需求 | 指标 | 验证方式 |
|------|------|---------|
| 向后兼容 | setup.ps1 修改不改变现有 .md 技能安装行为 | 30 个技能全部安装正常 |
| 降级处理 | versionCheck 文件不存在时跳过检测，不报错 | 手动测试 |
| 版本比较 | 支持语义化版本比较 | 测试用例覆盖各种比较场景 |