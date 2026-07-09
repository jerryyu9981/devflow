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
    echo "NOTE: DevFlow recommends using SSH Key + Deploy Key for backup authentication."
    echo "      HTTP Basic Auth with credentials in URL is discouraged for security."
    echo ""

    read -p "Enter your Git origin remote URL (press Enter to skip): " ORIGIN_URL

    BACKUP_URL=""
    if [ -n "$ORIGIN_URL" ]; then
        BACKUP_SUGGESTION=$(echo "$ORIGIN_URL" | sed 's/\.git$/-backup.git/')
        read -p "Suggested backup URL: $BACKUP_SUGGESTION. Use it? (Y/n): " USE_SUGGESTION
        if [ "$USE_SUGGESTION" != "n" ] && [ "$USE_SUGGESTION" != "N" ]; then
            BACKUP_URL="$BACKUP_SUGGESTION"
            DEV_BACKUP=$(echo "$BACKUP_SUGGESTION" | sed 's/-backup\.git$/-dev-backup.git/')
            TEST_BACKUP=$(echo "$BACKUP_SUGGESTION" | sed 's/-backup\.git$/-test-backup.git/')
            PRO_BACKUP=$(echo "$BACKUP_SUGGESTION" | sed 's/-backup\.git$/-pro-backup.git/')
            DISASTER_BACKUP=$(echo "$BACKUP_SUGGESTION" | sed 's/-backup\.git$/-disaster-backup.git/')
        else
            read -p "Enter your Git backup remote URL (press Enter to skip): " BACKUP_URL
            DEV_BACKUP=""
            TEST_BACKUP=""
            PRO_BACKUP=""
            DISASTER_BACKUP=""
        fi
    else
        read -p "Enter your Git backup remote URL (press Enter to skip): " BACKUP_URL
        DEV_BACKUP=""
        TEST_BACKUP=""
        PRO_BACKUP=""
        DISASTER_BACKUP=""
    fi

    cat > .devflow/config.json <<EOF
{
  "project": "$PROJECT_NAME",
  "projectVersion": "$PROJECT_VERSION",
  "branchStrategy": "$BRANCH_STRATEGY",
  "remote": {
    "origin": "$ORIGIN_URL",
    "backup": "$BACKUP_URL"
  },
  "backup": {
    "type": "git-mirror",
    "environments": {
      "dev": { "backup": "$DEV_BACKUP" },
      "test": { "backup": "$TEST_BACKUP" },
      "pro": { "backup": "$PRO_BACKUP", "disaster": "$DISASTER_BACKUP" }
    },
    "schedule": {
      "type": "post-push",
      "weeklyArchive": "sunday-02:00",
      "retentionDays": 90
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

    # Create log directory
    mkdir -p .devflow/logs

    # Create backup history CSV header
    if [ ! -f ".devflow/logs/backup-history.csv" ]; then
        echo "时间,备份类型,状态,Commit SHA" > .devflow/logs/backup-history.csv
    fi

    cat > .git/hooks/post-push <<'HOOKEOF'
#!/bin/bash
# DevFlow 自动备份 Hook
REMOTE_NAME="${1:-backup}"
LOG_DIR=".devflow/logs"
mkdir -p "$LOG_DIR"

if git remote | grep -q "$REMOTE_NAME"; then
    echo "[DevFlow Backup] $(date '+%Y-%m-%d %H:%M:%S') 开始备份到 $REMOTE_NAME ..."
    git push --mirror "$REMOTE_NAME" 2>&1
    git push --tags "$REMOTE_NAME" 2>&1

    if [ $? -eq 0 ]; then
        echo "[DevFlow Backup] 备份完成"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),git-mirror,成功,$(git rev-parse HEAD)" >> "$LOG_DIR/backup-history.csv"
    else
        echo "[DevFlow Backup] 备份失败"
        echo "$(date '+%Y-%m-%d %H:%M:%S'),git-mirror,失败,$(git rev-parse HEAD)" >> "$LOG_DIR/backup-error.csv"
    fi
else
    echo "[DevFlow Backup] 未找到远程仓库 '$REMOTE_NAME'，跳过备份"
fi
HOOKEOF
    chmod +x .git/hooks/post-push
    ok "Installed: .git/hooks/post-push"
    ok "Created: .devflow/logs"
fi

# 6. Install skills to TRAE (if TRAE detected)
TRA_SKILLS_DIR="${HOME}/.trae-cn/skills"
if [ -d "$HOME/.trae-cn" ]; then
    # Skill definitions: Name -> SourcePath (relative to plugin root)
    declare -A SKILL_MAP
    SKILL_MAP["devflow-init"]="devflow-init/SKILL.md"
    SKILL_MAP["devflow-phase-manager"]="devflow-phase-manager/SKILL.md"
    SKILL_MAP["devflow-project-config"]="devflow-project-config/SKILL.md"
    SKILL_MAP["project-development-workflow"]="skills/L1/project-development-workflow.md"
    SKILL_MAP["project-document-management"]="skills/L1/project-document-management.md"
    SKILL_MAP["project-role-management"]="skills/L1/project-role-management.md"
    SKILL_MAP["version-planning-stage-execution"]="skills/L2/version-planning-stage-execution.md"
    SKILL_MAP["requirements-stage-execution"]="skills/L2/requirements-stage-execution.md"
    SKILL_MAP["design-stage-execution"]="skills/L2/design-stage-execution.md"
    SKILL_MAP["coding-stage-execution"]="skills/L2/coding-stage-execution.md"
    SKILL_MAP["testing-stage-execution"]="skills/L2/testing-stage-execution.md"
    SKILL_MAP["operations-stage-execution"]="skills/L2/operations-stage-execution.md"
    SKILL_MAP["project-coding-conventions"]="skills/L3/project-coding-conventions.md"
    SKILL_MAP["code-static-quality-check"]="skills/L3/code-static-quality-check.md"
    SKILL_MAP["code-logic-review"]="skills/L3/code-logic-review.md"
    SKILL_MAP["cicd-pipeline-management"]="skills/L3/cicd-pipeline-management.md"
    SKILL_MAP["observability-standards"]="skills/L3/observability-standards.md"
    SKILL_MAP["api-contract-management"]="skills/L3/api-contract-management.md"
    SKILL_MAP["prototype-coverage"]="skills/L3/prototype-coverage.md"
    SKILL_MAP["backend-coverage"]="skills/L3/backend-coverage.md"
    SKILL_MAP["project-document-templates"]="skills/L3/project-document-templates.md"
    SKILL_MAP["code-version-backup-management"]="skills/L3/code-version-backup-management.md"

    # Phase 1: Uninstall existing DevFlow skills (clean slate)
    header "Uninstalling existing DevFlow Skills"
    for skill in $(echo "${!SKILL_MAP[@]}" | tr ' ' '\n' | sort); do
        dst_dir="${TRA_SKILLS_DIR}/${skill}"
        if [ -d "$dst_dir" ]; then
            rm -rf "$dst_dir"
            ok "Removed: $skill"
        fi
    done

    # Phase 2: Install DevFlow skills from plugin source
    header "Installing DevFlow Skills to TRAE"
    inst_count=0
    fail_count=0
    for skill in $(echo "${!SKILL_MAP[@]}" | tr ' ' '\n' | sort); do
        src="${SCRIPT_DIR}/${SKILL_MAP[$skill]}"
        dst="${TRA_SKILLS_DIR}/${skill}/SKILL.md"
        if [ -f "$src" ]; then
            mkdir -p "$(dirname "$dst")"
            cp "$src" "$dst"
            ok "Installed: $skill"
            inst_count=$((inst_count + 1))
        else
            warn "Skill source not found: $skill ($src)"
            fail_count=$((fail_count + 1))
        fi
    done
    echo ""
    echo "Skills install result: $inst_count installed, $fail_count failed"
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
