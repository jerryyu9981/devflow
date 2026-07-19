# DevFlow 本版本 Backlog v2.8.1

> **文档状态**: [Draft]
> **版本**: 1.0.0
> **项目**: DevFlow
> **目标版本**: v2.8.1
> **作者**: PM-DevFlow-Dev
> **创建日期**: 2026-07-15

---

## 纳入需求

| 需求 ID | 需求描述 | 优先级 | 涉及文件 | 验收标准 |
|:--------:|---------|:------:|---------|:--------:|
| V260-045 | **setup.ps1 增加交互确认**：复制前展示版本号+文件数+目标路径，用户 y/Y 确认后才执行 | 🔴 P0 | `setup.ps1` | AC-03: 执行前展示版本号和文件数，等待用户确认 |
| V260-038 | **修复 update.ps1 SKILL.md 硬编码**：对非 .md 文件保留原文件名（参照 V260-037 方案，约 10 行代码） | 🟡 P1 | `update.ps1` | AC-04: 非 .md 文件保留原文件名 |
| V260-044 | **download-devflow.ps1 增加版本比较+交互确认**：Clone/Update 前确认源/目的地址；git ls-remote 获取远程版本 vs 本地版本比较；有更新才下载 | 🔴 P0 | `download-devflow.ps1` | AC-01: 展示远程版本和本地版本，有更新才下载；AC-02: 展示源地址和目的地址供确认 |
| V260-046 | **devflow-init 版本更新时同步项目 devflow 文件**：installed_newer 时不仅更新版本号，还从 TRAE 系统目录同步文件到项目 .devflow/ | 🔴 P0 | `devflow-init/SKILL.md` | AC-05: 检测到 installed_newer 时同步 TRAE 文件到项目 .devflow/ |
