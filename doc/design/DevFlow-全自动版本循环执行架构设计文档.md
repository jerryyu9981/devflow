# DevFlow 全自动版本循环执行架构设计文档

> **文档状态**: [Draft]  
> **版本**: 1.0.0  
> **项目**: DevFlow  
> **作者**: AA-DevFlow-Dev  
> **创建日期**: 2026-07-12

---

## 1. 设计目标

在保留"人工门禁"的前提下，支持 DevFlow 版本开发周期的**全自动循环执行**，即：vN 版本的 Step 0~5 完成后，自动进入 vN+1 版本循环，直到所有候选需求被处理完毕或达到终止条件。

### 1.1 核心约束

1. **人工门禁不可省略**——每个 Step 完成后仍必须等待人工批准，但流程本身不应因非门禁原因卡住
2. **自动推进**——批准后，系统自动进入下一步，不等待用户额外指令
3. **异常容错**——出现卡住或死循环风险时，系统自动决策（跳过、降级、终止），不阻塞流程
4. **版本间闭环**——版本结束后自动评估"是否启动下一版本"，无需人工决定

---

## 2. 两维循环模型

```
┌─────────────────────────────────────────────────────────────────────┐
│                     DevFlow 全自动循环执行架构                        │
└─────────────────────────────────────────────────────────────────────┘

  版本内循环（Step 0 → 5）                 版本间循环（vN → vN+1）
  ┌──────────────────────────────┐      ┌──────────────────────────────┐
  │                              │      │                              │
  │  Step 0 ─→ Step 1 ─→ Step 2 │      │  v2.8.0 闭环 ──→ 检查候选池   │
  │       ↓         ↓         ↓  │      │       │                      │
  │  Step 3 ─→ Step 4 ─→ Step 5 │      │  ├─ 有剩余 P0/P1 ─→ 启动 vN+1│
  │                              │      │  ├─ 仅剩 P2    ─→ 暂停等待   │
  │  管理: devflow-phase-manager │      │  └─ 无剩余     ─→ 标记完成   │
  │                              │      │                              │
  └──────────────────────────────┘      └──────────────────────────────┘
         ↑                                      ↑
   重试管理器 + 自动降级                   循环状态机 + 空池检测器
```

### 2.1 版本内循环 vs 版本间循环

| 维度 | 版本内循环 | 版本间循环 |
|:----|:----------|:----------|
| 范围 | 单一版本 Step 0→1→2→3→4→5 | 多版本 vN→vN+1→vN+2... |
| 状态管理 | `auditResults` + `completedPhases` | `cycleState` 新字段 |
| 卡住检测 | retry 计数、覆盖率阈值 | 空池检测、滞留检测 |
| 管理者 | `devflow-phase-manager`（已有） | `cycle-state-machine`（新增 orchestrator） |
| 跳出方式 | 降级跳过 → 继续下一步 | 标记 completed → 停止循环 |
| 人工参与 | 每步门禁（不可跳过） | 启动/停止（可自动化） |

---

## 3. state.json 增强（cycleState 字段）

原有 state.json 字段保持不变，新增 `cycleState` 字段管理版本间循环状态：

```json
{
  "project": "DevFlow",
  "devflowVersion": "2.8.0",
  "currentPhase": "step_5_deployed",
  "completedPhases": ["step_0_planning", ...],
  "currentDocuments": { ... },
  "auditResults": { ... },

  "cycleState": {
    "mode": "auto_loop",
    "currentVersion": "2.8.0",
    "startedAt": "2026-07-12T10:00:00Z",
    "completedVersions": ["2.7.5", "2.8.0"],
    "status": "active",

    "retryCount": {
      "step_0": 0,
      "step_1": 0,
      "step_2": 0,
      "step_3": 0,
      "step_4": 0,
      "step_5": 0
    },
    "maxRetries": 3,

    "deferredItems": [],
    "blockedItems": [],
    "errors": [],
    "knownIssues": []
  }
}
```

### 3.1 字段说明

