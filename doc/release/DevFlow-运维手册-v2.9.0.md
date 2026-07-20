# DevFlow 运维手册 v2.9.0

> **文档类型**: 运维手册
> **版本**: v2.9.0
> **项目**: DevFlow
> **日期**: 2026-07-21

---

## 1. 项目基本信息

| 项目 | 内容 |
|:----|:------|
| 项目名称 | DevFlow |
| 项目类型 | 软件开发工程规范技能框架 |
| 核心技能 | 3 个 L1 + 6 个 L2 + 20+ 个 L3 |
| 项目版本 | v2.9.0 |
| DevFlow 框架版本 | v2.8.5 |
| 授权协议 | MIT |
| 兼容 IDE | TRAE, Claude Code, Cursor, Codex CLI |

## 2. 运维移交清单

| 移交项 | 状态 | 说明 |
|:------|:----:|:-----|
| 项目文档 | ✅ | 完整 6 阶段文档体系 |
| 版本历史 | ⬜ | doc/release/README.md — 待更新 |
| 发布文档 | ✅ | 发布计划 + Release Note + 回滚方案 |
| Git 仓库 | ✅ | origin + backup 双远程 |
| 构建命令 | 🚫 不适用 | 纯 Markdown 框架，无需构建 |
| 测试流程 | ✅ | 10 个测试用例 + 测试报告 + 测试回溯审计 |
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
| 版本号不一致 | 检查 config.json projectVersion | 手动更新后重新提交 |
| 还债配额门禁误报 | 检查 0.0a 规则(5)(6)(7) | 确认还债占比计算逻辑 |
| 覆盖率门禁误判 | 检查 testing 覆盖率门禁章节 | 确认门槛配置（默认 80%） |

## 5. 本版本新运维要点

| 新增功能 | 影响 | 运维操作 |
|:---------|:-----|:---------|
| 还债配额门禁 (0.0a) | Step 0 执行新增门禁检查 | 需关注还债占比 <15% 告警 |
| E2E 验证流程 (Step 4) | 测试阶段新增流程 | 测试前需准备 E2E 场景列表 |
| 覆盖率门禁 (Step 4) | 测试阶段新增门禁 | 确保新代码行覆盖率 ≥80% |
| version.json 补全 (devflow-init) | 初始化新增步骤 | 确保 config.json remote.origin 正确 |

## 6. 常用命令速查

```powershell
# 查看当前项目版本
Get-Content .devflow/config.json | ConvertFrom-Json | Select-Object projectVersion

# 查看版本历史
git tag -l 'v*' | sort -V

# 查看变更摘要
git log v2.8.5..v2.9.0 --oneline

# 查看完整变更
git diff v2.8.5..v2.9.0 --stat

# 手动发布
git add -A
git commit -m "feat(devflow): v2.9.0"
git tag v2.9.0
git push origin v2.9.0
git push backup v2.9.0
```

## 7. 目录结构

```
DevFlow/
├── .devflow/              # 项目状态和配置
├── devflow-plugin/        # 技能框架核心
│   ├── skills/
│   │   ├── L1/           # 编排层技能
│   │   ├── L2/           # 阶段执行层技能
│   │   └── L3/           # 专项技能层
│   ├── devflow-init/     # 初始化技能
│   └── version.json      # DevFlow 框架版本
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
| 1.0.0 | 2026-07-21 | v2.9.0 运维手册（更新自 v2.8.5） | PM-DevFlow-Dev |
