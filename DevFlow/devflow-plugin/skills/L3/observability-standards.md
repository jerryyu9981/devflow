---
name: observability-standards
description: 可观测性标准规范。定义日志格式、指标命名、链路追踪、告警规则和 Dashboard 标准。基于三大支柱（Logging/Metrics/Tracing）。被 design-stage-execution 和 operations-stage-execution 调用。
---

## 定位

说明本技能是可观测性工程的标准参考，定义基于三大支柱（日志、指标、链路追踪）的统一规范，包括日志格式、指标命名、告警规则模板、Dashboard 布局和 OpenTelemetry 集成。本技能不替代 `operations-stage-execution` 的部署和运维检查，只定义可观测性基础设施本身的配置标准。

## 触发条件

- Step 2 设计阶段涉及可观测性设计时自动触发
- Step 5 部署运维阶段配置监控告警时调用
- 新服务/模块引入可观测性时参考
- 排查线上问题时参考日志和链路追踪规范

## 可观测性三大支柱

可观测性（Observability）与监控（Monitoring）的区别：
- 监控：知道系统什么时候出问题（已知故障）
- 可观测性：能够在不新增代码的情况下，通过已有数据推断出为什么出问题（未知故障）

三大支柱协作关系：
```
日志（Logs）— 发生了什么（事件）
指标（Metrics）— 趋势如何（聚合数据）
链路追踪（Tracing）— 为什么慢/错（请求全貌）
```

## 1. 日志规范（Logging）

### 结构化日志格式
所有日志必须使用结构化 JSON 格式，禁止纯文本日志。严格禁用 `console.log()` 替代日志库。

```json
{
  "timestamp": "2026-06-21T10:30:00.123Z",
  "level": "INFO",
  "traceId": "abc123def456",
  "spanId": "span789",
  "service": "user-service",
  "module": "auth.controller",
  "message": "User login successful",
  "userId": "u_10086",
  "durationMs": 45,
  "requestId": "req_abc123",
  "env": "production",
  "version": "v2.4.1"
}
```

### 必填字段
| 字段 | 类型 | 说明 |
|------|------|------|
| timestamp | string | ISO 8601 UTC 时间戳，精确到毫秒 |
| level | string | DEBUG / INFO / WARN / ERROR / FATAL |
| traceId | string | 链路追踪 ID，关联 Tracing |
| spanId | string | Span ID，关联 Tracing |
| service | string | 服务名，与注册中心一致 |
| module | string | 模块名，如 auth.controller |
| message | string | 人类可读的描述（中文或英文） |
| env | string | 环境名：dev / test / production |

### 按场景建议的字段
| 场景 | 建议字段 |
|------|---------|
| API 请求 | method, path, statusCode, durationMs, clientIp |
| 数据库操作 | query (脱敏), dbName, durationMs, rowsAffected |
| 外部调用 | targetService, targetEndpoint, durationMs, statusCode |
| 业务事件 | eventType, entityType, entityId, operatorId |
| 错误/异常 | errorType, stackTrace (仅 ERROR), retryCount |

### 日志级别使用规则
| 级别 | 使用场景 | 示例 |
|------|---------|------|
| DEBUG | 开发调试信息，生产环境默认关闭 | 变量值、SQL 语句、详细执行路径 |
| INFO | 关键业务节点、状态变更 | 用户注册、订单创建、支付回调到达 |
| WARN | 可恢复的异常、降级操作 | 第三方超时后重试成功、限流触发 |
| ERROR | 不可恢复的错误、需要人工介入 | 数据库连接失败、支付失败、空指针 |
| FATAL | 系统崩溃、完全不可用 | 启动失败、主进程退出 |

### 禁止记录的内容
- 密码、令牌、API 密钥（任何级别）
- 用户个人隐私（身份证号、手机号需脱敏，保留后 4 位）
- 完整的请求/响应体（超过 1KB 只记录摘要）
- SQL 完整语句（记录摘要和参数类型，不记录具体参数值）

### 日志采样策略
| 级别 | 采样率 | 说明 |
|------|--------|------|
| ERROR | 100% | 所有错误必须完整记录 |
| WARN | 100% | 所有警告必须完整记录 |
| INFO | 10%（高流量接口）或 100%（低流量） | 按端点和流量级别配置 |
| DEBUG | 采样关闭或按需开启 | 生产环境默认关闭 |

### 日志轮转与保留
| 环境 | 保留周期 | 轮转策略 |
|------|---------|---------|
| Dev | 7 天 | 每日轮转 |
| Test | 30 天 | 每日轮转，按级别独立文件 |
| Pro | 90 天（可压缩归档至 365 天） | 每小时轮转（高流量），每日轮转（低流量） |

## 2. 指标规范（Metrics）

