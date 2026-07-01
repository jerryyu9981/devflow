# DevFlow 备份解决方案

## 整合策略、配置、操作三层能力的完整备份体系

> **版本**: v1.0.0 | **日期**: 2026-06-29 | **适用范围**: DevFlow 规范下的所有软件项目

---

## 一、备份体系总览

### 1.1 三层架构

DevFlow 的备份体系由策略层、配置层和操作层三层构成，各层职责清晰，互不重叠：

```
┌─────────────────────────────────────────────────────────────────┐
│                       策 略 层                                  │
│  code-version-backup-management（L3 技能）                       │
│  定义：做什么、为什么、什么频率、留多久                             │
│  • 备份类型：git mirror / git bundle / git archive / DB dump    │
│  • 留存策略：日常永久 / 周快照4周 / 发布归档永久 / DB 90天        │
│  • 不备份内容：node_modules/ vendor/ dist/ build/ target/ .git  │
│  • 上传技能 SKILL.md 文件中，运行时按需加载                       │
├─────────────────────────────────────────────────────────────────┤
│                       配 置 层                                  │
│  .devflow/config.json                                           │
│  定义：备份到哪里、用什么地址、多环境差异                           │
│  • remote.backup：主备份远程地址                                  │
│  • backup.environments：多环境分离配置                            │
│  • backup.schedule：定时备份策略                                  │
│  • 项目根目录下的 JSON 文件，DevFlow 所有技能共享读取              │
├─────────────────────────────────────────────────────────────────┤
│                       操 作 层                                  │
│  备份操作规范（docs/ 文档）                                       │
│  定义：怎么做、用什么命令、如何验证                                 │
│  • SSH Key 生成与配置（完整命令）                                 │
│  • 本地备份执行流程（git mirror / bundle / archive / robocopy）   │
│  • 数据库备份（MySQL / PostgreSQL / MongoDB 完整命令）            │
│  • 备份验证（commit SHA 比对 / checksum / bundle verify）         │
│  • 恢复测试（每月 / 每季度 / 每版本）                             │
│  • Pipeline Secrets 配置步骤                                     │
│  • 故障排查（7 种常见故障 + 诊断命令）                             │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 三层之间的关系

```
策略层（做什么）
    │ 告诉配置层需要哪些远程地址和留存策略
    ▼
配置层（存哪里）
    │ 存储地址供操作层读取
    ▼
操作层（怎么做）
    │ 执行操作后通过验证反馈回策略层
    ▼
