#!/bin/bash
# DevFlow Setup Script (Bash)
# Usage: ./setup.sh [--project-name <name>] [--branch-strategy <strategy>]

set -e

# Read version from version.json (same directory as this script)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION_JSON="${SCRIPT_DIR}/version.json"
if [ -f "$VERSION_JSON" ]; then
    DEVFLOW_VERSION=$(python3 -c "import json; print(json.load(open('$VERSION_JSON'))['version'])" 2>/dev/null || echo "unknown")
else
    DEVFLOW_VERSION="unknown"
    echo "[WARN] version.json not found, version will be 'unknown'"
fi
PROJECT_NAME=""
BRANCH_STRATEGY="git-flow"
INSTALL_HOOK=false
SKIP_CONFIG=false

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --project-name) PROJECT_NAME="$2"; shift 2 ;;
        --branch-strategy) BRANCH_STRATEGY="$2"; shift 2 ;;
        --install-hook) INSTALL_HOOK=true; shift ;;
        --skip-config) SKIP_CONFIG=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

header() { echo -e "${CYAN}\n=== $1 ===${NC}"; }
ok() { echo -e "${GREEN}[OK] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARN] $1${NC}"; }

# 1. Detect project name
header "Detecting Project Name"
if [ -z "$PROJECT_NAME" ]; then
    if [ -f "package.json" ]; then
        PROJECT_NAME=$(python3 -c "import json; print(json.load(open('package.json'))['name'])" 2>/dev/null || echo "")
    elif [ -d ".git" ]; then
        REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
        if [ -n "$REMOTE" ]; then
            PROJECT_NAME=$(basename "$REMOTE" .git)
        fi
    fi
    if [ -z "$PROJECT_NAME" ]; then
        PROJECT_NAME=$(basename "$PWD")
    fi
fi
ok "Project name: $PROJECT_NAME"

# 2. Create .devflow
header "Creating .devflow Configuration"
mkdir -p .devflow

# 3. Generate config.json
if [ "$SKIP_CONFIG" != "true" ]; then
    echo ""
    echo "NOTE: If your remote repository requires authentication (e.g., GitLab with HTTP Basic Auth),"
    echo "      you can include credentials in the URL: http://username:password@host/path/repo.git"
    echo "      Or leave it empty and configure Git Credential Manager when you first push/pull."
    echo ""

    read -p "Enter your Git origin remote URL (press Enter to skip): " ORIGIN_URL
    read -p "Enter your Git backup remote URL (press Enter to skip): " BACKUP_URL

    cat > .devflow/config.json <<EOF
{
  "project": "$PROJECT_NAME",
  "devflowVersion": "$DEVFLOW_VERSION",
  "branchStrategy": "$BRANCH_STRATEGY",
  "remote": {
    "origin": "$ORIGIN_URL",
    "backup": "$BACKUP_URL"
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
EOF
    ok "Created: .devflow/config.json"
fi

# 4. Generate state.json
cat > .devflow/state.json <<EOF
{
  "project": "$PROJECT_NAME",
  "version": "",
  "currentPhase": "step_0_planning",
  "completedPhases": [],
  "currentDocuments": {},
  "auditResults": {}
}
EOF
ok "Created: .devflow/state.json"

# 5. Install Git Hook
if [ "$INSTALL_HOOK" = "true" ] && [ -d ".git" ]; then
    header "Installing Git Post-Push Hook"
    cat > .git/hooks/post-push <<'HOOKEOF'
#!/bin/bash
if git remote | grep -q backup; then
    echo "[DevFlow] Pushing mirror to backup remote..."
    git push --mirror backup
    git push --tags backup
fi
HOOKEOF
    ok "Installed: .git/hooks/post-push"
fi

# 6. Summary
header "DevFlow Setup Complete"
echo "Project:         $PROJECT_NAME"
echo "Branch Strategy: $BRANCH_STRATEGY"
echo "DevFlow Version: $DEVFLOW_VERSION"
echo "Config:          .devflow/config.json"
echo "State:           .devflow/state.json"
echo ""
echo "Next steps:"
echo "  1. Run './update.sh' to update skills when new versions are available"
echo "  2. Edit .devflow/config.json to set your backup remote URL"
echo "  3. Start with: Invoke devflow-init skill to detect your current phase"
