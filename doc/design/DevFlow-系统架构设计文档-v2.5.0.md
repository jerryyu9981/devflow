# DevFlow-系统架构设计文档

## 基本信息

| 项目名 | 版本 | 文档状态 | 日期 | Owner | 远程仓库 | 分支策略 |
|--------|------|----------|------|-------|----------|----------|
| DevFlow | v2.5.0 | 草稿 | 2026-07-04 | jerry.yu | http://192.168.0.14/jerry.yu/devflow.git | git-flow |

## 修订历史

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| v2.5.0 | 2026-07-04 | jerry.yu | 初始创建，"生态集成版本"架构设计 |

---

> **重要说明**
>
> DevFlow 是一个工程规范插件，不是应用系统。它由技能文件（.md）、脚本（.ps1/.sh）、编排器和配置文件组成，运行在 TRAE IDE 等 AI 编程工具的技能系统中。因此本架构设计文档侧重于**技能体系结构、文件组织、技能间关系和版本管理**，而非传统的服务/模块/组件架构。

## 1. 架构概述

### 1.1 DevFlow 技能体系定位

DevFlow 是一个三层技能架构的工程规范引擎：

| 层级 | 定位 | 技能数量 | 说明 |
|------|------|----------|------|
| **Layer 1**（总控调度） | 全局流程控制与角色协调 | 3 | project-development-workflow, project-document-management, project-role-management |
| **Layer 2**（阶段执行） | 各开发阶段的流程执行与质量管控 | 6 | version-planning-stage-execution, requirements-stage-execution, design-stage-execution, coding-stage-execution, testing-stage-execution, operations-stage-execution |
| **Layer 3**（专项参考） | 领域知识与规范参考 | 14+2=16 | project-coding-conventions, code-static-quality-check, code-logic-review, cicd-pipeline-management, observability-standards, project-document-templates, code-version-backup-management, skill-md-writing-standards, prototype-coverage, backend-coverage, api-contract-management, security-design-review, secure-coding-practices, container-deployment, **performance-engineering（新增）**, **database-migration（新增）** |
| **Orchestrator**（编排器） | 初始化、阶段管理、项目配置 | 3 | devflow-init, devflow-phase-manager, devflow-project-config |

### 1.2 v2.5.0 架构变更范围

v2.5.0 不改变技能体系的层级结构或文件组织方式。变更限于：

| 序号 | 变更类型 | 说明 |
|------|----------|------|
| 1 | 新增 2 个 L3 技能文件 | performance-engineering.md, database-migration.md |
| 2 | 增强 1 个 Orchestrator 逻辑 | devflow-init 远程仓库交互式配置 |
| 3 | 新增技能市场元数据文件 | TRAE 技能市场集成所需的描述文件 |
| 4 | 更新 2 个 L2 技能的 L3 速查表 | coding-stage-execution.md, testing-stage-execution.md 补充性能工程速查条目 |
| 5 | Codex CLI 兼容性修复 | 确保核心流程在 Codex CLI 环境可用 |

## 2. 技能体系结构

### 2.1 目录结构

```
devflow-plugin-v2.5.0/
├── version.json                    # 版本号单一来源
├── CHANGELOG.md                    # 变更日志
├── README.md                       # 项目说明
├── quickstart.html / quickstart.md # 快速入门
├── install.ps1 / install.sh        # 安装脚本
├── setup.ps1 / setup.sh            # 设置脚本
├── update.ps1 / update.sh          # 更新脚本
├── skills/
│   ├── L1/                         # 总控调度层（3 个）
│   ├── L2/                         # 阶段执行层（6 个）
│   └── L3/                         # 专项参考层（14+2=16 个）
├── devflow-init/                   # 初始化编排器
├── devflow-phase-manager/          # 阶段管理编排器
├── devflow-project-config/         # 项目配置编排器
├── scripts/                        # 工具脚本
│   ├── validate-install.ps1        # 安装验证
│   ├── check-skill-format.ps1      # 技能格式检查
│   └── build.ps1                   # 构建同步
├── templates/                      # 文档模板（24 个）
├── hooks/                          # Git Hooks
└── doc/                            # 版本文档
```

### 2.2 v2.5.0 新增/修改文件清单

