# DevFlow Agent 架构设计文档 — v2.11.0

> 文档类型：Agent 架构设计文档（audit-agent 独立审计师）
> 版本：v2.11.0
> 日期：2026-07-26

---

## 1. Agent 定位

`audit-agent` 是一个独立的 L3 审计技能（Skill），定位为"独立审计师"。它在各阶段完成后独立重新验证审计点，从"形式核验"升级为"独立复审"。

| 维度 | 内容 |
|:-----|:------|
| **角色** | 独立审计师 AI Agent |
| **层級** | L3（流程增强技能） |
| **文件位置** | `devflow-plugin/skills/L3/audit-agent/SKILL.md` |
| **触发方式** | 手动执行（审计师/PM 主动调用） |

## 2. 设计决策与 ADR

### ADR-001：独立 Skill 而非嵌入现有技能

| 字段 | 内容 |
|:-----|:------|
| **上下文** | 审计逻辑可以嵌入 operations-stage-execution 或作为独立 Skill |
| **备选方案** | ① 独立 SKILL.md（L3）② 嵌入 operations-stage-execution 作为章节 ③ 嵌入 coding-stage-execution |
| **决策** | **方案 ① 独立 SKILL.md** |
| **理由** | audit-agent 跨所有阶段执行，不归属于单一阶段的主控技能；独立后可在 Step 0~5 任意节点调用 |
| **后果** | 需要单独维护；但审计结果与阶段松耦合，更容易持续演进 |

### ADR-002：CLI 参数驱动而非交互式

| 字段 | 内容 |
|:-----|:------|
| **上下文** | 审计师需要指定审计目标和范围 |
| **备选方案** | ① CLI 参数（`audit v2.11.0`）② 交互式问答 ③ 配置文件 |
| **决策** | **方案 ① CLI 参数** |
| **理由** | 参数清晰可重复，适用于自动化脚本调用；交互式在 CI/CD 场景下阻塞 |
| **后果** | 需定义参数格式，但执行过程完全可复现 |

### ADR-003：只读审计 + 报告写入

| 字段 | 内容 |
|:-----|:------|
| **上下文** | 审计过程中是否允许修复发现的问题 |
| **备选方案** | ① 只读审计（仅发现不修复）② 审计+自动修复 ③ 审计+建议修复 |
| **决策** | **方案 ① 只读审计** |
| **理由** | 独立审计师不参与修复，否则失去独立性；修复走正常的开发流程 |
| **后果** | 发现的问题需要在 DevLogReport 中记录后手动修复 |

## 3. 工作流设计

### 3.1 核心执行流程

```text
audit-agent --version v2.11.0
    │
    ├─ Phase 1：追溯链验证
    │    ├─ Step 1: git log --oneline v2.11.0 → 提取 commit footer 中的 RT-ID/TD-ID
    │    ├─ Step 2: Read 各阶段追溯矩阵
    │    │    ├─ doc/requirements/DevFlow-需求追溯矩阵-v2.11.0.md
    │    │    ├─ doc/development/DevFlow-TD-ID追溯矩阵-v2.11.0.md
    │    │    └─ doc/design/DevFlow-设计评审记录-v2.11.0.md（DT-ID）
    │    └─ Step 3: 交叉比对 → 输出追溯链一致性报告
    │
    ├─ Phase 2：产出物盘点 + 检查点复查
    │    ├─ Step 1: LS 各阶段产出目录（Step 0~5），逐一核对产出清单
    │    ├─ Step 2: 读取全流程闭环审计报告中的 Release Checklist
    │    ├─ Step 3: 逐项重新执行验证命令（如 `cat version.json`、`git tag -l`）
    │    └─ Step 4: 对比命令输出与 Checklist 中的声称结果
    │
    └─ Phase 3：报告生成 + 风险归集
         ├─ Step 1: 合并 Phase 1~2 结果
         ├─ Step 2: 读取技术债务总表，检查 P1+ 风险归集情况
         ├─ Step 3: 写入 doc/audit/comprehensive/DevFlow-全流程闭环审计报告-v2.11.0.md
         └─ Step 4: 输出摘要到 Console
```

### 3.2 季度审计流程

```text
audit-agent --quarterly 2026-Q3
    │
    ├─ Step 1: 扫描本季度所有已发布版本的 tag
    ├─ Step 2: 对每个版本执行 Phase 1~3 审计
    ├─ Step 3: 汇总 → 季度审计报告
    └─ Step 4: 写入 doc/version/global/DevFlow-季度审计报告-Q3-v2026.md
```

## 4. 工具映射

| 审计能力 | 使用的工具 | 说明 |
|:---------|:-----------|:------|
| Git log 提取 ID | `RunCommand(git log)` | 提取 commit footer 中的 RT-ID/TD-ID |
| 文件存在性验证 | `LS(filepath)` / `Glob(pattern)` | 盘点产出物 |
| 文件内容验证 | `Read(filepath)` / `Grep(pattern)` | 读取追溯矩阵、Release Checklist |
| 验证命令重执行 | `RunCommand(command)` | 重新执行 Checklist 验证命令 |
| 审计报告输出 | `Write(filepath)` | 写入标准格式审计报告 |

## 5. 上下文与记忆

| 维度 | 设计 |
|:-----|:------|
| **输入上下文** | 版本号 `--version` 或季度标识 `--quarterly` |
| **阶段状态** | 每个 Phase 的结果独立记录，Phase 3 汇总 |
| **重复执行** | 幂等——同一版本多次审计结果一致 |

## 6. 失败处理

| 失败场景 | 行为 |
|:---------|:------|
| Git log 命令失败 | 输出"Git 不可用"错误，跳过 Phase 1 |
| 追溯矩阵文件不存在 | 跳过该阶段的追溯链验证，在报告中标记为"未验证" |
| 产出目录不存在 | 标记为"缺失"，在报告中列明 |
| 验证命令执行超时（>30s） | 标记为"超时未验证" |
| 审计报告写入冲突 | 追加时间戳或版本号避免覆盖 |
| 无 commit 可提取 ID（新项目） | 输出"无追溯链数据"，不阻塞 |

## 7. 可观测性

| 能力 | 实现方式 |
|:-----|:---------|
| **进度日志** | 每个 Step 开始时输出 `[INFO] Phase X Step Y: ...` |
| **中间结果** | 每个 Step 完成后输出关键发现 |
| **错误日志** | 失败时输出 `[ERROR] ...` + 原因 |
| **输出报告** | 完整的 Markdown 审计报告写入文件 |
