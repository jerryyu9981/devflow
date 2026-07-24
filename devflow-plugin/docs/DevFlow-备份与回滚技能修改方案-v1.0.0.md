# DevFlow v2.3.1 技能修改总方案

> **版本**: v1.0.0 | **日期**: 2026-07-01 | **状态**: 待确认
> **涵盖内容**: 备份与回滚能力落地 + 设计总览首页规范
> **关联文档**: `docs/DevFlow-备份解决方案.md`（已更新第十二章回滚设计）

---

## 一、修改范围总览

本次修改基于 `docs/DevFlow-备份解决方案.md` 中定义的三层备份体系（策略层/配置层/操作层）和十二章回滚设计，将方案内容同步落地到以下 **7 个文件**:

| 序号 | 文件路径 | 层级 | 修改类型 | 修改量 |
|:----:|---------|:----:|:--------:|:------:|
| 1 | `skills/L3/code-version-backup-management.md` | 策略层 | 改 | 第六章回滚流程扩展为完整设计 |
| 2 | `skills/L2/operations-stage-execution.md` | 主控层 | 改 | 部署运维矩阵/强制规则/L3速查增强 |
| 3 | `skills/L3/cicd-pipeline-management.md` | 框架层 | 增 | 新增"回滚自动化"独立章节 |
| 4 | `devflow-project-config/SKILL.md` | 配置层 | 改 | 补充 `backup.environments` 多环境配置 |
| 5 | `devflow-init/SKILL.md` | 初始化层 | 改 | 更新 hook 脚本和 config.json 模板 |
| 6 | `setup.ps1` | 安装脚本 | 改 | 增强 post-push hook（日志/错误处理/验证） |
| 7 | `setup.sh` | 安装脚本 | 改 | 同上，Bash 版本 |

---

## 二、文件 1: code-version-backup-management.md

### 2.1 修改位置: 第六章"回滚流程"（第 176-196 行）

**修改类型**: 全文替换（从 3 个小节扩展为 10 个小节）

**当前内容（待替换）**:

```markdown
## 六、回滚流程

### 6.1 代码回滚

```bash
# 回退指定 commit（推荐，保留历史）
git revert {commit-hash}

# 恢复特定文件到指定版本
git checkout v1.0.0 -- {file/path}

# 硬重置到指定版本（谨慎使用，仅本地分支）
git reset --hard {commit-hash}
```

### 6.2 回滚门禁

- 任何回滚操作必须在 `问题跟踪记录` 中记录原因和影响
- 生产回滚必须在 `发布复盘报告` 中记录根本原因分析
- 详细回滚预案参考 `operations-stage-execution` 的部署运维矩阵
```

**替换为**（内容同 `docs/DevFlow-备份解决方案.md` 第十二章，此处仅列出结构）:

```markdown
## 六、回滚流程

### 6.1 回滚策略总览
- 按回滚对象分类: 代码/数据/配置/服务
- 按触发方式分类: 自动(CI/CD监控) / 手动(人工审批)
- ASCII 架构图

### 6.2 回滚触发条件
- 6.2.1 自动触发: 6项指标(健康检查/错误率/P99/冒烟失败/资源/依赖)
- 6.2.2 手动触发: 5种场景(P0缺陷/脏数据/安全/合规/性能)
- 自动回滚安全约束说明

### 6.3 回滚审批流程
- 6.3.1 审批级别矩阵(Dev/Test/Pro三级)
- 6.3.2 标准审批流程(Pro环境7步)
- 6.3.3 紧急回滚流程(P0故障绕过审批)

### 6.4 按部署策略的回滚路径
- 6.4.1 直接部署(Dev/Test): 6步+命令
- 6.4.2 蓝绿部署(Pro): 流程图+5步耗时
- 6.4.3 金丝雀发布(Pro): 3阶段回滚+影响表
- 6.4.4 滚动更新(K8s): 5步+kubectl命令

### 6.5 数据回滚策略
- 6.5.1 数据库回滚: 3种场景(down迁移/备份恢复/dump)
- 6.5.2 数据库回滚流程: 5步流程
- 6.5.3 缓存与消息回滚: Redis/消息队列

### 6.6 回滚验证
- 6.6.1 6项验证(健康/API/错误率/延迟/DB/业务流)
- 6.6.2 回滚失败处理: 5步升级流程

### 6.7 CI/CD 自动回滚 Job 设计
- 6.7.1 GitHub Actions rollback.yml (完整YAML)
- 6.7.2 金丝雀自动回滚 Job (监控触发)

### 6.8 回滚记录与审计
- 6.8.1 CSV回滚历史格式
- 6.8.2 6条增强版回滚门禁

### 6.9 与现有技能的衔接
- 4个技能协作关系表

### 6.10 执行检查清单
- 发布前6项/回滚时4项/回滚后3项
```

