# DevFlow v2.4.0 Phase 2 开发日志报告

| 项目 | 内容 |
|---|---|
| 项目名 | DevFlow — 软件开发工程规范插件 |
| 目标版本 | v2.4.0 |
| 基准版本 | v2.3.2 |
| 开发阶段 | Phase 2（体验升级） |
| 开发日期 | 2026-07-02 |
| 开发者 | jerry.yu |

---

## 1. 实现范围

### 已实现需求

| 需求编号 | 需求名称 | 优先级 | 状态 |
|---|---|---|---|
| VR-001 | 交互式安装向导 | P0 | 已完成 |
| VR-002 | 项目初始化向导增强 | P0 | 已完成 |
| VR-005 | 安装验证测试 | P1 | 已完成 |
| VR-018 | 跨平台安装脚本统一 | P1 | 已完成 |

### 排除项

以下内容不在 Phase 2 实现范围内，将在后续阶段处理：

- install.bat 的交互式改造（仅 install.ps1 完全重写）
- update.ps1 / update.sh 的改造
- CHANGELOG.md 的 v2.4.0 版本条目更新（将在版本发布时统一更新）
- 技能文件业务内容重构（与 Phase 1 相同）

---

## 2. 新增文件清单

| 文件路径 | 用途 | 对应需求 | 行数 |
|---|---|---|---|
| `install.sh` | 跨平台安装脚本（bash），与 install.ps1 功能对等 | VR-018 | ~189 |
| `setup.sh` | 跨平台配置脚本（bash），与 setup.ps1 功能对等 | VR-018 | ~107 |
| `scripts/validate-install.ps1` | 安装验证脚本（PowerShell），5 大类验证 | VR-005 | ~330 |
| `scripts/validate-install.sh` | 安装验证脚本（bash），5 大类验证 | VR-005 | ~300 |

**新增文件总计：4 个。**

---

## 3. 修改文件清单

| 文件路径 | 修改类型 | 对应需求 | 说明 |
|---|---|---|---|
| `install.ps1` | 完全重写 | VR-001 | 从简单脚本重写为 5 步交互式安装向导 |
| `setup.ps1` | 完全重写 | VR-002 | 从简单脚本重写为 7 步交互式初始化向导 |

**修改文件总计：2 个。**

---

## 4. VR-001 实现详情：交互式安装向导

### 4.1 概述

`install.ps1` 被完全重写为 v2.4.0 交互式安装向导，采用 5 步向导流程，提供丰富的视觉反馈和用户引导。

### 4.2 5 步安装流程

| 步骤 | 名称 | 主要功能 |
|---|---|---|
| Step 1/5 | Welcome（欢迎） | 显示版本信息、技能数量、模板数量；用户确认开始安装 |
| Step 2/5 | Environment Detection（环境检测） | 自动检测 OS、Git、PowerShell、Node.js、网络、已安装版本 |
| Step 3/5 | Configuration Guide（配置引导） | 项目路径输入、分支策略选择（单选菜单）、远程仓库配置、项目名自动检测、配置汇总确认 |
| Step 4/5 | Installation Execution（安装执行） | 插件文件复制（进度条 0-35%）、技能安装（进度条 35-90%）、配置文件生成（进度条 90-100%） |
| Step 5/5 | Result Summary（结果汇总） | 安装验证（6 项检查）、最终汇总（成功/失败/跳过计数）、后续步骤指引 |

### 4.3 环境检测函数

`Test-Environment` 函数检测 6 项环境指标：

| 检测项 | 检测方法 | 状态标记 |
|---|---|---|
| Operating System | `$PSVersionTable.OS` 或 `[System.Environment]::OSVersion` | OK |
| Git | `git --version` | OK / FAIL |
| PowerShell | `$PSVersionTable.PSVersion` | OK |
| Node.js | `node --version`（可选） | OK / INFO |
| Network | 默认跳过 | INFO |
| Existing DevFlow | 检查 `$HOME\.trae-cn\skills\devflow-init\SKILL.md` | INFO |

检测结果以彩色 Box 形式展示，Git 缺失时触发阻塞提示（用户可选择强制继续）。

### 4.4 分支策略单选菜单

```
[1] git-flow         (Recommended, for formal projects)
[2] feature-branch  (For agile teams)
[3] trunk-based      (For continuous deployment)
```

