# DevFlow 运维手册 v2.9.2

> **文档类型**: 运维手册（含运维移交清单）
> **版本**: v2.9.2
> **项目**: DevFlow
> **日期**: 2026-07-23

---

## 1. 项目概述

DevFlow 是一个软件开发工程规范插件，提供 6 阶段工程管控、28 个核心技能和 24 个文档模板。

## 2. 目录结构

| 目录 | 说明 |
|:-----|:------|
| `version.json` | 项目根版本文件 |
| `devflow-plugin/` | 插件主目录（技能 + 配置 + 脚本） |
| `.devflow/` | 项目配置 |
| `doc/` | 全部文档 |
| `skills/` | L1/L2/L3 技能文件 |

## 3. 关键配置

| 文件 | 用途 |
|:-----|:------|
| `devflow-plugin/devflow-config.json` | 全局配置 — 唯一权威配置源 |
| `.devflow/config.json` | 项目级配置 |
| `version.json` | 项目版本号 |

## 4. 运维移交清单

| 移交项 | 说明 | 负责人 |
|:-------|:-----|:-------|
| 配置文件说明 | 三配置层次结构、字段含义、更新顺序 | PM-DevFlow-Dev |
| 备份文件位置 | `.devflow/backup/` — 弃用文件备份 | PM-DevFlow-Dev |
| 文档发布流程 | 6 阶段开发流程（需求→设计→开发→测试→部署→运维） | PM-DevFlow-Dev |
| Release 流程 | 版本号更新→Release Note→Changelog→Tag | PM-DevFlow-Release |

## 5. 常见故障与排障

| 故障 | 排障步骤 |
|:-----|:---------|
| 版本号不一致 | 检查三个配置文件（version.json / devflow-config.json / .devflow/config.json）版本号 |
| 弃用文件残留 | 检查 devflow-plugin/ 下是否有 version.json 或 devflow-manifest.json |
| 模板章节缺失 | Grep "风险归集检查" 确认 operations-stage-execution.md 是否包含必填章节 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-23 | v2.9.2 运维手册初始创建 | PM-DevFlow-Release |
