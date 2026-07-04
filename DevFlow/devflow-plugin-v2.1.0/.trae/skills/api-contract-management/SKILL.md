---
name: "api-contract-management"
description: "Manages API contract design, code generation, runtime validation, and cross-stack consistency for Python/TypeScript projects. Invoke during design/coding/testing/deployment stages to prevent frontend-backend API drift."
---

# API Contract Management（API 契约管理）

## 定位

> **API 一致性保障体系**：本技能解决前后端技术栈异构（如 Python 后端 + TypeScript 前端）时，接口契约（端口、路径、参数、字段、返回值、错误码）在开发过程中漂移和不一致的问题。它贯穿 Step 2 到 Step 5，为每个阶段提供标准化的 API 契约管控方法。
>
> - **Step 2 设计阶段**：指导 API 契约编写规范，确保接口设计文档成为前后端唯一事实源
> - **Step 3 编码阶段**：指导从契约自动生成前端类型化客户端，消除手写接口层的同步成本
> - **Step 4 测试阶段**：指导 Mock 联调和契约测试，验证前后端是否遵守同一契约
> - **Step 5 部署阶段**：指导 CI 契约校验和环境配置统一，确保上线后不出现配置漂移
>
> 本技能与 `code-static-quality-check`（API 字段映射检查）互补。`code-static-quality-check` 负责静态层面的字段一致性检测；本技能负责从设计到部署的全流程契约管控方法论和工具链选型。
>
> 本技能与 `cicd-pipeline-management`（CI/CD 流水线管理）互补。`cicd-pipeline-management` 定义流水线整体结构；本技能定义其中 API 契约校验这一专项环节。
>
> - `prototype-coverage`（前端原型覆盖检查）和 `backend-coverage`（后端设计覆盖检查）是本技能在设计阶段的上下游协作技能。前端/后端覆盖检查各自完成后，本技能执行 API 契约对齐检查，形成"前端验证 → 后端验证 → 契约对齐 → 编码"的闭环。

## 触发条件

当用户提出以下需求时，调用本技能：

- 设计 API 接口、编写接口文档或制定前后端通信规范
- 选择前后端 API 一致性方案、工具链或技术选型
- 配置 OpenAPI/Swagger 代码生成、类型推导或客户端 SDK 自动生成
- 配置 Zod、Pydantic 或其他运行时 Schema 校验
- 配置 MSW、Mock Service Worker 或其他 Mock 联调方案
- 设置 API 契约测试（Pact、Dredd、自定义校验脚本）
- 解决前后端字段名、返回值、端口、环境变量不一致的问题
- 在 CI/CD 中加入 API 契约变更检测
- 审查或评审 API 设计文档与实现的一致性

如果用户只要求后端 API 设计模式（RESTful/GraphQL/gRPC），应调用 `api-design`；如果只要求安全审查，应调用 `security-best-practices`。本技能专注于前后端契约一致性，不替代 API 设计规范本身。

## 技术栈适配矩阵

根据项目后端和前端技术栈，选择对应的方案：

| 后端 | 前端 | 推荐方案 | 契约源 | 代码生成工具 |
|------|------|---------|--------|-------------|
| **Python (FastAPI)** | **TypeScript (Vue/React)** | FastAPI Pydantic → OpenAPI → Orval → TS Client + Zod + MSW | FastAPI 自动生成 | Orval |
| Java (Spring Boot) | TypeScript (Vue/React) | Springdoc → OpenAPI → openapi-generator / Orval | Springdoc 自动生成 | openapi-generator / Orval |
| Go (Gin/Echo) | TypeScript (Vue/React) | swag → OpenAPI → openapi-generator / Orval | swag 注解生成 | openapi-generator / Orval |
| Node.js (Express/Nest) | TypeScript (Vue/React) | tRPC / ts-rest（端到端类型安全，无需 OpenAPI 中间层） | TypeScript 共享类型 | tRPC / ts-rest 内置 |
| Python (Django/Flask) | TypeScript (Vue/React) | 手写 OpenAPI spec → Orval | 手写 YAML/JSON | Orval |

**主方案（本技能详细覆盖）**：Python (FastAPI) + TypeScript (Vue/React)

**备选方案**：按上表选择工具链，方法论相同，仅工具替换。

## 分阶段指南

### Step 2 设计阶段 — API 契约编写规范

#### 入场要求

