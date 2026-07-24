# DevFlow 系统架构设计文档 v2.8.3

> **文档状态**: [Draft]
> **版本**: 1.0.0
> **项目**: DevFlow
> **目标版本**: v2.8.3
> **作者**: AD-DevFlow-Dev
> **创建日期**: 2026-07-18

---

## 1. 入场检查

| 检查项 | 状态 | 证据 |
|--------|:----:|------|
| Step 1 需求已批准 | ✅ | 用户批准通过 |
| 开发需求文档齐备 | ✅ | doc/requirements/DevFlow-开发需求文档-v2.8.3.md |
| 需求评估审计通过 | ✅ | doc/audit/assessment/DevFlow-需求评估报告-v2.8.3.md |
| 轨道确认 | ✅ | 🎯整体 + ⚙️后端（🎨前端 N/A、🔗第三方 N/A） |

---

## 2. 需求-设计追溯（DT-ID）

| DT-ID | 关联 RT-ID | 关联 FR-ID | 设计项 | 覆盖状态 |
|:-----:|:----------:|:----------:|--------|:--------:|
| DT-01 | V260-051 | FR-01 | devflow-manifest.json 文件结构设计 | ✅ |
| DT-02 | V260-051 | FR-02 | PowerShell manifest 动态加载函数设计 | ✅ |
| DT-03 | V260-051 | FR-03 | Bash manifest 动态加载函数设计 | ✅ |
| DT-04 | V260-051 | FR-04 | 5 个脚本 skillMap 替换方案 | ✅ |
| DT-05 | V260-051 | FR-05 | Download 后 manifest 文件完整性校验设计 | ✅ |
| DT-06 | V260-051 | FR-06 | Setup 后安装数量校验设计 | ✅ |
| DT-07 | V260-051 | FR-07 | Init 技能数量一致性告警设计 | ✅ |

**覆盖统计**：7/7 DT-ID 覆盖 7/7 FR（100%）。无设计缺口。

---

## 3. 系统架构设计

### 3.1 当前架构（问题分析）

```
技能清单定义：
├── setup.ps1      ← hardcoded $skillMap (25 条)
├── setup.sh       ← hardcoded $SKILL_MAP × 2 分支 (25+25 条)
├── update.ps1     ← hardcoded $skillMap (22+ 条)
├── update.sh      ← hardcoded $SKILL_MAP (22+ 条)
└── sync-skills.ps1 ← hardcoded $DevFlowSkills (25+ 条)
                      ↑ 同一数据分散 5 处，历史已遗漏 4 次
```

### 3.2 目标架构

```
技能清单定义：
├── devflow-manifest.json  ← 单一事实源（1 处）
├── setup.ps1      ← 运行时从 manifest 加载
├── setup.sh       ← 运行时从 manifest 加载
├── update.ps1     ← 运行时从 manifest 加载
├── update.sh      ← 运行时从 manifest 加载
└── sync-skills.ps1 ← 运行时从 manifest 加载

三步走校验：
Download (download-devflow.ps1)
  └→ clone 后对照 manifest 校验 required 文件存在性
Setup (setup.ps1/sh)
  └→ 安装后校验已安装数量 == manifest.skillCount
Init (devflow-init)
  └→ 初始时检查技能数量一致性，不一致告警
```

### 3.3 部署拓扑

```
devflow-plugin/
├── devflow-manifest.json   ← ★ 新增：单一事实源
├── install.ps1             ← 引用 download-devflow.ps1 + setup.ps1
├── install.bat
├── download-devflow.ps1    ← [改造] 增加 manifest 校验
├── setup.ps1               ← [改造] 从 manifest 加载
├── setup.sh                ← [改造] 从 manifest 加载
├── update.ps1              ← [改造] 从 manifest 加载
├── update.sh               ← [改造] 从 manifest 加载
├── sync-skills.ps1          ← [改造] 从 manifest 加载
├── version.json
├── CHANGELOG.md
├── devflow-init/            ← [改造] 增加 Init 校验
├── devflow-phase-manager/
├── devflow-project-config/
└── skills/
    ├── L1/
    ├── L2/
    └── L3/
```

### 3.4 依赖关系

