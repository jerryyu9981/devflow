#!/bin/bash
# DevFlow Setup Script (Cross-Platform)
# Usage: bash setup.sh [-n NAME] [-b STRATEGY]

set -euo pipefail

# 参数
PROJECT_NAME=""
BRANCH_STRATEGY="git-flow"
SKIP_CONFIG=false

while getopts "n:b:s" opt; do
    case $opt in
        n) PROJECT_NAME="$OPTARG" ;;
        b) BRANCH_STRATEGY="$OPTARG" ;;
        s) SKIP_CONFIG=true ;;
        *) echo "Usage: setup.sh [-n NAME] [-b STRATEGY] [-s]"; exit 1 ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 工具函数
write_header() { echo ""; echo "=== $1 ==="; }
write_success() { echo "[OK] $1"; }
write_warn() { echo "[WARN] $1"; }

# 读取版本号
VERSION="unknown"
if [ -f "$SCRIPT_DIR/version.json" ]; then
    VERSION=$(python3 -c "import json; print(json.load(open('$SCRIPT_DIR/version.json'))['version'])" 2>/dev/null || \
             grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/version.json" | tail -1 | grep -o '"[^"]*"$' | tr -d '"')
fi

# 1. 检测项目名
write_header "Detecting Project Name"
if [ -z "$PROJECT_NAME" ]; then
    if [ -f "package.json" ]; then
        PROJECT_NAME=$(python3 -c "import json; print(json.load(open('package.json'))['name'])" 2>/dev/null || echo "")
    elif [ -d ".git" ]; then
        remote=$(git remote get-url origin 2>/dev/null || true)
        if [ -n "$remote" ]; then
            PROJECT_NAME=$(echo "$remote" | rev | cut -d'/' -f1 | rev | sed 's/\.git$//')
        fi
    fi
    [ -z "$PROJECT_NAME" ] && PROJECT_NAME=$(basename "$(pwd)")
fi
write_success "Project name: $PROJECT_NAME"

# 2. 创建 .devflow 目录
write_header "Creating .devflow Configuration"
DEVFLOW_DIR=".devflow"
mkdir -p "$DEVFLOW_DIR"

# 3. 生成 config.json
if [ "$SKIP_CONFIG" = false ]; then
    read -p "Enter Git origin remote URL (Enter to skip): " ORIGIN_URL
    read -p "Enter Git backup remote URL (Enter to skip): " BACKUP_URL

    cat > "$DEVFLOW_DIR/config.json" << JSONEOF
{
  "project": "$PROJECT_NAME",
  "devflowVersion": "$VERSION",
  "branchStrategy": "$BRANCH_STRATEGY",
  "remote": {
    "origin": "${ORIGIN_URL:-}",
    "backup": "${BACKUP_URL:-}"
  },
  "backup": {
    "type": "git-mirror",
    "schedule": {
      "bundle": "weekly",
      "bundleRetention": 4,
      "dbDump": "daily",
      "dbRetention": 90
    }
  }
}
JSONEOF
    write_success "Created: $DEVFLOW_DIR/config.json"
fi

# 4. 生成 state.json
cat > "$DEVFLOW_DIR/state.json" << JSONEOF
{
  "project": "$PROJECT_NAME",
  "version": "",
  "currentPhase": "step_0_planning",
  "completedPhases": [],
  "currentDocuments": {},
  "auditResults": {}
}
JSONEOF
write_success "Created: $DEVFLOW_DIR/state.json"

# 5. 摘要
write_header "DevFlow Setup Complete"
echo "Project:        $PROJECT_NAME"
echo "Branch Strategy: $BRANCH_STRATEGY"
echo "DevFlow Version: $VERSION"
echo "Config:         $DEVFLOW_DIR/config.json"
echo "State:          $DEVFLOW_DIR/state.json"
echo ""
echo "Next steps:"
echo "  1. Run 'bash update.sh' to update skills"
echo "  2. Edit .devflow/config.json to set backup remote URL"
echo "  3. Start with: Invoke devflow-init skill"