- 需求文档已批准，功能点和验收标准明确
- 系统架构设计已完成，模块边界和服务划分已确定

#### 交付物

1. **API 契约文件**（`openapi.json` 或 `openapi.yaml`）
2. **前后端共享类型定义**（如 TypeScript 接口、Pydantic 模型）
3. **环境配置规范**（`.env` 模板、端口约定、代理配置）
4. **统一响应格式和错误码定义**

#### API 契约编写规则

1. **统一响应格式**：

```json
{
  "code": 200,
  "data": { },
  "message": "success",
  "timestamp": 1719999999999
}
```

2. **统一错误格式**：

```json
{
  "code": 400001,
  "message": "参数校验失败",
  "details": [
    { "field": "email", "message": "邮箱格式不正确" }
  ]
}
```

3. **统一错误码体系**：在契约中定义全局错误码枚举，前后端共用

```python
# backend/shared/errors.py
class ErrorCode:
    SUCCESS = 0
    PARAM_ERROR = 400001
    AUTH_EXPIRED = 401001
    FORBIDDEN = 403001
    NOT_FOUND = 404001
    RATE_LIMIT = 429001
    SERVER_ERROR = 500001
```

```typescript
// frontend/shared/errors.ts — 与后端保持一致
export const ErrorCode = {
  SUCCESS: 0,
  PARAM_ERROR: 400001,
  AUTH_EXPIRED: 401001,
  FORBIDDEN: 403001,
  NOT_FOUND: 404001,
  RATE_LIMIT: 429001,
  SERVER_ERROR: 500001,
} as const
```

4. **命名约定**：
   - URL 路径使用 kebab-case：`/api/user-profiles`
   - 使用名词复数：`/api/users`（不是 `/api/user`）
   - 查询参数使用 camelCase：`pageSize`, `sortBy`
   - 响应字段使用 camelCase（TypeScript 约定）或 snake_case（Python 约定），但**必须统一选一种并在契约中明确**

5. **版本管理**：API 路径包含版本号 `/api/v1/users`

6. **分页标准**：

```json
{
  "code": 200,
  "data": {
    "items": [],
    "total": 100,
    "page": 1,
    "pageSize": 20
  }
}
```

#### 环境配置规范

```python
# backend/config.py — 使用 pydantic-settings 统一管理
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str
    REDIS_URL: str = "redis://localhost:6379"
    API_PREFIX: str = "/api/v1"
    CORS_ORIGINS: str = "http://localhost:5173,http://localhost:3000"
    
    class Config:
        env_file = ".env"
```

```bash
# .env.example — 项目根目录，前后端共用端口约定
# Backend
BACKEND_PORT=8000
BACKEND_HOST=0.0.0.0

# Frontend (Vue)
VITE_PORT=5173

# Frontend (React)
REACT_PORT=3000

# API
API_BASE_URL=http://localhost:8000/api/v1
```

```typescript
// frontend/vite.config.ts — Vue 或 React 通用
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: process.env.VITE_API_BASE_URL || 'http://localhost:8000',
        changeOrigin: true,
      }
    }
  }
})
```

#### 检查清单

- [ ] API 契约文件已创建，覆盖所有 P0/P1 接口
- [ ] 统一响应格式和错误码已定义
- [ ] 环境配置模板 `.env.example` 已创建
- [ ] 前端代理配置已就绪
- [ ] 命名约定已统一并在契约中明确记录

#### API 契约对齐检查（与前后端覆盖体系的协作）

当项目同时使用 `prototype-coverage` 和 `backend-coverage` 技能时，`api-contract-management` 在前后端覆盖检查完成后执行**交叉对齐检查**，确保前端需求与后端 API 设计之间无遗漏、无冲突：

**对齐维度**：

| 对齐对象 | 检查内容 | 示例 |
|---|---|---|
| 前端页面清单 ↔ 后端 API 设计 | 每个前端页面的数据展示是否都有对应 API | 页面需要用户列表，但无 `/api/users` 接口 |
| 前端数据需求 ↔ API 响应字段 | 前端所需的每个字段是否都包含在 API 响应中 | 前端需要 `userAvatar`，API 只返回 `userId` |
| API 响应字段 ↔ 前端实际使用 | API 返回的每个字段是否都被前端使用 | API 返回 `internalFlag`，前端从未使用（冗余字段） |
| 枚举/状态映射一致性 | 前端状态展示与后端枚举值是否对齐 | DB: 0/1; API: pending/paid; 前端: 待支付/已支付 |

