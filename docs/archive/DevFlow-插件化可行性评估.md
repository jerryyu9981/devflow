# DevFlow 插件化/框架化可行性评估

> 版本：v1.0 | 2026-06-26
> 评估目标：将 DevFlow 规范体系打包为可供不同 AI 编程智能体使用的可分发框架

---

## 一、对标参考：现有方案的发布形态

| 方案 | 发布形态 | 安装方式 | 文件结构 | 适配 Host |
|:-----|:---------|:---------|:---------|:---------|
| **Superpowers** | GitHub 仓库 + Marketplace 插件 | `/plugin install` 或 git clone 到 skills 目录 | `skills/*.skill` 文件 + `hook.lua` | Claude Code / Cursor / Codex / OpenCode |
| **Gstack** | GitHub 仓库 | git clone → `./setup` | `skills/*.md` + `setup` 脚本 + `lib/` 工具 | 8 个 Host（含 Codex CLI）|
| **DevFlow（当前）** | TRAE 平台本地 skill 目录 | 手动维护到 `~\.trae-cn\skills\` | 15 个 `SKILL.md` | ❌ TRAE 平台原生 |

### 关键发现

现有两个方案的共同模式：
1. **GitHub 仓库作为分发中心** — 不是平台市场
2. **SKILL.md / .skill 文件作为标准单元** — 所有 Host 都能识别
3. **setup 脚本做环境适配** — 不同 Host 的目录差异由脚本处理
4. **CLAUDE.md / .cursorrules 做激活** — 项目级配置文件触发流程
5. **无运行时依赖** — 纯 Prompt/规则，不需要部署服务

**DevFlow 的技能文件已经是标准的 `SKILL.md` 格式**，与 Superpowers/Gstack 的文件格式基本一致。

---

## 二、可行性评估

### 2.1 技术可行性 ✅

| 维度 | 评估 | 依据 |
|:-----|:------|:------|
| 技能格式 | ✅ **兼容** | 15 个核心技能已经是 SKILL.md 格式，与 Superpowers/Gstack 一致 |
| 编译层模式 | ✅ **天生可移植** | L2 内联 L3 速查是文本内嵌，不依赖任何平台能力 |
| 规范矩阵 | ✅ **纯Markdown表格** | 所有规范矩阵是表格，任何 Host 都能解析 |
| 追溯链 | ✅ **纯流程规则** | RT-ID / DT-ID / TD-ID 是文档中的编号规则，无平台依赖 |
| 文档模板 | ✅ **纯 Markdown 模板** | 18 个文档模板全部是 Markdown |
| L1 调度 | ⚠️ **需要适配器** | workflow + doc-management + role-management 的流程调度需封装为宿主 AI 能理解的激活指令 |
| 审计门禁 | ✅ **纯规则** | "覆盖率≥95%才能进入下一阶段"是条件判断，不依赖平台 |

### 2.2 需要解决的问题

| 问题 | 描述 | 解决方式 |
|:-----|:------|:---------|
| ① **150KB 体积** | 全部 15 个技能约 4,400 行 / 150KB，是 Superpowers 的 3 倍 | 编译层模式已有优化：L1+L2 ~112KB 预加载，L3 ~43KB 按需。体积本身不是问题（Claude Code 上下文窗口可容纳）|
| ② **6 个阶段的顺序执行** | DevFlow 依赖阶段的顺序执行（Step 0→1→2→3→4→5），其他 Host 没有内置的阶段状态机 | 需要一个**状态管理 Skill**（即"当前在哪个阶段"）——这在 Superpowers 中不存在，需要新建 |
| ③ **项目级配置** | 当前项目名、环境等是硬编码在技能中的 `{项目名}` 占位符 | 改为 CLAUDE.md 中的 DevFlow 配置区块，或 Gstack 式的 setup 脚本注入 |
| ④ **Host 适配** | TRAE 的 Skill 加载机制 vs Claude Code 的 skill 目录 vs Cursor 的 .cursorrules | 每个 Host 需要不同的入口文件，但技能文件内容不变 |
| ⑤ **多项目共存** | 当前技能目录是全局共享 | 改为项目级安装，每个项目独立激活 DevFlow |

---

## 三、推荐形态：DevFlow Framework

### 3.1 架构设计

```
devflow/
├── setup.ps1 / setup.sh          # 安装脚本（检测 Host 类型，自动配置）
├── CLAUDE.md                      # Claude Code 入口
├── .cursorrules                   # Cursor 入口
├── README.md                      # 项目说明
│
├── orchestrator/                  # 状态管理层（新增）
│   ├── 00-devflow-init.md        # 初始化 Skill：检测项目状态，确定当前阶段
│   ├── 00-devflow-phase-manager.md # 阶段状态机：记录当前在 Step 0-5 的哪个阶段
│   └── 00-devflow-project-config.md # 项目配置：项目名/环境/路径等
│
├── skills/                        # 核心技能（现有的 15 个技能，微调后）
│   ├── L1/                        # Layer 1：总控调度
│   │   ├── project-development-workflow.md
│   │   ├── project-document-management.md
│   │   └── project-role-management.md
│   ├── L2/                        # Layer 2：阶段执行
│   │   ├── version-planning-stage-execution.md
│   │   ├── requirements-stage-execution.md
│   │   ├── design-stage-execution.md
│   │   ├── coding-stage-execution.md
│   │   ├── testing-stage-execution.md
│   │   └── operations-stage-execution.md
│   └── L3/                        # Layer 3：专项参考
│       ├── project-coding-conventions.md
│       ├── code-static-quality-check.md
│       ├── code-logic-review.md
│       ├── cicd-pipeline-management.md
│       ├── observability-standards.md
│       └── project-document-templates.md
│
├── templates/                     # 文档模板（为不支持的 Host 独立提供）
│   ├── RT-需求追溯矩阵.md
│   ├── DT-需求设计追溯矩阵.md
│   ├── TD-设计开发追溯矩阵.md
│   └── ...
│
└── docs/                          # 文档
    ├── DevFlow-软件开发工程规范.md
    ├── 架构设计技能覆盖评估报告.md
    └── 工程化能力对比分析报告.md
