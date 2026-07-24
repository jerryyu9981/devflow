#!/bin/bash
# DevFlow 安装验证脚本 v1.0
# VR-005 安装验证测试 P1
# 用法: ./validate-install.sh [-p <插件目录>] [-s <技能目录>]
# 说明: 安装完成后自动运行验证测试，检查技能文件完整性、引用关系、模板文件、编排器加载和配置文件语法

set -euo pipefail

# ============================================================
# 参数解析
# ============================================================
PLUGIN_DIR=""
SKILLS_DIR=""

while getopts "p:s:" opt; do
    case $opt in
        p) PLUGIN_DIR="$OPTARG" ;;
        s) SKILLS_DIR="$OPTARG" ;;
        *) echo "用法: $0 [-p <插件目录>] [-s <技能目录>]"; exit 1 ;;
    esac
done

# 自动检测路径
if [ -z "$PLUGIN_DIR" ]; then
    # 脚本位于 scripts/ 下，上级即为插件根目录
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
fi
if [ -z "$SKILLS_DIR" ]; then
    SKILLS_DIR="$HOME/.trae-cn/skills"
fi

# ============================================================
# 颜色定义
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
DARK_GRAY='\033[1;30m'
NC='\033[0m' # No Color

# ============================================================
# 工具函数
# ============================================================
write_header() {
    echo ""
    echo -e "${CYAN}=== $1 ===${NC}"
}

write_pass() {
    echo -e "  ${GREEN}[PASS]${NC} $1"
}

write_fail() {
    echo -e "  ${RED}[FAIL]${NC} $1"
}

write_warn() {
    echo -e "  ${YELLOW}[WARN]${NC} $1"
}

write_skip() {
    echo -e "  ${DARK_GRAY}[SKIP]${NC} $1"
}

# 检查 JSON 文件是否有效
is_json_valid() {
    local file="$1"
    if command -v python3 &>/dev/null; then
        python3 -c "import json; json.load(open('$file', encoding='utf-8'))" 2>/dev/null
        return $?
    elif command -v python &>/dev/null; then
        python -c "import json; json.load(open('$file', encoding='utf-8'))" 2>/dev/null
        return $?
    elif command -v jq &>/dev/null; then
        jq . "$file" &>/dev/null
        return $?
    else
        # 最后手段：使用 grep 做基本检查
        grep -q '^{' "$file" 2>/dev/null && grep -q '}$' "$file" 2>/dev/null
        return $?
    fi
}

# ============================================================
# 计数器初始化
# ============================================================
pass_count=0
fail_count=0
warn_count=0
skip_count=0

# ============================================================
# 主流程
# ============================================================
echo -e "${CYAN}DevFlow 安装验证脚本 v1.0${NC}"
echo "========================================"
echo "插件目录:  $PLUGIN_DIR"
echo "技能目录:  $SKILLS_DIR"
echo ""

# ============================================================
# [1/5] 技能文件完整性检查
# ============================================================
write_header "1/5 技能文件完整性"

version_json="$PLUGIN_DIR/version.json"
all_skills=()