### 三种指标类型
| 类型 | 说明 | 示例 |
|------|------|------|
| Counter（计数器） | 只增不减的累计值 | 请求总数、错误总数 |
| Gauge（仪表盘） | 可增可减的瞬时值 | 当前连接数、内存使用率 |
| Histogram（直方图） | 值的分布统计 | 响应时间分布、请求大小分布 |

### RED 方法（面向服务）
| 指标 | 含义 | 示例 | 典型阈值 |
|------|------|------|---------|
| Rate | 请求速率 | requests_total / http_requests_total | 视业务而定 |
| Errors | 错误率 | http_requests_errors_total / http_requests_total | < 1% |
| Duration | 响应时间 | http_request_duration_ms{quantile="0.99"} | P50 < 200ms, P99 < 1000ms |

### USE 方法（面向资源）
| 指标 | 含义 | 示例 | 典型阈值 |
|------|------|------|---------|
| Utilization | 资源利用率 | cpu_utilization_ratio, memory_utilization_ratio | CPU < 80%, 内存 < 80% |
| Saturation | 资源饱和程度 | disk_io_queue_depth, thread_pool_active_ratio | < 80% |
| Errors | 错误计数 | disk_read_errors_total | 无持续错误 |

### 指标命名规范
遵循 Prometheus 命名规范：`{namespace}_{subsystem}_{metric_unit}[{labels}]`
- namespace：服务/模块名，如 http、db、cache、queue
- subsystem：子模块，如 request、connection、query
- metric_unit：指标名 + 可选单位，如 total、duration_seconds、bytes、ratio
- labels：标签，如 method="/api/users", status="200", env="production"

示例：
```
http_requests_total{method="GET", endpoint="/api/users", status="200"}
db_query_duration_seconds{query="select_user", db="primary"}
cache_hit_ratio{service="user-service", cache="redis"}
```

### 关键指标清单

每个服务必须暴露以下指标：

| 类别 | 指标名 | 类型 | 说明 |
|------|--------|------|------|
| HTTP | http_requests_total | Counter | 请求总数 |
| HTTP | http_request_duration_seconds | Histogram | 请求延迟 |
| HTTP | http_requests_in_flight | Gauge | 正在处理的请求数 |
| DB | db_query_duration_seconds | Histogram | 数据库查询延迟 |
| DB | db_connections_open | Gauge | 打开的数据库连接数 |
| Cache | cache_hit_total | Counter | 缓存命中数 |
| Cache | cache_miss_total | Counter | 缓存未命中数 |
| Queue | queue_depth | Gauge | 消息队列深度 |
| Queue | queue_process_duration_seconds | Histogram | 消息处理延迟 |
| Runtime | go_routines / python_threads | Gauge | 运行时协程/线程数 |
| Runtime | memory_usage_bytes | Gauge | 内存使用量 |
| Runtime | cpu_usage_ratio | Gauge | CPU 使用率 |
| Business | active_users | Gauge | 活跃用户数 |
| Business | order_total | Counter | 订单总数 |

## 3. 链路追踪规范（Tracing）

### OpenTelemetry 集成规范
| 配置项 | 推荐值 | 说明 |
|--------|--------|------|
| 协议 | OTLP gRPC / HTTP | 推荐 gRPC 以提高性能 |
| 采样策略 | 头部采样（Head Sampling）+ 尾部采样（Tail Sampling） | 低流量 100%，高流量按需采样 |
| 默认采样率 | 生产环境 10% | 高流量可降至 1%，错误追踪 100% |
| Span 导出 | 批次导出，每 5 秒或 512 条 | 避免单条导出性能开销 |
| 上下文传播 | W3C TraceContext（traceparent header） | 标准 HTTP 头，兼容性好 |

### Span 命名规范
```
{操作类型}.{资源名}
```
操作类型：GET / POST / PUT / DELETE / QUERY / PUBLISH / CONSUME / RPC
资源名：/api/users / select_user / send_email / process_order

示例：
```
GET./api/v1/users/{userId}
POST./api/v1/orders
QUERY.select_user
PUBLISH.order_created
```

### Span Attributes（标签字段）
| 类别 | 必须属性 | 建议属性 |
|------|---------|---------|
| HTTP | http.method, http.url, http.status_code, http.host | http.user_agent, http.request_content_length |
| 数据库 | db.system, db.name, db.statement（脱敏） | db.rows_affected, db.duration_ms |
| RPC | rpc.system, rpc.service, rpc.method | rpc.status_code |
| 消息队列 | messaging.destination, messaging.system | messaging.message_id, messaging.consumer_id |
| 业务 | business.type, business.entity_id | business.operator_id |

## 4. 告警规则规范

