---
name: cicd-pipeline-management
description: CI/CD 流水线管理规范。定义流水线阶段结构、质量闸门配置、构建触发规则、部署策略、回滚自动化和平台适配指南。被 operations-stage-execution 和 project-development-workflow 调用。
---

# cicd-pipeline-management（CI/CD 流水线管理）

## 定位

本技能是 CI/CD 流水线管理的标准参考。它定义从代码提交到生产部署的自动化流水线规范，包括阶段划分、质量闸门、触发策略和平台无关模板。本技能不替代 `operations-stage-execution` 的部署矩阵和运维规范，只定义流水线本身的构建和配置标准。

## 触发条件

- Step 5 部署阶段开始时自动触发
- 项目初始化时配置 CI/CD 流水线时调用
- 流水线故障需要排查时参考
- 新增/修改流水线阶段时参考

## CI/CD 通用原则

1. **流水线即代码**：所有流水线配置必须版本化管理（.gitlab-ci.yml / .github/workflows/*.yml / Jenkinsfile），禁止手动操作生产环境
2. **门禁阻断**：每个阶段设置质量闸门，未通过禁止进入后续阶段
3. **构建一次，部署多次**：构建产物不可变，同一产物经过各环境验证后逐级晋升，禁止重新构建后部署到生产
4. **快速反馈**：开发者提交后 10 分钟内应获得流水线结果
5. **最小权限**：CI/CD token 只有最小必要权限，禁止使用个人凭据
6. **可追溯**：每次部署的制品版本、代码 Commit、流水线日志必须可追溯

## 流水线标准阶段

### 标准五阶段模型

```
代码提交 → [Stage 1 检出] → [Stage 2 构建] → [Stage 3 质量门禁] → [Stage 4 部署] → [Stage 5 验证]
```

### Stage 1: 检出与依赖

| 子步骤 | 说明 | 成功标准 |
|--------|------|---------|
| 代码检出 | 拉取目标分支代码 | 版本一致、无合并冲突 |
| 依赖安装 | npm install / pip install / go mod download 等 | 依赖解析成功、无已知漏洞 |
| 缓存恢复 | 恢复之前缓存的 node_modules/.venv/vendor | 缓存命中率 >= 80% |
| 子模块/子项目同步 | git submodule update / 多仓库检出 | 子模块一致 |

### Stage 2: 构建

| 子步骤 | 说明 | 成功标准 |
|--------|------|---------|
| 编译/打包 | npm run build / tsc / go build / python build | 构建成功、无 Error |
| 制品生成 | 生成 Docker image / zip / jar / wheel | 制品签名或 checksum 记录 |
| 制品版本标记 | 注入版本号、Commit SHA、构建时间 | 制品元数据完整 |
| 缓存保存 | 保存 node_modules 等加速下次构建 | 缓存写入成功 |

### Stage 3: 质量门禁（阻断性）

| 门禁 | 检查内容 | 阻断条件 | 严重级别 |
|------|---------|---------|---------|
| 代码风格 | ESLint / Ruff / gofmt | 有 Error 级别违规 | P1 |
| 类型检查 | TypeScript / mypy / flow | 类型错误 | P0 |
| 单元测试 | pytest / jest / go test | 覆盖率低于阈值（默认 70%）或测试失败 | P0（失败）/ P1（覆盖不足） |
| 构建完整性 | 构建产物验证 | 构建失败或产物不完整 | P0 |
| 安全扫描 | SAST / 依赖漏洞 / 密钥泄露 | 发现 Critical 漏洞 | P0 |
| 锁文件验证 | `package-lock.json`/`go.sum`/`poetry.lock` 完整性 | 锁文件与声明文件不一致 | P1 |
| 集成测试 | API 测试 / 接口契约测试 | 核心接口失败 | P0 |
| 许可证检查 | 依赖许可证合规 | 含禁止使用的许可证 | P1 |

### Stage 4: 部署

支持的部署策略：

| 策略 | 适用场景 | 说明 |
|------|---------|------|
| 直接部署 | Dev/Test 环境 | 单实例直接替换 |
| 蓝绿部署 | Pro 环境 | 两套环境切换，零停机时间 |
| 金丝雀发布 | Pro 环境 | 先 10% 流量验证，逐步扩大到 100% |
| 灰度发布 | Pro 环境 | 按用户/地域分批发布 |
| 滚动更新 | K8s 集群 | 逐步替换 Pod，保持可用性 |

### Stage 5: 验证

| 子步骤 | 说明 | 成功标准 |
|--------|------|---------|
| 健康检查 | 核心端点 /health / /ready 返回 200 | 服务状态正常 |
| 冒烟测试 | 核心 API、关键用户流程验证 | 全部通过 |
| 监控检查 | 错误率、延迟、资源使用在基线范围内 | 无异常 |
| 集成验证 | 外部依赖可正常访问 | 外部调用正常 |
| 回滚就绪 | 回滚版本标记、回滚脚本确认 | 回滚路径明确 |

## 质量闸门详细配置

### 覆盖率阈值

| 环境 | 行覆盖率 | 分支覆盖率 | 通过条件 |
|------|---------|---------|---------|
| Dev | >= 60% | >= 50% | 可进入下一阶段 |
| Test | >= 70% | >= 60% | 可进入下一阶段 |
| Pro | >= 80% | >= 70% | 可进入下一阶段 |

### 安全扫描策略

| 扫描类型 | 工具建议 | 频率 | 阻断级别 |
|---------|---------|------|---------|
| SAST（静态应用安全测试） | Semgrep / SonarQube | 每次提交 | Critical/High 阻断 |
| 依赖漏洞扫描 | Snyk / Dependabot / Trivy | 每次提交 + 每日定时 | Critical 阻断 |
| 密钥泄露检测 | Gitleaks / truffleHog | 每次提交 | 发现即阻断 |
| Docker 镜像扫描 | Trivy / Clair | 每次构建 | Critical/High 阻断 |
| IaC 安全扫描 | Checkov / tfsec | 每次提交 | Critical 阻断 |

### 性能基线管理

性能基线用于判断版本间性能回归，建立方法：
- 新服务首个版本：在生产或预发环境运行压测3次取中位数作为基线
- 基线条目：P50延迟 / P99延迟 / 最大吞吐量 / CPU峰值 / 内存峰值
- 基线存储：记录在上线检查报告中
- 回归判断：当前版本指标与上次发布基线对比

### 性能回归门禁

| 指标 | 容忍范围 | 超过后处理 |
|------|---------|-----------|
| P50 响应时间 | 基线 +20% | 警告，记录到报告 |
| P99 响应时间 | 基线 +30% | 阻断，退回优化 |
| 吞吐量 | 基线 -20% | 阻断，退回优化 |
| 内存/CPU | 基线 +30% | 警告，记录到报告 |

## 触发器与分支策略

### 触发方式

| 触发事件 | 目标分支 | 流水线范围 |
|---------|---------|-----------|
| push（非 main 分支） | feature/*, fix/*, chore/* | Stage 1-3 |
| push（main 分支） | main | Stage 1-3 |
| 合并请求/PR | → main | Stage 1-3 + 代码评审 |
| 标签/Tag 创建 | v*.*.* | Stage 1-5 |
| 手动触发 | 任意 | 按需选择阶段 |
| 定时触发 | main | Stage 1-3（每日安全扫描） |

### 分支策略

```
main（生产分支）
├── develop（开发集成分支）
│   ├── feature/xxx（功能分支 → develop）
│   ├── fix/xxx（修复分支 → develop）
│   └── chore/xxx（工程分支 → develop）
└── release/v*.*.*（预发布分支 → main）
```

## 部署策略详细说明

### 直接部署

适用于 Dev/Test 环境：

1. 停止当前服务
2. 替换制品
3. 重启服务
4. 健康检查确认

### 蓝绿部署

适用于 Pro 环境（零停机）：

1. Blue 为当前运行环境
2. 将新版本部署到 Green 环境
3. Green 环境运行冒烟测试通过后
4. 负载均衡器切换流量到 Green
5. Blue 保留为回滚环境

### 金丝雀发布

适用于 Pro 环境（渐进式）：

1. 部署 1 个 Pod / 10% 流量
2. 监控 5-10 分钟，确认无异常
3. 逐步扩大至 50% → 100%
4. 若指标异常，自动回滚

## 常见平台流水线模板

### GitHub Actions

```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
    tags: [v*]
  pull_request:
    branches: [main]
jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: npm ci
      - name: Lint
        run: npm run lint
      - name: Type check
        run: npm run typecheck
      - name: Test
        run: npm run test -- --coverage
      - name: Build
        run: npm run build

  # tag 创建时自动推送到备份仓库（与 code-version-backup-management 联动）
  backup-mirror:
    if: startsWith(github.ref, 'refs/tags/')
    runs-on: ubuntu-latest
    needs: build-and-test
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Push mirror to backup remote
        run: |
          git remote add backup ${{ secrets.BACKUP_REMOTE_URL }}
          git push --mirror backup
          git push --tags backup
```

### GitLab CI

```yaml
stages:
  - build
  - test
  - security
  - deploy
  - verify
  - backup
build:
  stage: build
  script: npm run build
  artifacts:
    paths: [dist/]
test:
  stage: test
  script: npm run test -- --coverage
security:
  stage: security
  script: npx audit-ci --critical
deploy:
  stage: deploy
  script: npm run deploy
  only: [tags]
verify:
  stage: verify
  script: npm run smoke-test
# tag 创建时自动推送到备份仓库（与 code-version-backup-management 联动）
backup-mirror:
  stage: backup
  script: |
    git remote add backup "$BACKUP_REMOTE_URL"
    git push --mirror backup
    git push --tags backup
  only: [tags]
```

## 流水线故障排查

| 故障现象 | 常见原因 | 诊断方法 | 修复步骤 |
|---------|---------|---------|---------|
| 构建失败 | 依赖冲突、语法错误 | 查看构建日志 | 修复代码、锁定依赖版本 |
| 测试失败 | 功能变更未更新测试 | 查看测试报告 | 更新测试或回退代码变更 |
| 部署失败 | 配置错误、端口冲突 | 查看部署日志 | 检查配置、重启服务 |
| 门禁阻断 | 覆盖率不足、安全漏洞 | 查看质量报告 | 补充测试或修复漏洞 |
| 验证失败 | 服务未就绪、依赖异常 | 查看健康检查日志 | 检查服务状态、重试部署 |
| 超时 | 资源不足、构建文件过大 | 查看 Runner 日志 | 优化构建、增加 Runner 资源 |

## 运维记录输出

每次 CI/CD 流水线执行完成后，必须记录以下信息到对应文档：

| 记录项 | 文档 | 字段要求 |
|--------|------|---------

## 运维阶段反向声明

本技能被 `operations-stage-execution` 内联引用（内联内容：5 阶段流水线、8 个质量闸门、性能基线管理）。修改本技能时，需同步检查 `operations-stage-execution` 中的内联速查表。

|
| 构建信息 | CICD记录 | 构建编号、Commit SHA、构建时间、构建产物版本 |
| 测试结果 | 测试报告 | 测试用例数、通过数、失败数、覆盖率 |
| 安全扫描 | 安全扫描报告 | 扫描类型、发现数、严重级别、处理状态 |
| 部署记录 | 部署执行记录 | 部署时间、部署版本、部署策略、部署结果 |
| 验证结果 | 上线验证报告 | 验证项、验证结果、验证时间 |

### 依赖扫描说明

> 依赖引入规范（许可证检查、必要性评估、废弃清理）和锁文件规则由 `project-coding-conventions` 技能定义。本技能负责在 CI/CD 流水线中执行自动化依赖漏洞扫描和锁文件验证，发现的问题回传给编码阶段处理。

## 与其他技能的关系

### 被调用关系

- `operations-stage-execution`：在部署阶段调用本技能配置 CI/CD 流水线
- `project-development-workflow`：在总流程中引用本技能作为自动化标准
- `project-document-management`：引用本技能定义的 CICD 记录文档

### 不替代关系

- 不替代 `operations-stage-execution` 的部署矩阵和运维规范
- 不替代 `testing-stage-execution` 的测试矩阵和执行规范
- 不替代 `docker` 技能的容器化最佳实践

## 变更记录

| 日期 | 变更内容 | 变更人 |
|---|---|---|
| 2026-07-02 | 添加一级标题和变更记录章节 | jerry.yu |