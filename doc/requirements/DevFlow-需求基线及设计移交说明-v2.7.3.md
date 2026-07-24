# DevFlow-需求基线及设计移交说明-v2.7.3

> 文档类型：需求基线及设计移交说明
> 文档状态：[Draft]
> 版本：v1.0
> 日期：2026-07-11
> 所属版本：v2.7.3

---

## 需求基线确认

| 项目 | 内容 |
|:-----|:------|
| 版本 | v2.7.3 |
| 需求基线版本 | v1.0 |
| 基线范围 | V260-030~034 共 5 项 |
| 基线确认日期 | 2026-07-11 |
| 状态 | 待批准后生效 |

## 基线变更规则

1. 进入 Step 2 后，任何需求变更必须记录范围、影响、审批
2. 变更触发重新评审 + 更新追溯矩阵
3. 新增需求写入候选需求池

## 设计移交材料清单

| # | 移交材料 | 文件路径 |
|:--:|:---------|:---------|
| 1 | 开发需求文档 | `doc/requirements/DevFlow-开发需求文档-v2.7.3.md` |
| 2 | 需求追溯矩阵 | `doc/requirements/DevFlow-需求追溯矩阵-v2.7.3.md` |
| 3 | 需求评审记录 | `doc/requirements/DevFlow-需求评审记录-v2.7.3.md` |
| 4 | 本版本 Backlog | `doc/version/releases/v2.7.3/DevFlow-本版本Backlog-v2.7.3.md` |
| 5 | 候选需求池 | `doc/version/global/DevFlow-候选需求池.md` |

## 设计阶段注意事项

| 需求 | 设计阶段注意事项 |
|:-----|:-----------------|
| V260-030 | setup.ps1 剥离后需确保 TRAE 技能安装功能完整；`setup.sh` 同步修改 |
| V260-031 | update.ps1 移除 projectVersion 写入后，需确认不会影响 TRAE 技能同步 |
| V260-032 | devflow-init 需增加读取 `~/.trae-cn/skills/devflow-plugin-config/version.json` 的路径 |
| V260-033 | projectVersion 检测优先级链需覆盖主要项目配置文件 |
| V260-034 | currentPhase 推断逻辑需与 devflow-phase-manager 的状态定义一致 |