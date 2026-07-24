# 备份完整性校验规范模板

### 模板：备份完整性校验规范

- **对应文档名**：`{项目名}-备份完整性校验规范-v{版本号}.md`
- **存放路径**：`doc/operations/{项目名}-备份完整性校验规范-v{版本号}.md`
- **作用**：定义备份完整性校验的算法选择、频率策略、报告模板和失败处理流程，确保备份数据可可靠恢复
- **填写时机**：项目上线后首次备份任务配置时制定
- **填写责任角色**：OA（运维架构师）/ DA（数据库管理员）/ SA（安全架构师）
- **关联技能**：`code-version-backup-management`（备份策略）、`operations-stage-execution`（运维监控）
- **最小章节结构**：

---

## 1. 文档元信息

| 属性 | 值 |
|------|-----|
| 模板名称 | 备份完整性校验规范 |
| 文档目的 | 为 {项目名} 项目制定标准化的备份完整性校验流程，确保所有备份数据在需要恢复时可用且完整 |
| 适用项目 | {项目名} |
| 项目版本 | v{版本号} |
| 创建日期 | {yyyy-MM-dd} |
| 最后更新日期 | {yyyy-MM-dd} |
| 文档状态 | 草案 / 评审中 / 已批准 |
| 文档负责人 | {姓名/角色} |

---

## 2. 校验算法选择

### 2.1 算法对比

| 算法 | 输出长度 | 计算速度 | 碰撞概率 | 安全性 | 适用场景 |
|------|:-------:|:-------:|:-------:|:-----:|---------|
| CRC32 | 32位 | 极快 | 较高（1/2^32） | 低 | 大文件快速校验、网络传输校验、非安全场景 |
| MD5 | 128位 | 快 | 中等（已发现碰撞） | 中 | 兼容性要求、历史系统、非安全关键场景 |
| SHA-1 | 160位 | 快 | 较低（已发现碰撞） | 中低 | 兼容性要求、非安全关键场景 |
| SHA-256 | 256位 | 中等 | 极低 | 高 | 安全关键场景、合规要求、推荐默认选项 |

### 2.2 选择决策矩阵

| 校验场景 | 推荐算法 | 备选算法 | 选择理由 |
|---------|---------|---------|---------|
| 备份文件完整性 | SHA-256 | SHA-1 | 安全性优先，防止篡改和碰撞 |
| 快速传输校验 | CRC32 | MD5 | 速度优先，大文件传输中实时校验 |
| 数据库记录校验 | SHA-256 | MD5 | 数据一致性校验需要高安全性 |
| 配置文件校验 | SHA-256 | MD5 | 配置篡改检测需要高安全性 |
| 日志文件校验 | MD5 | CRC32 | 日志量大，性能和安全性平衡 |

### 2.3 项目校验算法配置

| 数据类型 | 校验算法 | 校验粒度 | 存储位置 | 说明 |
|---------|---------|---------|---------|------|
| 数据库备份 | SHA-256 | 文件级 + 表级 | 校验和数据库 | 每个备份文件生成 SHA-256 校验和 |
| 源代码 | SHA-256（Git 内置） | 文件级 | Git 对象存储 | Git 原生使用 SHA-1/SHA-256 |
| 配置文件 | SHA-256 | 文件级 | 校验和文件 | 配置文件变更即校验 |
| 用户文件 | MD5 | 文件级 | 元数据数据库 | 大文件兼顾性能 |
| 日志备份 | CRC32 | 文件级 | 校验和文件 | 大量日志文件快速校验 |

---

## 3. 校验频率策略

### 3.1 频率定义

| 校验类型 | 频率 | 触发方式 | 校验范围 | 资源消耗 | 适用数据 |
|---------|------|---------|---------|:-------:|---------|
| 实时校验 | 每次备份完成时 | 自动触发 | 仅本次备份 | 低 | 所有备份类型 |
| 每日增量校验 | 每日 | 定时任务 | 当日新增/变更备份 | 低-中 | 热备份数据 |
| 每周抽样校验 | 每周 | 定时任务 | 随机抽取 10% 备份 | 中 | 全部备份数据 |
| 每月全量校验 | 每月 | 定时任务 | 全部备份数据 | 高 | 全部备份数据 |
| 恢复前校验 | 每次恢复前 | 手动触发 | 待恢复的备份 | 低 | 特定备份 |

