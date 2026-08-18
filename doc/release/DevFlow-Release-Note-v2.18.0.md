# DevFlow Release Note — v2.18.0

> 版本：v2.18.0
> 发布日期：2026-08-19
> 类型：次版本（自动化落地 + 基础设施修复）
> 前置版本：v2.17.0

---

## 版本定位

v2.18.0 实现 **SPEC-291 完全闭环**：将 v2.17.0 预研结论落地为正式规范内容（T3a 自动化巡检），并修复发布基础设施问题（pre-push hook 递归 + 用户文档版本滞后）。

## 新增能力

### 网络层巡检自动化实施（SPEC-291 完全闭环）

- **T3a 网络层巡检 E2E 用例模板**：testing-stage-execution 新增正式 pytest 用例（attach_network_listeners + 全路由导航 + assert_network_clean + 逐页问题表 JSON 输出），全栈项目 Step 4 标准动作闭环
- **CI 回归集成示例**：GitHub Actions job 定义 + GitLab CI 等价说明（含平台适配标注）
- **巡检结果自动报告方案**：pytest-html 自动生成 HTML 报告，替代手工问题表整理

### 基础设施修复

- **pre-push hook 递归修复**（F-217-501 闭环）：push-with-backup.ps1 与 post-push hook 的 mirror 命令加 `--no-verify` 防递归；新增 Phase 4 远程 tag 一致性检查（TAG-CHECK）
- **用户指南/手册版本号同步**（F-217-502 闭环）：两文档更新至 v2.18.0 + changelog 补齐 v2.17.0/v2.18.0

## 变更文件

| 文件 | 变更 |
|:-----|:-----|
| devflow-plugin/skills/L2/testing-stage-execution.md | 新增 3 章节（~60 行）|
| .devflow/hooks/push-with-backup.ps1 | --no-verify ×2 + TAG-CHECK 逻辑 |
| .devflow/hooks/post-push + .git/hooks/pre-push | --no-verify 防递归 |
| DevFlow-用户指南.html + DevFlow-用户手册.html | 版本号 v2.18.0 |

## 测试与质量

| 项 | 结果 |
|:---|:-----|
| 验收标准 | 6/6 通过（含 TT-218-005b 推送端到端 TAG-CHECK PASS）|
| 需求覆盖 | 3/3 = 100% |
| P0/P1 缺陷 | 0 |
| 审计 | Stage0~4 审计全部通过 |

## 后续计划

- v2.19.0 候选：push-with-backup.ps1 exit code 捕获瑕疵（P3）+ github mirror main 保护适配（P3）
- v3.0.0：全自动循环架构（需预研完成）

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-19 | 初始创建，v2.18.0 发布说明（SPEC-291 完全闭环）| DO-DevFlow-Dev |
