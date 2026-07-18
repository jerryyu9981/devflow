# DevFlow-运维手册-v2.7.3

> 文档类型：运维手册
> 文档状态：[Draft]
> 版本：v1.0
> 日期：2026-07-11
> 所属版本：v2.7.3

---

## 运维移交清单

| # | 移交项 | 说明 |
|:--:|:-------|:------|
| 1 | 源码仓库 | `D:\Trae CN\myproject\Dev\DevFlow\devflow-plugin\` |
| 2 | Git 远程仓库 | origin: `http://192.168.0.14/jerry.yu/devflow.git` |
| 3 | Git 备份仓库 | backup: `http://192.168.0.14/jerry.yu/devflow-backup.git` |
| 4 | 技能同步脚本 | `devflow-plugin/sync-skills.ps1` |
| 5 | 安装脚本 | `devflow-plugin/setup.ps1` / `setup.sh` |
| 6 | 更新脚本 | `devflow-plugin/update.ps1` / `update.sh` |
| 7 | 版本文件 | `devflow-plugin/version.json` |
| 8 | TRAE 技能目录 | `~/.trae-cn/skills/` |

## 常见故障与排障

| 故障 | 诊断 | 修复 |
|:-----|:------|:------|
| 新项目看不到最新 DevFlow 版本 | 检查 `~/.trae-cn/skills/devflow-plugin-config/version.json` | 重新运行 setup.ps1 |
| 技能未更新 | 检查 sync-skills.ps1 输出 | 重新 run `sync` |
| devflow-init 读取版本号失败 | 检查 TRAE 技能目录是否存在 | 运行 setup.ps1 安装 |