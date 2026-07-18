#!/bin/bash
# DevFlow Setup Script (Bash)
# Usage: ./setup.sh [--install-hook]

set -e

# Read version from version.json (same directory as this script)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION_JSON="${SCRIPT_DIR}/version.json"
if [ -f "$VERSION_JSON" ]; then
    DEVFLOW_VERSION=$(python3 -c "import json; print(json.load(open('$VERSION_JSON'))['devflowVersion'])" 2>/dev/null || echo "unknown")
else
    DEVFLOW_VERSION="unknown"
    echo "[WARN] version.json not found, version will be 'unknown'"
fi
INSTALL_HOOK=false

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --install-hook) INSTALL_HOOK=true; shift ;;
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

# ─── BOM Removal Helper (DT-03) ──────────────────────────────────
remove_utf8_bom() {
    local file="$1"
    if [ ! -f "$file" ]; then return 1; fi
    local first3=$(head -c 3 "$file" 2>/dev/null | xxd -p 2>/dev/null)
    if [ "$first3" = "efbbbf" ]; then
        local tmpfile="${file}.tmp"
        tail -c +4 "$file" > "$tmpfile" 2>/dev/null && mv "$tmpfile" "$file"
        echo -e "${YELLOW}[BOM Fixed] $(basename "$file")${NC}"
        return 0
    fi
    return 1
}

# 1. Detect Host
header "Detecting Host Environment"
HOST_TYPE="unknown"
if [ -n "$TRAE_IDE" ] || [ -d "$HOME/.trae-cn" ]; then
    HOST_TYPE="TRAE"
elif [ -d ".git" ]; then
    HOST_TYPE="generic"
fi
ok "Host detected: $HOST_TYPE"

# 2. Install skills to TRAE (if TRAE detected)
if [ "$HOST_TYPE" = "TRAE" ]; then
    # DT-04: IDE system directory configurable via environment variable
    TRA_SKILLS_DIR="${DEVFLOW_SKILLS_DIR:-$HOME/.trae-cn/skills}"

    # Ensure target directory exists
    if [ ! -d "$TRA_SKILLS_DIR" ]; then
        mkdir -p "$TRA_SKILLS_DIR"
        echo -e "${CYAN}[INFO] Created skills directory: $TRA_SKILLS_DIR${NC}"
    fi

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

    # v2.7.5: Plugin configuration (version.json) and sync tool
    SKILL_MAP["devflow-plugin-config"]="version.json"
    SKILL_MAP["devflow-plugin-sync"]="sync-skills.ps1"

    # v2.8.0: Plugin download tool (git clone/pull for cloud repository)
    SKILL_MAP["devflow-plugin-download"]="download-devflow.ps1"

    # Phase 1: Uninstall existing DevFlow skills (clean slate)
    header "Uninstalling existing DevFlow Skills"
    for skill in $(echo "${!SKILL_MAP[@]}" | tr ' ' '\n' | sort); do
        dst_dir="${TRA_SKILLS_DIR}/${skill}"
        if [ -d "$dst_dir" ]; then
            rm -rf "$dst_dir"
            ok "Removed: $skill"
        fi
    done

    # Phase 1.5: Interactive confirmation before installation
    header "Installation Confirmation"
    echo "DevFlow Version: $DEVFLOW_VERSION"
    echo "Skills to install: ${#SKILL_MAP[@]}"
    echo "Target directory: $TRA_SKILLS_DIR"
    echo ""
    read -p "Proceed with installing DevFlow skills to TRAE? (Y/n) " confirm
    if [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
        echo "Installation cancelled by user."
        exit 0
    fi

    # Phase 2: Install DevFlow skills from plugin source
    header "Installing DevFlow Skills to TRAE"
    inst_count=0
    fail_count=0
    for skill in $(echo "${!SKILL_MAP[@]}" | tr ' ' '\n' | sort); do
        src="${SCRIPT_DIR}/${SKILL_MAP[$skill]}"
        dst_dir="${TRA_SKILLS_DIR}/${skill}"
        if [ -f "$src" ]; then
            mkdir -p "$dst_dir"
            # Preserve original filename for non-.md files
            src_basename=$(basename "$src")
            src_ext="${src_basename##*.}"
            if [ "$src_ext" = "md" ]; then
                dst="${dst_dir}/SKILL.md"
            else
                dst="${dst_dir}/${src_basename}"
            fi
            cp "$src" "$dst"
            ok "Installed: $skill"
            inst_count=$((inst_count + 1))
        else
            warn "Skill source not found: $skill ($src)"
            fail_count=$((fail_count + 1))
        fi
    done
    # DT-03: Remove UTF-8 BOM from all installed .md files
    bom_fixed=0
    find "$TRA_SKILLS_DIR" -name "*.md" -type f 2>/dev/null | while read -r mdfile; do
        if remove_utf8_bom "$mdfile"; then
            bom_fixed=$((bom_fixed + 1))
        fi
    done
    if [ "$bom_fixed" -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}BOM fix: $bom_fixed file(s) cleaned${NC}"
    fi

    echo ""
    if [ $fail_count -gt 0 ]; then
        echo -e "${YELLOW}Skills install result: $inst_count installed, $fail_count failed${NC}"
    else
        echo -e "${GREEN}Skills install result: $inst_count installed, $fail_count failed${NC}"
    fi
fi

# 3. Install Git Hook (optional)
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

# 4. Summary
header "DevFlow Setup Complete"
echo "DevFlow Version: $DEVFLOW_VERSION"
echo ""
echo "Next steps:"
echo "  1. Open your project in TRAE and invoke devflow-init to initialize project configuration"
echo "  2. Run './update.sh' to update skills when new versions are available"

exit 0