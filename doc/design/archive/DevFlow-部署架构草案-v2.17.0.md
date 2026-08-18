# DevFlow 部署架构草案 — v2.17.0

> 文档类型：部署架构草案
> 版本：v2.17.0
> 日期：2026-08-18
> 作者：AA-DevFlow-Dev

---

## 1. 说明

本版本为 DevFlow 规范框架增强（design-stage-execution + coding-stage-execution + testing-stage-execution + project-document-templates 技能文档更新），**不涉及运行时部署**。

## 2. 部署方式

| 项 | 内容 |
|:---|:-----|
| 部署方式 | ✅ N/A — 无容器化部署、无服务发布 |
| 分发机制 | 技能文档更新后通过 update.ps1 推送至 IDE 技能目录 |
| 安装副本 | `.devflow/skills/` + `.trae/skills/` 同步更新 |
| 环境差异 | Dev（本地）/ Test（同 Dev）/ Pro（Git 远程仓库）— 文档项目无独立环境 |

## 3. 发布路径

```text
Step 3 编码 → 更新 4 个技能文档 → validate（validate-version-header.ps1）
→ Step 4 测试 → Step 5 发布（Git tag + push + update.ps1 推送 IDE）
```

## 4. 涉及文件清单（发布核对）

| 文件 | 变更类型 |
|:-----|:---------|
| devflow-plugin/skills/L2/design-stage-execution.md | 新增章节 + 标记修正 |
| devflow-plugin/skills/L2/coding-stage-execution.md | 新增小节 |
| devflow-plugin/skills/L2/testing-stage-execution.md | 标记修正 + 新增小节 |
| devflow-plugin/skills/L3/project-document-templates.md | 模板新增/更新 |
| .devflow/skills/ + .trae/skills/ 对应副本 | 同步更新 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-18 | 初始创建，确认无运行时部署，定义 4 技能文档发布路径 | AA-DevFlow-Dev |
