---
name: "audit-agent"
description: "Independent auditor agent for DevFlow full-cycle audit. Replaces form-based verification with independent re-execution: traceability verification, deliverable inventory (including sub-step completeness), checkpoint re-execution, remote backup verification, evidence authenticity check, and report generation. Invoke before release to validate claimed vs actual results."
---

# Audit Agent（独立审计师）

## 定位

本技能作为 DevFlow 的**独立审计师**——在各阶段完成后独立重新验证关键审计点，从"形式核验"升级为"独立复审"。不替代各阶段的执行检查，而是验证"声称结果 vs 实际结果"是否一致。

参照预研报告 `DevFlow-自动化审计回溯-预研报告-v1.4.md` 的实现指引。

### 核心理念

```
各阶段 → 声称完成（自我声明）
    ↓
audit-agent → 独立复审（重新验证）
    ↓
判决：✅ 一致 → 通过      ❌ 不一致 → 标记虚假勾选，返回修正
```

### 审计能力矩阵

```
audit-agent（独立审计师）
│
├─ 能力 1：追溯链独立验证     ← AI 独立提取 ID 交叉比对
│   ├─ RT→DT（Step 2 完成后调用）
│   ├─ DT→TD（Step 3 完成后调用）
│   ├─ TT→RT（Step 4 完成后调用）
│   └─ 全链汇总（Step 5 发布时调用）
│
├─ 能力 2：产出物独立盘点     ← AI 独立 LS 目录核对
│   ├─ 各阶段完成时核对本阶段产出物
│   ├─ Step 5 全阶段汇总盘点
│   └─ 子步骤产出物完整性验证 ← 按子步骤清单逐一检查产出物存在性
│
├─ 能力 3：关键检查点复查     ← AI 独立重新执行验证命令
│   ├─ 版本号一致性（cat version.json vs Git tag）
│   ├─ 测试覆盖率（重新扫描或读取报告数据）
│   ├─ 构建验证（重新执行构建命令）
│   ├─ 远程同步（git ls-remote 各远程 Tag）
│   ├─ 仓库备份验证（git push --dry-run 检查远程连通性 + ls-remote 对比各远程 Tag 一致性）
│   └─ 随机抽查（从本阶段检查点中抽 1~2 项复现）
│
└─ 能力 4：审计报告生成       ← AI 汇总发现生成报告
    ├─ 各阶段审计记录
    └─ 全流程闭环审计报告
```

### 与传统审计的区别

| 对比维度 | 传统形式审计 | 独立审计师方案 |
|:---------|:------------|:--------------|
| **验证方式** | 检查文档内容（"有没有写"） | 独立重新执行（"结果对不对"） |
| **追溯链验证** | 人工对比追溯矩阵中的 ID | AI 从 Git log 和文件自行提取 ID 交叉比对 |
| **产出物盘点** | 人工查看目录列表 | AI 执行 LS 命令逐一盘点 |
| **子步骤完整性** | 无验证机制 | 读取技能文档提取子步骤 → LS 核对产出物 |
| **检查点复查** | 无复查机制 | 随机或全量重新执行关键验证命令 |
| **仓库备份验证** | 无验证机制 | git ls-remote 三远程 Tag 一致性验证 |
| **证据真实性** | 假设声称者为真 | 对比声称结果和实际结果，不一致则标记 |
| **审计报告** | 手工编写 Markdown | AI 汇总所有审计发现生成报告 |

---

## 触发条件

当用户提出以下需求时，调用本技能：
- 发布版本前需要审计回溯
- 检查各阶段产出物完整性和子步骤执行完整性
- 验证需求/设计/开发的追溯链是否闭环
- 重新执行版本号、构建、覆盖率等关键检查点
- 验证三远程仓库备份（origin/backup/github）Tag 一致性
- 验证声称结果与实际结果是否一致（证据真实性）
- 生成全流程闭环审计报告
- 执行季度债务审计

---

## 工作流程

