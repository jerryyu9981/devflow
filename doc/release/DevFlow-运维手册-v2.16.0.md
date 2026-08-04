# DevFlow 运维手册 — v2.16.0

> 文档类型：运维手册
> 版本：v2.16.0
> 状态：[Review]
> 日期：2026-08-04
> 作者：DO-DevFlow-Dev（DevOps工程师）

---

## 1. 系统概览

| 项 | 内容 |
|:---|:-----|
| 项目 | DevFlow 软件开发工程规范框架 |
| 当前版本 | v2.16.0 |
| 版本号来源 | `devflow-plugin/devflow-config.json` 的 `devflowVersion`（唯一事实源）|
| 部署形态 | Git 仓库 + 技能文档分发 |

## 2. 关键文件

| 文件 | 用途 |
|:-----|:-----|
| devflow-plugin/devflow-config.json | 版本号唯一事实源 + 插件配置 |
| .devflow/project-config.json | 项目名片（version/lastRelease/remote）|
| .devflow/state.json | 阶段状态机 |
| devflow-plugin/release.ps1 | 发布自动化脚本 |
| devflow-plugin/validate-version-header.ps1 | 版本一致性门禁 |

## 3. 常用运维命令

| 场景 | 命令 |
|:-----|:-----|
| 版本一致性检查 | `.\devflow-plugin\validate-version-header.ps1` |
| 发布版本 | `.\devflow-plugin\release.ps1` |
| 技能副本同步 | `.\devflow-plugin\update.ps1` |
| 查看备份日志 | `Get-Content .devflow\logs\backup-hook.log` |
| 回滚到 v2.15.0 | `git revert v2.16.0` |

## 4. 常见故障排查

| 故障 | 排查命令 | 处理 |
|:-----|:---------|:-----|
| 版本号不一致 | validate-version-header.ps1 | 执行 release.ps1 重新同步 |
| 技能副本过时 | 比对 devflow-plugin/skills vs .trae/skills | 执行 update.ps1 |
| 远程 push 失败 | git ls-remote origin | 检查认证与网络 |

## 5. 运维移交清单

| 项 | 状态 |
|:---|:----:|
| 运维联系人 | DO-DevFlow-Dev |
| 审批人 | PM-DevFlow-Dev |
| SLA | ✅ N/A（无运行时服务）|
| 备份策略 | Git 三远程（origin/backup/github）+ pre-push hook |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-04 | 初始创建，运维移交清单齐备 | DO-DevFlow-Dev |