| 字段 | 类型 | 说明 |
|:----|:----|:------|
| `mode` | string | `"manual"`（默认，单版本手工模式）\| `"auto_loop"`（全自动循环模式） |
| `currentVersion` | string | 当前循环的版本号（如 `"2.8.0"`） |
| `startedAt` | datetime | 循环开始时间 |
| `completedVersions` | string[] | 已完成的版本列表 |
| `status` | string | `"active"` \| `"paused"` \| `"completed"` \| `"aborted"` |
| `retryCount` | object | 各 Step 的当前重试次数 |
| `maxRetries` | int | 全局重试上限（默认 3），单步超过上限则跳过 |
| `deferredItems` | array | 本版本跳过的候选需求项 |
| `blockedItems` | array | 永久阻塞的候选需求项 |
| `errors` | array | 循环中记录的错误 |
| `knownIssues` | array | 已知未解决但非阻塞的问题 |

---

## 4. 新增组件设计

### 4.1 重试管理器（retry-manager）

**职责**：嵌入到 devflow-phase-manager 的阶段切换门禁中，管理单步重试计数与自动跳过。

**判断逻辑**：

```
在每次 Step N 完成后的门禁检查时：
  1. 判断本 Step 是否通过门禁
  2. 通过 → retryCount[step_N] = 0，正常进入下一步
  3. 不通过 → retryCount[step_N] += 1
     ├── retryCount[step_N] < maxRetries:
     │     → 记录失败原因到 errors[]
     │     → 提示用户修复后重新提交
     │     → 不推进，等待下次提交
     │
     └── retryCount[step_N] >= maxRetries:
           → 自动诊断：是"本 Step 全部失败"还是"部分失败"？
             ├── 部分失败（如部分测试用例通过）
             │    → 通过的项标记为 "passed"
             │    → 失败的项移入 deferredItems
             │    → 记录降级原因到 errors[]
             │    → retryCount[step_N] = 0（重置计数）
             │    → 强制进入下一步
             │
             └── 全部失败（如整个 Step 无法执行）
                   → 本版本所有未完成项移入 deferredItems
                   → 标记本 Step 为 "skipped"
                   → 记录 fatal 到 errors[]
                   → 强制进入下一步
```

**阶段特定超限策略**：

| 阶段 | 超限时行为 | 理由 |
|:----|:----------|:-----|
| Step 0 版本规划 | 跳过本版本所有项目，标记 `version_planning_failed` | 规划不了就直接放弃当前版本 |
| Step 1 需求分析 | 将模糊项 defer，清晰的继续 | 总比什么都不做好 |
| Step 2 设计 | 覆盖率缺口 > 5% → 将缺口项 defer；≤5% → 降级 pass | 覆盖率略低可接受 |
| Step 3 开发 | 语法检查失败 → defer 本项；逻辑审查失败 → defer 本项 | 单个模块可以暂缓 |
| Step 4 测试 | P0 失败 → defer 对应需求；P1/P2 失败 → 降级 knownIssues | 非关键项可带问题发布 |
| Step 5 部署 | TRAE 不可写 → abort；其他问题 → 重试 | 部署失败自动终止 |

### 4.2 自动降级机制（auto-degrade）

**职责**：为测试覆盖率略低、非 P0 失败等"灰色地带"提供自动通过逻辑，避免无谓的重试循环。

**降级判断矩阵**：

| 场景 | 条件 | 降级结果 | 记录内容 |
|:-----|:-----|:---------|:---------|
| 测试覆盖率 | ≥90% 且 <95% | `pass_with_note` | 记录缺口项列表 |
| 测试覆盖率 | <90% | 不降级，继续 retry | — |
| P1/P2 测试失败 | 1~3 项 | `partial_pass` | 记录到 knownIssues |
| P0 测试失败 | 任意数量 | 不降级，继续 retry | — |
| 代码审查 warnings | 仅 warnings，无 errors | `pass_with_warnings` | 记录 warnings 列表 |
| 语法检查 warnings | 仅 warnings，无 errors | `pass` | — |
| 部署成功率 | 非核心技能部署失败（<20%） | `pass_with_issues` | 记录失败的技能名 |
| 部署成功率 | 核心技能（devflow-init 等）失败 | 不降级，继续 retry | — |

### 4.3 空池检测器（empty-pool-detector）

**职责**：在 Step 5 闭环后、启动新版本前，检测候选池状态，判断是否继续循环。

