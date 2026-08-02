# DevFlow 系统架构设计文档 — v2.15.0

> 文档类型：系统架构设计文档（版本设计）
> 版本：v2.15.0
> 日期：2026-08-02
> 作者：AA-DevFlow-Dev

---

## 1. 设计入场检查

| 检查项 | 结果 | 证据 |
|:-------|:----:|:-----|
| Step 1 需求文档已批准 | ✅ | 开发需求文档 v1.0，5 项需求（F1~F5） |
| 需求评审记录已通过 | ✅ | 需求评审记录 v1.0，5 维度全部通过 |
| 需求追溯矩阵已建立 | ✅ | 5 条 RT-ID（RT-215-001~005），P0/P1 100% 可追溯 |
| 需求评估审计已通过 | ✅ | 需求评估报告 v1.0，6 维度全部通过 |
| Step 1 审计报告已通过 | ✅ | Stage 1 审计报告，允许进入 Step 2 |
| 单版本规划文档齐备 | ✅ | 单版本规划文档 v1.3，3 项目标 |
| 本版本 Backlog 齐备 | ✅ | Backlog v1.5，5 条 BL 条目 |
| Phase 计划已确认 | ✅ | Phase 迭代计划 v1.5，3 个 Phase |
| 设计输入材料齐备 | ✅ | T1-T4 设计方案 v1.4.0 + 4 份 SKILL.md 现有结构分析 |
| 无未确认的范围变更 | ✅ | version.json 弃用决策已执行，无遗留争议 |

### 轨道选择确认

| 轨道 | 激活 | 原因 |
|:----|:----:|:------|
| 🎯 整体 | ✅ | 跨技能架构设计（T1-T4 集成涉及多个技能文件） |
| ⚙️ 后端 | ✅ | SKILL.md 文档结构变更 + PowerShell 脚本修改 |
| 🎨 前端 | ❌ | 无前端页面/组件需求（规范框架项目） |
| 🔗 第三方集成 | ❌ | 无外部依赖集成 |

---

## 2. 需求-设计追溯矩阵

| DT-ID | RT-ID | 需求标题 | 设计项 | 设计位置 |
|:-----:|:------|:---------|:-------|:---------|
| DT-215-001 | RT-215-001 | T1-T4 四层测试架构集成 | testing-stage-execution 新增 15 项改动 | §3.1 F1 详细设计 |
| DT-215-002 | RT-215-002 | 路由映射表 diff 机制 | api-contract-management Step 4 新增 2 项改动 | §3.2 F2 详细设计 |
| DT-215-003 | RT-215-003 | Stage4 产出物清单新增 | 产出物清单新增 5 项强制产出 | §3.3 F3 详细设计 |
| DT-215-004 | RT-215-004 | 版本号单一事实源落地 | release.ps1 + validate-version-header.ps1 脚本增强 | §3.4 F4 详细设计 |
| DT-215-005 | RT-215-005 | Git hook 纳入规范 | code-version-backup-management + devflow-init 文档增强 | §3.5 F5 详细设计 |

> P0/P1 需求 100% 有设计覆盖（DT-ID 5/5）。

---

## 3. 系统架构设计

### 3.1 变更范围总览

