# DevFlow 文档模板

> 18 个标准文档模板的定义位于 `skills/L3/project-document-templates.md` 中。
> 本目录提供最常用的 3 个追溯矩阵模板的独立文件，便于直接复制使用。

## 完整模板列表

| 阶段 | 模板 | 文件 |
|------|------|------|
| Step 0 | 单版本规划文档 | `skills/L3/project-document-templates.md` Section: 模板：单版本规划文档 |
| Step 1 | 开发需求文档 | `skills/L3/project-document-templates.md` Section: 模板：开发需求文档 |
| Step 1 | **需求追溯矩阵** | [RT-需求追溯矩阵.md](RT-需求追溯矩阵.md) |
| Step 2 | 系统架构设计文档 | `skills/L3/project-document-templates.md` Section: 模板：系统架构设计文档 |
| Step 2 | **需求设计追溯矩阵** | [DT-需求设计追溯矩阵.md](DT-需求设计追溯矩阵.md) |
| Step 3 | **设计开发追溯矩阵** | [TD-设计开发追溯矩阵.md](TD-设计开发追溯矩阵.md) |
| Step 3 | DevLogReport | `skills/L3/project-document-templates.md` Section: 模板：DevLogReport |
| Step 4 | 测试报告 | `skills/L3/project-document-templates.md` Section: 模板：测试报告 |
| Step 5 | 发布计划 | `skills/L3/project-document-templates.md` Section: 模板：发布计划 |
| Step 5 | 部署执行记录 | `skills/L3/project-document-templates.md` Section: 模板：部署执行记录 |
| 审计 | 需求评审记录 | `skills/L3/project-document-templates.md` Section: 模板：需求评审记录 |
| 审计 | 设计评审记录 | `skills/L3/project-document-templates.md` Section: 模板：设计评审记录 |

> 其余模板（发布复盘报告、CICD记录、安全审计报告等）请查阅 `skills/L3/project-document-templates.md`。

## 容灾备份扩展模板（VR-006）

> 以下 5 个容灾模板为可选扩展，项目应根据自身数据安全级别和合规要求选用。详细说明请参阅 `skills/L3/code-version-backup-management.md` Section 5.4。

| 模板 | 文件 | 用途 |
|------|------|------|
| **灾难恢复预案** | [DR-灾难恢复预案.md](DR-灾难恢复预案.md) | 定义灾难场景分类、恢复优先级、团队分工和标准化恢复操作流程 |
| **备份策略配置指南** | [DR-备份策略配置指南.md](DR-备份策略配置指南.md) | 制定备份类型、频率、保留、存储、加密和监控策略 |
| **多地域备份方案** | [DR-多地域备份方案.md](DR-多地域备份方案.md) | 设计跨地域备份架构、数据同步和故障切换方案 |
| **数据恢复演练流程** | [DR-数据恢复演练流程.md](DR-数据恢复演练流程.md) | 计划和执行恢复演练，评估 RTO/RPO 达成情况 |
| **备份完整性校验规范** | [DR-备份完整性校验规范.md](DR-备份完整性校验规范.md) | 定义备份校验算法、频率、报告模板和失败处理流程 |
