# 远程仓库备份规范 — 方案建议书

## 背景

v1.5.0 发布期间配置了三个远程仓库，但 GitHub SSH 地址 `git@github.com:jerryyu9981/openrag.git` 目前仅存在于本地 git remote 配置中，未纳入正式文档规范。后续版本发布时操作者不知道要加这个远程、不知道推送到哪里。

## 建议固定格式

```
git@github.com:jerryyu9981/{project}.git
```

其中 `{project}` 为项目名，例如当前项目为 `openrag`，完整地址即：

```
git@github.com:jerryyu9981/openrag.git
```

## 建议插入位置

### 位置 A：部署架构草案（推荐，主定义）

- **文件**：`doc/design/OpenRAG-部署架构草案-v1.5.0.md`
- **位置**：§2.4 CD 阶段之后、§3 部署方式之前
- **内容**：新增 §4 远程仓库与备份规范，含三远程定义表、发布推送命令模板、Tag 同步验证命令

建议表格如下：

| 远程名称 | URL 模板 | 用途 |
|:--------:|----------|------|
| `origin` | `http://192.168.0.14/jerry.yu/{project}.git` | 内网主仓库（开发协作） |
| `backup` | `http://192.168.0.14/jerry.yu/{project}-backup.git` | 内网备份 |
| `github` | `git@github.com:jerryyu9981/{project}.git` | 外网 GitHub 镜像（发布归档） |

建议发布推送命令：

```bash
# 推送代码分支
git push origin master
git push backup master
git push github master

# 推送版本标签
git push origin v{version}
git push backup v{version}
git push github v{version}
```

建议 Tag 同步验证命令：

```bash
git ls-remote origin refs/tags/v{version}
git ls-remote backup refs/tags/v{version}
git ls-remote github refs/tags/v{version}
# 三个远程必须返回相同 commit hash
```

### 位置 B：回滚方案（引用）

- **文件**：`doc/operations/OpenRAG-回滚方案-v1.5.0.md`
- **位置**：回滚步骤 Step 4 之后
- **内容**：新增 Step 5，推送回滚后版本至三个远程

建议文本：

```
# Step 5: 推送至全部远程仓库
git push origin master
git push backup master
git push github master
git push origin v{目标版本}
git push backup v{目标版本}
git push github v{目标版本}
```

### 位置 C：发布计划（引用，可选）

- **文件**：`doc/operations/OpenRAG-发布计划-v1.5.0.md`
- **位置**：基本信息表下方或"发布方式"字段中
- **内容**：一句话说明"发布后须按部署架构草案 §4 推送至三远程并验证 tag 一致性"

## 涉及文件清单

| 文件 | 操作 | 优先级 |
|------|:----:|:------:|
| `doc/design/OpenRAG-部署架构草案-v1.5.0.md` | 新增 §4 远程仓库与备份规范 | 必选（主定义） |
| `doc/operations/OpenRAG-回滚方案-v1.5.0.md` | 回滚步骤新增 Step 5 | 推荐 |
| `doc/operations/OpenRAG-发布计划-v1.5.0.md` | 可选引用 | 可选 |

## 说明

- `{project}` 作为参数占位符，后续创建新项目（如 `openrag-frontend`）时只需替换项目名即可复用
- 所有 tag 创建后必须推送至全部三个远程，任一远程遗漏视为发布不完整
- Tag 同步验证的结果应记录在 Release Checklist 中