```
audit-agent --version v{版本号}
└── 能力 1：追溯链验证
│   ├── git log IDs → 提取 RT-ID/TD-ID
│   ├── Read 各阶段追溯矩阵文件
│   └── 交叉比对 → 一致性报告
│
├── 能力 2：产出物盘点 + 子步骤完整性
│   ├── 读取6阶段标准产出物清单（doc/audit/checklist/ 目录）
│   ├── LS 各阶段产出目录
│   ├── 读取阶段技能文档 → 提取子步骤产出物清单
│   ├── 按标准清单逐项核对：比对各阶段实际产出物与清单要求的文件
│   ├── 非清单内文件不计入通过率
│   └── 输出"清单核对通过率 = pass/total * 100%"
│
├── 能力 3：关键检查点复查 + 仓库备份验证
│   ├── 版本号一致：cat version.json vs git tag -l
│   ├── 构建验证：重新执行构建/编译命令
│   ├── 远程同步：git ls-remote origin/backup/github
│   ├── 仓库备份：三远程 Tag hash 一致性验证
│   └── 随机抽查：3 项 Release Checklist 验证命令
│
└── 能力 4：报告生成 + 风险归集
    ├── 合并能力 1~3 结果
    ├── 证据真实性判定 → 一致/不一致/部分一致
    ├── Read 技术债务总表 → 检查 P1+ 归集
    ├── 阶段审计时（--stage N）：Write 阶段审计报告到 doc/audit/review/
    └── 全流程审计时（--version）：聚合所有阶段报告 Write 到 doc/audit/comprehensive/
```

---

## 使用方法

### 全流程版本审计
```text
audit-agent --version v2.11.0
```

### 阶段专用审计
```text
audit-agent --stage 0 --phase 1+2     # Step 0 追溯 + 产物
audit-agent --stage 1 --phase 1+2     # Step 1 追溯 + 产物
audit-agent --stage 2 --phase 1+2+3   # Step 2 追溯 + 产物 + 检查点
audit-agent --stage 3 --phase 1+2+3   # Step 3 追溯(DT→TD) + 产物 + 检查点
audit-agent --stage 4 --phase 1+2+3   # Step 4 追溯 + 产物 + 1检查点
audit-agent --stage 5 --phase 2+3     # Step 5 产物 + 3检查点
```

### 季度审计
```text
audit-agent --quarterly 2026-Q3
```

### 部分审计
```text
audit-agent --version v2.11.0 --phase 1
audit-agent --version v2.11.0 --phase 2
audit-agent --version v2.11.0 --phase 3
```

---

## 能力 1：追溯链独立验证

能力 1 有两个数据源：
- **必选**：各阶段追溯矩阵文档（步骤 1）
- **可选**：Git log commit message（步骤 1b，仅在 Git 可用时执行额外交叉验证）

### 步骤 1 — 读取追溯矩阵（必选）

```text
[TOOL] Read(doc/requirements/DevFlow-需求追溯矩阵-{version}.md)       → RT-ID 集合
[TOOL] Read(doc/development/DevFlow-TD-ID追溯矩阵-{version}.md)       → TD-ID 集合
[TOOL] Read(doc/design/DevFlow-设计评审记录-{version}.md)              → DT-ID 集合
[TOOL] Read(doc/testing/DevFlow-测试报告-{version}.md)                 → TT-ID 集合
[TOOL] Grep(testing report, pattern: TT-{version}-\\d{3})
[EXPECTED] 各阶段文档中的 ID 清单
```

### 步骤 1b — 提取 Git log IDs（可选，仅 Git 可用时执行）

```text
[TOOL] RunCommand(git log --oneline v{version})
[EXPECTED] list of commits with footers containing RT-{version}-XXX / DT-{version}-XXX

[TOOL] Grep(commit messages, pattern: RT-{version}-\\d{3}|DT-{version}-\\d{3}|TD-{version}-\\d{3}|TT-{version}-\\d{3})
[EXPECTED] extracted ID list from commit history
[FALLBACK] Git 命令失败 → 跳过本步骤，报告中标记"Git 不可用"，不阻塞后续审计
```

