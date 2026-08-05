---
name: "version-planning-stage-execution"
description: "Guides Step 0 version planning before requirements. Invoke for roadmap, release scope, backlog prioritization, phase planning, risks, and version planning documents."
---

# Version Planning Stage Execution（Step 0 版本规划阶段执行规范）

## 定位

本技能用于软件开发流程中的 Step 0：需求前置 / 版本规划阶段。它发生在正式需求分析之前，负责确定版本目标、版本范围、优先级、路线图、Phase 拆分、资源依赖、风险约束和高层验收目标。

它不替代需求分析。版本规划回答“这个版本做什么、不做什么、为什么做、分几期做”；需求分析回答“已选定范围内的需求具体如何定义、如何验收”。

## 触发条件

当用户提出以下需求时，调用本技能：

- 制定项目或产品版本规划
- 创建版本迭代路线图
- 确定某个版本的范围、目标、优先级或发布节奏
- 整理候选需求池、Backlog 或版本需求池
- 拆分 Phase 迭代计划
- 做版本规划评审或范围变更记录
- 判断需求是否可以进入正式需求分析阶段
- 区分全部版本文档和单版本文档

## 阶段位置

**本阶段负责人角色**：参考 `project-role-management` 技能定义的角色矩阵。

```text
Step 0 版本规划 / 需求前置
→ Step 1 需求分析
→ Step 2 架构与设计
→ Step 3 开发 / 编码
→ Step 4 测试
→ Step 5 部署与运维
```

## 全部版本与单版本边界

| 层级 | 关注问题 | 文档特征 |
|---|---|---|
| 全部版本 | 项目长期怎么演进、版本节奏如何安排、候选需求如何管理 | 长期维护，不绑定单个版本号或按全局版本维护 |
| 单版本 | 当前版本做什么、不做什么、如何分 Phase、如何验收 | 绑定具体版本号，随版本归档 |

## 版本规划矩阵

正式 Step 0 应按以下矩阵执行。小型项目可合并文档，但不得缺失关键决策。

| 规划类别 | 必须执行内容 | 通过标准 | 强制产出 / 证据 |
|---|---|---|---|
| 背景与问题 | 收集业务背景、用户反馈、线上问题、数据洞察、竞品变化、技术债 | 能说明为什么需要规划该版本或路线 | 背景说明 |
| 全局目标 | 明确项目长期目标、版本节奏、版本命名和治理原则 | 全局版本方向清晰 | 版本规划总纲 |
| 候选需求池 | 收集候选需求、来源、价值、成本、风险、目标版本、状态 | 候选需求可追踪、可筛选 | 候选需求池 / Backlog |
| 路线图 | 规划多个版本的主题、时间窗口、核心能力和依赖关系 | 多版本演进方向清晰 | 版本迭代路线图 |
| 单版本目标 | 明确当前版本业务目标、用户目标、技术目标和成功指标 | 版本目标可衡量 | 单版本规划文档 |
| 单版本范围 | 明确本版本包含、不包含、延期和排除内容 | 范围边界清晰，避免需求膨胀 | 单版本规划文档、本版本 Backlog |
| 优先级排序 | 对需求进行 P0/P1/P2、MoSCoW、RICE 或价值/成本/风险评估 | 需求优先级可解释 | 版本优先级评估记录 |
| Phase 拆分 | 将单版本拆成 Phase、里程碑、交付物和验收重点 | 每个 Phase 可独立推进和验证 | Phase 迭代计划 |
| 资源与依赖 | 梳理人力、角色、时间、外部系统、数据、设计、法务、运营依赖 | 关键依赖有负责人和状态 | 版本依赖清单 |
| 风险与约束 | 识别业务、技术、合规、交付、外部依赖风险 | 风险有级别和应对方式 | 版本风险清单 |
| 高层验收 | 定义版本级验收目标、成功指标和上线门槛 | 可作为需求阶段验收细化输入 | 版本成功指标说明 |
| 发布策略草案 | 确认灰度、发布窗口、回滚策略、兼容策略草案 | 发布约束提前暴露 | 版本发布策略草案 |
| 规划评审 | 评审版本目标、范围、优先级、资源、风险和是否进入需求阶段 | 有明确批准或退回结论 | 版本规划评审记录 |
| 范围变更 | 记录版本范围新增、移出、替换、延期和影响 | 范围变更可追溯 | 单版本范围变更记录、版本范围变更总记录 |
| 技术债务评估 | 审查现有技术债清单，评估本版本应偿还的技术债，确定每个版本 15-20% 容量用于偿还；技术债优先级：安全债务 > 架构债务 > 测试债务 > 代码整洁债务 | 技术债偿还计划纳入版本范围 | 技术债务清单（可作为单版本规划文档强制章节） |

