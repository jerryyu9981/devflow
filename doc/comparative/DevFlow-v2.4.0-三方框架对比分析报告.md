# DevFlow v2.4.0 vs Superpowers v6.0.2 vs Gstack — 软件开发工程化能力对比分析报告

## 1. 基本信息

| 维度 | DevFlow v2.4.0 | Superpowers v6.0.2 | Gstack |
|------|---------------|-------------------|--------|
| 作者 | jerry.yu（个人开发者） | Jesse Vincent（obra）/ Prime Radiant | Garry Tan（YC CEO） |
| 首次发布 | 2025 年（v2.0.0） | 2025 年 10 月 | 2026 年 3 月 12 日 |
| 最新版本 | v2.4.0（2026-07-03） | v6.0.2（2026-06-17） | v1.43.0+（持续迭代，395+ 版本） |
| GitHub Stars | 私有项目 | 高增长社区项目 | 117,000+ Stars |
| 开源协议 | 项目内部使用 | MIT License | MIT License |
| 定位 | 中文项目级全流程工程规范 | AI 编程工程方法论与技能框架 | AI 虚拟工程团队与软件工厂 |
| 目标用户 | 中文开发团队/个人（TRAE IDE 生态） | Claude Code/Cursor/Codex 等 11+ 平台用户 | Claude Code 用户（深度绑定） |
| 支持平台 | TRAE IDE、Claude Code、Cursor、Codex CLI | Claude Code、Cursor、Codex、Gemini CLI、Kimi Code、Copilot CLI 等 11+ 平台 | 深度绑定 Claude Code |
| 技能数量 | 26 个（L1×3 + L2×6 + L3×14 + Orch×3） | ~15 个核心技能 | 23 个专家角色 + 6 个辅助工具 |
| 模板数量 | 24 个文档模板 | 无独立模板系统 | 无独立模板系统 |
| 核心语言 | Markdown（技能文件）+ PowerShell/Bash（脚本） | Shell(50.9%) + JavaScript(41.9%) + TypeScript(2.6%) | TypeScript(79.6%) + Go(18.3%) |
| 技术栈 | 纯 Markdown + Shell 脚本 | Markdown + Shell + Hooks | Markdown + Bun 编译二进制 + Playwright + Chromium |

## 2. 核心理念对比

### 2.1 设计哲学

| 维度 | DevFlow v2.4.0 | Superpowers v6.0.2 | Gstack |
|------|---------------|-------------------|--------|
| 核心哲学 | **流程规范化**：通过 6 阶段门禁+文档体系确保开发过程可追溯、可审计 | **工程纪律化**：TDD 铁律、证据优于声明、系统化优于临时性 | **角色分工化**：模拟真实工程组织，不同阶段激活不同角色 |
| 一句话概括 | "让 AI 开发有据可查、有迹可循" | "给 AI 编程助手装上工程师纪律" | "把 Claude Code 变成一支虚拟工程团队" |
| 核心价值观 | 规范 > 效率 | 质量 > 速度 | 方向 > 执行 |

### 2.2 解决的核心问题

| 框架 | 解决的核心问题 |
|------|---------------|
| **DevFlow** | AI 辅助开发缺乏流程规范：无版本规划、无需求追溯、无设计评审、无测试矩阵、无审计闭环。中文团队需要一个完整的、可落地的 6 阶段开发流程体系 |
| **Superpowers** | AI 编程"氛围化"（Vibe Coding）：AI 倾向于跳过测试直接写代码、不做验证就声称完成、缺乏系统化调试。需要一套强制性的工程方法论约束 AI 行为 |
| **Gstack** | AI 开发"单角色陷阱"：用同一个 AI 同时做产品决策、架构设计、编码实现、代码审查和发布部署，每个阶段的深度和专注度都不够。需要角色分离 |

## 3. 架构设计对比

### 3.1 技能体系架构

