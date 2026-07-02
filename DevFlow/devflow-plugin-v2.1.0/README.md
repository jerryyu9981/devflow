# DevFlow Plugin — 软件开发工程规范

> 版本：v2.3.1 | 支持 TRAE / Claude Code / Cursor / Codex CLI

DevFlow 是一个可插拔的软件开发工程规范框架，提供从版本规划到部署运维的完整 6 阶段管控能力。

## 快速开始

### 安装

**原则：每个项目独立安装，路径自由选择。**

在你想要使用 DevFlow 的项目根目录下执行（不是系统目录或用户主目录）：

```bash
# 方式一：克隆到项目目录（推荐）
# 在你的项目根目录执行，如 D:\MyProject\
git clone <your-repo-url> .devflow/

# 方式二：直接下载 release
curl -L <your-repo-url>/releases/download/v2.3.1/devflow-v2.3.1.zip -o devflow.zip
unzip devflow.zip -d .devflow/
```

> `.devflow/` 是建议的目录名，你可以根据团队规范自定义。

### 初始化

```bash
# Windows (PowerShell)
.devflow/setup.ps1

# macOS / Linux (Bash)
.devflow/setup.sh
```

安装脚本会自动：
1. 检测项目名称
2. 创建 `.devflow/config.json`（分支策略、备份配置）
3. 创建 `.devflow/state.json`（阶段状态）
4. 将 DevFlow 技能安装到 TRAE（如果检测到 TRAE 环境）
5. 可选：安装 Git post-push hook（自动备份）

#### 远程仓库认证

如果远程仓库需要认证（如 GitLab HTTP Basic Auth），有两种方式：

**方式一：URL 中嵌入凭据（适合自动化脚本）**
```
http://username:password@192.168.0.14/username/devflow.git
```
> 注意：密码中的特殊字符需 URL 编码，`@` → `%40`

**方式二：Git Credential Manager（推荐，更安全）**
首次 `git push` 或运行 `update.ps1` 时，Windows 会自动弹出 Git Credential Manager 对话框，输入用户名密码后勾选"记住密码"，后续操作无需重复输入。

### 开始使用

初始化完成后，在 TRAE 中调用：

```
调用 devflow-init 技能
```

它会检测你的项目当前处于哪个开发阶段，并引导你进入正确的 DevFlow 阶段。

## 架构

```
DevFlow
├── orchestrator/          ← 新增：状态管理层
│   ├── devflow-init/           项目初始化 + 阶段检测
│   ├── devflow-phase-manager/  阶段状态机 + 切换门禁
│   └── devflow-project-config/ 项目配置管理
│
├── skills/
│   ├── L1/                ← 总控调度（3 技能）
│   ├── L2/                ← 阶段执行（6 技能）
│   └── L3/                ← 专项参考（6 技能）
│
├── templates/             ← 18 个文档模板
└── docs/                  ← 规范文档
```

## 6 阶段流程

```
Step 0 版本规划 → Step 1 需求分析 → Step 2 架构设计
                                              ↓
Step 5 部署运维 ← Step 4 测试验证 ← Step 3 编码开发
```

每个阶段都有：入场门禁、规范矩阵、强制规则、输出要求、完成标准。

## 核心特性

| 特性 | 说明 |
|------|------|
| **编译层模式** | L2 内联 L3 核心规则，运行时只需 2 层深度 |
| **追溯链** | RT-ID → DT-ID → TD-ID，需求→设计→开发→测试全链路追溯 |
| **审计门禁** | 每阶段结束必须通过审计才能进入下一阶段 |
| **TDD 铁律** | feat/fix 提交必须包含测试，测试先于生产代码 |
| **可配置分支策略** | Trunk-Based / GitHub Flow / Git Flow 三选一 |
| **Git 原生备份** | `git push --mirror` 替代文件级拷贝 |
| **18 个文档模板** | 覆盖所有阶段的输出文档结构 |

## 更新

```bash
# 检查并更新到最新版本
.devflow/update.ps1    # Windows
.devflow/update.sh     # macOS/Linux
```

## 文档

- [DevFlow-软件开发工程规范](docs/DevFlow-软件开发工程规范.md) — 完整规范文档
- [版本历史](CHANGELOG.md)

## License

MIT