```text
DevFlow v2.15.0 变更架构
│
├── 🧪 T1-T4 四层测试架构集成（F1, ~470 行）
│   ├── testing-stage-execution/SKILL.md ← 15 项改动
│   │   ├── 新增章节：T1-T4 四层测试架构（层级总览+层间追溯+项目类型适配）
│   │   ├── 增强：强制测试矩阵 API 测试行（三要素校验+显式声明）
│   │   ├── 新增：T3 两档分层（T3a 巡检六步闭环+T3b 深度用例）
│   │   ├── 新增：T4 业务流走查模板+人机协同
│   │   ├── 增强：四轨并行工作流映射 T 层级
│   │   ├── 增强：通过标准（层间追溯+软断言清零+人工测试执行率）
│   │   ├── 增强：反模式（+4 条 T1-T4 相关）
│   │   ├── 新增：断言分级（L1/L2/L3）+禁止模式+推荐模式+速查表
│   │   ├── 新增：CRUD 全覆盖规则+用例设计规范
│   │   ├── 新增：测试覆盖矩阵+度量体系（7 指标）+覆盖缺口分析
│   │   ├── 新增：术语表（12 术语）
│   │   └── 新增：根因映射表+改进项验收标准
│   │
│   ├── api-contract-management/SKILL.md ← 2 项改动（F2, ~50 行）
│   │   ├── 新增：YAML 格式路由→字段映射表定义
│   │   ├── 新增：diff 脚本规范（输入/输出/执行方式）
│   │   └── 增强：检查清单+1 项（路由映射表 diff 已执行）
│   │
│   └── Stage4 产出物清单 ← 1 项改动（F3, ~12 行）
│       └── 新增 5 项强制产出（层间追溯矩阵/巡检问题表/UAT走查清单/覆盖矩阵/度量报告）
│
├── 🔒 版本号单一事实源修复（F4, ~30 行）
│   ├── release.ps1 ← 新增 JSON 配置同步步骤
│   ├── validate-version-header.ps1 ← Phase 1 纳入发布门禁
│   ├── sync-skills.ps1 ← 版本号源改为 devflow-config.json（已执行）
│   ├── download-devflow.ps1 ← 版本号源改为 devflow-config.json（已执行）
│   └── 安装副本同步（.devflow/skills/ + .trae/skills/）（已执行）
│
└── 🔧 Git hook 纳入规范（F5, ~20 行）
    ├── code-version-backup-management/SKILL.md ← 新增"自动备份 hook"章节
    └── devflow-init/SKILL.md ← 安装流程纳入 hook 安装步骤
```

### 3.2 技术选型与 ADR

#### ADR-001: T1-T4 架构集成方式——内联增强 vs 独立引用

| 维度 | 内容 |
|:-----|:------|
| **决策标题** | T1-T4 架构集成方式：内联增强 testing-stage-execution 还是独立引用设计方案 |
| **上下文** | T1-T4 四层测试架构方案 v1.4.0 包含 18 项核心改动，需集成到 testing-stage-execution。方案 A 为内联增强（将全部内容写入 SKILL.md），方案 B 为独立引用（SKILL.md 仅引用设计方案文件路径） |
| **备选方案 A** | 内联增强：将 T1-T4 全部规范内容直接写入 testing-stage-execution/SKILL.md。优点：技能自包含，加载即可用；缺点：SKILL.md 膨胀（+~470 行） |
| **备选方案 B** | 独立引用：SKILL.md 新增"T1-T4 四层测试架构"章节但仅放摘要和引用，详细内容引用 `doc/design/DevFlow-T1-T4四层测试架构方案-v1.4.0.md`。优点：SKILL.md 保持精简；缺点：多一层间接引用，AI 执行时需额外加载 |
| **决策** | **方案 A：内联增强** |
| **理由** | DevFlow 技能文件以 SKILL.md 为执行时的唯一上下文。AI 代理在执行测试阶段时不会自动加载 doc/design/ 下的设计方案文件。内联增强确保 T1-T4 架构在 testing-stage-execution 加载时即可用，符合 DevFlow"技能自包含"原则。~470 行增量在可接受范围内（当前 418 行 → ~888 行） |
| **已知后果** | SKILL.md 行数增长约 112%；后续 T1-T4 架构变更需同步修改 SKILL.md 和设计方案文件 |

#### ADR-002: 路由映射表格式——YAML vs JSON

| 维度 | 内容 |
|:-----|:------|
| **决策标题** | 路由映射表 diff 机制的数据格式选型 |
| **上下文** | F2 需要定义路由→字段映射表供 diff 脚本使用。需选择数据格式 |
| **备选方案 A** | YAML 格式：可读性高，支持注释，适合人工编写和维护 |
| **备选方案 B** | JSON 格式：机器友好，无注释能力，但解析工具链更成熟 |
| **决策** | **方案 A：YAML 格式** |
| **理由** | 路由映射表需要人工编写和维护（标注路由路径、HTTP 方法、请求/响应字段、前端调用文件位置），YAML 的注释能力和可读性更适合此场景。diff 脚本可使用 `yaml` Python 库解析 |
| **已知后果** | diff 脚本需依赖 YAML 解析库；YAML 缩进敏感需注意格式校验 |

#### ADR-003: 版本号同步方向——单向 vs 双向