| 维度 | DevFlow v2.4.0 | Superpowers v6.0.2 | Gstack |
|------|---------------|-------------------|--------|
| 层级模型 | 3 层架构：L1（编排层）→ L2（阶段执行层）→ L3（专项参考层）+ 3 个 Orchestrator | 扁平技能库：每个技能独立触发，通过 using-superpowers 编排器串联 | 角色矩阵：23 个专家角色按阶段分组，通过数据流串联 |
| 触发方式 | 用户手动调用 Use Skill 命令 | AI 自动检测上下文触发（mandatory workflows） | 用户通过斜杠命令（/office-hours、/plan-ceo-review 等）手动触发 |
| 运行时深度 | 2 层：L2 内联 L3 速查内容，单次 Skill 调用获取完整上下文 | 1 层：每个技能独立加载，通过引用关系互指 | 1 层：每个角色独立 SKILL.md，通过前置输出传递上下文 |
| 扩展机制 | version.json SSOT + install.ps1 skillMap 注册 | writing-skills 技能指导创建新技能 | SKILL.md.tmpl 模板管道 + gen:skill-docs 自动生成 |

### 3.2 流程模型

| 维度 | DevFlow v2.4.0 | Superpowers v6.0.2 | Gstack |
|------|---------------|-------------------|--------|
| 流程模型 | **6 阶段门禁模型**：Step 0 规划 → Step 1 需求 → Step 2 设计 → Step 3 编码 → Step 4 测试 → Step 5 部署 | **敏捷迭代模型**：brainstorming → planning → TDD 编码 → code review → finishing branch | **Sprint 闭环模型**：Think → Plan → Build → Review → Test → Ship → Reflect |
| 阶段门禁 | 每阶段有人工审批门禁，不通过不得进入下一阶段 | 技能自动触发，无显式门禁，通过 TDD 铁律和 verification-before-completion 隐式约束 | 角色间数据流驱动，/ship 命令前需通过 review + qa |
| 需求追溯 | RT-ID 需求追溯矩阵，100% 覆盖率要求 | design doc → plan → code review 链路 | /office-hours → /plan-ceo-review → /plan-eng-review 数据流 |
| 审计机制 | 3 层审计：需求评审 + 开发审计 + 测试回溯审计 + 运维审计 + 全流程闭环审计 | 无显式审计机制（依赖 code review 和 TDD） | /retro 工程回顾 + /review 审查记录 |

### 3.3 质量保障

| 维度 | DevFlow v2.4.0 | Superpowers v6.0.2 | Gstack |
|------|---------------|-------------------|--------|
| 测试策略 | 强制测试矩阵（14 类测试）、需求覆盖率 100%、修改文件覆盖率 ≥80% | TDD 铁律：RED-GREEN-REFACTOR 强制执行，先写测试再写代码 | /qa 真实浏览器测试 + /review 偏执型代码审查 + /cso 安全审计 |
| 代码审查 | code-logic-review（11 维度）+ code-static-quality-check（8 项静态检查） | requesting-code-review（pre-review checklist）+ receiving-code-review | /review（Staff Engineer 级偏执审查：N+1 查询、竞态条件、信任边界） |
| 安全 | security-design-review（STRIDE/DRED 威胁建模）+ secure-coding-practices（OWASP Top 10） | 无独立安全技能（依赖编码规范） | /cso（首席安全官 OWASP STRIDE 审计）+ 6 层 Prompt Injection 防御 |
| 文档规范 | skill-md-writing-standards（统一格式标准）+ 24 个文档模板 + project-document-management | 无独立文档标准 | DESIGN.md 概念 + /document-release 自动漂移修复 |

## 4. 功能覆盖对比

### 4.1 开发生命周期覆盖

