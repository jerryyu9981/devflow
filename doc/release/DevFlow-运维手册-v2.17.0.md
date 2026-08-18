# DevFlow 运维手册 — v2.17.0

> 文档类型：运维手册
> 版本：v2.17.0
> 日期：2026-08-18
> 作者：OE-DevFlow-Dev（运维工程师）

---

## 1. 系统概述

| 项 | 内容 |
|:---|:-----|
| 项目 | DevFlow 软件开发工程规范框架 |
| 版本 | v2.17.0（规范衔接完善）|
| 运行形态 | 无运行时服务；以技能文档（SKILL.md）形式运行于 IDE |
| 分发机制 | Git 三远程仓库 + update.ps1 推送 IDE 技能目录 |

## 2. 目录结构（关键）

| 路径 | 说明 |
|:-----|:-----|
| devflow-plugin/skills/L1~L3/ | 技能文档主源（29 个技能）|
| devflow-plugin/.trae/skills/ | IDE 技能分发副本 |
| .devflow/skills/ | 项目内技能副本 |
| doc/version/ | 版本文档（全局 + releases）|
| doc/audit/ | 审计文档（review/assessment/verification/comprehensive）|

## 3. 日常运维操作

### 3.1 版本发布（已规范化）

```text
1. 更新 devflow-config.json devflowVersion（唯一事实源）
2. git commit + git tag v{X.Y.Z}
3. 三远程推送（origin/backup/github）—— 注意 pre-push hook 问题（见 §5.1）
4. update.ps1 推送 IDE 技能
5. 生成 Release Note + 更新 Changelog
```

### 3.2 技能文档修改

```text
1. 修改 devflow-plugin/skills/L{层级}/{技能}.md（主源）
2. 同步副本：.devflow/skills/ + devflow-plugin/.trae/skills/ + IDE 副本
3. 验证 MD5 一致
```

### 3.3 版本回滚

```text
git revert <hash> 或 git checkout v{旧版本} -- {文件}
详见 doc/release/DevFlow-回滚方案-v2.17.0.md
```

## 4. 常见故障排查

| 故障 | 排查步骤 |
|:-----|:---------|
| 技能文档未更新 | 检查 4 处副本 MD5；update.ps1 重新推送 |
| 版本号不一致 | 检查 devflow-config/project-config/state 三处 |
| push 卡住 | 检查 pre-push hook（见 §5.1），用 --no-verify 绕过 |
| 审计报告缺失 | 检查 doc/audit/review/ 下对应 Stage 报告 |

## 5. 已知问题

### 5.1 pre-push hook 推送挂起（F-217-501）

| 项 | 内容 |
|:---|:-----|
| 现象 | git push 触发 `.git/hooks/pre-push` 后台 `git push --mirror` 任务导致挂起 |
| 影响 | 三远程推送时可能卡住 |
| 处置 | 发布时使用 `git push --no-verify` 绕过 hook，手动推送三远程 |
| 后续 | 已登记问题跟踪记录，建议修复 hook 递归逻辑（待 v2.18.0 评估）|

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
| v1.0 | 2026-08-18 | 初始创建，定义目录结构/运维操作/故障排查/已知问题 | OE-DevFlow-Dev |