### 3.2 校验时间窗口

| 校验类型 | 执行时间 | 预计耗时 | 优先级 | 资源限制 |
|---------|---------|---------|:------:|---------|
| 实时校验 | 备份完成后立即 | < 5分钟 | 最高 | 不限 |
| 每日增量校验 | 每日 06:00 | 30分钟 - 1小时 | 高 | CPU < 30% |
| 每周抽样校验 | 每周 {日} 06:00 | 1-2小时 | 中 | CPU < 20% |
| 每月全量校验 | 每月 1 日 02:00 | 4-8小时 | 低 | CPU < 10%，低峰期执行 |

### 3.3 校验策略配置

| 数据类型 | 实时校验 | 每日校验 | 每周抽样 | 每月全量 | 恢复前校验 |
|---------|:-------:|:-------:|:-------:|:-------:|:--------:|
| 数据库备份 | Y | Y | Y | Y | Y |
| 源代码 | N（Git 内置） | N | Y | N | Y |
| 配置文件 | Y | N | Y | Y | Y |
| 用户文件 | Y | Y | Y | Y | Y |
| 日志备份 | Y | N | N | Y | Y |

---

## 4. 校验报告模板

### 4.1 报告格式

每次校验完成后生成校验报告，记录校验结果。

#### 4.1.1 单次校验报告

```markdown
# 备份校验报告

## 基本信息
- 校验编号：VC-{序号}
- 校验时间：{yyyy-MM-dd HH:mm:ss}
- 校验类型：{实时/每日/每周/每月}
- 执行人：{自动/手动执行者}
- 校验范围：{描述校验的数据范围}

## 校验结果汇总
- 总校验项：{数量}
- 通过：{数量}（{百分比}）
- 失败：{数量}（{百分比}）
- 警告：{数量}（{百分比}）
- 跳过：{数量}（{百分比}）
- 总体状态：{通过/失败/警告}
```

#### 4.1.2 校验明细表

| 序号 | 备份文件/对象 | 校验算法 | 预期校验和 | 实际校验和 | 文件大小 | 备份时间 | 校验结果 | 备注 |
|------|-------------|---------|----------|----------|:-------:|---------|:-------:|------|
| 1 | {文件路径} | SHA-256 | {hash} | {hash} | {大小} | {时间} | 通过 | - |
| 2 | {文件路径} | SHA-256 | {hash} | {hash} | {大小} | {时间} | 失败 | 校验和不匹配 |
| 3 | {文件路径} | MD5 | {hash} | {hash} | {大小} | {时间} | 警告 | 文件大小异常 |

### 4.2 结果分级处理

| 校验结果 | 定义 | 处理方式 | 响应时限 | 后续动作 |
|---------|------|---------|:-------:|---------|
| 通过 | 校验和完全匹配 | 记录结果，无需处理 | - | 归档校验报告 |
| 警告 | 校验通过但存在异常（大小异常、耗时过长等） | 记录并调查原因 | 24小时 | 确认是否需要重新备份 |
| 失败 | 校验和不匹配或文件不可访问 | 触发告警，启动失败处理流程 | 15分钟 | 按"校验失败处理流程"执行 |
| 跳过 | 文件被锁定或不可读 | 记录原因，下次补验 | - | 加入下次校验队列 |

---

## 5. 校验失败处理流程

### 5.1 处理流程

