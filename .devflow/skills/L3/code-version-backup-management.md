---
name: "code-version-backup-management"
description: "代码版本控制与备份管理规范。管理 Git 工作流、分支策略、提交约定、版本号和备份策略。被 coding-stage-execution / testing-stage-execution / operations-stage-execution 调用。"
---

# 代码版本与备份管理

## 定位

本技能定义项目的代码版本控制与备份管理规范，包括 Git 工作流、分支策略、提交约定和备份策略。它是 Step 3 编码阶段、Step 4 测试阶段和 Step 5 部署运维阶段的版本管理依据。

应用 `version-planning` 中定义的版本规则，与 `cicd-pipeline-management` 中 CI/CD 流水线联动，实现代码版本的全生命周期管理。

---

## 一、项目配置驱动

### 1.1 配置方式

仓库路径、分支策略和远程仓库由 `{project_root}/.devflow/project-config.json` 定义，本技能读取该配置执行，不硬编码路径。

```json
{
  "project": "{项目名}",
  "branchStrategy": "git-flow",
  "remote": {
    "origin": "git@github.com:org/{项目名}.git",
    "backup": "git@backup-server:org/{项目名}-backup.git"
  },
  "backup": {
    "type": "git-mirror"
  }
}
```

### 1.2 项目根目录

`{project_root}` 代表项目根目录，由 DevFlow setup 脚本在安装时注入，**不硬编码为任何特定路径**（如 D:）。

---

## 二、分支策略（可配置）

### 2.1 配置选择

在 `.devflow/project-config.json` 中设置 `branchStrategy` 字段，支持三种模式：`trunk-based` / `github-flow` / `git-flow`。

### 2.2 Trunk-Based（小型项目/单人开发）

| 分支 | 命名 | 用途 | 合入目标 |
|------|------|------|---------|
| main | `main` | 主干开发 + 生产发布 | - |
| feature | `feature/{issue}-{name}` | 新功能/修复 | main |

- 适用：团队 <= 3 人，迭代快速，持续部署
- 特点：分支生命周期 < 1 天

### 2.3 GitHub Flow（标准团队协作）

| 分支 | 命名 | 用途 | 合入目标 |
|------|------|------|---------|
| main | `main` | 稳定版本（随时可发布）| - |
| feature | `feature/{issue}-{name}` | 新功能 | main |

- 适用：团队 3-10 人，CI/CD 完善
- 特点：无 develop 分支，合入 main 即触发 CI/CD 发布流程

### 2.4 Git Flow（多版本并行/推荐方案）

| 分支 | 命名 | 用途 | 合入目标 |
|------|------|------|---------|
| main | `main` | 生产发布（稳定）| - |
| release | `release/v{版本号}` | 发布准备（冻结功能）| main |
| develop | `develop` | 日常集成 | release |
| feature | `feature/{issue}-{name}` | 新功能 | develop |
| hotfix | `hotfix/{issue}-{name}` | 紧急修复 | main + develop |

- 适用：团队 >= 5 人，多版本并行维护
- 特点：隔离性好，但分支复杂度较高

---

## 三、提交约定

### 3.1 提交信息格式

```
{type}({scope}): {subject}

[optional body]

[optional footer: RT-{ID}]
```

### 3.2 类型定义

| 类型 | 说明 | 示例 |
|------|------|------|
| feat | 新功能 | `feat(auth): 添加登录 API` |
| fix | Bug 修复 | `fix(ui): 修复按钮样式` |
| docs | 文档 | `docs: 更新 README` |
| style | 代码风格 | `style: 格式化代码` |
| refactor | 重构 | `refactor(api): 优化查询` |
| test | 测试 | `test: 添加单元测试` |
| chore | 维护 | `chore: 更新依赖` |

### 3.3 提交规则

