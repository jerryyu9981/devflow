# DevFlow v2.8.0 三步走流程设计文档

> **文档状态**: [Draft]  
> **版本**: 1.0.0  
> **项目**: DevFlow  
> **目标版本**: v2.8.0  
> **作者**: AA-DevFlow-Dev  
> **创建日期**: 2026-07-12

---

## 1. 三步走总览

DevFlow 的完整使用流程由三个独立步骤组成，每个步骤有且只有一个执行入口，职责严格隔离：

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DevFlow 三步走                                 │
└─────────────────────────────────────────────────────────────────────┘

  第一步：download                         第二步：install              第三步：init
  ┌─────────────────┐                     ┌─────────────────┐          ┌─────────────────┐
  │  download-       │   云端仓库          │  install.bat     │          │  devflow-init    │
  │  devflow.ps1     │ ────────→          │  ↓               │          │                  │
  │                  │   本地副本           │  install.ps1     │          │  项目初始化      │
  │  从云端下载       │  (devflow-plugin/)  │  ↓               │          │  + 版本差异检测   │
  │  到本地副本       │                     │  setup.ps1       │          │                  │
  └─────────────────┘                     │  ↓               │          │  产出版本配置    │
                                          │  TRAE 系统目录    │          │  到项目目录      │
                                          │  ~/.trae-cn/     │          │                  │
                                          │  skills/         │          └─────────────────┘
                                          └─────────────────┘
```

### 1.1 三步职责边界

| 步骤 | 入口 | 方向 | 职责 | 操作目标 | 是否涉及项目目录 |
|:----:|:----|:----|:-----|:--------|:--------------:|
| **① download** | `download-devflow.ps1` | 云端→本地副本 | 从云端仓库拉取 DevFlow 最新代码 | 本地副本 `devflow-plugin/` | ❌ |
| **② install** | `install.bat` → `install.ps1` → `setup.ps1` | 本地副本→TRAE | 将本地副本技能安装到 TRAE 系统目录 | TRAE 系统目录 `~/.trae-cn/skills/` | ❌ |
| **③ init** | `devflow-init`（SKILL.md） | TRAE→项目 | 项目初始化 + 版本检测 + 输出配置 | 项目目录 `.devflow/` | ✅ **仅此步** |

### 1.2 核心原则

1. **download 不碰 install**：下载脚本只负责拉取代码，不调用任何安装逻辑
2. **install 不碰 init**：安装脚本只负责部署到 TRAE 系统目录，不涉及项目目录
3. **init 不碰 install**：初始化脚本只负责项目配置和版本检测，不安装技能
4. **每个步骤有且只有一个入口**：用户只需记住三步走，无需关心内部细节

---

## 2. 第一步：download（新增）

### 2.1 职责

从云端仓库下载最新 DevFlow 到本地副本，保证本地副本是最新版。

### 2.2 入口文件

`download-devflow.ps1`（新增，位于 `devflow-plugin/`）

### 2.3 功能

| 模式 | 参数 | 行为 |
|:----:|:----|:-----|
| **Clone** | `-Action Clone` | 首次从云端仓库克隆到本地副本，仓库地址从 `version.json.repository` 读取 |
| **Update** | `-Action Update`（默认） | 拉取云端最新代码（git pull），仓库地址从 `version.json.repository` 读取 |
| **SetRepo** | `-Action SetRepo` | 交互式设置仓库地址，写入 `version.json.repository` 和 `homepage` |

### 2.4 使用方式

```powershell
# 首次使用：设置仓库地址 + 克隆
.\download-devflow.ps1 -Action SetRepo    # 输入仓库地址
.\download-devflow.ps1 -Action Clone      # 克隆到本地