### 步骤 2 — 交叉比对

Each inter-stage traceability pair is independently verified:

```text
Stage 2: RT-ID → DT-ID 对照
  └─ Read 需求追溯矩阵 RT-ID list
  └─ Read 设计评审记录 DT-ID list
  └─ 每项 RT-ID 是否有至少 1 个对应的 DT-ID？→ ✅/❌

Stage 3: DT-ID → TD-ID 对照
  └─ Read 设计评审记录 DT-ID list
  └─ Read TD-ID 追溯矩阵 TD-ID list
  └─ 每项 DT-ID 是否有至少 1 个对应的 TD-ID？→ ✅/❌

Stage 4: TT-ID → RT-ID 对照
  └─ Read 测试报告 TT-ID list
  └─ Read 需求追溯矩阵 RT-ID list
  └─ 每项 TT-ID 是否关联到对应的 RT-ID？→ ✅/❌

Stage 5: 全链汇总
  └─ 合并 RT→DT→TD→TT 四段链条，输出完整追溯链路
  └─ 输出覆盖率：{M/N*100}%
  └─ 输出断点清单：声称有但 Git 无 / Git 有但声称无
```

### 各阶段追溯链检定

| 阶段 | 检定内容 | 输出 |
|:----:|:---------|:-----|
| **Stage 2** | RT→DT | 设计覆盖率 + 缺失设计项清单 |
| **Stage 3** | DT→TD | 开发覆盖率 + 缺失开发项清单 |
| **Stage 4** | TT→RT | 测试覆盖率 + 缺失测试项清单 |
| **Stage 5** | 全链汇总 | 完整链路 + 断点清单 + 覆盖率 |

---

## 能力 2：产出物独立盘点

### 步骤 1 — 标准产出物盘点

**当指定 `--stage N` 时，只盘点该阶段；否则盘点 Step 0~5 全部。**

```text
[STAGE FILTER] 如果指定了 --stage N，仅执行该阶段的 LS 检查

Stage 0 ── LS(doc/version/releases/{version}/)
          → 应当有：单版本规划文档、本版本Backlog、Phase迭代计划、版本规划评审记录
          → 共 4 份

Stage 1 ── LS(doc/requirements/)
          → 应当有：开发需求文档、需求追溯矩阵、需求评审记录、需求基线及设计移交、需求来源与干系人
          → LS(doc/audit/assessment/)
          → 应当有：需求评估报告
          → 共 6 份

Stage 2 ── LS(doc/design/)
          → 应当有：系统架构设计文档、Agent架构设计文档、设计评审记录
          → LS(doc/audit/comprehensive/)
          → 应当有：需求架构对比审计报告
          → 共 4 份

Stage 3 ── LS(doc/development/)
          → 应当有：DevLogReport、TD-ID追溯矩阵、开发审计移交材料
          → 共 3 份

Stage 4 ── LS(doc/testing/)
          → 应当有：测试报告
          → LS(doc/audit/verification/)
          → 应当有：测试回溯对比审计报告
          → 共 2 份

Stage 5 ── LS(doc/release/)
          → 应当有：Release Note
          → LS(doc/audit/comprehensive/)
          → 应当有：全流程闭环审计报告
          → 共 2 份
```

### 步骤 2 — 子步骤产出物完整性验证（预研报告 §4.2）

从各阶段技能文档中提取子步骤及其标准产出物，与实际 LS 结果逐一比对，发现可能的跳步问题。

