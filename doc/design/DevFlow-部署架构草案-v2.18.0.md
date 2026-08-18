# DevFlow 部署架构草案 — v2.18.0

> 文档类型：部署架构草案
> 版本：v2.18.0
> 日期：2026-08-19
> 作者：AA-DevFlow-Dev

---

## 1. 说明

本版本为 DevFlow 规范框架增强（testing-stage-execution 自动化章节）+ Git 基础设施修复（hook 脚本），**不涉及运行时部署**。

## 2. 部署方式

| 项 | 内容 |
|:---|:-----|
| 部署方式 | ✅ N/A — 无容器化部署、无服务发布 |
| 分发机制 | 技能文档更新后同步至 .devflow/skills + .trae/skills + IDE 副本；hook 脚本同步至 .git/hooks |
| 环境差异 | Dev（本地）/ Test（同 Dev）/ Pro（Git 远程仓库）|
| 回滚 | Git revert 到 v2.17.0 tag + hook 脚本回滚（.devflow/hooks 历史）|

## 3. 发布路径

```text
Step 3 编码 → testing-stage-execution 3 章节 + hook 修复 + 用户文档刷新
→ Step 4 测试（AC-218-001~006）→ Step 5 发布（Git tag + 三远程推送 + IDE 同步）
```

## 4. 涉及文件清单（发布核对）

| 文件 | 变更类型 |
|:-----|:---------|
| devflow-plugin/skills/L2/testing-stage-execution.md | 新增 3 章节 |
| .devflow/hooks/push-with-backup.ps1 | 修改（--no-verify + tag 检查）|
| .devflow/hooks/post-push + .git/hooks/pre-push | 修改（显式备份调用）|
| DevFlow-用户指南.html + DevFlow-用户手册.html | 修改（版本号 v2.18.0）|
| .devflow/skills/ + .trae/skills/ + IDE 副本（testing-stage-execution）| 同步更新 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-19 | 初始创建，确认无运行时部署，定义发布路径 | AA-DevFlow-Dev |
