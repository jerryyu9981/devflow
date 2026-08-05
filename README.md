# DevFlow — 软件开发工程规范框架

> 版本：v2.16.0 | 支持 TRAE / Claude Code / Cursor / Codex CLI
> 6 阶段全流程管控：版本规划 → 需求分析 → 架构设计 → 编码实现 → 测试验证 → 部署运维

DevFlow 是一个可插拔的软件开发工程规范框架。本仓库是 DevFlow 的**源码与开发文档库**（下载后用于安装或二次开发）。

---

## 从哪开始（三步入门）

| 步骤 | 操作 | 说明 |
|:----:|:-----|:-----|
| 1️⃣ | **安装**：进入 `devflow-plugin/` 执行 `install.bat`（Windows）或 `setup.sh`（macOS/Linux）| 将技能安装到你的 IDE（TRAE / Claude Code 等）|
| 2️⃣ | **初始化**：按提示设置项目名称、分支策略与远程仓库 | 生成 `.devflow/project-config.json` 与 `state.json` |
| 3️⃣ | **开始开发**：向 AI 助手发起第一个阶段指令（如"进入 Step 0 版本规划"）| DevFlow 自动驱动 6 阶段流程 |

> 只想快速试用？直接看 `devflow-plugin/README.md` 或本目录的 `DevFlow-用户指南.html` / `DevFlow-用户手册.html`。

---

## 目录地图

| 路径 | 内容 | 需要关注？ |
|:-----|:-----|:----------|
| `devflow-plugin/` | **插件本体**（技能 SKILL.md + 安装/发布脚本 + devflow-config.json）| ✅ 核心，安装与升级入口 |
| `DevFlow-用户指南.html` / `DevFlow-用户手册.html` | 用户交付文档（已更新至当前版本）| ✅ 快速上手 |
| `doc/` | **开发文档库**（按阶段分子目录，只保留当前版本 v2.16.0，历史版本在各自 `archive/`）| ✅ 二开/审计 |
| `doc/version/` | Step 0 版本规划（路线图、候选需求池、单版本规划）| 二开 |
| `doc/requirements/` | Step 1 需求分析 | 二开 |
| `doc/design/` | Step 2 架构设计 | 二开 |
| `doc/development/` | Step 3 编码实现（DevLogReport）| 二开 |
| `doc/test/` | Step 4 测试验证 | 二开 |
| `doc/release/` | Step 5 发布运维 + Release Note | 二开 |
| `doc/audit/` | 审计报告（assessment/review/verification/comprehensive）| 二开 |
| `doc/analysis/` | 预研与方案分析 | 二开 |
| `archive/` | **归档区**（历史插件版本、备份、分享 HTML、营销物料、旧技能源）| ⬜ 只读，无需关注 |
| `build.ps1` | 构建脚本 | 二开 |

---

## 文档归档规则（v2.16.0+）

每个 `doc` 业务子目录只保留**当前版本**文件；历史版本统一归入该目录的 `archive/` 子目录（只读，`git mv` 保留历史）。

```text
doc/test/                      # 仅当前版本 v2.16.0
├── DevFlow-测试报告-v2.16.0.md
└── archive/                   # 历史版本（v2.7~v2.15）
    ├── DevFlow-测试报告-v2.9.1.md
    └── ...
```

> 该规则已写入规范：`devflow-plugin/skills/L1/project-document-management.md` §6「文档就地归档规则」。

---

## 版本历史

最新版本：v2.16.0（测试巡检网络层监控增强 + 审计执行确定性加固）。完整变更见 `doc/release/DevFlow-Release-Note-All.md`。

---

## 许可与维护

- 维护者：DevFlow 团队
- 仓库远程：origin（主） / backup（备份） / github（GitHub 镜像）
- 三远程架构自动备份由 Git pre-push hook 保障（日志：`.devflow/logs/backup-hook.log`）
