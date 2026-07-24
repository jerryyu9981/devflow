# DevFlow 本版本 Backlog v2.8.2

> **文档状态**: [Draft]
> **版本**: 1.0.0
> **项目**: DevFlow
> **目标版本**: v2.8.2
> **作者**: PM-DevFlow-Dev
> **创建日期**: 2026-07-18

---

## 纳入需求

| 需求 ID | 需求描述 | 优先级 | 涉及文件 | 验收标准 |
|:--------:|---------|:------:|---------|:--------:|
| V260-047 | **install.ps1 下载步骤对齐 download-devflow.ps1**：删除第 65-212 行内联 git clone 逻辑（约 100 行），改为调用 `download-devflow.ps1 -Action Clone -TargetDir $PluginDir`；install.ps1 只保留流程编排和错误处理 | 🔴 P0 | `install.ps1`, `install.bat` | AC-01: install.ps1 的 Step 1 调用 download-devflow.ps1 而非内联逻辑 |
| V260-048 | **install.ps1 首次安装时引导设置下载仓库地址**：当 `version.json.repository` 为空时，自动调用 `download-devflow.ps1 -Action SetRepo` 引导用户输入仓库 URL；设置完成后继续 Clone 流程；install.ps1 新增 `-TargetDir` 参数 | 🔴 P0 | `install.ps1`, `install.bat` | AC-02: repository 为空时自动引导 SetRepo 交互；AC-03: 支持 -TargetDir 参数 |
| V260-050 | **安装后自动去除 SKILL.md 的 UTF-8 BOM 头**：在 setup.ps1/sh 的文件复制完成后，对所有已安装的 `.md` 文件检测 UTF-8 BOM（`EF BB BF`）并自动去除；同步修改 update.ps1、update.sh、sync-skills.ps1 | 🔴 P0 | `setup.ps1`, `setup.sh`, `update.ps1`, `update.sh`, `sync-skills.ps1` | AC-04: 安装后所有 .md 文件无 UTF-8 BOM |
| V260-049 | **IDE 系统目录可配置化**：优先读取环境变量 `DEVFLOW_SKILLS_DIR`，其次使用硬编码 `$env:USERPROFILE\.trae-cn\skills`；在安装确认步骤中展示该目录 | 🟡 P1 | `setup.ps1`, `setup.sh`, `update.ps1`, `update.sh`, `sync-skills.ps1` | AC-05: 设置 DEVFLOW_SKILLS_DIR 后安装到指定目录 |

---

## 优先级排序依据

- **P0**：V260-047（架构对齐，消除重复代码）、V260-048（首次安装体验）、V260-050（已验证的实际故障）
- **P1**：V260-049（增强兼容性，但默认路径已覆盖大多数场景）