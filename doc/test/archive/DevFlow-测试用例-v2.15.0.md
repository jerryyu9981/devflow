# DevFlow 测试用例 — v2.15.0

> 文档类型：测试用例
> 版本：v2.15.0
> 日期：2026-08-02
> 作者：AT-DevFlow-Dev（API测试工程师）

---

## 测试用例清单

| TT-ID | 关联 RT-ID | 关联 TD-ID | 测试类型 | T 层级 | 描述 | 验证方法 | 预期结果 | 状态 |
|:-----:|:----------:|:----------:|:---------|:------:|:-----|:---------|:---------|:----:|
| TT-215-001 | RT-215-001 | TD-215-001 | 文档完整性 | T4 | T1-T4 四层架构章节存在 | Grep testing-stage-execution/SKILL.md "## T1-T4 四层测试架构" | 章节存在 | ✅ |
| TT-215-002 | RT-215-001 | TD-215-001 | 文档完整性 | T4 | T1-T4 子章节完整性 | Grep "断言分级规范" + "CRUD 全覆盖" + "术语表" + "根因映射表" | 4 项子章节全部存在 | ✅ |
| TT-215-003 | RT-215-001 | TD-215-001 | 文档完整性 | T4 | 层间追溯要求表完整 | Grep "层间追溯要求" + 验证 3 条追溯维度 | T1→T2/T2→T3/T3→T4 全部存在 | ✅ |
| TT-215-004 | RT-215-002 | TD-215-002 | 文档完整性 | T4 | 路由映射表 diff 机制章节 | Grep api-contract-management/SKILL.md "路由映射表 diff 机制" | 章节存在 + YAML 格式 + diff 规范 | ✅ |
| TT-215-005 | RT-215-003 | TD-215-003 | 文档完整性 | T4 | Stage4 产出物清单新增 5 项 | 验证产出物清单序号 7-11 存在 | 5 项强制产出物全部存在 | ✅ |
| TT-215-006 | RT-215-004 | TD-215-004 | 脚本执行 | T2 | validate-version-header.ps1 执行 | 运行脚本检查 exit code | exit code = 0，零违规 | ✅ |
| TT-215-007 | RT-215-004 | TD-215-004 | 脚本集成 | T3 | release.ps1 Step 1b 调用逻辑 | Grep release.ps1 "validate-version-header" + "$LASTEXITCODE" + "exit 1" | 调用+检查+退出逻辑完整 | ✅ |
| TT-215-008 | RT-215-004 | TD-215-004 | 脚本集成 | T3 | release.ps1 Step 2c state.json 同步 | Grep release.ps1 "state.json" + "devflowVersion" + "try" + "catch" | 读取+更新+写回+错误处理完整 | ✅ |
| TT-215-009 | RT-215-005 | TD-215-005 | 文档完整性 | T4 | code-version-backup-management Hook 规范 | Grep code-version-backup-management/SKILL.md "5.4 自动备份 Hook" | 章节存在 | ✅ |
| TT-215-010 | RT-215-005 | TD-215-005 | 文档完整性 | T4 | devflow-init Hook 安装步骤 | Grep devflow-init/SKILL.md "自动备份 Hook 安装" | 安装步骤存在 | ✅ |
| TT-215-011 | — | TD-215-006 | 修正验证 | T4 | D-001 根因计数修正 | Grep Backlog + Phase 计划 "6 种" | 两份文档均为"6 种" | ✅ |
| TT-215-012 | — | TD-215-007 | 修正验证 | T4 | D-002 章节编号修正 | Grep devflow-init/SKILL.md "### 1.5.5" 计数 | 1.5.5 仅 1 处 + 1.5.6 存在 | ✅ |
| TT-215-013 | — | — | 回归测试 | T2 | validate-version-header.ps1 全量扫描 | 运行脚本全量扫描 | 490 文件零违规（+7 新增文件） | ✅ |
| TT-215-014 | — | — | 覆盖率 | T1 | RT-ID 验收标准覆盖 | 逐项检查 36 项验收标准 | 100% 覆盖 | ✅ |
| TT-215-015 | — | — | 合规测试 | T1 | 版本号一致性 + 命名规范 | devflow-config.json + 文件命名检查 | 全部合规 | ✅ |
| TT-215-016 | — | — | E2E 验证 | T3 | release.ps1 完整流程模拟 | 验证 Step 1→1b→2→2c 逻辑 | 步骤编号连续 + 逻辑完整 | ✅ |

---

## 测试用例详细描述

### TT-215-001: T1-T4 四层架构章节存在

- **前置条件**：testing-stage-execution/SKILL.md 文件存在
- **测试步骤**：
  1. 读取 testing-stage-execution/SKILL.md
  2. 搜索 "## T1-T4 四层测试架构" 标题
  3. 验证层级总览表包含 T1/T2/T3/T4 四层定义
- **预期结果**：章节存在，四层定义完整（T1契约层/T2接口层/T3页面集成层/T4验收层）

### TT-215-002: T1-T4 子章节完整性

- **前置条件**：TT-215-001 通过
- **测试步骤**：
  1. 搜索 "### 断言分级规范"
  2. 搜索 "CRUD 全覆盖"
  3. 搜索 "## 术语表"
  4. 搜索 "### 根因映射表"
