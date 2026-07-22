# DevFlow 运维手册 v2.9.1

> **文档类型**: 运维手册 / 运维移交清单
> **版本**: v2.9.1
> **项目**: DevFlow
> **日期**: 2026-07-22

---

## 1. 运维移交清单

| 类别 | 文档 | 状态 |
|:-----|:-----|:----:|
| 发布计划 | DevFlow-发布计划-v2.9.1.md | ✅ |
| 部署执行报告 | DevFlow-部署执行报告-v2.9.1.md | ✅ |
| 回滚方案 | DevFlow-回滚方案-v2.9.1.md | ✅ |
| 上线检查报告 | DevFlow-上线检查报告-v2.9.1.md | ✅ |
| 发布复盘 | DevFlow-发布复盘报告-v2.9.1.md | ✅ |
| Release Note | DevFlow-Release-Note-v2.9.1.md | ✅ |
| 运维手册 | 本文档 | ✅ |

---

## 2. 版本信息

| 项目 | 内容 |
|:-----|:------|
| 当前版本 | v2.9.1 |
| 上一版本 | v2.8.5 |
| Git Tag | v2.9.1 |
| 发布日期 | 2026-07-22 |
| 配置架构 | 双配置体系（devflow-config.json + project-config.json） |

---

## 3. 日常运维操作

### 3.1 安装/更新

```powershell
# 全新安装
.\download-devflow.ps1 -Operation clone -TargetDir <目标目录>

# 更新到最新版本
.\download-devflow.ps1 -Operation update

# 切换到指定版本
git checkout v2.9.1
```

### 3.2 验证安装

```powershell
# 全量验证
.\.devflow\scripts\validate-install.ps1 -Mode full

# 快速验证（仅 init 模式）
.\.devflow\scripts\validate-install.ps1 -Mode init

# 静默模式（返回对象）
$result = .\.devflow\scripts\validate-install.ps1 -Mode full -Quiet
$result.Valid  # $true / $false
```

### 3.3 验证模式说明

| 模式 | 检查项数 | 适用场景 |
|:-----|:--------:|:---------|
| package | 11 | 下载包完整性验证 |
| install | 14 | 安装后验证 |
| update | 16 | 更新后验证 |
| init | 6 | 初始化验证 |
| full | 16 | 全量验证 |

---

## 4. 常见故障排查

### 4.1 验证失败

| 现象 | 可能原因 | 处理方法 |
|:-----|:---------|:---------|
| C01 devflow-config.json 不存在 | 旧版本只有 version.json | 正常，旧版本兼容，可升级到 v2.9.1 |
| C15 版本不一致（Warn） | 新旧配置版本不同 | 过渡期正常，不影响使用 |
| C14 BOM 警告 | backup 目录遗留文件 | 不影响功能，可忽略 |
| C08 引用检查警告 | 未注册引用 | 过渡期遗留，后续版本统一 |

### 4.2 升级失败

| 现象 | 可能原因 | 处理方法 |
|:-----|:---------|:---------|
| download-devflow.ps1 更新失败 | 网络问题 / 仓库不可达 | 检查网络连接，重试或手动 git pull |
| package 验证失败 | 下载包损坏 | 自动删除并重新下载 |
| Update 后验证失败 | 本地变更冲突 | 查看 stash，手动解决冲突 |

### 4.3 回滚操作

```powershell
# 快速回滚到上一版本
git checkout v2.8.5

# 验证回滚结果
.\.devflow\scripts\validate-install.ps1 -Mode full

# 重新安装旧版本
.\download-devflow.ps1 -Operation clone -TargetDir <新目录>
```

---

## 5. 配置文件说明

### 5.1 框架级配置

**文件**: `devflow-plugin/devflow-config.json`

| 字段 | 说明 |
|:-----|:------|
| _meta | 元数据（schema版本、更新时间） |
| name | 插件名称 |
| devflowVersion | DevFlow 版本号 |
| minTraeVersion | 最低 TRAE 版本要求 |
| skills | 技能清单（31 个） |
| migration | 迁移说明（废弃文件、迁移指南） |

### 5.2 项目级配置

**文件**: `.devflow/project-config.json`

| 字段 | 说明 |
|:-----|:------|
| _meta | 元数据 |
| project | 项目信息（名称、代码、版本、描述） |
| remote | 远程仓库（origin、backup） |
| backup | 备份策略（类型、调度） |
| branchStrategy | 分支策略 |
| naming | 命名规范 |

### 5.3 运行时状态

**文件**: `.devflow/state.json`

| 字段 | 说明 |
|:-----|:------|
| project | 项目名称 |
| devflowVersion | 当前 DevFlow 版本 |
| currentPhase | 当前阶段 |
| phaseHistory | 阶段历史 |

---

## 6. 联系人

| 角色 | 职责 | 响应时间 |
|:-----|:-----|:--------:|
| 发布负责人 | 版本发布、回滚决策 | 1 小时 |
| 开发负责人 | Bug 修复、技术支持 | 4 小时 |
| 测试负责人 | 验证支持、测试协助 | 4 小时 |

---

## 7. 版本历史

| 版本 | 发布日期 | 主要变更 |
|:-----|:--------:|:---------|
| v2.9.1 | 2026-07-22 | 配置重构 + 多模式验证 + 全阶段门禁 |
| v2.8.5 | — | 上一稳定版本 |
