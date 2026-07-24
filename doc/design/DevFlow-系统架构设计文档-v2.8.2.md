# DevFlow 系统架构设计文档 v2.8.2

> **文档状态**: [Draft]
> **版本**: 1.0.0
> **项目**: DevFlow
> **目标版本**: v2.8.2
> **作者**: DA-DevFlow-Dev
> **创建日期**: 2026-07-18

---

## 1. 设计入场检查

| 检查项 | 状态 | 证据 |
|--------|:----:|------|
| Step 0 版本规划已批准 | ✅ | 评审结论 Approved |
| Step 1 需求文档+评审+评估审计已批准 | ✅ | 三项均 passed |
| 需求追溯矩阵齐全 | ✅ | RT-01~05，覆盖率 100% |
| P0/P1 需求可设计 | ✅ | 4 项需求均为脚本修改，涉及文件明确 |

**激活轨道**：🎯 整体 + ⚙️ 后端

**不适用设计类别**：Agent 架构、前端架构、UI/UX/原型/Figma、API 接口、数据模型/数据库、缓存与消息、安全设计、可观测性设计、部署与环境设计。原因：本版本为纯命令行脚本修改，不涉及 UI、数据库、服务端运行时或外部系统集成。

---

## 2. 需求-设计追溯矩阵

| DT-ID | RT-ID | Backlog ID | 设计项 | 涉及文件 | 设计章节 |
|:-----:|:-----:|:----------:|--------|---------|---------|
| DT-01 | RT-01 | V260-047 | install.ps1 Step 1 重构：删除内联 git clone，改为调用 download-devflow.ps1 | `install.ps1`, `install.bat` | §3.1 |
| DT-02 | RT-02 | V260-048 | install.ps1 新增 `-TargetDir` 参数 + repository 空值时自动引导 SetRepo | `install.ps1`, `install.bat` | §3.2 |
| DT-03 | RT-03 | V260-050 | 5 个脚本新增 BOM 检测+去除函数，在文件复制/同步后批量执行 | `setup.ps1`, `setup.sh`, `update.ps1`, `update.sh`, `sync-skills.ps1` | §3.3 |
| DT-04 | RT-04 | V260-049 | 5 个脚本统一从 `DEVFLOW_SKILLS_DIR` 环境变量读取目标目录 | `setup.ps1`, `setup.sh`, `update.ps1`, `update.sh`, `sync-skills.ps1` | §3.4 |
| DT-05 | RT-05 | — | 全部修改脚本语法验证 + version.json 版本号更新 | `version.json` | §3.5 |

**覆盖率**：5/5 Backlog 项 + 5/5 追溯项 = 100%

---

## 3. 系统架构设计

### 3.1 DT-01：install.ps1 Step 1 重构

**当前结构**（v2.8.1）：

```
install.ps1
├── 安全检测（.devflow 目录自检）
├── Step 1: Download（内联 ~100 行 git clone 逻辑）  ← 删除
├── Step 2: Setup（调用 setup.ps1）
└── Summary
```

**目标结构**（v2.8.2）：

```
install.ps1
├── 参数定义：param([string]$TargetDir = "")
├── 安全检测（.devflow 目录自检，保留）
├── Step 1: Download（调用 download-devflow.ps1）
│   ├── 检测 .git 目录 → 已下载则跳过
│   ├── 读取 version.json.repository
│   ├── repository 为空 → 调用 SetRepo（DT-02）
│   ├── 调用 download-devflow.ps1 -Action Clone -TargetDir $TargetDir
│   └── 失败时提示"使用本地文件"，不中断
├── Step 2: Setup（调用 setup.ps1，保留）
└── Summary + exit 0
```

**关键设计决策**：

| 决策 | 选择 | 理由 |
|------|------|------|
| 调用方式 | `& "$ScriptDir\download-devflow.ps1" -Action Clone -TargetDir $effectiveDir` | 使用 `$PSScriptRoot` 构建绝对路径，避免相对路径问题 |
| 错误处理 | `$ErrorActionPreference = "Continue"` 保持不变 | 下载失败不中断安装，使用本地文件继续 |
| .git 检测 | 保留原有的 `.git` 目录检测逻辑 | 已下载的用户直接跳到 Step 2 |
| SetRepo 后重读 | SetRepo 完成后重新读取 version.json.repository | 确保 Clone 使用刚设置的 URL |

**install.bat 变更**：

```batch
:: 支持 -TargetDir 参数透传
powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1" -TargetDir "%~1"
```

---

### 3.2 DT-02：install.ps1 首次安装引导 + -TargetDir

**参数设计**：

```powershell
param(
    [string]$TargetDir = ""
)
```

**TargetDir 解析逻辑**：

```
$effectiveDir = if ($TargetDir) { $TargetDir } else { $PSScriptRoot }
```

**repository 空值引导流程**：

```
读取 version.json.repository
  ├── 非空 → 直接进入 Clone
  └── 为空 → 调用 download-devflow.ps1 -Action SetRepo
              ├── 成功 → 重新读取 repository → Clone
              └── 失败/取消 → 提示"使用本地文件" → 继续 Step 2
```

---

### 3.3 DT-03：BOM 检测 + 去除函数设计

**PowerShell 函数**（供 3 个 .ps1 脚本复用）：

```powershell
function Remove-Utf8Bom {
    param([string]$FilePath)
    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $content = [System.IO.File]::ReadAllText($FilePath, [System.Text.UTF8Encoding]::new($true))
        [System.IO.File]::WriteAllText($FilePath, $content, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "[BOM Fixed] $(Split-Path $FilePath -Leaf)" -ForegroundColor Yellow
        return $true
    }
    return $false
}
```

