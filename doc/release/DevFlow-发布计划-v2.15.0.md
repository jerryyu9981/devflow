# DevFlow 发布计划 — v2.15.0

> 文档类型：发布计划
> 版本：v2.15.0
> 状态：[Approved]
> 日期：2026-08-02
> 作者：DO-DevFlow-Dev（DevOps工程师）

---

## 1. 发布概述

| 项目 | 内容 |
|:-----|:------|
| 发布版本 | v2.15.0（T1-T4 四层测试架构 + 版本号单一事实源 + 路由映射表 diff + Stage4 产出物增强 + Git hook 规范化）|
| 发布窗口 | 2026-08-02 |
| 发布类型 | 功能版本（次版本递增）|
| 发布范围 | testing-stage-execution T1-T4 架构集成 + api-contract-management diff 机制 + Stage4 产出物清单 + 版本号单一事实源 + Git hook 规范 |
| 变更类型 | 文档规范 + 验证脚本 + 配置文件 |
| 影响评估 | 增强 testing-stage-execution 和 api-contract-management 技能；弃用 version.json；新增 validate-version-header.ps1 脚本 |
| 发布负责人 | DO-DevFlow-Dev |
| 审批人 | 用户（人工门禁）|

---

## 2. 发布版本记录

| 项目 | 内容 |
|:-----|:------|
| 版本号 | v2.15.0 |
| 分支 | master |
| 最近 commit | 739ea0a（v2.13.0 发布 commit）|
| 待提交变更 | Step 0~4 全部产出物 + Step 5 发布文档 + 版本号更新 |
| Git tag | v2.15.0（待创建）|
| 制品版本 | devflow-config.json devflowVersion = 2.15.0 |
| 部署方式 | Git 仓库推送（文档规范项目，无运行时部署）|

### 变更摘要

| BL-ID | 需求描述 | 优先级 | 状态 |
|:------:|:---------|:------:|:----:|
| BL-215-001 | T1-T4 四层测试架构集成到 testing-stage-execution | P0 | ✅ 完成 |
| BL-215-002 | 路由映射表 diff 机制增强 api-contract-management | P1 | ✅ 完成 |
| BL-215-003 | Stage4 产出物清单新增 T1-T4 相关产出 | P1 | ✅ 完成 |
| BL-215-004 | 版本号单一事实源落地（TD-031 偿还） | P0 | ✅ 完成 |
| BL-215-005 | Git post-push 自动备份 hook 纳入规范 | P2 | ✅ 完成 |

---

## 3. 全阶段产出物盘点

### 盘点规则

空输出率 = 0% 才允许发布。以下为 6 个阶段（Step 0~5）产出物逐一盘点结果。

### Step 0 版本规划

| 文件 | 存在性 |
|:-----|:------:|
| doc/version/releases/v2.15.0/DevFlow-单版本规划文档-v2.15.0.md | ✅ |
| doc/version/releases/v2.15.0/DevFlow-Phase迭代计划-v2.15.0.md | ✅ |
| doc/version/releases/v2.15.0/DevFlow-本版本Backlog-v2.15.0.md | ✅ |
| doc/version/releases/v2.15.0/DevFlow-版本规划评审记录-v2.15.0.md | ✅ |

**Step 0 产出**：4/4 = 100% ✅

### Step 1 需求分析

| 文件 | 存在性 |
|:-----|:------:|
| doc/requirements/DevFlow-开发需求文档-v2.15.0.md | ✅ |
| doc/requirements/DevFlow-需求追溯矩阵-v2.15.0.md | ✅ |
| doc/requirements/DevFlow-需求评审记录-v2.15.0.md | ✅ |
| doc/requirements/DevFlow-需求基线及设计移交说明-v2.15.0.md | ✅ |
| doc/requirements/DevFlow-需求来源与干系人-v2.15.0.md | ✅ |

**Step 1 产出**：5/5 = 100% ✅

### Step 2 架构与设计

| 文件 | 存在性 |
|:-----|:------:|
| doc/design/DevFlow-系统架构设计文档-v2.15.0.md | ✅ |
| doc/design/DevFlow-非功能设计说明-v2.15.0.md | ✅ |
| doc/design/DevFlow-设计评审记录-v2.15.0.md | ✅ |
| doc/design/DevFlow-设计基线及开发测试移交说明-v2.15.0.md | ✅ |