if [ -f "$version_json" ]; then
    if is_json_valid "$version_json"; then
        write_pass "version.json 格式有效"
        ((pass_count++))
    else
        write_fail "version.json 格式无效"
        ((fail_count++))
        echo ""
        echo "========================================"
        echo "验证汇总: 通过=$pass_count 失败=$fail_count 警告=$warn_count 跳过=$skip_count"
        echo -e "${RED}结果: 验证失败（version.json 无法解析）${NC}"
        exit 1
    fi

    # 使用 python/jq 解析 JSON 获取技能列表
    if command -v python3 &>/dev/null; then
        # 解析 L1、L2、L3、orchestrator 层级的技能名
        mapfile -t all_skills < <(python3 -c "
import json, sys
with open('$version_json', encoding='utf-8') as f:
    ver = json.load(f)
for layer in ['L1','L2','L3','orchestrator']:
    if layer in ver.get('layers', {}):
        for s in ver['layers'][layer]:
            print(s)
")
    elif command -v python &>/dev/null; then
        mapfile -t all_skills < <(python -c "
import json, sys
with open('$version_json', encoding='utf-8') as f:
    ver = json.load(f)
for layer in ['L1','L2','L3','orchestrator']:
    if layer in ver.get('layers', {}):
        for s in ver['layers'][layer]:
            print(s)
")
    elif command -v jq &>/dev/null; then
        mapfile -t all_skills < <(jq -r '
            [.layers.L1[], .layers.L2[], .layers.L3[], .layers.orchestrator[]] | .[]
        ' "$version_json")
    else
        write_fail "缺少 python/python3/jq，无法解析 version.json"
        ((fail_count++))
        all_skills=()
    fi

    # 检查每个技能文件是否存在
    for skill in "${all_skills[@]}"; do
        skill_file="$SKILLS_DIR/$skill/SKILL.md"
        if [ -f "$skill_file" ]; then
            write_pass "$skill"
            ((pass_count++))
        else
            write_fail "$skill - SKILL.md 未找到: $skill_file"
            ((fail_count++))
        fi
    done

    echo "  技能总数: ${#all_skills[@]}"
else
    write_fail "version.json 未找到: $version_json"
    ((fail_count++))
fi

# ============================================================
# [2/5] 技能间引用关系检查（简化版）
# ============================================================
write_header "2/5 技能间引用关系"

if [ -f "$version_json" ] && [ ${#all_skills[@]} -gt 0 ]; then
    ref_check_pass=0

    # 构建技能集合用于快速查找
    declare -A skill_set
    for skill in "${all_skills[@]}"; do
        skill_set["$skill"]=1
    done

    # 检查每个已安装技能文件中的引用
    for skill in "${all_skills[@]}"; do
        skill_file="$SKILLS_DIR/$skill/SKILL.md"
        [ -f "$skill_file" ] || continue

        # 提取反引号中的引用名称
        while IFS= read -r ref_name; do
            [ -z "$ref_name" ] && continue
            # 跳过自身引用
            [ "$ref_name" = "$skill" ] && continue
            # 只检查看起来像 DevFlow 技能名称的引用（含连字符且长度>=5）
            if [[ "$ref_name" == *"-"* && ${#ref_name} -ge 5 ]]; then
                if [ -n "${skill_set[$ref_name]+x}" ]; then
                    ((ref_check_pass++))
                else
                    write_warn "$skill 引用了未在 version.json 中注册的技能: $ref_name"
                    ((warn_count++))
                fi
            fi
        done < <(grep -oP '`([a-z][\w-]+)`' "$skill_file" 2>/dev/null | sed 's/`//g')
    done

    if [ "$ref_check_pass" -gt 0 ]; then
        write_pass "引用关系检查完成（检查到 $ref_check_pass 条有效引用）"
        ((pass_count++))
    else
        write_warn "未检测到技能间引用"
        ((warn_count++))
    fi

    # 清理关联数组
    unset skill_set
else
    write_skip "version.json 不可用，跳过引用检查"
    ((skip_count++))
fi

# ============================================================
# [3/5] 模板文件可用性检查
# ============================================================
write_header "3/5 模板文件可用性"

templates_dir="$PLUGIN_DIR/templates"
if [ -d "$templates_dir" ]; then
    # 统计模板文件数量（不含目录）
    template_count=0
    if command -v find &>/dev/null; then
        template_count=$(find "$templates_dir" -maxdepth 1 -type f | wc -l | tr -d ' ')
    else
        template_count=$(ls -1A "$templates_dir" 2>/dev/null | wc -l | tr -d ' ')
    fi

    write_pass "模板目录存在: $template_count 个文件"
    ((pass_count++))

    # 与 version.json 中的 templates 数量对比
    expected_count=0
    if [ -f "$version_json" ]; then
        if command -v python3 &>/dev/null; then
            expected_count=$(python3 -c "
import json
with open('$version_json', encoding='utf-8') as f:
    ver = json.load(f)
print(ver.get('templates', 0))
")
        elif command -v python &>/dev/null; then
            expected_count=$(python -c "
import json
with open('$version_json', encoding='utf-8') as f:
    ver = json.load(f)
print(ver.get('templates', 0))
")
        elif command -v jq &>/dev/null; then
            expected_count=$(jq -r '.templates // 0' "$version_json")
        fi
    fi

    if [ "$expected_count" -gt 0 ]; then
        if [ "$template_count" -eq "$expected_count" ]; then
            write_pass "模板文件数量匹配 ($template_count/$expected_count)"
            ((pass_count++))
        else
            write_warn "模板文件数量不匹配 (实际=$template_count, 期望=$expected_count)"
            ((warn_count++))
        fi
    else
        write_skip "version.json 中未指定 templates 数量"
        ((skip_count++))
    fi
else
    write_fail "模板目录未找到: $templates_dir"
    ((fail_count++))
fi

# ============================================================
# [4/5] 编排器加载正常检查
# ============================================================
write_header "4/5 编排器加载正常"

# 获取编排器列表
orchestrators=()
if [ -f "$version_json" ]; then
    if command -v python3 &>/dev/null; then
        mapfile -t orchestrators < <(python3 -c "
import json
with open('$version_json', encoding='utf-8') as f:
    ver = json.load(f)
for s in ver.get('layers', {}).get('orchestrator', []):
    print(s)
")
    elif command -v python &>/dev/null; then
        mapfile -t orchestrators < <(python -c "
import json
with open('$version_json', encoding='utf-8') as f:
    ver = json.load(f)
for s in ver.get('layers', {}).get('orchestrator', []):
    print(s)
")
    elif command -v jq &>/dev/null; then
        mapfile -t orchestrators < <(jq -r '.layers.orchestrator[]?' "$version_json")
    fi
fi

# 如果未能从 JSON 解析，使用默认列表
if [ ${#orchestrators[@]} -eq 0 ]; then
    orchestrators=("devflow-init" "devflow-phase-manager" "devflow-project-config")
fi

for orch in "${orchestrators[@]}"; do
    orch_path="$PLUGIN_DIR/$orch/SKILL.md"
    if [ -f "$orch_path" ]; then
        content=$(cat "$orch_path")

        # 检查 YAML frontmatter（以 --- 开头）
        has_frontmatter=0
        echo "$content" | head -1 | grep -q '^---\s*$' && has_frontmatter=1

        # 检查必要章节：定位、触发条件
        has_positioning=0
        echo "$content" | grep -q '## 定位' && has_positioning=1

        has_trigger=0
        echo "$content" | grep -q '## 触发条件' && has_trigger=1

        if [ "$has_frontmatter" -eq 1 ] && [ "$has_positioning" -eq 1 ] && [ "$has_trigger" -eq 1 ]; then
            write_pass "$orch - 格式完整（frontmatter + 定位 + 触发条件）"
            ((pass_count++))
        elif [ "$has_positioning" -eq 1 ] && [ "$has_trigger" -eq 1 ]; then
            write_warn "$orch - 缺少 YAML frontmatter，但包含必要章节"
            ((warn_count++))
        else
            missing=""
            [ "$has_frontmatter" -eq 0 ] && missing="$missing YAML frontmatter"
            [ "$has_positioning" -eq 0 ] && missing="$missing 定位章节"
            [ "$has_trigger" -eq 0 ] && missing="$missing 触发条件章节"
            # 去掉开头的空格和分隔逗号
            missing=$(echo "$missing" | sed 's/^ //' | sed 's/ /, /')
            write_fail "$orch - 缺少: $missing"
            ((fail_count++))
        fi
    else
        write_fail "$orch - SKILL.md 未找到: $orch_path"
        ((fail_count++))
    fi
done

# ============================================================
# [5/5] 配置文件语法检查
# ============================================================
write_header "5/5 配置文件语法"

# 检查 version.json
if [ -f "$version_json" ]; then
    if is_json_valid "$version_json"; then
        write_pass "version.json - JSON 语法有效"
        ((pass_count++))
    else
        write_fail "version.json - JSON 语法无效"
        ((fail_count++))
    fi
else
    write_fail "version.json - 文件不存在"
    ((fail_count++))
fi

# 检查 .devflow/config.json
config_json="$PLUGIN_DIR/.devflow/config.json"
if [ -f "$config_json" ]; then
    if is_json_valid "$config_json"; then
        write_pass "config.json - JSON 语法有效"
        ((pass_count++))
    else
        write_fail "config.json - JSON 语法无效"
        ((fail_count++))
    fi
else
    write_warn "config.json - 文件不存在（首次安装后需通过 devflow-init 生成）"
    ((warn_count++))
fi

# 检查 .devflow/state.json
state_json="$PLUGIN_DIR/.devflow/state.json"
if [ -f "$state_json" ]; then
    if is_json_valid "$state_json"; then
        write_pass "state.json - JSON 语法有效"
        ((pass_count++))
    else
        write_fail "state.json - JSON 语法无效"
        ((fail_count++))
    fi
else
    write_warn "state.json - 文件不存在（首次安装后需通过 devflow-init 生成）"
    ((warn_count++))
fi

# ============================================================
# 验证汇总
# ============================================================
echo ""
echo "========================================"
echo "验证汇总: 通过=$pass_count 失败=$fail_count 警告=$warn_count 跳过=$skip_count"

if [ "$fail_count" -eq 0 ]; then
    echo -e "${GREEN}结果: 全部检查通过${NC}"
    exit 0
else
    echo -e "${RED}结果: 存在失败项，请检查上述错误${NC}"
    exit 1
fi
