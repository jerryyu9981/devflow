# OpenLLM 测试巡检规范完善方案 — v2.9.1

> 文档类型：规范完善方案
> 版本：v2.9.1
> 状态：[Review]
> 日期：2026-08-04
> 编制人：AT-OpenLLM-Dev
> 输入依据：《OpenLLM-测试巡检规范缺陷与改进记录-v2.9.1.md》（v1.0.0，SPEC-291-001~003）+ BUG-291-012
> 目标规范：`testing-stage-execution`（DevFlow Step 4 测试阶段主控技能）

---

## 1. 方案概述

### 1.1 目标

在 DevFlow `testing-stage-execution` 测试规范层面系统性补齐"真实前后端联调下的网络层健康监控"标准动作，根治 SPEC-291-001~003 三类覆盖盲区，使偶发性/时序性缺陷（如 BUG-291-012 竞态 500）在 Step 4 测试阶段即可被巡检捕获，而非漏检至人工测试。

### 1.2 规范现状核对（改进基线）

现有规范（v2.15.0 集成的 T1-T4 架构）已具备：

| 已有能力 | 章节 | 与本方案的差距 |
|:---------|:-----|:---------------|
| T3a 六步闭环工作流 | 六步闭环工作流 | 巡检步骤未强制"响应体摘要 + 网络失败采集"，问题分类无"环境类/弃用警告"分支 |
| 6 类巡检信号表 | 6 类巡检信号采集表 | HTTP≥400 单行未拆分 4xx/5xx，缺 requestfailed 信号，缺响应体采集 |
| 7 类标准问题分类 | 7 类标准问题分类表 | 无环境类提示（服务未就绪 503）、第三方弃用警告分类 |
| L1/L2/L3 断言分级 | 断言分级规范 | L1 页面加载断言未强制网络层检查，"页面可达≠请求成功"未写入禁止模式 |
| E2E 四轨贯通 | 4.5 E2E 测试 | E2E 断言以页面/流程为主，未定义浏览器网络层事件订阅标准动作与多轮策略 |

### 1.3 本方案 8 项改进全景

| 序号 | 改进项 | 对应 SPEC | 层级 |
|:----:|:-------|:---------:|:-----|
| IMP-1 | T3a 巡检信号表升级：6 类 → 8 类（拆分 4xx/5xx + 新增 requestfailed + 响应体摘要） | SPEC-291-001 | 信号采集 |
| IMP-2 | 问题分类扩展：7 类 → 9 类（新增 H 环境类提示 / I 第三方弃用警告） | SPEC-291-003 | 判定标准 |
| IMP-3 | 断言分级强制化：L3 网络层断言成为 T3a/T3b/E2E 强制项 | SPEC-291-001/002 | 断言门禁 |
| IMP-4 | E2E 网络层事件订阅标准动作 + 统一监听器代码模板 | SPEC-291-002 | 执行动作 |
| IMP-5 | 偶发缺陷多轮巡检策略（≥3 轮）+ 跨轮回归比对 | SPEC-291-002 | 执行策略 |
| IMP-6 | 根因定位手段扩展：6 种 → 7 种（并发/重复访问时序复现） | SPEC-291-002 | 根因定位 |
| IMP-7 | 巡检输出物标准：逐页问题表扩展（状态码分布/网络失败/console 分类/环境类清单） | SPEC-291-001/003 | 输出物 |
| IMP-8 | 门禁与完成标准明确化：代码类 ≥500=0、requestfailed=0、代码类 console error=0 | SPEC-291-001 | 门禁 |

---

## 2. 规范缺陷 → 规范盲区映射

| 使用反馈缺陷 | 规范盲区定位 | 说明 |
|:-------------|:-------------|:-----|
| SPEC-291-001：T3a 未监控 HTTP≥500/requestfailed/console error | 信号表粒度不足 + 无响应体采集 | 现有"HTTP ≥ 400"单行信号未区分 4xx（契约问题，A 类）与 5xx（后端运行时错误，B 类），且未定义响应体摘要采集，无法区分"代码缺陷 500"与"环境提示 503" |
| SPEC-291-002：E2E 未订阅网络层事件 | L3 断言非强制 + 无统一监听器模板 | L1/L2/L3 分级中 L1 仅"页面可达"，未强制"请求成功"；E2E 无 `page.on('response'/'requestfailed'/'console')` 标准动作，竞态缺陷靠运气命中 |
| SPEC-291-003：未区分环境类提示与代码缺陷 | 问题分类缺环境类分支 + 无多轮策略 | 7 类分类全是代码缺陷路径；503"无法连接Ollama服务"无归处；偶发缺陷无"多轮巡检提升命中率"策略 |