### 2.2 修改位置: 第七章"与 CI/CD 流水线的接口"

**修改类型**: 在接口表中增加回滚相关行

**当前接口表**（第 203-208 行）:

| 接口 | 本技能提供的规则 | 流水线执行方 |
|------|----------------|------------|
| tag 触发构建 | ... | ... |
| 自动备份 mirror | ... | ... |
| TDD 合规检查 | ... | ... |
| release 分支保护 | ... | ... |

**增加一行**:

| 接口 | 本技能提供的规则 | 流水线执行方 |
|------|----------------|------------|
| tag 触发构建 | ... | ... |
| 自动备份 mirror | ... | ... |
| **自动/手动回滚** | **回滚触发条件、审批流程、目标版本标记** | **`cicd-pipeline-management` rollback job + 金丝雀自动回滚** |
| TDD 合规检查 | ... | ... |
| release 分支保护 | ... | ... |

---

## 三、文件 2: operations-stage-execution.md

### 3.1 修改位置: 部署运维矩阵（第 74-94 行）

**修改类型**: 增强现有"回滚预案"和"回滚演练"两行

**当前"回滚预案"行**:

| 回滚预案 | 回滚触发条件、回滚步骤、数据回滚、验证方式 | 回滚路径明确、可执行 | 回滚预案 |

**修改为**:

| 回滚预案 | 回滚触发条件、回滚步骤、数据回滚、验证方式；**按部署策略区分回滚路径（直接/蓝绿/金丝雀/K8s）；审批流程（标准+紧急）** | 回滚路径明确、可执行；**Pro环境必须包含审批人列表** | 回滚预案 |

**当前"回滚演练"行**:

| 回滚演练 | 验证关键路径是否可回滚 | 演练成功或风险有批准 | 回滚演练记录 |

**修改为**:

| 回滚演练 | 验证关键路径是否可回滚；**蓝绿/金丝雀场景演练自动回滚触发；数据回滚演练（如有DB变更）** | 演练成功或风险有批准；**自动回滚触发验证通过** | 回滚演练记录 |

### 3.2 修改位置: 强制规则（第 96-105 行）

**修改类型**: 在现有 8 条规则基础上增加回滚相关规则

**当前第 2 条**:

2. **不得无回滚上线**：无回滚预案、回滚验证或风险批准，不得生产发布。

**增强为**:

2. **不得无回滚上线**：无回滚预案、回滚验证或风险批准，不得生产发布。**回滚预案必须包含：目标版本、部署策略对应的回滚路径、审批人、数据回滚方案。**

**新增规则 9**:

9. **回滚后必须验证**：回滚完成后 15 分钟内必须完成健康检查+冒烟验证，未验证通过视为回滚失败，必须升级至 P0 处理。

### 3.3 修改位置: L3 部署运维速查（第 182-184 行）

**修改类型**: 扩展内联自 code-version-backup-management 的回滚速查

**当前内容**:

以下规则内联自 code-version-backup-management 技能：
- 回滚命令：git revert {hash}（推荐保留历史）/ git checkout v1.0.0 -- {file}（恢复文件）/ git reset --hard {hash}（仅本地）
- 回滚门禁：任何回滚必须在问题跟踪记录中记录原因和影响；生产回滚必须在发布复盘中记录 RCA
- 权限：...
- 备份触发：...

**增强为**:

以下规则内联自 code-version-backup-management 技能：
- 回滚命令：git revert {hash}（推荐保留历史）/ git checkout v1.0.0 -- {file}（恢复文件）/ git reset --hard {hash}（仅本地）
- 回滚策略分类：代码回滚（git）、数据回滚（DB dump/down迁移）、配置回滚（配置中心/K8s ConfigMap）、服务回滚（蓝绿切换/金丝雀流量切回/滚动更新回退）
- 回滚触发：自动触发（健康检查失败/错误率>1%/P99>基线+50%/冒烟失败）+ 手动触发（P0缺陷/脏数据/安全/合规/性能）
- 审批流程：Dev自决/Test审查者审批/Pro发布负责人+PM双签（数据回滚+DBA三签）
- 紧急回滚：P0故障可绕过审批，2小时内补录材料，24小时内输出RCA
- 回滚门禁：任何回滚必须在问题跟踪记录中记录原因和影响；生产回滚必须在发布复盘中记录 RCA；回滚后15分钟内必须完成验证
- 权限：...
- 备份触发：...

---

## 四、文件 3: cicd-pipeline-management.md

### 4.1 修改位置: 在"部署策略详细说明"之后新增"回滚自动化"章节

**当前"部署策略详细说明"结束位置**: 第 177 行（金丝雀发布说明结束）

**在第 177 行后插入新章节**:

```markdown
## 回滚自动化

### 自动回滚触发条件

当以下任一指标在生产环境发布后 15 分钟内触发，系统自动发起回滚：

| 触发指标 | 阈值 | 检测窗口 | 自动动作 |
|---------|------|---------|---------|
| 健康检查失败 | `/health` 或 `/ready` 非 200 | 连续 3 次，间隔 10s | **自动回滚** |
| 错误率飙升 | 5xx 错误率 > 1% | 5 分钟滑动窗口 | **自动回滚** |
| P99 延迟超基线 | P99 > 基线 +50% | 5 分钟滑动窗口 | **告警 + 人工确认** |
| 核心功能冒烟失败 | 关键 API / 主流程失败 | 发布后 10 分钟内 | **自动回滚** |

> **约束**：自动回滚仅适用于蓝绿部署和金丝雀发布场景。

### 手动回滚触发

| 场景 | 触发方式 |
|------|---------|
| 发布后发现 P0 缺陷 | workflow_dispatch 触发 rollback job |
| 业务数据异常 | 数据回滚流程 |
| 安全漏洞紧急修复回退 | emergency-rollback |

### GitHub Actions 回滚 Job

```yaml
# .github/workflows/rollback.yml
name: Emergency Rollback
on:
  workflow_dispatch:
    inputs:
      target_version:
        description: '回滚目标版本 (tag)'
        required: true
      reason:
        description: '回滚原因'
        required: true
      environment:
        description: '目标环境'
        required: true
        default: 'pro'
        type: choice
        options: [dev, test, pro]

jobs:
  rollback:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.inputs.target_version }}
          fetch-depth: 0

      - name: Record rollback event
        run: |
          echo "ROLLBACK: $(date)" >> rollback-history.log
          echo "From: $(git describe --tags --abbrev=0)" >> rollback-history.log
          echo "To: ${{ github.event.inputs.target_version }}" >> rollback-history.log
          echo "Reason: ${{ github.event.inputs.reason }}" >> rollback-history.log
          echo "By: ${{ github.actor }}" >> rollback-history.log

      - name: Deploy previous version (Blue-Green)
        if: github.event.inputs.environment == 'pro'
        run: ./scripts/switch-traffic.sh ${{ github.event.inputs.target_version }}

      - name: Deploy previous version (Direct)
        if: github.event.inputs.environment != 'pro'
        run: ./scripts/deploy.sh ${{ github.event.inputs.target_version }} ${{ github.event.inputs.environment }}

      - name: Health check
        run: |
          sleep 30
          curl -sf ${{ env.HEALTH_URL }} || exit 1

      - name: Smoke test
        run: ./scripts/smoke-test.sh ${{ github.event.inputs.environment }}
