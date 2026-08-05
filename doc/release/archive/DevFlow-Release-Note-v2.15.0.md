# DevFlow Release Note — v2.15.0

> 文档类型：单版本发布说明
> 版本：v2.15.0
> 日期：2026-08-02
> 发布类型：功能版本（次版本递增）

---

## 概述

v2.15.0 是 DevFlow **测试架构与版本治理双重升级**功能版本。核心交付五大能力增强：T1-T4 四层测试架构集成、版本号单一事实源落地、路由映射表 diff 机制、Stage4 产出物清单增强、Git post-push 自动备份 hook 规范化。本版本同步偿还技术债务 TD-031（P1），实现版本号配置从多源到单一事实源的架构级治理。

### 版本亮点

1. **T1-T4 四层测试架构** — testing-stage-execution 技能全面升级，13 项子能力增强，建立从单元测试到业务走查的完整四层测试体系
2. **版本号单一事实源** — TD-031 债务偿还，确立 devflow-config.json 为唯一版本号来源，弃用并删除 version.json
3. **路由映射表 diff 机制** — api-contract-management 技能新增 YAML 格式路由-字段映射表与 diff 脚本规范
4. **Stage4 产出物增强** — 新增 5 项强制产出，确保 T1-T4 架构可追溯、可验证
5. **Git hook 规范化** — code-version-backup-management 技能纳入 post-push 自动备份 hook 标准

---

## 变更清单

### BL-215-001（P0）：T1-T4 四层测试架构集成到 testing-stage-execution

将 T1-T4 四层测试架构完整集成到 testing-stage-execution 技能，覆盖测试设计、执行、验收全流程。

| 序号 | 变更内容 | 说明 |
|:----:|:---------|:-----|
| ① | 新增"T1-T4 四层测试架构"章节 | 层级概览 + 层间追溯 + 项目类型适配 |
| ② | 强化强制测试矩阵 API 测试行 | 三要素验证 + "接口通过 ≠ 页面可用"声明 |
| ③ | 新增 T3 两层分层规范 | T3a 巡检 + T3b 深度用例，含 6 步闭环巡检工作流、7 类标准问题分类、6 种根因识别方法 |
| ④ | 新增 T4 业务流程走查清单模板 | 端到端业务流程验证模板 |
| ⑤ | 四轨并行工作流映射 T 层标注 | 工作流与测试层级对应关系明确化 |
| ⑥ | 通过标准增加层间追溯验证 | 确保层间一致性可验证 |
| ⑦ | 反模式新增 4 条 T1-T4 相关条目 | 防止常见测试架构误用 |
| ⑧ | 断言分级规范 | L1/L2/L3 分级 + 禁止模式 + 推荐模式 |
| ⑨ | CRUD 全覆盖硬规则 | 测试用例设计规范，确保增删改查全覆盖 |
| ⑩ | 人机协作定位 | 人工测试清单（5 类）+ 抽样策略 |
| ⑪ | 测试覆盖矩阵 + 度量体系 | 7 项度量指标 + 覆盖缺口分析方法论 + 根因映射表 |
| ⑫ | 术语表 | 12 个核心术语定义 |
| ⑬ | 改进验收标准 | 9 项验收标准 + 验证方法 |

**涉及文件**：`devflow-plugin/skills/L2/testing-stage-execution.md`、`.trae` 副本

---

### BL-215-002（P1）：路由映射表 diff 机制增强 api-contract-management

为 api-contract-management 技能新增路由映射表 diff 机制，解决前后端 API 契约一致性的自动化验证问题。

| 变更内容 | 说明 |
|:---------|:-----|
| YAML 格式路由-字段映射表 | 定义标准化路由到字段的映射表格式 |
| diff 脚本规范 | 路由映射表差异比对的脚本执行规范 |
| 新增 checklist 项 | "路由映射表 diff 已执行"纳入强制检查清单 |

**涉及文件**：`devflow-plugin/skills/L2/api-contract-management.md`、`.trae` 副本

---

### BL-215-003（P1）：Stage4 产出物清单增强

Stage4（测试阶段）产出物清单新增 5 项强制产出，确保 T1-T4 四层测试架构的产出可追溯、可验证。

| 序号 | 新增产出现 | 用途 |
|:----:|:-----------|:-----|
| 1 | T1-T4 层间追溯矩阵 | 验证四层测试的层间一致性 |
| 2 | 全页面巡检问题表 | T3a 巡检发现问题的结构化记录 |
| 3 | UAT 走查清单 | T4 业务流程走查的标准化清单 |
| 4 | 测试覆盖矩阵 | 覆盖率度量与缺口分析的基础 |
| 5 | 测试度量报告 | 7 项度量指标的量化报告 |

