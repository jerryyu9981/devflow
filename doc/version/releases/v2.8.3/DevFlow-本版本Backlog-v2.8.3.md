# DevFlow 本版本 Backlog v2.8.3

> **文档状态**: [Draft]
> **版本**: 1.0.0
> **项目**: DevFlow
> **目标版本**: v2.8.3
> **创建日期**: 2026-07-18

---

## 1. 优先级定义

| 级别 | 定义 | 处置规则 |
|:----:|------|---------|
| 🔴 P0 | 必做 | 版本必须完成，未完成不发布 |
| 🟡 P1 | 应做 | 尽量完成，未完成需评审决定是否延期 |
| 🟢 P2 | 可做 | 资源允许时做，可延期 |

---

## 2. Backlog 列表

| BL-ID | 优先级 | 需求 ID | 需求描述 | 验收标准 | 预估工作量 | 依赖 |
|:-----:|:------:|:-------:|---------|:--------:|:----------:|:----:|
| BL-01 | 🔴 P0 | V260-052 | 修复 4 个脚本的 skillMap 历史遗漏（commit 3d0fa2d，已修复） | AC-01：5 个脚本的 31 个技能条目 155/155 一致 | 0 人天（已修复） | 无 |
| BL-02 | 🔴 P0 | V260-051-01 | 创建 devflow-manifest.json，定义所有插件文件的路径、类别、必需性、安装目标位置 | AC-02：manifest 覆盖所有 31 个技能 + 6 个工具/入口文件 | 1 人天 | BL-01 |
| BL-03 | 🔴 P0 | V260-051-02 | setup.ps1 改为从 manifest 动态加载 skillMap | AC-03：setup.ps1 无硬编码技能列表 | 1 人天 | BL-02 |
| BL-04 | 🔴 P0 | V260-051-03 | setup.sh 两个分支改为从 manifest 动态加载 skillMap | AC-04：setup.sh 两个分支无硬编码技能列表 | 1 人天 | BL-02 |
| BL-05 | 🔴 P0 | V260-051-04 | update.ps1 改为从 manifest 动态加载 skillMap | AC-05：update.ps1 无硬编码技能列表 | 0.5 人天 | BL-02 |
| BL-06 | 🔴 P0 | V260-051-05 | update.sh 改为从 manifest 动态加载 skillMap | AC-06：update.sh 无硬编码技能列表 | 0.5 人天 | BL-02 |
| BL-07 | 🔴 P0 | V260-051-06 | sync-skills.ps1 改为从 manifest 动态加载 skillMap | AC-07：sync-skills.ps1 无硬编码技能列表 | 0.5 人天 | BL-02 |
| BL-08 | 🟡 P1 | V260-051-07 | Download 步骤（download-devflow.ps1）增加 manifest 文件完整性校验 | AC-08：clone 完成后校验所有 required=true 文件存在 | 0.5 人天 | BL-02 |
| BL-09 | 🟡 P1 | V260-051-08 | Setup 步骤后增加安装数量校验 | AC-09：安装完成后对比 manifest.skillCount | 0.5 人天 | BL-03~07 |
| BL-10 | 🟢 P2 | V260-051-09 | Init 步骤（devflow-init）验证已安装技能数量与 manifest 一致 | AC-10：init 时发现数量不一致告警 | 0.5 人天 | BL-02 |

---

## 3. Backlog 汇总

| 统计项 | 数量 |
|--------|:----:|
| 总 Backlog 条目 | 10 |
| 🔴 P0 | 7 |
| 🟡 P1 | 2 |
| 🟢 P2 | 1 |
| 预估总工作量 | 6 人天 |