## 全部版本文档

全部版本文档长期维护，默认存放在 `doc/version/global/`。

| 文档 | 作用 |
|---|---|
| 版本规划总纲 | 项目长期目标、版本节奏、版本命名、发布策略、兼容策略和治理原则 |
| 版本迭代路线图 | 多版本主题、时间窗口、核心能力、前后依赖和状态 |
| 候选需求池 | 全部候选需求、来源、价值、成本、风险、目标版本和状态 |
| 版本范围变更总记录 | 跨版本范围移动、延期、合并、拆分和决策记录 |
| 版本发布策略总则 | 发布节奏、灰度策略、版本类型、回滚原则和兼容策略 |

## 单版本文档

单版本文档绑定具体版本号，默认存放在 `doc/version/releases/v{版本号}/`。

| 文档 | 作用 |
|---|---|
| 单版本规划文档 | 当前版本目标、范围、优先级、资源、风险和高层验收 |
| Phase 迭代计划 | 当前版本内部 Phase 拆分、里程碑、交付物和验收重点 |
| 本版本 Backlog | 从全局候选需求池筛选出的当前版本需求子集 |
| 版本规划评审记录 | 当前版本规划评审意见、争议、决策和批准结论 |
| 单版本范围变更记录 | 可作为单版本规划文档的强制章节；当前版本内新增、移出、替换、延期和影响说明 |
| 版本成功指标说明 | 可作为单版本规划文档的强制章节；定义当前版本上线后如何判断是否成功 |
| 版本发布策略草案 | 可作为单版本规划文档的强制章节；当前版本灰度、发布窗口、回滚和运营节奏草案 |
| 版本依赖清单 | 当前版本人力、角色、时间、外部系统、数据、设计、法务、运营依赖清单（可作为单版本规划文档强制章节，独立输出时使用本命名） |
| 版本风险清单 | 当前版本业务、技术、合规、交付、外部依赖风险清单（可作为单版本规划文档强制章节，独立输出时使用本命名） |
| 版本优先级评估记录 | 当前版本需求优先级评估方法、依据和结论（可作为本版本 Backlog 强制章节，独立输出时使用本命名） |
| 技术债务清单 | 当前版本识别的技术债条目、分类、P0-P3 严重级别、偿还计划或挂起理由（可作为单版本规划文档强制章节，独立输出时使用本命名） |

## 输出到需求阶段

Step 0 完成后，必须向 Step 1 提供：

- 当前版本目标
- 当前版本范围和不包含范围
- 本版本 Backlog
- P0/P1/P2 优先级
- Phase 迭代计划
- 高层验收目标
- 关键依赖和风险
- 版本规划评审结论

Step 1 需求分析只能细化已批准进入当前版本的范围。新增需求应先进入候选需求池或触发版本范围变更。

## 技能速查映射

全流程/门禁→workflow | 文档管理→doc-management | 角色协调→role-management | 发散调研→brainstorming/research/consulting | 文档写作→doc-writing-guide | 命名规范→universal-naming-conventions

## 反模式

Step 0 应避免：

- 把版本规划混入详细需求文档，导致范围和需求细节纠缠
- 没有版本边界就进入需求分析
- 没有优先级就进入设计或开发
- 只维护单版本计划，不维护全局路线图和候选需求池
- 版本范围变更没有记录
- 版本目标没有成功指标
- 资源、依赖和风险没有负责人
- 评审未批准就进入 Step 1

## 强制规则

