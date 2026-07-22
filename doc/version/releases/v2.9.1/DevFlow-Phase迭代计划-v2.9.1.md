# DevFlow v2.9.1 Phase 迭代计划

> 文档类型：Phase 迭代计划
> 文档状态：[Draft]
> 版本：v1.0
> 日期：2026-07-22
> 负责人：PM-DevFlow-Dev

---

## 1. 版本总览

| 项 | 内容 |
|:---|:-----|
| 版本号 | v2.9.1 |
| 版本主题 | 配置架构精简 + 流程质量增强版 |
| 需求总数 | 3 项（P1 × 3） |
| Phase 数量 | 3 |
| 预计周期 | 短周期（架构调整 + 流程优化类） |

---

## 2. Phase 拆分

### Phase 1：JSON 配置架构重构

| 项 | 内容 |
|:---|:-----|
| Phase 主题 | JSON 配置文件精简合并 |
| 包含需求 | V291-001（JSON 配置精简） |
| 工作量占比 | 60% |
| 核心交付物 | `devflow-plugin/devflow-config.json`（source of truth，合并 version.json + manifest）、`.devflow/project-config.json`（原 config.json 改名）、IDE 系统目录 `devflow-config.json` |
| 关键任务 | 1. 重命名/合并 3 个 JSON 文件<br>2. 删除 3 个冗余 JSON 文件<br>3. 所有脚本路径引用更新<br>4. devflow-init 旧路径自动迁移<br>5. 技能文档路径引用更新 |
| 验收标准 | - 3 个配置文件各司其职，零重复<br>- 所有脚本和文档中的旧路径全部更新<br>- 旧版本用户升级时自动迁移无报错 |

**任务清单：**

| 任务 ID | 任务描述 | 关联文件 |
|:-------:|:---------|:---------|
| T-01 | `devflow-plugin/version.json` → `devflow-plugin/devflow-config.json` 重命名 + 合并 devflow-manifest.json | devflow-plugin/devflow-config.json |
| T-02 | `.devflow/config.json` → `.devflow/project-config.json` 重命名 | .devflow/project-config.json |
| T-03 | 删除项目根 `version.json`（字段合并进 project-config.json） | — |
| T-04 | 删除 `.devflow/version.json`（与框架 devflow-config 重复） | — |
| T-05 | setup.ps1 更新：写入 IDE 系统目录 `devflow-config.json` | setup.ps1 |
| T-06 | devflow-init 技能文档更新：所有路径引用 + 旧路径迁移逻辑 | devflow-init/SKILL.md |
| T-07 | 其他 L2 技能文档路径引用更新 | version-planning-stage-execution.md 等 |

---

### Phase 2：脚本精简

| 项 | 内容 |
|:---|:-----|
| Phase 主题 | 安装脚本精简 |
| 包含需求 | V291-002（脚本精简） |
| 工作量占比 | 40% |
| 前置依赖 | Phase 1 完成（脚本引用新的 JSON 路径） |
| 核心交付物 | `install.ps1`（首次安装入口）、`update.ps1`（更新主入口，含 sync 功能） |
| 关键任务 | 1. sync-skills.ps1 功能合并进 update.ps1<br>2. install.ps1 精简为纯编排（调 download + setup）<br>3. 统一参数规范和错误处理<br>4. 回归测试 |
| 验收标准 | - 2 个入口脚本功能完整<br>- sync 功能在 update.ps1 中正常工作<br>- install / update / sync 三场景全部通过回归测试 |

**任务清单：**

| 任务 ID | 任务描述 | 关联文件 |
|:-------:|:---------|:---------|
| T-08 | sync-skills.ps1 功能合并进 update.ps1 | update.ps1 |
| T-09 | 删除 sync-skills.ps1 | — |
| T-10 | install.ps1 精简为纯编排（调 download-devflow.ps1 + setup.ps1） | install.ps1 |
| T-11 | 统一参数规范、错误处理、BOM 修复函数 | 全部脚本 |
| T-12 | 回归测试：install / update / sync 各场景 | 测试用例 |

---

### Phase 3：全阶段产出真实性验证门禁

