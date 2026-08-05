# DevFlow 系统架构设计文档 v2.10.0

> **文档类型**: 系统架构设计文档
> **版本**: v2.10.0
> **项目**: DevFlow
> **日期**: 2026-07-24
> **设计负责人**: PM-DevFlow-Dev

---

## 1. 设计总览

v2.10.0 定位为 DevFlow 自身的**质量保障完善版本**，7 项需求全部围绕 DevFlow 知识库插件的流程规范增强、模板补全、脚本重构和文档完善，不涉及运行时服务变更。

### 1.1 设计策略

| 需求分类 | 设计策略 | 影响文件范围 |
|:---------|:---------|:-------------|
| 流程门禁增强 | 在现有 L2 技能文档中追加标准化章节/维度 | `skills/L2/*.md` (5~6 个文件) |
| 脚本重构 | 功能合并+入口收敛，保留旧入口 alias | `devflow-plugin/scripts/*.ps1` |
| 模板补全 | 新增文档模板文件 | `devflow-plugin/templates/*.md` (15 个) |
| 引用注册 | 扫描补全 devflow-config.json 技能索引 | `devflow-config.json` |
| 审计+基线 | 新增流程文档+首次数据采集 | `doc/version/global/` |



---

## 2. 需求-设计追溯矩阵

| DT-ID | 关联 RT-ID | 需求 | 设计文档章节 | 设计项 | 覆盖状态 |
|:-----:|:----------:|:----:|:------------|:------|:--------:|
| DT-2100-001 | RT-2100-001 | 季度技术债务审计机制 | §3.1 | 季度审计流程文档 + 审计模板 | ✅ |
| DT-2100-002 | RT-2100-002 | 性能基准测试 | §3.2 | 基线定义 + 首次数据采集 | ✅ |
| DT-2100-003 | RT-2100-003 | 文件结构一致性保障 | §3.3 | Subtask CheckList + 第14维度 + 命名对齐 | ✅ |
| DT-2100-004 | RT-2100-004 | 模板文件补全 9→24 | §3.4 | 15 份新模板 | ✅ |
| DT-2100-005 | RT-2100-005 | 技能引用统一注册 | §3.5 | devflow-config.json 索引补全 | ✅ |
| DT-2100-006 | RT-2100-006 | 风险归集门禁完整落地 | §3.6 | 5 个 L2 追加风险归集清单 | ✅ |
| DT-2100-007 | RT-2100-007 | 安装脚本精简 | §3.7 | sync 合并入 update，保留内部模块 | ✅ |

## 3. 详细设计

### 3.1 季度技术债务审计机制（V2100-001 / TD-010）

| 设计项 | 内容 |
|:-------|:------|
| **新增文件** | `doc/version/global/DevFlow-季度债务审计流程.md` |
| **审计模板** | `doc/version/global/DevFlow-季度债务审计报告-v{季度}-v{年份}.md` |
| **审计步骤** | 启动→遍历总表→老化升级→还债计划→报告归档→总表更新 |
| **触发方式** | 每季度末由 PM-DevFlow-Dev 手动触发 |
| **审计范围** | 全部待偿还、偿还中、挂起中债务 |

### 3.2 性能基准测试（V2100-002 / TD-011）

| 设计项 | 内容 |
|:-------|:------|
| **测量对象** | DevFlow 技能加载时间（devflow-init 启动到全部技能就绪） |
| **基线建立** | 运行 3 次取中位数 |
| **基线记录** | `doc/performance/DevFlow-性能基线-v{版本号}.md` |
| **退化判定** | 较基线退化 > 20% 标记告警 |

### 3.3 文件结构一致性保障（V2100-003 / TD-027）

三环补强设计，详见《DevFlow-项目结构一致性保障方案-v1.0.md》：

| 补强 | 目标技能 | 改动内容 |
|:-----|:---------|:---------|
| A-Subtask CheckList | `version-planning-stage-execution.md` §3.2 | 追加子任务清单表格模板+规则 |
| B-第14维度 | `code-logic-review.md` | 新增"命名与结构一致性"审查维度 |
| C-命名对齐 | `operations-stage-execution.md` | 全阶段盘点增加命名一致性列 |

### 3.4 模板文件补全（TD-024）

| 设计项 | 内容 |
|:-------|:------|
| **当前数量** | 9 |
| **目标数量** | 24 |
| **新增模板类型** | 各阶段缺失文档模板（PRD/API/数据/安全/部署/运维等） |
| **存放路径** | `devflow-plugin/templates/` |

### 3.5 技能引用统一注册（TD-025）

| 设计项 | 内容 |
|:-------|:------|
| **当前状态** | devflow-config.json skills 数组不完整 |
| **目标** | 全部 28 个技能 + 内部模块引用完整注册 |
| **验证方式** | 新增扫描脚本校验 |

### 3.6 风险归集门禁完整落地（TD-026）

| 设计项 | 内容 |
|:-------|:------|
| **已完成** | operations-stage-execution（v2.9.2 V292-004） |
| **本版本** | 5 个剩余 L2 技能各追加"风险归集检查"必填章节 |
| **涉及技能** | version-planning / requirements / design / coding / testing |

### 3.7 安装脚本精简（V291-002）

| 设计项 | 内容 |
|:-------|:------|
| **当前** | 5 个脚本（install / update / sync / download / setup） |
| **目标** | 2 入口（install + update）+ 2 内部模块（download + setup） |
| **删除** | sync-skills.ps1 |
| **保留 alias** | 旧入口保留重定向告警 |

---

## 4. 影响分析

### 4.1 文件影响

| 文件 | 操作 |
|:-----|:----:|
| devflow-plugin/skills/L2/version-planning-stage-execution.md | 修改（Subtask CheckList） |
| devflow-plugin/skills/L3/code-logic-review.md | 修改（第14维度） |
| devflow-plugin/skills/L2/operations-stage-execution.md | 修改（命名对齐列） |
| devflow-plugin/skills/L2/requirements-stage-execution.md | 修改（风险归集章节） |
| devflow-plugin/skills/L2/design-stage-execution.md | 修改（风险归集章节） |
| devflow-plugin/skills/L2/coding-stage-execution.md | 修改（风险归集章节） |
| devflow-plugin/skills/L2/testing-stage-execution.md | 修改（风险归集章节） |
| devflow-plugin/skills/L2/version-planning-stage-execution.md | 修改（风险归集章节） |
| devflow-plugin/devflow-config.json | 修改（skills 补全） |
| devflow-plugin/templates/*.md | 新增（15 份） |
| devflow-plugin/scripts/sync-skills.ps1 | 删除 |
| devflow-plugin/scripts/update.ps1 | 修改（合并 sync 功能） |
| doc/version/global/季度审计流程.md | 新增 |
| doc/performance/性能基线.md | 新增 |

### 4.2 无影响

- 无 API 变更
- 无数据库变更
- 无前端/UI 变更
- 无第三方集成变更
- 无部署/环境变更

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| v1.0 | 2026-07-24 | 初始创建 | PM-DevFlow-Dev |
