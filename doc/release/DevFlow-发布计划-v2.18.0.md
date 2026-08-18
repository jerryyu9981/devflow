# DevFlow 发布计划 — v2.18.0

> 文档类型：发布计划
> 版本：v2.18.0
> 日期：2026-08-19
> 作者：DO-DevFlow-Dev（DevOps工程师）

---

## 1. 发布概览

| 项 | 内容 |
|:---|:-----|
| 版本号 | v2.18.0（自动化落地 + 基础设施修复）|
| 发布类型 | 次版本（规范增强 + 基础设施修复）|
| 发布方式 | Git tag + 三远程推送 + IDE 技能推送（无运行时部署）|
| 发布窗口 | 2026-08-19 |
| 发布负责人 | DO-DevFlow-Dev |
| 影响范围 | testing-stage-execution（3 章节）+ hook 修复（push-with-backup/post-push/pre-push）+ 用户指南/手册 |
| 通知对象 | DevFlow 使用团队 |

## 2. 版本与制品

| 项 | 内容 |
|:---|:-----|
| Git Tag | v2.18.0 |
| devflow-config.json devflowVersion | 2.18.0（已更新）|
| 制品 | testing-stage-execution（63KB，3 章节）+ hook 脚本 3 个 + 用户文档 2 个 |
| 变更摘要 | SPEC-291 完全闭环（T3a 自动化实施）+ pre-push hook 递归修复 + 用户文档同步 |

## 3. 发布步骤

| 步骤 | 内容 | 验证 |
|:-----|:-----|:-----|
| 1 | git add 全部变更 + commit（footer 引用 RT-218-XXX）| git log 确认 |
| 2 | git tag v2.18.0 | git tag -l v2.18.0 |
| 3 | 三远程推送（--no-verify，hook 修复后应不挂起）| git ls-remote 三远程 |
| 4 | **TT-218-005b 验证**：push-with-backup.ps1 显式调用（验证备份 + TAG-CHECK 不挂起）| 日志 TAG-CHECK PASS |
| 5 | 生成 Release Note + 更新 Changelog + 路线图/候选需求池 | Grep 验证 |

## 4. 冻结与回滚

| 项 | 内容 |
|:---|:-----|
| 回滚策略 | Git revert 到 v2.17.0 tag；hook 脚本回滚（v2.17.0 版本）|
| 紧急回滚 | P0 故障可绕过审批，2 小时补材料 |

## 5. 部署验证清单（关联 TT-ID）

| 验证项 | 关联 TT-ID | 预期结果 |
|:-------|:----------:|:---------|
| 3 章节存在 | TT-218-001~003 | Grep 命中 |
| hook --no-verify | TT-218-004 | Grep 命中 |
| tag 检查逻辑 | TT-218-005a | TAG-CHECK 存在 |
| **推送端到端** | **TT-218-005b** | **push 不挂起 + 三远程 tag 解引用一致** |
| 用户文档版本号 | TT-218-006 | v2.18.0 命中 |
| 副本一致性 | TT-218-001~006 | MD5 3/3 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-19 | 初始创建，定义发布步骤与验证清单（含 TT-218-005b 端到端验证）| DO-DevFlow-Dev |
