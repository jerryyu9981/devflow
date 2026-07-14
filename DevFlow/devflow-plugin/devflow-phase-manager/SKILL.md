---
name: devflow-phase-manager
description: "DevFlow 阶段状态机。管理项目当前所处的开发阶段（Step 0-5），记录已完成阶段，控制阶段切换门禁。每个会话开始时读取状态，阶段完成时更新状态。"
---

# DevFlow 阶段管理器（devflow-phase-manager）

## 定位

本技能是 DevFlow 框架的**阶段状态机**。它解决的核心问题是：

> "AI 编程智能体在跨会话时没有记忆——不知道项目已经进行到哪一步了。"

本技能通过 `.devflow/state.json` 文件持久化阶段状态，让每次新的会话都能正确接续上一次的工作。

## 触发条件

- 每次会话开始时（读取当前阶段）
- 用户询问"现在项目在哪个阶段"
- 某阶段完成后，准备进入下一阶段前（阶段切换门禁检查）
- 审计评审通过/不通过时（更新 auditResults）

## 状态文件结构

`.devflow/state.json`：

```json
{
  "project": "MyProject",
  "devflowVersion": "v1.0.0",
  "mode": "full_loop",
  "currentPhase": "step_3_coding",
  "completedPhases": ["step_0_planning", "step_1_requirements", "step_2_design"],
  "currentDocuments": {
    "requirementsTraceMatrix": "doc/requirements/MyProject-需求追溯矩阵-v1.0.0.md",
    "designDevTraceMatrix": "doc/development/MyProject-设计开发追溯矩阵-v1.0.0.md"
  },
  "auditResults": {
    "step_0_review": "passed",
    "step_1_review": "passed",
    "step_1_assessment": "passed",
    "step_2_review": "passed",
    "step_2_arch_audit": "passed"
  },
  "standaloneEntries": {}
}
```

## LLM 模式决策逻辑

每次会话启动时，LLM 按以下决策树确定模式：

### 三步判定法

```text
第1步：读取 state.json
  ├── 文件不存在 → 独立模式（无状态降级）
  └── 文件存在 → 第2步

第2步：读取 mode 字段
  ├── mode=standalone → 独立模式
  └── mode=full_loop → 第3步

第3步：userRequest 指向的阶段，其上一阶段是否在 completedPhases 中？
  ├── 是 → 全流程模式（基础层+扩展层检查）
  └── 否 → 自动降级为独立模式（记录降级原因到 standaloneEntries）
```

### 核心原则
1. **state.json 优先**：有文件 + mode=full_loop + completedPhases 连续 → 全流程模式；否则独立
2. **userRequest 覆盖**：用户明确说"跳过"时，即使 state.json 设定了 full_loop 也走独立
3. **降级不报错**：全流程因前置断裂降级时正常执行并记录原因
4. **状态持久化**：mode 是唯一永久记录，LLM 不依赖对话上下文推断

## 阶段切换规则

### 标准切换流程

```
Step N 触发
  ├── 全流程模式：Step N 完成 → 完成标准检查 → 审计门禁 → 更新 completedPhases → 确认 source 对接下一阶段 → 进入 Step N+1
  └── 独立模式：Stage N 完成 → 独立审计 → 更新 standaloneEntries → 产出归档（不更新 completedPhases）
```

### 各阶段的切换门禁

| 从 → 到 | 门禁条件 | source 验证 | 状态更新 |
|---------|---------|------------|---------|
| Step 0 → Step 1 | 版本规划评审通过 | — | `completedPhases` 追加 `step_0_planning` |
| Step 1 → Step 2 | 需求评审通过 + 需求评估审计通过 | RT-ID 追溯矩阵完整性检查 | `auditResults` 更新 |
| Step 2 → Step 3 | 设计评审通过 + 需求架构对比审计覆盖率 ≥ 95% | DT-ID 全覆盖检查 | `auditResults` 更新 |
| Step 3 → Step 4 | 静态质量检查通过 + 代码逻辑审查通过 + 开发审计通过 | TD-ID 格式规范 + 覆盖率 ≥ 95% | `auditResults` 更新 |
| Step 4 → Step 5 | 14 类测试矩阵通过 + 测试回溯审计通过 | TD-ID→TT-ID 映射覆盖 + 缺陷闭环 | `auditResults` 更新 |
| Step 5 → 结束 | 运维审计通过 + 全流程闭环审计通过 | 部署验证项关联 TT-ID + 追溯链闭环 | `step_5_closed = true` |

### 回退规则

如果审计不通过：
- 不更新 `completedPhases`
- 在 `auditResults` 中记录 `failed` 和失败原因
- 提示用户修复问题后重新提交审计

## 独立模式记录

### standaloneEntries 字段说明

```json
"standaloneEntries": {
  "step_3": {
    "entryDate": "2026-07-07",
    "externalSource": "用户描述: 紧急Bug修复",
    "originalMode": "full_loop",
    "downgradeReason": "completedPhases 不包含 step_2",
    "auditPassed": true,
    "auditDate": "2026-07-08"
  }
}
```

**约束**：
- standaloneEntries 仅在独立模式入场时写入
- 同一阶段不得重复独立入场
- 已存在的 standaloneEntries 阶段不接受全流程模式接管

## 会话启动时的标准提示

每次会话开始时，本技能向 LLM 注入以下上下文：

```
【DevFlow 状态】
项目：{project}
当前阶段：{currentPhase}（{中文阶段名}）
已完成阶段：{completedPhases}
当前文档：{currentDocuments}

注意：所有操作必须遵守当前阶段的门禁规则。
如需切换阶段，必须先通过对应的审计检查。
```

## 与 L2 阶段技能的协作

| L2 技能 | 协作方式 |
|---------|---------|
| `version-planning-stage-execution` | 完成后调用本技能更新 `currentPhase` → `step_1_requirements` |
| `requirements-stage-execution` | 完成后更新 `currentPhase` → `step_2_design` |
| `design-stage-execution` | 完成后更新 `currentPhase` → `step_3_coding` |
| `coding-stage-execution` | 完成后更新 `currentPhase` → `step_4_testing` |
| `testing-stage-execution` | 完成后更新 `currentPhase` → `step_5_deploy` |
| `operations-stage-execution` | 完成后标记 `step_5_closed = true` |

## 约束

- 本技能**不执行任何阶段的具体工作**
- 本技能**只管理状态转换的门禁**
- 状态文件必须是有效的 JSON，损坏时自动从 devflow-init 重新初始化
