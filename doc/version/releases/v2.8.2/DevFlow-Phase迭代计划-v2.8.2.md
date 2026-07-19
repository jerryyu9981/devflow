# DevFlow Phase 迭代计划 v2.8.2

> **文档状态**: [Draft]
> **版本**: 1.0.0
> **项目**: DevFlow
> **目标版本**: v2.8.2
> **作者**: PM-DevFlow-Dev
> **创建日期**: 2026-07-18

---

## Phase 划分

v2.8.2 按 3 个 Phase 迭代，按依赖关系和脚本分组拆分。

### Phase 1：install.ps1 下载步骤对齐 + 首次安装引导（2 项需求）

> V260-047 和 V260-048 紧密耦合（都修改 install.ps1 的 Step 1），合并为一个 Phase。

| 步骤 | 任务 | 涉及文件 | 预估工时 | 依赖 | 状态 |
|:----:|------|---------|:--------:|:----:|:----:|
| 1 | **V260-047**：删除 install.ps1 第 65-212 行内联 git clone 逻辑，改为调用 `download-devflow.ps1 -Action Clone -TargetDir $PluginDir`；install.ps1 只保留流程编排 + 错误处理 + 仓库为空提示 | `install.ps1` | 30min | 无 | |
| 2 | **V260-048**：install.ps1 新增 `-TargetDir` 参数；Step 1 检测 repository 为空时自动调用 `download-devflow.ps1 -Action SetRepo`，设置完成后继续 Clone | `install.ps1` | 20min | 步骤 1 | |
| 3 | **V260-047/048**：同步修改 install.bat 确保参数传递正确 | `install.bat` | 5min | 步骤 2 | |

**Phase 1 预估工时**：约 55 分钟

---

### Phase 2：BOM 去除 + IDE 目录可配置化（2 项需求）

> V260-049（IDE 目录可配置化）和 V260-050（BOM 去除）都修改同一组脚本，合并为一个 Phase。

| 步骤 | 任务 | 涉及文件 | 预估工时 | 依赖 | 状态 |
|:----:|------|---------|:--------:|:----:|:----:|
| 1 | **V260-049**：setup.ps1/sh 新增 `DEVFLOW_SKILLS_DIR` 环境变量读取逻辑，优先级高于硬编码路径；安装确认步骤中展示该目录 | `setup.ps1`, `setup.sh` | 20min | 无 | |
| 2 | **V260-050**：setup.ps1/sh Phase 2 文件复制完成后，增加 BOM 检测 + 去除函数（检测首三字节 `EF BB BF`，用无 BOM UTF-8 重写） | `setup.ps1`, `setup.sh` | 15min | 步骤 1 | |
| 3 | **V260-049/050**：同步修改 update.ps1、update.sh、sync-skills.ps1（IDE 目录可配置化 + BOM 去除） | `update.ps1`, `update.sh`, `sync-skills.ps1` | 25min | 步骤 2 | |

**Phase 2 预估工时**：约 60 分钟

---

### Phase 3：语法验证 + 修复 v2.8.1 遗漏（1 项收尾）

> v2.8.1 交付时 setup.sh 遗漏了 v2.7.5/v2.8.0 的多项改进，本次一并修复。

| 步骤 | 任务 | 涉及文件 | 预估工时 | 依赖 | 状态 |
|:----:|------|---------|:--------:|:----:|:----:|
| 1 | 全部修改脚本语法验证（PowerShell: `Get-Content \| ForEach-Object { [System.Management.Automation.Language.Parser]::ParseInput }`；Bash: `bash -n`） | 全部 .ps1/.sh | 15min | Phase 1, 2 | |
| 2 | 更新 version.json 的 devflowVersion 为 2.8.2 | `version.json` | 2min | Phase 1, 2 | |
| 3 | 更新 CHANGELOG.md 添加 v2.8.2 记录 | `CHANGELOG.md` | 5min | Phase 1, 2 | |

**Phase 3 预估工时**：约 22 分钟

---

## 总体预估

| 项目 | 工时 |
|------|------|
| Phase 1 | 55min |
| Phase 2 | 60min |
| Phase 3 | 22min |
| **总计** | **约 2.3 小时** |

---

## Phase 里程碑

| 里程碑 | 条件 | 验收标准 |
|--------|------|---------|
| Phase 1 完成 | install.ps1 下载对齐 + 首次安装引导 | AC-01: 调用 download-devflow.ps1；AC-02: repository 为空时引导 SetRepo；AC-03: 支持 -TargetDir |
| Phase 2 完成 | BOM 去除 + IDE 目录可配置化 | AC-04: 安装后无 BOM；AC-05: DEVFLOW_SKILLS_DIR 生效 |
| 版本交付 | 全部脚本语法验证通过 + 版本号更新 | AC-06: 全部脚本语法验证通过 |