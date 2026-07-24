# DevFlow-设计评审记录-v2.7.3

> 文档类型：设计评审记录
> 文档状态：[Draft]
> 版本：v1.0
> 日期：2026-07-11
> 所属版本：v2.7.3

---

## 1. 设计入场检查

| 检查项 | 状态 | 说明 |
|:-------|:----:|:------|
| Step 0 版本规划已批准 | ✅ | 已批准 |
| Step 1 需求文档已批准 | ✅ | 已批准 |
| 本版本 Backlog 明确 | ✅ | V260-030~034 共 5 项 |
| P0/P1 需求具备可设计条件 | ✅ | 每项需求精确到具体文件行号 |
| 无重大未决范围变更 | ✅ | 无 |

## 2. 需求-设计追溯矩阵

| DT-ID | RT-ID | 需求 | 设计覆盖 | 设计说明 |
|:-----:|:-----:|:------|:---------|:---------|
| DT-001 | RT-001 | V260-030 Install 职责清理 | `setup.ps1` 剥离 4 个代码块 + `setup.sh` 同步 | 移除项目初始化逻辑，保留技能安装 + Git hook |
| DT-002 | RT-002 | V260-031 Update 修正 | `update.ps1` 移除 1 个代码块 + `update.sh` 同步 | 移除 projectVersion 写入逻辑 |
| DT-003 | RT-003 | V260-032 devflow-init 版本号读写 | `devflow-init/SKILL.md` 新增 3 条规则 | 读取 TRAE 版本 → 写入项目 version.json + state.json.version |
| DT-004 | RT-004 | V260-033 projectVersion 检测 | `devflow-init/SKILL.md` 新增 1 条规则 | 优先级链检测 → 写入 config.json.projectVersion |
| DT-005 | RT-005 | V260-034 currentPhase 写入 | `devflow-init/SKILL.md` 新增 1 条规则 | 文档扫描 → 写入 state.json.currentPhase + completedPhases |

**覆盖率**：5/5 = **100%** ✅（无缺口）

## 3. 详细设计方案

### Phase 1：脚本职责清理

#### DT-001：setup.ps1 剥离方案

**当前结构**：
```
setup.ps1 (约 270 行)
├── 1. 版本读取（第14-23行）              ← 保留（用于输出版本信息）
├── 2. 项目名检测（第49-62行）            ← 移除
├── 3. 创建 .devflow 目录（第66-68行）    ← 移除
├── 4. 生成 config.json（第71-126行）      ← 移除
├── 5. 生成 state.json（第130-140行）      ← 移除
├── 6. 安装技能到 TRAE（第143-207行）      ← 保留
├── 7. 安装 Git Hook（第210-253行）        ← 保留
└── 8. 输出摘要（第256-267行）             ← 保留，移除项目初始化相关的摘要行
```

**剥离后结构**：
```
setup.ps1 (约 150 行)
├── 1. 版本读取（保留）
├── 2. [移除] 项目名检测
├── 3. [移除] .devflow 目录创建
├── 4. [移除] config.json 生成
├── 5. [移除] state.json 生成
├── 6. 安装技能到 TRAE（保留）
├── 7. 安装 Git Hook（保留）
└── 8. 输出摘要（保留，简化）
```

**setup.sh 同步修改**：同等逻辑剥离（项目名检测、config.json/state.json 生成移除）。

#### DT-002：update.ps1 剥离方案

**当前 update.ps1 第4节（第193-199行）**：
```powershell
# 4. Update config version
if (Test-Path $ConfigPath) {
    $config = Get-Content $ConfigPath -Encoding UTF8 | ConvertFrom-Json
    $config.projectVersion = $LatestVersion
    $config | ConvertTo-Json -Depth 4 | Set-Content $ConfigPath -Encoding UTF8
    Write-Success "Updated config.projectVersion to v$LatestVersion"
}
```

**移除后**：update.ps1 只做 TRAE 技能同步，不碰项目配置。

**update.sh 同步修改**：移除第 162-172 行的 projectVersion 修改逻辑。

---

### Phase 2：devflow-init 规则增强

#### DT-003：版本号读取与写入

**当前规则**（devflow-init SKILL.md 第12行）：
```
**版本来源规则**：本技能生成的 `config.json` 模板中的 `devflowVersion` 必须与插件根目录 `version.json` 中的 `version` 字段保持完全一致。`version.json` 是 DevFlow 的唯一权威版本来源（Single Source of Truth）。
```