```text
[INPUT] 目标阶段的 L2 SKILL.md 文件
[LOGIC]
  For 每个阶段:
    1. Read 该阶段的 SKILL.md → 提取所有子步骤（如 3.4a/3.5a/3.6a 等）
    2. 提取每个子步骤的"强制产出"列中的文件名/路径
    3. LS 目标目录 → 获取实际产生的文件列表
    4. 逐一对比:
       子步骤产出物存在 ✅ → 该子步骤很可能已执行
       子步骤产出物缺失 ❌ → 该子步骤可能被跳过，标记为"待确认"

[OUTPUT] 子步骤完整性验证报告：
| 阶段 | 子步骤 | 标准产出物 | 实际存在 | 判定 |
|:----:|:-------|:----------|:--------:|:----:|
| Step 0 | 0.0a 债务审查 | 更新后的技术债务总表 | ✅/❌ | ✅ Done |
| Step 0 | 0.5 评审 | 版本规划评审记录 | ✅/❌ | ✅ Done |
| ...   | ...    | ...        | ...      | ...  |
```

**各阶段子步骤参考验证清单**：

| 阶段 | 子步骤数 | 关键验证目录 | 典型可跳过检查点 |
|:----:|:--------:|:-------------|:-----------------|
| Step 0 | 7 | `doc/version/releases/v{版本号}/` | 版本规划评审记录存在性 |
| Step 1 | 10 | `doc/requirements/` | 需求评估报告存在性 |
| Step 2 | 12 | `doc/design/` | 后端/原型/可观测性覆盖检查报告 |
| Step 3 | 12 | `doc/development/` | 静态质量检查记录、代码逻辑审查记录 |
| Step 4 | 11 | `doc/testing/` | 自测证据抽查记录、覆盖率报告 |
| Step 5 | 12 | `doc/release/` | 发布复盘报告、全流程闭环审计报告 |

---

## 能力 3：关键检查点复查

### 证据真实性判定逻辑（预研报告 §4.3）

```
对于每次复查：

[1] 读取阶段声称结果（文档/报告/Checklist）
[2] 独立重新执行验证命令
[3] 对比声称 vs 实际

    一致 ✅ → "证据真实，审计通过"
    不一致 ❌ → "证据虚假：声称{A}但实际{B}，返回修正"
    部分一致 ⚠️ → "N 项中有 M 项不一致，其余通过"
```

### 检查点 3.1 — 版本号一致性

```text
[TOOL] Read(version.json) → extract version field
[TOOL] RunCommand(git tag -l v{version})
[LOGIC] 对比 version.json 中的版本号 vs Git tag
  ✅ 一致 → 版本号确认通过
  ❌ 不一致 → 标记

[声称结果] 取自全流程闭环审计报告 or version.json
[重新执行] cat version.json + git tag -l v{version}
[对比] version.json的版本号 = Git tag 版本号？
```

### 检查点 3.2 — 构建验证

```text
[TOOL] Read(DevLogReport) → 提取构建命令
[TOOL] RunCommand(提取到的构建命令)
[LOGIC] 退出码 = 0 ✅ → 构建零错误
        退出码 ≠ 0 ❌ → 构建失败

[声称结果] DevLogReport 中记录的"构建成功"
[重新执行] 提取并执行构建命令
[对比] 退出码 = 0 vs 声称结果
```

### 检查点 3.3 — 测试覆盖率检查

```text
[TOOL] Read(测试报告) → 提取覆盖率声称值
[TOOL] Read(测试报告/覆盖率报告) → 提取实际覆盖数据
[LOGIC] 声称覆盖率 vs 实际覆盖率 → 偏差 > 5% 标记警告

[声称结果] 测试报告中"覆盖率 85%"
[重新执行] 从测试报告/覆盖率报告中读取覆盖率数据
[对比] 声称值 vs 实际值
```

### 检查点 3.4 — 远程同步 + 仓库备份验证（预研报告 §4.4）

