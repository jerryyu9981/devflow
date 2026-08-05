# DevFlow 设计开发追溯矩阵（v2.9.1）

> 文档类型：设计开发追溯矩阵
> 文档状态：[Draft]
> 版本：v1.0.0
> 日期：2026-07-22
> 维护者：PM-DevFlow-Dev

---

## 说明

本矩阵建立 v2.9.1 版本的设计项（DT-ID）与代码实现（文件/模块）之间的映射关系，用于：

1. 确保每个设计项都有对应的代码实现
2. 确保代码变更都有对应的设计依据
3. 支持开发审计（开发设计对比覆盖率 ≥ 95%）
4. 支持变更影响分析

**格式**：TD-v291-XXX（TD = Traceability Document / Design-Development）

---

## 追溯总表

| TD-ID | 对应 DT-ID | 设计项 | 需求 | 涉及文件 | 实现状态 |
|:-----:|:----------:|:-------|:----:|:---------|:--------:|
| TD-v291-001 | DT-001 | devflow-config.json 配置架构重构 | F-01 | `devflow-plugin/devflow-config.json`（新建）<br>`devflow-plugin/version.json`（待废弃）<br>`devflow-plugin/devflow-manifest.json`（待废弃） | ✅ 已实现 |
| TD-v291-002 | DT-002 | project-config.json 项目配置独立 | F-02 | `.devflow/project-config.json`（新建）<br>`.devflow/config.json`（待废弃/迁移） | ✅ 已实现 |
| TD-v291-003 | DT-003 | 旧配置自动迁移机制 | F-03 | `install.ps1` 迁移模块<br>`update.ps1` 迁移模块<br>迁移工具函数 | ⚠️ 部分实现（过渡期兼容已完成，自动迁移待后续） |
| TD-v291-004 | DT-004 | install.ps1 脚本重构 | F-04 | `devflow-plugin/install.ps1`（重构）<br>`.devflow/scripts/download-devflow.ps1`（内部模块）<br>`.devflow/scripts/setup.ps1`（内部模块）<br>`.devflow/scripts/validate-install.ps1`（强制门禁） | ⚠️ 部分实现（validate-install 已完成，install.ps1 重构待后续） |
| TD-v291-005 | DT-005 | update.ps1 脚本重构 + sync-skills 合并 | F-05 | `devflow-plugin/update.ps1`（重构）<br>`devflow-plugin/sync-skills.ps1`（删除）<br>`.devflow/scripts/validate-install.ps1`（强制门禁） | ⚠️ 部分实现（validate-install 已完成，update.ps1 重构待后续） |
| TD-v291-006 | DT-006 | validate-install.ps1 多模式验证 | F-04 / F-05 | `.devflow/scripts/validate-install.ps1`（重构）<br>5 种模式：package / install / update / init / full | ✅ 已实现 |
| TD-v291-007 | DT-006 | 技能文档路径引用统一更新 | F-06 | 11 份技能文档中的路径引用更新（详见 §3） | ⏳ 待实现 |
| TD-v291-008 | DT-007 | 阶段产出物验证门禁 | F-07 | 6 个 L2 阶段技能文档（version-planning / requirements / design / coding / testing / operations） | ✅ 已实现 |
| TD-v291-009 | DT-008 | 审计环节产出物存在性核查 | F-08 | 6 份阶段审计/评估报告模板 + 审计技能文档 | ⏳ 待实现 |
| TD-v291-010 | DT-009 | Step 5 全阶段产出盘点 | F-09 | operations-stage-execution 技能文档<br>部署执行记录模板 | ✅ 已实现 |

---

## 各 TD-ID 详细映射

### TD-v291-001：devflow-config.json 配置架构重构