```

### 金丝雀自动回滚 Job

```yaml
canary-rollback:
  if: failure() && github.ref == 'refs/tags/v*'
  needs: [deploy-canary, smoke-test, monitor-check]
  runs-on: ubuntu-latest
  steps:
    - name: Auto rollback canary
      run: |
        echo "金丝雀验证失败，自动回滚..."
        ./scripts/canary-rollback.sh
    - name: Verify rollback
      run: ./scripts/smoke-test.sh pro
```

### 回滚验证

回滚后必须执行：健康检查、核心 API 冒烟测试、错误率监控、P99 延迟检查、数据库连接验证、关键业务流 E2E 测试。

### 按部署策略的回滚路径

| 部署策略 | 回滚方式 | 耗时 | 停机 |
|---------|---------|------|------|
| 直接部署 | 停止→checkout旧版本→重建→重启 | 5-10min | 有 |
| 蓝绿部署 | 负载均衡器切换流量到 Blue | < 30s | 无 |
| 金丝雀发布 | 停止金丝雀实例/逐步切回流量 | < 30s | 无 |
| 滚动更新(K8s) | `kubectl rollout undo` | 2-5min | 无 |
```

### 4.2 修改位置: "流水线故障排查"表（第 260-269 行）

**增加回滚相关故障行**:

| 回滚失败 | 目标版本不存在/脚本错误/权限不足 | 检查 tag 存在性/脚本日志/权限 | 确认版本 tag / 修复脚本 / 授权 |
| 自动回滚未触发 | 监控阈值配置错误/告警未接入 | 检查监控规则/告警通道 | 校准阈值/修复告警通道 |
| 回滚后验证失败 | 数据不一致/依赖服务未恢复 | 检查数据状态/依赖服务健康 | 执行数据回滚/重启依赖服务 |

---

## 五、文件 4: devflow-project-config/SKILL.md

### 5.1 修改位置: config.json 完整结构（第 23-41 行）

**修改类型**: 在 backup 配置中增加 `environments` 多环境分离

**当前配置模板**:

```json
{
  "project": "项目名称",
  "devflowVersion": "2.3.0",
  "branchStrategy": "git-flow",
  "remote": {
    "origin": "git@github.com:org/project.git",
    "backup": "git@backup-server:org/project-backup.git"
  },
  "backup": {
    "type": "git-mirror",
    "schedule": {
      "bundle": "weekly",
      "bundleRetention": 4,
      "dbDump": "daily",
      "dbRetention": 90
    }
  }
}
```

**替换为**:

```json
{
  "project": "项目名称",
  "devflowVersion": "2.3.0",
  "branchStrategy": "git-flow",
  "remote": {
    "origin": "git@github.com:org/project.git",
    "backup": "git@backup-server:org/project-backup.git"
  },
  "backup": {
    "type": "git-mirror",
    "environments": {
      "dev": {
        "backup": "git@backup-server:org/project-dev-backup.git"
      },
      "test": {
        "backup": "git@backup-server:org/project-test-backup.git"
      },
      "pro": {
        "backup": "git@backup-server:org/project-pro-backup.git",
        "disaster": "git@disaster-server:org/project-disaster-backup.git"
      }
    },
    "schedule": {
      "type": "post-push",
      "weeklyArchive": "sunday-02:00",
      "retentionDays": 90
    }
  }
}
```

### 5.2 修改位置: 配置项详解表（第 46-57 行）

**增加以下配置项说明**:

| `backup.environments.dev.backup` | string | "" | 开发环境备份仓库地址 |
| `backup.environments.test.backup` | string | "" | 测试环境备份仓库地址 |
| `backup.environments.pro.backup` | string | "" | 生产环境备份仓库地址 |
| `backup.environments.pro.disaster` | string | "" | 容灾备份仓库地址（异地） |
| `backup.schedule.type` | enum | "post-push" | 备份触发方式：post-push / cron |
| `backup.schedule.weeklyArchive` | string | "sunday-02:00" | 每周归档时间 |
| `backup.schedule.retentionDays` | int | 90 | 备份保留天数 |

---

## 六、文件 5: devflow-init/SKILL.md