```
install.ps1 → download-devflow.ps1 → setup.ps1
                                    → devflow-manifest.json (校验用)

setup.ps1 → devflow-manifest.json (加载技能清单)
          → skills/L1/.. (安装来源)
          → skills/L2/..
          → skills/L3/..

update.ps1 → devflow-manifest.json (加载技能清单)

sync-skills.ps1 → devflow-manifest.json (加载技能清单)

download-devflow.ps1 → devflow-manifest.json (安装后校验)

devflow-init → devflow-manifest.json (初始化校验)
```

---

## 4. 后端详细设计

### 4.1 DT-01: devflow-manifest.json 文件结构

```json
{
  "_meta": {
    "description": "DevFlow 插件文件清单 — 所有安装/更新/同步脚本的单一事实源",
    "version": "1.0.0",
    "lastUpdated": "2026-07-18",
    "schemaUrl": ""
  },
  "plugin": {
    "name": "DevFlow",
    "version": "2.8.3",
    "description": "DevFlow — 软件开发工程规范插件"
  },
  "skillCount": 31,
  "totalFiles": 37,
  "skills": [
    { "name": "devflow-init",                    "source": "devflow-init/SKILL.md",                     "category": "orchestrator", "required": true, "destAs": "SKILL.md" },
    { "name": "devflow-phase-manager",           "source": "devflow-phase-manager/SKILL.md",            "category": "orchestrator", "required": true, "destAs": "SKILL.md" },
    { "name": "devflow-project-config",          "source": "devflow-project-config/SKILL.md",           "category": "orchestrator", "required": true, "destAs": "SKILL.md" },
    { "name": "devflow-plugin-config",           "source": "version.json",                              "category": "config",       "required": true, "destAs": "version.json" },
    { "name": "devflow-plugin-sync",             "source": "sync-skills.ps1",                           "category": "tool",         "required": true, "destAs": "sync-skills.ps1" },
    { "name": "devflow-plugin-download",         "source": "download-devflow.ps1",                      "category": "tool",         "required": true, "destAs": "download-devflow.ps1" },
    { "name": "project-development-workflow",    "source": "skills/L1/project-development-workflow.md", "category": "L1",           "required": true, "destAs": "SKILL.md" },
    { "name": "project-document-management",     "source": "skills/L1/project-document-management.md",  "category": "L1",           "required": true, "destAs": "SKILL.md" },
    { "name": "project-role-management",         "source": "skills/L1/project-role-management.md",      "category": "L1",           "required": true, "destAs": "SKILL.md" },
    { "name": "version-planning-stage-execution", "source": "skills/L2/version-planning-stage-execution.md", "category": "L2", "required": true, "destAs": "SKILL.md" },
    { "name": "requirements-stage-execution",    "source": "skills/L2/requirements-stage-execution.md",  "category": "L2",           "required": true, "destAs": "SKILL.md" },
    { "name": "design-stage-execution",          "source": "skills/L2/design-stage-execution.md",        "category": "L2",           "required": true, "destAs": "SKILL.md" },
    { "name": "coding-stage-execution",          "source": "skills/L2/coding-stage-execution.md",        "category": "L2",           "required": true, "destAs": "SKILL.md" },
    { "name": "testing-stage-execution",         "source": "skills/L2/testing-stage-execution.md",       "category": "L2",           "required": true, "destAs": "SKILL.md" },
    { "name": "operations-stage-execution",      "source": "skills/L2/operations-stage-execution.md",    "category": "L2",           "required": true, "destAs": "SKILL.md" },
    { "name": "project-coding-conventions",      "source": "skills/L3/project-coding-conventions.md",    "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "code-static-quality-check",       "source": "skills/L3/code-static-quality-check.md",     "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "code-logic-review",               "source": "skills/L3/code-logic-review.md",             "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "cicd-pipeline-management",        "source": "skills/L3/cicd-pipeline-management.md",      "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "observability-standards",         "source": "skills/L3/observability-standards.md",       "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "api-contract-management",         "source": "skills/L3/api-contract-management.md",       "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "prototype-coverage",              "source": "skills/L3/prototype-coverage.md",            "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "backend-coverage",                "source": "skills/L3/backend-coverage.md",              "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "project-document-templates",      "source": "skills/L3/project-document-templates.md",    "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "code-version-backup-management",  "source": "skills/L3/code-version-backup-management.md","category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "skill-md-writing-standards",      "source": "skills/L3/skill-md-writing-standards.md",   "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "security-design-review",          "source": "skills/L3/security-design-review.md",       "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "secure-coding-practices",         "source": "skills/L3/secure-coding-practices.md",      "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "container-deployment",            "source": "skills/L3/container-deployment.md",         "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "performance-engineering",         "source": "skills/L3/performance-engineering.md",      "category": "L3",           "required": true, "destAs": "SKILL.md" },
    { "name": "database-migration",              "source": "skills/L3/database-migration.md",           "category": "L3",           "required": true, "destAs": "SKILL.md" }
  ]
}
```

