#!/bin/bash
# DevFlow Skill Reference Checker v1.0
# VR-013 技能间交叉引用完整性检查
# 用法：./check-references.sh [-p <插件目录>] [-v]

set -euo pipefail

# ============================================================
# 参数解析
# ============================================================
PLUGIN_DIR=""
VERBOSE=0

while getopts "p:v" opt; do
    case $opt in
        p) PLUGIN_DIR="$OPTARG" ;;
        v) VERBOSE=1 ;;
        *) echo "用法: $0 [-p <插件目录>] [-v]"; exit 1 ;;
    esac
done

# 自动检测插件目录（脚本位于 scripts/ 下，上级即为插件根目录）
if [ -z "$PLUGIN_DIR" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
fi

# 检查插件目录是否存在
if [ ! -d "$PLUGIN_DIR" ]; then
    echo -e "\033[31m错误：插件目录不存在: $PLUGIN_DIR\033[0m"
    exit 1
fi

# ============================================================
# 颜色定义
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================================
# 函数: 获取所有技能列表，输出到全局关联数组
#   格式: skill_name|layer|file_path|rel_path
# ============================================================
declare -A SKILL_MAP       # skill_name -> "layer|file_path|rel_path"
declare -a SKILL_NAMES=()  # 所有技能名称的有序列表

scan_all_skills() {
    local root_dir="$1"
    local skills_dir="$root_dir/skills"

    # 收集 skills/L1、skills/L2、skills/L3 下的 .md 文件
    if [ -d "$skills_dir" ]; then
        for layer in L1 L2 L3; do
            local layer_dir="$skills_dir/$layer"
            if [ -d "$layer_dir" ]; then
                for file in "$layer_dir"/*.md; do
                    if [ -f "$file" ]; then
                        local skill_name="$(basename "$file" .md)"
                        local rel_path="skills/$layer/$(basename "$file")"
                        SKILL_MAP["$skill_name"]="$layer|$file|$rel_path"
                        SKILL_NAMES+=("$skill_name")
                    fi
                done
            fi
        done
    fi

    # 收集 orchestrator 目录（devflow-*/SKILL.md）
    for dir in "$root_dir"/devflow-*/; do
        if [ -d "$dir" ]; then
            local skill_file="$dir/SKILL.md"
            if [ -f "$skill_file" ]; then
                local skill_name="$(basename "$dir")"
                skill_name="${skill_name%/}"  # 去掉尾部的 /
                local rel_path="$skill_name/SKILL.md"
                SKILL_MAP["$skill_name"]="Orchestrator|$skill_file|$rel_path"
                SKILL_NAMES+=("$skill_name")
            fi
        done
    done
}

# ============================================================
# 函数: 检查技能名称是否存在
# ============================================================
skill_exists() {
    local name="$1"
    if [ -n "${SKILL_MAP[$name]+x}" ]; then
        return 0
    else
        return 1
    fi
}

# 获取技能的层
get_skill_layer() {
    local name="$1"
    local entry="${SKILL_MAP[$name]}"
    echo "$entry" | cut -d'|' -f1
}

# 获取技能的相对路径
get_skill_relpath() {
    local name="$1"
    local entry="${SKILL_MAP[$name]}"
    echo "$entry" | cut -d'|' -f3
}

# ============================================================
# 主流程
# ============================================================
echo -e "${CYAN}DevFlow Skill Reference Checker v1.0${NC}"
echo "========================================"
echo "插件目录: $PLUGIN_DIR"

# 1. 扫描所有技能文件
scan_all_skills "$PLUGIN_DIR"
skill_count=${#SKILL_NAMES[@]}

if [ "$skill_count" -eq 0 ]; then
    echo -e "${RED}错误：未找到任何技能文件。${NC}"
    exit 1
fi

echo -e "扫描技能数: ${GREEN}$skill_count${NC}"

# 按层统计
l1_count=0; l2_count=0; l3_count=0; orch_count=0
for name in "${SKILL_NAMES[@]}"; do
    layer="$(get_skill_layer "$name")"
    case "$layer" in
        L1) ((l1_count++)) ;;
        L2) ((l2_count++)) ;;
        L3) ((l3_count++)) ;;
        Orchestrator) ((orch_count++)) ;;
    esac
done
echo "  L1 ($l1_count) | L2 ($l2_count) | L3 ($l3_count) | Orchestrator ($orch_count)"