**判断逻辑**：

```
在 Step 5 闭环后，下一步动作前执行：

1. 读取候选需求池，统计所有 status = "📋 候选" 的需求
   ├── 候选池为空:
   │     → 设置 cycleState.status = "completed"
   │     → 输出最终报告："所有候选需求已处理完毕"
   │     → 停止循环
   │
   ├── 候选池仅剩 P2:
   │     → 设置 cycleState.status = "paused"
   │     → 记录原因："仅剩 P2 级需求，建议等待下个主要版本"
   │     → 等待用户决定（继续处理 P2 还是停止）
   │
   └── 候选池有 P0/P1:
         → 执行滞留检测（stale-item-detector）
           ├── 有滞留项 → 自动排除，记录原因
           └── 无滞留项 → 正常推进到下一版本
```

**版本号自动递增**：检测到需要启动新版本时，从候选池中优先级最高的目标版本号决定。若无指定，自动递增次版本号：
- `2.8.0` → `2.8.1`（如果延期项需要热修复）
- `2.8.0` → `2.9.0`（如果 P0 项是新功能）

### 4.4 滞留检测器（stale-item-detector）

**职责**：检测连续多个版本被纳入但从未完成的"滞留需求"，将其从候选池移除，避免无限循环。

**判断逻辑**：

```
在 version-planning-stage-execution 的 Step 0 执行时：

for each item in 本版本 Backlog:
  if item.id in cycleState.blockedItems:
    → 自动从 Backlog 中排除
    → 在版本规划文档中标注："已排除，因连续 X 个版本未完成"

在空池检测器判断为"有剩余"时：

for each item in 候选池（仅 P0/P1）:
  if item 已在 cycleState.deferredItems 中出现 >= 3 次:
    → 从候选池移除
    → 移入 cycleState.blockedItems
    → 记录 attemptedVersions 列表
    → 在报告中输出："需求 {id} 已被永久阻塞（连续 3 个版本未完成）"
```

### 4.5 致命错误处理器（fatal-error-handler）

**职责**：识别不可恢复的错误，安全地终止循环。

**致命错误列表**：

| 错误类型 | 检测方式 | 处理方式 |
|:---------|:---------|:---------|
| state.json 无法读取/损坏 | 文件读取失败 | abort → 提示运行 devflow-init |
| TRAE 系统目录不可写 | 写入测试失败 | abort → 提示检查权限 |
| 磁盘空间不足 | PowerShell 检测 | abort → 提示清理磁盘 |
| 候选需求池文件损坏 | JSON 解析失败 | abort → 提示修复候选池 |
| 版本号无意义 | 解析失败（如 "abc"） | abort → 提示修正版本号 |

**恢复检测**：每次 fatal error 记录后，间隔 30 分钟后自动重试。连续 3 次 fatal → 永久 abort。

---

## 5. 新增 orchestrator 技能：cycle-state-machine

### 5.1 定位

新 orchestrator 技能，位于 devflow-phase-manager 的上层，管理"版本间循环"的生命周期：
- 读取 `state.json.cycleState` 判断当前循环状态
- 控制循环启动、暂停、恢复、终止
- 在 Step 5 闭环后触发循环终结检查
- 决定是否启动下一版本

### 5.2 状态机

```
                    ┌──────────┐
                    │   idle   │ ← 初始状态
                    └────┬─────┘
                         │ mode = auto_loop 且候选池非空
                         ▼
                    ┌──────────┐
                    │ planning │ ← 检查候选池、确定版本号
                    └────┬─────┘
                         │ 候选池有 P0/P1
                         ▼
              ┌──────────────────────┐
              │  version_executing   │ ← 委托给 devflow-phase-manager
              │  (Step 0 → 5 逐级)   │    控制版本内各 Step 的执行
              └──────────┬───────────┘
                         │ Step 5 闭环
                         ▼
              ┌──────────────────────┐
              │  cycle_checking      │ ← 空池检测 + 滞留检测
              └──────────┬───────────┘
                    ┌────┼────┐
                    │    │    │
                    ▼    ▼    ▼
               ┌────┐ ┌────┐ ┌──────┐
               │    │ │    │ │      │
               │idle│ │暂停│ │完成  │
               │    │ │    │ │      │
               └────┘ └────┘ └──────┘
               (继续)  (等用户) (停止)
```

