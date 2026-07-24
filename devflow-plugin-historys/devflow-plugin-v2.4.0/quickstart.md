# DevFlow 快速入门指南

## 概述

DevFlow 是一套软件开发工程规范插件，为 AI 编程助手（TRAE IDE、Claude Code、Cursor、Codex CLI）提供 6 阶段工程管控能力。通过技能文件（.md）和文档模板，引导 AI 助手按照标准流程执行版本规划、需求分析、架构设计、编码实现、测试和部署运维。

本指南内容涵盖 DevFlow **全部版本**的整体使用指导，并详细说明 **v2.4.0 当前版本**的新增功能和用法。无论是初次使用的新用户，还是从旧版本升级的老用户，都可以找到所需的操作指引。

---

## 一、版本历史总览

DevFlow 从 v2.0.0 初始版本发展到 v2.4.0，历经 6 个版本迭代，技能体系从 15 个扩展到 26 个，模板从 18 个扩展到 24 个。

### 版本进化路线

```
v2.0.0 ──── v2.1.0 ──── v2.3.0 ──── v2.3.1 ──── v2.3.2 ──── v2.4.0 (当前)
2026-06-24  2026-06-26  2026-06-29  2026-07-01  2026-07-02  2026-07-03
初始版本     插件化架构   前端/后端/API  完整回滚    版本号/编码   全面迭代
                         契约覆盖      设计体系     修复         安全+容器化
```

### 版本特性对比表

| 版本 | 技能数 | L3 | 模板 | 核心方向 | 使用建议 |
|------|--------|-----|------|----------|----------|
| v2.0.0 | ~15 | — | ~18 | 初始 6 阶段流程 | ⚠️ 已归档，建议升级 |
| v2.1.0 | 16 | 7 | 19 | 插件化架构、三层技能分层 | ⚠️ 基础版本，建议升级 |
| v2.3.0 | 22 | 10 | 19 | 前端原型、后端设计、API 契约 | ✅ 可用（无回滚扩展） |
| v2.3.1 | 22 | 10 | 19 | 完整回滚设计体系 | ✅ 可用（推荐） |
| v2.3.2 | 22 | 10 | 19 | 版本号 SSOT、UTF-8 修复 | ✅ 可用（推荐，稳定版） |
| **v2.4.0** | **26** | **14** | **24** | **安全+容器化+质量统一** | **✅ 当前最新版（推荐）** |

### 各版本功能要点

**v2.0.0 — 初始版本**（2026-06-24）
- 6 阶段工程管控流程（Step 0-5）
- 需求→设计→开发→测试全链路追溯（RT-ID / DT-ID / TD-ID）
- 审计门禁机制和 TDD 铁律

**v2.1.0 — 插件化架构**（2026-06-26）
- 三层技能架构（L1 总控 / L2 阶段执行 / L3 专项参考）
- 3 个 Orchestrator 编排技能（devflow-init / devflow-phase-manager / devflow-project-config）
- 编译层模式（L2 内联 L3 速查表，运行时深度 2 层）
- 18 个标准文档模板
- setup.ps1 / setup.sh 安装脚本

**v2.3.0 — 工程能力扩展**（2026-06-29）
- 新增 prototype-coverage（前端原型覆盖率 7 步流程）
- 新增 backend-coverage（后端设计覆盖率 5 步流程）
- 新增 api-contract-management（API 契约对齐检查）
- 技能总数从 15 个增到 22 个

**v2.3.1 — 完整回滚设计体系**（2026-07-01）
- code-version-backup-management 扩展为 10 节（代码/数据/配置/服务回滚）
- cicd-pipeline-management 新增回滚自动化章节
- 蓝绿部署、金丝雀发布、K8s 滚动更新的回滚路径

**v2.3.2 — 补丁修复**（2026-07-02）
- 修复 version.json 版本号 SSOT 问题
- 修复 PowerShell UTF-8 编码乱码问题
- 新增 install.bat 安装脚本
- **建议：v2.3.x 用户应升级到此版本**

