# DevFlow 发布计划 v2.7.4

> 文档类型：发布计划
> 文档状态：[Draft]
> 版本：v1.0.0
> 日期：2026-07-12
> 项目名称：DevFlow
> 当前版本：2.7.4

---

## 发布入场检查

| 检查项 | 结果 |
|--------|:----:|
| Step 0 版本规划已批准 | ✅ |
| Step 1 需求已批准 | ✅ |
| Step 2 设计已批准 | ✅ |
| Step 3 开发已完成 | ✅ |
| Step 4 测试已通过 | ✅ 11/11 验收标准通过 |
| P0/P1 问题已闭环 | ✅ 无 P0/P1 问题 |

## 发布版本信息

| 项目 | 内容 |
|------|------|
| 版本号 | v2.7.4 |
| 版本类型 | 修订版本 |
| 核心变更 | version 字段命名规范化 + update 语义修复 |
| 影响范围 | DevFlow 插件配置文件和脚本 |

## 发布内容

| 文件 | 变更类型 |
|------|:--------:|
| `devflow-plugin/version.json` | 修改（字段重命名） |
| `DevFlow/version.json` | 修改（字段重命名） |
| `.devflow/state.json` | 修改（字段重命名+版本更新） |
| `.devflow/version.json` | **删除**（旧版备份遗留） |
| `devflow-plugin/setup.ps1` | 修改（字段引用同步） |
| `devflow-plugin/setup.sh` | 修改（字段引用同步） |
| `devflow-plugin/sync-skills.ps1` | 修改（字段引用同步） |
| `devflow-plugin/update.ps1` | 修改（语义修复+字段同步） |
| `devflow-plugin/update.sh` | 修改（语义修复+字段同步） |
| `devflow-plugin/devflow-init/SKILL.md` | 修改（6 处字段引用更新） |
| `devflow-plugin/devflow-phase-manager/SKILL.md` | 修改（1 处模板更新） |
| `devflow-plugin/devflow-project-config/SKILL.md` | 无需修改（引用已正确） |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| v1.0.0 | 2026-07-12 | 初始创建 | DevFlow 维护团队 |