1. **原子提交**：每个逻辑变更一个提交，不得将无关变更混入
2. **描述清晰**：说明做了什么和为什么做（不提怎么做）
3. **关联需求**：在 footer 中引用 RT-ID（需求追溯矩阵中的编号）
4. **TDD 合规**：`feat` 和 `fix` 类型的提交必须包含对应的测试文件变更；测试代码的提交应在生产代码之前。`code-logic-review` 中检查此合规性

---

## 四、版本号管理

### 4.1 语义化版本

```
MAJOR.MINOR.PATCH
  |     |    +-- Bug 修复 (1.0.0 -> 1.0.1)
  |     +------- 新功能 (1.0 -> 1.1)
  +------------- 破坏性变更 (1.0 -> 2.0)
```

### 4.2 版本标签

| 标签格式 | 示例 | 用途 |
|---------|------|------|
| v{major}.{minor}.{patch} | v1.0.0 | 正式发布 |
| v{...}-beta | v1.0.0-beta | Beta 版 |
| v{...}-alpha | v1.0.0-alpha | Alpha 版 |

---

## 五、备份策略

### 5.0 三远程标准化架构

所有 DevFlow 管理的项目应统一采用三远程仓库架构：

| 远程名称 | URL 模板 | 用途 | 认证方式 |
|:--------:|----------|------|:--------:|
| `origin` | `http://{内网服务器}/jerry.yu/{project}.git` | 内网主仓库（开发协作、CI/CD 触发） | HTTP(S) + 用户名密码 |
| `backup` | `http://{内网服务器}/jerry.yu/{project}-backup.git` | 内网备份仓库（容灾） | HTTP(S) + 用户名密码 |
| `github` | `git@github.com:{username}/{project}.git` | 外网 GitHub 镜像（发布归档、开源下载） | SSH Key |

**标准化推送命令模板**：

```bash
# 推送代码分支
git push origin master
git push backup master
git push github master

# 推送版本标签
git push origin v{version}
git push backup v{version}
git push github v{version}
```

**Tag 同步验证命令**：

```bash
git ls-remote origin refs/tags/v{version}
git ls-remote backup refs/tags/v{version}
git ls-remote github refs/tags/v{version}
# 三个远程必须返回相同 commit hash，否则视为发布不完整
```

> `{project}` 作为参数占位符，替换为实际项目名。所有 tag 创建后必须推送至全部三个远程，任一远程遗漏视为发布不完整。Tag 同步验证的结果应记录在 Release Checklist 中。

### 5.1 Git 原生增量备份（替代文件级全量拷贝）

| 类型 | 方式 | 频率 | 留存 |
|------|------|------|------|
| 日常备份 | `git push --mirror` 远程备份仓库 | 每次推送后自动 | 永久（增量对象存储）|
| 每周快照 | `git bundle create` 创建 bundle 文件 | 每周 | 4 周 |
| 发布归档 | `git archive` 打包源码 | 每版本 | 永久 |
| 数据库备份 | 数据库原生 dump 工具 | 每日 | 90 天 |

### 5.2 不备份的内容

`node_modules/`、`vendor/`、`dist/`、`build/`、`target/`、`logs/`、`*.tmp`、`.DS_Store`

### 5.3 自动备份：Git Hook 安装

在项目 `.git/hooks/post-push` 中安装以下脚本，实现每次推送后自动 mirror 到备份远程仓库：

```bash
#!/bin/bash
# DevFlow auto-backup hook
# 安装方式：cp .devflow/hooks/post-push .git/hooks/post-push && chmod +x .git/hooks/post-push
if git remote | grep -q backup; then
    echo "[DevFlow] Pushing mirror to backup remote..."
    git push --mirror backup
    git push --tags backup
fi
```

**前置条件**：
1. 备份远程仓库已在 `.devflow/project-config.json` 的 `remote.backup` 字段中配置
2. 已通过 `git remote add backup <backup-url>` 添加备份远程仓库
3. Hook 文件具有可执行权限

> DevFlow 插件安装脚本（`setup.ps1` / `setup.sh`）可通过 `--install-hook` 参数自动安装此 Hook。