---

## 3. 规范完善设计（8 项改进详述）

### 3.1 IMP-1：T3a 巡检信号表升级（6 类 → 8 类）

**改动位置**：`testing-stage-execution` → T3a 巡检信号和问题分类 → 6 类巡检信号采集表

| 信号类型 | Playwright API | 采集方式 | 对应问题 |
|:---------|:---------------|:---------|:---------|
| HTTP 4xx | `page.on('response')` | 拦截响应，检查 `400 ≤ status < 500` | 接口契约不一致（A 类）|
| HTTP ≥ 500 | `page.on('response')` | 拦截响应，检查 `status ≥ 500`，**采集响应体摘要**（前 200 字符）| 后端运行时错误（B 类）/ 环境类提示（H 类）|
| 网络请求失败 | `page.on('requestfailed')` | 捕获失败请求 + 失败原因（`request.failure()`）| 网络断点/代理错误/跨域（新增）|
| console.error | `page.on('console')` | 过滤 `msg.type() === 'error'`，记录 message 文本 | 前端逻辑错误（D 类）/ 第三方弃用警告（I 类）|
| pageerror | `page.on('pageerror')` | 直接捕获未处理异常 | 前端运行时异常（C 类）|
| 接口 200 但渲染空 | `page.evaluate()` + DOM 检查 | 主内容区域 `children.length === 0` | 字段映射/渲染问题（E 类）|
| 静默失败（行为信号） | `btn.click()` + 网络计数器 + DOM 检查 | 关键按钮点击后无新请求且无 UI 响应 | 空实现（F 类）|
| 表单提交响应 | `submit_btn.click()` + 错误消息检测 | 提交后 4xx/5xx 被前端吞掉 | 表单错误被吞（G 类）|

**关键增强点**：
- 原"HTTP ≥ 400"拆分为"HTTP 4xx"与"HTTP ≥ 500"两行，5xx 必须采集响应体摘要；
- 新增"网络请求失败"信号行（requestfailed）；
- 每个响应事件必须关联**来源页面**（逐页访问前后记录错误数），错误精确定位到页。

### 3.2 IMP-2：问题分类扩展（7 类 → 9 类）

**改动位置**：T3a 巡检信号和问题分类 → 7 类标准问题分类表

| 类别 | 模式名称 | 典型信号 | 判定方法 | 处置路径 |
|:----:|:---------|:---------|:---------|:---------|
| A 类 | 接口契约不一致 | HTTP 422/404 | 响应体字段校验 | T1 契约层修复 |
| B 类 | 后端运行时错误 | HTTP 500（代码异常）| **响应体含异常/堆栈/非服务提示** | Step 3 后端修复 → 登记缺陷 |
| C 类 | 前端运行时异常 | pageerror | 堆栈分析 | Step 3 前端修复 |
| D 类 | 前端逻辑错误 | console.error（代码类）| message 含业务/代码上下文 | Step 3 前端修复 |
| E 类 | 渲染空/白屏 | 200 但 DOM 空 | 字段映射检查 | Step 3 前端修复 |
| F 类 | 静默失败/空实现 | 按钮无响应 | handler 检查 | Step 3 前端修复 |
| G 类 | 表单提交错误被吞没 | 4xx/5xx 无提示 | error handler 检查 | Step 3 前端修复 |
| **H 类** | **环境类提示（服务未就绪/依赖缺失）** | **HTTP 503/504 + 响应体 `{"detail":"无法连接..."}` 类服务提示** | **响应体明确指向外部服务/依赖未启动** | **登记为环境遗留，不进缺陷闭环；环境恢复后复测** |
| **I 类** | **第三方弃用警告** | **console.error 含 "deprecated"/"deprecation"** | **message 匹配弃用关键词** | **仅记录，不登记缺陷** |

**判定优先级规则**（写入规范）：
```
HTTP ≥ 500 → 读取响应体摘要
  ├─ 响应体含服务未就绪/依赖提示（如 503 + "无法连接Xxx服务"）→ H 类（环境遗留）
  ├─ 响应体含异常堆栈/业务错误 → B 类（代码缺陷，登记）
  └─ 响应体为空/通用错误 → 直连复现后归 B 类
console.error → 检查 message
  ├─ 含 deprecated/deprecation → I 类（仅记录）
  └─ 否则 → D 类（代码缺陷）
```