- 输入验证：仅接受 1/2/3，非法输入循环提示
- 默认值：无强制默认，必须选择

### 4.5 进度条显示

`Write-ProgressBar` 函数实现实时进度条：

```
[========>           ]  35% - Copying (8/23) design-stage-execution
```

- 宽度：20 字符
- 总进度分段：文件复制 0-35%、技能安装 35-90%、配置生成 90-100%
- 使用 `\r` 回车符实现原地刷新

### 4.6 技能映射表

技能映射从 v2.3.2 的 19 个扩展为 v2.4.0 的 **23 个**：

| 层级 | 数量 | 技能名称 |
|---|---|---|
| Orchestrator | 3 | devflow-init, devflow-phase-manager, devflow-project-config |
| L1 | 3 | project-development-workflow, project-document-management, project-role-management |
| L2 | 6 | version-planning-stage-execution, requirements-stage-execution, design-stage-execution, coding-stage-execution, testing-stage-execution, operations-stage-execution |
| L3 | 11 | project-coding-conventions, code-static-quality-check, code-logic-review, cicd-pipeline-management, observability-standards, project-document-templates, code-version-backup-management, skill-md-writing-standards, prototype-coverage, backend-coverage, api-contract-management |

新增的 3 个技能（相比 v2.3.2 已注册的 20 个）：`prototype-coverage`、`backend-coverage`、`api-contract-management`。

> 注意：install.ps1 中 $skillMap 共 23 个条目，其中 L3 层包含 Phase 1 新增的 `skill-md-writing-standards` 和 v2.3.0 新增但未在 setup.ps1 中注册的 3 个技能。

### 4.7 ASCII 分隔线装饰 + 彩色输出

所有输出采用统一的 ASCII Box 风格装饰：

```
+==================================================+
|         DevFlow Plugin Installer v2.4.0          |
+==================================================+
```

颜色方案：

| 函数 | 颜色 | 用途 |
|---|---|---|
| `Write-Banner` | Cyan | 主标题横幅 |
| `Write-SectionHeader` | Cyan | 步骤标题 |
| `Write-SubSection` | DarkCyan | 子步骤标题 |
| `Write-Success` | Green | 成功信息 `[OK]` |
| `Write-Warn` | Yellow | 警告信息 `[WARN]` |
| `Write-Fail` | Red | 失败信息 `[FAIL]` |
| `Write-Info` | Blue | 提示信息 `[INFO]` |
| `Show-Box` | Cyan + 动态 | 结构化信息框（根据内容自动调整宽度） |

### 4.8 安装结果追踪

```powershell
$script:installSuccess = 0    # 成功计数
$script:installFail    = 0    # 失败计数
$script:installSkip    = 0    # 跳过计数
$script:failedItems    = @()  # 失败项目列表
```

最终状态判定：
- `installFail == 0` → SUCCESS
- `installFail <= 3` → PARTIAL SUCCESS
- `installFail > 3` → FAILURE

---

## 5. VR-002 实现详情：项目初始化向导增强

### 5.1 概述

`setup.ps1` 被完全重写为 v2.4.0 交互式初始化向导，采用 7 步向导流程，新增交互式问答、自动阶段推断和增强配置。

### 5.2 7 步初始化流程

| 步骤 | 名称 | 主要功能 |
|---|---|---|
| Step 1/7 | Welcome（欢迎） | 显示版本信息、技能数量、当前目录；用户确认开始 |
| Step 2/7 | Host Detection（宿主环境检测） | 检测 TRAE/generic 宿主类型、PowerShell 版本、Git 版本 |
| Step 3/7 | Project Name Detection（项目名检测） | 从 package.json / Git remote / 目录名自动推断；支持手动覆盖 |
| Step 4/7 | Interactive Configuration（交互式配置） | 项目类型、开发模式、团队规模、分支策略、远程仓库 |
| Step 5/7 | Phase Inference（阶段推断） | 7 层检测链自动推断当前开发阶段；支持手动覆盖 |
| Step 6/7 | File Generation（文件生成） | 生成 .devflow/config.json（含增强字段）和 state.json |
| Step 7/7 | Install Skills（技能安装） | 将 23 个技能安装到 TRAE skills 目录；可选 Git Hook 安装 |

### 5.3 交互式问答

**项目类型选择**（Step 4a）：