**v2.4.0 — 当前版本**（2026-07-03 编码完成）
- 新增 4 个 L3 技能：skill-md-writing-standards、security-design-review、secure-coding-practices、container-deployment
- 新增 5 个 DR 容灾备份模板
- 新增 quickstart.html 快速入门 HTML 版
- 交互式安装向导（install.ps1/sh）
- 交互式初始化向导（setup.ps1/sh）
- 安装验证脚本（validate-install.ps1/sh）
- 格式检查脚本（check-skill-format.ps1）
- 引用检查脚本（check-references.ps1/sh）
- Claude Code / Cursor / Codex CLI 兼容性验证清单
- 技能总体：26 个（3 L1 + 6 L2 + 14 L3 + 3 Orchestrator）
- 模板总数：24 个

### 升级路线建议

```
v2.0.0 ──→ v2.1.0 ──→ v2.3.0 ──→ v2.3.1 ──→ v2.3.2 ──→ v2.4.0 (推荐)
 旧版     插件化      工程扩展     回滚体系     稳定版      当前最新
```

---

## 二、Windows 系统启动流程

### 方式一：通过 TRAE IDE 使用（推荐）

TRAE IDE 是 DevFlow 在 Windows 上的原生开发平台。

**第 1 步：安装 DevFlow（所有版本通用）**
- 在文件管理器中找到 DevFlow 插件目录
- **v2.3.2 及以上**：双击 `install.bat`（推荐），或右键 `install.ps1` → "使用 PowerShell 运行"
- **v2.1.0 / v2.3.0 / v2.3.1**：右键 `install.ps1` → "使用 PowerShell 运行"
- **v2.0.0**：手动将技能文件夹复制到项目根目录
- 等待终端显示 `[OK] Installation completed!` 提示

**第 2 步：打开 TRAE IDE**
- 点击 Windows "开始"菜单 → 搜索 "TRAE" → 点击打开
- 或双击桌面上的 TRAE IDE 快捷方式
- 打开你的项目文件夹（文件 → 打开文件夹）

**第 3 步：打开 AI 对话窗口**
- 按 `Ctrl + K` 打开内联对话（Inline Chat）
- 或按 `Ctrl + Shift + I` 打开侧边对话面板（Chat Panel）
- 或按 `Ctrl + I` 打开独立对话窗口

**第 4 步：开始使用 DevFlow 流程**

在 AI 对话输入框中输入启动命令（所有版本通用）：
```
Use Skill: version-planning-stage-execution 开始 v1.0.0 版本规划
```

AI 助手会自动加载 DevFlow 技能，引导你完成第 1 个版本的规划。

### 方式二：通过命令行终端使用

如果仅需要执行 DevFlow 脚本（安装/初始化/验证），可以直接在终端中运行：

| 操作 | v2.3.2 及以上 | v2.1.0 ~ v2.3.1 | v2.0.0 |
|------|---------------|------------------|--------|
| 安装 | `install.bat` 或 `ps1` | `powershell -File install.ps1` | 手动复制 |
| 项目初始化 | `powershell -File setup.ps1` | `powershell -File setup.ps1` | — |
| 验证安装 | `powershell -File scripts/validate-install.ps1` | — | — |
| 格式检查 | `powershell -File scripts/check-skill-format.ps1` | — | — |
| 引用检查 | `powershell -File scripts/check-references.ps1` | — | — |
| 更新 | `powershell -File update.ps1` | `powershell -File update.ps1` | — |

**如何打开 PowerShell 终端：**
- 在项目文件夹中：按住 `Shift` 键 + 右键单击空白处 → "在此处打开 PowerShell 窗口"
- 或在 TRAE IDE 中：按 `` Ctrl + ` `` 打开内置终端
- 或在开始菜单中：搜索 "PowerShell" → 打开后 `cd` 到项目目录

### 常见问题（Windows）

> **Q:** 提示"无法加载文件 xxx.ps1，因为在此系统上禁止运行脚本"
> **A:** 以管理员身份运行 PowerShell，执行：`Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

> **Q:** 双击 install.bat 后窗口一闪而过
> **A:** 右键 install.bat → "以管理员身份运行"

