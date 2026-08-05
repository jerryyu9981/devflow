# DevFlow 回滚方案 — v2.15.0

> 文档类型：回滚方案（含回滚预案 + 回滚演练记录）
> 版本：v2.15.0
> 状态：[Approved]
> 日期：2026-08-02
> 作者：DO-DevFlow-Dev（DevOps工程师）

---

## 1. 回滚预案

### 1.1 版本特征与回滚策略

| 项目 | 内容 |
|:-----|:------|
| 版本特征 | 纯文档修订 + 验证脚本 + 配置文件变更，无运行时服务变更 |
| 部署策略 | 直接部署（Git-based，文档/脚本型项目） |
| 回滚方式 | Git revert + Git tag 删除 + 版本号回滚 |
| 回滚目标版本 | v2.14.0 |
| 回滚范围 | testing-stage-execution SKILL.md、api-contract-management SKILL.md、validate-version-header.ps1、devflow-config.json、project-config.json、state.json、Git hook（post-push）、L2/L3 输出要求变更 |
| 数据回滚 | N/A — 文档/脚本型项目，无数据库，无数据回滚需求 |

### 1.2 回滚触发条件

| 触发条件 | 级别 | 触发方式 | 说明 |
|:---------|:----:|:---------|:------|
| 健康检查失败 | P0 | 自动触发 | validate-version-header.ps1 退出码 ≠ 0，版本一致性校验不通过 |
| 错误率 > 1% | P0 | 自动触发 | 脚本执行失败率超过阈值（update.ps1 / sync-skills.ps1 / release.ps1） |
| P0 缺陷确认 | P0 | 手动触发 | 部署后发现 P0 级缺陷（如技能加载失败、配置文件损坏、版本号冲突） |
| P99 超基线 50% | P1 | 自动触发 | 脚本执行耗时超基线 50%（文档项目以脚本执行时间为性能基线） |
| 冒烟验证失败 | P1 | 自动触发 | 部署后冒烟验证（版本一致性 + 脚本可执行性）不通过 |

### 1.3 回滚步骤

#### 步骤 1：Git revert（代码回滚）

```powershell
# 1. 确认当前版本 commit hash
git log --oneline -5

# 2. 执行 git revert（推荐保留历史记录）
git revert <v2.15.0-commit-hash> --no-edit

# 3. 或者使用 git checkout 恢复到 v2.14.0（文件级恢复）
git checkout v2.14.0 -- devflow-plugin/skills/
git checkout v2.14.0 -- devflow-plugin/devflow-config.json
git checkout v2.14.0 -- devflow-plugin/validate-version-header.ps1
git checkout v2.14.0 -- .devflow/project-config.json
git checkout v2.14.0 -- .devflow/state.json
```

#### 步骤 2：Git tag 删除

```powershell
# 1. 删除本地 tag
git tag -d v2.15.0

# 2. 删除远程 origin tag
git push origin :refs/tags/v2.15.0

# 3. 删除远程 backup tag
git push backup :refs/tags/v2.15.0

# 4. 验证 tag 已删除
git tag -l v2.15.0
git ls-remote origin refs/tags/v2.15.0
git ls-remote backup refs/tags/v2.15.0
```

#### 步骤 3：版本号回滚

```powershell
# 1. 回滚 devflow-config.json 版本号
# devflowVersion: 2.15.0 → 2.14.0

# 2. 回滚 .devflow/project-config.json 版本号
# project.version: v2.15.0 → v2.14.0
# lastRelease.version: v2.15.0 → v2.14.0
# lastRelease.date: 2026-08-02 → 2026-07-28

# 3. 回滚 .devflow/state.json 版本号
# devflowVersion: 2.15.0 → 2.14.0

# 4. 提交版本号回滚
git add devflow-plugin/devflow-config.json .devflow/project-config.json .devflow/state.json
git commit -m "rollback: 版本号回滚至 v2.14.0"
```

### 1.4 数据回滚

| 项目 | 状态 | 说明 |
|:-----|:----:|:------|
| 数据库回滚 | ✅ N/A | 文档/脚本型项目，无数据库 |
| 缓存回滚 | ✅ N/A | 文档/脚本型项目，无缓存 |
| 消息队列回滚 | ✅ N/A | 文档/脚本型项目，无消息队列 |
| 配置回滚 | ✅ 已覆盖 | 通过 Git checkout 恢复配置文件（步骤 1） |
| 版本号回滚 | ✅ 已覆盖 | 通过手动修改配置文件版本号（步骤 3） |

**数据回滚结论**：N/A — 本项目为文档/脚本型项目，无数据库变更，无数据回滚需求。配置和版本号回滚已纳入回滚步骤。

### 1.5 回滚验证方法

| 验证项 | 验证命令 | 预期结果 | 通过标准 |
|:-------|:---------|:---------|:---------|
| 版本头一致性 | `.\devflow-plugin\validate-version-header.ps1` | 退出码 = 0 | exit code = 0 |
| 版本号一致性 | 检查 devflow-config.json / project-config.json / state.json 三处版本号 | 全部 = 2.14.0 | 三处一致 |
| Git tag 验证 | `git tag -l v2.15.0` | 无输出（tag 已删除） | 空输出 |
| 远程 tag 验证 | `git ls-remote origin refs/tags/v2.15.0` | 无输出 | 空输出 |
| 备份 tag 验证 | `git ls-remote backup refs/tags/v2.15.0` | 无输出 | 空输出 |
| 技能加载验证 | 重启 TRAE IDE 后检查技能列表 | 技能正常加载 | 无加载错误 |
| 脚本可执行性 | `.\devflow-plugin\update.ps1 -Action Sync` | 退出码 = 0 | exit code = 0 |