### 5.3 各状态对应行为

| 状态 | 行为 | 触发下一步的条件 |
|:----|:-----|:----------------|
| `idle` | 等待用户设置为 auto_loop 模式 | 用户在初始化或配置时选择 auto_loop |
| `planning` | 检查候选池，确定版本号，执行空池+滞留检测 | 检测通过 → version_executing；无内容 → completed |
| `version_executing` | 委托 devflow-phase-manager 执行 Step 0~5 | Step 5 closed → cycle_checking |
| `cycle_checking` | 空池检测+滞留检测 | 有剩余 → idle（新版本）；无剩余 → completed；仅 P2 → paused |
| `paused` | 输出状态报告，等待用户 | 用户选择继续/停止 |
| `completed` | 输出最终报告 | — |

### 5.4 切换门禁

| 从 → 到 | 门禁条件 |
|:--------|:---------|
| idle → planning | `cycleState.mode == "auto_loop"` 且候选池非空 |
| planning → version_executing | 空池检测通过（有 P0/P1） |
| version_executing → cycle_checking | `step_5_closed == true` |
| cycle_checking → idle | 候选池有剩余 P0/P1，自动递增版本号 |
| cycle_checking → paused | 候选池仅剩 P2 |
| cycle_checking → completed | 候选池为空，或所有剩余项均被阻塞 |
| paused → idle | 用户确认继续（即使仅 P2 也处理） |
| paused → completed | 用户确认停止 |

---

## 6. 全自动循环执行流程

### 6.1 初始化

```
用户首次配置 auto_loop 模式：
1. 确保候选需求池有内容
2. 设置 state.json → cycleState.mode = "auto_loop"
3. 初始化 cycleState 各字段（retryCount = 0, status = "active"）
4. 输出初始化报告：将在 {版本号} 上开始自动循环
```

### 6.2 版本内循环

```
Version vN 开始:
  Step 0 版本规划:
    ├── 纳入候选 → 空池检测 + 滞留检测
    ├── 产出规划文档
    └── → 人工门禁 → 通过 → retryCount[0] = 0

  Step 1 需求分析:
    ├── 撰写需求文档
    ├── 需求模糊? → defer 模糊项，清晰的继续
    └── → 人工门禁 → 通过 → retryCount[1] = 0

  Step 2 设计:
    ├── 架构设计
    ├── 覆盖率 < 95%?
    │   ├── retry < 3 → 继续修复
    │   └── retry ≥ 3 → 缺口 > 5%? → defer 缺口项；否则降级 pass
    └── → 人工门禁 → 通过 → retryCount[2] = 0

  Step 3 开发:
    ├── 编码实现
    ├── 语法检查/逻辑审查失败?
    │   ├── retry < 3 → 继续修复
    │   └── retry ≥ 3 → defer 失败项
    └── → 人工门禁 → 通过 → retryCount[3] = 0

  Step 4 测试:
    ├── 执行测试矩阵
    ├── P0 失败? → retry < 3 → 继续；≥ 3 → defer
    ├── P1/P2 失败? → 降级为 knownIssues
    ├── 覆盖率 90-94%? → 降级 pass_with_note
    └── → 人工门禁 → 通过 → retryCount[4] = 0

  Step 5 部署:
    ├── 同步到 TRAE
    ├── 致命错误? → abort
    └── → 人工门禁 → 通过 → step_5_closed = true

  → 触发 cycle_checking（版本间循环终结检查）
```

### 6.3 版本间循环

```
Step 5 闭环 → cycle_checking:

  ① 空池检测:
     ├── 候选池为空 → cycleState.status = "completed"
     │                 输出最终报告，停止
     │
     ├── 仅剩 P2 → cycleState.status = "paused"
     │             输出："仅剩低优先级需求，请决定是否继续"
     │
     └── 有 P0/P1 → ② 滞留检测

  ② 滞留检测:
     ├── 有连续 3 版未完成项 → 移入 blockedItems
     │                         在报告中标注排除原因
     └── 正常 → ③ 版本号递增

  ③ 版本号递增:
     ├── deferredItems 有 P0 热修复 → 修订号递增（2.8.0 → 2.8.1）
     └── 新增功能 P0 → 次版本号递增（2.8.0 → 2.9.0）

  ④ 启动下一版本:
     → cycleState.currentVersion = "2.9.0"
     → cycleState.retryCount 全部重置为 0
     → 回到 Step 0，开始新一轮循环
```