> **Q:** 找不到 TRAE IDE
> **A:** 从 TRAE 官网下载并安装，或使用 Claude Code / Cursor 替代

> **Q:** `Use Skill:` 命令没有效果
> **A:** 确保已在项目根目录下执行过安装操作，技能文件存在于 `skills/` 目录中。检查 version.json 中的版本号是否与插件版本匹配

---

## 三、安装 DevFlow（~1 分钟）

### v2.4.0（当前版本）

**Windows 操作**：
- 推荐：双击 `install.bat`（自动调用 PowerShell 安装）
- 或右键 `install.ps1` → "使用 PowerShell 运行"
- 或 `powershell -ExecutionPolicy Bypass -File install.ps1`

**macOS/Linux 操作**：
- `bash install.sh`

**新增 v2.4.0 交互式安装特性**：
- 5 步安装向导（检查依赖 → 选择分支策略 → 选择备份方式 → 等待安装 → 安装完成）
- ASCII 动画进度条（完全兼容 PowerShell 5.1，无需 ANSI 转义）
- 自动检测 Git、PowerShell 5.1+、Node.js / Python3 等依赖

**预期输出**：
- 终端显示 ASCII 风格安装进度条
- 输出 `[OK] Installation completed!` 提示
- 26 个技能文件 + 24 个文档模板部署到项目 `skills/` 和 `templates/` 目录

**验证安装**：
- Windows：运行 `powershell -File scripts/validate-install.ps1`
- macOS/Linux：运行 `bash scripts/validate-install.sh`
- v2.4.0 新增 6 项验证：技能文件存在性、模板文件完整性、脚本可执行性、version.json 一致性、编码正确性、跨平台脚本对称性

### v2.3.2（稳定版）

- Windows：`install.ps1`（已修复 UTF-8 编码问题）
- 新增 `install.bat` 双击安装
- macOS/Linux：`bash install.sh`
- 安装后验证：手动检查 `skills/` 目录文件完整性（22 个技能）

### v2.3.0 ~ v2.3.1

- Windows：`powershell -ExecutionPolicy Bypass -File install.ps1`
- macOS/Linux：`bash install.sh`
- 注意：此版本 `install.ps1` 使用 `Get-Content` 读取 UTF-8 文件可能在 PowerShell 5.1 下出现乱码，建议升级到 v2.3.2 或 v2.4.0

### v2.1.0（基础版本）

- Windows：`powershell -ExecutionPolicy Bypass -File install.ps1`
- macOS/Linux：`bash install.sh`
- 技能总数：16 个，模板总数：19 个

### v2.0.0（初始版本）

- 手动操作：将 DevFlow 技能文件夹复制到项目根目录
- 无自动安装脚本

---

## 四、初始化项目（~1 分钟）

### v2.4.0（当前版本）

**操作**：
- 进入你的项目根目录
- Windows：运行 `powershell -File setup.ps1`
- macOS/Linux：运行 `bash setup.sh`

**v2.4.0 新增交互式 Q&A 特性**：
- 项目类型选择：Web / Mobile / Backend / Library / CLI / Other（6 种）
- 开发模式选择：Agile / Waterfall / Hybrid（3 种）
- 团队规模选择：个人（1人）/ 小团队（2-10人）/ 大团队（10+人）
- 分支策略选择：git-flow（推荐）/ feature-branch / trunk-based
- 自动推断 Phase：根据团队规模和敏捷度自动推荐 4-6 个 Phase

**预期输出**：
- `.devflow/config.json` — 项目配置（含分支策略、备份仓库、项目类型）
- `.devflow/state.json` — 项目状态（当前阶段、已完成阶段）

### v2.3.x 版本

- 基本功能相同，但缺少 v2.4.0 的自动 Phase 推断和 6 种项目类型支持
- 项目类型仅支持：Web / CLI / Library（3 种）
- 安装后技能数量为 22 个

### v2.1.0 版本

- 安装后技能数量为 16 个
- 基础配置支持，无项目类型分类

### v2.0.0 版本

- 无 setup.ps1 脚本，需手动创建 `.devflow/config.json`