| 维度 | 内容 |
|:-----|:------|
| **决策标题** | devflow-config.json ↔ state.json 版本号同步方向 |
| **上下文** | F4 需要建立版本号自动同步链路。devflow-config.json 为唯一事实源，state.json 需要同步更新 |
| **备选方案 A** | 单向同步：devflow-config.json → state.json（发布时自动覆盖） |
| **备选方案 B** | 双向同步：允许从 state.json 回写到 devflow-config.json |
| **决策** | **方案 A：单向同步** |
| **理由** | 唯一事实源原则要求版本号只能从 devflow-config.json 流出，不可反向覆盖。双向同步会导致 state.json 被意外修改时污染事实源 |
| **已知后果** | state.json 中的版本号只能通过发布流程更新，不支持运行时反向修改 |

---

## 4. F1 详细设计：T1-T4 四层测试架构集成（DT-215-001）

### 4.1 文件变更目标

`devflow-plugin/.trae/skills/testing-stage-execution/SKILL.md`（当前 418 行 → 预计 ~888 行）

### 4.2 新增/增强章节设计

| 序号 | 改动 | 章节位置 | 设计要点 |
|:----:|:-----|:---------|:---------|
| ① | T1-T4 层级总览 | 新增 `## T1-T4 四层测试架构`（在 `## 强制测试矩阵` 之前） | 层级总览表（4 层）+ 层间追溯要求（T1→T2→T3→T4 100%）+ 项目类型适配（全栈/纯后端/单服务纯 API）+ 不适用声明规则 |
| ② | 强制测试矩阵增强 | `## 强制测试矩阵` API 测试行 | 新增三要素校验列（状态码 + 响应结构 + 边界参数）+ "接口通过≠页面可用"显式声明 |
| ③ | T3 两档分层 | 新增 `### T3 两档分层规范`（在 T1-T4 章节内） | T3a 全页面巡检（六步闭环：清单盘点→自动化巡检→问题分类→根因定位→修复回归→报告更新）+ T3b 深度用例（CRUD/筛选/分页/错误态） |
| ④ | T3a 巡检信号和问题分类 | T3a 章节内 | 6 类巡检信号（HTTP≥400/console.error/pageerror/接口200但渲染空/静默失败/表单提交响应）+ 7 类标准问题分类（A-G 类）+ 根因定位 6 种手段 + 关键按钮清单 7 类 + 对话框清理逻辑 |
| ⑤ | T4 业务流走查 | 新增 `### T4 业务流走查规范` | 走查清单模板 + 人机协同定位 + 人工测试检查清单（5 大类：基础功能/CRUD链路/边界异常/视觉交互/真实用户流）+ 抽样策略（核心模块100%/辅助模块30%） |
| ⑥ | 四轨映射 | `## 内部工作流` 四轨并行章节 | 四轨并行工作流映射中新增 T 层级标注（整体→T1/T4、后端→T2、前端→T3） |
| ⑦ | 通过标准增强 | `## 通过标准` | 新增 3 条：层间追溯校验（T1→T2→T3→T4 覆盖率 100%）+ 软断言清零 + 人工测试执行率 100% |
| ⑧ | 反模式增强 | `## 反模式` | 新增 4 条：只做契约测试不做页面巡检 / 软断言掩盖功能缺失 / 人工测试可选 / CRUD 仅做只读 |
| ⑨ | 断言分级 | 新增 `### 断言分级规范`（T1-T4 章节内） | L1 硬断言/L2 条件断言/L3 存在性断言 + 禁止模式清单（3 种）+ 推荐断言模式（L1/L2 标准代码模板）+ 断言策略速查表（6 种场景） |
| ⑩ | CRUD 全覆盖 | 新增 `### CRUD 全覆盖规则`（T3b 章节内） | 管理类模块 C+R+U+D 至少覆盖 3 类 + 用例设计规范 |
| ⑪ | 测试覆盖矩阵 | 新增 `### 测试覆盖矩阵与度量体系` | 模块×用例类型二维矩阵 + 7 项度量指标 + 覆盖缺口分析方法论（缺口分析表+分级规则+追踪闭环） |
| ⑫ | 术语表 | 新增 `## 术语表`（文件末尾） | 12 个核心术语定义 |
| ⑬ | 根因映射表 | 新增 `### 根因映射表与改进项` | 4 大根因→改进项映射 + 9 项改进项验收标准 |

### 4.3 关键设计约束

