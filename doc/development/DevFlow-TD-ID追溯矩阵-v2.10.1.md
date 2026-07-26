# DevFlow 设计开发追溯矩阵 — v2.10.1

> 文档类型：设计开发追溯矩阵（TD-ID）
> 版本：v2.10.1
> 日期：2026-07-26

---

| RT-ID | DT-ID | TD-ID | 任务描述 | 涉及文件 | 状态 |
|:-----:|:-----:|:-----:|:---------|:---------|:----:|
| RT-2101-001 | DT-2101-001 | TD-2101-001 | 删除旧 config.json，更新所有引用路径 | `.devflow/config.json` (删除)、各 L2 技能文档中 `.devflow/config.json` 路径引用 | ⏳ |
| RT-2101-002 | DT-2101-002 | TD-2101-002 | 验证远程备份规范 §5.0 章节完整性 | `code-version-backup-management.md` + SKILL.md 副本 | ⏳ |
| RT-2101-003 | DT-2101-003 | TD-2101-003 | 用户指南/手册纳入发布交付物门禁 | `operations-stage-execution.md` + SKILL.md 副本 | ⏳ |
| RT-2101-004 | DT-2101-004 | TD-2101-004 | 技术债务总表添加修订历史表格 | `DevFlow-技术债务总表.md` | ⏳ |
| RT-2101-005 | DT-2101-005 | TD-2101-005 | 跨阶段同步检查项追加 | `operations-stage-execution.md` + SKILL.md 副本 | ⏳ |
| RT-2101-006 | DT-2101-006 | TD-2101-006 | 发布产物命名标准化 | `operations-stage-execution.md` + SKILL.md 副本 | ⏳ |
| RT-2101-007 | DT-2101-007 | TD-2101-007 | TD-028 债务状态更新 | `DevFlow-技术债务总表.md` | ⏳ |
| RT-2101-008 | DT-2101-008 | TD-2101-008 | config.json → project-config.json 改名 | 与 TD-2101-001 同步执行 | ⏳ |

**Subtask CheckList**：

| TD-ID | 子任务 | 完成 |
|:-----:|:-------|:----:|
| TD-2101-001 | 搜索所有引用 `.devflow/config.json` 的文件，输出引用清单 | ✅ |
| TD-2101-001 | 删除 `.devflow/config.json` | ✅ |
| TD-2101-001 | 更新 15 个文件的路径引用 | ✅ |
| TD-2101-002 | 验证远程备份规范 §5.0 章节完整性（已在 v2.10.0 中实施） | ✅ |
| TD-2101-003 | 发布交付物门禁新增第3项（用户指南+用户手册） | ✅ |
| TD-2101-003 | Release Checklist 新增 2 项验证命令 | ✅ |
| TD-2101-005 | Release Checklist 新增候选需求池同步检查 | ✅ |
| TD-2101-006 | 发布交付物门禁中 Release Note/Changelog 命名变量化 | ✅ |
| TD-2101-004 | 债务总表修订历史表格追加 | ✅ |
| TD-2101-007 | TD-028 状态更新为已偿还 | ✅ |
| TD-2101-008 | config.json → project-config.json 改名（与 TD-2101-001 同步执行） | ✅ |