**Step 2 产出**：4/4 = 100% ✅

### Step 3 开发 / 编码

| 文件 | 存在性 |
|:-----|:------:|
| doc/development/DevFlow-DevLogReport-v2.15.0.md | ✅ |
| doc/development/DevFlow-TD-ID追溯矩阵-v2.15.0.md | ✅ |
| doc/development/DevFlow-代码逻辑审查记录-v2.15.0.md | ✅ |
| doc/development/DevFlow-实际运行验证记录-v2.15.0.md | ✅ |
| doc/development/DevFlow-静态质量检查记录-v2.15.0.md | ✅ |
| doc/development/DevFlow-开发审计移交材料-v2.15.0.md | ✅ |

**Step 3 产出**：6/6 = 100% ✅

### Step 4 测试

| 文件 | 存在性 |
|:-----|:------:|
| doc/testing/DevFlow-测试计划-v2.15.0.md | ✅ |
| doc/testing/DevFlow-测试报告-v2.15.0.md | ✅ |
| doc/testing/DevFlow-测试用例-v2.15.0.md | ✅ |
| doc/audit/verification/DevFlow-测试回溯对比审计报告-v2.15.0.md | ✅ |
| doc/testing/evidence/DevFlow-测试执行证据-v2.15.0.md | ✅ |
| doc/audit/review/DevFlow-阶段审计报告-Stage4-v2.15.0.md | ✅ |

**Step 4 产出**：6/6 = 100% ✅

### Step 5 部署与运维

| 文件 | 存在性 |
|:-----|:------:|
| doc/release/DevFlow-发布入场检查记录-v2.15.0.md | ✅ |
| doc/release/DevFlow-发布计划-v2.15.0.md | ✅（本文件）|
| doc/release/DevFlow-部署执行报告-v2.15.0.md | 🔄 待产出 |
| doc/release/DevFlow-上线检查报告-v2.15.0.md | 🔄 待产出 |
| doc/release/DevFlow-回滚方案-v2.15.0.md | 🔄 待产出 |
| doc/release/DevFlow-运维手册-v2.15.0.md | 🔄 待产出 |
| doc/release/DevFlow-发布复盘报告-v2.15.0.md | 🔄 待产出 |
| doc/release/DevFlow-问题跟踪记录-v2.15.0.md | 🔄 待产出 |
| doc/release/DevFlow-Release-Note-v2.15.0.md | 🔄 待产出 |
| doc/audit/comprehensive/DevFlow-运维审计报告-v2.15.0.md | 🔄 待产出 |
| doc/audit/comprehensive/DevFlow-全流程闭环审计报告-v2.15.0.md | 🔄 待产出 |
| doc/audit/review/DevFlow-阶段审计报告-Stage5-v2.15.0.md | 🔄 待产出 |

**Step 5 产出**：2/12 已完成，10/12 待产出（本步骤进行中）

### 盘点结论

| 阶段 | 产出率 | 结论 |
|:----:|:------:|:----:|
| Step 0 | 4/4 = 100% | ✅ |
| Step 1 | 5/5 = 100% | ✅ |
| Step 2 | 4/4 = 100% | ✅ |
| Step 3 | 6/6 = 100% | ✅ |
| Step 4 | 6/6 = 100% | ✅ |
| Step 5 | 进行中 | 🔄 |
| **空输出率** | **0%（Step 0~4）** | **✅ 允许发布** |

---

## 4. 发布方式与步骤

### 4.1 部署方式

本项目为文档规范框架，无运行时部署。部署方式为：

1. Git commit — 提交 v2.15.0 全部变更
2. Git tag — 创建 v2.15.0 标签
3. Git push origin — 推送到主远程仓库
4. Git push backup — 推送到备份远程仓库（自动 hook 触发）
5. release.ps1 — 执行发布脚本（版本号同步 + state.json 更新）

### 4.2 发布步骤