**执行条件**：`prototype-coverage` 和 `backend-coverage` 各自检查通过后方可执行。

**通过标准**：
- P0 页面所需 API 100% 对齐
- 字段不一致项必须有统一方案

**强制产出**：`{项目名}-API契约对齐确认书-v{版本号}.md`

---

### Step 3 编码阶段 — 代码生成与校验实现

#### 入场要求

- Step 2 设计阶段已完成，API 契约文件已交付
- 后端框架已搭建，API 端点已实现

#### 交付物

1. 前端类型化 API 客户端（自动生成）
2. Zod / Pydantic 运行时校验 Schema
3. MSW Mock handlers（可选）

#### 后端实现规范（FastAPI）

```python
# backend/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Project API",
    version="1.0.0",
    docs_url="/docs",       # Swagger UI
    openapi_url="/openapi.json"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS.split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

```python
# backend/schemas/user.py — 使用 Pydantic v2 定义模型
from pydantic import BaseModel, EmailStr

class UserBase(BaseModel):
    name: str
    email: EmailStr

class UserCreate(UserBase):
    password: str

class UserResponse(UserBase):
    id: int
    avatar: str | None = None

    model_config = {"from_attributes": True}
```

```python
# backend/routers/users.py — 路由实现
from fastapi import APIRouter, Depends

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(user_id: int):
    return await user_service.get_by_id(user_id)

@router.post("", response_model=UserResponse, status_code=201)
async def create_user(data: UserCreate):
    return await user_service.create(data)
```

**关键点**：`response_model` 参数让 FastAPI 自动在 OpenAPI 中记录响应格式，并自动校验返回数据。

#### 前端代码生成（Orval）

1. **安装 Orval**：

```bash
npm install -D orval
```

2. **配置 Orval**：

```typescript
// frontend/orval.config.ts
import { defineConfig } from 'orval'

export default defineConfig({
  'api-client': {
    input: 'http://localhost:8000/openapi.json',
    output: {
      target: 'src/api/generated',
      schemas: 'src/api/generated/schemas',
      mode: 'split',
      client: 'axios',       // 或 'fetch'
      mock: true,            // 生成 MSW mock handlers
      override: {
        useDates: false,     // 日期处理策略
      }
    }
  }
})
```

3. **package.json 添加脚本**：

```json
{
  "scripts": {
    "generate:api": "orval"
  }
}
```

4. **执行生成**：

```bash
npm run generate:api
```

5. **自动产出结构**：

```
src/api/generated/
├── schemas/                 # Zod schemas + TypeScript 类型
│   ├── user.ts             # UserResponseSchema, UserCreateSchema
│   └── index.ts
├── endpoints/              # API 客户端函数
│   ├── users.ts            # getUser(), createUser()
│   └── index.ts
├── client.ts               # axios/fetch 实例配置
└── mocks/                  # MSW mock handlers
    └── handlers.ts
```

#### 前端使用（React）

```tsx
import { useQuery, useMutation } from '@tanstack/react-query'
import { getUser, createUser } from '@/api/generated/endpoints/users'

function UserPage({ id }: { id: number }) {
  const { data, isLoading, error } = useQuery({
    queryKey: ['user', id],
    queryFn: () => getUser(id),   // 返回类型: UserResponse，完全自动推导
  })

  const mutation = useMutation({
    mutationFn: createUser,
  })

  // data.name 有完整类型提示，后端改了字段名这里编译报错
  return <div>{data?.name}</div>
}
```

#### 前端使用（Vue）

```vue
<script setup lang="ts">
import { useQuery, useMutation } from '@tanstack/vue-query'
import { getUser, createUser } from '@/api/generated/endpoints/users'

const props = defineProps<{ id: number }>()

const { data, isLoading } = useQuery({
  queryKey: ['user', () => props.id],
  queryFn: () => getUser(props.id),
})

const mutation = useMutation({
  mutationFn: createUser,
})
</script>

<template>
  <div v-if="isLoading">Loading...</div>
  <div v-else>{{ data?.name }}</div>
</template>
```

#### 运行时校验（防御层）

即使使用 TypeScript 编译时检查，仍需运行时校验防御后端版本不一致或异常数据：

```typescript
// Orval 已自动生成 Zod schema，可直接使用
import { UserResponseSchema } from '@/api/generated/schemas/user'