| 项 | 内容 |
|:---|:-----|
| Phase 主题 | 全阶段产出真实性验证门禁 |
| 包含需求 | V291-003（全阶段产出真实性验证门禁） |
| 工作量占比 | 30% |
| 前置依赖 | 无（可与 Phase 1/2 并行推进） |
| 核心交付物 | 6 个 L2 阶段执行技能文档新增产出物验证门禁 + Step 5 全流程闭环审计新增盘点章节 |
| 关键任务 | 1. 制定标准化产出物验证模板<br>2. 6 个 L2 技能文档逐一新增产出物验证门禁<br>3. 各阶段审计检查清单新增"产出物存在性核查"<br>4. Step 5 全流程闭环审计新增"全阶段产出物盘点"章节 |
| 验收标准 | - 6 个阶段全部新增产出物存在性验证门禁<br>- 验证门禁要求包含 LS/Glob 实际输出作为证据<br>- Step 5 盘点章节完整覆盖所有阶段产出物 |

**任务清单：**

| 任务 ID | 任务描述 | 关联文件 |
|:-------:|:---------|:---------|
| T-13 | 制定标准化产出物存在性验证模板 | （模板内嵌于各技能文档） |
| T-14 | version-planning-stage-execution 新增产出物验证门禁 | version-planning-stage-execution.md |
| T-15 | requirements-stage-execution 新增产出物验证门禁 | requirements-stage-execution.md |
| T-16 | design-stage-execution 新增产出物验证门禁 | design-stage-execution.md |
| T-17 | coding-stage-execution 新增产出物验证门禁 | coding-stage-execution.md |
| T-18 | testing-stage-execution 新增产出物验证门禁 | testing-stage-execution.md |
| T-19 | operations-stage-execution 新增产出物验证门禁 + 全阶段盘点章节 | operations-stage-execution.md |

---

## 3. 里程碑

| 里程碑 | 对应 Phase | 交付物 | 通过标准 |
|:------:|:----------:|:-------|:---------|
| M1 | Phase 1 完成 | 新 JSON 架构 + 路径全部更新 | 3 个配置文件各司其职，零重复，所有引用更新完成 |
| M2 | Phase 2 完成 | 精简后的脚本 + 回归测试通过 | 2 个入口脚本功能完整，全量回归测试通过 |
| M3 | Phase 3 完成 | 6 个阶段产出物验证门禁 + 全阶段盘点 | 6 个 L2 技能文档全部新增验证门禁，Step 5 盘点章节完成 |
| M4 | 版本发布 | Release Note + Changelog | 全流程闭环审计通过，全阶段产出物盘点零空输出 |

---

## 4. 风险清单

| 风险 ID | 描述 | 级别 | 影响 Phase | 应对措施 |
|:-------:|:-----|:----:|:----------:|:---------|
| R-01 | 旧路径引用遗漏 | 🟡 P1 | Phase 1 | 全量 grep 搜索 + 脚本化验证 |
| R-02 | 脚本合并回归 bug | 🟡 P1 | Phase 2 | 完整回归测试矩阵 |
| R-03 | 向后兼容性问题 | 🟡 P1 | Phase 1 | devflow-init 自动迁移逻辑 |
| R-04 | 产出验证门禁执行流于形式 | 🟡 P1 | Phase 3 | 验证门禁要求必须包含 LS/Glob 实际输出作为证据 |
| R-05 | 6 个阶段验证规则不一致 | 🟢 P2 | Phase 3 | 制定标准化验证模板，6 个阶段统一使用 |

---

## 5. 依赖清单

| 依赖 ID | 依赖项 | 影响 Phase | 状态 |
|:-------:|:-------|:----------:|:----:|
| D-01 | Phase 1 JSON 重构完成 | Phase 2 | ⏳ 待完成 |
| D-02 | PowerShell 5.1+ | 全部 | ✅ 已满足 |
| D-03 | devflow-init 技能文档同步 | Phase 1 | ⏳ 本版本修改 |
| D-04 | 6 个 L2 阶段执行技能文档存在 | Phase 3 | ✅ 已满足 |

---

## 6. 技术债务清单

本版本 3 项需求中，2 项为架构还债性质，1 项为流程还债性质：
- V291-001：偿还"配置文件职责不清、重复存储"的架构债务
- V291-002：偿还"脚本冗余、功能重复"的流程债务
- V291-003：偿还 TD-023"缺少全阶段产出真实性验证机制"的流程债务

全局债务总表详见 [DevFlow-技术债务总表 v1.7](computer://d:\TRAE%20CN\myproject\Dev\DevFlow\doc\version\global\DevFlow-技术债务总表.md)

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| v1.0 | 2026-07-22 | 初始创建，v2.9.1 Phase 迭代计划 | PM-DevFlow-Dev |
| v1.1 | 2026-07-22 | 新增 Phase 3（全阶段产出真实性验证门禁），更新里程碑、风险、依赖、债务清单 | PM-DevFlow-Dev |
