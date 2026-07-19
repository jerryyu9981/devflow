# DevFlow 开发需求文档 v2.8.3

> **文档状态**: [Draft]
> **版本**: 1.0.0
> **项目**: DevFlow
> **目标版本**: v2.8.3
> **作者**: RE-DevFlow-Dev
> **创建日期**: 2026-07-18

---

## 1. 入场检查

| 检查项 | 状态 | 证据 |
|--------|:----:|------|
| Step 0 版本规划已批准 | ✅ | 用户已批准 '批准，Use Skill: requirements-stage-execution step 1' |
| 单版本规划文档 | ✅ | doc/version/releases/v2.8.3/DevFlow-单版本规划文档-v2.8.3.md |
| 本版本 Backlog | ✅ | doc/version/releases/v2.8.3/DevFlow-本版本Backlog-v2.8.3.md |
| Phase 迭代计划 | ✅ | doc/version/releases/v2.8.3/DevFlow-Phase迭代计划-v2.8.3.md |
| 版本规划评审记录 | ✅ | doc/version/releases/v2.8.3/DevFlow-版本规划评审记录-v2.8.3.md |
| 全局候选需求池 | ✅ | doc/version/global/DevFlow-候选需求池.md（V260-051/052 已纳入） |

---

## 2. 业务目标

v2.8.3 为安装一致性架构修复版本（patch），核心业务目标：
1. **消除 skillMap 重复定义风险**：将 5 个脚本中硬编码的技能清单统一为 devflow-manifest.json 单一事实源
2. **建立安装完整性校验**：在三步走全流程中加入文件存在性、技能数量一致性自动检查
3. **杜绝历史遗漏重演**：v2.5.0 遗漏 6 个 L3 技能达 3 个版本的事件不再发生

### 2.1 版本成功指标

| 指标 | 目标值 | 衡量方法 |
|-----|:------:|---------|
| skillMap 一致率 | 100% | 5 个脚本全部从 manifest 读取，无一硬编码 |
| 安装完整性 | 100% | manifest 所有 required 文件安装到位 |
| 新增技能响应速度 | ≤1 个版本 | 新增技能只需改 manifest，不再需要 5 个脚本同步 |
| 自动化测试通过率 | 100% | 22 个原有测试用例全部 PASS |

---

## 3. 需求定义

### 3.1 V260-051：devflow-manifest.json 插件文件清单

#### 3.1.1 需求描述

创建 `devflow-manifest.json` 作为 DevFlow 插件所有文件的单一事实源，替代 5 个脚本中硬编码的 skillMap。

#### 3.1.2 用户故事

As a DevFlow 维护者,
I want 所有安装/更新/同步脚本从同一个 JSON 清单读取技能定义,
so that 新增或删除技能时只需修改一个文件，避免多脚本同步遗漏。

#### 3.1.3 功能需求

| FR-ID | 需求项 | 输入 | 处理 | 输出 |
|:-----:|--------|------|------|------|
| FR-01 | manifest 文件定义 | 所有插件文件路径 | 按 category（entry/tool/skill/config）分类，标记 required 和 destination | devflow-manifest.json |
| FR-02 | manifest 动态加载（PowerShell） | manifest JSON 路径 | ConvertFrom-Json 读取，生成 $skillMap 哈希表 | 内存中的技能清单 |
| FR-03 | manifest 动态加载（Bash） | manifest JSON 路径 | sed/awk 或 grep 解析，生成 SKILL_MAP 关联数组 | 内存中的技能清单 |
| FR-04 | 5 脚本 skillMap 替换 | setup.ps1/sh、update.ps1/sh、sync-skills.ps1 | 删除硬编码 skillMap，改为调用 manifest 加载函数 | 5 个无硬编码的脚本 |
| FR-05 | Download 后文件完整性校验 | download-devflow.ps1 | clone 完成后遍历 manifest required 文件，缺失则报错 | 校验通过/失败报告 |
| FR-06 | Setup 后安装数量校验 | setup.ps1/sh | 安装完成后统计已安装技能数，与 manifest.skillCount 对比 | 数量一致/不一致告警 |
| FR-07 | Init 技能一致性告警 | devflow-init | 初始化时检查已安装技能数量与 manifest 是否一致 | 不一致时输出警告日志 |

#### 3.1.4 验收标准

| AC-ID | 关联 FR | 验收条件 | 验证方法 |
|:-----:|:-------:|---------|---------|
| AC-01 | FR-01 | manifest.json 覆盖 devflow-plugin/ 下全部 31 个技能 + 6 个工具/入口文件 | 手动核对文件清单 |
| AC-02 | FR-02~03 | PowerShell 和 Bash 均可正确解析 manifest 并生成完整技能映射表 | 分别运行 $PSVersionTable 和 bash -c 测试 |
| AC-03 | FR-04 | 5 个脚本中不包含任何硬编码的技能名称列表 | grep -c 'devflow-init\|project-development' 检查无 hashtable 定义 |
| AC-04 | FR-05 | download-devflow.ps1 在 clone 后检测到缺失文件时以非零退出码终止 | 移除一个文件后运行，验证报错 |
| AC-05 | FR-06 | setup.ps1 安装后输出 "Installed: N/31 skills" | 运行 setup.ps1，检查输出行 |
| AC-06 | FR-07 | devflow-init 在技能数量不一致时输出 "[WARN] Skill count mismatch" | 删除一个技能目录后运行 devflow-init |