---

## 六、回滚流程

### 6.1 回滚策略总览

DevFlow 的回滚体系按**回滚对象**分为四类，按**触发方式**分为自动和手动两层：

```
┌─────────────────────────────────────────────────────────────┐
│                    回 滚 策 略 分 类                          │
├─────────────┬─────────────┬─────────────┬───────────────────┤
│  代码回滚    │  数据回滚    │  配置回滚    │   服务/部署回滚    │
├─────────────┼─────────────┼─────────────┼───────────────────┤
│ git revert  │ DB 还原     │ 配置中心回滚 │  蓝绿切换          │
│ git reset   │ 迁移回退    │ 环境变量还原 │  金丝雀流量切回    │
│ 归档恢复     │ 缓存重建    │ K8s ConfigMap│ 滚动更新回退      │
├─────────────┴─────────────┴─────────────┴───────────────────┤
│                    触 发 方 式                               │
├─────────────────────────┬───────────────────────────────────┤
│  自动触发（CI/CD 监控）   │  手动触发（人工审批）              │
│  • 健康检查失败          │  • P0 故障人工确认                 │
│  • 错误率超阈值          │  • 业务方要求回滚                  │
│  • P99 延迟超基线        │  • 合规/安全原因                   │
│  • 核心功能冒烟失败       │  • 数据异常需紧急恢复              │
└─────────────────────────┴───────────────────────────────────┘
```

### 6.2 回滚触发条件

#### 6.2.1 自动触发条件（CI/CD 监控）

当以下任一指标在**生产环境发布后 15 分钟内**触发，系统自动发起回滚：

| 触发指标 | 阈值 | 检测窗口 | 自动动作 |
|---------|------|---------|---------|
| **健康检查失败** | `/health` 或 `/ready` 非 200 | 连续 3 次，间隔 10s | **自动回滚** |
| **错误率飙升** | 5xx 错误率 > 1%（或环比 +500%） | 5 分钟滑动窗口 | **自动回滚** |
| **P99 延迟超基线** | P99 > 基线 +50% | 5 分钟滑动窗口 | **告警 + 人工确认** |
| **核心功能冒烟失败** | 关键 API / 主流程失败 | 发布后 10 分钟内 | **自动回滚** |
| **资源异常** | CPU/Memory 持续 > 90% | 5 分钟 | 告警，不自动回滚 |
| **依赖服务故障** | 下游服务不可用 | 立即 | 告警，不自动回滚 |

> **自动回滚安全约束**：自动回滚仅适用于**蓝绿部署**和**金丝雀发布**场景，直接部署场景需人工确认（无法快速无损切回）。

#### 6.2.2 手动触发条件

以下场景由人工判断后触发回滚：

| 场景 | 审批级别 | 触发方式 |
|------|---------|---------|
| 发布后发现 P0 缺陷 | 发布负责人 + PM | CI/CD 手动触发回滚 job |
| 业务数据异常（脏数据） | 发布负责人 + DBA | 数据回滚流程 |
| 安全漏洞紧急修复回退 | 安全负责人 + 发布负责人 | 紧急回滚流程 |
| 合规/审计要求 | 管理员 | 标准回滚流程 |
| 性能退化（非自动触发范围） | 发布负责人 | 标准回滚流程 |

### 6.3 回滚审批流程

#### 6.3.1 审批级别矩阵

| 环境 | 代码回滚 | 数据回滚 | 配置回滚 | 服务回滚 |
|------|---------|---------|---------|---------|
| **Dev** | 开发者自决 | 开发者自决 | 开发者自决 | 开发者自决 |
| **Test** | 审查者审批 | 审查者审批 | 审查者审批 | 审查者审批 |
| **Pro** | **发布负责人 + PM 双签** | **发布负责人 + DBA + PM 三签** | **发布负责人 + 运维 双签** | **发布负责人审批** |

