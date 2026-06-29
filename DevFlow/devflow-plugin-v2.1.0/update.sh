#!/bin/bash
# DevFlow Update Script (Bash)
# Usage: ./update.sh [--version <version>] [--dry-run]

set -e

VERSION=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --version) VERSION="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok() { echo -e "${GREEN}[OK] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARN] $1${NC}"; }
err() { echo -e "${RED}[ERROR] $1${NC}"; }

# Resolve repository URL: env var > config.json > fallback empty
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_URL="${DEVFLOW_REPO_URL:-}"
if [ -z "$REPO_URL" ] && [ -f ".devflow/config.json" ]; then
    REPO_URL=$(python3 -c "import json; print(json.load(open('.devflow/config.json')).get('remote',{}).get('origin',''))" 2>/dev/null || true)
fi
if [ -z "$REPO_URL" ]; then
    warn "No repository URL configured. Set DEVFLOW_REPO_URL or add remote.origin in .devflow/config.json"
    warn "Falling back to local file-based update."
fi

# 1. Check current version
CURRENT_VERSION=$(python3 -c "import json; print(json.load(open('.devflow/config.json'))['devflowVersion'])" 2>/dev/null || echo "unknown")
echo "Current DevFlow version: $CURRENT_VERSION"

# 2. Determine latest version
if [ -z "$VERSION" ]; then
    # Try local version.json first
    LOCAL_VERSION_JSON="${SCRIPT_DIR}/version.json"
    if [ -f "$LOCAL_VERSION_JSON" ]; then
        VERSION=$(python3 -c "import json; print(json.load(open('$LOCAL_VERSION_JSON'))['version'])" 2>/dev/null || true)
    fi
    # If repo configured and local failed, try remote
    if [ -n "$REPO_URL" ] && [ -z "$VERSION" ]; then
        VERSION=$(curl -sf "${REPO_URL}/raw/main/version.json" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['version'])" 2>/dev/null || true)
    fi
    if [ -z "$VERSION" ]; then
        err "Cannot determine target version. Please specify --version."
        exit 1
    fi
fi

if [ "$CURRENT_VERSION" = "$VERSION" ]; then
    ok "Already up to date (v$CURRENT_VERSION)"
    exit 0
fi

echo "Update available: v$CURRENT_VERSION -> v$VERSION"

if [ "$DRY_RUN" = "true" ]; then
    echo "Dry run mode - no changes made."
    exit 0
fi

# 3. Download and update skills
echo ""
echo "=== Updating DevFlow to v$VERSION ==="

TRA_SKILLS_DIR="${HOME}/.trae-cn/skills"

# Skill name 鈫?source path mapping (relative to plugin root)
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
echo ""
echo "=== Uninstalling existing DevFlow Skills ==="
for skill in $(echo "${!SKILL_MAP[@]}" | tr ' ' '\n' | sort); do
    dst_dir="${TRA_SKILLS_DIR}/${skill}"
    if [ -d "$dst_dir" ]; then
        rm -rf "$dst_dir"
        ok "Removed: $skill"
    fi
done

# Phase 2: Install DevFlow skills from plugin source
echo ""
echo "=== Installing DevFlow Skills ==="

UPDATE_COUNT=0
FAIL_COUNT=0

for skill in $(echo "${!SKILL_MAP[@]}" | tr ' ' '\n' | sort); do
    src="${SCRIPT_DIR}/${SKILL_MAP[$skill]}"
    dst="${TRA_SKILLS_DIR}/${skill}/SKILL.md"

    if [ -f "$src" ]; then
        # Ensure destination directory exists (already cleaned by Phase 1)
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        ok "Installed: $skill"
        UPDATE_COUNT=$((UPDATE_COUNT + 1))
    elif [ -n "$REPO_URL" ]; then
        # Try download from remote
        DOWNLOADED=false
        for remote_path in "orchestrator/${skill}/SKILL.md" "skills/L1/${skill}.md" "skills/L2/${skill}.md" "skills/L3/${skill}.md"; do
            url="${REPO_URL}/raw/main/${remote_path}"
            if curl -sf "$url" > /tmp/devflow-update-${skill}.md 2>/dev/null; then
                mkdir -p "$(dirname "$dst")"
                mv /tmp/devflow-update-${skill}.md "$dst"
                ok "Downloaded: $skill (from ${remote_path})"
                UPDATE_COUNT=$((UPDATE_COUNT + 1))
                DOWNLOADED=true
                break
            fi
        done
        if [ "$DOWNLOADED" = "false" ]; then
            warn "Failed to install: $skill (not found locally or remotely)"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        warn "Skipped: $skill (source not found: $src)"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
done

echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    warn "Update summary: $UPDATE_COUNT updated, $FAIL_COUNT failed"
else
    ok "Update summary: $UPDATE_COUNT updated, $FAIL_COUNT failed"
fi

# 4. Update config version
if [ -f ".devflow/config.json" ]; then
    python3 -c "
import json
with open('.devflow/config.json') as f:
    c = json.load(f)
c['devflowVersion'] = '$VERSION'
with open('.devflow/config.json', 'w') as f:
    json.dump(c, f, indent=2)
"
    ok "Updated config.devflowVersion to v$VERSION"
fi

ok "DevFlow update to v$VERSION complete"