```text
[1] 读取本地 Tag：git tag -l v{version}
[2] 获取本地 Tag 的 commit hash：git rev-parse v{version}
[3] 列出配置的远程仓库：git remote -v
[4] 对每个远程，执行 ls-remote：
      git ls-remote origin refs/tags/v{version}
      git ls-remote backup refs/tags/v{version}
      git ls-remote github refs/tags/v{version}
[5] 对比各远程返回的 commit hash：
      全部一致 ✅ → "备份完整，三远程同步"
      任一远程缺失 ❌ → 标记"备份不完整" + 输出缺失的远程名
      任一 hash 不一致 ❌ → 标记"备份异常"

[自愈建议] 对于缺失或不一致的远程，输出补推命令：
  git push {缺失远程名} v{version}
```

### 检查点 3.5 — 随机抽查（各阶段 1~2 项）

```text
[TOOL] Read(全流程闭环审计报告) → 提取 Release Checklist
[TOOL] 随机选择 1~2 项验证命令
[TOOL] RunCommand(选中的验证命令)
[LOGIC] 对比实际输出 vs Checklist 中的声称结果
```

### 各阶段检查点复查抽样

| 阶段 | # | 检查点 | 验证命令 | 声称来源 | 优先级 |
|:----:|:-:|:-------|:---------|:---------|:------:|
| **Stage 0** | 1 | 版本规划 4 份文档存在性 | LS(doc/version/releases/{version}/) | 当前阶段产出清单 | P0 |
| **Stage 0** | 2 | BL-ID 与 Backlog 一致性 | Read(追溯矩阵) vs Read(Backlog) | 版本规划评审记录 | P0 |
| **Stage 0** | 3 | 版本号格式合规 | Read(version.json) → 正则校验 v{major}.{minor}.{patch} | version.json | P1 |
| **Stage 1** | 1 | RT-ID 覆盖率（P0/P1 全覆盖） | Read(需求追溯矩阵) 逐项核对 | 需求评估报告 | P0 |
| **Stage 1** | 2 | P0/P1 验收标准完整性 | Grep(开发需求文档, pattern: 验收标准) | 开发需求文档 | P0 |
| **Stage 1** | 3 | 需求评估报告存在性 | LS(doc/audit/assessment/) | 需求评审记录 | P0 |
| **Stage 2** | 1 | DT-ID 覆盖率（由 Phase 1 覆盖） | Read(设计评审记录) 追溯矩阵 | 需求架构对比审计报告 | P0 |
| **Stage 2** | 2 | 系统架构+Agent 架构文档存在性 | LS(doc/design/) | 阶段产出清单 | P0 |
| **Stage 2** | 3 | 设计评审记录存在性 | LS(doc/design/) | 阶段产出清单 | P0 |
| **Stage 3** | 1 | 版本号一致性 | cat version.json + git tag -l v{version} | DevLogReport | P0 |
| **Stage 3** | 2 | 构建验证 | RunCommand(构建命令) → 退出码 = 0 | DevLogReport | P0 |
| **Stage 3** | 3 | DevLogReport 存在性 | LS(doc/development/) | 开发审计移交材料 | P0 |
| **Stage 4** | 1 | 测试覆盖率核查（偏差 ≤ 5%） | Read(测试报告) 提取覆盖数据 | 测试报告 | P0 |
| **Stage 4** | 2 | 测试报告存在性 | LS(doc/testing/) | 测试阶段产出 | P0 |
| **Stage 4** | 3 | 缺陷闭环状态（P0/P1 全关闭） | Read(测试报告) 缺陷章节 | 测试报告 | P0 |
| **Stage 5** | 1 | 三远程备份一致性 | git ls-remote origin/backup/github | Release Checklist | P0 |
| **Stage 5** | 2 | version→tag→lastRelease 三联校验 | Read(version.json) + git tag + Read(project-config.json) | 发布复盘记录 | P0 |
| **Stage 5** | 3 | Release Note 存在性 | LS(doc/release/) | 阶段产出清单 | P0 |
| **Stage 5** | 4 | Changelog 存在性 | LS(doc/) 或 Read 确认 | 阶段产出清单 | P0 |
| **Stage 5** | 5 | 3 项随机 Release Checklist 验证 | RunCommand(随机 3 项验证命令) | 全流程闭环审计报告 | P0 |
| **Stage 5** | 6 | 全流程闭环审计报告存在性 | LS(doc/audit/comprehensive/) | 阶段产出清单 | P0 |
| **Stage 5** | 7 | 运维审计报告存在性 | LS(doc/audit/comprehensive/) | 阶段产出清单 | P1 |