| 设计项 DT-ID | 关联 FR | 文件路径 | 操作 | 说明 |
|---|---|---|---|---|
| DT-001 | FR-001 | devflow-init/SKILL.md | 修改 | 增加远程仓库交互式配置步骤 |
| DT-002 | FR-002 | 根目录/ (元数据文件) | 新增 | TRAE 技能市场元数据描述文件 |
| DT-003 | FR-003 | skills/L3/performance-engineering.md | 新增 | 性能工程全流程 L3 技能 |
| DT-004 | FR-003 | skills/L2/coding-stage-execution.md | 修改 | 补充性能工程 L3 速查表 |
| DT-005 | FR-003 | skills/L2/testing-stage-execution.md | 修改 | 补充性能工程 L3 速查表 |
| DT-006 | FR-004 | skills/L3/database-migration.md | 新增 | 数据库迁移管理 L3 技能 |
| DT-007 | FR-005 | 多文件 | 修改 | Codex CLI 兼容性修复（待分析后确定） |

## 3. 各需求技术设计

### 3.1 DT-001: devflow-init 远程仓库交互式配置（FR-001）

**设计目标**：在 devflow-init 的初始化流程中增加远程仓库配置引导步骤。

**当前流程**：

1. 检测是否已初始化（.devflow/config.json 是否存在）
2. 如果未初始化，创建 config.json（remote 字段为空字符串）
3. 推断项目当前阶段
4. 输出初始化报告

**设计后流程**：

1. 检测是否已初始化
2. 如果未初始化：
   - a. 引导用户输入项目名称
   - b. **新增：引导用户输入远程仓库地址**
     - 显示提示："请输入您当前项目的 Git 远程仓库地址（origin）"
     - 显示区分说明："注意：此处输入的是您项目的远程仓库地址，非 DevFlow 下载地址"
     - 显示示例：
       - DevFlow 下载地址示例：`http://192.168.0.14/jerry.yu/devflow.git`
       - 项目远程仓库示例：`http://192.168.0.14/jerry.yu/myproject.git`
     - URL 格式校验（合法 Git URL：http/https/ssh/git 协议）
     - 允许空值（用户可跳过，保持空字符串）
   - c. **新增：引导用户输入备份仓库地址（可选）**
     - 类似 origin 流程，标注为可选
   - d. 创建 config.json，写入 remote.origin 和 remote.backup
3. 推断项目当前阶段
4. 输出初始化报告

**涉及文件**：仅 `devflow-init/SKILL.md`（编排器的行为定义文件）

**URL 格式校验规则**：

| 协议 | 合法格式示例 | 校验规则 |
|------|-------------|----------|
| HTTPS | `https://github.com/user/repo.git` | 以 `https://` 开头，包含域名和路径 |
| HTTP | `http://192.168.0.14/user/repo.git` | 以 `http://` 开头，包含 IP 或域名和路径 |
| SSH | `git@github.com:user/repo.git` | 匹配 `git@<host>:<path>` 格式 |
| Git | `git://github.com/user/repo` | 以 `git://` 开头 |

**config.json 变更**：

```json
// 变更前
{
  "remote": ""
}

// 变更后
{
  "remote": {
    "origin": "http://192.168.0.14/jerry.yu/myproject.git",
    "backup": ""
  }
}
```

> **注意**：config.json 的 remote 字段结构从字符串变更为对象，需确保 devflow-project-config 等下游读取方兼容此变更。

---

### 3.2 DT-002: 技能市场集成（FR-002）

**设计目标**：创建 TRAE 技能市场所需的元数据文件。

**设计方案**：

1. 调研 TRAE 技能市场元数据规范（Phase 3 开始前完成）
2. 在 devflow-plugin 根目录创建符合规范的描述文件
3. 包含：技能名称、描述、标签、版本声明、兼容性声明
4. 安装流程：市场下载 --> 解压到 skills 目录 --> 运行 setup.ps1

**涉及文件**：根目录新增元数据文件（具体文件名待规范调研后确定）

**元数据文件预期字段**：

