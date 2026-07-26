# DevFlow 本版本 Backlog — v2.10.2

> 文档类型：本版本 Backlog
> 版本：v2.10.2
> 日期：2026-07-26

---

| ID | 标题 | 优先级 | 来源 | 工作量估算 |
|:--:|:------|:------:|:-----|:----------:|
| V2102-001 | **项目配置名片标准化** — ① project-config.json 新增 lastRelease.version + lastRelease.date 字段 ② remote 补全 github 地址 ③ Step 5 发布复盘追加更新断言 ④ devflow-init 创建逻辑对齐 ⑤ devflow-project-config 技能适配 | 🟡 P1 | 复盘改进 | 中（约 6 处修改） |

## 子任务拆解

| 编号 | 子任务 | 工作量 |
|:----:|:-------|:------:|
| 1 | 更新 project-config.json 实际文件结构（加 lastRelease + remote.github） | 小 |
| 2 | Step 5 发布复盘（operations-stage-execution）追加 lastRelease 更新断言 | 小 |
| 3 | devflow-init/SKILL.md 创建逻辑对齐新结构 | 小 |
| 4 | devflow-project-config/SKILL.md 技能模板适配 | 小 |
| 5 | 更新 devflow-config.json 中的 deprecatedFiles 字段（清理 version.json/devflow-manifest.json 记录） | 极小 |

## 优先级汇总

| 优先级 | 数量 | ID |
|:------:|:----:|:----|
| 🟡 P1 | 1 | V2102-001 |