#### 6.3.2 标准审批流程（Pro 环境）

```
1. 发现异常 → 发布负责人评估影响
      ↓
2. 决策：回滚 / 热修复 / 观察
      ↓
3. 若决策回滚：
   a. 发布负责人在 CI/CD 平台触发 rollback job
   b. 系统自动生成回滚工单（含：原因、影响范围、回滚目标版本）
   c. 根据回滚类型，通知对应审批人（PM/DBA/运维）
   d. 审批人 5 分钟内响应（超时自动通过，P0 故障除外）
      ↓
4. 审批通过后，自动执行回滚
      ↓
5. 回滚完成后自动验证
      ↓
6. 发布负责人确认回滚结果，关闭工单
      ↓
7. 24 小时内输出发布复盘报告（含 RCA）
```

#### 6.3.3 紧急回滚流程（P0 故障，绕过审批）

```
1. 监控告警触发 P0（或人工上报 P0）
      ↓
2. 发布负责人一键触发 emergency-rollback
      ↓
3. 系统立即执行回滚（无需等待审批）
      ↓
4. 同步通知 PM + 运维 + 相关干系人
      ↓
5. 回滚完成后自动验证
      ↓
6. 2 小时内补录回滚原因和影响评估
      ↓
7. 24 小时内完成 RCA 报告
```

> **约束**：紧急回滚权限仅限**发布负责人**和**运维管理员**，且必须在 2 小时内补录审批材料。

### 6.4 按部署策略的回滚路径

#### 6.4.1 直接部署（Dev/Test）

| 步骤 | 操作 | 命令/方式 |
|------|------|----------|
| 1 | 停止当前服务 | `systemctl stop {service}` / `docker stop {container}` |
| 2 | 回退代码到上一版本 | `git checkout {previous-tag}` |
| 3 | 重新构建/拉取上一版本镜像 | `docker pull {image}:{previous-tag}` |
| 4 | 重启服务 | `systemctl start {service}` / `docker run ...` |
| 5 | 健康检查 | `curl /health` |
| 6 | 冒烟验证 | 核心 API 测试 |

**特点**：有停机时间，回滚慢（需重新构建/部署），仅适用于 Dev/Test。

#### 6.4.2 蓝绿部署（Pro 推荐）

```
当前状态：Blue 运行 v1.0.1，Green 空闲
           ↓
发布 v1.0.2 到 Green → Green 冒烟测试通过 → 流量切到 Green
           ↓
【回滚场景】：Green 出现问题
           ↓
立即操作：负载均衡器切换流量回 Blue（< 30 秒）
           ↓
结果：Blue 继续运行 v1.0.1，业务无感知
           ↓
后续：Green 保留用于问题排查，修复后重新发布
```

| 步骤 | 操作 | 耗时 |
|------|------|------|
| 1 | 监控触发或人工确认异常 | - |
| 2 | 负载均衡器切换流量到 Blue | < 30s |
| 3 | 自动验证 Blue 健康状态 | 1-2min |
| 4 | 核心功能冒烟测试 | 2-3min |
| 5 | 通知干系人回滚完成 | - |
| **总计** | | **< 5 分钟** |

#### 6.4.3 金丝雀发布（Pro）

```
阶段 1：10% 流量 → v1.0.2，90% 流量 → v1.0.1
    ↓ 监控 5-10 分钟，指标正常
阶段 2：50% 流量 → v1.0.2，50% 流量 → v1.0.1
    ↓ 监控 5-10 分钟，指标正常
阶段 3：100% 流量 → v1.0.2
    ↓ 【回滚场景】：阶段 1 或阶段 2 发现异常
阶段 X：立即将所有流量切回 v1.0.1（< 30 秒）
```

