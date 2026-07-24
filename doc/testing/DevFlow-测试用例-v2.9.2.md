# DevFlow 测试用例 v2.9.2

> **文档类型**: 测试用例
> **版本**: v2.9.2
> **项目**: DevFlow
> **阶段**: Step 4 测试
> **日期**: 2026-07-23
> **负责人**: PM-DevFlow-Test

---

## 1. 用例列表

### TT-v2.9.2-001: version.json 字段完整性

| 属性 | 内容 |
|:-----|:-----|
| **TT-ID** | TT-v2.9.2-001 |
| **关联 RT-ID** | AC-01 |
| **关联 TD-ID** | TD-292-001 |
| **优先级** | P0 |
| **测试类型** | 合规测试 |

**前置条件**: 项目根目录存在 version.json

**测试步骤**:
1. 读取 `version.json`
2. 验证 `version` 字段值为 `"2.9.2"`
3. 验证 `repository` 字段非空且为 `"http://192.168.0.14/jerry.yu/devflow.git"`
4. 验证 `homepage` 字段非空且为 `"http://192.168.0.14/jerry.yu/devflow"`

**预期结果**:
- version = "2.9.2" ✅
- repository 非空 ✅
- homepage 非空 ✅

---

### TT-v2.9.2-002: 三配置版本号一致性

| 属性 | 内容 |
|:-----|:-----|
| **TT-ID** | TT-v2.9.2-002 |
| **关联 RT-ID** | AC-02 |
| **关联 TD-ID** | TD-292-001, TD-292-002 |
| **优先级** | P0 |
| **测试类型** | 合规测试 |

**前置条件**: 三个配置文件均存在

**测试步骤**:
1. 读取 `version.json`，记录 `version` 字段
2. 读取 `devflow-plugin/devflow-config.json`，记录 `devflowVersion` 字段
3. 读取 `.devflow/config.json`，记录 `projectVersion` 字段
4. 对比三个字段值是否均为 `"2.9.2"`

**预期结果**:
- version.json: version = "2.9.2" ✅
- devflow-config.json: devflowVersion = "2.9.2" ✅
- .devflow/config.json: projectVersion = "2.9.2" ✅

---

### TT-v2.9.2-003: .devflow/config.json projectVersion

| 属性 | 内容 |
|:-----|:-----|
| **TT-ID** | TT-v2.9.2-003 |
| **关联 RT-ID** | AC-03 |
| **关联 TD-ID** | TD-292-002 |
| **优先级** | P0 |
| **测试类型** | 合规测试 |

**前置条件**: `.devflow/config.json` 存在

**测试步骤**:
1. 读取 `.devflow/config.json`
2. 验证 `projectVersion` 字段值为 `"2.9.2"`

**预期结果**:
- projectVersion = "2.9.2" ✅

---

### TT-v2.9.2-004: 弃用文件备份存在

| 属性 | 内容 |
|:-----|:-----|
| **TT-ID** | TT-v2.9.2-004 |
| **关联 RT-ID** | AC-04 |
| **关联 TD-ID** | TD-292-003 |
| **优先级** | P1 |
| **测试类型** | 合规测试 |

**前置条件**: 备份操作已完成

**测试步骤**:
1. 列出 `.devflow/backup/` 目录内容
2. 验证存在 `devflow-plugin_version.json.bak.20260723`
3. 验证存在 `devflow-plugin_devflow-manifest.json.bak.20260723`

**预期结果**:
- 两个备份文件均存在 ✅

---

### TT-v2.9.2-005: 弃用文件已删除

| 属性 | 内容 |
|:-----|:-----|
| **TT-ID** | TT-v2.9.2-005 |
| **关联 RT-ID** | AC-05 |
| **关联 TD-ID** | TD-292-003 |
| **优先级** | P1 |
| **测试类型** | 合规测试 |

**前置条件**: 删除操作已完成

**测试步骤**:
1. 搜索 `devflow-plugin/version.json`
2. 搜索 `devflow-plugin/devflow-manifest.json`

**预期结果**:
- 两个文件均不存在（Glob 返回空）✅

---

### TT-v2.9.2-006: 风险归集检查模板章节

| 属性 | 内容 |
|:-----|:-----|
| **TT-ID** | TT-v2.9.2-006 |
| **关联 RT-ID** | AC-06 |
| **关联 TD-ID** | TD-292-004 |
| **优先级** | P2 |
| **测试类型** | 文档验证 |

**前置条件**: operations-stage-execution.md 已更新

**测试步骤**:
1. 搜索 `devflow-plugin/skills/L2/operations-stage-execution.md` 中的"风险归集检查"
2. 验证包含"问题跟踪记录 — 风险归集检查章节（必填）"说明
3. 验证包含表格模板（检查项/结果/说明）

**预期结果**:
- 关键字匹配成功 ✅
- 包含必填说明 ✅
- 包含表格模板 ✅

---

## 2. 安全扫描用例

### TT-v2.9.2-007: 敏感信息扫描

| 属性 | 内容 |
|:-----|:-----|
| **TT-ID** | TT-v2.9.2-007 |
| **关联 RT-ID** | — |
| **关联 TD-ID** | 全部变更文件 |
| **优先级** | P1 |
| **测试类型** | 安全测试 |

**测试步骤**:
1. 扫描所有变更文件（version.json / devflow-config.json / .devflow/config.json / operations-stage-execution.md）
2. 检查是否包含密码、令牌、密钥、API Key 等敏感信息

**预期结果**:
- 无敏感信息泄露 ✅

---

## 3. 回归测试用例

### TT-v2.9.2-008: v2.9.1 配置不一致问题回归

| 属性 | 内容 |
|:-----|:-----|
| **TT-ID** | TT-v2.9.2-008 |
| **关联 RT-ID** | — |
| **关联 TD-ID** | — |
| **优先级** | P1 |
| **测试类型** | 回归测试 |

**测试步骤**:
1. 确认 v2.9.1 遗留的配置不一致问题（项目根 version.json 2.8.5 vs devflow-config.json 2.9.1）
2. 验证当前版本三个配置文件版本号均为 2.9.2

**预期结果**:
- 配置不一致问题已修复 ✅

---

## 修订历史

| 版本 | 日期 | 描述 | 作者 |
|:----:|:----:|:-----|:----:|
| 1.0.0 | 2026-07-23 | v2.9.2 测试用例初始创建 | PM-DevFlow-Test |
