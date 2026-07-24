# DevFlow 设计开发追溯矩阵 v2.9.0

> **文档类型**: 设计开发追溯矩阵（TD-ID）
> **版本**: v2.9.0
> **项目**: DevFlow
> **创建日期**: 2026-07-21
> **开发者**: PM-DevFlow-Dev

---

## 1. 版本控制记录

| 配置项 | 内容 |
|:------|:------|
| 分支策略 | `git-flow`（配置源：`.devflow/config.json`） |
| 主开发分支 | `develop` |
| 本版本分支 | `release/v2.9.0`（从 develop 切出） |
| Commit 格式 | `type(scope): subject` |
| 允许类型 | `feat / fix / docs / style / refactor / test / chore` |
| RT-ID footer 约定 | `RT-ID: #RT-{序号}`（例：`RT-ID: #RT-01`） |
| 版本号格式 | 语义化 `MAJOR.MINOR.PATCH` |
| 远程仓库 | `http://192.168.0.14/jerry.yu/devflow.git` |
| 备份仓库 | `http://192.168.0.14/jerry.yu/devflow-backup.git` |

---

## 2. 设计开发追溯矩阵

| TD-ID | DT-ID | RT-ID | 需求 | 设计项 | 涉及文件 | 修改类型 | 修改说明 |
|:-----:|:-----:|:-----:|:----:|:------:|:---------|:--------:|:---------|
| TD-290-01 | DT-001 | RT-01 | R-01 还债配额机制 | 0.0a 增强：还债配额检查 + 门禁 + 连续2版规则 | `devflow-plugin/skills/L2/version-planning-stage-execution.md` | 增量修改 | 0.0a 活动表追加规则(5)(6)(7)：还债占比计算、<15%门禁警告、连续2版<15%专项评审 |
| TD-290-02 | DT-002 | RT-02 | R-02 跨版本债务流转 | 0.0a 增强：老化升级确认 + 遍历规则 | `devflow-plugin/skills/L2/version-planning-stage-execution.md` | 增量修改 | 0.0a 活动表规则(3)(4) 补充完善：待偿还/挂起条目遍历、老化升级条件、确认记录 |
| TD-290-03 | DT-005 | RT-05 | R-05 Step 0 来源规范化 | 0.0 阶段新增 6 来源检查清单 | `devflow-plugin/skills/L2/version-planning-stage-execution.md` | 增量修改 | 0.0 活动表追加规则(2)：输出来源检查清单（6 标准通道） |
| TD-290-04 | DT-003 | RT-03 | R-03 测试覆盖率门禁 | testing-stage-execution 新增覆盖率门禁规则 | `devflow-plugin/skills/L2/testing-stage-execution.md` | 增量修改 | 测试门禁章节新增覆盖率门禁：>=80%通过、<80%阻塞+补充重测 |
| TD-290-05 | DT-004 | RT-04 | R-04 端到端集成验证 | testing-stage-execution 新增 E2E 验证流程 | `devflow-plugin/skills/L2/testing-stage-execution.md` | 增量修改 | 新增 E2E 集成验证独立章节：场景列表读取→逐场景执行→通过/失败报告 |
| TD-290-06 | DT-006 | RT-06 | R-06 version.json 字段补全 | devflow-init 新增 version.json 补全步骤 | `devflow-plugin/devflow-init/SKILL.md` | 增量修改 | 新增 §1.6.1：检查 repository/homepage 字段→从 config.json remote.origin 读取→写入 |
| TD-290-07 | DT-007 | RT-07 | R-07 devflow-init 版本差异检测 | devflow-init §1.5.5 版本差异检测 | `devflow-plugin/devflow-init/SKILL.md` | ✅ 已实现（v2.8.5） | §1.5.5 版本差异检测已在 v2.8.5 实现，本版本仅验证确认 |

---

## 3. 覆盖率统计

| 统计项 | 结果 |
|:-------|:----:|
| 设计项总数 | 7 (DT-001 ~ DT-007) |
| 需编码设计项 | 6 (DT-001 ~ DT-006) |
| 已实现设计项 | 1 (DT-007 / R-07 — v2.8.5 已完成) |
| 待编码设计项 | 0 |
| 已编码设计项 | 6 |
| 编码完成率 | 100% (6/6) |

---

## 4. 修改文件总览

| 文件 | 层级 | 对应 TD-ID | 当前状态 |
|:-----|:----:|:----------:|:--------:|
| `devflow-plugin/skills/L2/version-planning-stage-execution.md` | L2 | TD-290-01, TD-290-02, TD-290-03 | ✅ 已修改 |
| `devflow-plugin/skills/L2/testing-stage-execution.md` | L2 | TD-290-04, TD-290-05 | ✅ 已修改 |
| `devflow-plugin/devflow-init/SKILL.md` | L1 | TD-290-06, TD-290-07 | ✅ 已修改（R-07 已实现，仅验证） |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-21 | 初始创建，v2.9.0 设计开发追溯矩阵 | PM-DevFlow-Dev |