### 6.1 修改位置: config.json 模板（第 57-75 行）

**修改类型**: 同步 devflow-project-config 的增强配置

**当前模板**:

```json
{
  "project": "{项目名称}",
  "devflowVersion": "2.3.0",
  "branchStrategy": "git-flow",
  "remote": {
    "origin": "",
    "backup": ""
  },
  "backup": {
    "type": "git-mirror",
    "schedule": {
      "bundle": "weekly",
      "bundleRetention": 4,
      "dbDump": "daily",
      "dbRetention": 90
    }
  }
}
```

**替换为**（同 devflow-project-config 增强版）。

### 6.2 修改位置: 安装 Git Hook（第 104-114 行）

**修改类型**: 增强 hook 脚本（增加日志记录、错误处理、验证）

**当前 hook**:

```bash
#!/bin/bash
# DevFlow auto-backup hook
if git remote | grep -q backup; then
    git push --mirror backup 2>/dev/null
fi
```

**替换为**:

```bash
#!/bin/bash
# DevFlow 自动备份 Hook
# 安装方式：cp .devflow/hooks/post-push .git/hooks/post-push && chmod +x .git/hooks/post-push

REMOTE_NAME="${1:-backup}"
LOG_DIR=".devflow/logs"
mkdir -p "$LOG_DIR"

if git remote | grep -q "$REMOTE_NAME"; then
    echo "[DevFlow Backup] $(date '+%Y-%m-%d %H:%M:%S') 开始备份到 $REMOTE_NAME ..."
    git push --mirror "$REMOTE_NAME" 2>&1
    git push --tags "$REMOTE_NAME" 2>&1

    if [ $? -eq 0 ]; then
        echo "[DevFlow Backup] 备份完成"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),git-mirror,成功,$(git rev-parse HEAD)" >> "$LOG_DIR/backup-history.csv"
    else
        echo "[DevFlow Backup] 备份失败"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),git-mirror,失败,$(git rev-parse HEAD)" >> "$LOG_DIR/backup-error.csv"
    fi
else
    echo "[DevFlow Backup] 未找到远程仓库 '$REMOTE_NAME'，跳过备份"
fi
```

---

## 七、文件 6: setup.ps1

### 7.1 修改位置: Git Hook 安装段（第 189-205 行）

**修改类型**: 增强 hook 脚本，并增加 `.devflow/logs/` 目录创建

**当前 hook 安装逻辑**:

```powershell
# 7. Install Git Hook (optional)
if ($InstallHook -and (Test-Path ".git")) {
    Write-Header "Installing Git Post-Push Hook"
    $hookDir = ".git\hooks"
    $hookPath = Join-Path $hookDir "post-push"
    $hookContent = @'
#!/bin/bash
# DevFlow auto-backup hook
if git remote | grep -q backup; then
    echo "[DevFlow] Pushing mirror to backup remote..."
    git push --mirror backup
    git push --tags backup
fi
'@
    Set-Content $hookPath $hookContent -Encoding UTF8
    Write-Success "Installed: $hookPath"
}
```

**替换为**:

```powershell
# 7. Install Git Hook (optional)
if ($InstallHook -and (Test-Path ".git")) {
    Write-Header "Installing Git Post-Push Hook"
    
    # 创建日志目录
    $logDir = ".devflow\logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    }
    
    # 创建备份历史 CSV 头部
    $historyFile = Join-Path $logDir "backup-history.csv"
    if (-not (Test-Path $historyFile)) {
        "时间,备份类型,状态,Commit SHA" | Set-Content $historyFile -Encoding UTF8
    }
    
    $hookDir = ".git\hooks"
    $hookPath = Join-Path $hookDir "post-push"
    $hookContent = @'
#!/bin/bash
# DevFlow 自动备份 Hook
REMOTE_NAME="${1:-backup}"
LOG_DIR=".devflow/logs"
mkdir -p "$LOG_DIR"

if git remote | grep -q "$REMOTE_NAME"; then
    echo "[DevFlow Backup] $(date '+%Y-%m-%d %H:%M:%S') 开始备份到 $REMOTE_NAME ..."
    git push --mirror "$REMOTE_NAME" 2>&1
    git push --tags "$REMOTE_NAME" 2>&1

    if [ $? -eq 0 ]; then
        echo "[DevFlow Backup] 备份完成"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),git-mirror,成功,$(git rev-parse HEAD)" >> "$LOG_DIR/backup-history.csv"
    else
        echo "[DevFlow Backup] 备份失败"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),git-mirror,失败,$(git rev-parse HEAD)" >> "$LOG_DIR/backup-error.csv"
    fi
else
    echo "[DevFlow Backup] 未找到远程仓库 '$REMOTE_NAME'，跳过备份"
fi
'@
    Set-Content $hookPath $hookContent -Encoding UTF8
    Write-Success "Installed: $hookPath"
    Write-Success "Created: $logDir"
}
```