#### 设计说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `_meta` | object | 自描述元信息，帮助新维护者理解文件用途 |
| `plugin` | object | 插件基本信息，便于版本一致性校验 |
| `skillCount` | int | 声明的技能总数，用于安装后数量校验 |
| `skills[].name` | string | 技能在 TRAE 系统目录中的文件夹名称 |
| `skills[].source` | string | 源文件路径（相对于 devflow-plugin/） |
| `skills[].category` | string | 分类：orchestrator / L1 / L2 / L3 / config / tool |
| `skills[].required` | bool | 是否必需（Download 校验用） |
| `skills[].destAs` | string | 安装到 TRAE 目录时的文件名 |

### 4.2 DT-02: PowerShell manifest 动态加载函数

```powershell
# 从 devflow-manifest.json 加载技能清单
function Get-ManifestSkillMap {
    param([string]$ManifestPath)
    $manifest = Get-Content $ManifestPath -Encoding UTF8 | ConvertFrom-Json
    $skillMap = @{}
    foreach ($s in $manifest.skills) {
        $skillMap[$s.name] = $s.source
    }
    return $skillMap, $manifest.skillCount
}
```

**关键设计决策**：
- 返回两个值：`$skillMap`（兼容现有逻辑）+ `$skillCount`（校验用）
- 不修改原有的 `foreach ($skill in $skillMap.Keys)` 遍历模式，仅替换数据来源

### 4.3 DT-03: Bash manifest 动态加载函数

```bash
# 从 devflow-manifest.json 加载技能清单（不依赖 jq）
load_manifest_skills() {
    local manifest_file="$1"
    local -n _map="$2"
    local -n _count="$3"
    _count=$(grep -o '"skillCount": *[0-9]*' "$manifest_file" | grep -o '[0-9]*')
    while IFS= read -r line; do
        local name=$(echo "$line" | grep -o '"name": *"[^"]*"' | cut -d'"' -f4)
        local source=$(echo "$line" | grep -o '"source": *"[^"]*"' | cut -d'"' -f4)
        if [ -n "$name" ] && [ -n "$source" ]; then
            _map["$name"]="$source"
        fi
    done < <(python3 -c "
import json, sys
m = json.load(open('$manifest_file'))
for s in m['skills']:
    print(f'{s[\"name\"]}|{s[\"source\"]}')
" 2>/dev/null || grep -E '^\s*\{\s*"name"' "$manifest_file" | while read -r item; do
        # Fallback: use python3 if available, else parse line by line
        local n=$(echo "$item" | sed 's/.*"name": *"\([^"]*\)".*/\1/')
        local src=$(echo "$item" | sed 's/.*"source": *"\([^"]*\)".*/\1/')
        [ -n "$n" ] && [ -n "$src" ] && _map["$n"]="$src"
    done)
}
```

**关键设计决策**：
- 优先使用 `python3 -c` 解析（如果可用），语法最清晰
- 回退方案使用 `grep + sed` 行级解析，无需 jq

### 4.4 DT-04: 5 个脚本 skillMap 替换方案

#### 替换模式

每个脚本的改造遵循统一模板：

**改造前（以 setup.ps1 为例）**：
```powershell
$skillMap = @{
    "devflow-init" = "devflow-init\SKILL.md"
    # ... 25+ 行硬编码
}
```

**改造后**：
```powershell
$manifestPath = Join-Path $PSScriptRoot "devflow-manifest.json"
$skillMap, $skillCount = Get-ManifestSkillMap -ManifestPath $manifestPath
```

**各脚本改造量**：

| 脚本 | 当前行数 | 净删减 | 改后结构 |
|:----:|:--------:|:------:|---------|
| setup.ps1 | ~30 行 skillMap | -30 | 3 行调用 |
| setup.sh（PS 分支） | ~28 行 SKILL_MAP | -28 | 3 行调用 |
| setup.sh（Bash 分支） | ~28 行 SKILL_MAP | -28 | 3 行调用 |
| update.ps1 | ~30 行 skillMap | -30 | 3 行调用 |
| update.sh | ~30 行 SKILL_MAP | -30 | 3 行调用 |
| sync-skills.ps1 | ~50 行 DevFlowSkills | -50 | 改为从 manifest 动态构建 |

