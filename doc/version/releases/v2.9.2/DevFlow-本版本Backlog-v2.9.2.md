# DevFlow 本版本 Backlog v2.9.2

> **文档类型**: 本版本 Backlog
> **版本**: v2.9.2
> **项目**: DevFlow
> **创建日期**: 2026-07-23
> **维护者**: PM-DevFlow-Dev

---

## Backlog 概览

| 统计项 | 数量 |
|--------|:----:|
| 总需求数 | 4 |
| P0 | 2 |
| P1 | 1 |
| P2 | 1 |
| 还债项 | 1 |
| 还债占比 | 25% |

---

## 需求列表

| BL-ID | 关联需求 | 需求名称 | 优先级 | 状态 | 关联债务 | 预估工作量 |
|:------:|:--------:|:---------|:------:|:----:|:--------:|:----------:|
| BL-292-001 | V292-001 | 项目根 version.json 版本号统一 | P0 | 待开发 | — | 0.5h |
| BL-292-002 | V292-002 | .devflow/config.json projectVersion 更新 | P0 | 待开发 | — | 0.25h |
| BL-292-003 | V292-003 | devflow-plugin/ 已弃用配置文件清理 | P1 | 待开发 | — | 0.5h |
| BL-292-004 | V292-004 | 风险归集门禁前置准备（TD-026 部分偿还） | P2 | 待开发 | TD-026 | 1h |

---

## 需求详情

### BL-292-001 项目根 version.json 版本号统一

| 字段 | 值 |
|------|----|
| BL-ID | BL-292-001 |
| 关联需求 | V292-001 |
| 优先级 | P0 |
| 来源 | v2.9.1 devflow-init 检测 → 问题跟踪记录 |
| 描述 | 将项目根 `version.json`（当前 v2.8.5）更新至 v2.9.2，同时补全 repository.type、repository.url、homepage 字段（按 devflow-init §1.6.1 规范） |
| 验收标准 | 1. version.json.devflowVersion = "2.9.2"; 2. repository.type = "git"; 3. repository.url 非空; 4. homepage 非空; 5. devflow-init 检测 versionCheck.result = "consistent" |

### BL-292-002 .devflow/config.json projectVersion 更新

| 字段 | 值 |
|------|----|
| BL-ID | BL-292-002 |
| 关联需求 | V292-002 |
| 优先级 | P0 |
| 来源 | v2.9.1 devflow-init 检测 |
| 描述 | 将 `.devflow/config.json` 中的 `projectVersion` 从 "2.9.0" 更新至 "2.9.2"，与 Git describe 结果一致 |
| 验收标准 | 1. config.json.projectVersion = "2.9.2"; 2. `git describe --tags --abbrev=0` = v2.9.2 |

### BL-292-003 devflow-plugin/ 已弃用配置文件清理

| 字段 | 值 |
|------|----|
| BL-ID | BL-292-003 |
| 关联需求 | V292-003 |
| 优先级 | P1 |
| 来源 | v2.9.1 Release Note 迁移标记 + 复盘改进项 |
| 描述 | 1. 将 `devflow-plugin/version.json`（v2.8.5）备份至 `.devflow/backup/deprecated-version.json`; 2. 将 `devflow-plugin/devflow-manifest.json` 备份至 `.devflow/backup/deprecated-devflow-manifest.json`; 3. 删除原文件。迁移指南已在 devflow-config.json 的 migration 字段中说明 |
| 验收标准 | 1. 两个文件已备份至 .devflow/backup/; 2. 原路径文件不存在; 3. validate-install.ps1 full 模式对弃用文件缺失不报 Fail（标记为 deprecated） |

### BL-292-004 风险归集门禁前置准备（TD-026 部分偿还）

| 字段 | 值 |
|------|----|
| BL-ID | BL-292-004 |
| 关联需求 | V292-004 |
| 优先级 | P2 |
| 来源 | TD-026 风险归集门禁执行不到位 |
| 描述 | 在 operations-stage-execution 的「问题跟踪记录」输出要求中增加"风险归集检查"必填章节模板。该章节要求：1. 列出本阶段发现的所有 P1+ 风险; 2. 逐项检查是否已录入技术债务总表; 3. 未录入的说明原因; 4. 记录检查结论。这是 TD-026 完整偿还的前置准备工作 |
| 验收标准 | 1. operations-stage-execution SKILL.md 中问题跟踪记录模板包含风险归集检查章节; 2. 章节包含 4 个必填项 |

---

## 优先级评估记录

| 需求 | 价值 | 成本 | 价值/成本 | 风险 | 最终优先级 |
|:-----|:----:|:----:|:---------:|:----:|:----------:|
| V292-001 | 高（消除阻塞告警） | 极低（改 1 个字段） | 极高 | 低 | P0 |
| V292-002 | 高（消除版本不一致） | 极低（改 1 个字段） | 极高 | 低 | P0 |
| V292-003 | 中（防止用户混淆） | 低（备份+删除） | 高 | 低 | P1 |
| V292-004 | 中（TD-026 前置） | 中（模板章节追加） | 中 | 低 | P2 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-23 | v2.9.2 本版本 Backlog | PM-DevFlow-Dev |
