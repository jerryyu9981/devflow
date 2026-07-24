---
name: "project-role-management"
description: "Manages project role coordination rules and agent assignments. Invoke when user asks about role responsibilities, coordination conditions, or agent naming conventions."
---

# Project Role Management (项目角色管理)

## Overview

本技能定义项目角色体系，包括角色定义、命名规范、审批门禁和审计门禁。Solo 模式下所有角色由同一 AI 代理按阶段心智切换，本技能主要用于**审计职责定义、审批卡点和角色命名**。

## Role Definitions

### Core Roles

| Role | Abbreviation | Solo 心智切换阶段 |
|------|:-----------:|:-----------------|
| 项目经理 | PM | 全流程（阶段转换/资源协调） |
| 需求分析师 | RA | Step 1 需求分析 |
| Agent架构师 | AA | Step 2 系统架构设计 |
| 前端架构师 | FA | Step 2 前端架构设计 |
| UI设计师 | UI | Step 2 UI/UX 设计 |
| Agent开发工程师 | AD | Step 3 后端编码 |
| 前端工程师 | FD | Step 3 前端编码 |
| API测试工程师 | AT | Step 4 API 测试 |
| 安全工程师 | SE | Step 4 安全/合规测试 |
| 审计师 | AU | 全流程（阶段审计门禁） |
| DevOps工程师 | DO | Step 5 部署 |
| 运维工程师 | OE | Step 5 运维监控 |

### Auditor Agent 职责详情

审计师独立于开发和测试视图，负责以下审计工作：

| 阶段 | 审计类型 | 审计内容 | 审计产出 |
|------|---------|---------|---------|
| Step 1 | 评估报告 | 前期可行性分析、技术方案评估 | `{项目名}-{评估主题}评估报告`，固定存放于 `doc\audit\assessment` |
| Step 2 | 需求架构对比 | 对照需求文档检查架构设计覆盖率（≥95%）| `{项目名}-需求架构对比审计报告`，固定存放于 `doc\audit\review` |
| Step 3 | 开发设计对比 | 对照设计文档检查开发实现覆盖率（≥90%）| `{项目名}-开发设计对比审计报告`、`{项目名}-UI需求对比审计报告`，固定存放于 `doc\audit\review` |
| Step 4 | 测试回溯对比 | 检查测试是否覆盖所有需求和缺陷 | `{项目名}-测试回溯对比审计报告`，固定存放于 `doc\audit\verification` |
| Step 5 | 全流程闭环 | 综合检查所有阶段产物和审计问题闭环 | `{项目名}-全流程闭环审计报告`、`{项目名}-运维审计报告`，固定存放于 `doc\audit\comprehensive` |

## Agent Naming Conventions

### Format
```
{角色类型}-{项目名}-{环境}
```
Examples: RA-CoPlayer-Dev, AA-CoPlayer-Test, AU-CoPlayer-Dev, DO-CoPlayer-Pro

### Abbreviations

| Role Type | Abbreviation | Example |
|-----------|:-----------:|---------|
| 项目经理 | PM | PM-CoPlayer-Dev |
| 需求分析师 | RA | RA-CoPlayer-Dev |
| Agent架构师 | AA | AA-CoPlayer-Dev |
| 前端架构师 | FA | FA-CoPlayer-Dev |
| UI设计师 | UI | UI-CoPlayer-Dev |
| Agent开发工程师 | AD | AD-CoPlayer-Dev |
| 前端工程师 | FD | FD-CoPlayer-Dev |
| API测试工程师 | AT | AT-CoPlayer-Dev |
| 安全工程师 | SE | SE-CoPlayer-Dev |
| 审计师 | AU | AU-CoPlayer-Dev |
| DevOps工程师 | DO | DO-CoPlayer-Dev |
| 运维工程师 | OE | OE-CoPlayer-Pro |

## Coordination Rules

### General Rules

1. **上行下达**：PM 统一协调任务分配和阶段流转
2. **横向协作**：同级角色按需直接沟通（如 AD↔FD 接口协商）
3. **人工确认**：关键节点（阶段准入/审批/发布）需人类批准
4. **审计门禁**：每个阶段必须通过 AU 审计后方可进入下一阶段
5. **问题处理**：遇到跨领域问题直接向人类用户汇报决策