```

### 3.2 核心增量：orchestrator 层

这是当前 DevFlow 没有、但插件化后必须有的**状态管理层**：

```
orchestrator 的工作方式：

1. 项目初始化时（首次安装 DevFlow）
   → devflow-init 读取项目目录结构
   → 推断当前处于哪个阶段（有设计文档？有需求文档？）
   → 设置阶段状态为"Step 1 需求分析"（从最落后的已完成阶段的下一个开始）

2. 每次会话启动时
   → devflow-phase-manager 检查项目目录
   → 读取 .devflow/state.json（保存的阶段状态）
   → 将"当前阶段"注入到 LLM 的 System Prompt 中

3. 阶段切换时
   → 完成 Step N 的完成标准检查
   → 执行审计门禁（如覆盖率≥95%）
   → 更新 .devflow/state.json 到 Step N+1
   → 提示用户进入下一阶段
```

**状态文件 `.devflow/state.json` 示例**：

```json
{
  "project": "MyProject",
  "version": "v1.0.0",
  "currentPhase": "step_3_coding",
  "completedPhases": ["step_0_planning", "step_1_requirements", "step_2_design"],
  "currentDocuments": {
    "requirementsTraceMatrix": "doc/requirements/MyProject-需求追溯矩阵-v1.0.0.md",
    "designDevTraceMatrix": "doc/design/MyProject-设计开发追溯矩阵-v1.0.0.md"
  },
  "auditResults": {
    "step_0_review": "passed",
    "step_1_review": "passed",
    "step_1_assessment": "passed",
    "step_2_review": "passed",
    "step_2_arch_audit": "passed"
  }
}
```

### 3.3 安装流程

```bash
# 方式一：GitHub 克隆（通用）
git clone https://github.com/your-org/devflow.git .devflow/
.devflow/setup.sh

# 方式二：CLAUDE.md 激活（Claude Code 专用）
# 在项目 CLAUDE.md 中增加：
# > DevFlow 已激活。运行 .devflow/setup.sh 查看当前阶段状态。