反馈：备份成功/失败 → 日志记录 → 恢复测试报告
```

### 1.3 涉及文件清单

| 文件 | 层级 | 职责 |
|------|:----:|------|
| `skills/L3/code-version-backup-management.md` | 策略层 | 版本控制、备份策略、分支管理 |
| `.devflow/config.json` | 配置层 | 远程地址、调度策略、多环境配置 |
| `docs/备份操作规范.md` | 操作层 | 命令执行、凭据管理、验证恢复 |
| `skills/L3/cicd-pipeline-management.md` | 框架层 | CI/CD backup-mirror job |
| `skills/L2/operations-stage-execution.md` | 主控层 | 运维矩阵、备份验证门禁 |
| `.devflow/hooks/post-push` | 执行层 | 自动备份触发 |

---

## 二、策略层（code-version-backup-management）

### 2.1 备份类型

| 类型 | 方式 | 频率 | 留存 | 适用场景 |
|------|------|------|------|---------|
| **日常备份** | `git push --mirror` 远程备份仓库 | 每次推送后自动 | 永久（增量对象存储）| 代码版本主备份 |
| **每周快照** | `git bundle create` 创建 bundle 文件 | 每周 | 4 周 | 离线归档、网络不可用时回滚 |
| **发布归档** | `git archive` 打包源码 | 每版本 | 永久 | 合规审计、里程碑版本 |
| **数据库备份** | 数据库原生 dump 工具 | 每日 | 90 天 | 数据安全 |

### 2.2 不备份的内容

```
node_modules/  vendor/  dist/  build/  target/  logs/
*.tmp  .DS_Store  __pycache__/  .venv/  .env.local
```

### 2.3 分支策略（可配置）

`.devflow/config.json` 中的 `branchStrategy` 字段决定备份范围：

| 模式 | 备份的分支 | 推荐场景 |
|------|-----------|---------|
| `trunk-based` | 仅 `main` | 小型项目 ≤ 3 人 |
| `github-flow` | `main` + `feature/*` | 标准团队 3-10 人 |
| `git-flow` | `main` + `develop` + `release/*` + `hotfix/*` + `feature/*` | 多版本并行 ≥ 5 人 |

### 2.4 版本号与标签

```
v{MAJOR}.{MINOR}.{PATCH}
  |     |    +-- Bug 修复 (1.0.0 → 1.0.1)
  |     +------- 新功能 (1.0 → 1.1)
  +------------- 破坏性变更 (1.0 → 2.0)
```

标签格式：`v{major}.{minor}.{patch}[-beta|-alpha]`

---

## 三、配置层（.devflow/config.json）

### 3.1 基础配置模板

```json
{
  "project": "{项目名}",
  "devflowVersion": "2.3.1",
  "branchStrategy": "git-flow",
  "remote": {
    "origin": "{协议}://{托管平台}/{组织}/{项目名}.git",
    "backup": "{协议}://{托管平台}/{组织}/{项目名}-backup.git"
  },
  "backup": {
    "type": "git-mirror",
    "environments": {
      "dev": {
        "backup": "{协议}://{托管平台}/{组织}/{项目名}-dev-backup.git"
      },
      "test": {
        "backup": "{协议}://{托管平台}/{组织}/{项目名}-test-backup.git"
      },
      "pro": {
        "backup": "{协议}://{托管平台}/{组织}/{项目名}-pro-backup.git",
        "disaster": "{协议}://{备份服务器}/{组织}/{项目名}-disaster-backup.git"
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

### 3.2 远程仓库命名规则

```
{协议}://{托管平台}/{组织}/{项目名}-{环境}-backup.git
```

**环境区分**：

| 用途 | 示例 |
|------|------|
| 开发备份 | `git@github.com:myorg/myapp-dev-backup.git` |
| 测试备份 | `git@github.com:myorg/myapp-test-backup.git` |
| 生产备份 | `git@github.com:myorg/myapp-pro-backup.git` |
| 容灾备份 | `git@backup-server:myorg/myapp-disaster-backup.git` |

### 3.3 多仓库策略选择

| 类型 | 说明 | 适用场景 |
|------|------|---------|
| **单仓库** | 所有环境共用同一备份仓库，分支区分 | 小型项目（≤ 3 人） |
| **环境级** | 各环境独立备份仓库 | 标准推荐（≥ 5 人） |
| **容灾级** | 主仓库 + 异地容灾仓 | P0 项目强制 |

---

## 四、操作层（备份操作规范）

### 4.1 认证凭据管理

#### 4.1.1 SSH Key 生成

```bash
# 生成专用备份 SSH Key（ed25519 算法，更安全高效）
ssh-keygen -t ed25519 -C "backup-{项目名}-{环境}" -f ~/.ssh/id_backup_{项目名}_{环境}

# 添加到 SSH Agent
ssh-add ~/.ssh/id_backup_{项目名}_{环境}

# 查看公钥内容（添加到备份仓库的 Deploy Key）
cat ~/.ssh/id_backup_{项目名}_{环境}.pub

# 配置 SSH config（可选，方便多 key 管理）
cat >> ~/.ssh/config << 'EOF'
Host backup-github
  HostName github.com
  IdentityFile ~/.ssh/id_backup_{项目名}_{环境}
  IdentitiesOnly yes
EOF
```

#### 4.1.2 在托管平台添加 Deploy Key

**GitHub**：备份仓库 → Settings → Deploy Keys → Add deploy key → 标题 `backup-{项目名}-{环境}` → 粘贴公钥 → 勾选 `Allow write access`

**GitLab**：备份仓库 → Settings → Repository → Deploy Keys → Expand → 标题 `backup-{项目名}-{环境}` → 粘贴公钥 → 勾选 `Write access allowed`

#### 4.1.3 密钥轮换

| 项目 | 要求 |
|------|------|
| SSH Key 轮换周期 | **每 90 天**（或员工离职即时轮换） |
| CI/CD Token 轮换周期 | **每 90 天** |
| 轮换操作流程 | 生成新 Key → 更新 Deploy Key → 更新本地配置 → 验证推送 → 删除旧 Key |
| 告警规则 | 密钥到期前 7 天自动发出告警 |

轮换命令：

```bash
# 1. 生成新 Key
ssh-keygen -t ed25519 -C "backup-{项目}-{环境}-$(date +%Y%m)" -f ~/.ssh/id_backup_{项目}_{环境}_new

# 2. 手动更新托管平台上的 Deploy Key

# 3. 测试新 Key
ssh -T git@github.com -i ~/.ssh/id_backup_{项目}_{环境}_new

# 4. 替换旧 Key
mv ~/.ssh/id_backup_{项目}_{环境}_new ~/.ssh/id_backup_{项目}_{环境}
```

### 4.2 Git 镜像备份

#### 4.2.1 自动备份（post-push Hook）

安装到项目 `.git/hooks/post-push`：

```bash
#!/bin/bash
# DevFlow 自动备份 Hook
# 安装方式：
#   cp .devflow/hooks/post-push .git/hooks/post-push
#   chmod +x .git/hooks/post-push

REMOTE_NAME="${1:-backup}"

if git remote | grep -q "$REMOTE_NAME"; then
    echo "[DevFlow Backup] $(date '+%Y-%m-%d %H:%M:%S') 开始备份到 $REMOTE_NAME ..."
    git push --mirror "$REMOTE_NAME" 2>&1
    git push --tags "$REMOTE_NAME" 2>&1

    if [ $? -eq 0 ]; then
        echo "[DevFlow Backup] 备份完成 ✓"
        echo "$(date '+%Y-%m-%d %H:%M:%S') 备份成功" >> .devflow/logs/backup.log
    else
        echo "[DevFlow Backup] 备份失败 ✗"
        echo "$(date '+%Y-%m-%d %H:%M:%S') 备份失败" >> .devflow/logs/backup-error.log
    fi
else
    echo "[DevFlow Backup] 未找到远程仓库 '$REMOTE_NAME'，跳过备份"
fi
```

#### 4.2.2 Hook 安装验证

```bash
# 检查 hook 是否安装
ls -la .git/hooks/post-push

# 检查 hook 是否有执行权限
test -x .git/hooks/post-push && echo "可执行" || echo "缺少执行权限"

# 检查备份远程仓库是否已配置
git remote -v | grep backup

# 手动触发测试
bash .git/hooks/post-push backup
```

#### 4.2.3 手动备份

```bash
# 手动触发镜像备份
git push --mirror backup
git push --tags backup

# 或指定备份仓库 URL
git push --mirror git@github.com:myorg/myapp-dev-backup.git
```

### 4.3 每周快照（git bundle）

```bash
# 创建本周 bundle 文件（PowerShell）
$backupDir = "{project_root}/.devflow/backup/weekly"
$date = Get-Date -Format "yyyy-MM-dd"
$bundleFile = "$backupDir/{项目名}-$date.bundle"

# 首次创建 bundle（全量）
git bundle create $bundleFile --all

# 增量更新 bundle（仅上周以来新提交）
git bundle create $bundleFile --all --since="7 days ago"
```

### 4.4 发布归档（git archive）

```bash
# 在发布 tag 创建时归档源码（PowerShell）
$tag = "v1.0.0"
$archiveDir = "{project_root}/.devflow/backup/release/$tag"

New-Item -ItemType Directory -Force -Path $archiveDir

# 创建源码归档（不含 .git 目录）
git archive --format=zip --output="$archiveDir/{项目名}-$tag.zip" HEAD

# 记录 checksum
(Get-FileHash "$archiveDir/{项目名}-$tag.zip" -Algorithm SHA256).Hash |
  Out-File "$archiveDir/{项目名}-$tag.zip.sha256"
```

### 4.5 数据库备份

#### MySQL / MariaDB

```bash
# 全量备份 + 压缩
mysqldump -h {host} -u {user} -p \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  --max-allowed-packet=1G \
  {db_name} | 7z a -si"{db_name}-$(date +%Y%m%d).sql" \
  "{project_root}/.devflow/backup/daily/$(date +%Y%m%d)/{db_name}.sql.7z"
```

#### PostgreSQL

```bash
# 全量备份
pg_dump -h {host} -U {user} -Fc {db_name} | \
  7z a -si"{db_name}-$(Get-Date -Format yyyyMMdd).dump" \
  "{project_root}/.devflow/backup/daily/$(Get-Date -Format yyyyMMdd)/{db_name}.dump.7z"
```

#### MongoDB

```powershell
# 全量备份
$date = Get-Date -Format yyyyMMdd
$backupDir = "{project_root}/.devflow/backup/daily/$date"
New-Item -ItemType Directory -Force -Path $backupDir

mongodump --host {host} --port 27017 \
  --username {user} --password {password} \
  --db {db_name} \
  --out "$backupDir/mongo-{db_name}"

# 压缩备份
7z a "$backupDir/mongo-{db_name}.7z" "$backupDir/mongo-{db_name}\"
Remove-Item -Recurse -Force "$backupDir/mongo-{db_name}\"
```

### 4.6 文件级本地备份

#### 增量同步（robocopy — 适用于日常备份）

```powershell
$src = "{project_root}"
$dst = "{project_root}/.devflow/backup/daily/$(Get-Date -Format yyyyMMdd)"
$log = "{project_root}/.devflow/logs/backup-$(Get-Date -Format yyyyMMdd).log"

robocopy $src $dst /MIR /R:3 /W:10 `
  /XD node_modules vendor dist build target .git logs `
  /XF "*.tmp" ".DS_Store" "*.log" `
  /LOG+:$log /NP /NDL

if ($LASTEXITCODE -ge 8) {
    Write-Host "备份失败，请检查日志: $log" -ForegroundColor Red
} else {
    Write-Host "备份完成" -ForegroundColor Green
}
```

#### 全量压缩（7z — 适用于周/月归档）

```powershell
$date = Get-Date -Format yyyyMMdd
$src = "{project_root}"
$dst = "{project_root}/.devflow/backup/weekly/{项目名}-$date.7z"
$log = "{project_root}/.devflow/logs/archive-$(Get-Date -Format yyyyMMdd).log"

7z a -t7z -mx=5 -mhe=on -p{加密密码} $dst $src `
  -xr!node_modules -xr!vendor -xr!dist -xr!build -xr!target -xr!.git -xr!logs `
  -bb3 > $log
```

### 4.7 备份留存与清理

```powershell
# 清理 7 天前的日常备份
$retentionDays = 7
$backupRoot = "{project_root}/.devflow/backup/daily"
Get-ChildItem $backupRoot -Directory |
  Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-$retentionDays) } |
  Remove-Item -Recurse -Force

# 清理 4 周前的每周备份
$retentionWeeks = 4
$backupRoot = "{project_root}/.devflow/backup/weekly"
Get-ChildItem $backupRoot -Directory |
  Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-$retentionWeeks * 7) } |
  Remove-Item -Recurse -Force
```

### 4.8 备份记录日志

每次备份后，追加日志到 `{project_root}/.devflow/logs/backup-history.csv`：

```csv
日期,时间,备份类型,来源路径,目标路径,大小,状态,耗时(秒)
2026-06-29,02:00:00,git-mirror,{project_root},{backup_url},1.2GB,成功,45
2026-06-29,02:15:00,mysqldump,localhost:3306/myapp,{project_root}/.devflow/backup/daily/20260629/,450MB,成功,120
```

---

## 五、备份验证与恢复测试

### 5.1 自动验证（每次备份后执行）

| 备份类型 | 验证方法 | 验证命令 |
|---------|---------|---------|
| Git mirror | 比较 commit SHA | `git ls-remote backup HEAD` vs `git rev-parse HEAD` |
| Git bundle | 验证 bundle 完整性 | `git bundle verify {bundle}.bundle` |
| 归档文件 | SHA256 checksum 比对 | `(Get-FileHash {file}.zip).Hash -eq (Get-Content {file}.sha256)` |
| 数据库 dump | 测试恢复（单表） | `mysql test_verify < {dump}.sql` |

#### Git mirror 验证

```powershell
$originSha = git rev-parse HEAD
$backupSha = git ls-remote backup HEAD | ForEach-Object { $_ -split '\s+' | Select-Object -First 1 }

if ($originSha -eq $backupSha) {
    Write-Host "✅ 备份验证通过：HEAD commit SHA 一致" -ForegroundColor Green
    Write-Host "   Commit: $originSha" -ForegroundColor Gray
} else {
    Write-Host "❌ 备份验证失败：commit SHA 不匹配" -ForegroundColor Red
    Write-Host "   本地: $originSha" -ForegroundColor Yellow
    Write-Host "   备份: $backupSha" -ForegroundColor Yellow
}
```

#### 归档文件验证

```powershell
$archive = "{project_root}/.devflow/backup/release/v1.0.0/{项目名}-v1.0.0.zip"
$currentHash = (Get-FileHash $archive -Algorithm SHA256).Hash
$storedHash = Get-Content "$archive.sha256"

if ($currentHash -eq $storedHash) {
    Write-Host "✅ 归档完整性验证通过" -ForegroundColor Green
} else {
    Write-Host "❌ 归档完整性验证失败！文件可能已损坏" -ForegroundColor Red
}
```

### 5.2 定期恢复测试

| 测试频率 | 测试内容 | 范围 | 通过标准 |
|---------|---------|------|---------|
| **每月** | Git 仓库恢复测试 | 随机抽取一个 tag，完整 clone 备份仓库 | clone 成功，所有文件可访问 |
| **每季度** | 数据库恢复测试 | 从备份中恢复到一个测试实例 | 数据完整，业务查询可正常执行 |
| **每版本** | 发布归档恢复测试 | 从 release archive 恢复并构建 | 构建成功，冒烟测试通过 |

#### 每月恢复测试脚本

```powershell
$testDir = "{project_root}/.devflow/backup/restore-test/$(Get-Date -Format yyyyMMdd)"
$backupRepo = "{备份仓库 URL}"

New-Item -ItemType Directory -Force -Path $testDir
git clone $backupRepo $testDir 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 恢复测试失败" -ForegroundColor Red
    exit 1
}

$branches = git branch -r
$tags = git tag
Write-Host "远程分支数: $($branches.Count)" -ForegroundColor Gray
Write-Host "Tag 数: $($tags.Count)" -ForegroundColor Gray

if ($tags.Count -eq 0) {
    Write-Host "⚠️ 警告：备份仓库中没有任何 tag" -ForegroundColor Yellow
}

$latestTag = $tags | Select-Object -Last 1
git checkout $latestTag 2>&1
Write-Host "最新 tag: $latestTag" -ForegroundColor Gray

Remove-Item -Recurse -Force $testDir
Write-Host "=== 恢复测试通过 ✅ ===" -ForegroundColor Green
```

### 5.3 恢复测试记录

```csv
日期,测试类型,备份来源,验证结果,耗时,备注
2026-06-29,Git恢复测试,{backup_url},通过,30s,最新 tag v1.0.0
2026-06-29,数据库恢复测试,{project_root}/.devflow/backup/daily/20260629/mydb.sql.7z,通过,120s,数据行数一致
```

---

## 六、CI/CD 备份集成

### 6.1 GitHub Actions Secrets 配置

在 GitHub 仓库 → Settings → Secrets and variables → Actions → New repository secret：

| Secret 名称 | 值 | 示例 |
|---|---|---|
| `BACKUP_REMOTE_URL` | 备份远程仓库地址 | `git@github.com:org/myapp-dev-backup.git` |
| `BACKUP_SSH_KEY` | 私钥内容 | `-----BEGIN OPENSSH...` |
| `BACKUP_KNOWN_HOSTS` | ssh-keyscan 结果 | `github.com ssh-ed25519 AAAAC3...` |

获取 known_hosts：
```bash
ssh-keyscan -t ed25519 github.com
```

完整 YAML：
```yaml
backup-mirror:
  if: startsWith(github.ref, 'refs/tags/')
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
    - name: Push mirror to backup remote
      env:
        BACKUP_REMOTE_URL: ${{ secrets.BACKUP_REMOTE_URL }}
        BACKUP_SSH_KEY: ${{ secrets.BACKUP_SSH_KEY }}
        BACKUP_KNOWN_HOSTS: ${{ secrets.BACKUP_KNOWN_HOSTS }}
      run: |
        mkdir -p ~/.ssh
        echo "$BACKUP_SSH_KEY" > ~/.ssh/id_backup
        chmod 600 ~/.ssh/id_backup
        echo "$BACKUP_KNOWN_HOSTS" > ~/.ssh/known_hosts
        git remote add backup "$BACKUP_REMOTE_URL"
        git push --mirror backup
        git push --tags backup
```

### 6.2 GitLab CI Variables 配置

在 GitLab 项目 → Settings → CI/CD → Variables：

| Variable 名称 | 值 | 标记 |
|---|---|---|
| `BACKUP_REMOTE_URL` | 备份远程仓库地址 | Protected + Masked |
| `BACKUP_SSH_PRIVATE_KEY` | 私钥内容 | Protected + Masked |

完整 YAML：
```yaml
backup-mirror:
  stage: backup
  only: [tags]
  before_script:
    - apt-get update -qq && apt-get install -y -qq openssh-client
    - mkdir -p ~/.ssh
    - echo "$BACKUP_SSH_PRIVATE_KEY" > ~/.ssh/id_backup
    - chmod 600 ~/.ssh/id_backup
    - ssh-keyscan github.com >> ~/.ssh/known_hosts
  script:
    - git remote add backup "$BACKUP_REMOTE_URL"
    - git push --mirror backup
    - git push --tags backup
```

### 6.3 Secrets 命名约定

| 用途 | 命名规则 | 示例 |
|------|---------|------|
| 备份远程地址 | `BACKUP_REMOTE_URL_{ENV}` | `BACKUP_REMOTE_URL_DEV` |
| SSH 私钥 | `BACKUP_SSH_KEY_{ENV}` | `BACKUP_SSH_KEY_PRO` |
| 数据库备份凭据 | `DB_BACKUP_USER` / `DB_BACKUP_PASS` | — |
| 归档加密密码 | `ARCHIVE_ENCRYPT_PASS` | — |

> **安全约束**：所有 Pipeline 变量必须标记为 **Masked**（隐藏日志输出）和 **Protected**（仅保护分支可用）。

---

## 七、故障排查

### 7.1 常见备份故障

| 故障现象 | 常见原因 | 诊断命令 | 修复步骤 |
|---------|---------|---------|---------|
| `Permission denied (publickey)` | SSH Key 未添加到 Deploy Key | `ssh -T git@github.com -v` | 检查 Deploy Key 是否正确添加 |
| `Host key verification failed` | known_hosts 未配置 | `ssh-keyscan github.com` | 添加到 known_hosts |
| `repository not found` | 备份仓库地址错误 | `git ls-remote backup` | 检查远程地址 |
| `push declined` | Deploy Key 没有写权限 | 检查 Deploy Key 配置 | 重新勾选 Allow write access |
| `backup remote not found` | 本地未添加 remote | `git remote -v` | `git remote add backup {url}` |
| 备份文件损坏 | 磁盘空间不足或中断 | `7z t {file}.7z` | 重新执行备份 |
| 备份体积异常偏小 | 排除规则过宽 | 检查排除列表 | 调整排除规则 |

### 7.2 诊断命令汇总

```bash
# 检查 SSH 连接
ssh -T git@github.com
ssh -vT git@github.com      # 详细模式

# 检查所有远程仓库
git remote -v

# 检查备份远程仓库是否可达
git ls-remote backup HEAD

# 比较本地和备份的 commit SHA
echo "本地: $(git rev-parse HEAD)"
echo "备份: $(git ls-remote backup HEAD | awk '{print $1}')"

# 验证 bundle 文件
git bundle verify {project_root}/.devflow/backup/weekly/{项目名}-2026-06-29.bundle

# 验证 7z 文件
7z t "{project_root}/.devflow/backup/daily/20260629/mydb.sql.7z"
```

---

## 八、强制规则

DevFlow 备份体系强制执行以下 6 条规则：

| 规则 | 内容 | 违规后果 |
|:----:|------|---------|
| **规则 1** | 不得泄露密钥：所有凭据必须通过 Pipeline Secrets / 环境变量注入，禁止硬编码到代码或配置文件中 | 安全违规 |
| **规则 2** | 不得无验证备份：每次备份后必须执行自动验证（commit SHA 比对或 checksum 校验），未验证通过的备份视为无效 | 备份不可靠 |
| **规则 3** | 不得超期不轮换：SSH Key 和 CI/CD Token 超过 90 天未轮换视为违规，须在发现后 48 小时内完成轮换 | 安全违规 |
| **规则 4** | 不得无恢复测试：超过 1 个月无恢复测试记录的备份策略视为不可靠备份，须在 1 周内补测 | 备份不可靠 |
| **规则 5** | 必须记录备份日志：所有备份操作（成功/失败）必须记录到 `.devflow/logs/` 下的备份历史日志 | 运维审计缺失 |
| **规则 6** | 数据库备份必须加密：数据库备份文件在传输和存储过程中必须加密（7z 加密或 GPG 加密） | 数据安全违规 |

---

## 九、与 DevFlow 其他技能的协作关系

| 技能/配置 | 协作内容 | 引用方式 |
|-----------|---------|---------|
| `code-version-backup-management`（策略层） | 定义备份类型、留存、分支策略 | 本方案是策略层的操作实现 |
| `cicd-pipeline-management`（框架层） | backup-mirror job 的 Secrets 配置步骤 | 本方案第六章提供操作细节 |
| `operations-stage-execution`（主控层） | 备份验证作为上线验证的前置条件 | 运维矩阵中引用本方案第五章 |
| `.devflow/config.json`（配置层） | `remote.backup` + `backup.environments` 配置 | 本方案第三章提供配置模板 |
| `devflow-project-config`（配置管理） | 项目初始化时生成 backup 配置 | 读取本方案第三章集成 |
| `devflow-init`（初始化） | setup 脚本安装 post-push hook | 本方案 4.2.1 提供 hook 脚本 |

---

## 十、关键命令速查表

| 操作 | 命令 |
|------|------|
| 生成 SSH Key | `ssh-keygen -t ed25519 -C "backup-{项目}-{环境}" -f ~/.ssh/id_backup_{项目}_{环境}` |
| 查看公钥 | `cat ~/.ssh/id_backup_{项目}_{环境}.pub` |
| Git 镜像备份 | `git push --mirror backup && git push --tags backup` |
| 验证备份（SHA） | `git ls-remote backup HEAD` vs `git rev-parse HEAD` |
| 创建 bundle | `git bundle create {path}.bundle --all --since="7 days ago"` |
| 创建归档 | `git archive --format=zip --output={path}.zip HEAD` |
| MySQL 备份 | `mysqldump --single-transaction {db} \| 7z a -si{file}.sql.7z {path}` |
| PostgreSQL 备份 | `pg_dump -Fc {db} \| 7z a -si{file}.dump.7z {path}` |
| MongoDB 备份 | `mongodump --db {db} --out {path}` |
| 文件增量备份 | `robocopy {src} {dst} /MIR /XD node_modules vendor dist build target .git logs` |
| 文件全量压缩 | `7z a -t7z -mx=5 {dst}.7z {src} -xr!node_modules -xr!.git` |
| SSH 连接测试 | `ssh -T git@github.com` |
| known_hosts 获取 | `ssh-keyscan -t ed25519 github.com` |
| 备份清理（7天） | `Get-ChildItem {path} \| Where-Object CreationTime -lt (Get-Date).AddDays(-7) \| Remove-Item -Recurse` |

---

## 十一、执行检查清单

### 初始化阶段

- [ ] 在托管平台创建备份仓库（命名遵循 `{项目}-{环境}-backup` 规则）
- [ ] 生成备份专用 SSH Key 并添加到备份仓库的 Deploy Key
- [ ] 在 `.devflow/config.json` 中配置 `remote.backup` 和 `backup.environments`
- [ ] 添加 Git remote：`git remote add backup {backup_url}`
- [ ] 安装 post-push hook：`cp .devflow/hooks/post-push .git/hooks/post-push && chmod +x .git/hooks/post-push`
- [ ] 创建备份目录：`.devflow/backup/`、`.devflow/logs/`
- [ ] 在 CI/CD 平台配置 Pipeline Secrets

### 日常执行

- [ ] 每次 `git push` 后自动触发 backup mirror（post-push hook）
- [ ] 每周日 02:00 自动创建 git bundle 快照
- [ ] 每日自动执行数据库备份（如适用）
- [ ] 发布 tag 时自动创建发布归档
- [ ] 每次备份后自动执行验证

### 定期验证

- [ ] **每月**：Git 仓库恢复测试（clone 备份仓库 + 检查分支和 tag）
- [ ] **每季度**：数据库恢复测试
- [ ] **每版本**：发布归档恢复测试
- [ ] **每 90 天**：SSH Key 和 CI/CD Token 轮换

---

## 十二、回滚设计

> 本章节定义 DevFlow 备份体系下的完整回滚策略，与备份策略形成闭环。

### 12.1 回滚策略总览

DevFlow 的回滚体系按**回滚对象**分为四类，按**触发方式**分为自动和手动两层：

```
┌─────────────────────────────────────────────────────────────┐
│                    回 滚 策 略 分 类                          │
├─────────────┬─────────────┬─────────────┬───────────────────┤
│  代码回滚    │  数据回滚    │  配置回滚    │   服务/部署回滚    │
├─────────────┼─────────────┼─────────────┼───────────────────┤
│ git revert  │ DB 还原     │ 配置中心回滚 │  蓝绿切换          │
│ git reset   │ 迁移回退    │ 环境变量还原 │  金丝雀流量切回    │
│ 归档恢复     │ 缓存重建    │ K8s ConfigMap│ 滚动更新回退      │
├─────────────┴─────────────┴─────────────┴───────────────────┤
│                    触 发 方 式                               │
├─────────────────────────┬───────────────────────────────────┤
│  自动触发（CI/CD 监控）   │  手动触发（人工审批）              │
│  • 健康检查失败          │  • P0 故障人工确认                 │
│  • 错误率超阈值          │  • 业务方要求回滚                  │
│  • P99 延迟超基线        │  • 合规/安全原因                   │
│  • 核心功能冒烟失败       │  • 数据异常需紧急恢复              │
└─────────────────────────┴───────────────────────────────────┘
```

### 12.2 回滚触发条件

#### 12.2.1 自动触发条件（CI/CD 监控）

当以下任一指标在**生产环境发布后 15 分钟内**触发，系统自动发起回滚：

| 触发指标 | 阈值 | 检测窗口 | 自动动作 |
|---------|------|---------|---------|
| **健康检查失败** | `/health` 或 `/ready` 非 200 | 连续 3 次，间隔 10s | **自动回滚** |
| **错误率飙升** | 5xx 错误率 > 1%（或环比 +500%） | 5 分钟滑动窗口 | **自动回滚** |
| **P99 延迟超基线** | P99 > 基线 +50% | 5 分钟滑动窗口 | **告警 + 人工确认** |
| **核心功能冒烟失败** | 关键 API / 主流程失败 | 发布后 10 分钟内 | **自动回滚** |
| **资源异常** | CPU/Memory 持续 > 90% | 5 分钟 | 告警，不自动回滚 |
| **依赖服务故障** | 下游服务不可用 | 立即 | 告警，不自动回滚 |

> **自动回滚安全约束**：自动回滚仅适用于**蓝绿部署**和**金丝雀发布**场景，直接部署场景需人工确认（无法快速无损切回）。

#### 12.2.2 手动触发条件

以下场景由人工判断后触发回滚：

| 场景 | 审批级别 | 触发方式 |
|------|---------|---------|
| 发布后发现 P0 缺陷 | 发布负责人 + PM | CI/CD 手动触发回滚 job |
| 业务数据异常（脏数据） | 发布负责人 + DBA | 数据回滚流程 |
| 安全漏洞紧急修复回退 | 安全负责人 + 发布负责人 | 紧急回滚流程 |
| 合规/审计要求 | 管理员 | 标准回滚流程 |
| 性能退化（非自动触发范围） | 发布负责人 | 标准回滚流程 |

### 12.3 回滚审批流程

#### 12.3.1 审批级别矩阵

| 环境 | 代码回滚 | 数据回滚 | 配置回滚 | 服务回滚 |
|------|---------|---------|---------|---------|
| **Dev** | 开发者自决 | 开发者自决 | 开发者自决 | 开发者自决 |
| **Test** | 审查者审批 | 审查者审批 | 审查者审批 | 审查者审批 |
| **Pro** | **发布负责人 + PM 双签** | **发布负责人 + DBA + PM 三签** | **发布负责人 + 运维 双签** | **发布负责人审批** |

#### 12.3.2 标准审批流程（Pro 环境）

```
1. 发现异常 → 发布负责人评估影响
      ↓
2. 决策：回滚 / 热修复 / 观察
      ↓
3. 若决策回滚：
   a. 发布负责人在 CI/CD 平台触发 rollback job
   b. 系统自动生成回滚工单（含：原因、影响范围、回滚目标版本）
   c. 根据回滚类型，通知对应审批人（PM/DBA/运维）
   d. 审批人 5 分钟内响应（超时自动通过，P0 故障除外）
      ↓
4. 审批通过后，自动执行回滚
      ↓
5. 回滚完成后自动验证
      ↓
6. 发布负责人确认回滚结果，关闭工单
      ↓
7. 24 小时内输出发布复盘报告（含 RCA）
```

#### 12.3.3 紧急回滚流程（P0 故障，绕过审批）

```
1. 监控告警触发 P0（或人工上报 P0）
      ↓
2. 发布负责人一键触发 emergency-rollback
      ↓
3. 系统立即执行回滚（无需等待审批）
      ↓
4. 同步通知 PM + 运维 + 相关干系人
      ↓
5. 回滚完成后自动验证
      ↓
6. 2 小时内补录回滚原因和影响评估
      ↓
7. 24 小时内完成 RCA 报告
```

> **约束**：紧急回滚权限仅限**发布负责人**和**运维管理员**，且必须在 2 小时内补录审批材料。

### 12.4 按部署策略的回滚路径

#### 12.4.1 直接部署（Dev/Test）

| 步骤 | 操作 | 命令/方式 |
|------|------|----------|
| 1 | 停止当前服务 | `systemctl stop {service}` / `docker stop {container}` |
| 2 | 回退代码到上一版本 | `git checkout {previous-tag}` |
| 3 | 重新构建/拉取上一版本镜像 | `docker pull {image}:{previous-tag}` |
| 4 | 重启服务 | `systemctl start {service}` / `docker run ...` |
| 5 | 健康检查 | `curl /health` |
| 6 | 冒烟验证 | 核心 API 测试 |

**特点**：有停机时间，回滚慢（需重新构建/部署），仅适用于 Dev/Test。

#### 12.4.2 蓝绿部署（Pro 推荐）

```
当前状态：Blue 运行 v1.0.1，Green 空闲
           ↓
发布 v1.0.2 到 Green → Green 冒烟测试通过 → 流量切到 Green
           ↓
【回滚场景】：Green 出现问题
           ↓
立即操作：负载均衡器切换流量回 Blue（< 30 秒）
           ↓
结果：Blue 继续运行 v1.0.1，业务无感知
           ↓
后续：Green 保留用于问题排查，修复后重新发布
```

| 步骤 | 操作 | 耗时 |
|------|------|------|
| 1 | 监控触发或人工确认异常 | - |
| 2 | 负载均衡器切换流量到 Blue | < 30s |
| 3 | 自动验证 Blue 健康状态 | 1-2min |
| 4 | 核心功能冒烟测试 | 2-3min |
| 5 | 通知干系人回滚完成 | - |
| **总计** | | **< 5 分钟** |

#### 12.4.3 金丝雀发布（Pro）

```
阶段 1：10% 流量 → v1.0.2，90% 流量 → v1.0.1
    ↓ 监控 5-10 分钟，指标正常
阶段 2：50% 流量 → v1.0.2，50% 流量 → v1.0.1
    ↓ 监控 5-10 分钟，指标正常
阶段 3：100% 流量 → v1.0.2
    ↓ 【回滚场景】：阶段 1 或阶段 2 发现异常
阶段 X：立即将所有流量切回 v1.0.1（< 30 秒）
```

| 回滚时机 | 操作 | 影响 |
|---------|------|------|
| 阶段 1（10%） | 直接停止金丝雀实例，流量 100% 回到 v1.0.1 | 仅 10% 用户受影响 |
| 阶段 2（50%） | 逐步降低 v1.0.2 流量至 0%，切回 v1.0.1 | 50% 用户短暂受影响 |
| 阶段 3（100%） | 同蓝绿回滚：启动上一版本实例，切流量 | 全部用户短暂受影响 |

#### 12.4.4 滚动更新（K8s）

| 步骤 | 操作 | 命令 |
|------|------|------|
| 1 | 查看当前 Deployment 历史 | `kubectl rollout history deployment/{name}` |
| 2 | 回滚到上一版本 | `kubectl rollout undo deployment/{name}` |
| 3 | 监控回滚进度 | `kubectl rollout status deployment/{name}` |
| 4 | 验证 Pod 状态 | `kubectl get pods` |
| 5 | 健康检查和冒烟测试 | `curl /health` + API 测试 |

**特点**：K8s 自动管理 Pod 替换，零停机，回滚到上一版本一键完成。

### 12.5 数据回滚策略

#### 12.5.1 数据库回滚

| 场景 | 回滚方式 | 前提条件 |
|------|---------|---------|
| 迁移脚本出错 | 执行 `down` 迁移脚本 | 迁移工具（Flyway/Liquibase/Alembic）支持回退 |
| 数据被污染 | 从备份恢复 + 增量日志重放 | 发布前已做 DB 备份（`operations-stage-execution` 强制要求） |
| 误删数据 | 从每日 dump 恢复单表 | 有定期 dump 备份 |

#### 12.5.2 数据库回滚流程

```
1. 发布前自动备份数据库（CI/CD 部署 Stage 前置步骤）
      ↓
2. 发现数据异常
      ↓
3. 决策：执行 down 迁移 / 从备份恢复 / 热修复数据
      ↓
4. 若从备份恢复：
   a. 停止写入（进入维护模式或只读）
   b. 从备份恢复（mysql < backup.sql / pg_restore）
   c. 重放增量 binlog/wal（如有）
   d. 验证数据一致性
   e. 恢复写入
      ↓
5. 记录数据回滚操作到问题跟踪记录
```

#### 12.5.3 缓存与消息回滚

| 组件 | 回滚操作 |
|------|---------|
| Redis | 清除新版本的缓存 key 前缀，或全量 flush（谨慎） |
| 消息队列 | 暂停消费 → 回滚代码 → 恢复消费；或清空错误消息重发 |

### 12.6 回滚验证

#### 12.6.1 回滚后必须执行的验证

| 验证项 | 方法 | 通过标准 |
|--------|------|---------|
| 服务健康 | `curl /health` / `/ready` | 200 OK |
| 核心 API | 冒烟测试脚本 | 关键接口全部通过 |
| 错误率 | 监控面板 | 5xx 错误率 < 0.1% |
| 延迟 | 监控面板 | P99 恢复至基线范围 |
| 数据库连接 | 应用日志 | 无连接异常 |
| 关键业务流 | E2E 测试 | 主流程通过 |

#### 12.6.2 回滚失败处理

若回滚后验证仍不通过：

```
1. 立即升级告警至 P0
2. 启动灾备预案（如有）
3. 通知技术负责人 + 运维负责人
4. 保留现场（不随意重启/清理）
5. 2 小时内必须定位根因或切换到备用方案
```

### 12.7 CI/CD 自动回滚 Job 设计

#### 12.7.1 GitHub Actions 回滚 Job

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
        options:
          - dev
          - test
          - pro

jobs:
  rollback:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    steps:
      - name: Checkout target version
        uses: actions/checkout@v4
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
        run: |
          # 蓝绿部署：切换负载均衡器到 Blue（上一版本）
          ./scripts/switch-traffic.sh ${{ github.event.inputs.target_version }}

      - name: Deploy previous version (Direct)
        if: github.event.inputs.environment != 'pro'
        run: |
          # 直接部署：重新部署上一版本
          ./scripts/deploy.sh ${{ github.event.inputs.target_version }} ${{ github.event.inputs.environment }}

      - name: Health check
        run: |
          sleep 30
          curl -sf ${{ env.HEALTH_URL }} || exit 1

      - name: Smoke test
        run: ./scripts/smoke-test.sh ${{ github.event.inputs.environment }}

      - name: Notify stakeholders
        if: always()
        uses: slack/notify-action@v1
        with:
          message: |
            回滚完成
            环境: ${{ github.event.inputs.environment }}
            目标版本: ${{ github.event.inputs.target_version }}
            原因: ${{ github.event.inputs.reason }}
            执行人: ${{ github.actor }}
            结果: ${{ job.status }}
```

#### 12.7.2 金丝雀自动回滚 Job（监控触发）

```yaml
# 集成在部署流水线中的自动回滚
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

### 12.8 回滚记录与审计

#### 12.8.1 回滚历史记录

每次回滚必须记录到 `{项目名}-回滚历史.csv`：

```csv
时间,环境,从版本,到版本,回滚类型,触发方式,原因,执行人,审批人,验证结果,耗时
2026-07-01 14:32:00,pro,v1.2.0,v1.1.5,代码+服务,自动,健康检查失败3次,CI/CD,系统,P0紧急,成功,45s
2026-07-01 10:15:00,test,v1.1.5,v1.1.4,数据,手动,迁移脚本污染数据,张三,李四,审批通过,成功,3min
```

#### 12.8.2 回滚门禁（增强版）

| 规则 | 内容 | 违反后果 |
|------|------|---------|
| **规则 1** | 生产发布必须有回滚预案，无预案不得上线 | 阻断发布 |
| **规则 2** | 回滚操作必须在 5 分钟内记录到问题跟踪记录 | 审计缺失 |
| **规则 3** | P0 紧急回滚须在 2 小时内补录审批材料 | 流程违规 |
| **规则 4** | 回滚后必须在 15 分钟内完成验证，未验证通过视为回滚失败 | 回滚不可靠 |
| **规则 5** | 数据回滚前必须做二次备份（防止回滚操作本身造成数据丢失） | 数据安全风险 |
| **规则 6** | 24 小时内必须输出发布复盘报告（含 RCA） | 改进闭环缺失 |

### 12.9 与现有技能的衔接

| 技能 | 衔接内容 |
|------|---------|
| `code-version-backup-management` | 提供代码回滚命令（revert/checkout/reset）和版本基线 |
| `operations-stage-execution` | 回滚预案纳入部署运维矩阵，回滚演练作为 Step 5 必做项 |
| `cicd-pipeline-management` | 回滚 job 纳入流水线，金丝雀/蓝绿部署策略定义回滚路径 |
| `observability-standards` | 提供监控指标（错误率/P99/健康检查）作为自动回滚触发源 |

### 12.10 执行检查清单

#### 发布前（必须完成）

- [ ] 已制定回滚预案（含：回滚目标版本、回滚步骤、验证方式）
- [ ] 已配置 CI/CD rollback job
- [ ] 数据库已备份（如有数据变更）
- [ ] 蓝绿/Green 环境已就绪（Pro 环境）
- [ ] 监控告警规则已配置（自动回滚依赖）
- [ ] 回滚审批人已明确

#### 回滚时

- [ ] 已记录回滚原因到问题跟踪记录
- [ ] 已获取必要审批（或已触发紧急回滚）
- [ ] 数据回滚前已做二次备份
- [ ] 回滚后已完成健康检查和冒烟验证

#### 回滚后

- [ ] 已通知所有干系人
- [ ] 已更新回滚历史记录
- [ ] 24 小时内完成发布复盘报告（含 RCA）

---

*本方案整合了 DevFlow 现有策略层（code-version-backup-management）、配置层（.devflow/config.json）、框架层（cicd-pipeline-management）以及操作层（备份操作规范）的全部能力，形成完整的备份解决方案。*