---

## 五、使用 DevFlow 6 阶段流程

### 阶段入口命令速查

以下命令在所有版本中均可使用（v2.0.0 需手动确认技能文件存在）：

| 阶段 | 启动命令 | 适用版本 | 输出文档数 |
|------|----------|----------|----------|
| Step 0: 版本规划 | `Use Skill: version-planning-stage-execution 开始 v1.0.0 版本规划` | 全部 | 9 个 |
| Step 1: 需求分析 | `Use Skill: requirements-stage-execution 开始需求分析` | 全部 | 8 个 |
| Step 2: 架构设计 | `Use Skill: design-stage-execution 开始架构设计` | 全部 | 5 个 |
| Step 3: 编码实现 | `Use Skill: coding-stage-execution 开始编码` | 全部 | DevLogReport + 代码 |
| Step 4: 测试 | `Use Skill: testing-stage-execution 开始测试` | 全部 | 测试报告 |
| Step 5: 部署运维 | `Use Skill: operations-stage-execution 开始部署` | 全部 | 部署运维文档 |

### 第 1 步：版本规划（~1.5 分钟）

**操作**：
- 在 AI 编程助手的对话窗口中输入：
  ```
  Use Skill: version-planning-stage-execution 开始 v1.0.0 版本规划
  ```
- AI 助手引导完成：版本目标定义 → 范围确认 → 优先级排序 → Phase 拆分 → 依赖和风险梳理 → 评审确认

**输出文档**（`doc/version/releases/v1.0.0/` 目录下）：
- `{项目名}-v1.0.0-单版本规划文档.md`
- `{项目名}-v1.0.0-本版本Backlog.md`
- `{项目名}-v1.0.0-Phase迭代计划.md`
- `{项目名}-v1.0.0-版本风险清单.md`
- `{项目名}-v1.0.0-版本依赖清单.md`
- `{项目名}-v1.0.0-版本成功指标说明.md`
- `{项目名}-v1.0.0-版本发布策略草案.md`
- `{项目名}-v1.0.0-版本规划评审记录.md`
- `{项目名}-v1.0.0-版本优先级评估记录.md`（共 9 个）

**关键概念**：
- 版本目标：本版本要达成的业务和技术目标（必须可衡量）
- 包含/不包含范围：明确本版本做什么、不做什么
- P0/P1/P2 优先级：P0=阻塞发布、P1=强烈建议、P2=资源允许
- Phase 拆分：将版本拆分为多个迭代阶段

### 第 2 步：需求分析（~1 分钟）

**操作**：
  ```
  Use Skill: requirements-stage-execution 开始需求分析
  ```

**v2.4.0 新增**：需求分析阶段新增安全需求作为独立维度（配合 security-design-review 技能）

**输出文档**（`doc/requirements/` 目录下）：
- `{项目名}-v1.0.0-开发需求文档.md`
- `{项目名}-v1.0.0-用户需求说明书.md`（含用户场景/用户故事/业务流程）
- `{项目名}-v1.0.0-需求来源与干系人.md`
- `{项目名}-v1.0.0-UIUX需求说明.md`
- `{项目名}-v1.0.0-需求追溯矩阵.md`
- `{项目名}-v1.0.0-需求评审记录.md`
- `{项目名}-v1.0.0-需求基线及设计移交说明.md`
- `{项目名}-v1.0.0-需求评估报告.md`（共 8 个）

### 第 3 步：架构设计（~1 分钟）

**操作**：
  ```
  Use Skill: design-stage-execution 开始架构设计
  ```

**v2.4.0 新增**：设计阶段新增安全设计维度（STRIDE/DREAD 威胁建模）

**输出文档**（`doc/design/` 目录下）：
- `{项目名}-v1.0.0-系统架构设计文档.md`
- `{项目名}-v1.0.0-UI设计文档.md`
- `{项目名}-v1.0.0-非功能设计说明.md`
- `{项目名}-v1.0.0-部署架构草案.md`
- `{项目名}-v1.0.0-设计评审记录.md`（共 5 个）