# 后续更新
.\download-devflow.ps1 -Action Update     # 拉取最新代码
```

### 2.5 边界约束

- ❌ 不调用 install.ps1 或 setup.ps1
- ❌ 不写入 TRAE 系统目录
- ❌ 不涉及项目目录
- ✅ 只做 git fetch/pull/clone 操作

---

## 3. 第二步：install（已有，职责明确）

### 3.1 职责

将本地副本中的 DevFlow 技能文件安装到 TRAE 系统目录，使 TRAE IDE 能够加载 DevFlow 技能。

### 3.2 入口文件

`install.bat`（Windows 双击入口）→ `install.ps1`（交互式安装器）→ `setup.ps1`（安装引擎）

### 3.3 执行流程（v2.7.5 已修复）

```
install.bat
  → 检查 PowerShell 可用
  → 调用 install.ps1

install.ps1
  → 读取 version.json 显示版本号
  → .devflow 目录自检（安全检测）
  → 直接调用本目录下的 setup.ps1（不再复制到项目目录）
  → 提示安装完成，重启 TRAE IDE

setup.ps1
  → Host 检测（~/.trae-cn 是否存在）
  → 读取 skillMap，遍历安装 30 个技能到 TRAE 系统目录
  → 非 .md 文件保留原文件名（v2.8.0 修复）
  → 显示安装结果
```

### 3.4 更新方式

| 方式 | 命令 | 说明 |
|:----|:-----|:-----|
| 首次安装 | `install.bat` 双击 | 交互式安装器 |
| 增量更新 | `update.ps1` 运行 | 版本比较后同步 |
| 强制同步 | `update-devflow.bat` 双击 | 无条件全量同步 |
| 更新引擎 | `sync-skills.ps1 -Action Sync -Target All` | 底层同步工具 |

### 3.5 边界约束

- ❌ 不执行 git clone/pull（这是 download 的职责）
- ❌ 不写入项目目录（这是 init 的职责）
- ❌ 不修改 version.json 的版本号
- ✅ 只操作 TRAE 系统目录

---

## 4. 第三步：init（增强）

### 4.1 职责

在用户项目中初始化 DevFlow 配置，包括创建 `.devflow/` 目录结构、记录版本信息、检测 TRAE 版本与项目记录版本的差异。

### 4.2 入口文件

`devflow-init`（SKILL.md，TRAE 技能面板中调用）

### 4.3 执行流程（v2.8.0 增强后）

```
步骤 1.0: 检查项目根目录
  → 确认当前工作目录是项目根目录

步骤 1.1: 检查 .devflow/ 目录
  → 不存在则创建

步骤 1.2: 创建 .devflow/state.json（首次）
  → 写入初始状态

步骤 1.3: 创建 .devflow/config.json（首次）
  → 写入项目配置

步骤 1.4: 创建 .gitignore（首次）
  → 设置 .devflow/ 忽略规则

步骤 1.5: 读取 TRAE 系统目录版本
  → 从 ~/.trae-cn/skills/devflow-plugin-config/version.json 读取 devflowVersion 字段
  → 得到 devflowVersionInTrae（TRAE 已安装的 DevFlow 版本）

步骤 1.5.5: 版本差异检测 ⭐（本次新增）
  → 从 .devflow/state.json.devflowVersion 读取 devflowVersionInProject（项目记录的 DevFlow 版本）
  → 比较 devflowVersionInTrae 与 devflowVersionInProject：
    → 一致 → 跳过，无操作
    → devflowVersionInTrae > devflowVersionInProject → 自动更新 state.json 并提示用户
    → devflowVersionInTrae < devflowVersionInProject → 提示用户，不自动修改
  → 将结果写入 state.json.versionCheck

步骤 1.6: 写入项目根目录 version.json
  → 记录 devflowVersion = devflowVersionInTrae

步骤 2~3: 标准项目初始化流程

步骤 4: 更新 state.json
  → 将版本信息写入 state.json
