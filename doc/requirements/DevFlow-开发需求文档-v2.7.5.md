# DevFlow 开发需求文档 v2.7.5

> **文档状态**: [Draft]  
> **版本**: 1.0.0  
> **项目**: DevFlow  
> **目标版本**: v2.7.5  
> **作者**: RA-DevFlow-Dev  
> **创建日期**: 2026-07-12

---

## 1. 项目概述

### 1.1 项目定位

v2.7.5 是 v2.7.4 的架构修复版本，旨在修复 DevFlow 执行文件体系中的组件边界违规和技能映射遗漏问题。

### 1.2 核心目标

1. **消除 Install 组件边界违规**：install.ps1 移除项目目录操作，只做 TRAE 全局安装
2. **补齐 skillMap 遗漏项**：setup.ps1、update.ps1 补齐 devflow-plugin-config（version.json）和 devflow-plugin-sync（sync-skills.ps1）
3. **补齐 sync-skills.ps1 自身引用**：确保同步时自身也被更新
4. **修复硬编码版本号**：update-devflow.bat 标题版本号更新
5. **同步 Linux 客户端**：setup.sh / update.sh 同步补齐 skillMap

### 1.3 需求优先级

| 优先级 | 定义 | 本版本数量 |
|:------:|------|:---------:|
| 🔴 P0 | 必须完成，blocking | 3 项 |
| 🟡 P1 | 应该完成，高优先级 | 2 项 |
| 🟢 P2 | 可以完成，低优先级 | 1 项 |

### 1.4 核心概念定义

| 概念 | 定义 |
|------|------|
| **skillMap** | setup.ps1 / update.ps1 中定义的技能名称→源路径映射字典，决定哪些技能文件被复制到 TRAE 系统目录 |
| **$DevFlowSkills** | sync-skills.ps1 中定义的技能列表，包含所有需要同步的技能名称和源路径 |
| **组件边界** | Install（安装）、Update（更新）、Init（初始化）三个组件的职责划分边界，由 v2.7.3 确立 |

---

## 2. 核心功能需求

### 2.1 V260-036-02：修复 install.ps1 组件边界违规

**用户故事**：作为 DevFlow 维护者，我希望 install.ps1 只做 TRAE 全局安装，不涉及项目目录操作，以便遵从 Install/Init 组件边界。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-03 | 运行 install.ps1 不会在项目目录下创建任何文件 | 手动测试 + 目录检查 |

**功能点**：

| 功能 | 描述 |
|------|------|
| 字段名修正 | 将 `$verInfo.version` 改为 `$verInfo.devflowVersion`，与 v2.7.4 命名规范一致 |
| 移除项目目录复制 | 移除将整个 devflow-plugin/ 复制到项目 .devflow/ 的代码 |
| 移除项目目录指引 | 移除提示用户从 .devflow/ 运行 update.ps1 的提示 |
| 保留核心逻辑 | 保留环境检查、版本显示、调用 setup.ps1 的核心流程 |
| **保留 .devflow 目录自检** | 保留禁止从 .devflow/ 目录运行 install.ps1 的检测（第 44-58 行），该检测属于安装器自身安全检查，不属项目目录操作 |

### 2.2 V260-036-03：修复 setup.ps1 skillMap 遗漏

**用户故事**：作为 DevFlow 维护者，我希望 setup.ps1 的 skillMap 包含 version.json 和 sync-skills.ps1，确保首次安装时版本配置和同步工具也被复制到 TRAE 系统目录。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-04 | 运行 setup.ps1 后，TRAE 系统目录下存在 `devflow-plugin-config/version.json` | 文件存在性检查 |
| AC-05 | 运行 setup.ps1 后，TRAE 系统目录下存在 `devflow-plugin-sync/sync-skills.ps1` | 文件存在性检查 |

**功能点**：

| 功能 | 描述 |
|------|------|
| 新增 devflow-plugin-config | 在 skillMap 中添加 `"devflow-plugin-config" = "version.json"` |
| 新增 devflow-plugin-sync | 在 skillMap 中添加 `"devflow-plugin-sync" = "sync-skills.ps1"` |

### 2.3 V260-036-04：修复 sync-skills.ps1 缺少自身引用

**用户故事**：作为 DevFlow 维护者，我希望 sync-skills.ps1 在同步时也更新自身，避免每次修改 sync-skills.ps1 后需要手动复制。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-06 | 运行 sync-skills.ps1 后，TRAE 系统目录下的 sync-skills.ps1 与本地副本一致 | 文件内容对比 |

**功能点**：

| 功能 | 描述 |
|------|------|
| 新增自身引用 | 在 `$DevFlowSkills` 中添加 `@{ Name = "devflow-plugin-sync"; SourceDir = "sync-skills.ps1" }` 条目 |

### 2.4 V260-036-05：修复 update.ps1 skillMap 遗漏

**用户故事**：作为 DevFlow 维护者，我希望 update.ps1 的 skillMap 包含 version.json 和 sync-skills.ps1，确保增量更新时版本配置和同步工具也被同步。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-07 | 运行 update.ps1 后，TRAE 系统目录存在 `devflow-plugin-config/version.json` | 文件存在性检查 |

**功能点**：