### 第 4 步：编码实现

**操作**：
  ```
  Use Skill: coding-stage-execution 开始编码
  ```

**v2.4.0 新增**：
- SKILL.md 编写标准和格式检查脚本（`check-skill-format.ps1`）
- 安全编码实践作为 L3 技能（`secure-coding-practices.md`）
- 容器化部署技能（`container-deployment.md`）
- 代码逻辑审查新增 11 维审查维度

### 第 5 步：测试

**操作**：
  ```
  Use Skill: testing-stage-execution 开始测试
  ```

**v2.4.0 新增**：
- 兼容性验证清单（Claude Code / Cursor / Codex CLI）
- 安装验证脚本（`validate-install.ps1/sh`）

### 第 6 步：部署运维

**操作**：
  ```
  Use Skill: operations-stage-execution 开始部署
  ```

**v2.3.1 新增**：
- 完整回滚设计体系（代码/数据/配置/服务四类）
- 回滚审批流程矩阵
- CI/CD 自动回滚 Job 设计

**v2.4.0 新增**：
- 容器化部署技能（`container-deployment.md`，946 行）
- Dockerfile 最佳实践、K8s 部署、容器安全扫描

---

## 六、v2.4.0 新功能使用指南

### 6.1 安全开发全流程

v2.4.0 新增两个安全相关的 L3 技能：

| 技能 | 文件 | 用途 |
|------|------|------|
| 安全设计审查 | `skills/L3/security-design-review.md`（238行） | STRIDE/DREAD 威胁建模、安全架构审查 7 个领域 |
| 安全编码实践 | `skills/L3/secure-coding-practices.md`（301行） | 8 项安全编码通则、JS/TS/Python/Go 语言专项、OWASP Top 10 |

**使用场景**：
```
Use Skill: security-design-review 对当前架构进行安全审查
Use Skill: secure-coding-practices 检查代码中的安全漏洞
```

### 6.2 容器化部署

| 技能 | 文件 | 用途 |
|------|------|------|
| 容器化部署 | `skills/L3/container-deployment.md`（946行） | Dockerfile、Docker Compose、K8s、容器安全、Trivy扫描 |

**使用场景**：
```
Use Skill: container-deployment 为项目配置 Docker 部署
```

### 6.3 容灾备份模板

新增 5 个 DR 模板（`templates/DR-*.md`）：

| 模板 | 用途 |
|------|------|
| DR-灾难恢复预案.md | 6 种灾难场景、RPO/RTO、恢复流程 |
| DR-备份策略配置指南.md | 全量/增量/差异备份频率矩阵 |
| DR-多地域备份方案.md | 主/备/冷三地架构、跨区域同步 |
| DR-数据恢复演练流程.md | 年度演练日历、4 种演练场景 |
| DR-备份完整性校验规范.md | CRC32/MD5/SHA-256校验、PS+Bash脚本 |

### 6.4 快速入门文档

| 文档 | 用途 |
|------|------|
| `quickstart.html` | 单文件 HTML 版（浏览器打开，带交互式 FAQ） |
| `quickstart.md` | Markdown 版（本文档） |

### 6.5 交互式安装/初始化向导

| 脚本 | 版本 | 交互特性 |
|------|------|----------|
| `install.ps1` | v2.4.0 | 5 步向导、ASCII 进度条、依赖检测 |
| `install.sh` | v2.4.0 | bash 版等价功能 |
| `setup.ps1` | v2.4.0 | 6 种项目类型、3 种开发模式、3 种团队规模 |
| `setup.sh` | v2.4.0 | bash 版等价功能 |

### 6.6 质量保障脚本

| 脚本 | 用途 | 使用命令 |
|------|------|----------|
| `scripts/check-skill-format.ps1` | 10 项格式检查 + 自动修复 | `powershell -File scripts/check-skill-format.ps1` |
| `scripts/check-references.ps1` | 5 项交叉引用检查 | `powershell -File scripts/check-references.ps1` |
| `scripts/check-references.sh` | Bash 版等价 | `bash scripts/check-references.sh` |
| `scripts/validate-install.ps1` | 6 项安装验证 | `powershell -File scripts/validate-install.ps1` |
| `scripts/validate-install.sh` | Bash 版等价 | `bash scripts/validate-install.sh` |

