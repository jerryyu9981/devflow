# DevFlow 发布计划 — v2.17.0

> 文档类型：发布计划
> 版本：v2.17.0
> 日期：2026-08-18
> 作者：DO-DevFlow-Dev（DevOps工程师）

---

## 1. 发布概览

| 项 | 内容 |
|:---|:-----|
| 版本号 | v2.17.0（规范衔接完善）|
| 发布类型 | 次版本（规范结构性增强）|
| 发布方式 | Git tag + 三远程推送 + IDE 技能推送（无运行时部署）|
| 发布窗口 | 2026-08-18（工作日）|
| 发布负责人 | DO-DevFlow-Dev |
| 影响范围 | 4 个技能文档（design/coding/testing-stage-execution + project-document-templates）+ 预研报告 + 版本文档 |
| 通知对象 | DevFlow 使用团队 |

## 2. 版本与制品

| 项 | 内容 |
|:---|:-----|
| Git Tag | v2.17.0 |
| 分支 | main（release 流程）|
| devflow-config.json devflowVersion | 2.17.0（已更新）|
| 制品 | 4 个技能文档（主源 + 副本 12 处同步）|
| 变更摘要 | SPEC-291 遗留闭合 3 项 + 原型衔接规范 3 项 |

## 3. 发布步骤

| 步骤 | 内容 | 验证 |
|:-----|:-----|:-----|
| 1 | git add 全部变更 + commit（footer 引用 RT-217-XXX）| git log 确认 |
| 2 | git tag v2.17.0 | git tag -l v2.17.0 |
| 3 | git push origin + backup + github（含 tag）| git ls-remote 三远程确认 |
| 4 | update.ps1 推送 IDE 技能（4 个技能）| IDE 副本 MD5 一致 |
| 5 | 生成 Release Note + 更新 Changelog | Test-Path + grep |

## 4. 冻结与回滚

| 项 | 内容 |
|:---|:-----|
| 发布冻结 | 发布前 24 小时冻结代码合入（本版本已满足）|
| 回滚策略 | Git revert 到 v2.16.0 tag；技能文档回退到 v2.16.0 版本 |
| 紧急回滚 | P0 故障可绕过审批，2 小时补材料 |

## 5. 部署验证清单（关联 TT-ID）

| 验证项 | 关联 TT-ID | 预期结果 |
|:-------|:----------:|:---------|
| 4 技能文档修改存在 | TT-217-001~017 | Grep/LS 命中 |
| 副本一致性 | TT-217-001~017 | MD5 12/12 一致 |
| Git tag 创建 | — | git tag -l v2.17.0 命中 |
| 三远程推送 | — | git ls-remote 三远程均命中 |
| IDE 技能推送 | — | IDE 副本 MD5 一致 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-18 | 初始创建，定义发布步骤与验证清单 | DO-DevFlow-Dev |