// 方式一：API 拦截器统一校验
apiClient.interceptors.response.use((response) => {
  const result = UserResponseSchema.safeParse(response.data)
  if (!result.success) {
    console.error('API response validation failed:', result.error)
    // 可触发告警或降级处理
  }
  return response
})

// 方式二：关键数据手动校验
const validated = UserResponseSchema.parse(response.data)
```

#### 开发工作流

```text
后端启动 (uvicorn) → http://localhost:8000/openapi.json 就绪
    → 前端执行 npm run generate:api → 生成类型化客户端
    → 前端编码，使用自动生成的 API 函数
    → 后端接口变更 → 重新执行 npm run generate:api
    → TypeScript 编译器自动发现不兼容的变更
```

#### 检查清单

- [ ] 后端 FastAPI 已配置 `response_model`，OpenAPI 可正常访问
- [ ] Orval 已配置并成功生成前端代码
- [ ] 前端 API 调用使用生成的客户端函数，无手写 fetch/axios 调用
- [ ] Zod schema 已用于运行时校验（至少在 API 拦截器中）
- [ ] `.env` 配置已统一，无硬编码的端口或域名
- [ ] 前端代理配置与后端端口一致

---

### Step 4 测试阶段 — Mock 联调与契约测试

#### 入场要求

- Step 3 编码阶段已完成
- API 契约文件和生成的前端代码已就绪

#### MSW Mock 联调

Orval 已自动生成 MSW mock handlers，可直接用于前端独立开发：

```typescript
// frontend/src/mocks/browser.ts — 初始化 MSW
import { setupWorker } from 'msw/browser'
import { handlers } from '@/api/generated/mocks/handlers'

export const worker = setupWorker(...handlers)
```

```typescript
// frontend/src/main.tsx (React) 或 frontend/src/main.ts (Vue)
async function enableMocking() {
  if (import.meta.env.DEV) {
    const { worker } = await import('./mocks/browser')
    return worker.start({
      onUnhandledRequest: 'bypass',  // 未匹配的请求放行到真实后端
    })
  }
}

enableMocking().then(() => {
  // 挂载应用
})
```

**优势**：
- Mock 数据结构来自 OpenAPI 契约，与真实接口完全一致
- 前端可独立开发，不依赖后端启动
- 可通过环境变量控制是否启用 Mock

#### 契约测试

在后端侧验证 API 响应是否符合 OpenAPI 规范：

```python
# tests/test_api_contract.py — 使用 schemathesis 或自定义校验
from schemathesis import from_aiohttp, from_pytest

# 从 OpenAPI spec 自动生成测试用例
schema = from_pytest(openapi_schema)

@schema.parametrize()
def test_api_conformance(response):
    assert response.status_code < 500  # 无服务器错误
    # schemathesis 自动校验响应格式是否符合 OpenAPI 定义
```

```bash
# 运行契约测试
pip install schemathesis
schemathesis run http://localhost:8000/openapi.json --base-url http://localhost:8000
```

#### 前后端字段一致性校验

在 `code-static-quality-check` 的 API 字段映射检查中，对照 OpenAPI 契约验证：

```typescript
// scripts/check-api-consistency.ts — 自定义校验脚本
import openapiSpec from './openapi.json'
import { ZodSchema } from '@/api/generated/schemas'

// 校验每个 endpoint 的响应 schema 是否与 OpenAPI 定义匹配
// 校验每个 query/body 参数是否与前端调用一致
```

#### 检查清单

- [ ] MSW 已配置，前端可脱离后端独立开发
- [ ] Mock 数据结构与 OpenAPI 契约一致
- [ ] 后端契约测试已通过（schemathesis 或等效工具）
- [ ] 前后端字段一致性校验已纳入 `code-static-quality-check`

---

### Step 5 部署阶段 — CI 校验与环境配置

#### 入场要求

- Step 4 测试阶段已通过
- 部署文档已编写

#### CI 契约变更检测

在 CI/CD 流水线中加入 API 契约校验，防止后端改接口但前端未同步：

```yaml
# .github/workflows/api-contract-check.yml
name: API Contract Check
on: [push, pull_request]

