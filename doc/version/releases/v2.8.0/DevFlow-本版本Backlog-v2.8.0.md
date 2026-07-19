# DevFlow 本版本 Backlog v2.8.0

> **文档状态**: [Draft]  
> **版本**: 1.0.0  
> **项目**: DevFlow  
> **目标版本**: v2.8.0  
> **作者**: PM-DevFlow-Dev  
> **创建日期**: 2026-07-12

---

## 纳入需求

| 需求 ID | 需求描述 | 优先级 | 涉及文件 | 验收标准 |
|:--------:|---------|:------:|---------|:--------:|
| V260-037 | **修复 setup.ps1 复制逻辑**：非 .md 文件保留原文件名（已修复） | 🔴 P0 | `setup.ps1` | AC-12: 运行 setup.ps1 后 version.json 和 sync-skills.ps1 文件名正确 |
| V260-036-07 | **devflow-init 版本差异检测增强**：比较 TRAE 版本 vs 项目记录版本并提示 | 🔴 P0 | `devflow-init/SKILL.md` | AC-09: versionCheck 字段写入 state.json |
| V260-036-01 | **新增 download-devflow.ps1 脚本**：从云端下载 | 🟡 P1 | `download-devflow.ps1` | AC-13: 三种模式正常运行 |
| V260-036-08 | **填充 version.json 仓库地址** | 🟢 P2 | `version.json` | AC-14: repository/homepage 字段可设置 |