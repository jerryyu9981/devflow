# OpenLLM 测试巡检规范缺陷与改进记录 v2.9.1

## 文档元信息

| 属性 | 值 |
|------|-----|
| 文档名称 | OpenLLM 测试巡检规范缺陷与改进记录 |
| 文档版本 | v1.0.0 |
| 文档状态 | [Review] |
| 适用版本 | v2.9.1 |
| 编制人 | AT-OpenLLM-Dev |
| 创建日期 | 2026-08-04 |
| 关联文档 | 《OpenLLM 问题跟踪记录-v2.9.1》（v1.6.0，BUG-291-012）、《OpenLLM 测试报告-v2.9.1》、《OpenLLM 测试计划-v2.9.1》 |

---

## 修订历史

| 日期 | 修订版本 | 修订内容 | 修订人 |
|:----:|:--------:|:--------:|:------:|
| 2026-08-04 | v1.0.0 | 初稿创建：登记 Step 4 测试巡检规范缺陷（网络层监控缺失致 BUG-291-012 漏检）与解决方案 | AT-OpenLLM-Dev |

---

## 1. 背景与触发

### 1.1 触发过程

v2.9.1 Step 4 测试阶段完成后，用户在人工测试阶段反馈"二级页面有部分功能还是报错"。经补检（全页面网络层巡检）发现：

- `GET /api/v1/providers/models/all`、`/providers/models/{id}`、`/providers/{id}/models` 等模型接口**偶发**返回 500；
- 根因：`ModelResponse.extract_metadata` 响应序列化与 DB session 关闭产生竞态，懒加载 `model.provider` 抛 `DetachedInstanceError`；
- 该缺陷已登记 **BUG-291-012**（问题跟踪记录 v1.6.0）并修复。

### 1.2 规范缺陷定义

本缺陷在 Step 4 测试阶段**漏检**至人工测试阶段，暴露出测试巡检规范的覆盖盲区：

> **规范缺陷**：Step 4 测试巡检（T3a 全页面巡检 + E2E）未建立"真实前后端联调下的全页面网络层健康监控"标准动作，导致 HTTP≥500、网络请求失败、console error 等偶发性/时序性问题无法被巡检捕获。

---

## 2. 规范缺陷详述

### 2.1 缺陷清单

| 缺陷 ID | 缺陷描述 | 类别 | 影响 |
|:--------|:---------|:-----|:-----|
| SPEC-291-001 | T3a 全页面巡检仅验证页面可达性与关键元素存在，**未监控 HTTP 响应状态（≥500）、请求失败（requestfailed）、console error** | 测试规范盲区 | 偶发 500 不阻塞主渲染时断言仍通过，缺陷漏检至人工测试 |
| SPEC-291-002 | E2E 断言以页面可达性/元素存在为主，**未订阅浏览器网络层事件**（response / requestfailed / console） | 测试规范盲区 | 竞态型、低复现概率缺陷（如 BUG-291-012）在多轮 E2E 中恰好未命中 |
| SPEC-291-003 | 巡检结果**未区分"环境类提示"与"代码缺陷"**（如 /local-models 在 Ollama 未启动时返回 503"无法连接Ollama服务"） | 判定标准缺失 | 环境问题易误报为代码缺陷，或反向忽略真实缺陷 |

### 2.2 根因分析

| 根因 | 说明 |
|:-----|:-----|
| 巡检断言层级不足 | 既有巡检/E2E 断言停留在"页面是否打开、元素是否存在"，未下沉到"请求是否成功、控制台是否报错"的网络层 |
| 偶发缺陷特性 | BUG-291-012 属**时序竞态**（FastAPI 响应序列化在线程池执行，与 `get_db` session 关闭竞态），单次/低并发访问复现概率低，多轮 E2E 未命中属概率事件 |
| 无专项巡检工具 | 测试阶段无"全页面 × 网络层"监控脚本，无法在真实前后端联调下批量捕获 500/网络失败/console error |

### 2.3 证据

- 后端日志（2026-08-04 11:36:09）：`未处理的异常: Parent instance <Model at 0x...> is not bound to a Session; lazy load operation of attribute 'provider' cannot proceed`（`schemas/provider.py` L133 `extract_metadata` → `DetachedInstanceError` → 500）；
- 补检脚本捕获：`/roles`、`/routing/circuit-breakers` 页面加载时模型接口偶发 500（页面提示"获取基础数据失败: AxiosError: Request failed with status code 500"）；
- 修复前多轮快速巡检可复现 2 次 500，单页独立访问稳定 200 —— 典型竞态特征。

---