---

## 能力 4：审计报告生成 + 风险归集

### 步骤 1 — 合并发现

```text
[LOGIC] 合并能力 1~3 的结果，生成标准格式审计报告

[FORMAT]
# DevFlow 全流程闭环审计报告 — v{version}

## 审计概况
- 版本号：{version}
- 审计日期：{date}
- 追溯链覆盖率：{rate}%
- 产出物盘点：{pass_count}/{total_count}
- 检查点一致性：{match_count}/{checklist_count}

## 追溯链验证
（能力 1 输出）
各阶段追溯链裁定：
  Stage 2 RT→DT: ✅/❌
  Stage 3 DT→TD: ✅/❌
  Stage 4 TT→RT: ✅/❌
  Stage 5 全链汇总：{覆盖率}%

## 产出物盘点
（能力 2 输出）
各阶段产出物：
  Stage 0: {pass}/{total}
  Stage 1: {pass}/{total}
  Stage 2: {pass}/{total}
  Stage 3: {pass}/{total}
  Stage 4: {pass}/{total}
  Stage 5: {pass}/{total}

## 子步骤完整性验证
（能力 2 子步骤验证输出）
各阶段跳步疑点：{疑点数}

## 关键检查点复查
（能力 3 输出）
| 检查点 | 验证命令 | 声称结果 | 实际结果 | 一致性 |
|:------:|:---------|:--------:|:--------:|:------:|
| 版本号确认 | cat version.json | v{version} | {actual} | ✅/❌ |
| 构建验证 | {command} | 成功 | {actual} | ✅/❌ |
| 远程备份 | git ls-remote | 3/3 | {actual} | ✅/❌ |

## 仓库备份验证
  origin:   ✅ {hash}
  backup:   ✅ {hash} / ❌ 缺失
  github:   ✅ {hash} / ❌ 缺失
  自愈命令：git push {缺失远程} v{version}

## 风险归集检查
（Read 技术债务总表）
  本版本 P1+ 风险归集：✅/❌
  未归集 ID：{ID list}

## 证据真实性判定
  复查项数：{N}
  一致项数：{M}
  虚假项数：{K}
  通过率：{M/N*100}%

  结论：✅ 证据真实 / ⚠️ 部分不一致 / ❌ 存在虚假勾选

## 审计结论
✅ 通过 / ⚠️ 有条件通过 / ❌ 不通过
```

### 步骤 2 — 风险归集检查

```text
[TOOL] Read(doc/version/global/DevFlow-技术债务总表.md)
[TOOL] Grep(内容, pattern: 待偿还|偿还中)
[LOGIC] 筛选 P1+ 级别的待偿还条目，检查是否已归集
[OUTPUT]
| 检查项 | 结果 | 说明 |
|:-------|:----:|:-----|
| 本版本 P1+ 风险是否已归集 | ✅/❌ | 列出已归集的风险 ID |
| 未归集风险 ID 及原因 | 无 / {ID}: {原因} |
```

### 步骤 3 — 写入审计报告

**阶段审计输出**（指定 `--stage N` 时）：

