---
name: "database-migration"
description: "数据库迁移管理技能。覆盖Schema版本管理、迁移脚本编写规范、回滚策略、多环境迁移流程和数据一致性校验，支持MySQL/PostgreSQL/MongoDB。被 coding-stage-execution / operations-stage-execution 调用。"
---

# 数据库迁移管理

## 定位

本技能定义项目数据库迁移的全流程规范，从Schema版本管理到多环境迁移执行。它是数据库变更管理的专项参考技能，被 `coding-stage-execution` 和 `operations-stage-execution` 在编码和部署阶段引用。

## 触发条件

当以下情况时调用本技能：
- 需要创建或修改数据库Schema
- 需要编写数据库迁移脚本
- 需要执行跨环境数据库迁移
- 需要制定迁移回滚策略
- 需要校验迁移后数据一致性
- 需要管理数据库Schema版本

---

## 一、Schema 版本管理

### 1.1 命名约定

迁移文件命名格式：`{timestamp}_{description}.{up|down}.sql`

```
20260704120000_create_users_table.up.sql
20260704120000_create_users_table.down.sql
20260704130000_add_email_index.up.sql
20260704130000_add_email_index.down.sql
```

### 1.2 版本号规则

- 每个迁移文件有唯一时间戳版本号
- 版本号递增，不可修改已执行的迁移
- Schema版本记录在 `_schema_migrations` 表中

### 1.3 兼容性原则

| 兼容类型 | 规则 | 部署要求 |
|---------|------|---------|
| 向前兼容 | 新版本代码可读旧版本数据 | 先部署代码再迁移数据 |
| 向后兼容 | 旧版本代码可读新版本数据 | 先迁移数据再部署代码 |
| 破坏性变更 | 需要协调部署窗口 | 分阶段迁移+双写过渡 |

### 1.4 Schema 版本追踪表

```sql
-- MySQL / PostgreSQL
CREATE TABLE IF NOT EXISTS _schema_migrations (
    version VARCHAR(14) PRIMARY KEY,
    description TEXT NOT NULL,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    execution_time_ms INTEGER,
    status VARCHAR(20) DEFAULT 'applied'
);
```

---

## 二、迁移脚本编写规范

### 2.1 基本要求

| 要求 | 说明 |
|------|------|
| 原子性 | 每个迁移文件必须是原子的（全部成功或全部失败） |
| 幂等性 | 迁移脚本可安全重复执行（使用 IF NOT EXISTS / IF EXISTS） |
| 可回滚 | 每个up迁移必须有对应的down迁移 |
| 事务包裹 | DDL和DML操作包裹在事务中（数据库支持时） |
| 无数据丢失 | 迁移不得导致数据丢失（除非有明确的降级方案） |

### 2.2 迁移脚本模板

```sql
-- =============================================
-- Migration: {description}
-- Version: {timestamp}
-- Author: {author}
-- =============================================

-- UP Migration
BEGIN;

-- 1. DDL: 表结构变更
CREATE TABLE IF NOT EXISTS {table_name} (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    -- ...
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. DML: 数据迁移（如需要）
-- INSERT INTO ... SELECT ... FROM ...

-- 3. 索引
CREATE INDEX IF NOT EXISTS idx_{table}_{column} ON {table}({column});

COMMIT;

-- =============================================
-- DOWN Migration
-- =============================================
-- BEGIN;
-- DROP TABLE IF EXISTS {table_name};
-- COMMIT;
```

### 2.3 编写检查清单

- [ ] 每个迁移文件包含 up 和 down 两个脚本
- [ ] up 脚本可重复执行（幂等）
- [ ] down 脚本可完整回滚 up 的变更
- [ ] DDL 和 DML 包裹在事务中
- [ ] 使用 IF NOT EXISTS / IF EXISTS 避免重复执行错误
- [ ] 大表变更使用 pt-online-schema-change 或 gh-ost（MySQL）
- [ ] 迁移脚本在 Dev/Test 环境验证后再应用到 Pro

---

## 三、回滚策略

### 3.1 回滚类型

| 类型 | 适用场景 | 操作 | 风险 |
|------|---------|------|------|
| 自动回滚 | 迁移执行失败 | 执行 down 脚本 | 低（原始数据未删除） |
| 手动回滚 | 发现数据问题 | 按回滚方案逐步执行 | 中 |
| 数据恢复 | 大规模数据损坏 | 从备份恢复 | 高（需要停机） |

### 3.2 回滚决策树

```
迁移后发现问题
├── 迁移脚本执行失败（未完成）→ 自动回滚（down脚本）
├── 数据不一致但可修复 → 手动回滚 + 数据修复脚本
├── 数据丢失或严重损坏 → 从备份恢复
└── 性能严重退化 → 回滚到迁移前版本
```

### 3.3 回滚要求

- 每个迁移必须有可执行的 down 脚本
- down 脚本必须在 Test 环境验证
- 大表变更的回滚需要评估执行时间
- 回滚操作必须记录日志