| 属性 | 内容 |
|:-----|:-----|
| **设计项** | DT-001：F-01 devflow-config.json |
| **需求来源** | V291-001 / F-01 |
| **设计章节** | 系统架构设计文档 §3.1 |
| **涉及文件** | |
| 新建 | `devflow-plugin/devflow-config.json` |
| 修改 | （无，首次创建） |
| 废弃 | `devflow-plugin/version.json`（合并入 devflow-config.json）<br>`devflow-plugin/devflow-manifest.json`（skills 字段合并入 devflow-config.json） |
| **实现要点** | 1. 合并 version.json 的元数据字段<br>2. 合并 devflow-manifest.json 的 skills 清单<br>3. 统一 JSON Schema，关键字段校验<br>4. Source of Truth 原则：唯一框架配置源 |

### TD-v291-002：project-config.json 项目配置独立

| 属性 | 内容 |
|:-----|:-----|
| **设计项** | DT-002：F-02 project-config.json |
| **需求来源** | V291-001 / F-02 |
| **设计章节** | 系统架构设计文档 §3.2 |
| **涉及文件** | |
| 新建 | `.devflow/project-config.json` |
| 修改 | （无，首次创建） |
| 废弃 | `.devflow/config.json`（迁移后删除或备份） |
| **实现要点** | 1. 项目元数据（name / version / code）<br>2. 远程仓库配置（remote.origin / remote.backup）<br>3. 命名规范（naming 字段）<br>4. 工作流配置（workflow.startingStep 等）<br>5. 环境配置（environments 字段） |

### TD-v291-003：旧配置自动迁移机制

| 属性 | 内容 |
|:-----|:-----|
| **设计项** | DT-003：F-03 旧路径自动迁移 |
| **需求来源** | V291-001 / F-03 |
| **设计章节** | 系统架构设计文档 §4 |
| **涉及文件** | `install.ps1` 迁移模块<br>`update.ps1` 迁移模块 |
| **实现要点** | 1. 迁移触发条件：检测到旧配置文件存在<br>2. 迁移流程：备份 → 读取旧数据 → 写入新格式 → 验证 → 归档旧文件<br>3. 迁移失败保护：自动回滚到备份<br>4. 新旧文件共存策略：过渡期双读，新文件优先 |

### TD-v291-004：install.ps1 脚本重构

| 属性 | 内容 |
|:-----|:-----|
| **设计项** | DT-004：F-04 install.ps1 模块化 |
| **需求来源** | V291-002 / F-04 |
| **设计章节** | 系统架构设计文档 §5.2 |
| **涉及文件** | `devflow-plugin/install.ps1`（主入口，重构）<br>`.devflow/scripts/download-devflow.ps1`（内部模块）<br>`.devflow/scripts/setup.ps1`（内部模块）<br>`.devflow/scripts/validate-install.ps1`（强制门禁，install 模式） |
| **实现要点** | 1. 7 步流程：环境检测 → 前置检查 → 下载框架 → 部署文件 → IDE集成 → 验证门禁 → 收尾输出<br>2. 调用 download-devflow.ps1 下载（含 package 模式验证）<br>3. 调用 setup.ps1 执行技能部署<br>4. 最后一步强制调用 validate-install.ps1 -Mode install<br>5. 验证失败自动回滚 |

### TD-v291-005：update.ps1 脚本重构 + sync-skills 合并

| 属性 | 内容 |
|:-----|:-----|
| **设计项** | DT-005：F-05 update.ps1 增量更新 |
| **需求来源** | V291-002 / F-05 |
| **设计章节** | 系统架构设计文档 §5.3 |
| **涉及文件** | `devflow-plugin/update.ps1`（主入口，重构）<br>`devflow-plugin/sync-skills.ps1`（删除，功能合并）<br>`.devflow/scripts/validate-install.ps1`（强制门禁，update 模式） |
| **实现要点** | 1. 9 步流程：版本检测 → 备份 → 下载更新 → 差异比对 → 增量部署 → 配置迁移 → 技能同步 → 验证门禁 → 收尾<br>2. 合并原 sync-skills.ps1 的技能同步功能<br>3. 自动检测旧配置并执行迁移<br>4. 最后一步强制调用 validate-install.ps1 -Mode update<br>5. 验证失败自动从备份恢复 |

### TD-v291-006：validate-install.ps1 多模式验证

