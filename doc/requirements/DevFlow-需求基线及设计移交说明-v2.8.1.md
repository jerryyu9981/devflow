# DevFlow 需求基线及设计移交说明 v2.8.1

> **文档状态**: [Draft]
> **版本**: 1.0.0
> **项目**: DevFlow
> **目标版本**: v2.8.1
> **作者**: RA-DevFlow-Dev
> **创建日期**: 2026-07-15

---

## 1. 需求基线

| 编号 | Backlog ID | 需求描述 | 优先级 | 涉及文件 | 验收标准 | 状态 |
|:----:|:----------:|---------|:------:|---------|:--------:|:----:|
| R01 | V260-044 | download-devflow.ps1 增加版本比较与交互确认 | 🔴 P0 | `download-devflow.ps1` | AC-01、AC-02 | 📋 待开发 |
| R02 | V260-045 | setup.ps1 增加交互确认步骤 | 🔴 P0 | `setup.ps1` | AC-03、AC-06 | 📋 待开发 |
| R03 | V260-038 | 修复 update.ps1 SKILL.md 硬编码 | 🟡 P1 | `update.ps1` | AC-04 | 📋 待开发 |
| R04 | V260-046 | devflow-init 版本更新时同步项目 devflow 文件 | 🔴 P0 | `devflow-init/SKILL.md` | AC-05 | 📋 待开发 |

## 2. 设计移交事项

1. **V260-044**：在 download-devflow.ps1 的 Clone 和 Update 分支前插入交互确认和版本比较逻辑
   - 交互确认：Read-Host 展示并确认源地址（version.json.repository）和目的地址（默认当前目录）
   - 版本比较：git ls-remote --tags 获取远程最新 tag → 读取本地 version.json.devflowVersion → 语义化比较 → 远程较新才执行 clone/pull

2. **V260-045**：在 setup.ps1 的文件复制循环前插入交互确认逻辑
   - 读取 version.json.devflowVersion 展示版本号
   - 统计 skillMap 中待复制文件数量
   - 展示目标路径 `~/.trae-cn/skills/`
   - Read-Host 等待 y/Y 确认，非 y/Y 则优雅退出

3. **V260-038**：参照 V260-037（setup.ps1 修复方案），在 update.ps1 第 153 行附近增加扩展名判断
   - .md 文件 → `SKILL.md`
   - 非 .md 文件 → 保留原文件名
   - 仅影响用户直接运行 update.ps1 的场景

4. **V260-046**：在 devflow-init/SKILL.md 版本差异检测结果为 `installed_newer` 的处理分支中增加文件同步逻辑
   - 从 `~/.trae-cn/skills/` 读取 DevFlow 相关文件
   - 复制到项目 `.devflow/` 目录
   - 同步更新 config.json 和 state.json 的模板结构
   - 更新 state.json.devflowVersion 为 TRAE 系统目录版本