jobs:
  api-contract:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # 启动后端并导出最新 OpenAPI
      - name: Export OpenAPI
        run: |
          cd backend
          pip install -r requirements.txt
          python -c "
          import json
          from main import app
          with open('openapi-latest.json', 'w') as f:
              json.dump(app.openapi(), f, indent=2)
          "

      # 重新生成前端客户端代码
      - name: Regenerate Frontend Client
        run: |
          cd frontend
          npm ci
          npm run generate:api

      # 检查是否有未提交的变更（意味着契约被破坏）
      - name: Check Contract Drift
        run: |
          cd frontend
          git diff --exit-code src/api/generated/
          echo "API contract is in sync with frontend"

      # 运行后端契约测试
      - name: Contract Tests
        run: |
          cd backend
          pip install schemathesis pytest
          schemathesis run tests/ --base-url http://localhost:8000
```

#### 环境配置统一

```bash
# 各环境 .env 文件
.env.development    # 开发环境
.env.staging        # 测试环境
.env.production     # 生产环境

# Docker Compose 统一管理
docker-compose.yml          # 开发
docker-compose.staging.yml  # 测试
docker-compose.prod.yml     # 生产
```

```nginx
# nginx.conf — 生产环境反向代理
server {
    listen 80;
    server_name example.com;

    # 前端静态资源
    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;
    }

    # 后端 API 反向代理
    location /api/ {
        proxy_pass http://backend:8000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

#### 监控与告警

- API 响应格式异常率监控（如 JSON 解析失败）
- 前端错误捕获上报（Sentry 等），关注 API 数据结构相关错误
- 接口响应时间 P99 告警

#### 检查清单

- [ ] CI 流水线包含 API 契约变更检测
- [ ] 后端契约测试已纳入 CI
- [ ] 各环境 `.env` 配置已分离，无硬编码
- [ ] Nginx / 网关反向代理配置已就绪
- [ ] API 异常监控和告警已配置

---

## 常见陷阱与排错

### 1. 后端改了接口但前端不知道

**症状**：前端请求成功但数据取不到，或字段名变了导致 undefined

**根因**：没有代码生成，前端手写接口调用

**解决**：接入 Orval 代码生成，后端改接口 → 重新生成 → TypeScript 编译报错

### 2. 环境端口不一致

**症状**：本地开发正常，部署后 404

**根因**：不同环境的端口或 API 前缀硬编码

**解决**：统一使用 `.env` + 环境变量 + 代理配置

### 3. null vs 空数组 vs undefined

**症状**：前端遍历时报错 "Cannot read properties of null"

**根因**：后端返回 null，前端期望数组

**解决**：Pydantic 模型中使用 `list[Type] = []`（默认空数组），不用 `list[Type] | None`

### 4. 日期/时间格式不一致

**症状**：日期显示异常

**根因**：后端返回 ISO 8601 字符串，前端用 Date 对象

**解决**：Orval 配置 `useDates: true`，或统一约定时间格式（推荐 ISO 8601 UTC）

### 5. 分页参数命名不一致

**症状**：分页不生效或数据重复

**根因**：前端传 `offset`，后端期望 `page`

**解决**：在 OpenAPI 契约中明确定义分页参数，前端从生成的客户端获取参数名

### 6. 文件上传/下载格式不一致

**症状**：文件上传失败或下载损坏

**根因**：Content-Type 不匹配，或 multipart 字段名不一致

**解决**：OpenAPI 中明确指定 `requestBody.content.multipart/form-data` 的字段名和类型

### 7. CORS 问题

**症状**：浏览器控制台 CORS 错误

**根因**：后端 CORS 配置未包含前端域名

**解决**：通过 `.env` 统一配置 `CORS_ORIGINS`，包含所有前端环境域名

## 工具链速查表

| 环节 | 工具 | 命令 / 用法 |
|------|------|-------------|
| 后端 OpenAPI 生成 | FastAPI 内置 | `GET /openapi.json` |
| 前端代码生成 | Orval | `npx orval` 或 `npm run generate:api` |
| 运行时校验 | Zod | `Schema.parse(data)` |
| 后端数据校验 | Pydantic v2 | `response_model=UserResponse` |
| 前端 Mock 联调 | MSW | `worker.start()` |
| 后端契约测试 | Schemathesis | `schemathesis run openapi.json` |
| API 文档协作 | Apifox / Bruno | 导入 OpenAPI spec |
| 环境配置 | pydantic-settings + dotenv | `.env` + `Settings()` |
| CI 契约校验 | GitHub Actions | `git diff --exit-code src/api/generated/` |