---

## 7. 与已有组件的关系

### 7.1 分层架构

```
cycle-state-machine (新增 orchestrator)
    ↑ 版本间循环管理
    ↓ 委托
devflow-phase-manager (已有 L2)
    ↑ 版本内状态机
    ↓ 委托
coding-stage-execution / testing-stage-execution ... (已有 L2 子技能)
    ↑ 各阶段执行
    ↓ 增强
retry-manager / auto-degrade (新增逻辑，嵌入 L2)
```

### 7.2 调用关系

| 调用方 | 被调用方 | 触发场景 |
|:-------|:---------|:---------|
| cycle-state-machine | devflow-phase-manager | 启动/暂停版本内循环 |
| devflow-phase-manager | retry-manager | 每个 Step 门禁检查时 |
| devflow-phase-manager | auto-degrade | 覆盖率/测试失败检查时 |
| cycle-state-machine | empty-pool-detector | Step 5 闭环后 |
| version-planning-stage-execution | stale-item-detector | Step 0 版本规划时 |
| cycle-state-machine | fatal-error-handler | 贯穿所有步，异常捕获时 |

### 7.3 需要修改的已有文件清单

| 文件 | 修改内容 |
|:----|:---------|
| `devflow-phase-manager/SKILL.md` | 嵌入 retry-manager 逻辑；阶段切换门禁前增加 retry 检查 |
| `devflow-phase-manager/SKILL.md` | 支持 cycleState 字段的读写 |
| `devflow-init/SKILL.md` | 初始化时支持设置 mode=auto_loop |
| `version-planning-stage-execution` | 嵌入 stale-item-detector 逻辑 |
| `coding-stage-execution` | retry 超限后自动跳过失败项 |
| `testing-stage-execution` | 降级逻辑：非 P0 失败→knownIssues；覆盖率≥90%→pass_with_note |
| `operations-stage-execution` | Step 5 闭环后触发 cycle_checking |
| `state.json` 结构 | 新增 cycleState 字段 |

---

## 8. 跳出条件完整汇总

### 8.1 正常跳出（预期行为）

| 跳出条件 | 触发时机 | 影响范围 | 自动/人工 |
|:---------|:---------|:---------|:---------:|
| 版本内人工门禁不通过 | 每个 Step 完成后 | 暂停版本内循环，等待用户 | 人工 |
| 候选池为空 | Step 5 闭环后 | 终止版本间循环 | 自动 |
| 候选池仅剩 P2 | Step 5 闭环后 | 暂停版本间循环，等待用户 | 自动+人工确认 |
| 用户手动切换 mode=manual | 任意时刻 | 立即退出 auto_loop | 人工 |

### 8.2 异常跳出（容错机制）

| 跳出条件 | 触发时机 | 影响范围 | 自动/人工 |
|:---------|:---------|:---------|:---------:|
| 单步 retry ≥ maxRetries（3次） | Step 门禁检查时 | 本版跳过该步失败项，继续下一步 | 自动 |
| 同一需求 3 版未完成 | 空池检测时 | 从候选池移除，永久阻塞 | 自动 |
| 致命错误（TRAE不写/磁盘满） | 任意时刻 | 立即终止循环，标记 aborted | 自动 |
| 版本冲突 3 次未解决 | 每次 devflow-init | 跳过版本检测 | 自动 |

### 8.3 死循环防护

| 死循环风险 | 防护机制 | 防护方式 |
|:-----------|:---------|:---------|
| 测试-修复无限循环 | retry-manager（maxRetries=3） | 3 次后自动跳过 |
| 审计门禁无限重试 | retry-manager（maxRetries=3） | 3 次后自动跳过 |
| 覆盖率门禁无限循环 | auto-degrade（≥90% 自动 pass） | 阈值自动降级 |
| 空版本无限循环 | empty-pool-detector | 空池检测自动终止 |
| 版本差异检测重复 | 幂等性保证 | 每次 init 仅触发一次 versionCheck |