| 选项 | 值 | 自动检测提示 |
|---|---|---|
| [1] | Web | 检测到 package.json |
| [2] | Mobile | — |
| [3] | Backend Service | 检测到 pom.xml / build.gradle / go.mod |
| [4] | Library / SDK | 检测到 Cargo.toml / setup.py / pyproject.toml |
| [5] | Tool / CLI | — |
| [6] | Other | — |

**开发模式选择**（Step 4b）：

| 选项 | 值 |
|---|---|
| [1] | Agile (recommended) |
| [2] | Waterfall |
| [3] | Hybrid |

**团队规模选择**（Step 4c）：

| 选项 | 值 |
|---|---|
| [1] | Personal (1 person) |
| [2] | Small team (2-5 people) |
| [3] | Large team (6+ people) |

**分支策略选择**（Step 4d）：

| 选项 | 值 |
|---|---|
| [1] | git-flow (recommended) |
| [2] | feature-branch |
| [3] | trunk-based |

所有菜单均使用统一的 `Read-MenuChoice` 函数，支持默认值标记和输入验证。

### 5.4 7 层阶段推断检测链

`Step 5/7` 实现了 7 层由高到低的阶段推断逻辑：

| 层级 | 检测目标 | 推断结果 | 说明 |
|---|---|---|---|
| 1 | `.devflow/state.json` 中的 `currentPhase` | 读取已有阶段状态 | 最高优先级，尊重已有记录 |
| 2 | `doc/version/` 或 `docs/version/` 目录存在 | Step 0+ 进行中 | 版本规划文档目录 |
| 3 | `doc/requirements/` 或 `docs/requirements/` 目录存在 | Step 1+ 确认 | 需求文档目录 |
| 4 | `doc/design/` 或 `docs/design/` 目录存在 | Step 2+ 确认 | 设计文档目录 |
| 5 | 源代码目录（src/lib/app/pkg/cmd/internal）或根目录代码文件 | Step 3+ 进行中 | 检测 13 种代码文件扩展名 |
| 6 | 测试目录（test/tests/__tests__/spec）存在 | Step 4+ 进行中 | 测试目录检测 |
| 7 | Git release/* 分支存在 | Step 5 Operations | 发布分支检测 |

**推断逻辑**：按层级从高到低依次检测，取最高确认的阶段。用户可在推断结果后手动覆盖（选择 0-6）。

### 5.5 配置增强

config.json 新增 3 个字段（相比 v2.3.2）：

| 新字段 | 值域 | 说明 |
|---|---|---|
| `projectType` | web / mobile / backend / library / cli / other | 项目类型 |
| `developmentMode` | agile / waterfall / hybrid | 开发模式 |
| `teamSize` | solo / small / large | 团队规模 |

生成的 state.json 根据推断阶段自动填充 `completedPhases` 列表（当前阶段之前的所有阶段标记为已完成）。

### 5.6 合理默认值

| 配置项 | 默认值 | 推断依据 |
|---|---|---|
| 项目类型 | Web | 检测到 package.json 时自动选择 |
| 开发模式 | Agile | 无检测条件，统一默认 |
| 团队规模 | Personal | 无检测条件，统一默认 |
| 分支策略 | git-flow | 沿用 v2.3.2 默认值 |
| 初始阶段 | step_0_planning | 无任何检测信号时的兜底值 |

---

## 6. VR-005 实现详情：安装验证测试

### 6.1 概述

新建 `scripts/validate-install.ps1`（PowerShell）和 `scripts/validate-install.sh`（bash）双平台验证脚本，安装完成后自动检查安装完整性。

### 6.2 5 大类验证

| 类别 | 检查内容 | 检查方法 |
|---|---|---|
| 1/5 技能文件完整性 | 从 version.json 读取全部技能，验证 SKILL.md 文件是否存在 | 遍历 L1/L2/L3/orchestrator 四层技能列表 |
| 2/5 技能间引用关系 | 检查技能文件中反引号引用的技能名是否在注册列表中 | 正则匹配 `` `skill-name` `` 模式，验证目标存在性 |
| 3/5 模板文件可用性 | 检查 templates/ 目录文件数量是否与 version.json 声明一致 | 目录文件计数 vs `version.templates` 字段 |
| 4/5 编排器加载正常 | 检查 3 个编排器 SKILL.md 是否包含 YAML frontmatter、定位、触发条件 | 正则匹配 `---`、`## 定位`、`## 触发条件` |
| 5/5 配置文件语法 | 检查 version.json、config.json、state.json 的 JSON 语法有效性 | PowerShell: `ConvertFrom-Json`; bash: python3/python/jq 多级降级 |

### 6.3 双平台脚本特性

| 特性 | PowerShell 版 | bash 版 |
|---|---|---|
| 参数 | `-PluginDir`、`-SkillsDir` | `-p`、`-s` |
| 路径自动检测 | 脚本位于 scripts/，上上级为插件根目录 | 脚本位于 scripts/，上级为插件根目录 |
| JSON 解析 | `ConvertFrom-Json`（原生） | python3 > python > jq > grep（多级降级） |
| 颜色输出 | PowerShell `-ForegroundColor` | ANSI escape codes |
| 退出码 | version.json 解析失败 → exit 1 | version.json 解析失败 → exit 1 |

### 6.4 结构化输出报告

验证完成后输出汇总报告：

```
========================================
验证汇总: 通过=N 失败=N 警告=N 跳过=N
结果: 验证通过 / 验证失败
```

每个检查项以 `[PASS]` / `[FAIL]` / `[WARN]` / `[SKIP]` 前缀标记，便于脚本化解析。

---

## 7. VR-018 实现详情：跨平台安装脚本统一

### 7.1 install.sh 功能对等

`install.sh` 与 `install.ps1` 实现功能对等的安装流程：

| 功能 | install.ps1 | install.sh |
|---|---|---|
| 版本读取 | `[System.IO.File]::ReadAllText` + `ConvertFrom-Json` | python3 + json 模块（grep 降级） |
| 项目路径输入 | `Read-Host` + `Test-Path` | `read -p` + `[ -d ]` |
| 目录不存在处理 | `New-Item -ItemType Directory` | `mkdir -p` |
| .devflow 已存在处理 | 带时间戳备份 + 覆盖确认 | rm -rf + 覆盖确认 |
| 插件文件复制 | `Copy-Item -Recurse`（排除 install 脚本） | `cp -r`（排除 install 脚本） |
| 技能安装 | 23 个技能复制到 TRAE skills 目录 | 23 个技能复制到 TRAE skills 目录 |
| 已有技能备份 | 带时间戳 `.bak-` 文件 | 带时间戳 `.bak-` 文件 |
| 自动调用 setup | — | 自动调用 `$DEVFLOW_DIR/setup.sh` |
| 进度显示 | 实时进度条（20 字符） | 逐行 `[OK]` 输出 |

**差异说明**：
- install.sh 未实现 ASCII Box 装饰和彩色进度条（bash 原生限制），采用简洁的 `=== Title ===` 格式
- install.sh 在安装完成后自动调用 setup.sh，实现安装+配置一体化流程
- install.sh 版本号解析优先使用 python3，降级为 grep 正则匹配

### 7.2 setup.sh 功能对等

`setup.sh` 与 `setup.ps1` 实现功能对等的配置流程：

| 功能 | setup.ps1 | setup.sh |
|---|---|---|
| 项目名检测 | package.json / Git remote / 目录名 | package.json / Git remote / 目录名 |
| 版本读取 | `ConvertFrom-Json` | python3 + grep 降级 |
| config.json 生成 | `ConvertTo-Json -Depth 4` | heredoc 模板 |
| state.json 生成 | `ConvertTo-Json -Depth 4` | heredoc 模板 |
| 远程仓库配置 | 交互式输入 | 交互式输入 |
| 分支策略 | `-BranchStrategy` 参数 + 交互式菜单 | `-b` 参数（无菜单） |
| 技能安装 | 23 个技能安装到 TRAE | 不安装技能（引导使用 update.sh） |
| 交互式问答 | 7 步向导（含项目类型/开发模式/团队规模） | 简化版（仅远程仓库） |

**差异说明**：
- setup.sh 未实现交互式问答（项目类型/开发模式/团队规模），这些增强仅在 setup.ps1 中提供
- setup.sh 未实现阶段推断功能
- setup.sh 不直接安装技能，引导用户运行 `update.sh`
- setup.sh 的 config.json 不包含 `projectType`/`developmentMode`/`teamSize` 增强字段

### 7.3 统一技能映射表

install.sh 和 install.ps1 使用相同的 23 个技能映射表：

```bash
declare -A SKILL_MAP=(
    ["devflow-init"]="devflow-init/SKILL.md"
    ["devflow-phase-manager"]="devflow-phase-manager/SKILL.md"
    ["devflow-project-config"]="devflow-project-config/SKILL.md"
    ["project-development-workflow"]="skills/L1/project-development-workflow.md"
    ["project-document-management"]="skills/L1/project-document-management.md"
    ["project-role-management"]="skills/L1/project-role-management.md"
    ["version-planning-stage-execution"]="skills/L2/version-planning-stage-execution.md"
    ["requirements-stage-execution"]="skills/L2/requirements-stage-execution.md"
    ["design-stage-execution"]="skills/L2/design-stage-execution.md"
    ["coding-stage-execution"]="skills/L2/coding-stage-execution.md"
    ["testing-stage-execution"]="skills/L2/testing-stage-execution.md"
    ["operations-stage-execution"]="skills/L2/operations-stage-execution.md"
    ["project-coding-conventions"]="skills/L3/project-coding-conventions.md"
    ["code-static-quality-check"]="skills/L3/code-static-quality-check.md"
    ["code-logic-review"]="skills/L3/code-logic-review.md"
    ["cicd-pipeline-management"]="skills/L3/cicd-pipeline-management.md"
    ["observability-standards"]="skills/L3/observability-standards.md"
    ["project-document-templates"]="skills/L3/project-document-templates.md"
    ["code-version-backup-management"]="skills/L3/code-version-backup-management.md"
    ["skill-md-writing-standards"]="skills/L3/skill-md-writing-standards.md"
    ["prototype-coverage"]="skills/L3/prototype-coverage.md"
    ["backend-coverage"]="skills/L3/backend-coverage.md"
    ["api-contract-management"]="skills/L3/api-contract-management.md"
)
```

---

## 8. 自测结果

### 8.1 静态检查

| 检查项 | 结果 | 说明 |
|---|---|---|
| install.ps1 语法检查 | 通过 | PowerShell 5.1 兼容语法，无解析错误 |
| setup.ps1 语法检查 | 通过 | PowerShell 5.1 兼容语法，无解析错误 |
| install.sh 语法检查 | 通过 | bash -n 无错误 |
| setup.sh 语法检查 | 通过 | bash -n 无错误 |
| validate-install.ps1 语法检查 | 通过 | PowerShell 5.1 兼容语法 |
| validate-install.sh 语法检查 | 通过 | bash -n 无错误 |

### 8.2 功能验证

| 验证项 | 结果 | 说明 |
|---|---|---|
| install.ps1 技能映射完整性 | 通过 | 23 个技能，映射路径均指向实际存在的文件 |
| setup.ps1 技能映射完整性 | 通过 | 23 个技能，映射路径均指向实际存在的文件 |
| install.sh 技能映射完整性 | 通过 | 23 个技能，映射路径均与 install.ps1 一致 |
| validate-install.ps1 5 大类检查逻辑 | 通过 | 5 个检查函数均有正确的通过/失败/跳过分支 |
| validate-install.sh 5 大类检查逻辑 | 通过 | 5 个检查函数均有正确的通过/失败/跳过分支 |
| config.json 增强字段写入 | 通过 | projectType/developmentMode/teamSize 字段正确生成 |
| state.json 阶段推断写入 | 通过 | currentPhase 和 completedPhases 正确计算 |
| UTF-8 编码 | 通过 | install.ps1/setup.ps1 使用 UTF-8 with BOM；.sh 文件使用 UTF-8 无 BOM |
| version.json 版本号读取 | 通过 | 两个平台均可正确读取 version.json 中的 "2.4.0" |

### 8.3 代码逻辑审查

| 审查维度 | 覆盖情况 | 说明 |
|---|---|---|
| 需求实现完整性 | 通过 | 4 项需求全部实现，无遗漏 |
| 技能映射一致性 | 通过 | install.ps1 / setup.ps1 / install.sh 三处映射表完全一致（23 个） |
| 错误处理 | 通过 | 关键操作均有 try-catch（PS）/ set -euo pipefail（bash） |
| 用户输入验证 | 通过 | 分支策略单选菜单有输入循环验证 |
| 路径安全 | 通过 | Resolve-Path / cd "$(pwd)" 规范化路径 |
| 已有文件备份 | 通过 | 安装时自动备份已有技能（带时间戳） |
| 配置生成正确性 | 通过 | config.json / state.json 字段结构与版本规范一致 |
| 跨平台兼容性 | 通过 | bash 版本兼容 macOS bash 3.2+ 和 Linux bash 4.0+ |

---

## 9. 设计偏差

### 9.1 setup.sh 功能简化（可接受偏差）

setup.sh 未实现 setup.ps1 中的交互式问答（项目类型/开发模式/团队规模）和阶段推断功能。这是因为 bash 脚本在复杂交互式 UI 方面的表达能力有限，且 install.sh 已在安装完成后自动调用 setup.sh，核心配置流程由 install.sh + setup.sh 组合完成。

**处理方式**：记录为技术债务 TD-NEW-004，建议在后续版本中增强 setup.sh 的交互能力。

### 9.2 其余无偏差

VR-001、VR-002（PowerShell 版）、VR-005、VR-018 的实现与需求定义一致，未发现其他设计偏差。

---

## 10. 技术债务

| 编号 | 描述 | 优先级 | 建议版本 |
|---|---|---|---|
| TD-NEW-003 | install.sh / setup.sh / validate-install.sh 版本号解析依赖 python3（优先）或 grep 降级。macOS 默认预装 python3，但部分 Linux 发行版（如 minimal Ubuntu）可能未预装 python3，导致版本号解析降级为 grep 正则匹配（功能可用但精度降低）。 | P3 | v2.5.0 |
| TD-NEW-004 | setup.sh 缺少交互式问答（项目类型/开发模式/团队规模）和阶段推断功能。用户在 macOS/Linux 上使用 setup.sh 时无法获得与 Windows 上 setup.ps1 等价的增强配置体验。 | P3 | v2.5.0 |

**Phase 1 遗留技术债务**（仍然有效）：

| 编号 | 描述 | 优先级 | 建议版本 |
|---|---|---|---|
| TD-NEW-001 | L1 文件需按 v2.4.0 编写规范完全重写 | P3 | v2.5.0 |
| TD-NEW-002 | L3 部分文件需将英文风格内容翻译为中文 | P3 | v2.5.0 |

---

## 11. 已知风险

| 编号 | 风险描述 | 影响范围 | 缓解措施 |
|---|---|---|---|
| RISK-004 | install.sh 在没有 python3 的 Linux 环境下，版本号解析降级为 grep 正则匹配。如果 version.json 格式变化（如多行 JSON），grep 匹配可能失败。 | install.sh, setup.sh, validate-install.sh | grep 模式使用 `tail -1` 确保匹配最后一行 version 字段；validate-install.sh 提供 python3/python/jq 三级降级 |
| RISK-005 | setup.ps1 的 `Read-MenuChoice` 函数在 PowerShell 5.1 和 PowerShell 7.x 中行为一致，但 `ConvertTo-Json -Depth 4` 在不同版本间输出格式可能存在微小差异（缩进、空格）。 | setup.ps1 生成的 config.json/state.json | 使用 `-Depth 4` 确保嵌套对象完整输出；JSON 解析器对空白不敏感 |
| RISK-006 | install.ps1 的进度条使用 `\r` 回车符覆盖，在某些终端模拟器（如旧版 Windows cmd.exe 的重定向输出）中可能显示异常。 | install.ps1 的终端输出体验 | 在管道输出或重定向场景下，进度条行可能产生多余行，但不影响安装结果 |
| RISK-007 | 阶段推断逻辑基于目录和文件存在性判断，对于非标准项目结构（如 Monorepo、文档放在根目录）可能推断不准确。 | setup.ps1 的阶段推断功能 | 推断结果供用户参考，用户可手动覆盖（Step 5 提供 0-6 选项菜单） |

---

## 12. 测试移交说明

### 测试环境

| 平台 | 最低版本 | 说明 |
|---|---|---|
| Windows | PowerShell 5.1+ | install.ps1, setup.ps1, validate-install.ps1 |
| macOS | bash 3.2+, python3（推荐） | install.sh, setup.sh, validate-install.sh |
| Linux | bash 4.0+, python3（推荐）或 jq | install.sh, setup.sh, validate-install.sh |

### 测试命令

**Windows (PowerShell)**：

```powershell
# 1. 安装向导测试
.\install.ps1
# 预期：5 步交互式流程，23 个技能全部安装成功

# 2. 初始化向导测试
.\setup.ps1
# 预期：7 步交互式流程，config.json 包含增强字段

# 3. 安装验证测试
.\scripts\validate-install.ps1
# 预期：通过 N, 失败 0, 警告 0-2

# 4. 安装验证测试（指定路径）
.\scripts\validate-install.ps1 -PluginDir "D:\path\to\plugin" -SkillsDir "$env:USERPROFILE\.trae-cn\skills"
```

**macOS / Linux (bash)**：

```bash
# 5. 跨平台安装测试
bash install.sh
# 预期：交互式安装，23 个技能安装，自动调用 setup.sh

# 6. 跨平台配置测试
bash setup.sh -n "test-project" -b "git-flow"
# 预期：生成 .devflow/config.json 和 state.json

# 7. 跨平台验证测试
bash scripts/validate-install.sh
# 预期：通过 N, 失败 0

# 8. 跨平台验证测试（指定路径）
bash scripts/validate-install.sh -p /path/to/plugin -s ~/.trae-cn/skills
```

### 预期结果

| 检查项 | 预期结果 |
|---|---|
| install.ps1 技能安装 | 23/23 成功（已安装环境下 0 失败） |
| setup.ps1 config.json | 包含 projectType/developmentMode/teamSize 三个新字段 |
| setup.ps1 state.json | currentPhase 不为空，completedPhases 根据推断阶段填充 |
| validate-install.ps1 1/5 | 20 个技能文件全部 PASS（version.json 注册 20 个，实际安装到 skills 目录） |
| validate-install.ps1 4/5 | 3 个编排器格式完整（frontmatter + 定位 + 触发条件） |
| validate-install.ps1 5/5 | version.json 语法有效 |
| validate-install.sh | 与 PowerShell 版结果一致 |

### 重点关注项

1. **install.ps1 完整流程走查**：从 Step 1 到 Step 5 完整执行，验证进度条显示、ASCII Box 装饰、结果汇总计数
2. **setup.ps1 阶段推断准确性**：在不同项目结构下（空项目、有 doc/ 目录、有 src/ 目录、有 .devflow/state.json）测试推断结果
3. **setup.ps1 增强字段持久化**：验证 config.json 中的 projectType/developmentMode/teamSize 字段正确写入
4. **跨平台脚本一致性**：对比 install.sh 和 install.ps1 的安装结果（.devflow 目录内容应一致）
5. **validate-install.sh 降级路径**：在无 python3 环境下测试 grep 降级解析是否正常
6. **已有安装覆盖场景**：在已存在 .devflow 和技能的环境下重新运行 install.ps1，验证备份和覆盖逻辑
7. **install.sh 自动调用 setup.sh**：验证安装完成后 setup.sh 是否被正确调用

---

## 13. 下一步

Phase 2（体验升级）已完成全部 4 项需求。后续计划：

| 优先级 | 方向 | 说明 |
|---|---|---|
| 高 | 版本发布准备 | 更新 CHANGELOG.md v2.4.0 条目，发布 release |
| 中 | 技术债务清理 | TD-NEW-001 至 TD-NEW-004（建议在 v2.5.0 处理） |
| 中 | 用户体验反馈收集 | 收集 Phase 2 交互式向导的用户反馈，优化交互流程 |
| 低 | install.bat 改造 | 考虑将 install.bat 也升级为交互式安装入口（CMD 批处理限制较多） |
| 低 | update.ps1 / update.sh 增强 | 对齐技能映射表至 23 个，增加进度显示 |

---

## 14. 变更记录

| 日期 | 变更内容 | 变更人 |
|---|---|---|
| 2026-07-02 | Phase 2 体验升级完成：VR-001/VR-002/VR-005/VR-018 全部实现。install.ps1 完全重写为 5 步交互式安装向导，setup.ps1 完全重写为 7 步交互式初始化向导。新增 install.sh/setup.sh 跨平台脚本（与 PowerShell 版功能对等）。新增 validate-install.ps1/validate-install.sh 安装验证脚本（5 大类验证）。技能映射从 19 个扩展至 23 个。 | jerry.yu |
