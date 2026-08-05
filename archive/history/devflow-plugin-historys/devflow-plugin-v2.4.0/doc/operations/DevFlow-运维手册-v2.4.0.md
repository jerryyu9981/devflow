# DevFlow v2.4.0 — 运维手册

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| 版本号 | v2.4.0 |
| 编制日期 | 2026-07-03 |
| 运维负责人 | jerry.yu |

## 2. 安装与部署

### 2.1 新安装

```bash
# Windows
powershell -ExecutionPolicy Bypass -File install.ps1
# 或双击 install.bat

# macOS / Linux
bash install.sh
```

### 2.2 项目初始化

```bash
# Windows
powershell -File setup.ps1

# macOS / Linux
bash setup.sh
```

### 2.3 验证安装

```bash
# Windows
powershell -File scripts/validate-install.ps1

# macOS / Linux
bash scripts/validate-install.sh
```

## 3. 质量检查脚本

| 脚本 | 用途 | 命令 |
|------|------|------|
| check-skill-format.ps1 | 10 项格式检查 | `powershell -File scripts/check-skill-format.ps1 [-Fix]` |
| check-references.ps1 | 5 项引用检查 | `powershell -File scripts/check-references.ps1` |
| check-references.sh | Bash 版引用检查 | `bash scripts/check-references.sh` |
| validate-install.ps1 | 6 项安装验证 | `powershell -File scripts/validate-install.ps1` |
| validate-install.sh | Bash 版安装验证 | `bash scripts/validate-install.sh` |

## 4. 版本信息

| 文件 | 路径 | 说明 |
|------|------|------|
| version.json | devflow-plugin-v2.4.0/version.json | 版本号单一来源（SSOT） |
| CHANGELOG.md | devflow-plugin-v2.4.0/CHANGELOG.md | 版本变更历史 |
| state.json | .devflow/state.json | 项目当前阶段状态 |

## 5. 目录结构

```
devflow-plugin-v2.4.0/
├── skills/              # 26 个技能文件
│   ├── L1/             # 3 个编排层
│   ├── L2/             # 6 个阶段执行层
│   └── L3/             # 14 个专项参考层
├── templates/          # 24 个文档模板
├── scripts/            # 6 个质量脚本
├── devflow-init/       # 初始化编排器
├── devflow-phase-manager/  # 阶段管理编排器
├── devflow-project-config/ # 项目配置编排器
├── install.ps1 / .sh   # 交互式安装
├── install.bat         # Windows 双击安装
├── setup.ps1 / .sh     # 交互式初始化
├── update.ps1 / .sh    # 更新脚本
├── version.json        # 版本 SSOT
├── CHANGELOG.md        # 变更历史
├── README.md           # 项目说明
├── quickstart.md       # 快速入门（Markdown）
├── quickstart.html     # 快速入门（HTML）
└── doc/                # 项目文档
    ├── test/           # 测试文档
    ├── operations/     # 运维文档
    ├── audit/          # 审计文档
    ├── development/    # 开发文档
    ├── design/         # 设计文档
    ├── requirements/   # 需求文档
    └── version/        # 版本文档
```

## 6. 常见问题排查

| 问题 | 排查方法 | 解决方案 |
|------|----------|----------|
| Use Skill 命令无效果 | 检查 skills/ 目录是否存在 | 运行 install.ps1 安装 |
| PS1 脚本中文乱码 | 检查文件编码 | 确认 UTF-8 with BOM |
| 技能文件数量不对 | 运行 validate-install.ps1 | 对比 version.json |
| 格式检查大量 FAIL | 运行 check-skill-format.ps1 -Fix | 自动修复尾随空格 |

## 7. 联系方式

| 角色 | 联系方式 |
|------|----------|
| 项目负责人 | jerry.yu |
| 反馈渠道 | CHANGELOG.md + 快速入门 |

## 8. 变更记录

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| 1.0 | 2026-07-03 | v2.4.0 运维手册初始版本 |