| 阶段 | DevFlow v2.4.0 | Superpowers v6.0.2 | Gstack |
|------|---------------|-------------------|--------|
| **产品构思** | Step 0 版本规划（Backlog、Phase 拆分、优先级） | brainstorming（苏格拉底式提问） | /office-hours（YC 六问产品定义） |
| **需求分析** | Step 1 需求分析（用户需求→开发需求→追溯矩阵→评审） | brainstorming 输出 design doc | /spec + /plan-ceo-review（CEO 视角审视） |
| **架构设计** | Step 2 设计（系统架构 + UI + 非功能 + 部署 + 评审） | writing-plans（拆分为 2-5 分钟任务） | /plan-eng-review（架构图、序列图、状态机） |
| **编码实现** | Step 3 编码（TDD 铁律 + 4 Phase 迭代 + DevLogReport） | TDD + subagent-driven-development | 直接编码（~8 分钟 2,400 行） |
| **代码审查** | code-logic-review + code-static-quality-check | requesting-code-review + receiving-code-review | /review（AUTO-FIX + 人工确认） |
| **测试** | Step 4 测试（87 用例、14 类测试、回溯审计） | TDD 内置 + verification-before-completion | /qa（真实浏览器 find-fix-verify） |
| **部署** | Step 5 部署（发布计划 + 回滚方案 + 运维审计） | finishing-a-development-branch（merge/PR） | /ship（一键发布 + /canary 金丝雀） |
| **监控运维** | observability-standards + 运维手册 + 运维移交 | 无 | /retro（工程回顾） |
| **安全** | security-design-review + secure-coding-practices + container-deployment | 无独立安全技能 | /cso（STRIDE 审计） |

### 4.2 独特能力对比

| 独特能力 | DevFlow v2.4.0 | Superpowers v6.0.2 | Gstack |
|----------|---------------|-------------------|--------|
| **中文本地化** | ✅ 全中文技能文件、中文文档模板、中文脚本输出 | ❌ 英文为主 | ❌ 英文为主 |
| **6 阶段门禁** | ✅ 每阶段人工审批，强制规范流程 | ❌ 无显式门禁 | ❌ 角色间数据流驱动 |
| **文档模板体系** | ✅ 24 个标准模板（需求/设计/测试/运维） | ❌ 无 | ⚠️ DESIGN.md 概念 |
| **需求追溯矩阵** | ✅ RT-ID 100% 覆盖 | ❌ 无 | ❌ 无 |
| **全流程审计** | ✅ 3 层审计 + 全流程闭环 | ❌ 无 | ⚠️ /retro 回顾 |
| **质量检查脚本** | ✅ 6 个自动化脚本（格式/引用/安装验证） | ❌ 无 | ✅ 3 层测试（静态/E2E/LLM 评分） |
| **版本号 SSOT** | ✅ version.json 单一来源原则 | ⚠️ .version-bump.json | ⚠️ package.json |
| **跨平台脚本** | ✅ PowerShell + Bash + install.bat | ✅ Shell hooks + pre-commit | ⚠️ Bun 编译二进制（跨平台但需 Bun） |
| **容器化部署** | ✅ container-deployment（Docker/K8s/Compose） | ❌ 无 | ❌ 无 |
| **CI/CD 规范** | ✅ cicd-pipeline-management（质量闸门/部署策略） | ❌ 无 | ⚠️ /ship + /canary |
| **浏览器自动化** | ❌ 无 | ❌ 无 | ✅ 持久化 Chromium 守护进程（100ms 响应） |
| **Prompt Injection 防御** | ❌ 无 | ❌ 无 | ✅ 6 层防御（BERT 模型 + Canary Token） |
| **TDD 铁律强制** | ✅ coding-stage-execution 第 5 条 | ✅ 核心 TDD 技能 | ❌ 无强制 TDD |
| **Git Worktree** | ❌ 无 | ✅ using-git-worktrees（并行分支开发） | ❌ 无 |
| **Subagent 驱动开发** | ❌ 无（手动 Phase 迭代） | ✅ subagent-driven-development（双阶段审查） | ❌ 无（单 agent + 多角色切换） |
| **跨模型协作** | ❌ 无 | ❌ 无 | ✅ /codex（OpenAI Codex 做第二意见） |
| **持久化浏览器** | ❌ 无 | ❌ 无 | ✅ Chromium 守护进程 + Cookie 管理 |
| **可观测性标准** | ✅ observability-standards（日志/指标/追踪/告警） | ❌ 无 | ❌ 无 |
| **安装向导** | ✅ 交互式 install.ps1/setup.ps1 Q&A 向导 | ✅ 多平台 plugin 安装命令 | ⚠️ git clone + setup 脚本 |
| **兼容性验证清单** | ✅ 3 份（Claude Code/Cursor/Codex CLI） | ✅ 11+ 平台支持 | ❌ 仅 Claude Code |