**Bash 函数**（供 2 个 .sh 脚本复用）：

```bash
remove_utf8_bom() {
    local file="$1"
    local first3=$(head -c 3 "$file" 2>/dev/null | xxd -p)
    if [ "$first3" = "efbbbf" ]; then
        # 去除 BOM：跳过前 3 字节重写
        { printf '\xef\xbb\xbf' | cmp -s - "$file" 2>/dev/null; } && \
        { tail -c +4 "$file" > "$file.tmp" && mv "$file.tmp" "$file"; }
        echo -e "${YELLOW}[BOM Fixed] $(basename "$file")${NC}"
    fi
}
```

**调用时机**：在每个脚本的文件复制/同步完成后、统计输出前执行：

```
文件复制/同步循环
  ├── 复制 .md 文件
  └── ...
BOM 批量处理（新增）
  ├── 遍历目标目录所有 .md 文件
  ├── 调用 Remove-Utf8Bom / remove_utf8_bom
  └── 记录修复数量
输出安装统计
```

**约束**：
- 仅处理 `.md` 文件（`Get-ChildItem -Filter "*.md"` / `find -name "*.md"`）
- 仅检测 UTF-8 BOM（`EF BB BF`），不处理其他编码
- 检测到 BOM 时输出 `[BOM Fixed]` 日志，无 BOM 时静默

---

### 3.4 DT-04：IDE 系统目录可配置化

**统一变量解析逻辑**（PowerShell）：

```powershell
$TraeSkillsDir = if ($env:DEVFLOW_SKILLS_DIR) { $env:DEVFLOW_SKILLS_DIR } else { "$env:USERPROFILE\.trae-cn\skills" }
```

**统一变量解析逻辑**（Bash）：

```bash
TRAE_SKILLS_DIR="${DEVFLOW_SKILLS_DIR:-$HOME/.trae-cn/skills}"
```

**应用位置**：

| 脚本 | 当前硬编码 | 替换为 |
|------|-----------|--------|
| setup.ps1 第 45 行 | `$TraeSkillsDir = "$env:USERPROFILE\.trae-cn\skills"` | 上述变量解析逻辑 |
| setup.sh | `TRA_SKILLS_DIR="${HOME}/.trae-cn/skills"` | 上述变量解析逻辑 |
| update.ps1 | 需检查是否引用了该路径 | 同步替换 |
| update.sh | 需检查是否引用了该路径 | 同步替换 |
| sync-skills.ps1 | 使用 `$env:USERPROFILE\.trae-cn\skills` | 同步替换 |

**目录存在性处理**：

```powershell
if (-not (Test-Path $TraeSkillsDir)) {
    New-Item -ItemType Directory -Path $TraeSkillsDir -Force | Out-Null
    Write-Host "[INFO] Created skills directory: $TraeSkillsDir" -ForegroundColor Cyan
}
```

**安装确认展示增强**：在确认步骤中展示实际使用的目录：

```
DevFlow Version: 2.8.2
Skills to install: 25
Target directory: C:\Users\jerry\.trae-cn\skills  ← 此处展示解析后的路径
```

---

### 3.5 DT-05：语法验证 + 版本号更新

**语法验证方法**：

| 脚本类型 | 验证命令 |
|---------|---------|
| PowerShell | `$null = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$null)` |
| Bash | `bash -n $path` |

**version.json 变更**：

```json
{
  "devflowVersion": "2.8.2"
}
```

---

## 4. 不适用设计类别说明

| 设计类别 | 不适用原因 |
|---------|-----------|
| Agent 架构设计 | 不涉及 LLM/Agent |
| 前端架构设计 | 不涉及前端页面/组件 |
| UI/UX 与原型 / Figma / 设计系统 | 不涉及图形界面 |
| API 接口设计 | 不涉及 REST/GraphQL 接口 |
| 数据模型与数据库设计 | 不涉及数据库 |
| 缓存与消息设计 | 不涉及 Redis/消息队列 |
| 安全设计 | 不涉及认证/授权/敏感数据 |
| 可观测性设计 | 不涉及服务端运行时 |
| 部署与环境设计 | 不涉及容器/CI/CD |

---

## 5. 涉及文件清单

| 文件 | 修改内容 | 对应 DT-ID |
|------|---------|:----------:|
| `install.ps1` | 删除内联 clone（~100 行），新增 -TargetDir 参数，新增 SetRepo 引导，调用 download-devflow.ps1 | DT-01, DT-02 |
| `install.bat` | 支持 TargetDir 参数透传 | DT-01, DT-02 |
| `setup.ps1` | 新增 DEVFLOW_SKILLS_DIR 读取，新增 BOM 去除函数和调用 | DT-03, DT-04 |
| `setup.sh` | 新增 DEVFLOW_SKILLS_DIR 读取，新增 BOM 去除函数和调用 | DT-03, DT-04 |
| `update.ps1` | 新增 DEVFLOW_SKILLS_DIR 读取，新增 BOM 去除函数和调用 | DT-03, DT-04 |
| `update.sh` | 新增 DEVFLOW_SKILLS_DIR 读取，新增 BOM 去除函数和调用 | DT-03, DT-04 |
| `sync-skills.ps1` | 新增 DEVFLOW_SKILLS_DIR 读取，新增 BOM 去除函数和调用 | DT-03, DT-04 |
| `version.json` | devflowVersion 更新为 2.8.2 | DT-05 |
| `CHANGELOG.md` | 新增 v2.8.2 变更记录 | DT-05 |