### 告警严重级别
| 级别 | 响应时间 | 通知方式 | 示例 |
|------|---------|---------|------|
| P0（灾难） | 15 分钟内 | 电话 / 即时通讯 + 电话 | 服务完全不可用、数据持久性失败、安全事件 |
| P1（危急） | 1 小时内 | 即时通讯 | 核心功能错误率＞5%、P99 延迟 > 5s、磁盘满 |
| P2（告警） | 24 小时内 | 即时通讯 | 错误率 > 1%、P99 延迟 > 2s、CPU > 90% |
| P3（通知） | 下个工作日 | 邮件 / 通知 | 错误率 > 0.1%、证书即将过期、磁盘 > 70% |

### 告警规则模板
```yaml
# 服务不可用
rule: "service_down"
expr: "up{service='user-service'} == 0"
for: 30s
severity: P0
labels:
  team: backend
annotations:
  summary: "{{$labels.service}} is down"
  description: "{{$labels.service}} instance {{$labels.instance}} has been down for > 30s"
  
# 错误率过高
rule: "high_error_rate"
expr: "rate(http_requests_errors_total[5m]) / rate(http_requests_total[5m]) > 0.05"
for: 3m
severity: P1
labels:
  team: backend
annotations:
  summary: "High error rate on {{$labels.service}}"
  description: "Error rate {{$value | humanizePercentage}} on {{$labels.service}} {{$labels.endpoint}}"

# P99 延迟过高
rule: "high_p99_latency"
expr: "histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 2"
for: 5m
severity: P2
labels:
  team: backend
annotations:
  summary: "High P99 latency on {{$labels.service}}"
  description: "P99 latency {{$value}}s on {{$labels.service}} {{$labels.endpoint}}"

# CPU 使用率过高
rule: "high_cpu"
expr: "cpu_usage_ratio > 0.9"
for: 10m
severity: P2
labels:
  team: infra
annotations:
  summary: "High CPU usage on {{$labels.instance}}"
  description: "CPU usage {{$value | humanizePercentage}} on {{$labels.instance}}"
```

### 告警聚合与抑制
| 策略 | 说明 | 配置示例 |
|------|------|---------|
| 抑制 | 父级告警触发时抑制子级告警 | 服务不可用时，抑制该服务的延迟/错误告警 |
| 聚合 | 相同规则、不同实例的告警合并 | 按规则名和 severity 聚合 |
| 静默 | 已知问题、维护窗口期间静默 | 维护窗口期间静默相关告警 |

## 5. Dashboard 规范

### 必备 Dashboard
每个新服务必须包含以下 Dashboard：

| Dashboard 名称 | 内容 | 说明 |
|---------------|------|------|
| Service Overview | RED 指标（请求速率/错误率/延迟） + 服务健康状态 | 第一屏，快速判断服务健康度 |
| Resource | CPU、内存、磁盘、网络 I/O | 资源趋势和瓶颈分析 |
| Dependencies | 上游/下游服务调用延迟和错误率 | 依赖关系分析 |
| Business | 核心业务指标（日活/订单/转化率） | 业务运营监控 |
| Errors | 错误日志聚合、错误类型分布、Top 10 错误 | 错误归因分析 |
| Alert History | 告警事件时间线 | 事后复盘 |

## 6. 可观测性技术栈建议

| 组件 | 推荐方案 | 开源替代 |
|------|---------|---------

## 设计阶段反向声明

本技能被 `design-stage-execution` 和 `operations-stage-execution` 内联引用（内联内容：日志格式、RED 指标、告警级别、OTLP/采样策略）。修改本技能时，需同步检查两个 L2 技能中的内联速查表。

|
| 日志收集 | Loki / ELK Stack | Filebeat + Elasticsearch |
| 指标存储 | Prometheus + Thanos | VictoriaMetrics |
| 链路追踪 | OpenTelemetry Collector + Jaeger | Tempo / Zipkin |
| Dashboard | Grafana | - |
| 告警管理 | Alertmanager | OnCall 自建 |
| 事件聚合 | PagerDuty | 自建 Webhook |

## 与现有技能的关系

### 被引用关系
- `design-stage-execution`：Step 2 可观测性设计中调用本技能定义日志/指标/追踪规范
- `operations-stage-execution`：Step 5 监控日志检查中调用本技能验证是否符合可观测性标准
- `project-coding-conventions`：日志级别规则和禁止记录内容由本技能定义，作为日志规范的单点事实来源

### 不替代关系
- 不替代 `operations-stage-execution` 的监控日志检查步骤（只定义"应该怎么配"，不定义"部署时怎么查"）
- 不替代 `cicd-pipeline-management` 的流水线验证步骤
- 不替代 `project-coding-conventions` 的日志级别规则（本技能是日志规范的事实来源，coding-conventions引用本技能）