---
name: container-deployment
description: "容器化部署规范。覆盖 Dockerfile 最佳实践、Docker Compose 编排和 Kubernetes 部署规范，包含容器安全、健康检查和镜像扫描集成。被 operations-stage-execution 调用。"
---

# container-deployment（容器化部署规范）

## 定位

本技能定义项目的容器化部署规范，覆盖从 Docker 开发环境到 Kubernetes 生产部署的完整容器化生命周期。它是 Step 5 部署运维阶段的容器化专项参考，与 `docker` 通用技能互补（`docker` 偏开发环境容器管理，本技能偏生产级部署规范和 DevOps 集成）。

## 触发条件

- 创建或优化 Dockerfile 时
- 编写 docker-compose.yml 开发/测试环境编排时
- 设计 Kubernetes 部署清单（Deployment/Service/Ingress）时
- 配置容器健康检查和资源限制时
- 集成镜像安全扫描到 CI/CD 时
- 审查容器化部署方案时

## Dockerfile 最佳实践

### 基础镜像选择策略

| 策略 | 说明 | 示例 |
|------|------|------|
| 优先官方 Alpine/Slim 镜像 | 镜像体积小、攻击面小 | node:20-alpine / python:3.12-slim / golang:1.22-alpine |
| 定期更新基础镜像 | 每月检查并更新基础镜像版本，修复已知 CVE | 钉定到具体版本号，不用 latest |
| 生产禁用 latest 标签 | latest 标签不可复现，禁止用于生产 | node:20.11.0-alpine3.19 |

### Dockerfile 编写规范

1. **精简镜像**：每个 RUN 指令合并为一条，使用 `&&` 链接，减少层数
2. **多阶段构建**：编译阶段与运行阶段分离，运行阶段只包含必要产物
3. **层缓存优化**：先 COPY 依赖文件（package.json / go.mod），后 COPY 源代码
4. **.dockerignore**：排除 node_modules、.git、IDE 配置等不必要文件
5. **不安装多余包**：编译工具只在构建阶段安装，运行阶段不携带

### 多阶段构建示例

**前端：Node.js build -> Nginx serve**

```dockerfile
# Stage 1: 构建
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production=false
COPY . .
RUN npm run build

# Stage 2: 运行
FROM nginx:1.25-alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
USER nginx
```

**后端：Go build -> distroless serve**

```dockerfile
# Stage 1: 构建
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server .

# Stage 2: 运行
FROM gcr.io/distroless/static-debian12
COPY --from=builder /app/server /server
ENTRYPOINT ["/server"]
```

### 层缓存优化

```dockerfile
# 正确：先 COPY 依赖文件，利用缓存
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# 错误：每次代码变更都会使依赖安装缓存失效
COPY . .
RUN npm ci
RUN npm run build
```

### .dockerignore 模板

```
# 版本控制
.git
.gitignore

# IDE 配置
.vscode
.idea
*.swp
*.swo

# 依赖目录
node_modules
vendor
__pycache__
.venv

# 构建产物
dist
build
*.exe
*.dll

# 测试与文档
test
tests
*.md
docs

# 环境配置
.env
.env.local
.env.*.local

# Docker 文件
Dockerfile
docker-compose*.yml
.dockerignore

# 操作系统文件
.DS_Store
Thumbs.db
```

## Docker Compose 编排

### docker-compose.yml 编写规范

| 规范项 | 要求 | 示例 |
|--------|------|------|
| 版本声明 | 使用 Compose Specification（可省略 version 字段） | - |
| service 定义 | 每个 service 必须包含 image 或 build | - |
| 网络隔离 | 定义自定义网络，服务间通过服务名通信 | networks: app-net |
| 数据卷持久化 | 数据库数据必须使用命名卷持久化 | volumes: db-data |
| 环境变量 | 敏感信息使用 env_file，非敏感信息使用 environment | - |
| 健康检查 | 每个服务必须定义 healthcheck | - |

