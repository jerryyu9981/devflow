# DevFlow 运维手册 — v2.15.0

> 文档类型：运维手册（含运维移交清单）
> 版本：v2.15.0
> 状态：[Approved]
> 日期：2026-08-02
> 作者：OE-DevFlow-Dev（运维工程师）

---

## 1. 运维移交清单

| 移交项 | 说明 | 状态 |
|:-------|:------|:----:|
| 部署架构 | 无运行时服务，纯文档/配置/脚本插件项目 | ✅ |
| 仓库地址 | `http://192.168.0.14/jerry.yu/devflow.git` | ✅ |
| 备份仓库 | `http://192.168.0.14/jerry.yu/devflow-backup.git` | ✅ |
| 构建方式 | Git commit + tag + push（无编译构建） | ✅ |
| 部署方式 | Git 仓库推送 + release.ps1 版本号同步 | ✅ |
| 启动方式 | 重启 TRAE IDE 自动加载技能 | ✅ |
| 版本号文件 | devflow-config.json（devflowVersion 为唯一事实源） | ✅ |
| 配置中心 | .devflow/project-config.json | ✅ |
| 状态文件 | .devflow/state.json | ✅ |
| 版本一致性验证 | devflow-plugin/validate-version-header.ps1 | ✅ |
| 发布脚本 | devflow-plugin/release.ps1 | ✅ |
| 更新脚本 | devflow-plugin/update.ps1 | ✅ |
| 技能同步脚本 | devflow-plugin/sync-skills.ps1 | ✅ |
| Git hook | .devflow/hooks/post-push（自动备份推送） | ✅ |
| 回滚方案 | doc/release/DevFlow-回滚方案-v2.15.0.md | ✅ |
| 运维审计 | 待产出（Step 5 运维审计报告） | 🔄 |

---

## 2. 联系方式

| 角色 | 负责人 ID | 职责 | 联系场景 |
|:-----|:----------|:-----|:---------|
| DevOps 工程师 | DO-DevFlow-Dev | 发布执行、回滚操作、版本号管理、Git 仓库维护 | 发布问题、回滚决策、版本号不一致 |
| 运维工程师 | OE-DevFlow-Dev | 上线验证、日常监控、故障排查、运维移交 | 健康检查异常、脚本执行失败、日志排查 |
| 审计员 | AU-DevFlow-Dev | 运维审计、全流程闭环审计、合规检查 | 审计材料缺失、追溯链路断裂、合规问题 |

---

## 3. 常见故障与排障

### 3.1 常见故障表

| 故障 | 级别 | 原因 | 排障命令 | 处理方式 |
|:-----|:----:|:-----|:---------|:---------|
| 版本号不一致 | P1 | devflow-config.json / project-config.json / state.json 三处版本号不同步 | `.\devflow-plugin\validate-version-header.ps1` | 执行 release.ps1 重新同步版本号 |
| 脚本执行失败 | P1 | update.ps1 / sync-skills.ps1 执行报错 | `.\devflow-plugin\update.ps1 -Action Sync` | 检查脚本输出日志，修正配置后重新执行 |
| Git push 失败 | P2 | 远程仓库不可达或权限问题 | `git status` + `git push origin master` | 检查网络连接和 Git 凭据，重试推送 |
| 技能未加载 | P2 | 未执行 update.ps1 或技能目录路径错误 | `LS .trae/skills/` | 执行 `.\devflow-plugin\update.ps1 -Action Sync` |
| 技能版本不对 | P2 | devflow-config.json 版本号落后 | `Get-Content devflow-plugin\devflow-config.json \| Select-String "devflowVersion"` | 执行 release.ps1 更新版本号 |
| 配置文件格式错误 | P2 | 手动修改 JSON 语法错误 | `Get-Content .devflow\project-config.json \| ConvertFrom-Json` | 修正 JSON 语法错误后重新加载 |
| Git hook 未触发备份 | P3 | post-push hook 权限或路径问题 | `Get-Content .devflow\logs\backup-hook.log` | 检查 hook 脚本权限和远程仓库配置 |
| validate-version-header.ps1 失败 | P1 | 文件头版本号与 devflow-config.json 不一致 | `.\devflow-plugin\validate-version-header.ps1` | 按脚本输出修正不一致的文件头 |

### 3.2 排障命令速查