---

## 七、从旧版本升级到 v2.4.0

### 升级检查清单

| 检查项 | 说明 |
|--------|------|
| ✅ 备份现有 `.devflow/` 配置 | 备份 `config.json`、`state.json` |
| ✅ 备份自定义技能文件 | 如有自定义 L3 技能，先备份再覆盖 |
| ✅ 运行 install.ps1/sh 安装 | 覆盖安装 v2.4.0（自动备份旧技能） |
| ✅ 运行 validate-install.ps1/sh | 验证全部 6 项检查通过 |
| ✅ 检查 version.json 版本号 | 确认版本号 = 2.4.0 |
| ✅ 运行格式检查 | `check-skill-format.ps1 -fix` 自动修复格式 |
| ✅ 运行引用检查 | `check-references.ps1` 确保交叉引用完整 |

### 各版本升级差异说明

**从 v2.3.2 升级到 v2.4.0**：
- 新增 4 个 L3 技能，3 个安装脚本需更新 skillMap
- 新增 5 个容灾备份模板
- 新增 4 个格式/验证脚本
- 新增 quickstart.html 和 quickstart.md
- 更新 version.json（skills: 22→26, templates: 19→24）

**从 v2.3.1 升级到 v2.4.0**：
- 先升级到 v2.3.2（修复 UTF-8 编码问题）
- 再参考 v2.3.2→v2.4.0 的升级步骤

**从 v2.3.0 升级到 v2.4.0**：
- 先升级到 v2.3.1 再升级到 v2.3.2，或直接安装 v2.4.0

**从 v2.1.0 升级到 v2.4.0**：
- 建议直接全新安装 v2.4.0

---

## 八、完整流程总览

```
Step 0: 版本规划 ───→ 输出 9 个规划文档
  ↓
Step 1: 需求分析 ───→ 输出 8 个需求文档
  ↓
Step 2: 架构设计 ───→ 输出 5 个设计文档
  ↓
Step 3: 编码实现 ───→ 输出 DevLogReport + 代码
  ↓
Step 4: 测试     ───→ 输出测试报告
  ↓
Step 5: 部署运维 ───→ 输出部署和运维文档
```

---

## 九、技能体系速览

| 层级 | v2.4.0 数量 | v2.3.x 数量 | 作用 |
|------|-------------|-------------|------|
| Orchestrator | 3 | 3 | 安装/初始化/项目配置编排 |
| L1 编排层 | 3 | 3 | 工作流/文档管理/角色管理 |
| L2 阶段执行层 | 6 | 6 | 6 个阶段的执行规范 |
| L3 专项参考层 | 14 | 8~10 | 编码约定/质量检查/安全/容器化/备份等 |
| **总计** | **26** | **17~22** | — |

### v2.4.0 L3 技能全表

| 技能 | 引入版本 | 用途 |
|------|----------|------|
| project-coding-conventions | v2.1.0 | 编码约定（分层/错误/日志/API/数据库/并发） |
| code-static-quality-check | v2.1.0 | 12 类检查项、P0/P1/P2/P3 严重级别 |
| code-logic-review | v2.1.0 | 11 维审查维度 |
| cicd-pipeline-management | v2.1.0 | CI/CD 流水线、质量闸门、部署策略 |
| observability-standards | v2.1.0 | 日志/指标/追踪三大支柱 |
| project-document-templates | v2.1.0 | 文档内容模板 |
| code-version-backup-management | v2.1.0 | 分支/提交/版本号/备份/回滚 |
| prototype-coverage | v2.3.0 | 前端原型覆盖率 7 步流程 |
| backend-coverage | v2.3.0 | 后端设计覆盖率 5 步流程 |
| api-contract-management | v2.3.0 | API 契约对齐检查 |
| **skill-md-writing-standards** | **v2.4.0** | **SKILL.md 编写标准、格式检查** |
| **security-design-review** | **v2.4.0** | **STRIDE/DREAD 威胁建模、安全审查** |
| **secure-coding-practices** | **v2.4.0** | **安全编码、OWASP Top 10、语言专项** |
| **container-deployment** | **v2.4.0** | **Docker/K8s 容器化部署** |