### 服务依赖和启动顺序

```yaml
services:
  api:
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health/ready"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 15s

  db:
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 5s
      timeout: 3s
      retries: 5
```

### 网络配置

| 网络模式 | 适用场景 | 说明 |
|---------|---------|------|
| bridge（默认） | 单机多服务 | 容器通过服务名互相访问 |
| host | 需要直接使用主机网络栈 | 调试时使用，生产禁用 |
| 自定义网络 | 生产推荐 | 可定义网络驱动和子网 |
| 跨主机网络 | 多机集群 | overlay 驱动，配合 Swarm 或 K8s |

### 数据卷管理

| 卷类型 | 适用场景 | 示例 |
|--------|---------|------|
| 命名卷 | 数据库持久化、共享配置 | volumes: db-data:/var/lib/postgresql/data |
| 绑定挂载 | 开发时代码热重载、配置文件 | volumes: ./src:/app/src |
| 临时卷 | 临时文件交换 | volumes: - tmp:/tmp |

### 多环境配置策略

```
docker-compose.yml              # 基础配置（服务定义）
docker-compose.override.yml      # 开发环境覆盖（默认加载）
docker-compose.prod.yml           # 生产环境覆盖
docker-compose.staging.yml       # 预发布环境覆盖
```

使用方式：

```bash
# 开发环境（自动加载 override）
docker compose up

# 预发布环境
docker compose -f docker-compose.yml -f docker-compose.staging.yml up

# 生产环境
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 开发环境完整示例

```yaml
version: "3.9"

services:
  web:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:80"
    volumes:
      - ./frontend/src:/app/src   # 热重载
    depends_on:
      api:
        condition: service_healthy
    networks:
      - app-net

  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      - DB_HOST=db
      - REDIS_HOST=redis
      - MINIO_ENDPOINT=minio:9000
    env_file:
      - ./backend/.env
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health/ready"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 15s
    networks:
      - app-net

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: dev_password
      POSTGRES_DB: app_db
    volumes:
      - db-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "app"]
      interval: 5s
      timeout: 3s
      retries: 5
    networks:
      - app-net

  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    networks:
      - app-net

  minio:
    image: minio/minio:latest
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    volumes:
      - minio-data:/data
    ports:
      - "9000:9000"
      - "9001:9001"
    command: server /data --console-address ":9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 10s
      timeout: 5s
      retries: 3
    networks:
      - app-net

volumes:
  db-data:
  redis-data:
  minio-data:

networks:
  app-net:
    driver: bridge
```

## Kubernetes 部署规范

### Deployment 编写规范

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  labels:
    app: api-server
    version: v1.2.0
spec:
  replicas: 3
  # 滚动更新策略
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # 滚动更新时最多多出 1 个 Pod
      maxUnavailable: 0   # 滚动更新时不允许不可用
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    spec:
      # 优雅终止
      terminationGracePeriodSeconds: 60
      # 资源限制
      containers:
        - name: api-server
          image: registry.example.com/api-server:v1.2.0
          ports:
            - containerPort: 8080
          # 资源请求和限制
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
          # 健康检查探针
          livenessProbe:
            httpGet:
              path: /health/live
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 15
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 3
          startupProbe:
            httpGet:
              path: /health/live
              port: 8080
            initialDelaySeconds: 0
            periodSeconds: 5
            failureThreshold: 30
          # 生命周期钩子
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh", "-c", "sleep 10"]
      # 反亲和性：Pod 分散到不同节点
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchLabels:
                    app: api-server
                topologyKey: kubernetes.io/hostname
```

### Service 编写规范

| Service 类型 | 适用场景 | 说明 |
|-------------|---------|------|
| ClusterIP | 集群内部服务访问 | 默认类型，仅集群内可达 |
| NodePort | 开发测试环境对外暴露 | 30000-32767 端口范围，不推荐生产 |
| LoadBalancer | 生产环境对外暴露 | 云厂商提供外部 LB |