# 方式三：Marketplace 安装（未来）
# /plugin install devflow
```

### 3.4 Host 适配策略

| Host | 激活方式 | 特殊处理 |
|:-----|:---------|:---------|
| **TRAE**（当前）| 直接使用现有 skill 目录 | 无需改动，现有方式即可 |
| **Claude Code** | 项目根目录放 CLAUDE.md + `.claude/skills/devflow/` | 需重写 `file_path` 引用为相对路径 |
| **Cursor** | 项目根目录放 `.cursorrules` | 需简化到 Cursor 能理解的单文件规则 |
| **Codex CLI** | 项目根目录放 `CODEX.md` + 环境变量 | Gstack 已有 Codex CLI 适配参考 |
| **OpenCode** | `~/.config/opencode/skills/` | 需做路径映射 |

---

## 四、工作量和风险

### 4.1 开发工作量估算

| 模块 | 内容 | 工作量 |
|:-----|:------|:------|
| **orchestrator 层** | 新建 devflow-init / phase-manager / project-config 3 个 Skill | ~150 行（3 × 50 行）|
| **技能文件路径微调** | 将 `c:\Users\zkja\.trae-cn\skills\` 中的硬编码路径改为 `{project_root}/.devflow/skills/` 相对路径 | ~20 行搜替换 |
| **setup 脚本** | powershell + bash 双版本安装脚本 | ~80 行 |
| **Host 入口文件** | CLAUDE.md + .cursorrules + CODEX.md 各一份 | ~60 行（3 × 20 行）|
| **README + 文档** | 使用说明、安装指南、FAQ | ~100 行 |
| **templates 独立化** | 将 18 个模板从 SKILL.md 中提取为独立 Markdown 文件 | ~1 行（复制现有内容）|
| **GitHub 仓库准备** | README、LICENSE、.gitignore、CI（可选）| ~30 行 |
| **总计** | — | **~440 行（+现有 4,400 行）** |

> 注：15 个核心技能文件（4,400 行）**不需要重写**，只需微调路径引用。新增 ~440 行主要是 orchestrator + setup + 入口文件。

### 4.2 风险分析

| 风险 | 级别 | 说明 | 缓解措施 |
|:-----|:----|:------|:---------|
| **体积过大** | 中 | 150KB 对某些 Host 可能过大 | 保留编译层优化；orchestrator 自述"按需加载分阶段技能" |
| **Host 兼容性差异** | 中 | 不同 Host 对 SKILL.md 的解析方式不同 | setup 脚本做 Host 检测并生成适配配置 |
| **状态持久化** | 低 | 跨会话的阶段状态需要文件存储 | 使用 `.devflow/state.json`，简单可靠 |
| **L3 按需加载** | 低 | 其他 Host 没有 TRAE 的 Skill 工具调用 | 改为在 orchestrator 中显式引用：用系统提示告诉 LLM"如需数据库设计知识请读取 skills/L3/sql-database.md" |
| **编译层内联内容过期** | 低 | L3 更新后 L2 速查表不同步 | 在 setup 中增加验证命令 |

### 4.3 与 Superpowers/Gstack 的共存策略

DevFlow Framework 不应替代 Superpowers 或 Gstack，而应**与之互补**：

```
Superpowers 的 TDD + 子Agent   ← 专注编码纪律
        ↓
Gstack 的角色分工 + 安全护栏    ← 专注团队协作
        ↓
DevFlow 的全流程管控 + 追溯链  ← 专注工程管控
```

共存方式：
- **与 Superpowers 共存**：DevFlow 管理"做什么"（版本规划→需求→设计→测试→部署），Superpowers 管理"怎么写代码"（TDD 铁律、子 Agent 实现）
- **与 Gstack 共存**：DevFlow 管流程审计和文档，Gstack 管角色分工和无头浏览器测试
- **互不冲突**：DevFlow 的规范矩阵定义"必须做哪些测试"，Gstack 的 `/qa` 执行"怎么做 E2E 测试"

---

## 五、结论

### 5.1 可行性：✅ 可行，且工作量可控

总增量 ~440 行，其中核心的 orchestrator 状态管理 3 个 Skill 约 150 行。现有 15 个技能几乎不需重写。

### 5.2 推荐执行路线

| 阶段 | 内容 | 优先级 |
|:-----|:------|:------|
| **Phase 1** | 创建 orchestrator 3 个 Skill（init / phase-manager / project-config）| P0 |
| **Phase 2** | 自动 setup 脚本（powershell + bash 双版本）| P0 |
| **Phase 3** | CLAUDE.md + .cursorrules 入口文件 | P1 |
| **Phase 4** | 技能文件路径微调（去掉 `c:\...` 硬编码）| P1 |
| **Phase 5** | GitHub 仓库准备 + README | P2 |
| **Phase 6** | 其他 Host 适配（Codex CLI / OpenCode）| P3 |

### 5.3 一句话结论

**可以。** DevFlow 的核心技能已经是标准的 SKILL.md 格式，只需新增约 150 行的 orchestrator 状态管理层 + 80 行 setup 脚本 + 60 行 Host 入口文件，就能打包为一个可分发、可跨 Host 使用的框架，总增量约 440 行。同时 DevFlow 与 Superpowers/Gstack 天然互补，可以共存。
