# DevFlow Phase 迭代计划 v2.8.0

> **文档状态**: [Draft]  
> **版本**: 1.0.0  
> **项目**: DevFlow  
> **目标版本**: v2.8.0  
> **作者**: PM-DevFlow-Dev  
> **创建日期**: 2026-07-12

---

## Phase 划分

v2.8.0 为单 Phase 迭代。

### Phase 1：三阶段流程完善（4 项需求）

| 步骤 | 任务 | 涉及文件 | 预估工时 | 依赖 | 状态 |
|:----:|------|---------|:--------:|:----:|:----:|
| 0 | **setup.ps1 复制逻辑修复**（V260-037） | `setup.ps1` | 10min | 无 | ✅ 已修复 |
| 1 | **devflow-init 版本差异检测增强**（V260-036-07） | `devflow-init/SKILL.md` | 30min | 无 |
| 2 | **新增 download-devflow.ps1**（V260-036-01） | `download-devflow.ps1`（新增） | 45min | 无 |
| 3 | **填充 version.json 仓库地址**（V260-036-08） | `version.json` | 5min | 步骤 2 |

**总预估工时**：约 1.5 小时

---

## Phase 里程碑

| 里程碑 | 条件 | 验收标准 |
|--------|------|---------|
| setup.ps1 修复 | 代码修改完成 | 非 .md 文件安装后保留原文件名 |
| devflow-init 增强 | SKILL.md 修改完成 | 版本差异可检测并提示 |
| 下载脚本完成 | download-devflow.ps1 编写完成 | 三种模式正常运行 |
| 部署完成 | 技能同步到 TRAE 系统目录 | 全部 4 项 AC 通过 |