**Service 选择决策树：**

```
服务需要对外暴露吗？
├── 否 → ClusterIP
└── 是
    ├── K8s 集群在云平台上吗？
    │   ├── 是 → LoadBalancer
    │   └── 否 → NodePort（仅开发/测试）或 Ingress
    └── 是否需要 TLS/域名路由？
        ├── 是 → Ingress + ClusterIP
        └── 否 → LoadBalancer / NodePort
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-server
  labels:
    app: api-server
spec:
  type: ClusterIP
  selector:
    app: api-server
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
```

### ConfigMap 和 Secret 管理

**ConfigMap - 非敏感配置：**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
data:
  LOG_LEVEL: "info"
  DB_HOST: "db-service"
  CACHE_HOST: "redis-service"
```

**Secret - 敏感配置：**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: api-secret
type: Opaque
data:
  # base64 编码（K8s 要求）
  DB_PASSWORD: c2VjcmV0X3Bhc3N3b3Jk
  API_KEY: YWJjZGVmMTIzNDU2
```

| 挂载方式 | 适用场景 | 示例 |
|---------|---------|------|
| env 环境变量注入 | 少量配置，热更新不敏感 | envFrom / valueFrom |
| 卷挂载为文件 | 配置文件（nginx.conf 等） | volumeMounts + configMap/secret volumes |
| 一次性环境变量 | 启动时读取，不随 ConfigMap 更新 | env + valueFrom |

```yaml
# 使用 ConfigMap 和 Secret 的 Pod 配置
spec:
  containers:
    - name: api-server
      envFrom:
        - configMapRef:
            name: api-config
      env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: api-secret
              key: DB_PASSWORD
```

### Ingress 配置

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  annotations:
    # Nginx Ingress Controller 注解
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - api.example.com
      secretName: api-tls-secret
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /api(/|$)(.*)
            pathType: Prefix
            backend:
              service:
                name: api-server
                port:
                  number: 80
```

### HorizontalPodAutoscaler（HPA 自动扩缩）

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-server-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-server
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
        - type: Percent
          value: 50
          periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 25
          periodSeconds: 60
```

### PodDisruptionBudget（PDB 中断预算）

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: api-server-pdb
spec:
  minAvailable: "50%"
  selector:
    matchLabels:
      app: api-server
```

### K8s 清单目录结构示例

```
deploy/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   └── kustomization.yaml
├── overlays/
│   ├── dev/
│   │   ├── kustomization.yaml
│   │   └── patches.yaml
│   ├── staging/
│   │   ├── kustomization.yaml
│   │   └── patches.yaml
│   └── prod/
│       ├── kustomization.yaml
│       ├── hpa.yaml
│       ├── pdb.yaml
│       ├── ingress.yaml
│       └── patches.yaml
└── namespace.yaml
```

## 容器安全规范

### 非 root 用户运行

```dockerfile
# 创建非 root 用户
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app
USER appuser
```

| 安全项 | 要求 | 说明 |
|--------|------|------|
| USER 指令 | 必须设置 | 生产容器禁止以 root 运行 |
| 安全 UID | 1000-65535 范围 | 避免与系统用户冲突 |
| 文件权限 | 运行用户有读写权限 | COPY 后执行 chown |

### 镜像安全

| 策略 | 说明 |
|------|------|
| 优先 distroless/scratch | 不含 shell 和包管理器，攻击面最小 |
| 禁用运行时包管理器 | 运行阶段不携带 apt/yum/apk |
| 定期扫描 | 每次构建扫描镜像，阻止 Critical 漏洞发布 |

### 运行时安全

| 安全项 | K8s 配置 | 说明 |
|--------|---------|------|
| 只读根文件系统 | `readOnlyRootFilesystem: true` | 需要写路径使用 emptyDir |
| 禁止特权容器 | `privileged: false`（默认） | 不允许 --privileged |
| seccomp 配置 | `seccompProfile: runtime/default` | 限制系统调用 |
| AppArmor 配置 | `appArmorProfile` | 限制程序能力 |
| 允许权限提升 | `allowPrivilegeEscalation: false` | 禁止 setuid/setgid |
| Capabilities 丢弃 | `drop: ["ALL"]` | 移除所有 Linux capabilities |

```yaml
# Pod 安全上下文
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault
  # 容器级别安全
  containers:
    - name: api-server
      securityContext:
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
```

### 网络策略

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-server-netpol
spec:
  podSelector:
    matchLabels:
      app: api-server
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: ingress-controller
      ports:
        - port: 8080
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: db
      ports:
        - port: 5432
    - to:
        - namespaceSelector: {}
      ports:
        - port: 53     # DNS
          protocol: UDP
    - to:
        - 0.0.0.0/0   # 外部 API（需白名单 IP）
      ports:
        - port: 443
```