### 3.3 IMP-3：断言分级强制化（L3 网络层断言）

**改动位置**：断言分级规范（L1/L2/L3）

现有分级补充强制声明：

| 层级 | 断言内容 | 强制等级 |
|:----:|:---------|:---------|
| L1 页面可达 | `page.goto(url)` + `networkidle` + 关键元素可见 | 强制 |
| L2 交互正确 | 表单/按钮/CRUD 操作结果符合预期 | 强制 |
| **L3 网络层健康（新增强制）** | ① 无代码类 HTTP≥500（H 类环境提示除外）② 无 requestfailed ③ 无代码类 console.error（I 类弃用警告除外）| **强制（T3a/T3b/E2E 通用）** |

**禁止模式清单新增**（写入禁止模式）：

> ❌ 禁止"页面可达即通过"——页面打开成功但请求返回 500 时，断言必须失败。**"页面可达 ≠ 请求成功 ≠ 功能正确"**。

### 3.4 IMP-4：E2E 网络层事件订阅标准动作

**改动位置**：E2E 测试（4.5 四轨贯通）→ 新增"网络层事件订阅标准动作"

```python
# 标准动作：E2E 用例强制订阅网络层事件（写入规范模板）
network_errors = {"http5xx": [], "request_failed": [], "console_errors": []}

def attach_network_listeners(page):
    def on_response(resp):
        if resp.status >= 500:
            body = ""
            try:
                body = resp.text()[:200]  # 响应体摘要
            except Exception:
                pass
            network_errors["http5xx"].append(
                {"url": resp.url, "status": resp.status, "body": body}
            )
    def on_request_failed(req):
        network_errors["request_failed"].append(
            {"url": req.url, "reason": req.failure}
        )
    def on_console(msg):
        if msg.type == "error":
            network_errors["console_errors"].append(msg.text)
    page.on("response", on_response)
    page.on("requestfailed", on_request_failed)
    page.on("console", on_console)

def assert_network_clean():
    code_5xx = [e for e in network_errors["http5xx"]
                if not is_env_hint(e["body"])]          # 排除 H 类环境提示
    code_console = [m for m in network_errors["console_errors"]
                    if "deprecated" not in m.lower()]    # 排除 I 类弃用警告
    assert not code_5xx, f"代码类 HTTP≥500: {code_5xx}"
    assert not network_errors["request_failed"], \
        f"网络请求失败: {network_errors['request_failed']}"
    assert not code_console, f"代码类 console error: {code_console}"
```

**规范要求**：T3b 深度用例与 4.5 E2E 用例**必须**调用 `attach_network_listeners` + 用例末尾 `assert_network_clean`，列入 T3b/E2E 断言模板。

### 3.5 IMP-5：偶发缺陷多轮巡检策略（≥3 轮）

**改动位置**：T3a 六步闭环工作流 → 步骤 2 自动化巡检

| 项 | 规范内容 |
|:---|:---------|
| 触发条件 | 首轮巡检发现 0 个缺陷，但存在 500 类风险页面（含模型/数据异步加载页）时 |
| 执行轮次 | 至少 3 轮快速巡检（全页面 × 网络层监控）|
| 目的 | 提升偶发/竞态缺陷（如 DetachedInstanceError 竞态 500）捕获概率 |
| 记录 | 每轮独立输出错误计数，跨轮对比；任一轮出现代码类 500 → 立即登记缺陷 |
| 依据 | BUG-291-012 经验：单轮未命中属概率事件，3 轮×9 页可稳定复现 |

### 3.6 IMP-6：根因定位手段扩展（6 种 → 7 种）

**改动位置**：根因定位 6 种手段表 → 新增

| 定位手段 | 适用类别 | 方法 |
|:---------|:---------|:-----|
| 日志分析 | A/B/C/D 类 | 查看后端日志、浏览器 Network 面板 |
| 堆栈追踪 | C/D 类 | pageerror stack trace、console.error 调用链 |
| 直连复现 | A/B 类 | curl/httpie 直连接口，绕过前端确认归属 |
| DOM 检查 | E 类 | 接口返回 vs 渲染代码字段映射 |
| 源码检查 | F 类 | handler 空实现/TODO/事件绑定检查 |
| 错误处理检查 | G 类 | catch/then 分支错误提示逻辑检查 |
| **并发/时序复现（新增）** | **B 类（竞态型）** | **快速连续访问/多轮重复请求触发竞态（如响应序列化与 DB session 关闭竞态），比对单次稳定与多轮偶发差异** |

