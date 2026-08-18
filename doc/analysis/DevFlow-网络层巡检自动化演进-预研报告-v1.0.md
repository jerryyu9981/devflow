# DevFlow 网络层巡检自动化演进 — 预研报告 v1.0

> 文档类型：预研报告
> 版本：v1.0
> 日期：2026-08-18
> 作者：AD-DevFlow-Dev（开发工程师）
> 状态：[Draft]
> 关联需求：RT-217-004（V216-004 网络层巡检自动化演进）

---

## 1. 背景与目标

### 1.1 背景

OpenLLM v2.9.1 使用反馈（SPEC-291-001）暴露 DevFlow 测试巡检规范的自动化盲区：T3a 全页面巡检仍为"脚本扫描+逐页问题表"模式（manual_scan_all_pages.py），非正式 E2E 断言用例。该模式：

| 问题 | 说明 |
|:-----|:-----|
| 断言缺失 | 巡检脚本输出问题表供人工判定，无自动 assert 断言 |
| 无 CI 回归 | 巡检脚本不纳入 CI 流水线，仅在 Step 4 手动执行 |
| 报告手工 | 巡检结果需人工整理为逐页问题表，无自动测试报告 |

### 1.2 目标

将 T3a 网络层巡检脚本模式升级为正式 E2E 用例：
1. 巡检脚本模板标准化为 Playwright E2E 用例（attach_network_listeners + assert_network_clean 全页面批量执行）
2. 纳入 CI 回归流水线
3. 巡检结果自动生成测试报告

### 1.3 现状基础

v2.16.0 已将 attach_network_listeners + assert_network_clean 代码模板固化入 testing-stage-execution 规范（L4 网络层断言强制），具备标准化为正式 E2E 用例的规范基础。

---

## 2. 方案设计

### 2.1 方案 A：T3a 巡检用例标准化为 Playwright E2E 用例

将 manual_scan_all_pages.py 模式升级为规范级 E2E 用例模板（写入 testing-stage-execution E2E 章节）：

```python
# T3a-001 全页面网络层巡检（Playwright 标准实现）
import pytest
from playwright.sync_api import Page

ROUTES = [...]  # 从路由清单或配置提取

def test_t3a_network_scan(page: Page):
    attach_network_listeners(page)
    for route in ROUTES:
        page.goto(route)
        # 逐页采集：HTTP 4xx/5xx/requestfailed/console/空渲染/静默失败
    assert_network_clean()  # L4 网络层断言（含 H/I 类过滤）
    # 自动输出逐页问题表（JSON/HTML 报告）
```

| 优势 | 劣势 |
|:-----|:-----|
| 与既有 L4 断言规范无缝衔接 | 需定义 ROUTES 提取规则（路由清单/配置/爬取）|
| Playwright 为标准实现，规范已有模板 | 全页面批量执行耗时较长（可并行优化）|

### 2.2 方案 B：CI 回归集成

| CI 平台 | 集成方式 | 复杂度 |
|:--------|:---------|:------:|
| GitHub Actions | 新增 e2e-network-scan job：checkout → install → playwright → pytest T3a 用例 | 低 |
| GitLab CI | 类似 pipeline job 定义 | 低 |
| 本地/无 CI | 通过 pytest 命令手动触发，纳入 Step 4 门禁执行 | 最低 |

### 2.3 方案 C：巡检结果自动生成测试报告

利用 pytest-html 或 pytest 插件自动生成 HTML 报告（含逐页问题表数据），替代手工整理。问题表数据仍按 v2.16.0 输出物标准（状态码分布/网络失败/console 分类/环境类清单）。

---

## 3. 技术可行性评估

| 评估项 | 结论 | 说明 |
|:-------|:----:|:-----|
| Playwright 用例标准化 | ✅ 可行 | 规范已有 attach_network_listeners/assert_network_clean 代码模板，标准化为 pytest 用例仅需封装 ROUTES 提取 |
| 路由清单提取 | ✅ 可行 | 从路由配置文件/路由注册表提取，或配置显式 ROUTES 列表 |
| CI 集成（GitHub Actions/GitLab CI）| ✅ 可行 | 标准 pipeline 定义，无平台障碍 |
| 自动报告生成 | ✅ 可行 | pytest-html 插件成熟，逐页问题表数据可序列化为 JSON |
| 与 T1-T4 架构兼容 | ✅ 可行 | T3a 用例作为 T3 层新增用例类型，不破坏层间追溯 |
| 跨框架适配（Cypress 等）| ⚠️ 需标注 | 规范标注"Playwright 为标准实现，其他框架按等价事件映射"（与 v2.16.0 一致）|
| 全页面巡检耗时 | ⚠️ 可优化 | 大型项目全页面巡检耗时长；通过并行执行/风险页子集限定缓解（沿用 v2.16.0 多轮策略范围限定）|

**总体可行性结论：✅ 可行**，无技术阻碍。

---

## 4. 结论

| 结论 | 内容 |
|:-----|:-----|
| **可行性判定** | ✅ **可行** |
| 核心依据 | 规范层基础已就绪（v2.16.0 L4 断言模板）、Playwright 生态成熟、CI 集成无平台障碍 |
| 实施范围（建议 v2.18.0）| ① testing-stage-execution 新增 T3a 网络层巡检 E2E 用例模板（约 30 行）② project-document-templates 测试用例模板引用（v2.17.0 已完成）③ CI 集成示例章节（约 20 行）④ 自动报告方案说明（约 10 行）|
| 预估工作量 | ~60 行技能文档增强 + CI 配置示例 |

---

## 5. 后续计划（移交 v2.18.0 候选）

| 项 | 内容 |
|:---|:-----|
| 目标版本 | v2.18.0（候选，待 Step 0 纳入）|
| 实施任务 | T3a E2E 用例模板入规范 + CI 集成示例 + 自动报告方案 |
| 验收方向 | 全栈项目 Step 4 可直接引用 T3a E2E 用例模板执行巡检并自动产出报告 |
| 关联 | 与 V216-003（T3a 强制标记，v2.17.0 已完成）衔接：强制执行 + 自动化用例 = 全栈项目 Step 4 标准动作闭环 |

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-18 | 初始创建，结论：✅ 可行，建议 v2.18.0 实施 | AD-DevFlow-Dev |
