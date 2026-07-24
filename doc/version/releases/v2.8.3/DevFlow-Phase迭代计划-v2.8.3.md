# DevFlow Phase 迭代计划 v2.8.3

> **文档状态**: [Draft]
> **版本**: 1.0.0
> **项目**: DevFlow
> **目标版本**: v2.8.3
> **创建日期**: 2026-07-18

---

## 1. Phase 总览

| Phase | 名称 | BL-ID 范围 | 预估人天 | 交付物 |
|:-----:|------|:----------:|:--------:|--------|
| Phase 1 | 前置修复 + manifest 定义 | BL-01, BL-02 | 1 人天 | devflow-manifest.json + 调用库 |
| Phase 2 | 5 个脚本动态加载改造 | BL-03~BL-07 | 3.5 人天 | 改造后的 5 个脚本 |
| Phase 3 | 三步走校验 + 测试 + 部署 | BL-08~BL-10 | 1.5 人天 | 校验逻辑 + 测试报告 + 部署 |

---

## 2. Phase 详细计划

### Phase 1：前置修复 + Manifest 定义（1 人天）

| BL-ID | 活动 | 验收重点 |
|:-----:|------|---------|
| BL-01 | V260-052 skillMap 历史遗漏修复（已修复，验证通过） | 验证 155/155 一致 |
| BL-02 | 创建 devflow-manifest.json，包含 37+ 个文件条目；设计 JSON Schema | 覆盖所有文件；Schema 可扩展 |
| — | 开发 manifest 解析函数（PowerShell: ConvertFrom-Json；Bash: sed/awk） | 5 个脚本均可正确读取 manifest |

**Phase 1 门禁**：manifest.json 所有 source 路径指向的文件必须全部存在
**Phase 1 产出**：devflow-manifest.json + 各脚本的 manifest 加载函数

### Phase 2：5 个脚本动态加载改造（3.5 人天）

| BL-ID | 活动 | 验收重点 |
|:-----:|------|---------|
| BL-03 | setup.ps1：删除硬编码 skillMap，改为调用 manifest 加载函数 | setup.ps1 无硬编码技能列表 |
| BL-04 | setup.sh：PS 分支 + Bash 分支同步改造 | setup.sh 两个分支均无硬编码 |
| BL-05 | update.ps1：删除硬编码 skillMap | update.ps1 无硬编码 |
| BL-06 | update.sh：删除硬编码 skillMap | update.sh 无硬编码 |
| BL-07 | sync-skills.ps1：删除硬编码 $DevFlowSkills 数组 | sync-skills.ps1 无硬编码 |

**Phase 2 门禁**：5 个脚本全部通过 regex 验证（无硬编码技能列表残留）
**Phase 2 产出**：改造后的 5 个脚本

### Phase 3：三步走校验 + 测试 + 部署（1.5 人天）

| BL-ID | 活动 | 验收重点 |
|:-----:|------|---------|
| BL-08 | download-devflow.ps1 增加安装后 manifest 校验 | clone 后自动检查文件完整性 |
| BL-09 | setup.ps1/sh 安装完成后校验技能数量 | 数量与 manifest.skillCount 一致 |
| BL-10 | devflow-init 增加 init 时技能数量一致性告警 | 不一致时输出告警 |
| — | 22 个自动化测试用例全部通过 | TT 全部 PASS |
| — | 部署执行 + 文档产出 | state.json 更新为 closed |

**Phase 3 门禁**：22 个自动化测试全部 PASS
**Phase 3 产出**：测试报告 + 部署执行报告 + 运维审计报告

---

## 3. 高层验收目标

| 目标 | 衡量标准 | 验证方法 |
|------|---------|---------|
| 单一事实源 | 新增技能只需改 manifest，数量变为 1 处 | 测试新增一个虚拟条目，验证 5 个脚本均感应 |
| 安装完整性 | manifest 中 required=true 的文件必须全部到位 | Download 后自动校验 |
| 数量一致性 | 已安装技能数量 == manifest.skillCount | Setup/Init 后自动校验 |
| 无回归 | 原有 22 个测试用例全部 PASS | 自动化验证 |
