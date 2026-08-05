# DevFlow v2.10.1 设计与变更方案

> 文档类型：系统架构设计文档
> 版本：v2.10.1
> 日期：2026-07-26

---

## 1. 设计概述

本版本为修订版（发布规范化 + 遗留治理），不涉及新功能开发。所有修改均为文档/配置/流程类变更，涉及技能文档的章节增补、文件重命名、引用路径同步和流程规则增强。

### 1.1 变更分类

| 变更类型 | 涉及数量 | 说明 |
|:---------|:--------:|:------|
| 文件重命名 | 1 个 | `.devflow/config.json → .devflow/project-config.json` |
| 技能文档修改 | 3 个 | `operations-stage-execution`（发布门禁 + Release Checklist）、`code-version-backup-management`（§5.0 章节） |
| 文档模板修改 | 24 个 | 全局模板文件名 `{项目名}-` 变量替换 |
| SKILL.md 副本同步 | 5 个 | `.trae/skills/` 下副本的路径引用更新 |
| 文档内容追加 | 2 个 | 技术债务总表修订历史；候选需求池同步检查 |

### 1.2 核心原则

- **向后兼容**：config.json 改名后，旧路径检测到自动创建符号链接或迁移提示
- **变量化**：所有硬编码 `DevFlow-` 项目名前缀改为 `{项目名}` 变量引用
- **门禁先行**：用户指南/手册门禁先加到发布交付物，再更新文档内容

---

## 2. 影响范围分析

### 2.1 文件维度

| 文件/目录 | V2100-004 | V2100-005 | V2100-006 | V2100-009 | V2100-007 | V2100-008 |
|:----------|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|
| `.devflow/config.json` | 🔴 改名 | — | — | — | — | — |
| `devflow-plugin/skills/L2/operations-stage-execution.md` | ⚠️ 路径引用 | — | 🔴 核心 | 🔴 核心 | — | 🔴 核心 |
| `.trae/skills/operations-stage-execution/SKILL.md` | ⚠️ 路径引用 | — | 🔴 | 🔴 | — | 🔴 |
| `devflow-plugin/skills/L3/code-version-backup-management.md` | — | 🔴 核心 | — | — | — | — |
| `.trae/skills/code-version-backup-management/SKILL.md` | — | 🔴 | — | — | — | — |
| `doc/version/global/DevFlow-技术债务总表.md` | — | — | — | — | 🔴 核心 | — |
| 24 个模板文件 `devflow-plugin/templates/*.md` | 🔴 全部 | — | — | — | — | — |
| 6 个 L2 技能中硬编码的 `DevFlow-` 路径 | 🔴 全部 | — | — | — | — | — |
| `devflow-config.json` 中 `skills[].source` 路径 | 🔴 更新 | — | — | 🔴 更新 | — | — |

### 2.2 技能文档引用路径盘点

需更新 `DevFlow-` → `{项目名}` 引用的文件（约 15~20 处）：

```
devflow-plugin/skills/L2/operations-stage-execution.md
devflow-plugin/skills/L3/code-version-backup-management.md
devflow-plugin/.trae/skills/operations-stage-execution/SKILL.md
devflow-plugin/.trae/skills/code-version-backup-management/SKILL.md
devflow-plugin/devflow-config.json (skills[].source 字段)
```

---

## 3. 变更执行计划

### 3.1 执行顺序

```
Phase 1：发布规范化核心
  1a. config.json 改名（含引用盘点 → 执行改名 → 更新引用路径）
  1b. 发布产物命名标准化（operations-stage-execution 中路径更新）
  1c. 远程备份规范定稿（code-version-backup-management §5.0 追加）
  1d. 用户指南门禁（operations-stage-execution 发布交付物 + Release Checklist）

Phase 2：遗留治理补充
  2a. 技术债务总表修订历史章节
  2b. 跨阶段同步机制（operations-stage-execution 复盘阶段）
  2c. 全局模板 `{项目名}` 变量替换
```

### 3.2 向后兼容策略

| 场景 | 策略 |
|:-----|:------|
| 项目使用旧 `.devflow/config.json` | devflow-init 检测旧文件，自动迁移至 project-config.json |
| 旧版本技能引用 `DevFlow-` 前缀 | 保持向后兼容，新版本使用变量，旧版本不变 |
| Release Note 使用旧命名 `DevFlow-Release-Note-` | 过渡期两个命名都接受，新版本强制使用 `{项目名}` |

---

## 4. 各需求详细设计

### 4.1 DT-2101-001：跨项目文件命名（V2100-004 + TD-029）

**现状**：`.devflow/config.json` 仍使用旧名，24 个模板和 6 个 L2 技能硬编码 `DevFlow-` 前缀。

**方案**：
```
步骤 1：重命名 .devflow/config.json → .devflow/project-config.json
步骤 2：更新 devflow-config.json 中 skills[].source 路径（.devflow/config.json → .devflow/project-config.json）
步骤 3：更新 6 个 L2 技能文档中 .devflow/config.json 的引用路径
步骤 4：更新 5 个 SKILL.md 副本中同步的引用路径
步骤 5：更新 24 个模板文件，`DevFlow-` 前缀改为 {项目名}-
步骤 6：验证 rename-registry（旧路径可被检测，新路径正常使用）
```

