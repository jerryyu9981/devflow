# DevFlow 需求基线及设计移交说明 v2.7.5

> **文档状态**: [Draft]  
> **版本**: 1.0.0  
> **项目**: DevFlow  
> **目标版本**: v2.7.5  
> **作者**: RA-DevFlow-Dev  
> **创建日期**: 2026-07-12

---

## 1. 需求基线

### 1.1 基线范围

本基线覆盖 v2.7.5 版本全部 6 项纳入需求，源自候选需求池 V260-036。

### 1.2 基线清单

| 编号 | 需求 | 优先级 | 涉及文件 | 验收标准 |
|:----:|------|:------:|---------|:--------:|
| R01 | V260-036-02：install.ps1 边界修复 | 🔴 P0 | `install.ps1` | AC-03 |
| R02 | V260-036-03：setup.ps1 skillMap 补齐 | 🔴 P0 | `setup.ps1` | AC-04, AC-05 |
| R03 | V260-036-04：sync-skills.ps1 自身引用补齐 | 🔴 P0 | `sync-skills.ps1` | AC-06 |
| R04 | V260-036-05：update.ps1 skillMap 补齐 | 🟡 P1 | `update.ps1` | AC-07 |
| R05 | V260-036-06：update-devflow.bat 标题修复 | 🟢 P2 | `update-devflow.bat` | AC-08 |
| R06 | V260-036-09：setup.sh / update.sh 同步 | 🟡 P1 | `setup.sh`、`update.sh` | AC-11 |

### 1.3 基线外需求

以下需求已确认推迟至 v2.8.0：
- V260-036-01：新增 download-devflow.ps1 脚本
- V260-036-07：devflow-init 版本差异检测增强
- V260-036-08：填充 version.json 仓库地址字段

---

## 2. 设计移交说明

### 2.1 设计输入

本需求基线已提供以下设计输入：

1. **完整解决方案设计文档**：`doc/design/devflow-version-management-architecture.md`
   - 第 4 章：第二阶段设计（安装/更新/同步组件）
   - 第 4.3 节：各文件修改清单（含修改前/修改后内容）
   - 第 6 章：执行文件职责矩阵
   - 第 7 章：详细修改清单（按文件）

2. **开发需求文档**：`doc/requirements/DevFlow-开发需求文档-v2.7.5.md`
   - 第 2 章：核心功能需求（每个需求的用户故事、验收标准、功能点）

### 2.2 设计注意事项

1. **skillMap 修改**：setup.ps1 和 update.ps1 的 skillMap 修改应保持一致，使用相同的键名和路径
2. **$preserveFileName 机制**：version.json 和 sync-skills.ps1 是非 .md 文件，sync-skills.ps1 已有 `$preserveFileName` 处理逻辑，无需额外处理
3. **向后兼容**：移除 install.ps1 的项目目录复制逻辑时，不需要写兼容代码——因为该逻辑本来就不应该存在
4. **同步修改**：PS1 和 SH 文件应同步修改，保持功能一致

### 2.3 移交确认

| 移交项 | 状态 | 接收方 |
|--------|:----:|--------|
| 需求基线文档 | ✅ 就绪 | AA-DevFlow-Dev |
| 开发需求文档 | ✅ 就绪 | AA-DevFlow-Dev |
| 完整解决方案设计 | ✅ 就绪 | AA-DevFlow-Dev |
| 本版本 Backlog | ✅ 就绪 | AA-DevFlow-Dev |