# 统计变量
total_pass=0
total_fail=0
total_warn=0

# ============================================================
# [1/4] 引用目标存在性检查
# ============================================================
echo ""
echo -e "${CYAN}[1/4] 引用目标存在性检查...${NC}"

ref_pass=0
ref_fail=0

for name in "${SKILL_NAMES[@]}"; do
    entry="${SKILL_MAP[$name]}"
    file_path=$(echo "$entry" | cut -d'|' -f2)
    rel_path=$(echo "$entry" | cut -d'|' -f3)
    leaf_file="$(basename "$rel_path")"

    # 提取所有被反引号包裹的名称
    backtick_names=()
    while IFS= read -r match; do
        [ -n "$match" ] && backtick_names+=("$match")
    done < <(grep -oP '`([a-z][\w-]+)`' "$file_path" | sed 's/`//g')

    # 去重并排序
    unique_names=($(echo "${backtick_names[@]}" | tr ' ' '\n' | sort -u))

    for ref_name in "${unique_names[@]}"; do
        # 跳过自身引用
        [ "$ref_name" = "$name" ] && continue

        if skill_exists "$ref_name"; then
            layer="$(get_skill_layer "$ref_name")"
            if [ "$VERBOSE" -eq 1 ]; then
                echo -e "  ${GREEN}\u2713${NC} $leaf_file 引用 $ref_name ($layer) -> 存在"
            fi
            ((ref_pass++))
        else
            # 只报告看起来像技能名称的引用（包含连字符，长度>=5）
            if [[ "$ref_name" == *"-"* && ${#ref_name} -ge 5 ]]; then
                echo -e "  ${RED}\u2717${NC} $leaf_file 引用 $ref_name -> 不存在"
                ((ref_fail++))
            fi
        fi
    done
done

echo -e "  通过: $ref_pass, 失败: $ref_fail"
total_pass=$((total_pass + ref_pass))
total_fail=$((total_fail + ref_fail))

# ============================================================
# [2/4] 路径引用正确性检查
# ============================================================
echo ""
echo -e "${CYAN}[2/4] 路径引用正确性检查...${NC}"

path_pass=0
path_fail=0
has_path_ref=0

for name in "${SKILL_NAMES[@]}"; do
    entry="${SKILL_MAP[$name]}"
    file_path=$(echo "$entry" | cut -d'|' -f2)
    rel_path=$(echo "$entry" | cut -d'|' -f3)
    leaf_file="$(basename "$rel_path")"

    # 提取路径引用（skills/xxx.md 或 orchestrator/xxx.md）
    path_refs=()
    while IFS= read -r match; do
        [ -n "$match" ] && path_refs+=("$match")
    done < <(grep -oP '(?:skills|orchestrator)/[\w/-]+\.md' "$file_path")

    # 去重并排序
    unique_paths=($(echo "${path_refs[@]}" | tr ' ' '\n' | sort -u))

    for path_ref in "${unique_paths[@]}"; do
        has_path_ref=1
        full_path="$PLUGIN_DIR/$path_ref"
        if [ -f "$full_path" ]; then
            if [ "$VERBOSE" -eq 1 ]; then
                echo -e "  ${GREEN}\u2713${NC} $leaf_file 引用路径 $path_ref -> 存在"
            fi
            ((path_pass++))
        else
            echo -e "  ${RED}\u2717${NC} $leaf_file 引用路径 $path_ref -> 不存在"
            ((path_fail++))
        fi
    done
done

if [ "$has_path_ref" -eq 0 ]; then
    echo -e "  ${YELLOW}未找到路径引用${NC}"
else
    echo -e "  通过: $path_pass, 失败: $path_fail"
fi

total_pass=$((total_pass + path_pass))
total_fail=$((total_fail + path_fail))

# ============================================================
# [3/4] 循环引用检测
# ============================================================
echo ""
echo -e "${CYAN}[3/4] 循环引用检测...${NC}"

# 构建邻接表（临时文件）
graph_file=$(mktemp)
for name in "${SKILL_NAMES[@]}"; do
    entry="${SKILL_MAP[$name]}"
    file_path=$(echo "$entry" | cut -d'|' -f2)
    neighbors=""

    # 提取反引号中的技能名
    backtick_names=()
    while IFS= read -r match; do
        [ -n "$match" ] && backtick_names+=("$match")
    done < <(grep -oP '`([a-z][\w-]+)`' "$file_path" | sed 's/`//g')

    unique_neighbors=($(echo "${backtick_names[@]}" | tr ' ' '\n' | sort -u))
    for neighbor in "${unique_neighbors[@]}"; do
        [ "$neighbor" = "$name" ] && continue
        if skill_exists "$neighbor"; then
            if [ -z "$neighbors" ]; then
                neighbors="$neighbor"
            else
                neighbors="$neighbors $neighbor"
            fi
        fi
    done

    echo "$name|$neighbors" >> "$graph_file"
done

# DFS 检测循环引用（使用递归 + 临时标记文件）
visited_file=$(mktemp)
stack_file=$(mktemp)
circle_found=0
circle_count=0

# 初始化访问记录
for name in "${SKILL_NAMES[@]}"; do
    echo "$name:unvisited" >> "$visited_file"
done

dfs_check() {
    local node="$1"
    local path="$2"

    # 检查是否在当前递归栈中
    local in_stack=0
    while IFS= read -r line; do
        local sname="${line%:*}"
        if [ "$sname" = "$node" ]; then
            in_stack=1
            break
        fi
    done < "$stack_file"

    if [ "$in_stack" -eq 1 ]; then
        # 找到循环，提取循环路径
        local cycle_start=0
        local path_arr=()
        IFS=' ' read -ra path_arr <<< "$path"
        local cycle_str=""
        local printing=0
        for pnode in "${path_arr[@]}"; do
            if [ "$pnode" = "$node" ]; then
                printing=1
            fi
            if [ "$printing" -eq 1 ]; then
                if [ -z "$cycle_str" ]; then
                    cycle_str="$pnode"
                else
                    cycle_str="$cycle_str -> $pnode"
                fi
            fi
        done
        cycle_str="$cycle_str -> $node"
        # 仅报告包含 3 个或更多不同节点的环（排除双向引用 A<->B）
        local unique_count=0
        local seen=""
        for cnode in "${path_arr[@]}"; do
            if [ "$printing" -eq 0 ] && [ "$cnode" = "$node" ]; then
                printing=1
            fi
            if [ "$printing" -eq 1 ]; then
                if [[ ! "$seen" =~ "$cnode" ]]; then
                    seen="$seen $cnode"
                    ((unique_count++))
                fi
            fi
        done
        if [ "$unique_count" -ge 3 ]; then
            echo -e "  ${RED}\u2717 循环引用: $cycle_str${NC}"
            circle_found=1
        fi
        return 0
    fi

    # 检查是否已完全访问过
    local visited_status=$(grep "^$node:" "$visited_file" | cut -d':' -f2)
    if [ "$visited_status" = "visited" ]; then
        return 0
    fi

    # 标记为在栈中
    sed -i "s/^$node:unvisited/$node:in_stack/" "$visited_file"
    echo "$node:1" >> "$stack_file"

    # 获取邻居
    local neighbors=""
    while IFS= read -r line; do
        if [[ "$line" == "$node|"* ]]; then
            neighbors="${line#*|}"
            break
        fi
    done < "$graph_file"

    local new_path="$path $node"
    for neighbor in $neighbors; do
        if dfs_check "$neighbor" "$new_path"; then
            :
        else
            circle_found=1
            # 不立即返回，尝试找完所有循环
        fi
    done

    # 从栈中移除，标记为已访问
    sed -i "/^$node:1$/d" "$stack_file"
    sed -i "s/^$node:in_stack/$node:visited/" "$visited_file"
    return 0
}

# 对每个未访问的节点执行 DFS
for name in $(sort <<< "${SKILL_NAMES[*]}"); do
    visited_status=$(grep "^$name:" "$visited_file" | cut -d':' -f2)
    if [ "$visited_status" = "unvisited" ]; then
        dfs_check "$name" ""
    fi
done

# 清理临时文件
rm -f "$graph_file" "$visited_file" "$stack_file"

if [ "$circle_found" -eq 0 ]; then
    echo -e "  ${GREEN}未检测到循环引用${NC}"
    total_pass=$((total_pass + 1))
else
    total_fail=$((total_fail + 1))
fi

# ============================================================
# [4/4] 孤立技能检测
# ============================================================
echo ""
echo -e "${CYAN}[4/4] 孤立技能检测...${NC}"

# 构建反向引用表
declare -A REVERSE_REFS
for name in "${SKILL_NAMES[@]}"; do
    REVERSE_REFS["$name"]=""
done

for name in "${SKILL_NAMES[@]}"; do
    entry="${SKILL_MAP[$name]}"
    file_path=$(echo "$entry" | cut -d'|' -f2)

    # 提取反引号中的技能名
    backtick_names=()
    while IFS= read -r match; do
        [ -n "$match" ] && backtick_names+=("$match")
    done < <(grep -oP '`([a-z][\w-]+)`' "$file_path" | sed 's/`//g')

    unique_names=($(echo "${backtick_names[@]}" | tr ' ' '\n' | sort -u))
    for ref in "${unique_names[@]}"; do
        [ "$ref" = "$name" ] && continue
        if skill_exists "$ref"; then
            current="${REVERSE_REFS[$ref]}"
            if [ -z "$current" ]; then
                REVERSE_REFS["$ref"]="$name"
            else
                REVERSE_REFS["$ref"]="$current $name"
            fi
        fi
    done
done

orphan_count=0
for name in $(printf '%s\n' "${SKILL_NAMES[@]}" | sort); do
    refs="${REVERSE_REFS[$name]}"
    if [ -z "$refs" ]; then
        layer="$(get_skill_layer "$name")"
        echo -e "  ${YELLOW}\u26A0${NC} $name ($layer) 未被任何技能引用（可能是新添加的）"
        ((orphan_count++))
    fi
done

if [ "$orphan_count" -eq 0 ]; then
    echo -e "  ${GREEN}所有技能均被至少一个其他技能引用${NC}"
fi

non_orphan=$((skill_count - orphan_count))
total_pass=$((total_pass + non_orphan))
total_warn=$((total_warn + orphan_count))

# ============================================================
# [附加] 技能速查映射检查（L2 -> L3）
# ============================================================
echo ""
echo -e "${CYAN}[附加] 技能速查映射检查（L2 -> L3）...${NC}"

qr_pass=0
qr_fail=0
has_qr_ref=0

for name in $(printf '%s\n' "${SKILL_NAMES[@]}" | sort); do
    layer="$(get_skill_layer "$name")"
    [ "$layer" != "L2" ] && continue

    entry="${SKILL_MAP[$name]}"
    file_path=$(echo "$entry" | cut -d'|' -f2)
    rel_path=$(echo "$entry" | cut -d'|' -f3)
    leaf_file="$(basename "$rel_path")"

    # 提取 "内联自 xxx 技能" 引用
    qr_refs=()
    while IFS= read -r match; do
        [ -n "$match" ] && qr_refs+=("$match")
    done < <(grep -oP '内联自\s+[\w-]+\s*技能' "$file_path" | grep -oP '(?<=内联自\s)[\w-]+')

    # 去重并排序
    unique_qr=($(echo "${qr_refs[@]}" | tr ' ' '\n' | sort -u))

    for ref_name in "${unique_qr[@]}"; do
        has_qr_ref=1
        if skill_exists "$ref_name"; then
            ref_layer="$(get_skill_layer "$ref_name")"
            echo -e "  ${GREEN}\u2713${NC} $leaf_file 速查引用 $ref_name ($ref_layer) -> 存在"
            ((qr_pass++))
        else
            echo -e "  ${RED}\u2717${NC} $leaf_file 速查引用 $ref_name -> 不存在"
            ((qr_fail++))
        fi
    done
done

if [ "$has_qr_ref" -eq 0 ]; then
    echo -e "  ${YELLOW}未找到 L3 速查引用${NC}"
else
    echo -e "  通过: $qr_pass, 失败: $qr_fail"
fi

total_pass=$((total_pass + qr_pass))
total_fail=$((total_fail + qr_fail))

# ============================================================
# 输出汇总
# ============================================================
echo ""
echo "========================================"

if [ "$total_fail" -gt 0 ]; then
    echo -e "${RED}检查汇总: 通过 $total_pass, 警告 $total_warn, 失败 $total_fail${NC}"
    echo -e "${RED}退出码: 1${NC}"
    exit 1
elif [ "$total_warn" -gt 0 ]; then
    echo -e "${YELLOW}检查汇总: 通过 $total_pass, 警告 $total_warn, 失败 $total_fail${NC}"
    echo -e "${GREEN}退出码: 0${NC}"
    exit 0
else
    echo -e "${GREEN}检查汇总: 通过 $total_pass, 警告 $total_warn, 失败 $total_fail${NC}"
    echo -e "${GREEN}退出码: 0${NC}"
    exit 0
fi