---

## 八、文件 7: setup.sh

### 8.1 修改位置: Git Hook 安装段

**修改类型**: 同 setup.ps1，Bash 版本同步增强

由于当前 setup.sh 内容未在对话中展示，修改方案为：找到 hook 安装段（类似 setup.ps1 第 189-205 行的逻辑），替换为增强版 hook（同 devflow-init/SKILL.md 中的增强脚本），并增加 `.devflow/logs/` 目录和 `backup-history.csv` 初始化。

---

## 九、文件 8: prototype-coverage.md

### 9.1 修改位置: Step 1（建立前端页面清单）之后新增 Step 1.5

**修改类型**: 新增"生成设计总览首页"步骤

**插入位置**: Step 1 结束（第 45 行强制产出之后），Step 2 开始之前

**插入内容**:

```markdown
### Step 1.5: 生成设计总览首页（Design Overview Index）

基于页面清单，自动生成 `prototype/index.html` 设计总览首页。

**首页必须包含**:

1. **项目元信息**：项目名称、版本号、设计阶段、生成时间
2. **页面导航列表**：按优先级排序，标注 P0/P1/P2
3. **每个页面条目**：
   - 页面名称和唯一 ID（PG-/MD-/DW- 编号）
   - 优先级（P0 🔴 / P1 🟡 / P2 🟢）
   - 状态覆盖进度（已覆盖 / 总计 6 种状态）
   - 设计完成度标记（已完成 / 进行中 / 未开始）
   - 走查状态标记（通过 ✅ / 有断点 ⚠️ / 未走查 —）
   - 可点击链接：打开该页面原型
4. **核心用户路径走查入口**：按路径分组，点击后按顺序浏览页面
5. **覆盖率汇总统计**：页面总数、覆盖率、状态覆盖率、走查通过率

**技术要求**:

- 纯静态 HTML + CSS，无外部网络依赖
- 支持浏览器直接打开（`file://` 协议）
- 页面链接使用相对路径（如 `./pages/login.html`）
- 响应式布局，支持不同屏幕尺寸

**强制产出**: `prototype/index.html`
```

### 9.2 修改位置: Document Storage（第 222-235 行）

**修改类型**: 目录结构中明确 index.html 位置

**当前目录结构**:

```text
环境目录\项目名\doc\design\
    ├── {项目名}-前端页面清单-v{版本号}.md
    ├── ...
    └── prototype\
        ├── index.html
        └── ...
```

**修改为**:

```text
环境目录\项目名\doc\design\
    ├── {项目名}-前端页面清单-v{版本号}.md
    ├── ...
    └── prototype\              # HTML原型文件目录
        ├── index.html          ← 设计总览首页（审核入口）
        ├── pages\              # 各页面原型文件
        │   ├── login.html
        │   ├── dashboard.html
        │   └── ...
        └── assets\             # 静态资源
            ├── css\
            └── images\