| 回滚时机 | 操作 | 影响 |
|---------|------|------|
| 阶段 1（10%） | 直接停止金丝雀实例，流量 100% 回到 v1.0.1 | 仅 10% 用户受影响 |
| 阶段 2（50%） | 逐步降低 v1.0.2 流量至 0%，切回 v1.0.1 | 50% 用户短暂受影响 |
| 阶段 3（100%） | 同蓝绿回滚：启动上一版本实例，切流量 | 全部用户短暂受影响 |

#### 6.4.4 滚动更新（K8s）

| 步骤 | 操作 | 命令 |
|------|------|------|
| 1 | 查看当前 Deployment 历史 | `kubectl rollout history deployment/{name}` |
| 2 | 回滚到上一版本 | `kubectl rollout undo deployment/{name}` |
| 3 | 监控回滚进度 | `kubectl rollout status deployment/{name}` |
| 4 | 验证 Pod 状态 | `kubectl get pods` |
| 5 | 健康检查和冒烟测试 | `curl /health` + API 测试 |

**特点**：K8s 自动管理 Pod 替换，零停机，回滚到上一版本一键完成。

### 6.5 数据回滚策略

#### 6.5.1 数据库回滚

| 场景 | 回滚方式 | 前提条件 |
|------|---------|---------|
| 迁移脚本出错 | 执行 `down` 迁移脚本 | 迁移工具（Flyway/Liquibase/Alembic）支持回退 |
| 数据被污染 | 从备份恢复 + 增量日志重放 | 发布前已做 DB 备份（`operations-stage-execution` 强制要求） |
| 误删数据 | 从每日 dump 恢复单表 | 有定期 dump 备份 |

#### 6.5.2 数据库回滚流程

```
1. 发布前自动备份数据库（CI/CD 部署 Stage 前置步骤）
      ↓
2. 发现数据异常
      ↓
3. 决策：执行 down 迁移 / 从备份恢复 / 热修复数据
      ↓
4. 若从备份恢复：
   a. 停止写入（进入维护模式或只读）
   b. 从备份恢复（mysql < backup.sql / pg_restore）
   c. 重放增量 binlog/wal（如有）
   d. 验证数据一致性
   e. 恢复写入
      ↓
5. 记录数据回滚操作到问题跟踪记录
```

#### 6.5.3 缓存与消息回滚

| 组件 | 回滚操作 |
|------|---------|
| Redis | 清除新版本的缓存 key 前缀，或全量 flush（谨慎） |
| 消息队列 | 暂停消费 → 回滚代码 → 恢复消费；或清空错误消息重发 |

### 6.6 回滚验证

#### 6.6.1 回滚后必须执行的验证

| 验证项 | 方法 | 通过标准 |
|--------|------|---------|
| 服务健康 | `curl /health` / `/ready` | 200 OK |
| 核心 API | 冒烟测试脚本 | 关键接口全部通过 |
| 错误率 | 监控面板 | 5xx 错误率 < 0.1% |
| 延迟 | 监控面板 | P99 恢复至基线范围 |
| 数据库连接 | 应用日志 | 无连接异常 |
| 关键业务流 | E2E 测试 | 主流程通过 |

#### 6.6.2 回滚失败处理

若回滚后验证仍不通过：

```
1. 立即升级告警至 P0
2. 启动灾备预案（如有）
3. 通知技术负责人 + 运维负责人
4. 保留现场（不随意重启/清理）
5. 2 小时内必须定位根因或切换到备用方案
```

### 6.7 CI/CD 自动回滚 Job 设计

#### 6.7.1 GitHub Actions 回滚 Job

