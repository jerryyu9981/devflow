# DevFlow 运维手册 v2.8.5

> **文档类型**: 运维手册
> **版本**: v2.8.5
> **项目**: DevFlow
> **日期**: 2026-07-20

---

## 1. 项目基本信息

| 项目 | 内容 |
|:----|:------|
| 项目名称 | DevFlow |
| 项目类型 | 软件开发工程规范技能框架 |
| 技能数量 | 28 个核心技能（L1: 3, L2: 6, L3: 16, Orchestrator: 3）|
| 文档模板 | 24 个 |
| 总代码行 | ~7,800 |
| 授权协议 | MIT |
| 兼容 IDE | TRAE, Claude Code, Cursor, Codex CLI |

## 2. 运维移交清单

| 移交项 | 状态 | 说明 |
|:------|:----:|:-----|
| 项目文档 | ✅ | 完整 6 阶段文档体系 |
| 版本历史 | ✅ | Changelog（doc/release/README.md）|
| 发布文档 | ✅ | 发布计划 + Release Note + 回滚方案 |
| Git 仓库 | ✅ | origin + backup 双远程 |
| 构建命令 | ✅ | 无需构建（纯 Markdown 框架）|
| 测试流程 | ✅ | 21 个测试用例 + 测试报告 |
| 回滚方案 | ✅ | 代码回滚 + Tag 回滚 |
| 联系人 | ✅ | PM-DevFlow-Dev |
| SLA/SLO | ✅ | 见下文 |

## 3. SLA / SLO

| 指标 | 目标 | 说明 |
|:----|:----:|:-----|
| 版本发布响应时间 | 2h | 从审批到 Tag 推送完成 |
| P0 故障响应时间 | 2h | 紧急回滚 + 补材料 |
| P1 故障响应时间 | 24h | 标准回滚 + RCA |
| 版本发布频率 | 按需 | 建议每 1-2 周发布一个迭代 |

## 4. 常见故障与排障

| 故障场景 | 排查步骤 | 解决方案 |
|:--------|---------|:---------|
| 技能文件格式异常 | 检查 Markdown 渲染 | `git checkout HEAD -- <file>` 恢复 |
| Git Tag 冲突 | `git tag -l 'v*'` 检查 | 删除冲突 Tag 后重推 |
| 远程推送失败 | `git remote -v` 确认 | 检查网络 + 认证配置 |
| 版本号不一致 | 检查 version.json | 手动更新后重新提交 |
| 文档链接断裂 | 追溯矩阵检查 | 修正 RT-ID/TD-ID/TT-ID 引用 |

## 5. 常用命令速查

```powershell
# 查看当前版本
cat devflow-plugin/version.json

# 查看版本历史
git tag -l 'v*' | sort -V

# 查看变更摘要
git log v2.8.4..v2.8.5 --oneline

# 查看完整变更
git diff v2.8.4..v2.8.5 --stat

# 自动化发布（需先确认 version.json 版本号）
.\devflow-plugin\release.ps1 -Version "v2.8.6"

# 手动发布
git add -A
git commit -m "commit message"
git tag v2.8.6
git push origin v2.8.6
git push backup v2.8.6
```

## 6. 目录结构

```
DevFlow/
├── .devflow/              # 项目状态和配置
├── devflow-plugin/        # 技能框架核心
│   ├── skills/
│   │   ├── L1/           # 编排层技能
│   │   ├── L2/           # 阶段执行层技能
│   │   └── L3/           # 专项技能层
│   ├── devflow-init/     # 初始化技能
│   ├── release.ps1       # 自动化发布脚本
│   └── version.json      # 版本权威来源
├── doc/                   # 项目文档
│   ├── version/          # 版本规划文档
│   ├── requirements/     # 需求文档
│   ├── design/           # 设计文档
│   ├── development/      # 开发文档
│   ├── test/             # 测试文档
│   ├── release/          # 发布文档
│   └── audit/            # 审计文档
└── README.md
```

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-20 | v2.8.5 运维手册 | PM-DevFlow-Dev |
