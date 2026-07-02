#!/bin/bash
# DevFlow Plugin Installer (Cross-Platform)
# Usage: bash install.sh or ./install.sh
# Supports: macOS (zsh/bash), Linux (bash)

set -euo pipefail

# === 配置 ===
PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"

# === 工具函数 ===
write_header() {
    echo ""
    echo "=== $1 ==="
}

write_success() {
    echo "[OK] $1"
}

write_warn() {
    echo "[WARN] $1"
}

write_error() {
    echo "[ERROR] $1" >&2
}

# === 读取版本号 ===
VERSION="unknown"
VERSION_JSON="$PLUGIN_DIR/version.json"
if [ -f "$VERSION_JSON" ]; then
    VERSION=$(python3 -c "import json; print(json.load(open('$VERSION_JSON'))['version'])" 2>/dev/null || \
             grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$VERSION_JSON" | tail -1 | grep -o '"[^"]*"$' | tr -d '"')
fi

# === 欢迎信息 ===
echo ""
echo "========================================"
echo "  DevFlow Plugin Installer v$VERSION"
echo "========================================"
echo ""
echo "This wizard will install DevFlow into your project directory."
echo ""

# === 询问项目路径 ===
DEFAULT_PATH="$(pwd)"
read -p "Enter project directory path (Enter for default: $DEFAULT_PATH): " PROJECT_PATH
PROJECT_PATH="${PROJECT_PATH:-$DEFAULT_PATH}"

# 验证/创建路径
if [ ! -d "$PROJECT_PATH" ]; then
    read -p "Directory does not exist. Create it? (Y/n): " CREATE
    CREATE="${CREATE:-Y}"
    if [[ "$CREATE" =~ ^[Yy]$ ]]; then
        mkdir -p "$PROJECT_PATH"
        write_success "Created directory: $PROJECT_PATH"
    else
        write_error "Installation cancelled."
        exit 1
    fi
fi

PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
DEVFLOW_DIR="$PROJECT_PATH/.devflow"

# 检查 .devflow 是否已存在
if [ -d "$DEVFLOW_DIR" ]; then
    write_warn ".devflow already exists at: $DEVFLOW_DIR"
    read -p "Overwrite? (y/N): " OVERWRITE
    if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
        rm -rf "$DEVFLOW_DIR"
        write_success "Removed existing .devflow"
    else
        write_error "Installation cancelled."
        exit 1
    fi
fi

# === Step 1: 复制插件文件 ===
write_header "Step 1: Copying DevFlow plugin files"

# 排除 install.bat/install.ps1/install.sh
for item in "$PLUGIN_DIR"/*; do
    name="$(basename "$item")"
    # 跳过安装脚本本身
    [[ "$name" == "install.bat" || "$name" == "install.ps1" || "$name" == "install.sh" ]] && continue
    cp -r "$item" "$DEVFLOW_DIR/"
    write_success "Copied: $name"
done

write_success "DevFlow plugin files installed to: $DEVFLOW_DIR"

# === Step 2: 安装技能 ===
write_header "Step 2: Installing DevFlow skills"

# 检测 TRAE skills 目录
if [ -d "$HOME/.trae-cn/skills" ]; then
    TRAE_SKILLS_DIR="$HOME/.trae-cn/skills"
elif [ -d "$HOME/.trae/skills" ]; then
    TRAE_SKILLS_DIR="$HOME/.trae/skills"
else
    # 默认创建
    TRAE_SKILLS_DIR="$HOME/.trae-cn/skills"
    mkdir -p "$TRAE_SKILLS_DIR"
fi

# 技能映射表（skill-name: relative-path-from-devflow）
declare -A SKILL_MAP=(
    ["devflow-init"]="devflow-init/SKILL.md"
    ["devflow-phase-manager"]="devflow-phase-manager/SKILL.md"
    ["devflow-project-config"]="devflow-project-config/SKILL.md"
    ["project-development-workflow"]="skills/L1/project-development-workflow.md"
    ["project-document-management"]="skills/L1/project-document-management.md"
    ["project-role-management"]="skills/L1/project-role-management.md"
    ["version-planning-stage-execution"]="skills/L2/version-planning-stage-execution.md"
    ["requirements-stage-execution"]="skills/L2/requirements-stage-execution.md"
    ["design-stage-execution"]="skills/L2/design-stage-execution.md"
    ["coding-stage-execution"]="skills/L2/coding-stage-execution.md"
    ["testing-stage-execution"]="skills/L2/testing-stage-execution.md"
    ["operations-stage-execution"]="skills/L2/operations-stage-execution.md"
    ["project-coding-conventions"]="skills/L3/project-coding-conventions.md"
    ["code-static-quality-check"]="skills/L3/code-static-quality-check.md"
    ["code-logic-review"]="skills/L3/code-logic-review.md"
    ["cicd-pipeline-management"]="skills/L3/cicd-pipeline-management.md"
    ["observability-standards"]="skills/L3/observability-standards.md"
    ["project-document-templates"]="skills/L3/project-document-templates.md"
    ["code-version-backup-management"]="skills/L3/code-version-backup-management.md"
    ["prototype-coverage"]="skills/L3/prototype-coverage.md"
    ["backend-coverage"]="skills/L3/backend-coverage.md"
    ["api-contract-management"]="skills/L3/api-contract-management.md"
    ["skill-md-writing-standards"]="skills/L3/skill-md-writing-standards.md"
    ["security-design-review"]="skills/L3/security-design-review.md"
    ["secure-coding-practices"]="skills/L3/secure-coding-practices.md"
    ["container-deployment"]="skills/L3/container-deployment.md"
)

SKILL_COUNT=0
SKILL_FAIL=0

for skill in $(echo "${!SKILL_MAP[@]}" | tr ' ' '\n' | sort); do
    src="$DEVFLOW_DIR/${SKILL_MAP[$skill]}"
    dst="$TRAE_SKILLS_DIR/$skill/SKILL.md"

    if [ -f "$src" ]; then
        # 备份已存在的技能
        if [ -f "$dst" ]; then
            timestamp=$(date +%Y%m%d%H%M%S)
            cp "$dst" "$dst.bak-$timestamp"
        fi
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        write_success "Installed skill: $skill"
        ((SKILL_COUNT++)) || true
    else
        write_warn "Skill source not found: $skill"
        ((SKILL_FAIL++)) || true
    fi
done

echo ""
if [ "$SKILL_FAIL" -gt 0 ]; then
    echo "Skills installed: $SKILL_COUNT succeeded, $SKILL_FAIL failed"
else
    echo "Skills installed: $SKILL_COUNT succeeded"
fi

# === Step 3: 运行 setup.sh ===
write_header "Step 3: Running Setup"
SETUP_SCRIPT="$DEVFLOW_DIR/setup.sh"
if [ -f "$SETUP_SCRIPT" ]; then
    echo "Launching setup.sh for configuration..."
    bash "$SETUP_SCRIPT"
else
    write_warn "setup.sh not found. Please run it manually:"
    echo "  cd '$DEVFLOW_DIR'"
    echo "  bash setup.sh"
fi

# === 安装结果 ===
write_header "Installation Complete"
echo "DevFlow v$VERSION has been installed to your project."
echo ""
echo "Project:     $PROJECT_PATH"
echo "Plugin:      $DEVFLOW_DIR"
echo "TRAE Skills: $TRAE_SKILLS_DIR"
echo ""
echo "Next steps:"
echo "  1. Open TRAE and invoke: devflow-init"
echo "  2. Or run 'bash update.sh' in $DEVFLOW_DIR to update skills later"
echo ""
read -p "Press Enter to exit"
