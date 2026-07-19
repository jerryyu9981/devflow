# DevFlow 本版本 Backlog v2.7.5

> **文档状态**: [Draft]  
> **版本**: 1.0.0  
> **项目**: DevFlow  
> **目标版本**: v2.7.5  
> **作者**: PM-DevFlow-Dev  
> **创建日期**: 2026-07-12

---

## 纳入需求

### V260-036（部分）— 三阶段版本管理架构修复

| 子需求 ID | 需求描述 | 优先级 | 涉及文件 | 验收标准 |
|:---------:|---------|:------:|---------|---------|
| V260-036-02 | **修复 install.ps1 组件边界违规**：将 `$verInfo.version` 改为 `$verInfo.devflowVersion`；移除复制整个 devflow-plugin/ 到项目 .devflow/ 的代码；移除提示用户从 .devflow/ 运行 update.ps1 的代码 | 🔴 P0 | `install.ps1` | AC-03: 运行 install.ps1 不会在项目目录下创建任何文件 |
| V260-036-03 | **修复 setup.ps1 skillMap 遗漏**：在 skillMap 中添加 `devflow-plugin-config` → `version.json` 和 `devflow-plugin-sync` → `sync-skills.ps1` | 🔴 P0 | `setup.ps1` | AC-04: 运行 setup.ps1 后，TRAE 系统目录下存在 `devflow-plugin-config/version.json` |
| V260-036-04 | **修复 sync-skills.ps1 缺少自身引用**：在 `$DevFlowSkills` 列表中添加 `devflow-plugin-sync` → `sync-skills.ps1` | 🔴 P0 | `sync-skills.ps1` | AC-05: 运行 setup.ps1 后，TRAE 系统目录下存在 `devflow-plugin-sync/sync-skills.ps1` |
| V260-036-05 | **修复 update.ps1 skillMap 遗漏**：在 skillMap 中添加 `devflow-plugin-config` → `version.json` 和 `devflow-plugin-sync` → `sync-skills.ps1` | 🟡 P1 | `update.ps1` | AC-06: 运行 sync-skills.ps1 后，TRAE 系统目录下的 sync-skills.ps1 与本地副本一致 |
| V260-036-06 | **修复 update-devflow.bat 硬编码版本号**：标题从 v2.6.0 改为通用标题 DevFlow Updater | 🟢 P2 | `update-devflow.bat` | AC-07: 运行 update.ps1 后，TRAE 系统目录存在 `devflow-plugin-config/version.json` |
| V260-036-09 | **同步修改 setup.sh / update.sh**：在 SKILL_MAP 中添加 `devflow-plugin-config` 和 `devflow-plugin-sync` 条目 | 🟡 P1 | `setup.sh`、`update.sh` | AC-08: update-devflow.bat 标题不包含 v2.6.0 |

---

## 延期需求（推迟至 v2.8.0）

| 子需求 ID | 需求描述 | 推迟原因 |
|:---------:|---------|---------|
| V260-036-01 | 新增 download-devflow.ps1 脚本 | 新增功能，需更多测试 |
| V260-036-07 | devflow-init 版本差异检测增强 | 新增功能，依赖步骤 1 |
| V260-036-08 | 填充 version.json 仓库地址字段 | 依赖 V260-036-01 |

---

## 验收标准汇总

| 编号 | 验收项 | 对应需求 | 验证方法 |
|:----:|--------|:--------:|---------|
| AC-03 | 运行 install.ps1 不会在项目目录下创建任何文件 | V260-036-02 | 手动测试 + 目录检查 |
| AC-04 | 运行 setup.ps1 后，TRAE 系统目录下存在 `devflow-plugin-config/version.json` | V260-036-03 | 文件存在性检查 |
| AC-05 | 运行 setup.ps1 后，TRAE 系统目录下存在 `devflow-plugin-sync/sync-skills.ps1` | V260-036-03 | 文件存在性检查 |
| AC-06 | 运行 sync-skills.ps1 后，TRAE 系统目录下的 sync-skills.ps1 与本地副本一致 | V260-036-04 | 文件内容对比 |
| AC-07 | 运行 update.ps1 后，TRAE 系统目录存在 `devflow-plugin-config/version.json` | V260-036-05 | 文件存在性检查 |
| AC-08 | update-devflow.bat 标题显示为 DevFlow Updater 而非包含 v2.6.0 | V260-036-06 | 查看标题 |
| AC-11 | setup.sh 和 update.sh 的 SKILL_MAP 包含 `devflow-plugin-config` 和 `devflow-plugin-sync` | V260-036-09 | 文件内容检查 |