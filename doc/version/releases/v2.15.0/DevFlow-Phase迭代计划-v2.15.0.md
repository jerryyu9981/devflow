# DevFlow Phase 迭代计划 — v2.15.0

> 文档类型：Phase 迭代计划
> 版本：v2.15.0
> 状态：[Draft]
> 日期：2026-08-01
> 作者：PM-DevFlow-Dev

---

## 说明

本计划将 v2.15.0 版本 Backlog 拆分为 3 个 Phase，每个 Phase 可独立推进和验证。Phase 间存在依赖关系，需按顺序执行。

---

## Phase 总览

| Phase | 主题 | 包含 BL-ID | 工作量 | 依赖 | 状态 |
|:------:|:-----|:-----------|:------:|:-----|:----:|
| Phase 1 | P0 核心：T1-T4 架构骨架 + 版本号治理 | BL-215-001（部分）+ BL-215-004 | ~125 行 | 无 | 📋 待开始 |
| Phase 2 | P1 配套：T1-T4 完整集成 + v1.4.0 增强 + 产出物门禁 | BL-215-001（剩余）+ BL-215-002 + BL-215-003 | ~437 行 | Phase 1 | 📋 待开始 |
| Phase 3 | P2 收尾：Git hook 规范化 + 发布 | BL-215-005 + 版本发布 | ~50 行 | Phase 2 | 📋 待开始 |

---

## Phase 1：P0 核心 — T1-T4 架构骨架 + 版本号治理

### 目标

完成两项 P0 需求的核心部分：T1-T4 架构层级总览和 T3a 巡检工作流（BL-215-001 核心），以及版本号单一事实源修复（BL-215-004 全量）。

### 包含任务

| 任务 | BL-ID | 描述 | 工作量 | 产出 |
|:-----|:------|:------|:------:|:-----|
| 1.1 T1-T4 层级总览章节 | BL-215-001 | 在 testing-stage-execution 中新增"T1-T4 四层测试架构"章节，包含层级总览表、层间追溯说明、项目类型适配（纯后端/全栈） | ~40 行 | testing-stage-execution SKILL.md 更新 |
| 1.2 T3a 巡检工作流 | BL-215-001 | 新增 T3a 六步闭环巡检工作流（清单盘点→自动化巡检→问题分类→根因定位→修复回归→报告更新），含 **6 类巡检信号**（v1.4.0 新增表单提交响应检测）、**关键按钮清单 7 类**（v1.4.0 补充"新建""刷新"）、**对话框清理逻辑**（v1.4.0 新增）、7 类标准问题分类（A-G 类，含 F 类静默失败检测+G 类表单提交错误被吞没）、**根因定位 6 种手段**（v1.4.0 新增 G 类"错误处理检查"） | ~55 行 | testing-stage-execution SKILL.md 更新 |
| 1.3 版本号单一事实源确立 | BL-215-004 | ① 确立 devflow-config.json 的 devflowVersion 为版本号唯一事实源 ② 删除根目录 version.json 和 .devflow/version.json ③ 从 devflow-config.json 的 deprecatedFiles 移除 version.json ④ 更新 code-version-backup-management 中版本号管理规则 ⑤ 同步安装副本（.devflow/skills/ + .trae/skills/） | ~15 行 | devflow-config.json + code-version-backup-management SKILL.md |
| 1.4 发布流程自动同步链路 | BL-215-004 | ① release.ps1 增加 JSON 配置同步步骤（devflow-config.json 的 devflowVersion → state.json） ② validate-version-header.ps1 Phase 1 检查纳入发布门禁（3 份配置） ③ 更新 sync-skills.ps1 和 download-devflow.ps1 脚本引用 | ~15 行 | release.ps1 + validate-version-header.ps1 |

### 里程碑

- M1.1：testing-stage-execution 包含 T1-T4 层级总览 + T3a 巡检工作流
- M1.2：devflow-config.json 的 devflowVersion 为唯一事实源；version.json 已删除；release.ps1 包含自动同步链路

### 验收重点

- [ ] testing-stage-execution 中可检索到"T1-T4 四层测试架构"章节标题
- [ ] T3a 六步闭环工作流完整（6 步均有标题和说明）
- [ ] 7 类标准问题分类表格存在（A/B/C/D/E/F/G 类）
- [ ] **T3a 巡检信号包含 6 类（含表单提交响应检测）**（v1.4.0）
- [ ] **关键按钮清单包含 7 类（含"新建""刷新"）**（v1.4.0）
- [ ] **巡检规范包含对话框清理逻辑代码片段**（v1.4.0）
- [ ] **根因定位包含 G 类"错误处理检查"手段**（v1.4.0）
- [ ] devflow-config.json 的 devflowVersion 包含 `_meta.sourceOfTruth=true` 标注
- [ ] devflow-config.json 的 deprecatedFiles 不再包含 version.json
- [ ] 根目录 version.json 和 .devflow/version.json 已删除
- [ ] release.ps1 包含 JSON 配置同步步骤