| 字段 | 说明 | 示例值 |
|------|------|--------|
| name | 技能名称 | `devflow-engineering-standards` |
| displayName | 显示名称 | `DevFlow 工程规范引擎` |
| version | 版本号 | 引用 `version.json` 中的版本 |
| description | 技能描述 | 三层架构工程规范引擎，覆盖项目全生命周期 |
| tags | 标签 | `engineering`, `workflow`, `quality`, `standards` |
| compatibility | 兼容性声明 | `TRAE IDE >= 1.0, Codex CLI >= 1.0` |
| installScript | 安装脚本路径 | `setup.ps1` |
| author | 作者 | `jerry.yu` |

**前置依赖**：TRAE 技能市场规范必须在 Phase 3 编码阶段开始前发布。若规范未就绪，则 DT-002 降级为"准备元数据草稿，待规范发布后补全"。

---

### 3.3 DT-003~005: 性能工程全流程技能（FR-003）

**设计目标**：新增性能工程 L3 技能，补充 L2 速查表。

#### 3.3.1 技能文件设计（DT-003）

- **文件路径**：`skills/L3/performance-engineering.md`
- **格式**：遵循 `skill-md-writing-standards` 编写规范

**章节结构**：

| 章节 | 内容 |
|------|------|
| 1. 定位与触发条件 | 说明本技能在 DevFlow 体系中的位置（L3 专项参考），定义何时触发（涉及性能需求、性能测试、性能优化场景） |
| 2. 性能需求定义 | 响应时间 / 吞吐量 / 并发数 / 资源约束 / SLA / SLO 模板，提供标准化的性能需求描述框架 |
| 3. 性能测试基准建立 | 基准测试 --> 负载测试 --> 压力测试 --> 稳定性测试流程，各阶段输入/输出/工具推荐 |
| 4. 性能瓶颈分析 | 前端渲染 / 后端接口 / 数据库查询 / 缓存策略分类方法论，提供常见瓶颈模式识别清单 |
| 5. 性能优化决策树 | 分析 --> 定位 --> 优化 --> 验证循环，提供决策树图示和分支判断逻辑 |
| 6. 容量规划指南 | 资源评估 / 扩容策略 / 降级方案，提供容量评估计算模板 |
| 7. 技能速查映射 | 与 coding-stage-execution / testing-stage-execution 的引用关系，明确交叉调用路径 |
| 8. 变更记录 | 记录本技能文件自身的版本变更历史 |

#### 3.3.2 L2 速查表补充（DT-004, DT-005）

**coding-stage-execution.md**：在"编码技能速查"表中新增一行：

| 技能名称 | 触发条件 | 速查要点 |
|----------|----------|----------|
| performance-engineering | 编码阶段涉及性能敏感模块 | 性能需求定义 --> 基准建立 --> 瓶颈分析 --> 优化验证循环 |

**testing-stage-execution.md**：在"测试技能速查"表中新增一行：

| 技能名称 | 触发条件 | 速查要点 |
|----------|----------|----------|
| performance-engineering | 测试阶段需要性能测试 | 基准测试 --> 负载测试 --> 压力测试 --> 稳定性测试四阶段流程 |

---

### 3.4 DT-006: 数据库迁移管理技能（FR-004）

**设计目标**：新增数据库迁移管理 L3 技能。

**技能文件设计**：

- **文件路径**：`skills/L3/database-migration.md`
- **格式**：遵循 `skill-md-writing-standards` 编写规范

**章节结构**：

| 章节 | 内容 |
|------|------|
| 1. 定位与触发条件 | L3 专项参考，触发条件：涉及数据库 Schema 变更、数据迁移、数据库版本升级场景 |
| 2. Schema 版本管理规范 | 命名约定 / 版本号 / 向前向后兼容策略 |
| 3. 迁移脚本编写规范 | up/down 迁移 / 幂等性要求 / 事务包裹 / 回滚支持 |
| 4. 回滚策略 | 自动回滚（迁移失败时的事务回滚）/ 手动回滚（数据修复脚本）/ 数据恢复（备份恢复流程） |
| 5. 多环境迁移流程 | Dev --> Test --> Pro / 数据脱敏策略 / 配置差异管理 |
| 6. 数据一致性校验 | 校验脚本编写 / Checksum 对比 / 行数对比 / 数据抽样验证 |
| 7. 数据库专项指南 | MySQL / PostgreSQL / MongoDB 各自的迁移最佳实践与注意事项 |
| 8. 技能速查映射 | 与 coding-stage-execution / operations-stage-execution 的引用关系 |
| 9. 变更记录 | 本技能文件自身的版本变更历史 |