| 命令 | 用途 | 预期输出 |
|:-----|:-----|:---------|
| `.\devflow-plugin\validate-version-header.ps1` | 版本头一致性验证 | exit code = 0（通过） |
| `git status` | 查看工作区状态 | clean（无未提交变更） |
| `git log --oneline -5` | 查看最近 5 条提交 | 最新提交为 v2.15.0 发布 commit |
| `git tag -l v2.15.0` | 验证 tag 存在 | 输出 v2.15.0 |
| `git ls-remote origin refs/tags/v2.15.0` | 验证远程 tag | 输出 tag hash |
| `Get-Content devflow-plugin\devflow-config.json \| Select-String "devflowVersion"` | 检查版本号 | 2.15.0 |
| `Get-Content .devflow\project-config.json \| ConvertFrom-Json \| Select-Object -ExpandProperty project` | 检查项目配置 | version = v2.15.0 |
| `.\devflow-plugin\update.ps1 -Action Sync` | 同步技能到 IDE | exit code = 0 |
| `Get-Content .devflow\logs\backup-hook.log` | 查看备份 hook 日志 | 最近推送成功记录 |

---

## 4. SLA / SLO

### 4.1 服务级别协议

| 级别 | 响应时间 | 处理时限 | 通知方式 | 适用场景 |
|:----:|:---------|:---------|:---------|:---------|
| P0 | < 4 小时 | < 24 小时 | 电话 + IM | 版本号冲突导致技能加载失败、配置文件损坏 |
| P1 | < 24 小时 | < 3 个工作日 | IM | 脚本执行失败、版本号不一致、validate-version-header.ps1 失败 |
| P2 | < 2 个工作日 | < 5 个工作日 | IM | Git push 失败、技能未加载 |
| P3 | < 5 个工作日 | < 10 个工作日 | 邮件 | Git hook 未触发备份、历史命名违规 |

> **说明**：本项目为文档/脚本型项目，无运行时服务，SLA 以工作日为基准。P0/P1 问题由 DO-DevFlow-Dev + OE-DevFlow-Dev 联合响应。

### 4.2 服务级别目标

| 指标 | 目标值 | 测量方式 |
|:-----|:-------|:---------|
| 版本一致性 | 100% | validate-version-header.ps1 exit code = 0 |
| 脚本可执行率 | ≥ 99% | update.ps1 / sync-skills.ps1 / release.ps1 执行成功率 |
| Git 仓库可用性 | ≥ 99.5% | git push / git pull 成功率 |
| 备份完整性 | 100% | post-push hook 日志确认每次推送已备份 |
| 文件头合规率 | 100% | validate-version-header.ps1 零违规 |

---

## 5. 监控

### 5.1 监控项

| 监控项 | 监控方式 | 检查频率 | 告警阈值 | 负责人 |
|:-------|:---------|:---------|:---------|:-------|
| Git 仓库健康检查 | `git status` + `git fetch origin` | 每日 1 次 | 工作区不干净 / 远程不可达 | OE-DevFlow-Dev |
| 版本一致性检查 | `.\devflow-plugin\validate-version-header.ps1` | 每次发布后 | exit code ≠ 0 | OE-DevFlow-Dev |
| 备份仓库同步 | `git ls-remote backup refs/tags/v2.15.0` | 每次 tag 创建后 | tag 不存在 | DO-DevFlow-Dev |
| 脚本可执行性 | `.\devflow-plugin\update.ps1 -Action Sync` | 每次发布后 | exit code ≠ 0 | OE-DevFlow-Dev |
| Git hook 日志 | `Get-Content .devflow\logs\backup-hook.log` | 每次推送后 | 最近的推送记录缺失 | OE-DevFlow-Dev |

### 5.2 告警规则

| 告警级别 | 触发条件 | 通知方式 | 通知对象 | 响应时限 |
|:---------|:---------|:---------|:---------|:---------|
| P0 | 版本号冲突导致技能加载失败 | 电话 + IM | DO-DevFlow-Dev | < 4 小时 |
| P1 | validate-version-header.ps1 失败 | IM | DO-DevFlow-Dev + OE-DevFlow-Dev | < 24 小时 |
| P2 | Git push 失败或备份未完成 | IM | DO-DevFlow-Dev | < 2 个工作日 |

---

## 6. 日志

### 6.1 日志位置

| 日志文件 | 路径 | 说明 | 保留策略 |
|:---------|:-----|:------|:---------|
| 备份 hook 日志 | `.devflow/logs/backup-hook.log` | post-push hook 自动备份推送记录 | 永久保留 |
| 发布脚本日志 | `.devflow/logs/release.log` | release.ps1 执行记录 | 保留最近 10 个版本 |
| 更新脚本日志 | `.devflow/logs/update.log` | update.ps1 执行记录 | 保留最近 30 天 |

### 6.2 日志格式

日志采用文本格式，每行记录包含时间戳、级别、消息：