### Secret 管理

| 策略 | 说明 |
|------|------|
| 不将 Secret 编码进镜像 | 镜像应不含密钥、Token、密码 |
| 使用外部密钥管理 | 集成 HashiCorp Vault / AWS Secrets Manager / K8s Secret |
| Vault 集成 | 通过 CSI Driver 或 Agent 注入 Secret |
| Secret 加密存储 | 使用 Sealed Secrets / SOPS / KMS 加密 |
| 最小权限 | 每个 Pod 只能访问必要的 Secret |

## 容器健康检查规范

### 三种探针配置标准

| 探针 | 用途 | 推荐 initialDelaySeconds | 推荐 periodSeconds | 推荐 failureThreshold |
|------|------|--------------------------|---------------------|-----------------------|
| livenessProbe | 检测容器是否存活 | 30-60 | 10-30 | 3 |
| readinessProbe | 检测是否可接收流量 | 5-15 | 5-10 | 3 |
| startupProbe | 检测应用是否启动完成 | 0-30 | 5-10 | 30-60 |

### 各类型应用探针配置示例

**HTTP 探针（Web/API 服务）：**

```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 15
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 3
```

**TCP 探针（数据库/TCP 服务）：**

```yaml
livenessProbe:
  tcpSocket:
    port: 5432
  initialDelaySeconds: 15
  periodSeconds: 10
  failureThreshold: 3
```

**Exec 探针（脚本检查）：**

```yaml
livenessProbe:
  exec:
    command:
      - /bin/sh
      - -c
      - "pgrep -f 'my-app' && curl -sf http://localhost:8080/health/live"
  initialDelaySeconds: 30
  periodSeconds: 15
  failureThreshold: 3
```

### 健康检查端点设计规范

| 端点路径 | 检查内容 | 返回状态 | 说明 |
|---------|---------|---------|------|
| /health/live | 应用进程存活 | 200（正常）/ 503（异常） | livenessProbe 使用 |
| /health/ready | 依赖就绪（DB/Cache/外部 API） | 200（就绪）/ 503（未就绪） | readinessProbe 使用 |
| /health/startup | 应用启动完成 | 200（完成）/ 503（启动中） | startupProbe 使用 |

端点返回格式（JSON）：

```json
{
  "status": "ok",
  "timestamp": "2026-07-02T10:30:00Z",
  "checks": {
    "database": "ok",
    "redis": "ok",
    "external_api": "ok"
  },
  "version": "v1.2.0"
}
```

## 镜像安全扫描集成

### Trivy 扫描配置

**安装：**

```bash
# Linux
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# macOS
brew install trivy
```

**扫描命令：**

```bash
# 扫描镜像
trivy image registry.example.com/api-server:v1.2.0

# 扫描镜像文件系统
trivy fs ./docker

# 扫描 IaC 配置
trivy config ./deploy

# 输出 JSON 格式（CI 集成）
trivy image --format json --output report.json registry.example.com/api-server:v1.2.0

# 扫描并指定严重级别阻断
trivy image --exit-code 1 --severity CRITICAL,HIGH registry.example.com/api-server:v1.2.0
```