**涉及文件**：`devflow-plugin/skills/L2/testing-stage-execution.md`（Stage4 checklist 章节）

---

### BL-215-004（P0）：版本号单一事实源落地（TD-031 债务偿还）

实施版本号单一事实源架构，彻底解决版本号多源维护导致的不一致风险。

| 序号 | 变更内容 | 说明 |
|:----:|:---------|:-----|
| ① | 确立 devflow-config.json devflowVersion 为唯一事实源 | 弃用并删除 version.json |
| ② | 增强发布流程 | 更新 devflow-config.json → 自动同步 state.json → 运行 update.ps1 |
| ③ | validate-version-header.ps1 Phase 1 | JSON 一致性检查作为发布门禁 |
| ④ | release.ps1 增强 | 新增 JSON 配置同步步骤 |
| ⑤ | 同步安装副本 | 确保安装路径下副本一致 |
| ⑥ | 脚本引用更新 | sync-skills.ps1 和 download-devflow.ps1 脚本引用同步更新 |

**涉及文件**：`devflow-plugin/devflow-config.json`、`.devflow/state.json`、`validate-version-header.ps1`、`release.ps1`、`sync-skills.ps1`、`download-devflow.ps1`、`version.json`（已删除）

---

### BL-215-005（P2）：Git post-push 自动备份 hook 规范化

将 Git post-push 自动备份 hook 纳入 code-version-backup-management 技能规范。

| 变更内容 | 说明 |
|:---------|:-----|
| 新增"自动备份 hook"章节 | code-version-backup-management 技能中新增 hook 规范 |
| devflow-init 安装流程 | 在 devflow-init 中集成 hook 安装过程 |
| 日志规范 | `.devflow/logs/backup-hook.log` 日志路径与格式规范 |

**涉及文件**：`devflow-plugin/skills/L2/code-version-backup-management.md`、`devflow-plugin/skills/L2/devflow-init.md`、`.trae` 副本

---

## 技术债务

| 债务 ID | 描述 | 级别 | 状态 |
|:-------:|:------|:----:|:----:|
| TD-031 | 版本号多源维护导致不一致风险（devflow-config.json + version.json 双源） | P1 | ✅ 已偿还 |

> TD-031 在本版本通过 BL-215-004 完成偿还。version.json 已弃用并删除，devflow-config.json devflowVersion 成为唯一版本号事实源。

---

## 已知问题

| 问题 | 级别 | 来源 | 状态 |
|:-----|:----:|:-----|:----:|
| 21 项历史命名违规 | P3 | v1.0~v2.6.0 历史遗留 | 待治理（v2.15.0 无新增违规） |

> 21 项命名违规均为 v1.0~v2.6.0 期间历史遗留，本版本（v2.15.0）未引入任何新增命名违规。历史违规将在后续版本中逐步治理。

---

## 测试结果

| 维度 | 结果 | 说明 |
|:---------|:----:|:-----|
| 测试用例通过率 | 16/16 = 100% | 全部通过 |
| P0/P1 缺陷 | 0 项 | 零严重缺陷 |
| 文件头一致性 | 490 文件零违规 | validate-version-header.ps1 验证通过 |

---

## 升级影响

- **向后兼容**：v2.15.0 完全兼容 v2.14.x。所有变更为技能文档规则增强、脚本增强和配置架构治理。
- **版本号迁移**：v2.15.0 起 version.json 已弃用并删除。升级后版本号以 devflow-config.json devflowVersion 为唯一事实源。
- **升级方式**：`.\update.ps1 -Action Sync`（或重新 install）

---

## 关联文档

| 文档 | 说明 |
|:-----|:-----|
| [发布计划 v2.15.0](DevFlow-发布计划-v2.15.0.md) | 发布计划与全阶段产出物盘点 |
| [发布入场检查记录 v2.15.0](DevFlow-发布入场检查记录-v2.15.0.md) | 9 项入场门禁全部通过 |
| 开发需求文档 v2.15.0 | 13 章完整需求规格 |
| 系统架构设计文档 v2.15.0 | 模块架构设计 |
| 测试报告 v2.15.0 | 16/16 通过，0 P0/P1 缺陷 |
| 测试回溯对比审计报告 v2.15.0 | RT-ID + TD-ID 全覆盖 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-02 | 初始创建，v2.15.0 功能版本发布说明 | DO-DevFlow-Dev |