- **预期结果**：4 项子章节全部存在

### TT-215-003: 层间追溯要求表完整

- **前置条件**：TT-215-001 通过
- **测试步骤**：
  1. 搜索 "### 层间追溯要求"
  2. 验证追溯维度表包含 3 条：T1→T2、T2→T3、T3→T4
- **预期结果**：3 条追溯维度全部存在，含覆盖率要求

### TT-215-004: 路由映射表 diff 机制章节

- **前置条件**：api-contract-management/SKILL.md 文件存在
- **测试步骤**：
  1. 搜索 "#### 路由映射表 diff 机制"
  2. 验证 YAML 格式定义包含 routes/path/method/request_fields/response_fields
  3. 验证 diff 脚本规范包含输入/输出/执行时机
  4. 验证检查清单新增"路由映射表 diff 已执行"项
- **预期结果**：章节存在，YAML 格式 + diff 规范 + 检查清单完整

### TT-215-005: Stage4 产出物清单新增 5 项

- **前置条件**：产出物清单文件存在
- **测试步骤**：
  1. 读取 DevFlow-产出物清单-Stage4-v2.13.0.md
  2. 验证新增 5 项条目（层间追溯矩阵/巡检问题表/UAT走查清单/覆盖矩阵/度量报告）
- **预期结果**：5 项强制产出物全部存在

### TT-215-006: validate-version-header.ps1 执行

- **前置条件**：脚本文件存在
- **测试步骤**：
  1. 执行 `& validate-version-header.ps1`
  2. 检查退出码
  3. 验证输出包含 Phase 1 和 Phase 2
- **预期结果**：exit code = 0，Phase 1 JSON 一致 + Phase 2 MD 一致，零违规

### TT-215-007: release.ps1 Step 1b 调用逻辑

- **前置条件**：release.ps1 文件存在
- **测试步骤**：
  1. 搜索 "validate-version-header.ps1" 调用
  2. 搜索 "$LASTEXITCODE" 检查
  3. 搜索 "exit 1" 非零退出
- **预期结果**：调用+检查+退出逻辑完整

### TT-215-008: release.ps1 Step 2c state.json 同步

- **前置条件**：release.ps1 文件存在
- **测试步骤**：
  1. 搜索 "state.json" 引用
  2. 搜索 "devflowVersion" 同步
  3. 搜索 "try" + "catch" 错误处理
- **预期结果**：读取+更新+写回+错误处理完整

### TT-215-009: code-version-backup-management Hook 规范

- **前置条件**：code-version-backup-management/SKILL.md 存在
- **测试步骤**：搜索 "### 5.4 自动备份 Hook 规范化"
- **预期结果**：章节存在

### TT-215-010: devflow-init Hook 安装步骤

- **前置条件**：devflow-init/SKILL.md 存在
- **测试步骤**：搜索 "自动备份 Hook 安装"
- **预期结果**：安装步骤存在

### TT-215-011: D-001 根因计数修正

- **前置条件**：Backlog + Phase 计划文件存在
- **测试步骤**：
  1. 搜索 Backlog "6 种"
  2. 搜索 Phase 计划 "6 种"
  3. 验证不含"7 种"（在根因定位手段上下文中）
- **预期结果**：两份文档均为"6 种"

### TT-215-012: D-002 章节编号修正

- **前置条件**：devflow-init/SKILL.md 存在
- **测试步骤**：
  1. 搜索 "### 1.5.5" 出现次数
  2. 搜索 "### 1.5.6" 存在
- **预期结果**：1.5.5 仅 1 处 + 1.5.6 存在

### TT-215-013: 回归测试 — 全量文件扫描

- **前置条件**：validate-version-header.ps1 可执行
- **测试步骤**：运行脚本全量扫描
- **预期结果**：490 文件零违规（+7 新增文件，与 v2.14.0 回归无退化）

### TT-215-014: 覆盖率 — RT-ID 验收标准覆盖

- **前置条件**：需求文档存在
- **测试步骤**：逐项检查 36 项验收标准是否有对应测试
- **预期结果**：100% 覆盖

### TT-215-015: 合规测试 — 版本号一致性

- **前置条件**：devflow-config.json 存在
- **测试步骤**：
  1. 验证 devflow-config.json devflowVersion 字段
  2. 验证文件命名符合规范
  3. 验证文件头版本号一致
- **预期结果**：全部合规

### TT-215-016: E2E 验证 — release.ps1 流程模拟

- **前置条件**：release.ps1 文件存在
- **测试步骤**：
  1. 验证 Step 1 → Step 1b → Step 2 → Step 2c 逻辑连续
  2. 验证步骤编号无缺失
  3. 验证数据流：devflow-config.json → $configJson → state.json
- **预期结果**：步骤编号连续 + 逻辑完整 + 数据流正确

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-02 | 初始创建，16 项测试用例覆盖 5 RT-ID + 7 TD-ID | AT-DevFlow-Dev |
| v1.1 | 2026-08-02 | 测试执行完成：16 项全部 ✅ 通过，0 失败 0 跳过；TT-215-013 文件数从 483→490（+7 新增文档） | AT-DevFlow-Dev |
