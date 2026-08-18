# DevFlow 运维手册 — v2.18.0

> 文档类型：运维手册
> 版本：v2.18.0
> 日期：2026-08-19
> 作者：OE-DevFlow-Dev（运维工程师）

---

## 1. 系统概述

| 项 | 内容 |
|:---|:-----|
| 项目 | DevFlow 软件开发工程规范框架 |
| 版本 | v2.18.0（自动化落地 + 基础设施修复）|
| 运行形态 | 无运行时服务；以技能文档（SKILL.md）形式运行于 IDE |
| 分发机制 | Git 三远程仓库 + update.ps1 推送 IDE 技能目录 |

## 2. 目录结构（关键）

| 路径 | 说明 |
|:-----|:-----|
| devflow-plugin/skills/L1~L3/ | 技能文档主源（29 个技能）|
| devflow-plugin/.trae/skills/ | IDE 技能分发副本 |
| .devflow/skills/ | 项目内技能副本 |
| .devflow/hooks/ | Git hook 源文件（post-push + push-with-backup.ps1）|
| .git/hooks/pre-push | 安装的 hook（源自 .devflow/hooks/post-push）|

## 3. 日常运维操作

### 3.1 版本发布

```text
1. 更新 devflow-config.json devflowVersion（唯一事实源）
2. git commit + git tag v{X.Y.Z}
3. 三远程推送（--no-verify 或直接 push——v2.18.0 起 hook 已防递归）
4. 可选：显式调用 push-with-backup.ps1 验证备份 + TAG-CHECK
5. 生成 Release Note + 更新 Changelog
```

### 3.2 T3a 自动化巡检使用（v2.18.0 新增）

```text
1. Step 4 引用 testing-stage-execution "T3a 网络层巡检 E2E 用例模板"
2. ROUTES 替换为项目全部路由
3. pytest tests/e2e -m e2e 执行 + pytest --html 生成报告
4. CI 集成参考 "CI 回归集成示例" 章节
```

## 4. 常见故障排查

| 故障 | 排查步骤 |
|:-----|:---------|
| push 挂起 | v2.18.0 已修复（--no-verify 防递归）；如仍挂起检查 .devflow/logs/backup-hook.log |
| TAG-CHECK WARN | 三远程 tag 不一致，逐远程 ls-remote 核对后修正 |
| 技能文档未更新 | 检查 3 处副本 MD5；update.ps1 重新推送 |
| mirror 报 FAIL | 检查日志 BACKUP-ERROR/GITHUB-ERROR（"Everything up-to-date"为正常）|

## 5. 已知问题（v2.18.0 新增发现）

| 问题 | 级别 | 说明 |
|:-----|:----:|:-----|
| push-with-backup.ps1 mirror exit code 捕获瑕疵 | 🟢 P3 | 无新变更时 mirror 被误标 FAIL（实际 up-to-date）|
| github mirror 拒绝删除 main | 🟢 P3 | github 默认分支保护（mirror 模式兼容性），不影响 master/tag |

> 两项 P3 均不影响发布，记录于问题跟踪 F-218-501/502，v2.19.0 候选评估。

## 6. 联系人

| 角色 | 负责人 |
|:-----|:-------|
| 发布负责人 | DO-DevFlow-Dev |
| 运维负责人 | OE-DevFlow-Dev |
| 规范问题反馈 | PM-DevFlow-Dev |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-19 | 初始创建，含 T3a 自动化使用说明 + 2 项新发现 P3 问题 | OE-DevFlow-Dev |
