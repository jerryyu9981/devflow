# DevFlow v2.4.0 部署架构草案

| 项目信息 | |
|---|---|
| **项目名称** | DevFlow — 软件开发工程规范插件 |
| **目标版本** | v2.4.0 |
| **基准版本** | v2.3.2 |
| **文档版本** | 1.0 |
| **创建日期** | 2026-07-02 |
| **文档状态** | 编制中 |
| **文档 owner** | jerry.yu |
| **所属阶段** | Step 2 — 架构与设计 |

---

## 目录

1. [概述](#1-概述)
2. [部署目标环境](#2-部署目标环境)
3. [安装部署流程设计](#3-安装部署流程设计)
4. [版本分发策略](#4-版本分发策略)
5. [回滚策略](#5-回滚策略)
6. [跨平台部署差异](#6-跨平台部署差异)
7. [环境变量和配置](#7-环境变量和配置)
8. [发布流程](#8-发布流程)
9. [变更记录](#9-变更记录)

---

## 1. 概述

### 1.1 DevFlow 的"部署"概念

DevFlow 不是传统意义上的 Web 应用或桌面软件。它是一套以 **SKILL.md 文件**为核心的 AI 编程助手技能插件系统，其"部署"本质是将技能文件和配套资源复制到目标位置，使 AI 编程助手能够识别并加载这些技能。

DevFlow 的部署包含以下核心动作：

| 动作 | 说明 |
|---|---|
| **技能部署** | 将 `skills/` 目录下的技能文件复制到 AI 平台的技能目录（如 `~/.trae-cn/skills/`） |
| **模板部署** | 将 `templates/` 目录下的文档模板复制到项目的 `.devflow/templates/` 目录 |
| **配置生成** | 在项目根目录生成 `.devflow/config.json`，记录分支策略、备份配置等 |
| **状态初始化** | 生成 `.devflow/state.json`，记录项目当前开发阶段 |

### 1.2 部署与安装的关系

| 操作 | 定义 | 流程 |
|---|---|---|
| **安装** | 首次部署到本地环境 | 从远程仓库获取源码 → 检测环境 → 复制技能和模板 → 生成配置 → 验证安装结果 |
| **更新** | 从远程获取新版本后重新部署 | 检测当前版本 → 备份现有技能 → 拉取新版本 → 重新部署 → 验证 |
| **卸载** | 从本地环境移除技能文件 | 确认卸载 → 删除技能文件 → 保留用户配置数据 |

安装等同于"部署到本地"，更新等同于"从远程获取新版本后重新部署"。DevFlow 不依赖运行时服务，所有文件均为静态 Markdown 和 JSON 文件，部署即生效，无需额外启动或编译步骤。

---

## 2. 部署目标环境

### 2.1 目标路径矩阵

DevFlow 部署涉及以下目标路径，覆盖技能文件、项目配置、项目状态、备份和模板五大类组件：

| 组件 | Windows 路径 | macOS/Linux 路径 | 说明 |
|---|---|---|---|
| **AI 平台技能目录** | `%USERPROFILE%\.trae-cn\skills\{skill-name}\SKILL.md` | `~/.trae-cn/skills/{skill-name}/SKILL.md` | 运行时目录，AI 编程助手从此目录加载技能 |
| **项目配置目录** | `{project}\.devflow\config.json` | `{project}/.devflow/config.json` | 项目级配置，存储分支策略、远程仓库等 |
| **项目状态目录** | `{project}\.devflow\state.json` | `{project}/.devflow/state.json` | 项目阶段状态，记录当前开发阶段与已完成阶段 |
| **插件备份目录** | `{project}\.devflow\backup\` | `{project}/.devflow/backup/` | 已存在技能的备份，用于升级回滚 |
| **项目模板目录** | `{project}\.devflow\templates\` | `{project}/.devflow/templates/` | 文档模板，供需求、设计、测试等阶段使用 |

> **说明**：`{project}` 表示用户当前工作项目的根目录，由安装脚本在交互式引导中获取或由用户指定。`{skill-name}` 对应 DevFlow 技能名称，格式为 `devflow-*`（如 `devflow-init`、`devflow-phase-manager`、`devflow-project-config`）。

### 2.2 支持的 AI 平台

DevFlow v2.4.0 支持以下 AI 编程助手平台：

| 平台 | 技能目录机制 | 版本支持 | 备注 |
|---|---|---|---|
| **TRAE Work** | `~/.trae-cn/skills/` | v1.0+（主力平台） | 首要适配平台，所有测试以此平台为准 |
| **Claude Code** | 同上或平台特定目录 | v1.0+ | 技能格式兼容，路径可能需适配 |
| **Cursor** | 同上或平台特定目录 | v1.0+ | 技能格式兼容，路径可能需适配 |
| **Codex CLI** | 同上或平台特定目录 | v1.0+ | 技能格式兼容，路径可能需适配 |

> **适配策略**：以 `~/.trae-cn/skills/` 为标准路径。对于各平台存在差异的目录机制，安装脚本将在环境检测阶段识别平台类型并自动适配。当前版本以 TRAE Work 为主力平台，其他平台支持待后续版本逐步完善。

---

## 3. 安装部署流程设计

### 3.1 全新安装流程

全新安装适用于首次使用 DevFlow 或在新环境中部署。流程共 8 个步骤：

```
步骤 1：下载源
  ├─ 方式 A：Git clone 远程仓库（标准方式）
  │         git clone http://192.168.0.14/jerry.yu/devflow.git
  ├─ 方式 B：解压本地 ZIP 包（离线方式）
  └─ 验证源码完整性（检查 version.json、SKILL.md 文件数量）

步骤 2：环境检测
  ├─ 操作系统识别（Windows / macOS / Linux）
  ├─ Git 版本检查（>= 2.0）
  ├─ Shell 版本检查（PowerShell >= 5.1 / Bash >= 4.0）
  ├─ 网络连通性检测（远程仓库可达性）
  └─ AI 平台检测（识别 ~/.trae-cn/skills/ 是否存在）

步骤 3：配置引导（交互式）
  ├─ 远程仓库地址确认（默认 http://192.168.0.14/jerry.yu/devflow.git）
  ├─ 分支策略选择（main / release / feature）
  ├─ 项目信息收集（项目名称、项目路径）
  └─ 技能目录确认（默认 ~/.trae-cn/skills/）

步骤 4：技能部署
  ├─ 读取 skills/ 目录下所有技能文件
  ├─ 将每个技能文件复制到 AI 平台技能目录
  │   skills/L1/*.md → ~/.trae-cn/skills/{skill-name}/SKILL.md
  │   skills/L2/*.md → ~/.trae-cn/skills/{skill-name}/SKILL.md
  │   skills/L3/*.md → ~/.trae-cn/skills/{skill-name}/SKILL.md
  └─ 复制 Orchestrator 技能
      devflow-init/SKILL.md → ~/.trae-cn/skills/devflow-init/SKILL.md
      devflow-phase-manager/SKILL.md → ~/.trae-cn/skills/devflow-phase-manager/SKILL.md
      devflow-project-config/SKILL.md → ~/.trae-cn/skills/devflow-project-config/SKILL.md

步骤 5：模板部署
  ├─ 创建 .devflow/templates/ 目录（如不存在）
  └─ 复制 templates/ 下所有模板文件到 .devflow/templates/

步骤 6：配置生成
  ├─ 生成 .devflow/config.json
  │   {
  │     "repoUrl": "http://192.168.0.14/jerry.yu/devflow.git",
  │     "branch": "main",
  │     "backupEnabled": true,
  │     "backupRetention": 3
  │   }
  ├─ 生成 .devflow/state.json
  │   {
  │     "currentPhase": "idle",
  │     "completedPhases": []
  │   }
  └─ 复制 version.json 到 .devflow/

步骤 7：安装验证
  ├─ 运行 validate-install.ps1（Windows）/ validate-install.sh（macOS/Linux）
  ├─ 验证技能文件数量与 version.json 中声明一致
  ├─ 验证模板文件完整性
  ├─ 验证 config.json 和 state.json 格式正确
  └─ 输出验证结果（通过/失败 + 详细信息）

步骤 8：结果报告
  ├─ 输出安装结果摘要（成功/失败）
  ├─ 显示已安装技能数量和列表
  ├─ 显示已安装模板数量和列表
  ├─ 显示配置文件路径
  └─ 提示后续操作（如何开始使用 DevFlow）
```

### 3.2 升级安装流程

升级安装适用于已有旧版本 DevFlow 的环境中更新到新版本：

```
步骤 1：检测已安装版本
  ├─ 读取 .devflow/version.json 获取当前版本号
  ├─ 对比远程仓库 version.json 获取目标版本号
  └─ 如版本相同则提示"已是最新版本"并退出

步骤 2：备份现有技能
  ├─ 创建备份目录 .devflow/backup/{timestamp}/
  │   timestamp 格式：YYYYMMDD-HHmmss
  ├─ 备份所有已安装技能文件
  │   ~/.trae-cn/skills/devflow-* → .devflow/backup/{timestamp}/skills/
  ├─ 备份 .devflow/config.json → .devflow/backup/{timestamp}/config.json
  ├─ 备份 .devflow/state.json → .devflow/backup/{timestamp}/state.json
  └─ 记录备份元信息（版本号、时间戳、备份原因）

步骤 3：下载新版本源
  ├─ 方式 A：Git pull（已存在本地仓库）
  │         git pull origin main
  ├─ 方式 B：Git clone（不存在本地仓库）
  │         git clone http://192.168.0.14/jerry.yu/devflow.git
  └─ 切换到目标版本标签（如指定）
      git checkout v2.4.0

步骤 4：执行全新安装流程（步骤 4-8）
  ├─ 技能部署
  ├─ 模板部署
  ├─ 配置生成（合并现有配置，保留用户自定义项）
  ├─ 安装验证
  └─ 结果报告

步骤 5：清理备份（可选）
  ├─ 列出所有备份，按时间排序
  └─ 仅保留最近 3 次备份，自动清理更早的备份
```

### 3.3 卸载流程

```
步骤 1：确认卸载
  └─ 交互式确认："确认卸载 DevFlow？(y/N)"

步骤 2：删除技能文件
  └─ 删除 ~/.trae-cn/skills/ 下所有 devflow-* 技能目录
      rm -rf ~/.trae-cn/skills/devflow-*

步骤 3：删除备份目录（可选）
  ├─ 交互式确认："是否删除备份目录？(y/N)"
  └─ 确认后删除 .devflow/backup/

步骤 4：保留用户数据
  ├─ 保留 .devflow/config.json（用户配置不删除）
  ├─ 保留 .devflow/state.json（项目状态不删除）
  └─ 保留 .devflow/templates/（模板文件不删除）

步骤 5：输出卸载完成信息
  ├─ 显示已删除的技能列表
  ├─ 显示保留的配置文件路径
  └─ 提示如需重新安装可再次运行安装脚本
```

---

## 4. 版本分发策略

### 4.1 分发方式

DevFlow v2.4.0 支持以下三种分发方式：

| 方式 | 说明 | 适用场景 |
|---|---|---|
| **Git 仓库** | 用户 clone 远程仓库后运行 install 脚本 | 标准分发方式，适用于有网络环境 |
| **本地包** | 解压 ZIP 包后运行 install 脚本 | 无网络环境或内网受限环境 |
| **版本标签** | Git tag `v2.4.0` 指向对应 commit | 版本锁定，确保可复现的安装 |

**Git 仓库分发流程**：
1. 用户执行 `git clone http://192.168.0.14/jerry.yu/devflow.git`
2. 进入仓库目录
3. 运行安装脚本：`install.bat`（Windows）/ `install.sh`（macOS/Linux）

**本地包分发流程**：
1. 管理员从仓库导出 ZIP 包
2. 用户解压 ZIP 包到本地目录
3. 运行安装脚本：`install.bat`（Windows）/ `install.sh`（macOS/Linux）

**版本标签锁定**：
- 使用 `git checkout v2.4.0` 切换到指定版本
- 确保安装的技能文件与版本标签完全一致
- 适用于需要精确版本控制的场景

### 4.2 版本管理

| 要素 | 说明 |
|---|---|
| **version.json** | 作为唯一版本号来源（Single Source of Truth），所有脚本和工具从此文件读取版本信息 |
| **Git tag** | 标记发布版本，格式为 `v{major}.{minor}.{patch}`（如 `v2.4.0`） |
| **CHANGELOG.md** | 记录每个版本的变更内容，遵循 [Keep a Changelog](https://keepachangelog.com/) 格式 |

版本号遵循语义化版本规范（SemVer）：
- **major**：不兼容的架构变更
- **minor**：向后兼容的功能新增
- **patch**：向后兼容的问题修复

---

## 5. 回滚策略

### 5.1 自动备份机制

| 项目 | 说明 |
|---|---|
| **备份时机** | 每次升级安装前自动触发 |
| **备份位置** | `.devflow/backup/{YYYYMMDD-HHmmss}/` |
| **备份内容** | 所有已安装的技能文件、config.json、state.json |
| **备份保留** | 最多保留最近 3 次备份，更早的备份自动清理 |
| **备份元信息** | 每次备份记录版本号、时间戳、备份原因 |

### 5.2 回滚操作

```
方式一：从备份恢复（推荐）
  1. 列出可用备份：ls .devflow/backup/
  2. 选择目标备份版本
  3. 从备份目录恢复技能文件：
     cp -r .devflow/backup/{timestamp}/skills/* ~/.trae-cn/skills/
  4. 恢复配置文件（如需要）：
     cp .devflow/backup/{timestamp}/config.json .devflow/config.json
  5. 运行安装验证脚本确认恢复成功

方式二：Git 紧急回滚
  1. 进入 DevFlow 本地仓库目录
  2. 切换到上一个版本标签：git checkout v2.3.2
  3. 重新运行安装脚本
  4. 运行安装验证脚本确认恢复成功
```

### 5.3 回滚验证

回滚完成后，必须执行以下验证：
- 技能文件数量与目标版本 version.json 声明一致
- 所有技能文件可被 AI 平台正常加载
- config.json 和 state.json 格式正确
- 模板文件完整

---

## 6. 跨平台部署差异

### 6.1 Windows 特殊处理

| 项目 | 处理方式 |
|---|---|
| **路径分隔符** | 脚本内部统一使用正斜杠 `/`，输出用户可见路径时按需转换为反斜杠 `\` |
| **文件编码** | 脚本文件使用 UTF-8 BOM（确保 PowerShell 5.1 兼容性） |
| **行尾** | 脚本文件使用 CRLF（`\r\n`） |
| **执行策略** | `install.bat` 内部调用 PowerShell 时使用 `-ExecutionPolicy Bypass` 参数 |
| **脚本入口** | 优先使用 `install.bat` 作为入口（兼容 CMD 和 PowerShell） |
| **路径变量** | 使用 `%USERPROFILE%` 获取用户主目录，在脚本中展开为绝对路径 |

**Windows 安装脚本调用链**：
```
install.bat
  └─ install.ps1  (PowerShell 5.1+)
       ├─ 环境检测
       ├─ 配置引导
       ├─ 技能部署
       ├─ 模板部署
       ├─ 配置生成
       └─ validate-install.ps1  (安装验证)
```

### 6.2 macOS/Linux 特殊处理

| 项目 | 处理方式 |
|---|---|
| **路径分隔符** | 统一使用正斜杠 `/` |
| **文件编码** | UTF-8 无 BOM |
| **行尾** | LF（`\n`） |
| **权限** | `install.sh` 需要在首次使用前执行 `chmod +x install.sh` 赋予执行权限 |
| **脚本入口** | 直接使用 `install.sh` 作为入口 |
| **路径变量** | 使用 `$HOME` 获取用户主目录，展开为 `~` 或绝对路径 |

**macOS/Linux 安装脚本调用链**：
```
install.sh  (Bash 4.0+, chmod +x)
  ├─ 环境检测
  ├─ 配置引导
  ├─ 技能部署
  ├─ 模板部署
  ├─ 配置生成
  └─ validate-install.sh  (安装验证)
```

### 6.3 跨平台一致性保障

| 保障措施 | 说明 |
|---|---|
| **统一逻辑** | 安装脚本的核心部署逻辑（文件复制、配置生成）在所有平台保持一致 |
| **平台适配层** | 仅在路径处理、编码、行尾等平台差异处做适配，其余逻辑共享 |
| **验证脚本** | 跨平台验证脚本确保安装结果一致，无论使用哪个平台安装 |

---

## 7. 环境变量和配置

### 7.1 环境变量

以下环境变量可用于覆盖 DevFlow 的默认行为：

| 环境变量 | 默认值 | 说明 |
|---|---|---|
| `DEVFLOW_REPO_URL` | `http://192.168.0.14/jerry.yu/devflow.git` | 远程仓库地址，可选覆盖 |
| `DEVFLOW_SKILLS_DIR` | `~/.trae-cn/skills` | 技能安装目录，可选覆盖 |
| `DEVFLOW_HOME` | `{project}/.devflow/` | DevFlow 配置目录，可选覆盖 |

### 7.2 配置文件

**config.json**（项目级配置）：
```json
{
  "repoUrl": "http://192.168.0.14/jerry.yu/devflow.git",
  "branch": "main",
  "backupEnabled": true,
  "backupRetention": 3,
  "skillsDir": "~/.trae-cn/skills",
  "templatesDir": ".devflow/templates"
}
```

**state.json**（项目状态）：
```json
{
  "currentPhase": "idle",
  "completedPhases": [],
  "lastUpdated": "2026-07-02T00:00:00Z"
}
```

### 7.3 优先级

配置加载优先级（由高到低）：
1. 命令行参数（如 `--repo-url`）
2. 环境变量（如 `DEVFLOW_REPO_URL`）
3. config.json 配置文件
4. 内置默认值

---

## 8. 发布流程

DevFlow v2.4.0 的发布流程如下：

```
步骤 1：代码冻结
  └─ 合并所有 Phase 代码到 main 分支
     git checkout main
     git merge phase-1-xxx phase-2-xxx ...

步骤 2：版本标记
  ├─ 更新 version.json 中的版本号为 "2.4.0"
  ├─ 创建 Git tag：
  │   git tag -a v2.4.0 -m "DevFlow v2.4.0 release"
  └─ 确保 tag 指向正确的 commit

步骤 3：推送远程
  ├─ 推送代码和标签到远程仓库：
  │   git push origin main --tags
  └─ 验证远程仓库已更新

步骤 4：更新文档
  ├─ 更新 CHANGELOG.md，记录 v2.4.0 的所有变更
  ├─ 更新 README.md，反映最新功能和安装说明
  └─ 更新版本相关文档

步骤 5：验证发布
  ├─ Windows 平台：全新安装测试 + 升级安装测试
  ├─ macOS 平台：全新安装测试 + 升级安装测试
  ├─ Linux 平台：全新安装测试 + 升级安装测试
  └─ 验证所有技能可被 AI 平台正常加载

步骤 6：发布公告
  ├─ 编写发布公告，包含版本亮点和变更摘要
  └─ 通知用户升级方式和注意事项
```

---

## 9. 变更记录

| 版本 | 日期 | 变更内容 | 作者 |
|---|---|---|---|
| 1.0 | 2026-07-02 | 初始版本：完成部署架构草案编制，覆盖概述、目标环境、安装流程、分发策略、回滚策略、跨平台差异、环境配置和发布流程 | jerry.yu |