### 3.7 IMP-7：巡检输出物标准

**改动位置**：T3a 六步闭环工作流 → 步骤 6 报告更新

逐页巡检问题表（测试执行证据）扩展为：

| 字段 | 内容 |
|:-----|:-----|
| 页面路由 | 巡检页面路径 |
| HTTP 状态码分布 | 该页所有请求的状态码计数（200/4xx/5xx）|
| 网络失败清单 | requestfailed URL + 失败原因 |
| console error 清单 | 分类：代码类（D）/弃用警告（I）|
| 环境类提示清单 | H 类：URL + 响应体摘要 + 依赖说明 |
| 问题分类 | A~I 类 |
| 关联缺陷 | BUG-ID（如 BUG-291-012）|

### 3.8 IMP-8：门禁与完成标准

**改动位置**：T3 通过标准 + 测试矩阵通过标准

| 门禁项 | 通过标准 |
|:-------|:---------|
| T3a 巡检 | 代码类 HTTP≥500 = 0、requestfailed = 0、代码类 console error = 0；H 类环境提示允许遗留但必须登记环境遗留清单 |
| T3b/E2E | 每个用例通过前必须执行 `assert_network_clean`（L3 断言）|
| 偶发缺陷 | 多轮巡检任一轮出现代码类 500 → 门禁不通过，回退 Step 3 |

---

## 4. 落地映射（规范 → 文档/产物改动）

| 规范改动 | 目标文件/章节 | 产出物 |
|:---------|:--------------|:-------|
| IMP-1 信号表 8 类 | `testing-stage-execution` T3a 信号表 | 技能章节更新 |
| IMP-2 分类 9 类 + 判定优先级 | `testing-stage-execution` 问题分类表 | 技能章节更新 |
| IMP-3 L3 强制断言 + 禁止模式 | `testing-stage-execution` 断言分级 + 禁止模式 | 技能章节更新 |
| IMP-4 网络层订阅标准动作 | `testing-stage-execution` E2E 章节 | 代码模板入规范 |
| IMP-5 多轮策略 | `testing-stage-execution` T3a 六步工作流 | 技能章节更新 |
| IMP-6 根因定位第 7 种 | `testing-stage-execution` 根因定位表 | 技能章节更新 |
| IMP-7 输出物标准 | 测试执行证据模板 + Stage4 产出物清单 | 模板更新 |
| IMP-8 门禁标准 | `testing-stage-execution` T3 通过标准 + 测试矩阵 | 技能章节更新 |
| 项目落地 | OpenLLM 测试计划模板 + 巡检脚本 | `manual_scan_all_pages.py` 固化 |

---

## 5. 验收标准

| 验收项 | 验收方法 | 通过标准 |
|:-------|:---------|:---------|
| 规范章节可检索 | 读取更新后的 `testing-stage-execution` | 8 项改进全部落位，章节编号连续 |
| 信号表完整性 | 对照本文档 IMP-1 | 8 类信号 + 响应体摘要 + 来源页面 |
| 判定标准可执行 | 用 BUG-291-012 + /local-models 503 用例演练 | 500（竞态）→ B 类登记；503（Ollama）→ H 类环境遗留 |
| L3 断言强制 | 检查 T3b/E2E 模板 | `assert_network_clean` 为强制调用 |
| 门禁生效 | 模拟代码类 500 场景 | T3a 门禁不通过 |

---

## 6. 实施建议

1. **版本归属**：建议纳入 DevFlow 下一版本（v2.16.0）测试规范增强，走完整 Step 0~5 流程；
2. **优先级**：IMP-4（E2E 订阅标准动作）与 IMP-8（门禁）为 P0，直接决定 Step 4 能否捕获偶发缺陷；IMP-1/2/3 为 P1；IMP-5/6/7 为 P2；
3. **OpenLLM 短期落地**：本方案 8 项改进先以 OpenLLM v2.9.1 已验证的巡检脚本为参考实现，纳入下一版本测试计划模板；
4. **回归验证**：规范更新后，用 BUG-291-012 修复前后场景验证新规范可捕获。

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:-----|
| v1.0 | 2026-08-04 | 初始创建，基于 SPEC-291-001~003 输出规范层面 8 项改进方案 | AT-OpenLLM-Dev |