```
告警
 │
 ▼
定位（15分钟内）
 │ ├── 确认失败范围：单个文件 / 批量文件 / 整个备份集
 │ ├── 确认失败原因：存储故障 / 传输错误 / 篡改 / 算法问题
 │ └── 评估影响：是否有可用的替代备份
 │
 ▼
修复（1小时内）
 │ ├── 可重新校验：排除临时故障后重新执行校验
 │ ├── 可重新备份：从源数据重新生成备份
 │ ├── 使用替代备份：从其他备份副本或时间点恢复
 │ └── 不可修复：标记备份为不可用，启动灾难恢复流程
 │
 ▼
重验（修复完成后）
 │ ├── 对修复后的备份重新执行完整性校验
 │ ├── 如校验通过，关闭告警并记录
 │ └── 如校验仍失败，升级处理
 │
 ▼
复盘（72小时内）
 │ ├── 分析根本原因
 │ ├── 评估是否需要调整校验策略或备份策略
 │ ├── 更新校验规范或备份配置
 │ └── 记录改进措施
```

### 5.2 失败处理记录表

| 事件编号 | 发现时间 | 失败备份 | 失败类型 | 影响评估 | 处理方式 | 修复时间 | 重验结果 | 关闭时间 | 根本原因 |
|---------|---------|---------|---------|:-------:|---------|---------|:-------:|---------|---------|
| VF-001 | {时间} | {备份路径} | {类型} | {高/中/低} | {方式} | {时间} | {通过/失败} | {时间} | {原因} |

### 5.3 升级路径

| 升级级别 | 触发条件 | 升级对象 | 时限 |
|---------|---------|---------|:----:|
| Level 1 | 单个备份校验失败 | 数据负责人 | 15分钟 |
| Level 2 | 多个备份校验失败或重验仍失败 | 技术负责人 | 1小时 |
| Level 3 | 关键备份不可恢复（无替代备份） | 总指挥 + 数据负责人 | 立即 |

---

## 6. 自动化校验脚本模板

以下提供 PowerShell 和 Bash 双版本校验脚本模板，项目可根据实际环境调整使用。

### 6.1 PowerShell 版本

```powershell
<#
.SYNOPSIS
    DevFlow 备份完整性校验脚本 (PowerShell)
.DESCRIPTION
    对指定目录下的备份文件执行完整性校验，生成校验报告。
    支持多算法选择、增量校验和报告输出。
.NOTES
    文件名: DevFlow-BackupVerify.ps1
    用法: .\DevFlow-BackupVerify.ps1 -BackupPath "D:\backup" -Algorithm SHA256 -ReportPath "D:\reports"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupPath,

    [Parameter(Mandatory=$false)]
    [ValidateSet("SHA256", "MD5", "CRC32")]
    [string]$Algorithm = "SHA256",

    [Parameter(Mandatory=$false)]
    [string]$ReportPath = ".\verify-report",

    [Parameter(Mandatory=$false)]
    [switch]$Incremental,

    [Parameter(Mandatory=$false)]
    [string]$ChecksumFile = "checksums.json"
)

# 校验结果统计
$script:TotalCount = 0
$script:PassCount = 0
$script:FailCount = 0
$script:WarnCount = 0

function Get-FileChecksum {
    param(
        [string]$FilePath,
        [string]$Algorithm
    )

    switch ($Algorithm) {
        "SHA256" { return (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash }
        "MD5"    { return (Get-FileHash -Path $FilePath -Algorithm MD5).Hash }
        default  { throw "不支持的算法: $Algorithm" }
    }
}

function Verify-BackupFile {
    param(
        [string]$FilePath,
        [string]$Algorithm,
        [hashtable]$KnownChecksums
    )

    $script:TotalCount++

    $result = @{
        File     = $FilePath
        Size     = (Get-Item $FilePath).Length
        Checksum = (Get-FileChecksum -FilePath $FilePath -Algorithm $Algorithm)
        Status   = "PASS"
        Message  = ""
    }

    if ($KnownChecksums.ContainsKey($FilePath)) {
        $expected = $KnownChecksums[$FilePath]
        if ($result.Checksum -ne $expected) {
            $result.Status = "FAIL"
            $result.Message = "校验和不匹配: 预期=$expected, 实际=$($result.Checksum)"
            $script:FailCount++
        } else {
            $script:PassCount++
        }
    } else {
        $result.Status = "WARN"
        $result.Message = "无历史校验和记录（首次校验）"
        $script:WarnCount++
    }

    return $result
}

# 主逻辑
Write-Host "[DevFlow] 开始备份校验: 路径=$BackupPath, 算法=$Algorithm"
$startTime = Get-Date

$backupFiles = Get-ChildItem -Path $BackupPath -Recurse -File
$results = @()

foreach ($file in $backupFiles) {
    $result = Verify-BackupFile -FilePath $file.FullName -Algorithm $Algorithm
    $results += $result
}

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

# 输出报告
$report = @{
    Timestamp   = $startTime.ToString("yyyy-MM-dd HH:mm:ss")
    Algorithm   = $Algorithm
    TotalCount  = $script:TotalCount
    PassCount   = $script:PassCount
    FailCount   = $script:FailCount
    WarnCount   = $script:WarnCount
    DurationSec = $duration
    Results     = $results
}

$report | ConvertTo-Json -Depth 3 | Out-File -FilePath "$ReportPath\verify-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"

Write-Host "[DevFlow] 校验完成: 总计=$($script:TotalCount), 通过=$($script:PassCount), 失败=$($script:FailCount), 警告=$($script:WarnCount), 耗时=$([math]::Round($duration, 1))秒"

if ($script:FailCount -gt 0) {
    Write-Host "[DevFlow] WARNING: 存在校验失败的备份文件，请检查报告！" -ForegroundColor Red
    exit 1
}
exit 0
```