---

## 十、进阶使用

| 功能 | v2.4.0 | v2.3.x | v2.1.0 | 说明 |
|------|--------|--------|--------|------|
| 自定义分支策略 | ✅ | ✅ | ✅ | 修改 config.json 的 branchStrategy |
| 格式检查 | ✅ | — | — | `check-skill-format.ps1` |
| 交叉引用检查 | ✅ | — | — | `check-references.ps1/sh` |
| 安装验证 | ✅ | — | — | `validate-install.ps1/sh` |
| 容灾备份 | ✅ | ✅ (v2.3.1+) | — | 5 个 DR 模板（v2.4.0 新增） |
| 安全设计审查 | ✅ | — | — | `security-design-review.md` |
| 容器化部署 | ✅ | — | — | `container-deployment.md` |
| 回滚设计 | ✅ | ✅ (v2.3.1+) | — | 代码/数据/配置/服务四类 |
| UTF-8 SSOT | ✅ | ✅ (v2.3.2+) | — | 版本号单一来源原则 |

---

## 十一、版本特定注意事项

### v2.4.0 注意事项
- PowerShell 5.1 不支持 ANSI 转义序列，安装脚本使用 ASCII 图形字符替代
- 容器化部署技能依赖外部工具（Docker / kubectl / Trivy）
- 安全技能模板依赖于外部漏洞数据库（CVE/NVD）
- 兼容性验证清单为模板性质，需在各平台实际执行并填写结果

### v2.3.2 注意事项
- 已修复 UTF-8 编码问题，是 v2.3.x 系列的稳定版
- 技能总数 22 个，L3 技能 10 个

### v2.3.0 注意事项
- `install.ps1` 使用 `Get-Content` 读取 UTF-8 文件可能在 PS 5.1 下出现乱码
- 建议使用 `[System.IO.File]::ReadAllText(path, [System.Text.Encoding]::UTF8)` 替代

### v2.1.0 注意事项
- version.json 版本号标记为 2.1.1 但实际上为 v2.1.0 版本
- 技能总数 16 个（L3 仅 7 个），无前端/后端/API 覆盖
- 无回滚设计体系

### v2.0.0 注意事项
- 无自动化安装脚本，需手动部署
- 无版本号 SSOT 机制
- 不建议在新项目中使用，请升级到 v2.4.0

---

## 十二、获取帮助

| 资源 | 路径 |
|------|------|
| 技能体系 | `skills/` 目录下全部 .md 文件 |
| 文档模板 | `templates/` 目录下的模板文件 |
| 版本信息 | `version.json` |
| 变更历史 | `CHANGELOG.md` |
| HTML 快速入门 | `quickstart.html`（浏览器打开） |
| Markdown 快速入门 | `quickstart.md`（本文档） |
| 安装脚本 | `install.bat` / `install.ps1` / `install.sh` |
| 初始化脚本 | `setup.ps1` / `setup.sh` |
| 质量脚本 | `scripts/*.ps1` / `scripts/*.sh` |

---

## 附录：版本需求编号说明

| 需求编号前缀 | 说明 |
|-------------|------|
| RT-ID | Requirements Traceability ID（需求追溯编号） |
| DT-ID | Design Traceability ID（设计追溯编号） |
| TD-ID | Task-Design ID（设计开发追溯编号） |
| VR-xxx | Version Requirement（版本需求编号，如 VR-012） |
| CLC-xxx | Claude Code 兼容性风险编号 |
| CUR-xxx | Cursor 兼容性风险编号 |
| CDX-xxx | Codex CLI 兼容性风险编号 |
| TD-xxx | Technical Debt（技术债务编号） |

---

*本指南覆盖 DevFlow v2.0.0 至 v2.4.0 全部版本。当前最新版本为 v2.4.0（2026-07-03 编码完成）。*