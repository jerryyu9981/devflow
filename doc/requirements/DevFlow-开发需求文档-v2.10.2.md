# DevFlow 开发需求文档 — v2.10.2

> 文档类型：开发需求文档
> 版本：v2.10.2
> 日期：2026-07-26

---

## 1. 业务目标

| 目标 | 内容 |
|:-----|:------|
| **业务目标** | 统一项目配置名片结构，实现"了解一个项目只需看 project-config.json + state.json 两个文件" |
| **用户目标** | 开发者打开 project-config.json 即可看到项目名、最新发布版本/日期、所有仓库地址 |
| **技术目标** | project-config.json 增加 lastRelease 字段、补全三远程架构、发布复盘联动更新 |
| **成功指标** | project-config.json 包含 lastRelease.version/date 字段；Step 5 发布复盘包含更新 lastRelease 的断言 |

## 2. 功能需求

### 2.1 V2102-001：项目配置名片标准化

| 字段 | 内容 |
|:-----|:------|
| **Backlog ID** | V2102-001 |
| **优先级** | 🟡 P1 |
| **来源** | `doc/design/DevFlow-项目配置名片方案-v1.0.md` |
| **描述** | 统一 project-config.json 为"项目名片"，开发者打开该文件和 state.json 即可了解项目全貌 |

**子任务列表**：

| 编号 | 子任务 | 说明 |
|:----:|:-------|:------|
| 1 | 更新 project-config.json 实际文件结构 | 新增 `project.lastRelease.version`、`project.lastRelease.date`；`remote` 补全 `github` 地址；精简 `_meta.description` |
| 2 | Step 5 发布复盘追加 lastRelease 更新断言 | `operations-stage-execution.md` 5.10 发布复盘步骤追加：更新 project-config.json 的 lastRelease 字段 |
| 3 | devflow-init/SKILL.md 创建逻辑对齐 | 初始化创建 project-config.json 时包含新字段（lastRelease 初始为空） |
| 4 | devflow-project-config/SKILL.md 技能适配 | 技能文档中的配置模板更新为新结构 |
| 5 | devflow-config.json deprecatedFiles 更新 | 更新已清除文件的记录 |

### 2.2 project-config.json 目标结构

```json
{
  "_meta": { "description": "...", "schemaVersion": "1.1.0", "lastUpdated": "2026-07-26" },
  "project": {
    "name": "DevFlow",
    "version": "v2.10.0",
    "description": "DevFlow 软件开发工程规范框架",
    "lastRelease": { "version": "v2.10.1", "date": "2026-07-26" }
  },
  "remote": {
    "origin": "http://192.168.0.14/jerry.yu/devflow.git",
    "backup": "http://192.168.0.14/jerry.yu/devflow-backup.git",
    "github": "git@github.com:jerryyu9981/devflow.git"
  },
  "branchStrategy": "git-flow"
}
```

## 3. 非功能需求

| 需求 | 说明 |
|:-----|:------|
| **向后兼容** | 新增 lastRelease/remote.github 字段，对旧版本读取无影响（JSON 解析忽略未知字段） |

## 4. 范围边界

### 包含范围
- project-config.json 字段补充（lastRelease + remote.github）
- Step 5 发布复盘联动更新断言
- devflow-init / devflow-project-config 创建逻辑对齐
- devflow-config.json deprecatedFiles 更新

### 不包含范围
- state.json 合并到 project-config.json（已明确排除）
- 技术债务偿还（本版本为纯功能补充）

## 5. 验收标准清单

| 子任务 | 验收条件 | 验证方式 |
|:-------|:---------|:---------|
| 1 | project-config.json 包含 lastRelease.version/date + remote.github | Read 文件确认字段存在 |
| 2 | Step 5 发布复盘含"更新 lastRelease"断言 | Grep operations-stage-execution.md 确认 |
| 3 | devflow-init 创建的新 project-config.json 含新字段 | 读 SKILL.md 中模板确认 |
| 4 | devflow-project-config 技能模板对齐新结构 | 读 SKILL.md 确认 |
| 5 | devflow-config.json deprecatedFiles 已更新 | Read 确认 |