1. **版本目标必须可衡量**：每个版本目标必须包含至少 1 个可量化的成功指标
2. **范围边界必须明确**：必须同时定义"包含范围"和"不包含范围"，未明确的范围视为不包含
3. **P0 项必须 100% 覆盖**：版本规划中的 P0 项必须全部有对应的 Backlog 条目，不允许 P0 项无对应需求
4. **风险必须分级**：所有风险必须按 P0/P1/P2 分级，P0 风险必须有缓解计划
5. **依赖必须验证**：所有外部依赖必须确认可用性和时间窗口，未确认的依赖标记为风险项

## 完成标准

Step 0 可完成的最低条件：

1. 全局候选需求池已更新。
2. 当前版本目标和范围已明确。
3. 本版本 Backlog 已形成。
4. P0/P1/P2 优先级已确认。
5. Phase 迭代计划已确认。
6. 关键依赖和风险已记录。
7. 高层验收目标已定义。
8. 版本规划评审已通过。
9. 已明确允许进入 Step 1 需求分析。

## Requirements Stage Integration


When this skill is used during the formal requirements stage, coordinate with `requirements-stage-execution`.

- Treat `requirements-stage-execution` as the Step 1 requirements-stage controller.
- Use this skill only for its specialty area; do not use it to declare the whole requirements stage complete.
- Record requirement sources, assumptions, constraints, open questions, decisions, acceptance criteria, and downstream impacts in the relevant requirements document.
- Do not let a successful specialty analysis replace the Step 1 requirements review or requirements audit.
- If a P0/P1 requirement gap is found, fix it within Step 1, update the requirements baseline and traceability matrix, then rerun the relevant requirements review before design handoff.

## L3 代码版本备份管理速查

以下规则内联自 code-version-backup-management 技能：
- 分支策略(3种)：trunk-based(<=3人/快速迭代) / github-flow(3-10人/CI完善) / git-flow(>=5人/多版本并行，推荐方案)
- Git Flow 分支：main(生产) ← release(发布准备) ← develop(日常集成) ← feature(功能) + hotfix(紧急修复)
- 提交约定：type(scope): subject，footer 引用 RT-ID；类型包括 feat/fix/docs/style/refactor/test/chore
- TDD 合规：feat 和 fix 提交必须包含对应的测试文件变更；测试代码先于生产代码提交
- 版本号：语义化 MAJOR.MINOR.PATCH（破坏性变更/新功能/Bug修复）；标签格式 v{major}.{minor}.{patch}
- 备份策略：日常 git push --mirror 远程备份仓库；每周 git bundle create 快照(留存4周)；每版本 git archive 归档
- 回滚命令：git revert {hash}(推荐保留历史) / git checkout v1.0.0 -- {file}(恢复文件) / git reset --hard {hash}(仅本地)
- 权限：只有审查者/PM/管理员可合入 develop/release/main；只有管理员可创建 tag
- 配置驱动：分支策略和远程仓库由 `.devflow/config.json` 定义，不硬编码路径

## L3 项目文档模板速查

以下规则内联自 project-document-templates 技能：
- 模板总数(16类)：单版本规划文档/开发需求文档/系统架构设计文档/需求追溯矩阵/需求设计追溯矩阵/DevLogReport/测试报告/发布计划/部署执行记录/需求评审记录/设计评审记录/回滚预案/运维手册/发布复盘报告/版本规划评审记录/测试计划/技术债务清单/静态质量检查记录/设计开发追溯矩阵
- 使用原则：模板中标记"必须"的章节不可省略，"可选"的按需添加；支持中文编号和阿拉伯数字两种风格
- 元信息统一：所有文档开头必须包含基本信息表格（项目名、版本号、状态、日期、负责人/作者）；重要文档建议包含修订历史表
- 系统架构设计文档按架构风格分支：先确定架构风格（单体/微服务/Agent/混合），再按对应分支补充设计章节
- 追溯矩阵(2种)：需求追溯矩阵(RT-{序号})用于 Step 1 需求阶段；需求设计追溯矩阵(DT-{序号})用于 Step 2 设计阶段
- 设计开发追溯矩阵(TD-{序号})：编码前创建设计项到文件的映射，作为编码指引和 Step 3 尾端开发设计对比审计的基准输入
- 不替代 project-document-management：命名和存储路径由该技能负责

## 变更记录

| 日期 | 变更内容 | 变更人 |
|---|---|---|
| 2026-07-02 | 添加变更记录章节 | jerry.yu |