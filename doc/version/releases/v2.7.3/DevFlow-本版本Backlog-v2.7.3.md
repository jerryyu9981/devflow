# DevFlow-本版本Backlog-v2.7.3

> 文档类型：本版本 Backlog
> 文档状态：[Draft]
> 版本：v1.0
> 日期：2026-07-11
> 所属版本：v2.7.3

---

| ID | 需求 | 优先级 | 技术可行性 | 修改文件 |
|:--:|:-----|:------:|:----------:|:---------|
| V260-030 | Install DevFlow 职责清理——setup.ps1/sh 移除项目初始化逻辑 | P0 | ✅ 代码剥离 | `setup.ps1`、`setup.sh` |
| V260-031 | Update DevFlow 修正——移除修改 projectVersion 的逻辑 | P0 | ✅ 移除越界逻辑 | `update.ps1`、`update.sh` |
| V260-032 | devflow-init 增强：DevFlow 版本号读取与写入 | P0 | ✅ SKILL.md 规则实现 | `devflow-init/SKILL.md` |
| V260-033 | devflow-init 增强：projectVersion 自动扫描+交互补充 | P0 | ✅ 自动检测链+交互 | `devflow-init/SKILL.md` |
| V260-034 | devflow-init 增强：currentPhase 推断并写入 state.json | P1 | ✅ 状态写入增强 | `devflow-init/SKILL.md` |