### 6.2 Bash 版本

```bash
#!/bin/bash
# ============================================================================
# DevFlow 备份完整性校验脚本 (Bash)
# 文件名: devflow-backup-verify.sh
# 用法: ./devflow-backup-verify.sh --path /backup --algo sha256 --report /reports
# ============================================================================

set -euo pipefail

# 默认参数
BACKUP_PATH=""
ALGORITHM="sha256"
REPORT_PATH="./verify-report"
CHECKSUM_FILE="checksums.db"

# 统计变量
TOTAL_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --path)     BACKUP_PATH="$2"; shift 2 ;;
        --algo)     ALGORITHM="$2"; shift 2 ;;
        --report)   REPORT_PATH="$2"; shift 2 ;;
        --checksum) CHECKSUM_FILE="$2"; shift 2 ;;
        *) echo "未知参数: $1"; exit 1 ;;
    esac
done

if [[ -z "$BACKUP_PATH" ]]; then
    echo "错误: 必须指定 --path 参数"
    exit 1
fi

echo "[DevFlow] 开始备份校验: 路径=$BACKUP_PATH, 算法=$ALGORITHM"
START_TIME=$(date +%s)

# 校验函数
verify_file() {
    local file="$1"
    TOTAL_COUNT=$((TOTAL_COUNT + 1))

    local checksum=""
    case "$ALGORITHM" in
        sha256) checksum=$(sha256sum "$file" | awk '{print $1}') ;;
        md5)    checksum=$(md5sum "$file" | awk '{print $1}') ;;
        *)      echo "不支持的算法: $ALGORITHM"; exit 1 ;;
    esac

    local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")
    local status="PASS"
    local message=""

    # 查找已知校验和
    local expected=""
    if [[ -f "$CHECKSUM_FILE" ]]; then
        expected=$(grep "$file" "$CHECKSUM_FILE" 2>/dev/null | awk '{print $2}' || true)
    fi

    if [[ -n "$expected" ]]; then
        if [[ "$checksum" == "$expected" ]]; then
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            status="FAIL"
            message="校验和不匹配: 预期=$expected, 实际=$checksum"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        status="WARN"
        message="无历史校验和记录（首次校验）"
        WARN_COUNT=$((WARN_COUNT + 1))
    fi

    echo "$file|$size|$checksum|$status|$message" >> "$REPORT_PATH/details.txt"

    if [[ "$status" == "FAIL" ]]; then
        echo "[FAIL] $file: $message" >&2
    fi
}

# 主逻辑
mkdir -p "$REPORT_PATH"
echo "" > "$REPORT_PATH/details.txt"

while IFS= read -r -d '' file; do
    verify_file "$file"
done < <(find "$BACKUP_PATH" -type f -print0)

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# 生成报告摘要
cat > "$REPORT_PATH/summary.txt" << EOF
校验时间: $(date -d "@$START_TIME" "+%Y-%m-%d %H:%M:%S")
校验算法: $ALGORITHM
备份路径: $BACKUP_PATH
总计: $TOTAL_COUNT
通过: $PASS_COUNT
失败: $FAIL_COUNT
警告: $WARN_COUNT
耗时: ${DURATION}秒
EOF

echo "[DevFlow] 校验完成: 总计=$TOTAL_COUNT, 通过=$PASS_COUNT, 失败=$FAIL_COUNT, 警告=$WARN_COUNT, 耗时=${DURATION}秒"

if [[ $FAIL_COUNT -gt 0 ]]; then
    echo "[DevFlow] WARNING: 存在校验失败的备份文件，请检查报告！" >&2
    exit 1
fi

exit 0
```

