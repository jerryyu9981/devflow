# DevFlow Release Note — v2.10.2

> 文档类型：单版本发布说明
> 版本：v2.10.2
> 日期：2026-07-26

---

## 版本概要

| 项目 | 内容 |
|:-----|:------|
| 版本号 | v2.10.2 |
| 版本类型 | 修订版 |
| 主题 | 项目配置名片标准化 |
| 发布日期 | 2026-07-26 |
| 前置版本 | v2.10.1（发布规范化 + 遗留治理） |

## 变更清单

### 新增需求

| ID | 标题 | 优先级 | 说明 |
|:--:|:-----|:------:|:------|
| V2102-001 | **项目配置名片标准化** | 🟡 P1 | 统一 project-config.json 为项目名片，实现"两个文件了解一个项目" |

## 重大变更

### 数据结构变更
- `.devflow/project-config.json` **结构重构**
  - 新增 `project.lastRelease.{version, date}` — 记录最后发布的版本号和日期
  - 新增 `remote.github` — 补全三远程架构
  - 精简 `naming.*`、`workflow.*`、`environments.*`、`backup.*`、`migration.*` 无用字段

### 流程变更
- Step 5 发布复盘（5.10）追加 lastRelease 更新断言 — 发布后自动更新 project-config.json 的 lastRelease
- devflow-init 和 devflow-project-config 技能模板同步对齐新结构

## 兼容性

| 维度 | 说明 |
|:-----|:------|
| 向后兼容 | ✅ 完全兼容 v2.10.1，新增字段不影响旧版本读取 |