---

## Phase 2：P1 配套 — T1-T4 完整集成 + 产出物门禁

### 目标

完成 T1-T4 架构剩余部分（T3b 深度用例、T4 模板、四轨映射、反模式、断言分级、禁止模式、推荐断言模式、CRUD 规则、人机协同、覆盖矩阵、度量体系、覆盖缺口分析、根因映射表、改进项验收标准、术语表），路由映射表 diff 机制，以及 Stage4 产出物清单增强。

### 包含任务

| 任务 | BL-ID | 描述 | 工作量 | 产出 |
|:-----|:------|:------|:------:|:-----|
| 2.1 T3b 深度用例 + T4 模板 + 人机协同 | BL-215-001 | 新增 T3b 深度用例规范（CRUD/筛选/分页/错误态+CRUD 全覆盖硬性规则+用例设计规范）和 T4 业务流走查清单模板+人机协同定位+人工测试检查清单（5 大类）+抽样策略 | ~105 行 | testing-stage-execution SKILL.md 更新 |
| 2.2 四轨映射 + 通过标准 + 反模式 + 断言规范 | BL-215-001 | ① 四轨并行工作流映射 T 层级标注 ② 通过标准新增层间追溯校验+软断言清零+人工测试执行率 100% ③ 反模式新增 4 条 T1-T4 相关条目 ④ 增强强制测试矩阵 API 测试行 ⑤ 断言分级规范（L1/L2/L3）+ 禁止模式清单（3 种） ⑥ **推荐断言模式（L1/L2 标准代码模板）+ 断言策略速查表（6 种场景）**（v1.4.0 改动 13） | ~100 行 | testing-stage-execution SKILL.md 更新 |
| 2.3 路由映射表 diff 机制 | BL-215-002 | api-contract-management 新增：① YAML 格式路由→字段映射表定义 ② diff 脚本规范 ③ 检查清单新增"路由映射表 diff 已执行"项 | ~50 行 | api-contract-management SKILL.md 更新 |
| 2.4 Stage4 产出物清单增强 | BL-215-003 | 新增 5 项强制产出：T1-T4 层间追溯矩阵、全页面巡检问题表、UAT 走查清单、测试覆盖矩阵、测试度量报告 | ~12 行 | 产出物清单-Stage4.md 更新 |
| 2.5 测试覆盖矩阵 + 度量体系 + 覆盖缺口分析 | BL-215-001 | 新增测试覆盖矩阵（模块×用例类型）和测试度量体系（7 项指标：用例覆盖率/硬断言比例/软断言数量/巡检覆盖率/静默失败检测覆盖率/缺陷逃逸率/人工测试执行率）+ 度量报告模板 + **覆盖缺口分析方法论（缺口分析表格式+缺口分级规则 P0/P1/P2+缺口追踪闭环流程图）**（v1.4.0 改动 15） | ~115 行 | testing-stage-execution SKILL.md 更新 |
| 2.6 术语表 | BL-215-001 | 新增术语表章节（12 个核心术语：CRUD/软断言/硬断言/条件断言/存在性断言/静默失败/行为信号检测/表单提交错误被吞没/缺陷逃逸率/覆盖矩阵/覆盖缺口/巡检工具）（v1.4.0 第 10 章） | ~20 行 | testing-stage-execution SKILL.md 更新 |
| 2.7 根因映射表 + 改进项验收标准 | BL-215-001 | 新增根因映射表（4 大根因→改进项映射：测试设计原则缺失/巡检工具能力不足/测试度量缺失/人工测试定位模糊，v1.4.0 第 8.3 节）和改进项验收标准（9 项验收标准+验证方法，v1.4.0 第 8.2 节） | ~35 行 | testing-stage-execution SKILL.md 更新 |

### 里程碑

- M2.1：testing-stage-execution T1-T4 架构 18 项核心改动全部完成
- M2.2：api-contract-management 包含路由映射表 diff 机制
- M2.3：Stage4 产出物清单包含 5 项 T1-T4 强制产出
- M2.4：测试覆盖矩阵、度量体系（7 项指标）和覆盖缺口分析方法论已纳入 testing-stage-execution
- M2.5：推荐断言模式（L1/L2 标准模板）+ 断言策略速查表（6 种场景）+ 术语表（12 个核心术语）已纳入 testing-stage-execution
- M2.6：根因映射表（4 大根因→改进项）+ 改进项验收标准（9 项）已纳入 testing-stage-execution