---

### 3.2 V260-052：skillMap 历史遗漏修复

#### 3.2.1 需求描述

修补 4 个脚本的 hardcoded skillMap 中缺失的 v2.5.0/v2.8.0 技能条目。已由 commit 3d0fa2d 修复。

#### 3.2.2 修复清单

| 脚本 | 缺失条目 | 修复 commit | 状态 |
|------|---------|:-----------:|:----:|
| setup.ps1 | 6 个 L3 技能 | 3d0fa2d | ✅ |
| setup.sh（Bash 分支） | 6 个 L3 技能 + devflow-plugin-download | 3d0fa2d | ✅ |
| update.ps1 | 6 个 L3 技能 | 3d0fa2d | ✅ |
| update.sh | 6 个 L3 技能 + devflow-plugin-download | 3d0fa2d | ✅ |

#### 3.2.3 验收标准

| AC-ID | 验收条件 | 验证方法 |
|:-----:|---------|---------|
| AC-07 | 5 个脚本的 31 个技能条目 155/155 完全一致 | 自动化 grep 验证脚本 |

---

## 4. 非功能需求

| NFR-ID | 类别 | 需求 | 验证方法 |
|:------:|:----:|------|---------|
| NFR-01 | 可维护性 | manifest.json 格式应支持注释或 self-describing _meta 字段，便于新维护者理解 | 检查 _meta 字段是否存在 |
| NFR-02 | 兼容性 | 现有已安装的 DevFlow 技能不受 manifest 引入影响 | 安装后技能数量不变 |
| NFR-03 | 性能 | manifest 解析时间 < 100ms | 测试解析时间 |

---

## 5. 数据需求

| DR-ID | 实体 | 说明 |
|:-----:|------|------|
| DR-01 | devflow-manifest.json | 插件文件清单，JSON 格式，存储在 devflow-plugin/ 根目录 |

---

## 6. 权限与安全需求

| SR-ID | 需求 | 说明 |
|:-----:|------|------|
| SR-01 | manifest.json 应为只读引用 | 脚本只读不写 manifest，防止运行时修改导致校验失效 |

---

## 7. UI/UX 需求

不适用。v2.8.3 不涉及任何 UI/UX 变更。安装输出日志增加一条数量统计行（如 "Installed: 31/31 skills"）。

---

## 8. 接口与集成需求

不适用。无外部系统接口变更。

---

## 9. 约束和排除项

**约束**：
- 所有 5 个脚本必须保持在切换 manifest 前后行为一致（安装相同技能列表）
- manifest.json 不能引入新的外部依赖（Bash 分支不用 jq，用 sed/awk 解析）

**排除项**（明确不做）：
- ❌ 不改造 download-devflow.ps1 本身（仅增加校验）
- ❌ 不改造 devflow-init 流程（仅增加告警）
- ❌ 不涉及任何 SKILL.md 内容变更

---

## 10. 验收标准汇总

| AC-ID | 关联需求 | 验收条件 | 验证方法 |
|:-----:|:--------:|---------|---------|
| AC-01 | FR-01 | manifest 覆盖 37+ 文件 | 手动核对 |
| AC-02 | FR-02~03 | PS/Bash 均可解析 | 脚本测试 |
| AC-03 | FR-04 | 5 脚本无硬编码 | grep 检查 |
| AC-04 | FR-05 | 缺失文件时报错退出 | 破坏测试 |
| AC-05 | FR-06 | 安装后输出数量统计 | 运行验证 |
| AC-06 | FR-07 | init 告警数量不一致 | 破坏测试 |
| AC-07 | V260-052 | 31x5=155 一致 | 自动验证 |

---

## 11. 优先级确认

| 需求 ID | 对应 BL-ID | 优先级 | 理由 |
|:-------:|:----------:|:------:|------|
| V260-052 | BL-01 | :red_circle: P0 | 前置修复，manifest 改造的前提条件 |
| V260-051 | BL-02~BL-07 | :red_circle: P0 | 核心需求：manifest 创建+5 脚本改造 |
| V260-051 | BL-08~BL-09 | :large_yellow_circle: P1 | 校验增强，非核心但在 Phase 3 完成 |
| V260-051 | BL-10 | :large_green_circle: P2 | Init 告警，可选优化 |

---

## 12. 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-18 | 初始创建 | RE-DevFlow-Dev |