### Solo 模式执行说明

Solo 模式下，所有角色由同一 AI 代理按阶段自动切换心智模型。各阶段的执行细节由对应的 `-stage-execution` 技能定义，不以角色之间的手顺流转为依据。

## Human Approval Requirements

### Approval Gates

| Step | Gate | Approver | Required |
|------|------|----------|----------|
| 0 | 版本规划评审 | 用户 | Yes |
| 1 | 需求评审通过 | 用户 | Yes |
| 2 | 设计评审通过 | 用户 | Yes |
| 3 | 代码提测批准 | 用户 | Yes |
| 4 | 测试通过确认 | 用户 | Yes |
| 5 | 上线发布批准 | 用户 | Yes |

### Audit Gates

| Step | Audit Gate | Auditor | Required |
|------|-----------|---------|---------|
| 0 | 版本规划评审通过 | AU | Yes |
| 1 | 需求评估通过 | AU | Yes |
| 2 | 需求架构对比审计通过（覆盖率>=95%） | AU | Yes |
| 3 | 开发设计对比/UI需求对比审计通过（覆盖率>=90%） | AU | Yes |
| 4 | 测试回溯对比审计通过 | AU | Yes |
| 5 | 运维审计 + 全流程闭环审计通过 | AU | Yes |

## Role Availability by Environment

| Environment | Available Roles |
|------------|-----------------|
| Dev | RA, AA, FA, UI, AD, FD, AU |
| Test | AT, SE, AU, DO |
| Pro | DO, OE, AU |

## Usage

调用此技能的场景：
- 查询角色职责和缩写
- 配置 Agent 命名
- 确认审批门禁和审计门禁要求
- 理解审计师的职责范围

## Version Planning Stage Integration

When this skill is used during Step 0 version planning, coordinate with `version-planning-stage-execution`.

- Treat `version-planning-stage-execution` as the Step 0 controller.
- Keep global version documents separate from single-version documents according to `project-document-management`.
- Do not let detailed requirements, design, development, or testing work start until Step 0 approval confirms version goals, scope, priorities, risks, and handoff inputs.

## Design Stage Integration

When this skill is used during the formal design stage, coordinate with design-stage-execution.

- Treat design-stage-execution as the Step 2 design-stage controller.
- Use this skill only for its specialty area; do not use it to declare the whole design stage complete.
- Record design decisions, assumptions, alternatives, risks, open questions, and downstream impacts in the relevant design document.
- Do not let a successful specialty design review replace the Step 2 design review or requirements-architecture audit.
- If a P0/P1 design gap is found, fix it within Step 2, update the relevant design document and traceability matrix, then rerun the relevant design review before development handoff.

## Requirements Stage Integration

When this skill is used during the formal requirements stage, coordinate with `requirements-stage-execution`.

- Treat `requirements-stage-execution` as the Step 1 requirements-stage controller.
- Use this skill only for its specialty area; do not use it to declare the whole requirements stage complete.
- Record requirement sources, assumptions, constraints, open questions, decisions, acceptance criteria, and downstream impacts in the relevant requirements document.
- Do not let a successful specialty analysis replace the Step 1 requirements review or requirements audit.
- If a P0/P1 requirement gap is found, fix it within Step 1, update the requirements baseline and traceability matrix, then rerun the relevant requirements review before design handoff.

## Operations Stage Integration

When this skill is used during the formal deployment and operations stage, coordinate with operations-stage-execution.

- Treat operations-stage-execution as the Step 5 deployment-and-operations controller.
- Use this skill only for its specialty area; do not use it to declare the whole operations stage complete.
- Record commands, environment, release version, verification evidence, risks, rollback steps, and follow-up actions in the relevant operations document.
- Do not let a successful specialty deployment or check replace Step 5 release verification or operations audit.
- If a P0/P1 deployment or production issue is found, stop rollout or trigger rollback, update release records, and rerun the required verification.

## 变更记录

| 日期 | 变更内容 | 变更人 |
|---|---|---|
| 2026-07-02 | 添加变更记录章节 | jerry.yu |