### 验收重点

- [ ] testing-stage-execution 包含 T3b 深度用例规范（含 CRUD 全覆盖硬性规则）
- [ ] testing-stage-execution 包含 T4 业务流走查清单模板
- [ ] testing-stage-execution 包含人机协同定位 + 人工测试检查清单（5 大类）+ 抽样策略
- [ ] 四轨并行工作流映射中包含 T 层级标注
- [ ] 通过标准包含"层间追溯校验"+"软断言清零"+"人工测试执行率 100%"条目
- [ ] 反模式包含至少 4 条 T1-T4 相关条目
- [ ] 断言分级规范（L1/L2/L3）和禁止模式清单（3 种）已纳入
- [ ] **推荐断言模式（L1/L2 标准代码模板）和断言策略速查表（6 种场景）已纳入**（v1.4.0）
- [ ] 测试覆盖矩阵模板和度量体系（7 项指标）已纳入
- [ ] **覆盖缺口分析方法论（缺口分析表+分级规则+追踪闭环）已纳入**（v1.4.0）
- [ ] **术语表（≥8 个核心术语）已纳入**（v1.4.0）
- [ ] **根因映射表（4 大根因→改进项）已纳入**（v1.4.0）
- [ ] **改进项验收标准（≥9 项）已纳入**（v1.4.0）
- [ ] api-contract-management 包含路由映射表 YAML 格式定义
- [ ] 产出物清单-Stage4 包含 5 项新条目

---

## Phase 3：P2 收尾 — Git hook 规范化 + 发布

### 目标

将 Git pre-push hook 纳入 code-version-backup-management 技能规范，完成版本号更新和发布。

### 包含任务

| 任务 | BL-ID | 描述 | 工作量 | 产出 |
|:-----|:------|:------|:------:|:-----|
| 3.1 Git hook 纳入规范 | BL-215-005 | ① code-version-backup-management 新增"自动备份 hook"章节 ② 安装流程纳入 devflow-init ③ 日志规范（.devflow/logs/backup-hook.log） | ~20 行 | code-version-backup-management + devflow-init SKILL.md |
| 3.2 版本号更新 | — | 更新 devflow-config.json 的 devflowVersion 和 state.json 版本号至 2.15.0 | ~5 行 | JSON 配置文件更新 |
| 3.3 IDE 技能同步 | — | 执行 update.ps1 推送全部技能到 IDE 系统目录 | ~5 行 | IDE 技能同步验证 |
| 3.4 发布验证 | — | 执行 validate-version-header.ps1 全量检查；执行 release.ps1 发布 | ~20 行 | 发布验证记录 |

### 里程碑

- M3.1：code-version-backup-management 包含 hook 章节
- M3.2：全部 JSON 配置版本号统一为 2.15.0
- M3.3：IDE 技能同步完成并验证
- M3.4：v2.15.0 tag 创建并推送

### 验收重点

- [ ] code-version-backup-management 包含"自动备份 hook"章节
- [ ] devflow-init 安装流程包含 hook 安装步骤
- [ ] devflow-config.json 的 devflowVersion 为 2.15.0
- [ ] state.json 版本号为 2.15.0
- [ ] validate-version-header.ps1 全部检查通过
- [ ] git tag v2.15.0 已创建并推送

---

## Phase 依赖关系

```
Phase 1（P0 核心）
  ├── BL-215-001 部分（T1-T4 骨架）
  └── BL-215-004 全量（版本号治理）
       │
       ▼
Phase 2（P1 配套）
  ├── BL-215-001 剩余（T3b/T4/四轨/反模式）
  ├── BL-215-002 全量（路由映射表 diff）
  └── BL-215-003 全量（Stage4 清单）
       │
       ▼
Phase 3（P2 收尾）
  ├── BL-215-005 全量（Git hook 规范化）
  └── 版本发布（版本号更新 + IDE 同步 + tag）
```

### 依赖说明

- Phase 1 → Phase 2：T1-T4 层级总览是 T3b/T4/四轨映射的前置基础
- Phase 2 → Phase 3：所有功能需求完成后才能进行版本号更新和发布
- Phase 1 内部：BL-215-001 和 BL-215-004 可并行

---

## 资源评估

| 角色 | Phase 1 | Phase 2 | Phase 3 | 总计 |
|:-----|:--------|:--------|:--------|:-----|
| PM-DevFlow-Dev | 规范编写 + 脚本修改 | 规范编写 + 清单更新 | 规范编写 + 发布执行 | 全程 |
| 审计师 | — | — | 发布前审计 | Phase 3 |

---

## 风险与应对