- 根因定位手段以设计方案 v1.4.0 为准：**6 种**（非 Backlog 记录的 7 种）。Step 3 实施时需同步修正 Backlog BL-215-001 和 Phase 计划中的计数
- T3a 巡检信号为 **6 类**（含 v1.4.0 新增的表单提交响应检测）
- 关键按钮清单为 **7 类**（含 v1.4.0 新增的"新建"和"刷新"）
- 对话框清理逻辑需包含代码片段示例（Playwright `page.keyboard.press('Escape')` + 点击 modal 外部）

---

## 5. F2 详细设计：路由映射表 diff 机制（DT-215-002）

### 5.1 文件变更目标

`devflow-plugin/.trae/skills/api-contract-management/SKILL.md`（当前 706 行 → 预计 ~756 行）

### 5.2 新增章节设计

在 `### Step 4 测试阶段` 的 `#### 前后端字段一致性校验` 之后、`#### 检查清单` 之前新增：

| 序号 | 改动 | 章节位置 | 设计要点 |
|:----:|:-----|:---------|:---------|
| ① | 路由映射表定义 | 新增 `#### 路由映射表 diff 机制` | YAML 格式定义（路由路径/HTTP 方法/请求字段/响应字段/前端调用文件位置）+ 示例 |
| ② | diff 脚本规范 | 同上章节内 | 输入（后端路由定义 + 前端 API 调用代码）→ 输出（差异清单）→ 执行方式（命令行） |
| ③ | 检查清单增强 | `#### 检查清单` | 新增第 5 项：`- [ ] 路由映射表 diff 已执行` |

### 5.3 YAML 路由映射表格式设计

```yaml
# 路由映射表 (route-mapping.yaml)
routes:
  - path: /api/v1/users
    method: GET
    request_fields:
      - name: page
        type: integer
        required: false
    response_fields:
      - name: id
        type: integer
      - name: username
        type: string
    frontend_call: src/api/users.ts#getUsers
  - path: /api/v1/users
    method: POST
    request_fields:
      - name: username
        type: string
        required: true
    response_fields:
      - name: id
        type: integer
    frontend_call: src/api/users.ts#createUser
```

---

## 6. F3 详细设计：Stage4 产出物清单新增（DT-215-003）

### 6.1 文件变更目标

`doc/audit/checklist/DevFlow-产出物清单-Stage4.md`

### 6.2 新增产出物设计

| 序号 | 产出物名称 | 类型 | 文件路径模式 |
|:----:|:----------|:----:|:-------------|
| ① | T1-T4 层间追溯矩阵 | 强制 | `doc/test/{项目名}-T1-T4层间追溯矩阵-v{版本号}.md` |
| ② | 全页面巡检问题表 | 强制 | `doc/test/{项目名}-全页面巡检问题表-v{版本号}.md` |
| ③ | UAT 走查清单 | 强制 | `doc/test/{项目名}-UAT走查清单-v{版本号}.md` |
| ④ | 测试覆盖矩阵 | 强制 | `doc/test/{项目名}-测试覆盖矩阵-v{版本号}.md` |
| ⑤ | 测试度量报告 | 强制 | `doc/test/{项目名}-测试度量报告-v{版本号}.md` |

---

## 7. F4 详细设计：版本号单一事实源落地（DT-215-004）

### 7.1 文件变更目标

| 文件 | 变更类型 | 状态 |
|:-----|:---------|:----:|
| `devflow-plugin/release.ps1` | 新增 JSON 配置同步步骤 | ⏳ 待 Step 3 实现 |
| `devflow-plugin/validate-version-header.ps1` | Phase 1 纳入发布门禁 | ⏳ 待 Step 3 实现 |
| `devflow-plugin/sync-skills.ps1` | 版本号源改为 devflow-config.json | ✅ 已执行 |
| `devflow-plugin/download-devflow.ps1` | 版本号源改为 devflow-config.json | ✅ 已执行 |
| `.devflow/skills/` + `.trae/skills/` 安装副本 | 同步更新 | ✅ 已执行 |

### 7.2 release.ps1 增强设计

在 release.ps1 发布流程中新增 JSON 配置同步步骤：

```powershell
# Step: JSON 配置同步（devflow-config.json → state.json）
$devflowConfig = Get-Content "devflow-config.json" | ConvertFrom-Json
$version = $devflowConfig.devflowVersion

# 同步 state.json
$statePath = ".devflow/state.json"
if (Test-Path $statePath) {
    $state = Get-Content $statePath | ConvertFrom-Json
    $state.devflowVersion = $version
    $state | ConvertTo-Json -Depth 10 | Set-Content $statePath -Encoding UTF8
    Write-Host "✅ state.json 版本号已同步至 $version"
}
```