## 5. 工程化深度对比

### 5.1 流程规范性

| 评分项（满分 5 分） | DevFlow v2.4.0 | Superpowers v6.0.2 | Gstack |
|---------------------|---------------|-------------------|--------|
| 阶段门禁与审批 | ★★★★★ | ★★☆☆☆ | ★★★☆☆ |
| 文档产出标准化 | ★★★★★ | ★★☆☆☆ | ★★★☆☆ |
| 需求追溯完整性 | ★★★★★ | ★★☆☆☆ | ★☆☆☆☆ |
| 审计与合规 | ★★★★★ | ★☆☆☆☆ | ★★☆☆☆ |
| 变更管理 | ★★★★★ | ★★★☆☆ | ★★★☆☆ |

### 5.2 编码质量约束

| 评分项（满分 5 分） | DevFlow v2.4.0 | Superpowers v6.0.2 | Gstack |
|---------------------|---------------|-------------------|--------|
| TDD 强制执行 | ★★★★☆ | ★★★★★ | ★☆☆☆☆ |
| 代码审查深度 | ★★★★☆ | ★★★☆☆ | ★★★★★ |
| 静态质量检查 | ★★★★★ | ★☆☆☆☆ | ★★★☆☆ |
| 安全审计 | ★★★★☆ | ★☆☆☆☆ | ★★★★☆ |
| 自动化测试覆盖 | ★★★★☆ | ★★★★☆ | ★★★★☆ |

### 5.3 工程工具链

| 评分项（满分 5 分） | DevFlow v2.4.0 | Superpowers v6.0.2 | Gstack |
|---------------------|---------------|-------------------|--------|
| 浏览器自动化 | ☆☆☆☆☆ | ☆☆☆☆☆ | ★★★★★ |
| CI/CD 集成 | ★★★★☆ | ★★☆☆☆ | ★★★☆☆ |
| 容器化支持 | ★★★★☆ | ☆☆☆☆☆ | ☆☆☆☆☆ |
| 可观测性 | ★★★★☆ | ☆☆☆☆☆ | ☆☆☆☆☆ |
| 多平台兼容 | ★★★★☆ | ★★★★★ | ★★☆☆☆ |

### 5.4 用户体验

| 评分项（满分 5 分） | DevFlow v2.4.0 | Superpowers v6.0.2 | Gstack |
|---------------------|---------------|-------------------|--------|
| 上手难度 | ★★★☆☆（需学习 6 阶段流程） | ★★★★★（自动触发、无需记忆） | ★★★☆☆（需学习 23 个角色） |
| 中文支持 | ★★★★★ | ★☆☆☆☆ | ★☆☆☆☆ |
| 文档完整度 | ★★★★★ | ★★★★☆ | ★★★☆☆ |
| 社区生态 | ★☆☆☆☆（私有项目） | ★★★★☆（活跃社区 + Discord） | ★★★★★（11.8 万 Stars + HN 热议） |
| 商业支持 | 无 | Prime Radiant 商业服务 | 无 |

## 6. 适用场景分析

### 6.1 DevFlow v2.4.0 最佳场景

1. **中文团队规范化开发**：需要完整中文文档体系和 6 阶段流程规范的团队
2. **高合规要求项目**：需要审计闭环、需求追溯、变更管理的金融/政企项目
3. **技能插件开发**：DevFlow 自身就是技能插件，适合为 AI 平台开发技能体系
4. **教育与培训**：完整的 6 阶段流程可作为 AI 辅助开发的培训教材
5. **容器化部署项目**：内置 Docker/K8s/Compose 部署规范

### 6.2 Superpowers v6.0.2 最佳场景

1. **个人开发者日常编码**：自动触发的 TDD 纪律，无需手动管理
2. **跨平台 AI 开发**：支持 11+ 个 AI 编码平台，一套方法论多端通用
3. **代码质量至上**：TDD 铁律 + systematic-debugging + verification-before-completion
4. **敏捷迭代**：brainstorming → writing-plans → subagent-driven-development 高效循环
5. **Git 并行开发**：using-git-worktrees 支持多分支并行

### 6.3 Gstack 最佳场景