```yaml
# .github/workflows/rollback.yml
name: Emergency Rollback
on:
  workflow_dispatch:
    inputs:
      target_version:
        description: '回滚目标版本 (tag)'
        required: true
      reason:
        description: '回滚原因'
        required: true
      environment:
        description: '目标环境'
        required: true
        default: 'pro'
        type: choice
        options:
          - dev
          - test
          - pro

jobs:
  rollback:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    steps:
      - name: Checkout target version
        uses: actions/checkout@v4
        with:
          ref: ${{ github.event.inputs.target_version }}
          fetch-depth: 0

      - name: Record rollback event
        run: |
          echo "ROLLBACK: $(date)" >> rollback-history.log
          echo "From: $(git describe --tags --abbrev=0)" >> rollback-history.log
          echo "To: ${{ github.event.inputs.target_version }}" >> rollback-history.log
          echo "Reason: ${{ github.event.inputs.reason }}" >> rollback-history.log
          echo "By: ${{ github.actor }}" >> rollback-history.log

      - name: Deploy previous version (Blue-Green)
        if: github.event.inputs.environment == 'pro'
        run: |
          ./scripts/switch-traffic.sh ${{ github.event.inputs.target_version }}

      - name: Deploy previous version (Direct)
        if: github.event.inputs.environment != 'pro'
        run: |
          ./scripts/deploy.sh ${{ github.event.inputs.target_version }} ${{ github.event.inputs.environment }}

      - name: Health check
        run: |
          sleep 30
          curl -sf ${{ env.HEALTH_URL }} || exit 1

      - name: Smoke test
        run: ./scripts/smoke-test.sh ${{ github.event.inputs.environment }}

      - name: Notify stakeholders
        if: always()
        uses: slack/notify-action@v1
        with:
          message: |
            回滚完成
            环境: ${{ github.event.inputs.environment }}
            目标版本: ${{ github.event.inputs.target_version }}
            原因: ${{ github.event.inputs.reason }}
            执行人: ${{ github.actor }}
            结果: ${{ job.status }}
```

#### 6.7.2 金丝雀自动回滚 Job（监控触发）

```yaml
# 集成在部署流水线中的自动回滚
canary-rollback:
  if: failure() && github.ref == 'refs/tags/v*'
  needs: [deploy-canary, smoke-test, monitor-check]
  runs-on: ubuntu-latest
  steps:
    - name: Auto rollback canary
      run: |
        echo "金丝雀验证失败，自动回滚..."
        ./scripts/canary-rollback.sh
    - name: Verify rollback
      run: ./scripts/smoke-test.sh pro
```

### 6.8 回滚记录与审计

#### 6.8.1 回滚历史记录

每次回滚必须记录到 `{项目名}-回滚历史.csv`：

```csv
时间,环境,从版本,到版本,回滚类型,触发方式,原因,执行人,审批人,验证结果,耗时
2026-07-01 14:32:00,pro,v1.2.0,v1.1.5,代码+服务,自动,健康检查失败3次,CI/CD,系统,P0紧急,成功,45s
2026-07-01 10:15:00,test,v1.1.5,v1.1.4,数据,手动,迁移脚本污染数据,张三,李四,审批通过,成功,3min
```

#### 6.8.2 回滚门禁（增强版）

| 规则 | 内容 | 违反后果 |
|------|------|---------|
| **规则 1** | 生产发布必须有回滚预案，无预案不得上线 | 阻断发布 |
| **规则 2** | 回滚操作必须在 5 分钟内记录到问题跟踪记录 | 审计缺失 |
| **规则 3** | P0 紧急回滚须在 2 小时内补录审批材料 | 流程违规 |
| **规则 4** | 回滚后必须在 15 分钟内完成验证，未验证通过视为回滚失败 | 回滚不可靠 |
| **规则 5** | 数据回滚前必须做二次备份（防止回滚操作本身造成数据丢失） | 数据安全风险 |
| **规则 6** | 24 小时内必须输出发布复盘报告（含 RCA） | 改进闭环缺失 |

### 6.9 与现有技能的衔接

| 技能 | 衔接内容 |
|------|---------|
| `code-version-backup-management` | 提供代码回滚命令（revert/checkout/reset）和版本基线 |
| `operations-stage-execution` | 回滚预案纳入部署运维矩阵，回滚演练作为 Step 5 必做项 |
| `cicd-pipeline-management` | 回滚 job 纳入流水线，金丝雀/蓝绿部署策略定义回滚路径 |
| `observability-standards` | 提供监控指标（错误率/P99/健康检查）作为自动回滚触发源 |