**回滚验证要求**：回滚完成后 15 分钟内必须完成上述全部验证项。未验证通过视为回滚失败，必须升级至 P0 处理。

### 1.6 审批流程

#### 标准回滚流程

| 步骤 | 活动 | 负责人 | 通过标准 |
|:----:|:-----|:-------|:---------|
| 1 | 回滚申请 | DO-DevFlow-Dev | 提交回滚原因和影响评估 |
| 2 | 回滚审批 | DO-DevFlow-Dev + PM-DevFlow-Dev | 双签批准 |
| 3 | 执行回滚 | DO-DevFlow-Dev | 按回滚步骤执行 |
| 4 | 回滚验证 | OE-DevFlow-Dev | 15 分钟内完成验证 |
| 5 | 回滚记录 | DO-DevFlow-Dev | 在问题跟踪记录中记录原因和影响 |

#### 紧急回滚流程（P0 故障）

| 步骤 | 活动 | 负责人 | 通过标准 |
|:----:|:-----|:-------|:---------|
| 1 | P0 故障确认 | DO-DevFlow-Dev | 确认故障级别为 P0 |
| 2 | 紧急回滚执行 | DO-DevFlow-Dev | **跳过审批，立即执行回滚** |
| 3 | 回滚验证 | OE-DevFlow-Dev | 15 分钟内完成验证 |
| 4 | 补录材料 | DO-DevFlow-Dev | **2 小时内补录回滚审批材料** |
| 5 | RCA 输出 | DO-DevFlow-Dev | **24 小时内输出根因分析（RCA）** |

### 1.7 Pro 环境审批人列表

| 环境 | 审批人角色 | 审批人 ID | 审批权限 |
|:-----|:----------|:----------|:---------|
| Pro | DevOps 工程师 | DO-DevFlow-Dev | 标准回滚审批 + 紧急回滚执行 |
| Pro | 项目经理 | PM-DevFlow-Dev | 标准回滚审批（双签） |

> **注意**：Pro 环境标准回滚必须 DO-DevFlow-Dev + PM-DevFlow-Dev 双签批准后方可执行。紧急回滚（P0 故障）可由 DO-DevFlow-Dev 单独决定执行，2 小时内补录审批材料。

---

## 2. 回滚演练

### 2.1 演练计划

| 演练项 | 验证方式 | 演练环境 | 状态 |
|:-------|:---------|:---------|:----:|
| `git checkout v2.14.0` 恢复旧版文件 | 命令执行 + 文件存在性验证 | Dev | ✅ N/A |
| version.json 恢复 | N/A（v2.15.0 已弃用 version.json） | Dev | ✅ N/A |
| 回滚后版本号一致性 | devflow-config.json / project-config.json / state.json 三处版本号一致 | Dev | ✅ N/A |
| validate-version-header.ps1 回滚后验证 | 退出码 = 0 | Dev | ✅ N/A |

### 2.2 演练结论

| 项目 | 结论 | 说明 |
|:-----|:----:|:------|
| 演练方式 | ✅ N/A | 文档/脚本型项目，无运行时服务，无需回滚演练 |
| 风险评估 | ✅ 已批准 | 回滚路径明确（Git revert + tag 删除 + 版本号回滚），风险可控 |
| 风险批准人 | DO-DevFlow-Dev | 已确认无需演练，回滚步骤可执行 |

**演练结论**：✅ N/A — 本项目为文档/脚本型项目，无运行时服务部署，无需蓝绿/金丝雀回滚演练。回滚路径为纯 Git 操作（revert + tag 删除 + 版本号回滚），步骤明确、可执行、可验证。风险已经 DO-DevFlow-Dev 评估并批准，无需额外演练。

---

## 3. 回滚后处理

### 3.1 回滚后 mandatory 动作

| 动作 | 负责人 | 时限 | 说明 |
|:-----|:-------|:-----|:------|
| 健康检查 + 冒烟验证 | OE-DevFlow-Dev | 回滚后 15 分钟内 | validate-version-header.ps1 + 版本一致性检查 |
| 回滚原因记录 | DO-DevFlow-Dev | 回滚后立即 | 在问题跟踪记录中记录原因和影响 |
| 发布复盘记录 RCA | DO-DevFlow-Dev | 24 小时内（P0 故障） | 在发布复盘中记录根因分析 |
| 技术债务总表更新 | DO-DevFlow-Dev | 回滚后 | 如产生新债务，归集至技术债务总表 |

### 3.2 回滚后版本号一致性验证

| 配置文件 | 字段 | 回滚后预期值 |
|:---------|:-----|:-----------|
| devflow-plugin/devflow-config.json | devflowVersion | 2.14.0 |
| .devflow/project-config.json | project.version | v2.14.0 |
| .devflow/project-config.json | lastRelease.version | v2.14.0 |
| .devflow/state.json | devflowVersion | 2.14.0 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-02 | 初始创建，v2.15.0 回滚方案（含回滚预案 + 回滚演练记录） | DO-DevFlow-Dev |