| 功能 | 描述 |
|------|------|
| 新增 devflow-plugin-config | 在 skillMap 中添加 `"devflow-plugin-config" = "version.json"` |
| 新增 devflow-plugin-sync | 在 skillMap 中添加 `"devflow-plugin-sync" = "sync-skills.ps1"` |

### 2.5 V260-036-06：修复 update-devflow.bat 硬编码版本号

**用户故事**：作为 DevFlow 维护者，我希望 update-devflow.bat 的标题不包含硬编码版本号，避免版本更新后标题与实际版本不一致。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-08 | update-devflow.bat 标题显示为 DevFlow Updater 而非包含 v2.6.0 | 查看标题 |

**功能点**：

| 功能 | 描述 |
|------|------|
| 标题修正 | 将 `title DevFlow Updater v2.6.0` 改为 `title DevFlow Updater` |

### 2.6 V260-036-09：同步修改 setup.sh / update.sh

**用户故事**：作为 Linux 用户，我希望 setup.sh / update.sh 的 SKILL_MAP 与 setup.ps1 / update.ps1 保持一致，确保 Linux 环境也能获得完整技能映射。

**验收标准**：

| 编号 | 验收项 | 验证方法 |
|:----:|--------|---------|
| AC-11 | setup.sh 和 update.sh 的 SKILL_MAP 包含 `devflow-plugin-config` 和 `devflow-plugin-sync` | 文件内容检查 |

**功能点**：

| 功能 | 描述 |
|------|------|
| 新增 SKILL_MAP 条目 | 在 setup.sh 和 update.sh 的 SKILL_MAP 中添加 `devflow-plugin-config` 和 `devflow-plugin-sync` |

---

## 3. 业务流程

### 3.1 安装流程（install.ps1）修改前后对比

```
修改前：                            修改后：
  检查环境                             检查环境
  ↓                                    ↓
  显示版本信息                          显示版本信息
  ↓                                    ↓
  询问项目路径                          询问项目路径（可选）
  ↓                                    ↓
  → 复制 devflow-plugin/ 到 .devflow/  ❌ 移除
  ↓
  调用 setup.ps1                       调用 setup.ps1
  ↓                                    ↓
  提示用户从 .devflow/ 运行 update     提示安装完成，重启 TRAE IDE
```

### 3.2 skillMap 修改前后对比

**修改前**（setup.ps1 / update.ps1）：

```
skillMap = {
    "devflow-init"            → "devflow-init\SKILL.md"
    "devflow-phase-manager"   → "devflow-phase-manager\SKILL.md"
    "devflow-project-config"  → "devflow-project-config\SKILL.md"
    ... (18 个其他技能)
    ❌ 缺少 devflow-plugin-config
    ❌ 缺少 devflow-plugin-sync
}
```

**修改后**：

```
skillMap = {
    "devflow-init"            → "devflow-init\SKILL.md"
    "devflow-phase-manager"   → "devflow-phase-manager\SKILL.md"
    "devflow-project-config"  → "devflow-project-config\SKILL.md"
    ... (18 个其他技能)
    ✅ "devflow-plugin-config" → "version.json"
    ✅ "devflow-plugin-sync"   → "sync-skills.ps1"
}
```

### 3.3 $DevFlowSkills 修改前后对比

**修改前**（sync-skills.ps1）：

```
$DevFlowSkills = @(
    @{ Name = "devflow-init"; SourceDir = "devflow-init" }
    @{ Name = "devflow-plugin-config"; SourceDir = "version.json" }
    ❌ 缺少 devflow-plugin-sync（自身引用）
    ...
)
```

**修改后**：

```
$DevFlowSkills = @(
    @{ Name = "devflow-init"; SourceDir = "devflow-init" }
    @{ Name = "devflow-plugin-config"; SourceDir = "version.json" }
    ✅ @{ Name = "devflow-plugin-sync"; SourceDir = "sync-skills.ps1" }
    ...
)
```

---

## 4. 数据模型

### 4.1 受影响文件清单

| 文件 | 类型 | 修改性质 | 本版本修改内容 |
|------|:----:|:--------:|--------------|
| `setup.ps1` | PowerShell 脚本 | 修改 | skillMap 新增 2 条 |
| `sync-skills.ps1` | PowerShell 脚本 | 修改 | $DevFlowSkills 新增 1 条 |
| `update.ps1` | PowerShell 脚本 | 修改 | skillMap 新增 2 条 |
| `update-devflow.bat` | Batch 脚本 | 修改 | 标题字符串修改 |
| `install.ps1` | PowerShell 脚本 | 修改 | 字段名修正 + 移除代码段 |
| `setup.sh` | Shell 脚本 | 修改 | SKILL_MAP 新增 2 条 |
| `update.sh` | Shell 脚本 | 修改 | SKILL_MAP 新增 2 条 |

---

## 5. 非功能需求

| 需求 | 指标 | 验证方式 |
|------|------|---------|
| 向后兼容 | 现有用户升级后所有功能不受影响 | 运行现有 update.ps1 验证无报错 |
| 文件完整性 | 所有修改文件语法正确 | 静态语法检查 |
| 一致性 | setup.ps1 和 update.ps1 的 skillMap 保持一致 | 内容对比 |