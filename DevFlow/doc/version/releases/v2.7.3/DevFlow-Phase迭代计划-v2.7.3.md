# DevFlow-Phase迭代计划-v2.7.3

> 文档类型：Phase 迭代计划（单 Phase）
> 文档状态：[Draft]
> 版本：v1.0
> 日期：2026-07-11
> 所属版本：v2.7.3

---

## Phase 1：脚本职责清理

**包含需求**：V260-030、V260-031

**修改目标**：
- `setup.ps1` 移除项目名检测（49-62行）、`.devflow/` 创建（66-68行）、config.json 生成（71-126行）、state.json 生成（130-140行），仅保留 TRAE 技能安装（143-207行）和 Git hook（210-253行）
- `setup.sh` 同理移除项目初始化逻辑
- `update.ps1` 移除第 193-199 行的 `config.projectVersion = $LatestVersion` 写入逻辑
- `update.sh` 同理移除 projectVersion 修改逻辑

**验证标准**：
- setup.ps1/sh 执行后不再创建 `.devflow/config.json` 和 `.devflow/state.json`
- update.ps1/sh 执行后 `.devflow/config.json` 的 `projectVersion` 不变

---

## Phase 2：devflow-init 职责增强

**包含需求**：V260-032、V260-033、V260-034

**修改目标**：
- `devflow-init/SKILL.md` 的"版本来源规则"改为：**从 `~/.trae-cn/skills/devflow-plugin-config/version.json` 读取 DevFlow 版本**
- 新增可执行步骤：读取 TRAE 目录版本号 → 写入项目根 `version.json` → 写入 `state.json.version`
- 新增交互步骤：按照优先级链自动检测项目版本号（已有 config → Git tag → package.json → pyproject.toml → 其他），均无法获取时询问用户输入 → 写入 `config.json.projectVersion`
- 扫描文档后实际写入 `state.json.currentPhase`

**验证标准**：
- devflow-init 执行后，项目根目录生成 `version.json` 且版本号 = TRAE 技能目录版本号
- `state.json.version` 填入DevFlow版本号
- `state.json.currentPhase` 根据文档扫描结果正确填写
- `config.json.projectVersion` 填入自动检测到的版本号（或用户输入的版本号）