### 6.10 执行检查清单

#### 发布前（必须完成）

- [ ] 已制定回滚预案（含：回滚目标版本、回滚步骤、验证方式）
- [ ] 已配置 CI/CD rollback job
- [ ] 数据库已备份（如有数据变更）
- [ ] 蓝绿/Green 环境已就绪（Pro 环境）
- [ ] 监控告警规则已配置（自动回滚依赖）
- [ ] 回滚审批人已明确

#### 回滚时

- [ ] 已记录回滚原因到问题跟踪记录
- [ ] 已获取必要审批（或已触发紧急回滚）
- [ ] 数据回滚前已做二次备份
- [ ] 回滚后已完成健康检查和冒烟验证

#### 回滚后

- [ ] 已通知所有干系人
- [ ] 已更新回滚历史记录
- [ ] 24 小时内完成发布复盘报告（含 RCA）

---

## 七、与 CI/CD 流水线的接口

本技能定义版本控制规则，`cicd-pipeline-management` 定义流水线执行。两者通过以下接口协作：

| 接口 | 本技能提供的规则 | 流水线执行方 |
|------|----------------|------------|
| tag 触发构建 | 版本号格式 `v{MAJOR}.{MINOR}.{PATCH}` | `cicd-pipeline-management` 触发器章节 |
| 自动备份 mirror | 备份策略定义（git push --mirror） | `cicd-pipeline-management` backup-mirror job |
| **自动/手动回滚** | **回滚触发条件、审批流程、目标版本标记** | **`cicd-pipeline-management` rollback job + 金丝雀自动回滚** |
| TDD 合规检查 | feat/fix 提交必须包含测试文件变更 | CI/CD 流水线检查 + `code-logic-review` 阻断 |
| release 分支保护 | Git Flow 中 release 分支冻结功能 | `cicd-pipeline-management` 触发器章节 |

> **注意**：流水线触发规则、质量闸门、部署策略等执行细节由 `cicd-pipeline-management` 技能定义，本技能不重复描述。

---

## 八、权限矩阵

| 操作 | 开发者 | 审查者 | PM | 管理员 |
|------|:------:|:------:|:--:|:------:|
| 创建分支 | Y | Y | Y | Y |
| 提交到 feature | Y | Y | - | Y |
| 合入 develop/release | - | Y | Y | Y |
| 合入 main | - | - | Y | Y |
| 创建 tag | - | - | Y | Y |
| 删除分支 | - | Y | Y | Y |

---

## 九、触发条件

当以下情况时调用本技能：
- 项目初始化时配置 Git 仓库和分支策略
- 需要选择或变更分支策略
- 生成或审查提交信息
- 管理版本号和发布标签
- 制定或执行备份策略
- 执行代码回滚或版本回退
- 配置 CI/CD 版本管理集成
- 审查 commit 的 TDD 合规性

---

## 十、与其他 DevFlow 技能的协作

| 集成阶段 | 引用技能 | 协作内容 |
|---------|---------|---------

## 编码与运维阶段反向声明

本技能被 `coding-stage-execution` 和 `operations-stage-execution` 内联引用（内联内容：提交约定、分支策略、回滚流程、权限矩阵）。修改本技能时，需同步检查两个 L2 技能中的内联速查表。

|
| Step 3 编码 | `coding-stage-execution` | 分支管理 + 提交规范执行 |
| Step 3 审查 | `code-logic-review` | 审核提交的 TDD 合规性 |
| Step 4 测试 | `testing-stage-execution` | 版本基线管理 |
| Step 5 部署 | `operations-stage-execution` | 发布 tag + 备份 + 回滚 |
| Step 5 CI/CD | `cicd-pipeline-management` | 自动 tag + 自动 mirror 备份 |
| 全局文档 | `project-document-management` | 文档版本控制规则 |