---

### 3.5 DT-007: Codex CLI 深度适配（FR-005）

**设计目标**：确保 DevFlow 在 Codex CLI 环境的核心流程可用。

**设计方案**：

1. Phase 3 开始前获取 Codex CLI 最新版本
2. 在 Codex CLI 环境执行完整 Step 0 ~ Step 5 流程验证
3. 重点检查项：

| 检查项 | 说明 | 风险等级 |
|--------|------|----------|
| 无交互模式技能调用 | Codex CLI 可能不支持交互式输入，需确保非交互路径可用 | 高 |
| 命令行参数传递 | 技能调用时参数传递机制是否与 IDE 环境一致 | 中 |
| 输出格式适配 | Markdown 输出是否被 Codex CLI 正确解析和展示 | 中 |
| 文件路径处理 | Codex CLI 的运行时工作目录可能与 IDE 不同 | 高 |

4. 兼容性问题修复策略：优先修改技能文件内容使其兼容，避免引入 Codex CLI 特定的条件分支

**涉及文件**：待兼容性测试后确定。预估可能涉及：

| 文件 | 潜在变更点 |
|------|-----------|
| `devflow-init/SKILL.md` | 交互式输入部分需支持非交互降级（环境变量/默认值） |
| `install.ps1` / `install.sh` | 平台检测逻辑可能需要适配 Codex CLI 运行时 |
| `setup.ps1` / `setup.sh` | 路径处理可能需要适配 Codex CLI 工作目录 |

---

## 4. 版本管理设计

### 4.1 版本号更新

| 文件 | 变更 |
|------|------|
| `version.json` | `"version": "2.4.1"` --> `"version": "2.5.0"` |

`version.json` 是版本号唯一来源，所有文件不得硬编码版本号。

### 4.2 硬编码检查

全局搜索确认无硬编码残留：

```bash
grep -rn "\d\+\.\d\+\.\d\+" skills/ devflow-init/ --include="*.md"
```

搜索结果中若发现版本号字面量（非示例、非日期），需替换为对 `version.json` 的引用说明。

## 5. 设计决策记录

| 决策 | 选项 | 选择 | 理由 |
|------|------|------|------|
| 性能工程技能层级 | L2（阶段执行） vs L3（专项参考） | **L3** | 性能工程是专项领域知识，非阶段流程控制，适合作为被 L2 引用的参考技能 |
| 数据库迁移技能层级 | L2（阶段执行） vs L3（专项参考） | **L3** | 数据库迁移是专项领域知识，跨编码和运维阶段，适合作为被 L2 引用的参考技能 |
| devflow-init 修改范围 | 新建编排器 vs 增强现有编排器 | **增强现有** | 避免引入新编排器，保持架构简洁，减少编排器间的协调成本 |
| Codex CLI 适配策略 | 新建适配层 vs 修改现有内容 | **修改现有内容** | 避免引入平台特定分支，保持跨平台统一的技能文件内容 |

## 6. 风险与开放问题

| 风险 | 级别 | 缓解措施 |
|------|------|----------|
| TRAE 技能市场规范尚未发布，DT-002 元数据文件设计无法最终确定 | **P1** | Phase 3 开始前确认规范可用性；若未就绪，先准备草稿待规范发布后补全 |
| Codex CLI 功能模型不稳定，兼容性修复范围可能在 Phase 3 中扩大 | **P2** | 兼容性目标可降级到核心流程（Step 0~Step 5）可用，非核心路径可后续迭代 |
| 性能工程技能内容量大，可能超出单次交付的合理范围 | **P2** | 分 Phase 交付：先完成核心章节（定位、需求定义、瓶颈分析、决策树），后扩展（容量规划、数据库专项） |
| config.json remote 字段结构变更（字符串 --> 对象）可能导致下游兼容问题 | **P3** | 全面排查 devflow-project-config 等下游读取方，确保兼容新结构 |

---

## 变更记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| v2.5.0 | 2026-07-04 | jerry.yu | 初始创建，"生态集成版本"架构设计 |