1. **产品型创业公司**：/office-hours + /plan-ceo-review 从产品定义到技术实现全链路
2. **浏览器交互密集项目**：持久化 Chromium 守护进程 + /qa 真实浏览器测试
3. **高频发布 Web 应用**：/ship 一键发布 + /canary 金丝雀部署
4. **安全敏感应用**：6 层 Prompt Injection 防御 + /cso STRIDE 审计
5. **单人高产出开发**：Garry Tan 模式的"一个人 = 一个团队"高效产出

## 7. 三者组合的可能性

社区已有实践表明三者可以组合使用：

### 7.1 推荐组合方案

```
Gstack（产品定义 + 方向把控）
    ↓
DevFlow（流程规范 + 审计闭环）
    ↓
Superpowers（编码纪律 + TDD 执行）
```

| 阶段 | 推荐框架 | 原因 |
|------|----------|------|
| 产品构思 → 需求分析 | Gstack | /office-hours YC 六问 + /plan-ceo-review CEO 视角 |
| 需求 → 设计 → 规划 | DevFlow | Step 0-2 门禁 + 需求追溯矩阵 + 文档模板 |
| 编码实现 + 测试 | Superpowers | TDD 铁律 + subagent-driven-development |
| 代码审查 + 安全审计 | Gstack | /review 偏执审查 + /cso STRIDE |
| 测试 + 审计 | DevFlow | Step 4 测试矩阵 + 测试回溯审计 |
| 部署 + 运维 | DevFlow | Step 5 + observability-standards + container-deployment |
| 发布 + 验收 | Gstack | /ship + /qa 真实浏览器验证 |

### 7.2 组合痛点

1. **上下文传递损耗**：三个框架各自维护独立的文档体系，Spec/Plan 在传递过程中可能丢失上下文
2. **流程冗余**：DevFlow 的 6 阶段门禁 + Superpowers 的自动触发 + Gstack 的角色切换，可能导致流程过重
3. **语言不一致**：DevFlow 中文 vs Superpowers/Gstack 英文，团队需要双语能力
4. **平台兼容性**：DevFlow 支持 TRAE IDE + Claude Code + Cursor + Codex CLI，Superpowers 支持 11+ 平台，Gstack 仅支持 Claude Code

## 8. 总结

### 8.1 三方定位图

```
                    流程规范性
                       ↑
                       │
              DevFlow ●│
                       │
                       │
    ───────────────────┼──────────────────→ 技术深度
                       │
                       │         ● Superpowers
                       │
                       │
                       │              ● Gstack
```

- **DevFlow**：流程规范性最强，适合需要完整审计闭环的规范化开发
- **Superpowers**：编码纪律最强，TDD 铁律和自动触发机制确保代码质量
- **Gstack**：技术深度最深，浏览器守护进程和 Prompt Injection 防御是独特竞争力

### 8.2 一句话总结

| 框架 | 一句话总结 |
|------|-----------|
| **DevFlow v2.4.0** | 中文环境下最完整的 AI 辅助开发流程规范体系，6 阶段门禁 + 全流程审计闭环，适合高合规团队 |
| **Superpowers v6.0.2** | AI 编程工程纪律的天花板，TDD 铁律 + 自动触发 + 11 平台兼容，适合追求代码质量的个人开发者 |
| **Gstack** | AI 虚拟工程工厂的标杆，角色分离 + 浏览器自动化 + 安全防御，适合产品型创业团队的高效交付 |

### 8.3 选择建议

| 如果你... | 推荐 |
|-----------|------|
| 是中文团队，需要完整流程规范和审计闭环 | **DevFlow v2.4.0** |
| 是个人开发者，追求代码质量和 TDD 纪律 | **Superpowers v6.0.2** |
| 是创业团队，需要从产品定义到快速发布 | **Gstack** |
| 需要最大程度的工程化保障 | **DevFlow + Superpowers 组合** |
| 需要产品+技术双轮驱动 | **Gstack + DevFlow 组合** |
| 想要最全面的工程化覆盖 | **三者组合（Gstack → DevFlow → Superpowers）** |

## 9. 变更记录

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| 1.0 | 2026-07-03 | 三方框架对比分析报告初始版本 |