```
[2026-08-02 10:30:00] [INFO] backup-hook: pushing to backup remote...
[2026-08-02 10:30:05] [INFO] backup-hook: backup push completed successfully
```

### 6.3 日志检查命令

```powershell
# 查看最近的备份 hook 日志
Get-Content .devflow\logs\backup-hook.log -Tail 20

# 查看发布脚本日志
Get-Content .devflow\logs\release.log -Tail 20

# 检查备份 hook 是否有错误
Select-String -Path .devflow\logs\backup-hook.log -Pattern "ERROR" -SimpleMatch
```

---

## 7. 维护操作

### 7.1 日常维护脚本

| 脚本 | 路径 | 用途 | 执行频率 |
|:-----|:-----|:-----|:---------|
| update.ps1 | `devflow-plugin/update.ps1` | 同步技能到 TRAE IDE（-Action Sync） | 每次发布后 / 按需 |
| sync-skills.ps1 | `devflow-plugin/sync-skills.ps1` | 同步技能文件到安装目录 | 每次发布后 / 按需 |
| release.ps1 | `devflow-plugin/release.ps1` | 发布脚本（版本号同步 + state.json 更新） | 每次发布时 |
| validate-version-header.ps1 | `devflow-plugin/validate-version-header.ps1` | 版本头一致性验证 | 每次发布后 / 日常检查 |

### 7.2 update.ps1 使用说明

```powershell
# 同步技能到 IDE
.\devflow-plugin\update.ps1 -Action Sync

# 验证安装
.\devflow-plugin\update.ps1 -Action Verify
```

### 7.3 sync-skills.ps1 使用说明

```powershell
# 同步技能文件到 .trae/skills/ 目录
.\devflow-plugin\sync-skills.ps1

# 验证同步结果
LS .trae/skills/
```

### 7.4 版本号一致性维护

```powershell
# 1. 验证版本号一致性
.\devflow-plugin\validate-version-header.ps1

# 2. 检查三处配置文件版本号
Get-Content devflow-plugin\devflow-config.json | Select-String "devflowVersion"
Get-Content .devflow\project-config.json | ConvertFrom-Json | Select-Object -ExpandProperty project
Get-Content .devflow\state.json | ConvertFrom-Json | Select-Object -ExpandProperty devflowVersion

# 3. 如不一致，执行 release.ps1 重新同步
.\devflow-plugin\release.ps1
```

### 7.5 Git 仓库维护

```powershell
# 查看仓库状态
git status

# 查看最近提交
git log --oneline -10

# 查看所有 tag
git tag -l "v2.*"

# 验证远程仓库连通性
git ls-remote origin
git ls-remote backup

# 清理本地未跟踪文件（谨慎使用）
git clean -n  # 预览
git clean -f  # 执行
```

---

## 8. 运维检查清单

### 8.1 发布后检查清单

| 检查项 | 验证命令 | 预期结果 | 状态 |
|:-------|:---------|:---------|:----:|
| 版本号一致性 | `.\devflow-plugin\validate-version-header.ps1` | exit code = 0 | ✅ |
| Git tag 存在 | `git tag -l v2.15.0` | 输出 v2.15.0 | ✅ |
| 远程 tag 同步 | `git ls-remote origin refs/tags/v2.15.0` | 输出 tag hash | ✅ |
| 备份 tag 同步 | `git ls-remote backup refs/tags/v2.15.0` | 输出 tag hash | ✅ |
| 技能加载正常 | 重启 TRAE IDE 后检查技能列表 | 技能正常加载 | ✅ |
| 脚本可执行 | `.\devflow-plugin\update.ps1 -Action Sync` | exit code = 0 | ✅ |
| 备份 hook 日志 | `Get-Content .devflow\logs\backup-hook.log -Tail 5` | 最近推送成功 | ✅ |

### 8.2 日常巡检清单

| 检查项 | 验证命令 | 检查频率 | 负责人 |
|:-------|:---------|:---------|:-------|
| Git 仓库状态 | `git status` | 每日 | OE-DevFlow-Dev |
| 版本一致性 | `.\devflow-plugin\validate-version-header.ps1` | 每日 | OE-DevFlow-Dev |
| 备份 hook 日志 | `Get-Content .devflow\logs\backup-hook.log -Tail 10` | 每日 | OE-DevFlow-Dev |
| 远程仓库连通 | `git ls-remote origin` | 每周 | DO-DevFlow-Dev |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-02 | 初始创建，v2.15.0 运维手册（含运维移交清单 + 常见故障 + SLA/SLO + 监控 + 日志 + 维护操作） | OE-DevFlow-Dev |
