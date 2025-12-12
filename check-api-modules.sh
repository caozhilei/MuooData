#!/bin/bash

# 检查服务API模块编译状态脚本

set -e

cd "$(dirname "$0")"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}✗${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

echo "=========================================="
echo "检查服务API模块编译状态"
echo "=========================================="
echo ""

# API模块列表（格式：模块名|路径）
API_MODULES=(
    "data-system-service-api|moat/studio/data-system-service-parent/data-system-service-api"
    "file-service-api|moat/studio/file-service-parent/file-service-api"
    "email-service-api|moat/studio/email-service-parent/email-service-api"
    "quartz-service-api|moat/studio/quartz-service-parent/quartz-service-api"
    "data-metadata-service-api|moat/studio/data-metadata-service-parent/data-metadata-service-api"
    "data-market-service-api|moat/studio/data-market-service-parent/data-market-service-api"
    "data-standard-service-api|moat/studio/data-standard-service-parent/data-standard-service-api"
    "data-quality-service-api|moat/studio/data-quality-service-parent/data-quality-service-api"
    "data-visual-service-api|moat/studio/data-visual-service-parent/data-visual-service-api"
    "data-masterdata-service-api|moat/studio/data-masterdata-service-parent/data-masterdata-service-api"
    "service-data-rpc|moat/studio/service-data-dts-parent/service-data-rpc"
    "service-data-core|moat/studio/service-data-dts-parent/service-data-core"
)

COMPILED=0
NOT_COMPILED=0
NOT_COMPILED_LIST=()

for module_info in "${API_MODULES[@]}"; do
    IFS='|' read -r module_name module_path <<< "$module_info"
    
    if [ ! -d "$module_path" ]; then
        log_error "$module_name: 模块路径不存在 ($module_path)"
        ((NOT_COMPILED++))
        NOT_COMPILED_LIST+=("$module_name|$module_path")
        continue
    fi
    
    # 检查target目录和jar文件
    jar_file=$(find "$module_path/target" -name "*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" 2>/dev/null | head -1)
    
    if [ -n "$jar_file" ] && [ -f "$jar_file" ]; then
        jar_size=$(ls -lh "$jar_file" | awk '{print $5}')
        log_success "$module_name: 已编译 ($jar_size) - $jar_file"
        ((COMPILED++))
    else
        log_warning "$module_name: 未编译"
        ((NOT_COMPILED++))
        NOT_COMPILED_LIST+=("$module_name|$module_path")
    fi
done

echo ""
echo "=========================================="
echo "编译状态统计"
echo "=========================================="
echo -e "${GREEN}已编译: $COMPILED 个模块${NC}"
echo -e "${YELLOW}未编译: $NOT_COMPILED 个模块${NC}"

if [ $NOT_COMPILED -gt 0 ]; then
    echo ""
    echo "未编译的模块:"
    for module_info in "${NOT_COMPILED_LIST[@]}"; do
        IFS='|' read -r module_name module_path <<< "$module_info"
        echo "  - $module_name"
    done
    echo ""
    echo "建议执行以下命令编译这些模块:"
    echo ""
    for module_info in "${NOT_COMPILED_LIST[@]}"; do
        IFS='|' read -r module_name module_path <<< "$module_info"
        if [ -d "$module_path" ]; then
            echo "cd $module_path && mvn clean install -DskipTests"
        fi
    done
    echo ""
    echo "或者使用批量编译脚本:"
    echo "  ./build-api-modules.sh"
fi

echo ""