| 属性 | 内容 |
|:-----|:-----|
| **设计项** | DT-004 / DT-005：F-04 / F-05 强制验证门禁 |
| **需求来源** | V291-002 / F-04 / F-05 |
| **设计章节** | 系统架构设计文档 §5.4.3 |
| **涉及文件** | `.devflow/scripts/validate-install.ps1`（重构为多模式） |
| **实现要点** | 1. 5 种模式：package / install / update / init / full<br>2. 渐进式检查：8 → 11 → 13 → 6 → 16 项<br>3. 分层验证 + 模式复用 + 渐进严格<br>4. 失败自动回滚（除 full 模式外）<br>5. 结构化返回对象 + 详细检查项结果 |

### TD-v291-007：技能文档路径引用统一更新

| 属性 | 内容 |
|:-----|:-----|
| **设计项** | DT-006：F-06 技能文档路径引用统一 |
| **需求来源** | V291-001 / F-06 |
| **设计章节** | 系统架构设计文档 §6 |
| **涉及文件** | 11 份技能文档（详见 §3 路径映射表） |
| **实现要点** | 1. version.json → devflow-config.json<br>2. config.json → project-config.json<br>3. devflow-manifest.json → devflow-config.json 的 skills 字段<br>4. 所有读取路径同步更新 |

### TD-v291-008：阶段产出物验证门禁

| 属性 | 内容 |
|:-----|:-----|
| **设计项** | DT-007：F-07 阶段产出物验证门禁 |
| **需求来源** | V291-003 / F-07 |
| **设计章节** | 系统架构设计文档 §7.1 |
| **涉及文件** | 6 个 L2 阶段技能文档：<br>• version-planning-stage-execution.md<br>• requirements-stage-execution.md<br>• design-stage-execution.md<br>• coding-stage-execution.md<br>• testing-stage-execution.md<br>• operations-stage-execution.md |
| **实现要点** | 1. 每个阶段完成标准增加"产出物存在性验证"条目<br>2. 标准化验证模板（LS/Glob 列出目标目录 + 逐项核对）<br>3. 验证不通过不得移交下一阶段<br>4. 风险归集门禁同步增加验证要求 |

### TD-v291-009：审计环节产出物存在性核查

| 属性 | 内容 |
|:-----|:-----|
| **设计项** | DT-008：F-08 审计环节核查 |
| **需求来源** | V291-003 / F-08 |
| **设计章节** | 系统架构设计文档 §7.2 |
| **涉及文件** | 各阶段审计/评估相关文档 + code-logic-review 等审查技能 |
| **实现要点** | 1. 审计清单增加"产出物存在性核查"项<br>2. 审计师须逐一核实文件实际存在<br>3. 核查结果记入审计报告 |

### TD-v291-010：Step 5 全阶段产出盘点

| 属性 | 内容 |
|:-----|:-----|
| **设计项** | DT-009：F-09 全阶段产出盘点 |
| **需求来源** | V291-003 / F-09 |
| **设计章节** | 系统架构设计文档 §7.3 |
| **涉及文件** | operations-stage-execution.md<br>部署执行记录模板 |
| **实现要点** | 1. Step 5 增加"全阶段产出物盘点"章节<br>2. 6 个阶段产出物逐一盘点<br>3. 空输出率 = 0% 才允许发布<br>4. 盘点结果作为发布门禁之一 |

---

## 覆盖率统计

| 统计项 | 总数 | 已实现 | 待实现 | 覆盖率 |
|:------|:----:|:------:|:------:|:------:|
| 设计项（DT-ID） | 9 | 0 | 9 | 0% |
| 需求（F-ID） | 9 | 0 | 9 | 0% |
| 追溯条目（TD-ID） | 10 | 0 | 10 | 0% |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-22 | 初始创建，v2.9.1 设计开发追溯矩阵<br>• 10 个 TD-ID 条目<br>• 覆盖 3 大需求 / 9 个 F-ID / 9 个 DT-ID | PM-DevFlow-Dev |