---

## 9. 风险与约束

### 9.1 已知风险

| 风险 | 级别 | 说明 | 应对 |
|:-----|:----:|:-----|:-----|
| 自动降级可能导致质量下降 | 🟡 P1 | 覆盖率略低、P2 失败的项被自动通过 | 降级后仍在报告中明确记录，用户可人工审查 |
| deferredItems 持续积累 | 🟡 P1 | 多次跳过后，deferred 项越来越多 | 滞留检测器自动标记永久阻塞；定期提示用户审查 |
| 版本号自动递增不合理 | 🟢 P2 | 自动递增的版本号可能不符合语义化版本规范 | 保留人工 override，用户可修改 state.json 中的 version |
| 候选池 JSON 损坏 | 🔴 P0 | 空池检测无法进行 | fatal-error-handler 捕获，提示修复 |
| mode=auto_loop 与手工操作冲突 | 🟡 P1 | 用户同时在手工推进其他版本 | 检测到 mode=manual 的手工操作时，自动暂停 auto_loop |

### 9.2 约束

1. auto_loop 模式仅在 `state.json.cycleState.mode == "auto_loop"` 时生效
2. 手工模式（manual）下，cycleStyle 所有字段被忽略，保留不做自清理
3. deferredItems 和 blockedItems 在每次版本闭环时自动审查，不手动清理
4. maxRetries 默认 3，用户可手动调整
5. 自动降级仅适用于非 P0 项和覆盖率≥90%场景，P0 失败和覆盖率<90%永不自动降级

---

## 10. 所需新增与修改汇总

### 10.1 新增文件

| 序号 | 文件 | 类型 | 说明 |
|:----:|:-----|:----:|:------|
| F-01 | `cycle-state-machine/SKILL.md` | orchestrator | 版本间循环状态机 |
| F-02 | `doc/design/DevFlow-全自动版本循环执行架构设计文档-*` | 设计文档 | 本文档 |

### 10.2 新增需求

| ID | 名称 | 来源 |
|:--:|:-----|:-----|
| V260-039 | 重试管理器（retry-manager） | 全自动循环 |
| V260-040 | 空池检测器（empty-pool-detector） | 全自动循环 |
| V260-041 | 自动降级机制（auto-degrade） | 全自动循环 |
| V260-042 | 致命错误处理器（fatal-error-handler） | 全自动循环 |
| V260-043 | 循环状态机（cycle-state-machine） | 全自动循环 |

### 10.3 修改文件

| 序号 | 文件 | 影响范围 |
|:----:|:-----|:---------|
| M-01 | `devflow-phase-manager/SKILL.md` | L2：嵌入 retry-manager + 支持 cycleState 字段 |
| M-02 | `devflow-init/SKILL.md` | orchestrator：初始化支持 auto_loop 模式 |
| M-03 | `version-planning-stage-execution` | L2：嵌入 stale-item-detector |
| M-04 | `coding-stage-execution` | L2：retry 超限后自动跳过失败项 |
| M-05 | `testing-stage-execution` | L2：新增自动降级逻辑 |
| M-06 | `operations-stage-execution` | L2：闭环后触发 cycle_checking |
| M-07 | `state.json` 结构定义 | 新增 cycleState 字段 |

---

## 11. 未解决问题

| 问题 | 待决策 | 建议方案 |
|:-----|:-------|:---------|
| 空池检测器读取候选池的方式 | 文件路径固定还是可配置？ | 固定路径 `doc/version/global/DevFlow-候选需求池.md` |
| 版本号自动递增策略 | 修订号 vs 次版本号 vs 主版本号 | deferredItems 有 P0 热修复→修订号；新增功能→次版本号；用户指定→主版本号 |
| auto_loop 中途用户插手工操作 | 冲突解决策略 | 检测到手工操作→自动暂停 auto_loop，输出冲突报告 |
| maxRetries 默认值 | 默认几次？ | 3 次（平衡容错与质量） |
| deferredItems 的审查周期 | 多久审查一次？ | 每次版本闭环时自动审查，同时提示用户手动审查 |