## 3. 解决方案

### 3.1 方案一：全页面网络层巡检脚本（治标 —— 补检测手段）

新增巡检脚本 `frontend/tests/e2e/manual_scan_all_pages.py`：

| 项 | 内容 |
|:---|:-----|
| 覆盖范围 | 42 个二级页面（含多级子页：工作台/模型中心/AI 应用/路由与监控/系统管理/EdgeRouter） |
| 监控项 | ① HTTP 响应状态 ≥500（含响应体摘要）；② 网络请求失败（requestfailed + 失败原因）；③ console error |
| 归属定位 | 逐页访问前后记录错误数，将错误精确定位到来源页面 |
| 执行方式 | Playwright（真实登录 admin/admin123，经 vite proxy 访问后端 8000） |
| 输出 | 逐页错误清单 + 总数统计，可用于缺陷登记与回归比对 |

### 3.2 方案二：后端根治（治本 —— 修复 BUG-291-012）

`app/api/providers.py` 5 个模型端点预加载 provider 关系，杜绝 detached 懒加载：

| 端点 | 修复方式 |
|:-----|:---------|
| `GET /{provider_id}/models`（list_models_by_provider） | `db.query(LLMModel).options(joinedload(LLMModel.provider))` |
| `GET /models/all`（list_all_models） | 同上 |
| `GET /models/{model_id}`（get_model） | 同上 |
| `POST /{provider_id}/models`（create_model） | commit 后显式 `_ = model.provider` 触发加载并绑定到对象 |
| `PUT /models/{model_id}`（update_model） | 同上 |

> 根治原则：任何 `response_model=ModelResponse` 的端点返回 ORM 对象前，必须确保 `provider` 关系已加载（joinedload 或显式触发），避免响应序列化阶段访问未绑定 session 的懒加载属性。

### 3.3 方案三：流程改进（固化 —— 纳入测试常规动作）

将网络层巡检固化为 Step 4 测试阶段的标准动作：

| 改进项 | 内容 |
|:-------|:-----|
| 新增巡检档 | T3a 巡检补充"网络层巡检"子项：全页面 × HTTP≥500 / requestfailed / console error |
| 判定标准 | ① HTTP≥500 一律登记缺陷（响应体提示服务未就绪的除外）；② console error 区分代码错误与第三方弃用警告（Element Plus 弃用警告仅记录不登记）；③ 环境类提示（如 Ollama 未启动 503）登记为环境遗留而非代码缺陷 |
| 执行时机 | 每次 Step 4 测试环境就绪后执行一次；缺陷修复后回归执行 |
| 关联缺陷 | BUG-291-012 即由该巡检方式在补检时捕获 |

---

## 4. 验证结果

| 验证项 | 结果 |
|:-------|:-----|
| 42 页全页面网络层巡检 | ✅ 0 个 HTTP≥500、0 个 requestfailed、0 个 console error（仅 /local-models 503 为 Ollama 未启动环境提示，响应体 `{"detail":"无法连接Ollama服务"}` 正常） |
| 多轮快速巡检（3 轮 × 9 页） | ✅ 0 次 500 |
| 单页独立访问（/roles、/routing/circuit-breakers、/models） | ✅ 稳定 200 |
| API 直连（requests 复现带参请求） | ✅ 200 |
| 后端 py_compile | ✅ 通过 |

---

## 5. 输出物清单

| 输出物 | 路径 |
|:-------|:-----|
| 网络层巡检脚本 | `frontend/tests/e2e/manual_scan_all_pages.py` |
| 缺陷登记 | `doc/operation/OpenLLM-问题跟踪记录-v2.9.1.md` v1.6.0（BUG-291-012） |
| 本规范改进记录 | `doc/testing/OpenLLM-测试巡检规范缺陷与改进记录-v2.9.1.md` |

---

## 6. 遗留与后续

| 项 | 说明 | 目标 |
|:---|:-----|:-----|
| Ollama 环境遗留 | /local-models 页依赖 Ollama 服务，本机未启动返回 503（环境提示，非代码缺陷） | 启动 Ollama 后复测 |
| 规范固化 | 将网络层巡检纳入下一版本测试计划模板与 Step 4 执行规范 | 后续版本 |
| 自动化演进 | 将网络层巡检脚本升级为正式 E2E 用例（断言全页面无 ≥500 响应） | 后续版本 |

---

## 7. 审批

| 审批人 | 角色 | 状态 |
|--------|------|------|
| PM-OpenLLM-Dev | 项目经理 | 待审批 |
| AU-OpenLLM-Dev | 审计师 | 待审计 |
