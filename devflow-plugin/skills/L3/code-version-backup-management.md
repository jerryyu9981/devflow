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

仓库路径、分支策略和远程仓库由 `{project_root}/.devflow/config.json` 定义，本技能读取该配置执行，不硬编码路径。

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

在 `.devflow/config.json` 中设置 `branchStrategy` 字段，支持三种模式：`trunk-based` / `github-flow` / `git-flow`。

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

### 4.3 DevFlow 插件自身版本管理（Single Source of Truth）

DevFlow 插件的版本号**严禁在 SKILL.md 或脚本中硬编码**。所有版本号必须遵循"单一来源"原则：

| 规则 | 说明 |
|------|------|
| 唯一来源 | 插件根目录下的 `version.json`，格式为 `{"version": "x.y.z"}` |
| 注入时机 | `setup.ps1` / `install.ps1` 从 `version.json` 读取后写入项目 `.devflow/config.json` 的 `devflowVersion` 字段 |
| 技能模板 | SKILL.md 中的 config.json 模板使用 `{从 version.json 动态读取}` 占位符，**不得出现具体版本号** |
| 更新流程 | `update.ps1` 从目标版本的 `version.json` 读取新版本号，自动更新 `config.json` |

**发布新版本时的强制检查**：
1. 更新 `version.json`
2. 更新 `CHANGELOG.md`
3. 全局搜索确认无硬编码残留：`grep -rn "\d\+\.\d\+\.\d\+" skills/ devflow-init/ devflow-phase-manager/ devflow-project-config/ --include="*.md"`
4. 运行 `setup.ps1` 验证生成的 `config.json` 版本号正确

---

## 五、备份策略

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
1. 备份远程仓库已在 `.devflow/config.json` 的 `remote.backup` 字段中配置
2. 已通过 `git remote add backup <backup-url>` 添加备份远程仓库
3. Hook 文件具有可执行权限

> DevFlow 插件安装脚本（`setup.ps1` / `setup.sh`）可通过 `--install-hook` 参数自动安装此 Hook。

---

## 六、回滚流程

### 6.1 代码回滚

```bash
# 回退指定 commit（推荐，保留历史）
git revert {commit-hash}

# 恢复特定文件到指定版本
git checkout v1.0.0 -- {file/path}

# 硬重置到指定版本（谨慎使用，仅本地分支）
git reset --hard {commit-hash}
```

### 6.2 回滚门禁

- 任何回滚操作必须在 `问题跟踪记录` 中记录原因和影响
- 生产回滚必须在 `发布复盘报告` 中记录根本原因分析
- 详细回滚预案参考 `operations-stage-execution` 的部署运维矩阵

---

## 七、与 CI/CD 流水线的接口

本技能定义版本控制规则，`cicd-pipeline-management` 定义流水线执行。两者通过以下接口协作：

| 接口 | 本技能提供的规则 | 流水线执行方 |
|------|----------------|------------|
| tag 触发构建 | 版本号格式 `v{MAJOR}.{MINOR}.{PATCH}` | `cicd-pipeline-management` 触发器章节 |
| 自动备份 mirror | 备份策略定义（git push --mirror） | `cicd-pipeline-management` backup-mirror job |
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