### 4.5 DT-05: Download 后 manifest 文件完整性校验

```powershell
# 校验 clone 后 required 文件完整
function Invoke-ManifestIntegrityCheck {
    param([string]$CloneDir, [string]$ManifestPath)
    $manifest = Get-Content $ManifestPath -Encoding UTF8 | ConvertFrom-Json
    $missing = @()
    foreach ($s in $manifest.skills) {
        if ($s.required) {
            $filePath = Join-Path $CloneDir $s.source
            if (-not (Test-Path $filePath)) {
                $missing += "$($s.name): $($s.source)"
            }
        }
    }
    if ($missing.Count -gt 0) {
        Write-Err "MANIFEST CHECK FAILED: $($missing.Count) required file(s) missing"
        $missing | ForEach-Object { Write-Err "  missing: $_" }
        exit 1
    }
    Write-OK "Manifest integrity check: $($manifest.skills.Count) entries OK"
}
```

### 4.6 DT-06: Setup 后安装数量校验

```powershell
# 在 Phase 2 安装完成后
$installedDirs = Get-ChildItem -Path $TraeSkillsDir -Directory
$installedCount = ($installedDirs | Where-Object {
    $skillName = $_.Name
    # 只统计 manifest 中声明的技能，排除非 DevFlow 目录
    $manifest.skills.name -contains $skillName
}).Count

if ($installedCount -ne $skillCount) {
    Write-Warn "Skill count mismatch: installed=$installedCount, expected=$skillCount"
} else {
    Write-OK "Installed: $installedCount/$skillCount skills"
}
```

### 4.7 DT-07: Init 技能数量一致性告警

```powershell
# 在 devflow-init 流程末尾
$traeSkillsDir = "$env:USERPROFILE\.trae-cn\skills"
$manifest = Get-Content "$PSScriptRoot\devflow-manifest.json" -Encoding UTF8 | ConvertFrom-Json
$installedSkills = Get-ChildItem $traeSkillsDir -Directory | Where-Object {
    $manifest.skills.name -contains $_.Name
}
if ($installedSkills.Count -ne $manifest.skillCount) {
    Write-Warn "[WARN] DevFlow skill count mismatch: installed=$($installedSkills.Count), expected=$($manifest.skillCount)"
    Write-Warn "[WARN] Run 'sync-skills.ps1 -Action Sync' to reinstall"
}
```

---

## 5. 非功能设计

### 5.1 兼容性

| 维度 | 设计 | 
|------|------|
| 向后兼容 | manifest 改造后 5 个脚本输出的安装结果与改造前完全一致 |
| 脚本 API 不变 | 各脚本不新增/不修改参数和退出码语义 |
| JSON 解析 | PowerShell 用 `ConvertFrom-Json`, Bash 用 `python3 -c`(首选)/`grep+sed`(回退) |

### 5.2 性能

manifest.json 约 2KB, 加载+解析时间在 PowerShell/Bash 下均 < 20ms，对安装总耗时无影响。

---

## 6. 安全设计

| 项 | 设计 |
|----|------|
| 防篡改 | manifest.json 为只读引用，脚本不修改 |
| 路径安全 | 所有 source 路径使用相对路径（相对于 devflow-plugin/），防止路径遍历 |

---

## 7. 部署与环境设计

| 环境 | 安装方式 | manifest 使用 |
|:----:|---------|:-------------:|
| Dev | install.ps1 / install.sh | 从本地 devflow-plugin/ 读取 |
| Test | update.ps1 / update.sh | 从本地 devflow-plugin/ 读取 |
| Pro | sync-skills.ps1 | 从本地 devflow-plugin/ 读取 |

---

## 8. 已知设计缺口与风险

| 缺口/风险 | 级别 | 说明 | 缓解措施 |
|-----------|:----:|------|---------|
| Bash 分支 JSON 解析 | P1 | Bash 原生不支持 JSON，可能在某些受限环境解析失败 | 首选 python3，回退 grep/sed，极低概率无 python3 |
| manifest 路径硬编码 | P1 | 脚本在 `$PSScriptRoot` 寻找 manifest，如果移动则失败 | 与 version.json 同目录，移动概率极低 |

---

## 9. 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-18 | 初始创建 | AD-DevFlow-Dev |