```

### 4.4 版本检测交互示例

**TRAE 已安装版本更新时**：
```
[DevFlow] 版本检测
  TRAE 已安装 DevFlow 版本: v2.8.0
  项目记录 DevFlow 版本:    v2.7.5
  → 已自动更新项目版本记录
  → 建议重启 TRAE IDE 以加载最新技能
```

**项目记录版本更新时**（异常情况）：
```
[DevFlow] 版本检测
  TRAE 已安装 DevFlow 版本: v2.7.5
  项目记录 DevFlow 版本:    v2.8.0
  → 项目记录版本高于 TRAE 已安装版本（可能部署了更高版本）
  → 请检查 TRAE 系统目录是否需要更新
```

### 4.5 state.json 新增字段

```json
{
  "devflowVersion": "2.8.0",
  "projectVersion": "1.0.0",
  "versionCheck": {
    "lastCheck": "2026-07-12T10:30:00Z",
    "installedDevflowVersion": "2.8.0",
    "recordedDevflowVersion": "2.7.5",
    "result": "installed_newer",
    "action": "auto_updated"
  }
}
```

`result` 取值：`consistent` | `installed_newer` | `project_newer` | `first_check` | `error`
`action` 取值：`no_action` | `auto_updated` | `user_prompted` | `error`

### 4.6 边界约束

- ❌ 不调用 setup.ps1 或 sync-skills.ps1（不安装技能）
- ❌ 不写入 TRAE 系统目录
- ❌ 不执行 git 操作
- ✅ 只操作项目目录 + 读取 TRAE 系统目录（只读）

---

## 5. 三步走对应关系

| 场景 | 用户操作 | 执行步骤 | 涉及的执行文件 |
|:----|:---------|:--------|:-------------|
| **全新环境** | ① 下载 → ② 安装 → ③ 初始化 | download + install + init | download-devflow.ps1 → install.bat/ps1 → setup.ps1 → devflow-init |
| **已有环境、更新版本** | ① 下载 → ② 更新 | download + install | download-devflow.ps1 → update.ps1/update-devflow.bat |
| **已有环境、新项目** | ③ 初始化 | init | devflow-init |
| **已有环境、切换项目** | ③ 重新初始化 | init（自动版本检测） | devflow-init |

---

## 6. 修改清单

### 6.1 V260-037：setup.ps1 复制逻辑（已修复）

| 修改项 | 位置 | 修改前 | 修改后 |
|--------|------|--------|--------|
| 目标文件名 | 第 98 行 | `$dstFile = Join-Path $dstDir "SKILL.md"` | 增加扩展名判断：.md→SKILL.md，非 .md→保留原文件名 |

### 6.2 V260-036-07：devflow-init 版本差异检测（新增）

| 修改项 | 位置 | 说明 |
|--------|------|------|
| 新增步骤 1.5.5 | 步骤 1.5 之后 | 版本差异检测逻辑 |
| 新增 versionCheck 字段 | state.json | 记录检测结果 |
| 降级处理 | 文件不存在时 | 跳过检测，记录 error |

### 6.3 V260-036-01：download-devflow.ps1（新增文件）

| 内容 | 说明 |
|:----|:-----|
| 文件位置 | `devflow-plugin/download-devflow.ps1` |
| 参数 | `-Action Clone|Update|SetRepo`、`-RepoUrl <string>`、`-TargetDir <string>` |
| Clone 模式 | `git clone` 首次克隆 |
| Update 模式 | `git pull` 拉取更新 |
| SetRepo 模式 | 交互式设置仓库地址，写入 `version.json` |
| 地址来源 | 从 `version.json.repository` 读取 |

### 6.4 V260-036-08：version.json 仓库地址（填充）

| 修改项 | 说明 |
|--------|------|
| repository 字段 | 由 SetRepo 模式写入，格式 `https://github.com/...` |
| homepage 字段 | 由 SetRepo 模式写入，格式 `https://github.com/...` |
| bugs 字段 | 自动生成，格式 `https://github.com/.../issues` |