**风险**：config.json 被 `devflow-init` 和 `devflow-phase-manager` 的 `devflow-project-config` 技能引用。需要确认 `devflow-project-config` 中读取的路径统一更新。

**验收**：`LS .devflow/` → 无 `config.json`，有 `project-config.json`；`Grep "\.devflow/config\.json"` → 无匹配。

### 4.2 DT-2101-002：远程仓库备份规范（V2100-005）

**现状**：三远程架构（origin/backup/github）已在 `release.ps1` 和 `code-version-backup-management` 中部分实现，GitHub URL 已改为 `{username}` 变量。

**方案**：
```
步骤 1：验证 code-version-backup-management.md 中 §5.0 章节已完整（三远程表格 + 推送命令 + Tag 验证）
步骤 2：验证 SKILL.md 副本已同步
步骤 3：验证 release.ps1 中 Step 4c（github 推送）和 github Tag 验证已实现
```

**验收**：三远程架构图、URL 模板表、推送命令、Tag 同步验证命令在技能文档中完整定义。

### 4.3 DT-2101-003：用户指南/手册纳入发布门禁（V2100-006）

**现状**：`DevFlow-用户指南.html` 和 `DevFlow-用户手册.html` 完全游离在标准化流程之外。

**方案**：
```
修改位置：devflow-plugin/skills/L2/operations-stage-execution.md
           devflow-plugin/.trae/skills/operations-stage-execution/SKILL.md

修改 1：发布交付物门禁 → 新增第 3 项
  "3. `DevFlow-用户指南.html` 和 `DevFlow-用户手册.html` — 项目根目录，
       版本号更新至最新，内容与发布版本同步"
   → 缺失则版本不得标记为"已发布"

修改 2：Release Checklist 发布后 → 新增 2 项
  "- [ ] 用户指南已更新 — 验证命令：grep DevFlow-用户指南.html 中版本号已更新至当前版本"
  "- [ ] 用户手册已更新 — 验证命令：grep DevFlow-用户手册.html 中版本号已更新至当前版本"

修改 3：5.11b 证据审计 → 11 项 → 13 项（+2），加倍复核范围同步扩大
```

### 4.4 DT-2101-004：技术债务总表修订历史（V2100-007）

**现状**：总表每次被 6 个阶段独立修改，无变更记录，后改可能覆盖先改。

**方案**：
```
修改位置：doc/version/global/DevFlow-技术债务总表.md

追加"修订历史"表格（与现有 §修订历史 合并增强）：
| 修改日期 | 修改阶段 | TD-ID | 修改类型 | 责任人 |
|:--------:|:--------:|:-----:|:---------|:------|
| 2026-07-26 | Step 0 | TD-029 | 新增 | PM-DevFlow-Dev |

每次修改必须追加一行，修改类型包括：新增/偿还/升级/挂起/更新字段。
```

### 4.5 DT-2101-005：跨阶段同步机制（V2100-008）

**现状**：候选需求池、版本规划总纲、版本迭代路线图仅在 Step 0 创建，后续阶段的变更不反馈。

**方案**：
```
修改位置：devflow-plugin/skills/L2/operations-stage-execution.md

在 Release Checklist 发布后区域追加 1 项：
"- [ ] 候选需求池状态已同步 — 验证方式：检查候选需求池中已纳入/已延期条目与实际一致"
```

### 4.6 DT-2101-006：发布产物标准化命名（V2100-009）

**现状**：Release Note 硬编码为 `DevFlow-Release-Note-v{版本号}.md`，Changelog 使用 `doc/release/README.md`。

**方案**：
```
修改位置：operations-stage-execution.md（源 + SKILL.md 副本）

① 发布交付物门禁：
  "`DevFlow-Release-Note-v{版本号}.md`" → "`{项目名}-Release-Note-v{版本号}.md`"
  "`doc/release/README.md`" → "`{项目名}-Release-Note-All.md`"

② Release Checklist：
  "DevFlow-Release-Note-v{版本号}.md" → "{项目名}-Release-Note-v{版本号}.md"
```

### 4.7 DT-2101-007：TD-028 状态更新

**方案**：在技术债务总表中将 TD-028 标记为"已偿还"，计划偿还版本更新为 v2.10.1。

---

## 5. 变更波及清单

| 需求 | 涉及技能文件 | 涉及脚本 | 涉及文档 |
|:-----|:------------|:---------|:---------|
| V2100-004 | 6 个 L2 技能文档 + 5 个 SKILL.md 副本 | devflow-init 读取路径更新 | 24 个模板 + devflow-config.json |
| V2100-005 | `code-version-backup-management.md` + 副本 | release.ps1（已实施） | — |
| V2100-006 | `operations-stage-execution.md` + 副本 | — | — |
| V2100-009 | `operations-stage-execution.md` + 副本 | — | — |
| V2100-007 | — | — | 技术债务总表 |
| V2100-008 | `operations-stage-execution.md` + 副本 | — | — |
