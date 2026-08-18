# DevFlow 测试执行证据 — v2.18.0

> 文档类型：测试执行证据
> 版本：v2.18.0
> 日期：2026-08-19
> 关联测试：TT-218-001~006

---

## 1. 测试执行结果汇总

| TT-ID | 用例名称 | 结果 | 验证方式 |
|:-----:|:---------|:----:|:---------|
| TT-218-001 | T3a E2E 用例模板章节 | ✅ 通过 | Grep 命中章节标题 + `def test_t3a_network_scan` |
| TT-218-002 | CI 回归集成示例章节 | ✅ 通过 | Grep 命中章节 + `network-scan` + `pytest tests/e2e` |
| TT-218-003 | 自动报告方案章节 | ✅ 通过 | Grep 命中章节 + `pytest --html` |
| TT-218-004 | hook --no-verify 防递归 | ✅ 通过 | ps=2 处 + post-push=2 处 |
| TT-218-005a | tag 一致性检查逻辑 | ✅ 通过 | Grep 命中 `TAG-CHECK` + `git ls-remote` |
| TT-218-005b | 推送端到端验证 | ⏸ 待 Step 5 | 发布 v2.18.0 时执行 |
| TT-218-006 | 用户文档版本号 v2.18.0 | ✅ 通过 | 指南 + 手册均命中 |

**汇总：6 通过 / 0 失败 / 1 延迟验证（5b）**

## 2. 自测证据抽查记录（4.0b）

| 抽查项 | 抽取方法 | 复核结果 | 一致性 |
|:-------|:---------|:---------|:------:|
| T3a E2E 用例模板 | DevLogReport §5 第 1 项 | True | ✅ 一致 |
| hook --no-verify | DevLogReport §5 第 4 项 | True | ✅ 一致 |
| 用户文档版本号 | DevLogReport §5 第 5 项 | True | ✅ 一致 |

## 3. 回归验证记录（4.6）

| 验证项 | 结果 |
|:-------|:----:|
| 副本一致性（testing-stage-execution 3 处）| ✅ 3/3 MD5 一致 |
| pre-push ↔ post-push 同步 | ✅ True |
| AC 覆盖率 | ✅ 6/6 = 100% |
| 软断言数量 | ✅ 0 |

## 4. 执行命令记录

```text
1. Grep testing-stage-execution.md - 3 章节模式（T3a 模板/CI 示例/自动报告）
2. Grep push-with-backup.ps1 - --no-verify ×2 + TAG-CHECK + ls-remote
3. Grep post-push - --no-verify ×2
4. Grep DevFlow-用户指南.html + 用户手册.html - v2.18.0
5. Get-FileHash - 3 处副本 + pre-push 同步比对
6. PS Parser - push-with-backup.ps1 语法零错误
```

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-19 | 初始创建，6 项测试证据 + 抽查记录 + 回归记录 | AT-DevFlow-Dev |