---

## 7. 校验数据记录和趋势分析

### 7.1 数据记录

所有校验结果记录到中央校验数据库，用于趋势分析和审计。

| 记录字段 | 类型 | 说明 |
|---------|------|------|
| 校验编号 | VC-{序号} | 唯一标识 |
| 校验时间 | datetime | 校验执行时间 |
| 校验类型 | enum | 实时/每日/每周/每月 |
| 备份文件路径 | string | 被校验的备份文件 |
| 校验算法 | enum | SHA-256/MD5/CRC32 |
| 校验和值 | string | 计算得到的校验和 |
| 文件大小 | bigint | 备份文件大小（字节） |
| 校验结果 | enum | 通过/失败/警告/跳过 |
| 校验耗时 | int | 校验执行耗时（秒） |
| 备份时间 | datetime | 备份创建时间 |

### 7.2 趋势分析指标

| 分析指标 | 计算方式 | 用途 | 告警条件 |
|---------|---------|------|---------|
| 校验通过率 | 通过数 / 总数 * 100% | 评估备份整体健康度 | < 99% |
| 校验失败趋势 | 按周/月统计失败次数变化 | 发现系统性问题 | 连续2周上升 |
| 平均校验耗时 | 按数据类型统计平均耗时 | 评估校验效率 | 耗时增长 > 50% |
| 备份增长率 | 按月统计备份总量变化 | 规划存储容量 | 增长超预期 |
| 校验覆盖度 | 已校验备份 / 总备份数 * 100% | 确保所有备份都被校验 | < 95% |

### 7.3 月度趋势报告

每月生成校验趋势报告，包含以下内容：

| 报告章节 | 内容 |
|---------|------|
| 本月概览 | 总校验次数、通过率、失败次数、平均耗时 |
| 与上月对比 | 通过率变化、失败次数变化、耗时变化 |
| 失败原因分析 | 按失败原因分类统计 |
| 存储趋势 | 备份总量变化、各类型占比 |
| 改进建议 | 基于趋势分析的改进建议 |
| 下月计划 | 下月校验重点和调整 |

### 7.4 监控面板建议

在运维监控平台中创建校验专用面板，实时展示：

- 校验通过率趋势（折线图，最近 30 天）
- 校验失败数量分布（柱状图，按数据类型）
- 备份存储空间趋势（面积图，最近 90 天）
- 最近校验结果列表（表格，最新 20 条）

---

## 8. 附录

### 8.1 关联文档

| 文档 | 路径 | 关联关系 |
|------|------|---------|
| 备份策略配置指南 | `templates/DR-备份策略配置指南.md` | 定义备份策略，本规范定义备份的校验标准 |
| 灾难恢复预案 | `templates/DR-灾难恢复预案.md` | 恢复前需确认备份完整性 |
| 数据恢复演练流程 | `templates/DR-数据恢复演练流程.md` | 演练前需确认备份完整性 |
| 多地域备份方案 | `templates/DR-多地域备份方案.md` | 跨地域数据一致性校验 |
| 代码版本与备份管理 | `skills/L3/code-version-backup-management.md` | Git 对象的完整性校验机制 |