```text
[TOOL] Write(doc/audit/review/DevFlow-阶段审计报告-Stage{v2.12.0}.md)
[CONTENT] 仅含当前阶段的审计结果
[LOG] 报告头部标注："本报告为阶段独立审计报告，仅覆盖单个阶段的追溯链/产出物/检查点"

[FORMAT]
# DevFlow 阶段审计报告 — Stage {N} - v{version}

## 审计范围
- 版本号：{version}
- 审计阶段：Stage {N}（{阶段名}）
- 审计日期：{date}
- 审计能力：Phase {phase_list}（追溯链/产出物盘点/检查点复查）

## 追溯链验证
该阶段相关追溯链检定结果

## 产出物盘点
该阶段产出物存在性 + 子步骤完整性结果

## 关键检查点复查
该阶段检查点复查结果

## 风险标记
⚠️ 标记本次审计发现的待关闭问题，供人工干预
- P0 阻塞项：{list}
- P1 高风险项：{list}

## 阶段审计结论
✅ 允许进入下一阶段 / ❌ 阻塞，需先解决标记问题
```

**全流程审计输出**（指定 `--version` 时）：

```text
[TOOL] Write(doc/audit/comprehensive/DevFlow-全流程闭环审计报告-{version}.md)
[CONTENT] 聚合 doc/audit/review/ 中所有阶段审计报告内容
[LOG] 报告头部标注："本报告由 audit-agent AI 生成，汇集各阶段独立审计报告"
```

### 步骤 4 — 季度审计

```text
audit-agent --quarterly {year}-Q{quarter}
  [1] 扫描本季度所有已发布版本的 tag
      git tag -l | grep {year} | filter by date range
  [2] 对每个版本执行能力 1~4
  [3] 汇总 → 季度审计报告
      - 本季度发布版本数
      - 每个版本的审计结论
      - 本季度未关闭的 P1+ 债务清单
  [4] Write(季度审计报告)
```

---

## 失败处理

| 场景 | 行为 |
|:-----|:------|
| Git log 命令失败（Git 不可用） | `[ERROR] Git command failed`，跳过能力 1，报告中标记"Git 不可用" |
| 追溯矩阵文件不存在 | 该阶段跳过追溯链验证，标记为"文件不存在" |
| 产出目录不存在 | 标记为"缺失"，报告中列明 |
| 验证命令执行超时（>30s） | 标记为"超时未验证" |
| 无 commit 可提取 ID（新项目） | 输出"无追溯链数据"，不阻塞能力 2~4 |
| git ls-remote 失败（远程不可达） | 标记该远程为"不可达"，继续验证其他远程 |
| 审计报告写入目标已存在 | 追加覆盖（幂等——同一版本多次审计结果一致） |

---

## 可观测性

| 能力 | 实现 |
|:-----|:------|
| **进度日志** | 每个能力开始时输出 `[INFO] 能力 N: ...` |
| **步骤日志** | 每个步骤开始时输出 `  [STEP] Step X: ...` |
| **中间结果** | 每个步骤完成后输出关键发现 |
| **错误日志** | 失败时输出 `[ERROR] ...` + 原因 |
| **阶段审计输出** | 写入 `doc/audit/review/DevFlow-阶段审计报告-Stage{N}-v{version}.md` |
| **最终输出** | 全流程审计报告写入 `doc/audit/comprehensive/` |

---

## 编码规范审查 vs audit-agent 分工

| 责任方 | 职责 | 时机 |
|:-------|:-----|:-----|
| **编码规范审查（coding-stage-execution 3.4a/3.4b）** | 在编码阶段执行时阻止跳步，"你跳过了 3.4a，请返回执行" | 编码进行中 |
| **audit-agent 产出物完整性验证（能力 2）** | 阶段完成后独立验证，"你声称完成了但缺少 XX 产出物" | 阶段审计时 |

---

## Coding Stage Integration

When this skill is used during the formal coding stage, coordinate with `coding-stage-execution`.

- Treat `coding-stage-execution` as the Step 3 coding-stage controller.
- Use this skill only for its specialty area; do not use it to declare the whole development stage complete.
- Record implementation decisions, changed files, static quality commands, self-test evidence, risks, and remaining issues in `DevLogReport`.
- Do not let a successful specialty check replace `code-logic-review` or development audit.
- If a P0/P1 issue is found, fix it within Step 3, rerun relevant checks, update `DevLogReport`, and run `code-logic-review` before handoff.