**.trivyignore 模板：**

```
# 忽略已知且无修复方案的漏洞
CVE-2023-XXXX
# 忽略开发依赖中的低危漏洞
lib/
```

### 扫描策略

| 扫描时机 | 频率 | 阻断条件 | 说明 |
|---------|------|---------|------|
| 每次构建 | CI 流水线触发时 | Critical 阻断 | 阻止有严重漏洞的镜像推送到仓库 |
| 每日定时 | 每日凌晨 2:00 | Critical 通知 | 发现新漏洞及时告警 |
| PR 门禁 | PR 创建/更新时 | Critical/High 阻断 | 防止引入新漏洞 |

### 漏洞分级处理

| 严重级别 | 处理要求 | SLA | CI 处理 |
|---------|---------|-----|--------|
| Critical | 阻断发布，立即修复 | 24h 内修复 | 流水线失败，阻止推送 |
| High | 必须修复 | 7d 内修复 | 流水线警告，记录为 TODO |
| Medium | 记录并计划修复 | 30d 内修复 | 扫描报告中标记 |
| Low | 记录跟踪 | 下一版本修复 | 仅报告 |

### 与 CI/CD 集成配置示例

**GitHub Actions 集成：**

```yaml
name: Container Security Scan
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  trivy-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build image
        run: docker build -t app:${{ github.sha }} .
      - name: Trivy vulnerability scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: "app:${{ github.sha }}"
          severity: "CRITICAL,HIGH"
          exit-code: "1"
          format: "table"
      - name: Trivy config scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: "config"
          scan-ref: "deploy/"
          severity: "CRITICAL,HIGH"
          exit-code: "1"
```

**GitLab CI 集成：**

```yaml
container-scan:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --exit-code 1 --severity CRITICAL,HIGH app:$CI_COMMIT_SHA
    - trivy config --exit-code 1 --severity CRITICAL,HIGH deploy/
  allow_failure: false
  only:
    - main
    - merge_requests
```

## 与其他 DevFlow 技能的协作

| 集成阶段 | 引用技能 | 协作内容 |
|---------|---------|---------|
| Step 3 编码 | `coding-stage-execution` | Dockerfile 和 compose 作为交付物 |
| Step 5 部署 | `operations-stage-execution` | 容器化部署作为部署策略选项 |
| CI/CD | `cicd-pipeline-management` | 镜像构建/扫描/推送流水线 |
| 通用容器 | `docker` | 开发环境容器管理 |

## Operations Stage Integration

When this skill is used during the formal deployment and operations stage, coordinate with `operations-stage-execution`.

- Treat `operations-stage-execution` as the Step 5 controller.
- Use this skill only for container-specific deployment concerns.
- Record container configurations, image tags, scan results, and health check outcomes in deployment documents.

## 反模式

- 在生产镜像中使用 latest 标签
- 以 root 用户运行容器
- 在镜像中硬编码密钥或配置
- 忽略镜像安全扫描
- 不设置资源限制（limits/requests）
- 使用特权模式运行容器
- 容器内安装完整操作系统包
- 忽略健康检查配置

## 强制规则

1. 生产容器必须以非 root 用户运行
2. 生产镜像必须设置资源限制（CPU/Memory requests + limits）
3. 生产容器必须配置 livenessProbe 和 readinessProbe
4. 禁止在镜像中硬编码密钥、Token 或数据库密码
5. 镜像必须通过安全扫描（Critical 漏洞阻断发布）
6. 必须使用 .dockerignore 排除不必要的文件
7. K8s 清单中 Secret 禁止明文存储

## 变更记录

| 日期 | 变更内容 | 变更人 |
|---|---|---|
| 2026-07-02 | VR-009: 初始创建，覆盖 Dockerfile/Compose/K8s/安全/扫描 | jerry.yu |