### 7.3 validate-version-header.ps1 Phase 1 门禁设计

```powershell
# Phase 1: JSON 配置一致性检查（3 份配置）
$configs = @(
    @{ Path = "devflow-config.json"; Field = "devflowVersion" },
    @{ Path = ".devflow/project-config.json"; Field = "devflowVersion" },
    @{ Path = ".devflow/state.json"; Field = "devflowVersion" }
)
# 逐份读取并比对版本号，不一致则退出非零
```

---

## 8. F5 详细设计：Git hook 纳入规范（DT-215-005）

### 8.1 文件变更目标

| 文件 | 变更类型 | 行数 |
|:-----|:---------|:----:|
| `code-version-backup-management/SKILL.md` | 新增"自动备份 hook"章节 | ~15 行 |
| `devflow-init/SKILL.md` | 安装流程纳入 hook 安装步骤 | ~5 行 |

### 8.2 code-version-backup-management 新增章节设计

在 `### 5.3 自动备份：Git Hook 安装` 章节后新增 `### 5.4 自动备份 Hook 规范化（v2.15.0+）`：

| 内容项 | 设计要点 |
|:-------|:---------|
| Hook 工作原理 | pre-push 触发 → 允许主推送通过（exit 0）→ 5 秒延迟后后台镜像推送至 backup 和 github 远程 |
| 安装方式 | devflow-init 自动安装（幂等） / 手动安装（.devflow/hooks/post-push → .git/hooks/pre-push） |
| 日志规范 | `.devflow/logs/backup-hook.log`，含时间戳/推送引用/SHA 验证/成功失败状态 |
| PowerShell 替代 | `.devflow/hooks/push-with-backup.ps1` 手动执行方案 |
| 跳过方式 | `git push --no-verify` |

### 8.3 devflow-init 安装流程增强

在 `## 安装 Git Hook（可选）` 章节中新增：

```markdown
### 自动备份 Hook 安装（v2.15.0+）

如果项目已配置三远程架构（origin/backup/github），DevFlow 会自动安装 pre-push hook：
1. 检测 `.devflow/hooks/post-push` 是否存在
2. 复制到 `.git/hooks/pre-push`
3. 设置可执行权限
4. 创建 `.devflow/logs/` 目录
```

---

## 9. 不适用项说明

| 设计类别 | 说明 |
|:---------|:------|
| Agent 架构设计 | 不适用。DevFlow 为规范框架项目，无 Agent 运行时架构 |
| 前端架构设计 | 不适用。无前端页面/组件 |
| UI/UX 与原型 | 不适用。无用户界面 |
| Figma 交付 | 不适用。无设计稿 |
| 设计系统 | 不适用。无 UI 规范 |
| API 接口设计 | 不适用。无运行时 API |
| 数据模型设计 | 不适用。无数据库 |
| 缓存与消息设计 | 不适用。无运行时缓存/消息队列 |
| 安全设计 | 不适用。无运行时安全需求。版本号完整性通过 validate-version-header.ps1 保障 |
| 性能与容量设计 | 不适用。规范框架项目，无运行时性能指标 |
| 可观测性设计 | 不适用。无运行时服务 |
| 部署架构草案 | 不适用。DevFlow 通过 setup.ps1/setup.sh 安装，无容器化部署 |

> 以上不适用项已确认：DevFlow 为规范框架项目，所有变更为 SKILL.md 文档和 PowerShell 脚本，无运行时系统。

---

## 10. 设计决策汇总

| 决策 ID | 决策标题 | 决策 | 风险 |
|:--------|:---------|:-----|:-----|
| ADR-001 | T1-T4 架构集成方式 | 内联增强 | SKILL.md 膨胀（+112%） |
| ADR-002 | 路由映射表格式 | YAML | 需依赖 YAML 解析库 |
| ADR-003 | 版本号同步方向 | 单向（config→state） | state.json 不可运行时修改 |
| ADR-004 | 根因定位手段数量 | 以 v1.4.0 为准（6 种） | 需修正 Backlog 和 Phase 计划计数 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-02 | 初始创建，含入场检查、追溯矩阵、3 项 ADR、5 项详细设计、不适用项说明 | AA-DevFlow-Dev |
