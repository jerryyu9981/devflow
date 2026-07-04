# DevFlow 测试用例 v2.5.0

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| 项目名 | DevFlow — 软件开发工程规范插件 |
| 版本 | v2.5.0 |
| 状态 | 草稿 |
| 日期 | 2026-07-04 |
| 负责人 | jerry.yu |
| 测试环境 | Windows, PowerShell 5, devflow-plugin-v2.4.0 目录 |
| 待测分支 | master |

### 修订历史

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| v2.5.0 | 2026-07-04 | jerry.yu | 初始版本 |

---

## 2. 测试用例

> **说明**：本版本测试用例覆盖 FR-001（远程仓库交互式配置）、FR-003（性能工程技能）、FR-004（数据库迁移管理技能）、L2 速查表更新及回归测试。

---

### DT-001: devflow-init 远程仓库交互式配置（FR-001, P1）

| TC-ID | 测试项 | 前置条件 | 测试步骤 | 预期结果 | 关联 AC | 优先级 |
|---|---|---|---|---|---|---|
| TC-001 | 远程仓库配置章节存在 | — | Select-String "远程仓库配置引导" devflow-init/SKILL.md | 找到匹配行 | AC-013 | P1 |
| TC-002 | DevFlow 下载地址与项目地址区分说明 | — | Select-String "DevFlow 下载地址" devflow-init/SKILL.md | 找到区分说明 | AC-014 | P1 |
| TC-003 | origin 输入引导步骤 | — | Select-String "Step A" devflow-init/SKILL.md | 找到 Step A 说明 | AC-015 | P1 |
| TC-004 | backup 输入引导步骤 | — | Select-String "Step B" devflow-init/SKILL.md | 找到 Step B 说明 | AC-015 | P1 |
| TC-005 | URL 校验规则说明 | — | Select-String "校验规则" devflow-init/SKILL.md | 找到校验规则 | AC-014 | P1 |
| TC-006 | config.json 写入说明 | — | Select-String "remote.origin" devflow-init/SKILL.md | 找到写入说明 | AC-016 | P1 |
| TC-007 | 空值跳过说明 | — | Select-String "留空" devflow-init/SKILL.md | 找到空值处理说明 | AC-015 | P1 |
| TC-008 | 变更记录更新 | — | Select-String "VR-019" devflow-init/SKILL.md | 找到变更记录条目 | AC-016 | P1 |

---

### DT-003: 性能工程技能（FR-003, P2）

| TC-ID | 测试项 | 前置条件 | 测试步骤 | 预期结果 | 关联 AC | 优先级 |
|---|---|---|---|---|---|---|
| TC-009 | 文件存在 | — | Test-Path skills/L3/performance-engineering.md | 文件存在 | AC-005 | P2 |
| TC-010 | 性能需求定义章节 | — | Select-String "性能需求定义" | 找到匹配行 | AC-006 | P2 |
| TC-011 | 性能测试基准章节 | — | Select-String "性能测试基准" | 找到匹配行 | AC-006 | P2 |
| TC-012 | 性能瓶颈分析章节 | — | Select-String "性能瓶颈分析" | 找到匹配行 | AC-006 | P2 |
| TC-013 | 性能优化决策树章节 | — | Select-String "性能优化决策树" | 找到匹配行 | AC-006 | P2 |
| TC-014 | 容量规划章节 | — | Select-String "容量规划" | 找到匹配行 | AC-006 | P2 |

---

### DT-006: 数据库迁移管理技能（FR-004, P2）

| TC-ID | 测试项 | 前置条件 | 测试步骤 | 预期结果 | 关联 AC | 优先级 |
|---|---|---|---|---|---|---|
| TC-015 | 文件存在 | — | Test-Path skills/L3/database-migration.md | 文件存在 | AC-009 | P2 |
| TC-016 | Schema 版本管理章节 | — | Select-String "Schema 版本管理" | 找到匹配行 | AC-010 | P2 |
| TC-017 | 迁移脚本编写规范 | — | Select-String "迁移脚本编写" | 找到匹配行 | AC-011 | P2 |
| TC-018 | 回滚策略章节 | — | Select-String "回滚策略" | 找到匹配行 | AC-011 | P2 |
| TC-019 | 多环境迁移章节 | — | Select-String "多环境迁移" | 找到匹配行 | AC-011 | P2 |
| TC-020 | 数据一致性校验章节 | — | Select-String "数据一致性校验" | 找到匹配行 | AC-011 | P2 |
| TC-021 | MySQL 支持 | — | Select-String "MySQL" | 找到匹配行 | AC-012 | P2 |
| TC-022 | PostgreSQL 支持 | — | Select-String "PostgreSQL" | 找到匹配行 | AC-012 | P2 |
| TC-023 | MongoDB 支持 | — | Select-String "MongoDB" | 找到匹配行 | AC-012 | P2 |

---

### DT-004+005: L2 速查表更新（FR-003, P2）

| TC-ID | 测试项 | 前置条件 | 测试步骤 | 预期结果 | 关联 AC | 优先级 |
|---|---|---|---|---|---|---|
| TC-024 | coding-stage 速查表引用 | — | Select-String "performance-engineering" coding-stage-execution.md | 找到匹配行 | AC-007 | P2 |
| TC-025 | testing-stage 速查表引用 | — | Select-String "performance-engineering" testing-stage-execution.md | 找到匹配行 | AC-007 | P2 |

---

### 回归测试

| TC-ID | 测试项 | 前置条件 | 测试步骤 | 预期结果 | 关联 AC | 优先级 |
|---|---|---|---|---|---|---|
| TC-026 | v2.4.1 validate-install.ps1 | — | Select-String "versionJsonExists" validate-install.ps1 | 修复仍存在 | 回归 | P1 |
| TC-027 | v2.4.1 L3 偏执级检查 | — | Select-String "偏执级检查" code-logic-review.md | 修复仍存在 | 回归 | P1 |
| TC-028 | v2.4.1 TDD 合规行 | — | Select-String "TDD合规" testing-stage-execution.md | 修复仍存在 | 回归 | P1 |
| TC-029 | v2.4.1 AutoFill 参数 | — | Select-String "AutoFill" check-skill-format.ps1 | 修复仍存在 | 回归 | P1 |

---

## 3. 用例统计

| 指标 | 数值 |
|------|------|
| 总用例数 | 29 条 |
| P1 用例 | 9 条（TC-001~008 + TC-026~029） |
| P2 用例 | 17 条（TC-009~025） |
| 回归用例 | 4 条（TC-026~029） |

### 需求追溯

| 需求 | 用例数 | 用例编号 |
|------|--------|----------|
| FR-001 | 8 条 | TC-001~008 |
| FR-003 | 10 条 | TC-009~014, TC-024~025 |
| FR-004 | 9 条 | TC-015~023 |
| 回归 | 4 条 | TC-026~029（有重叠） |

---

## 变更记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| v2.5.0 | 2026-07-04 | jerry.yu | 初始版本 |