| 步骤 | 活动 | 负责人 | 产出 |
|:----:|:-----|:-------|:-----|
| 5.1 | 发布计划 + 版本号更新 | DO-DevFlow-Dev | 发布计划 + 版本号已更新 |
| 5.2 | 环境配置核验 + 产出物盘点 | DO-DevFlow-Dev | 产出物盘点（本文件 §3）|
| 5.3 | 部署执行（commit + tag + push）| DO-DevFlow-Dev | 部署执行报告 |
| 5.4 | 上线验证（版本一致性 + 脚本验证）| OE-DevFlow-Dev | 上线检查报告 |
| 5.5 | 回滚方案 + 运维移交 | DO-DevFlow-Dev | 回滚方案 + 运维手册 |
| 5.6 | 发布复盘 + Release Note | DO-DevFlow-Dev | 发布复盘报告 + Release Note |
| 5.7 | 运维审计 + 全流程闭环 | AU-DevFlow-Dev | 运维审计报告 + 全流程闭环审计报告 |

### 4.3 通知对象

| 对象 | 通知内容 | 通知方式 |
|:-----|:---------|:---------|
| 项目负责人 | v2.15.0 发布完成 | 对话交付 |
| DevFlow 用户 | Release Note v2.15.0 | 仓库 README + Release Note |

### 4.4 冻结窗口

| 项目 | 内容 |
|:-----|:------|
| 冻结起始 | 2026-08-02 发布开始 |
| 冻结结束 | 2026-08-02 发布完成 |
| 冻结范围 | master 分支，禁止非发布相关提交 |

---

## 5. 环境配置核验

### 5.1 环境差异

| 环境 | 用途 | 配置 |
|:-----|:-----|:-----|
| Dev | 开发环境（当前）| 本地 Git 仓库 + PowerShell 5.1 |
| Test | 测试环境 | 同 Dev（文档项目无独立测试环境）|
| Pro | 生产环境 | Git 远程仓库（origin + backup + github）|

### 5.2 配置文件核验

| 配置文件 | 版本号 | 状态 |
|:---------|:-------|:----:|
| devflow-plugin/devflow-config.json | devflowVersion = 2.15.0 | ✅ |
| .devflow/project-config.json | project.version = v2.15.0 | ✅ |
| .devflow/project-config.json | lastRelease.version = v2.15.0 | ✅ |
| .devflow/state.json | devflowVersion = 2.15.0 | ✅ |
| version.json | 已弃用并删除 | ✅ |

### 5.3 数据库迁移

| 项目 | 状态 |
|:-----|:----:|
| 数据库迁移 | ✅ N/A — 文档/脚本型项目，无数据库 |

### 5.4 缓存与消息

| 项目 | 状态 |
|:-----|:----:|
| 缓存清理 | ✅ N/A — 文档/脚本型项目，无缓存 |
| 消息队列 | ✅ N/A — 文档/脚本型项目，无消息队列 |

---

## 6. 发布 Checklist

### 发布前

- [✅] 版本号确认 — `Get-Content devflow-plugin\devflow-config.json | Select-String "devflowVersion"` → 输出 "2.15.0"
- [✅] Backlog 完成度确认 — 5/5 BL-ID 全部 ✅ 完成
- [✅] 测试报告确认 — 读取测试报告 §结论 → "✅ 通过"
- [🔄] 审计报告确认 — 全流程闭环审计报告待生成
- [✅] 全阶段产出物盘点通过 — Step 0~4 空输出率 = 0%
- [✅] 版本迭代路线图已更新 — grep v2.15.0 路线图 → 匹配

### 发布时

- [🔄] release.ps1 执行完成 — 待执行
- [🔄] Git Tag 已创建并推送 origin — 待执行
- [🔄] Git Tag 已推送 backup — 待执行

### 发布后

- [🔄] Tag 存在性验证 — 待验证
- [🔄] 远程仓库同步验证 — 待验证
- [🔄] 备份仓库同步验证 — 待验证
- [✅] 版本号一致性验证 — 3 处配置文件均为 v2.15.0
- [🔄] Release Note 已生成 — 待生成
- [🔄] Changelog 已更新 — 待更新
- [🔄] 用户指南已更新 — 待更新
- [🔄] 用户手册已更新 — 待更新
- [🔄] 候选需求池状态已同步 — 待同步

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-02 | 初始创建，发布计划 + 全阶段产出物盘点 + 发布 Checklist | DO-DevFlow-Dev |