| Phase | 风险 | 级别 | 应对 |
|:------:|:-----|:----:|:-----|
| Phase 1 | T1-T4 架构章节工作量超预期 | 🟡 P1 | 先完成层级总览+T3a 核心，T3b/T4 可推迟到 Phase 2 |
| Phase 1 | release.ps1 修改引入 bug | 🟢 P2 | 新增步骤前添加 dry-run 模式 |
| Phase 2 | 路由映射表 YAML 格式需迭代 | 🟡 P1 | 先定义规范模板，标注"待验证" |
| Phase 2 | v1.4.0 扩展范围增加工作量（Phase 2 总计 ~437 行，BL-215-001 Phase 2 部分 ~375 行） | 🟡 P1 | 任务 2.5（覆盖矩阵+度量体系+缺口分析）、任务 2.6（术语表）和任务 2.7（根因映射表+验收标准）可推迟到 v2.16.0；断言分级、推荐模式、CRUD 规则和巡检增强为核心改进不可推迟 |
| Phase 3 | IDE 同步可能遗漏技能 | 🟢 P2 | 同步后执行 validate-install.ps1 全量验证 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-01 | 初始创建，拆分为 3 个 Phase（P0 核心→P1 配套→P2 收尾） | PM-DevFlow-Dev |
| v1.1 | 2026-08-01 | T1-T4 架构方案升级至 v1.3.0：Phase 1 任务 1.2 问题分类从 5 类增至 6 类（+F 类静默失败）；Phase 2 新增任务 2.5（覆盖矩阵+度量体系），任务 2.1/2.2 扩展 v1.3.0 内容（断言分级/CRUD 规则/人机协同），Stage4 产出从 3 项增至 5 项；Phase 2 工作量从 ~108 行增至 ~252 行 | PM-DevFlow-Dev |
| v1.2 | 2026-08-01 | T1-T4 架构方案版本引用从 v1.3.0 更新至 v1.4.0；Phase 1 任务 1.2 问题分类从 5 类更新为 7 类（含静默失败检测+表单提交错误被吞没）；Phase 1 验收重点问题分类从 6 类（A-F）更新为 7 类（A-G）；Phase 2 里程碑核心改动从 12 项更新为 16 项 | PM-DevFlow-Dev |
| v1.3 | 2026-08-01 | 补全 v1.4.0 遗漏改进项：① 任务 2.2 补充推荐断言模式+断言策略速查表（改动 13），工作量 ~50→~80 行 ② 任务 2.5 补充覆盖缺口分析方法论（改动 15），工作量 ~60→~90 行 ③ 新增任务 2.6 术语表（12 个核心术语），~15 行 ④ Phase 2 工作量从 ~252 行更新为 ~327 行 ⑤ 新增里程碑 M2.5 ⑥ 验收重点补充 3 项 v1.4.0 检查项 | PM-DevFlow-Dev |
| v1.4 | 2026-08-01 | 补全 v1.4.0 改动 14 遗漏子项 + 新增改动 8.2/8.3：① 任务 1.2 补全 6 类巡检信号（含表单提交响应检测）、关键按钮清单 7 类、对话框清理逻辑、根因定位 G 类"错误处理检查"，工作量 ~40→~55 行 ② 新增任务 2.7 根因映射表+改进项验收标准（~25 行）③ Phase 1 工作量 ~110→~125 行，Phase 2 工作量 ~327→~352 行 ④ 里程碑 M2.1 从 16 项更新为 18 项，新增 M2.6 ⑤ Phase 1 验收重点补充 4 项 v1.4.0 检查项，Phase 2 验收重点补充 2 项 ⑥ 风险表 Phase 2 工作量更新 | PM-DevFlow-Dev |
| v1.5 | 2026-08-01 | 审计发现项 A-001/A-002 修复：① 任务 1.3/1.4 工作量从 ~10→~15 行（BL-215-004 Phase 1 合计 20→30 行，与 Backlog 对齐），补全安装副本同步和脚本更新描述 ② 任务 2.1 ~80→~105 行，任务 2.2 ~80→~100 行，任务 2.5 ~90→~115 行，任务 2.6 ~15→~20 行，任务 2.7 ~25→~35 行（BL-215-001 Phase 2 合计 290→375 行，与 Backlog 对齐）③ Phase 2 总工作量 ~352→~437 行 ④ 风险表 Phase 2 工作量更新 ⑤ Phase 1 子任务和(125)与声明总计(125)一致，A-002 修复 ⑥ BL-215-001 Phase 合计(95+375=470)与 Backlog(470)一致，A-001 修复 | AU-DevFlow-Dev |
| v1.6 | 2026-08-02 | TD-215-006 修正：任务 1.2 根因定位手段计数从 7 种更正为 6 种（D-001 缺陷修复） | AD-DevFlow-Dev |
