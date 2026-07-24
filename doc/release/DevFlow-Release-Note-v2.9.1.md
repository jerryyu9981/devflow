# DevFlow Release Note v2.9.1

> **发布版本**: v2.9.1
> **发布日期**: 2026-07-22
> **发布类型**: 小版本迭代（功能增强 + 架构优化）
> **Git Tag**: v2.9.1

---

## 版本亮点

v2.9.1 是一次架构优化版本，核心改进包括：

1. **配置体系重构** — 引入 `devflow-config.json` 作为框架级唯一配置源，与 `project-config.json` 项目级配置分离
2. **多模式验证系统** — `validate-install.ps1` 支持 5 种验证模式，覆盖下载→安装→更新→初始化→全量各阶段
3. **验证门禁嵌入** — `download-devflow.ps1` Clone/Update 后强制执行 package 模式验证，失败自动处理
4. **全阶段产出验证** — 6 个 L2 阶段技能文档全部新增产出物存在性验证规则，杜绝空输出
5. **完全向后兼容** — 新旧配置并存，分代版本比对，过渡期平滑升级

---

## 新增功能

### F-01 配置体系重构（P0）

- **devflow-config.json**：框架级统一配置，替代 version.json + devflow-manifest.json
  - 合并了版本号、技能清单、元数据等信息
  - 包含 31 个技能定义（3 个 L1 + 28 个 L2+）
  - 支持迁移说明和废弃文件列表
- **project-config.json**：项目级独立配置，替代 `.devflow/config.json`
  - 包含项目元数据、远程仓库、备份策略、命名规范等
  - 与框架配置完全分离，项目升级不影响项目配置
- **向后兼容**：旧配置文件继续可用，新配置优先读取

### F-04 validate-install 多模式验证（P0）

- **5 种验证模式**：
  - `package`：下载包完整性验证（11 项检查）
  - `install`：安装后验证（14 项检查）
  - `update`：更新后验证（16 项检查）
  - `init`：初始化验证（6 项检查）
  - `full`：全量验证（16 项检查）
- **16 项检查定义**：配置存在性、语法、关键字段、技能完整性、模板完整性、脚本完整性、BOM 检查、版本一致性等
- **分代版本一致性**：同代配置版本必须一致（Fail），新旧两代版本差异为警告（Warn）
- **Quiet 模式**：返回结构化对象，便于脚本集成

### F-05 全流程验证门禁（P0）

- **download Clone 门禁**：下载完成后强制 package 模式验证，失败自动删除下载目录
- **download Update 门禁**：有更新时才验证，已是最新版本跳过
- **异常降级机制**：验证脚本异常时回退到基础 manifest 检查，不阻断流程
- **失败处理策略**：Clone 失败清理目录，Update 失败保留状态并报警

### F-03 全阶段产出验证门禁（P1）

- **6 个 L2 阶段文档全部更新**：
  - version-planning-stage-execution.md
  - requirements-stage-execution.md
  - design-stage-execution.md
  - coding-stage-execution.md
  - testing-stage-execution.md
  - operations-stage-execution.md
- **每阶段新增 3 处验证规则**：强制规则、完成标准、输出要求
- **Step 5 全阶段产出盘点**：operations 阶段新增 6 阶段盘点表和 Release Checklist
- **空输出率 = 0%**：发布前必须确认所有阶段产出物真实存在

### F-02 脚本简化与 setup 保留（P1）

- **setup.ps1**：继续作为内部模块，负责技能部署和 IDE 集成
- **download-devflow.ps1**：版本升级到 v2.9.1，集成验证门禁
- **不删除任何脚本**：保持向后兼容，逐步过渡

---

## 技术改进

| 改进项 | 说明 |
|:-------|:-----|
| 数组计数 bug 修复 | 使用 `@(...)` 强制数组包装，解决单元素时 `.Count` 返回空的问题 |
| 版本号读取优先级 | 优先从 devflow-config.json 读取，fallback 到 version.json |
| BOM 清理 | 146 个 .json/.md 文件移除 UTF-8 BOM（.ps1 保留 BOM 以兼容 PowerShell 5.1） |
| 脚本位置优化 | package 级脚本仅在 package 模式检查，避免 install 模式误报 |

---

## 兼容性说明

- **向后兼容**：v2.9.1 完全兼容 v2.8.5 及之前版本
- **过渡期策略**：新旧配置并存，新配置优先，旧配置继续可用
- **升级路径**：直接 `download-devflow.ps1 -Operation update` 即可升级
- **回滚方式**：`git checkout v2.8.5` 或重新安装旧版本

---

## 已知问题

| 问题 | 级别 | 说明 | 计划版本 |
|:-----|:----:|:-----|:--------:|
| 模板文件 9/24 未补全 | 低 | 模板数量不足，后续逐步补全 | v2.10.0 |
| 138 个未注册技能引用 | 低 | 引用系统未统一 | v2.10.0 |
| 旧配置文件并存 | 低 | version.json 等旧配置暂保留 | v3.0.0 正式废弃 |

---

## 文件变更统计

| 类别 | 新增 | 修改 | 合计 |
|:-----|:----:|:----:|:----:|
| 配置文件 | 2 | 0 | 2 |
| 脚本 | 0 | 3 | 3 |
| 技能文档 | 0 | 6 | 6 |
| 设计文档 | 4 | 0 | 4 |
| 开发文档 | 3 | 0 | 3 |
| 测试文档 | 2 | 0 | 2 |
| 发布文档 | 6 | 0 | 6 |
| 审计文档 | 1 | 0 | 1 |
| **合计** | **18** | **9** | **27** |

---

## 升级方法

```powershell
# 方式 1：使用 download-devflow.ps1 更新
cd devflow-plugin
.\download-devflow.ps1 -Operation update

# 方式 2：Git Tag 切换
git fetch --tags
git checkout v2.9.1

# 验证安装
.\.devflow\scripts\validate-install.ps1 -Mode full
```

---

**发布负责人**: PM-DevFlow-Release
**发布日期**: 2026-07-22