---

## 四、多环境迁移流程

### 4.1 环境顺序

```
Dev（开发） → Test（测试） → Pro（生产）
```

### 4.2 各环境要求

| 环境 | 数据要求 | 验证要求 | 审批要求 |
|------|---------|---------|---------|
| Dev | 使用开发数据或种子数据 | 迁移成功执行即可 | 无 |
| Test | 使用接近生产的测试数据 | 迁移成功+数据校验通过 | 技术负责人审批 |
| Pro | 生产真实数据 | 迁移成功+数据校验+性能验证 | 技术负责人+运维审批 |

### 4.3 数据脱敏

Test 环境的数据库应使用脱敏后的生产数据副本：

| 脱敏类型 | 字段示例 | 脱敏方式 |
|---------|---------|---------|
| 个人信息 | 手机号、邮箱 | 部分遮盖（138****1234） |
| 密码 | 密码哈希 | 替换为固定值 |
| 金额 | 交易金额 | 随机偏移或固定值 |
| IP地址 | 访问日志 | 替换为内网IP |

### 4.4 配置差异管理

不同环境的数据库配置通过环境变量或配置文件管理：

| 配置项 | Dev | Test | Pro |
|-------|-----|------|-----|
| 连接池大小 | 5 | 20 | 50 |
| 超时时间 | 30s | 10s | 5s |
| 慢查询阈值 | 1000ms | 500ms | 200ms |
| 备份频率 | 每日 | 每6小时 | 实时 |

---

## 五、数据一致性校验

### 5.1 校验方法

| 方法 | 说明 | 适用场景 |
|------|------|---------|
| 行数对比 | 迁移前后表行数对比 | 简单增删操作 |
| Checksum | 关键列的哈希值对比 | 数据变更 |
| 采样校验 | 随机抽样数据人工核对 | 复杂数据转换 |
| 业务规则校验 | 按业务规则检查数据完整性 | 关键业务表 |

### 5.2 校验脚本模板

```sql
-- 迁移后校验
SELECT
    (SELECT COUNT(*) FROM {table_name}) AS current_count,
    {expected_count} AS expected_count,
    CASE
        WHEN (SELECT COUNT(*) FROM {table_name}) = {expected_count}
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;
```

### 5.3 校验清单

- [ ] 表结构变更正确（DESC / \d）
- [ ] 索引创建成功
- [ ] 数据迁移行数一致
- [ ] 关键字段数据完整
- [ ] 外键约束满足
- [ ] 应用功能验证通过

---

## 六、数据库专项指南

### 6.1 MySQL

| 特性 | 说明 |
|------|------|
| 在线DDL | 使用 pt-online-schema-change 或 gh-ost 处理大表变更 |
| 字符集 | 推荐 utf8mb4 |
| 存储引擎 | 推荐 InnoDB |
| 慢查询 | 通过 slow_query_log 监控 |

### 6.2 PostgreSQL

| 特性 | 说明 |
|------|------|
| 迁移工具 | 推荐 Flyway 或自定义脚本 |
| 在线DDL | PostgreSQL 支持大多数 DDL 的非阻塞执行 |
| 事务DDL | 支持 DDL 事务，可安全回滚 |
| 扩展 | 需要时启用 pg_partman（分区）、pg_trgm（模糊搜索） |

### 6.3 MongoDB

| 特性 | 说明 |
|------|------|
| 迁移方式 | 使用迁移脚本（JavaScript） |
| 版本追踪 | 在 `_schema_migrations` collection 中记录 |
| 回滚 | 在迁移脚本中实现 undo 操作 |
| 大集合变更 | 分批处理（batch size 1000~5000） |

---

## 技能速查映射

| 调用本技能的阶段 | 引用技能 |
|---|---|
| Step 3 编码阶段数据库变更 | `coding-stage-execution` |
| Step 5 部署阶段数据库迁移 | `operations-stage-execution` |
| 数据库设计 | `sql-database`、`mongodb` |
| 数据库迁移CI/CD | `cicd-pipeline-management` |

## 与其他 DevFlow 技能的协作

| 集成阶段 | 引用技能 | 协作内容 |

## 编码与运维阶段反向声明

本技能被 `coding-stage-execution` 和 `operations-stage-execution` 引用。修改本技能时，需同步检查两个 L2 技能中的速查表。

| Step 3 编码 | `coding-stage-execution` | 编码阶段数据库变更规范 |
| Step 5 部署 | `operations-stage-execution` | 部署阶段数据库迁移执行 |
| Step 2 设计 | `design-stage-execution` | 数据模型设计输入 |

## 变更记录

| 日期 | 变更内容 | 变更人 |
|---|---|---|
| 2026-07-04 | VR-010/DT-006: 初始创建，6个核心章节（Schema版本管理/迁移脚本/回滚策略/多环境/数据校验/数据库专项） | jerry.yu |