```

---

## 十、文件 9: design-stage-execution.md

### 10.1 修改位置: 设计规范矩阵（第 74-96 行）

**修改类型**: 增强"UI/UX 与原型"行

**当前行**:

| UI/UX 与原型 | 用户路径、线框图、交互状态、表单、错误态、空态、加载态 | 关键用户路径和状态完整 | UI 设计文档、原型 |

**修改为**:

| UI/UX 与原型 | 用户路径、线框图、交互状态、表单、错误态、空态、加载态；**生成设计总览首页（`prototype/index.html`）供审核人一键预览全部页面** | 关键用户路径和状态完整；**设计总览首页可从浏览器直接打开且所有页面链接有效** | UI 设计文档、原型、**设计总览首页** |

### 10.2 修改位置: 输出要求（第 130-146 行）

**修改类型**: 在输出列表中增加设计总览首页

**在原型相关输出项后增加**:

```markdown
- `prototype/index.html`（设计总览首页，含页面导航、覆盖率一览、用户路径走查入口；审核人可直接从浏览器打开预览全部页面）
```

---

## 十一、版本更新计划

### 11.1 文档版本号更新

| 文档 | 当前版本 | 更新后版本 | 变更类型 |
|------|---------|-----------|---------|
| `docs/DevFlow-备份解决方案.md` | v1.0.0 | **v1.1.0** | 新增第十二章回滚设计 |
| `skills/L3/code-version-backup-management.md` | 无版本 | 在 YAML frontmatter 中增加 `version: "2.3.1"` | 第六章回滚流程扩展 |
| `skills/L2/operations-stage-execution.md` | 无版本 | 在 YAML frontmatter 中增加 `version: "2.3.1"` | 部署矩阵/强制规则增强 |
| `skills/L3/cicd-pipeline-management.md` | 无版本 | 在 YAML frontmatter 中增加 `version: "2.3.1"` | 新增回滚自动化章节 |
| `devflow-project-config/SKILL.md` | 无版本 | 在 YAML frontmatter 中增加 `version: "2.3.1"` | 配置模板增强 |
| `devflow-init/SKILL.md` | 无版本 | 在 YAML frontmatter 中增加 `version: "2.3.1"` | config/hook 增强 |

### 11.2 DevFlow 插件版本

| 项目 | 当前 | 更新后 |
|------|------|--------|
| 插件整体版本 | v2.3.0 | **v2.3.1**（功能增强，次版本+1） |
| `devflowVersion` 硬编码值 | 2.3.0 | **2.3.1** |

### 11.3 修订历史记录

在 `docs/DevFlow-备份解决方案.md` 文档头部增加修订历史：

```markdown
## 修订历史

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|---------|
| v1.1.0 | 2026-07-01 | DevFlow | 新增第十二章"回滚设计"，完善备份-回滚闭环 |
| v1.0.0 | 2026-06-29 | DevFlow | 初始版本，整合策略层/配置层/操作层备份体系 |
```

---

## 十二、执行顺序建议

建议按以下顺序执行修改，确保引用关系正确：

```
1. devflow-project-config/SKILL.md              → 配置层先定稿
2. devflow-init/SKILL.md                        → 初始化引用配置层
3. setup.ps1 + setup.sh                         → 安装脚本引用 hook 逻辑
4. skills/L3/code-version-backup-management.md  → 策略层定义回滚规范
5. skills/L3/cicd-pipeline-management.md        → 框架层实现自动化
6. skills/L2/operations-stage-execution.md      → 主控层整合到部署矩阵
7. skills/L3/prototype-coverage.md              → 原型覆盖检查增加设计总览首页
8. skills/L2/design-stage-execution.md          → 设计阶段输出增加首页要求
9. docs/DevFlow-备份解决方案.md                  → 版本号+修订历史
```

---

## 十三、确认后执行清单

确认本方案后，将执行以下操作：

- [ ] 按第 1-10 节修改 9 个文件
- [ ] 按第 11 节更新所有版本号
- [ ] 在 `docs/DevFlow-备份解决方案.md` 头部增加修订历史
- [ ] 更新 `README.md` 中的版本号（如有硬编码）
- [ ] 重新打包 DevFlow 插件
- [ ] 提交 Git commit + push 到 origin + backup
- [ ] 同步到 TRAE 技能目录

---

*本方案为 DevFlow v2.3.1 的完整技能修改方案，涵盖备份-回滚闭环能力落地和设计总览首页规范，待确认后执行。*
