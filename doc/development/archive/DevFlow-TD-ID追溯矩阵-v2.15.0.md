# DevFlow TD-ID 追溯矩阵 — v2.15.0

> 文档类型：设计开发追溯矩阵
> 版本：v2.15.0
> 日期：2026-08-02
> 作者：AD-DevFlow-Dev（开发工程师）

---

## 1. 追溯链路说明

```
需求追溯矩阵 RT-ID（Step 1）
  → 设计追溯矩阵 DT-ID（Step 2）
    → 开发追溯矩阵 TD-ID（Step 3，本文件）
      → 涉及文件 + 子任务
```

---

## 2. TD-ID 追溯矩阵

| TD-ID | DT-ID | RT-ID | 需求标题 | 涉及文件 | 子任务数 | 优先级 | 状态 |
|:------|:------|:------|:---------|:---------|:--------:|:------:|:----:|
| TD-215-001 | DT-215-001 | RT-215-001 | T1-T4 四层测试架构集成 | `testing-stage-execution/SKILL.md` | 15 | 🔴 P0 | ✅ |
| TD-215-002 | DT-215-002 | RT-215-002 | 路由映射表 diff 机制 | `api-contract-management/SKILL.md` | 3 | 🟡 P1 | ✅ |
| TD-215-003 | DT-215-003 | RT-215-003 | Stage4 产出物清单新增 | `doc/audit/checklist/DevFlow-产出物清单-Stage4-v2.13.0.md` | 1 | 🟡 P1 | ✅ |
| TD-215-004 | DT-215-004 | RT-215-004 | 版本号单一事实源落地 | `release.ps1` + `validate-version-header.ps1` | 2 | 🔴 P0 | ✅ |
| TD-215-005 | DT-215-005 | RT-215-005 | Git hook 纳入规范 | `code-version-backup-management/SKILL.md` + `devflow-init/SKILL.md` | 2 | 🟢 P2 | ✅ |
| TD-215-006 | — | — | D-001 修正：根因定位手段计数 | `Backlog-v2.15.0.md` + `Phase迭代计划-v2.15.0.md` | 2 | ⚠️ 低 | ✅ |
| TD-215-007 | — | — | D-002 修正：devflow-init 编号重复 | `devflow-init/SKILL.md` | 1 | ℹ️ 信息 | ✅ |

> TD-215-006 和 TD-215-007 为设计评审发现项的修正任务，不对应 RT-ID 但需在 Step 3 完成。

---

## 3. Subtask CheckList

### TD-215-001: T1-T4 四层测试架构集成（15 项子任务）

| 序号 | 子任务 | 涉及文件 | 设计位置 | 状态 |
|:----:|:-------|:---------|:---------|:----:|
| ① | 新增 `## T1-T4 四层测试架构` 章节（层级总览+层间追溯+项目类型适配+不适用声明） | testing-stage-execution/SKILL.md | §4.2 序号① | ✅ |
| ② | 增强 `## 强制测试矩阵` API 测试行（三要素校验+显式声明） | testing-stage-execution/SKILL.md | §4.2 序号② | ✅ |
| ③ | 新增 `### T3 两档分层规范`（T3a 巡检六步闭环+T3b 深度用例） | testing-stage-execution/SKILL.md | §4.2 序号③ | ✅ |
| ④ | 新增 T3a 巡检信号和问题分类（6 类信号+7 类分类+6 种根因+7 类按钮+对话框清理） | testing-stage-execution/SKILL.md | §4.2 序号④ | ✅ |
| ⑤ | 新增 `### T4 业务流走查规范`（走查清单+人机协同+人工测试检查清单+抽样策略） | testing-stage-execution/SKILL.md | §4.2 序号⑤ | ✅ |
| ⑥ | 增强 `## 内部工作流` 四轨并行映射 T 层级 | testing-stage-execution/SKILL.md | §4.2 序号⑥ | ✅ |
| ⑦ | 增强 `## 通过标准`（+3 条：层间追溯+软断言清零+人工测试执行率） | testing-stage-execution/SKILL.md | §4.2 序号⑦ | ✅ |
| ⑧ | 增强 `## 反模式`（+4 条 T1-T4 相关） | testing-stage-execution/SKILL.md | §4.2 序号⑧ | ✅ |
| ⑨ | 新增 `### 断言分级规范`（L1/L2/L3+禁止模式 3 种+推荐模式+速查表） | testing-stage-execution/SKILL.md | §4.2 序号⑨ | ✅ |
| ⑩ | 新增 `### CRUD 全覆盖规则`（管理类模块 C+R+U+D≥3+用例设计规范） | testing-stage-execution/SKILL.md | §4.2 序号⑩ | ✅ |
| ⑪ | 新增 `### 测试覆盖矩阵与度量体系`（模块×用例矩阵+7 指标+覆盖缺口分析） | testing-stage-execution/SKILL.md | §4.2 序号⑪ | ✅ |
| ⑫ | 新增 `## 术语表`（12 个核心术语） | testing-stage-execution/SKILL.md | §4.2 序号⑫ | ✅ |
| ⑬ | 新增 `### 根因映射表与改进项`（4 大根因→改进项+9 项验收标准） | testing-stage-execution/SKILL.md | §4.2 序号⑬ | ✅ |
| ⑭ | 同步安装副本（.devflow/skills/ + .trae/skills/） | 安装副本目录 | — | ✅ |
| ⑮ | 同步 L2 层级副本（skills/L2/testing-stage-execution.md） | skills/L2/ 目录 | — | ✅ |

