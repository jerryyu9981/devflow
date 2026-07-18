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
CURRENT_VERSION=$(python3 -c "import json; s=json.load(open('.devflow/state.json')); print(s.get('devflowVersion','unknown'))" 2>/dev/null || echo "unknown")
echo "Current DevFlow version: $CURRENT_VERSION"

# 2. Determine latest version
if [ -z "$VERSION" ]; then
    # Try local version.json first
    LOCAL_VERSION_JSON="${SCRIPT_DIR}/version.json"
    if [ -f "$LOCAL_VERSION_JSON" ]; then
        VERSION=$(python3 -c "import json; print(json.load(open('$LOCAL_VERSION_JSON'))['devflowVersion'])" 2>/dev/null || true)
    fi
    # If repo configured and local failed, try remote
    if [ -n "$REPO_URL" ] && [ -z "$VERSION" ]; then
        VERSION=$(curl -sf "${REPO_URL}/raw/main/version.json" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['devflowVersion'])" 2>/dev/null || true)
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

# DT-04: IDE system directory configurable via environment variable
TRA_SKILLS_DIR="${DEVFLOW_SKILLS_DIR:-$HOME/.trae-cn/skills}"

# Ensure target directory exists
if [ ! -d "$TRA_SKILLS_DIR" ]; then
    mkdir -p "$TRA_SKILLS_DIR"
fi

# DT-01: Load skill map from devflow-manifest.json (Bash, no jq)
local manifest_file="${SCRIPT_DIR}/devflow-manifest.json"
ExpectedSkillCount=$(grep -o '"skillCount": *[0-9]*' "$manifest_file" | grep -o '[0-9]*')
declare -A SKILL_MAP
while IFS='|' read -r name source; do
    [ -n "$name" ] && SKILL_MAP["$name"]="$source"
done < <(python3 -c "
import json, sys
m = json.load(open('$manifest_file'))
for s in m['skills']:
    print(s['name'] + '|' + s['source'])
" 2>/dev/null)

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

# DT-03: Remove UTF-8 BOM from all installed/updated .md files
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
if [ "$FAIL_COUNT" -gt 0 ]; then
    warn "Update summary: $UPDATE_COUNT updated, $FAIL_COUNT failed"
else
    ok "Update summary: $UPDATE_COUNT updated, $FAIL_COUNT failed"
fi

# DT-06: Verify installed skill count
if [ "$UPDATE_COUNT" -eq "$ExpectedSkillCount" ]; then
    ok "Installed: $UPDATE_COUNT/$ExpectedSkillCount skills"
else
    warn "Skill count mismatch: installed=$UPDATE_COUNT, expected=$ExpectedSkillCount"
fi

ok "DevFlow update to v$VERSION complete"