**设计修改**：
1. 改为从 `~/.trae-cn/skills/devflow-plugin-config/version.json` 读取版本号
2. 写入项目根目录 `version.json`
3. 写入 `.devflow/state.json` 的 `version` 字段

**新增流程**：在初始化流程中增加版本号获取步骤：
```
保存在 "初始化流程" 第1步之后

1.5 获取 DevFlow 版本号
  - 读取 ~/.trae-cn/skills/devflow-plugin-config/version.json 的 version 字段
  - 若无法读取（如 TRAE 未安装），降级为读取项目根目录已有 version.json
  - 若仍无法获取，标记为 "unknown"

1.6 创建项目根目录 version.json
  - 写入 { "name": "DevFlow", "version": "{读取到的版本号}" }
```

**state.json 模板修改**：
- `"version": ""` → `"version": "{读取到的版本号}"`

#### DT-004：projectVersion 自动扫描

**当前**：`config.json` 模板中 `projectVersion` 为 `""`。

**设计修改**：新增检测优先级链：

```
① .devflow/config.json projectVersion（已有非空值）→ 保留
② git describe --tags --abbrev=0 → 取 tag 值（去掉前缀 v）
③ package.json → version 字段
④ pyproject.toml → version 字段
⑤ 其他项目配置文件
⑥ 均无法获取 → 交互询问用户输入
```

**新增流程**：在初始化流程中增加 projectVersion 检测步骤：
```
1.7 检测项目版本号
  - 按优先级链依次检测
  - 检测到版本号 → 写入 config.json.projectVersion
  - 均无法获取 → 询问用户输入
```

#### DT-005：currentPhase 推断写入

**当前**：
- state.json 模板中 `"currentPhase": "{推断的阶段}"` — 但实际 LLM 执行时只提示用户，不实际写入

**设计修改**：扫描文档后实际写入 state.json

```
currentPhase 推断逻辑：
  doc/operation/ 有部署记录                 → step_5_deployed
  doc/test/ 有测试报告                      → step_4_testing
  doc/development/ 有 DevLogReport          → step_3_coding
  doc/design/ 有架构设计文档                → step_2_design
  doc/requirements/ 有需求文档              → step_1_requirements
  以上均无                                  → step_0_planning

completedPhases 推断逻辑：
  基于 currentPhase 倒推
  如 currentPhase = step_4_testing
  → completedPhases = [step_0_planning, step_1_requirements, step_2_design, step_3_coding]
```

**新增流程**：在初始化流程的最后阶段：
```
5. 创建/更新 state.json
  - version: 步骤1.5获取的 DevFlow 版本号
  - currentPhase: 步骤2推断的阶段
  - completedPhases: 基于 currentPhase 倒推
  - 已有状态文件的：合并 currentDocuments 和 auditResults 字段
```

## 4. 轨道选择

| 轨道 | 是否激活 | 理由 |
|:----:|:--------:|:------|
| 🎯 整体 | ✅ | 始终激活（设计文件结构变更） |
| ⚙️ 后端 | ❌ 无后端代码修改 |
| 🎨 前端 | ❌ 无前端代码修改 |
| 🔗 第三方集成 | ❌ 无外部依赖变更 |

## 5. 设计风险

| 风险 | 概率 | 影响 | 缓解 |
|:-----|:----:|:----:|:-----|
| setup.ps1 剥离后输出摘要缺少项目名和版本信息 | 低 | 低 | 保留版本读取变量用于摘要输出 |
| devflow-init 读取 TRAE 技能目录失败 | 低 | 中 | 降级读取已有项目文件或标记 unknown |

## 6. 设计评审结论

| 评审项 | 结论 | 说明 |
|:-------|:----:|:------|
| 需求-设计追溯覆盖率 | ✅ ≥95%（100%） | 5/5 项全部覆盖 |
| 设计完整性 | ✅ | 每项需求有精确到代码块的剥离方案或规则新增描述 |
| 可开发性 | ✅ | 所有修改可精确实现，无歧义 |
| 可测试性 | ✅ | 每项修改有明确验收标准 |
| 风险可控 | ✅ | 无高风险项 |
| Phase 划分合理 | ✅ | Phase 1（脚本）+ Phase 2（规则）|

> **待人工批准**：请确认是否批准 v2.7.3 设计评审，进入 Step 3 开发阶段。