### TD-215-002: 路由映射表 diff 机制（3 项子任务）

| 序号 | 子任务 | 涉及文件 | 设计位置 | 状态 |
|:----:|:-------|:---------|:---------|:----:|
| ① | 新增 `#### 路由映射表 diff 机制`（YAML 格式定义+示例） | api-contract-management/SKILL.md | §5.2 序号① | ✅ |
| ② | 新增 diff 脚本规范（输入/输出/执行方式） | api-contract-management/SKILL.md | §5.2 序号② | ✅ |
| ③ | 检查清单增强（+1 项：路由映射表 diff 已执行） | api-contract-management/SKILL.md | §5.2 序号③ | ✅ |

### TD-215-003: Stage4 产出物清单新增（1 项子任务）

| 序号 | 子任务 | 涉及文件 | 设计位置 | 状态 |
|:----:|:-------|:---------|:---------|:----:|
| ① | 新增 5 项强制产出（层间追溯矩阵/巡检问题表/UAT走查清单/覆盖矩阵/度量报告） | DevFlow-产出物清单-Stage4-v2.13.0.md | §6.2 | ✅ |

### TD-215-004: 版本号单一事实源落地（2 项子任务）

| 序号 | 子任务 | 涉及文件 | 设计位置 | 状态 |
|:----:|:-------|:---------|:---------|:----:|
| ① | release.ps1 新增 JSON 配置同步步骤（devflow-config.json → state.json） | release.ps1 | §7.2 | ✅ |
| ② | validate-version-header.ps1 纳入发布门禁（release.ps1 调用验证脚本） | release.ps1 | §7.3 | ✅ |

### TD-215-005: Git hook 纳入规范（2 项子任务）

| 序号 | 子任务 | 涉及文件 | 设计位置 | 状态 |
|:----:|:-------|:---------|:---------|:----:|
| ① | code-version-backup-management 新增 `### 5.4 自动备份 Hook 规范化（v2.15.0+）` | code-version-backup-management/SKILL.md | §8.2 | ✅ |
| ② | devflow-init 安装流程纳入 hook 安装步骤增强 | devflow-init/SKILL.md | §8.3 | ✅ |

### TD-215-006: D-001 修正（2 项子任务）

| 序号 | 子任务 | 涉及文件 | 设计位置 | 状态 |
|:----:|:-------|:---------|:---------|:----:|
| ① | Backlog BL-215-001 "7 种"→"6 种" | DevFlow-本版本Backlog-v2.15.0.md | D-001 | ✅ |
| ② | Phase 计划 "7 种"→"6 种" | DevFlow-Phase迭代计划-v2.15.0.md | D-001 | ✅ |

### TD-215-007: D-002 修正（1 项子任务）

| 序号 | 子任务 | 涉及文件 | 设计位置 | 状态 |
|:----:|:-------|:---------|:---------|:----:|
| ① | devflow-init `### 1.5.5`（第 108 行）改为 `### 1.5.6` | devflow-init/SKILL.md | D-002 | ✅ |

---

## 4. 版本控制记录

| 项目 | 内容 |
|:-----|:------|
| 分支策略 | git-flow（feature 分支开发，develop 集成） |
| Commit 格式 | `type(scope): subject` — footer 引用 RT-ID |
| Commit 类型 | feat（F1-F5 功能实现）/ fix（D-001/D-002 修正） |
| RT-ID 引用约定 | 每次提交 footer 包含 `RT-215-XXX` 或 `D-00X` |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-02 | 初始创建，7 条 TD-ID，26 项子任务 | AD-DevFlow-Dev |
| v1.1 | 2026-08-02 | 3.3a 编码完成：7 条 TD-ID 全部 ✅，26 项子任务全部 ✅。F1-F5 功能实现 + D-001/D-002 修正完成 | AD-DevFlow-Dev |
