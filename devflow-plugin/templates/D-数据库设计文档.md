# 数据库设计文档

## 文档元信息

| 项目 | 内容 |
|------|------|
| **项目名** | {项目名} |
| **文档版本** | {版本号} |
| **状态** | [Draft] / [Review] / [Approved] |
| **数据库类型** | [MySQL / PostgreSQL / MongoDB / Redis] |
| **作者** | {姓名} |
| **审批人** | {姓名} |

---

## 1. 数据总览

### 1.1 数据库信息

| 项目 | 说明 |
|------|------|
| 数据库引擎 | {MySQL 8.0 / PostgreSQL 15 / MongoDB 6.0} |
| 字符集 | `utf8mb4` |
| 排序规则 | `utf8mb4_unicode_ci` |
| ER 图参考 | `{ER图文件路径或链接}` |

### 1.2 实体关系概览

| 实体名 | 别名 | 说明 | 核心字段 |
|--------|------|------|---------|
| {实体名} | {别名} | {简要描述} | {字段列表} |
| {实体名} | {别名} | {简要描述} | {字段列表} |

---

## 2. 各表结构

### 2.1 `{表名}` — {表说明}

| 字段名 | 类型 | 长度 | 允许空 | 主键 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|--------|------|------|
| id | BIGINT | 20 | 否 | 是 | AUTO_INCREMENT | PRIMARY KEY | 主键 ID |
| {field_name} | VARCHAR | 255 | 否 | 否 | | UNIQUE | {字段说明} |
| {field_name} | INT | 11 | 是 | 否 | 0 | | {字段说明} |
| {field_name} | DATETIME | | 否 | 否 | CURRENT_TIMESTAMP | | {字段说明} |
| created_at | DATETIME | | 否 | 否 | CURRENT_TIMESTAMP | | 创建时间 |
| updated_at | DATETIME | | 否 | 否 | CURRENT_TIMESTAMP ON UPDATE | | 更新时间 |
| deleted_at | DATETIME | | 是 | 否 | | | 软删除时间 |

**建表 SQL 参考：**

```sql
CREATE TABLE `{表名}` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  ...
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at` DATETIME DEFAULT NULL COMMENT '软删除时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='{表说明}';
```

### 2.2 `{表名}` — {表说明}

...

---

## 3. 索引设计

| 表名 | 索引名 | 索引字段 | 索引类型 | 说明 |
|------|--------|---------|---------|------|
| {表名} | idx_{字段} | {字段} | [BTREE / HASH / UNIQUE / FULLTEXT] | {加速查询说明} |
| {表名} | idx_{字段1}_{字段2} | {字段1, 字段2} | [BTREE / UNIQUE] | {复合索引说明} |

---

## 4. 迁移策略

| 阶段 | 操作 | 说明 |
|------|------|------|
| 首次部署 | 执行全量 DDL 脚本 | 创建所有表结构和索引 |
| 增量变更 | 执行增量 DDL 脚本 | 每次变更一个独立脚本，不可修改历史脚本 |
| 回滚策略 | 执行对应回滚 DDL | 每次增量 DDL 必须附带回滚脚本 |
| 数据迁移 | 执行数据迁移脚本 | 涉及数据迁移时使用，需提供数据校验方案 |
| 工具 | [Flyway / Liquibase / Alembic / Prisma Migrate] | 版本管理工具 |

**迁移脚本命名规范：** `V{版本号}__{描述}.sql`（如 `V1.0.0__init_schema.sql`）

---

## 5. 修订历史

| 版本 | 日期 | 修订说明 | 修订人 | 批准人 |
|------|------|---------|--------|--------|
| v{版本号} | {YYYY-MM-DD} | {修订说明} | {姓名} | {姓名} |
