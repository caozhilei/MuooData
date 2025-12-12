#!/bin/bash

# 批量编译服务API模块脚本

set -e

cd "$(dirname "$0")"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 切换到Java 8
setup_java8() {
    JAVA8_HOME=""
    if [ -d "/Library/Java/JavaVirtualMachines" ]; then
        for jdk in /Library/Java/JavaVirtualMachines/*; do
            if [[ "$jdk" =~ "temurin-8" ]] || [[ "$jdk" =~ "temurin@8" ]] || \
               [[ "$jdk" =~ "jdk-8" ]] || [[ "$jdk" =~ "jdk1.8" ]] || \
               [[ "$jdk" =~ "1.8" ]] || [[ "$jdk" =~ "8.jdk" ]]; then
                if [ -d "$jdk/Contents/Home" ]; then
                    JAVA8_HOME="$jdk/Contents/Home"
                    if [ -f "$JAVA8_HOME/bin/java" ]; then
                        JAVA_VERSION=$("$JAVA8_HOME/bin/java" -version 2>&1 | head -1)
                        if [[ "$JAVA_VERSION" =~ "1.8" ]] || [[ "$JAVA_VERSION" =~ "8" ]]; then
                            break
                        fi
                    fi
                fi
            fi
        done
    fi
    
    if [ -z "$JAVA8_HOME" ] || [ ! -d "$JAVA8_HOME" ]; then
        error "未找到Java 8安装"
        exit 1
    fi
    
    export JAVA_HOME="$JAVA8_HOME"
    export PATH="$JAVA_HOME/bin:$PATH"
    log "使用Java 8: $JAVA8_HOME"
}

# 编译模块函数
build_module() {
    local module_name=$1
    local module_path=$2
    
    log "=========================================="
    log "编译模块: $module_name"
    log "路径: $module_path"
    log "=========================================="
    
    if [ ! -d "$module_path" ]; then
        error "模块路径不存在: $module_path"
        return 1
    fi
    
    cd "$module_path"
    
    # 使用docker/maven-settings.xml（如果存在）
    MAVEN_OPTS="-s ../../../../docker/maven-settings.xml"
    if [ ! -f "../../../../docker/maven-settings.xml" ]; then
        MAVEN_OPTS=""
    fi
    
    log "开始编译..."
    if mvn $MAVEN_OPTS clean install -DskipTests; then
        log "$module_name 编译成功！"
        cd - > /dev/null
        return 0
    else
        error "$module_name 编译失败！"
        cd - > /dev/null
        return 1
    fi
}

# 主流程
main() {
    echo ""
    log "=========================================="
    log "AllData 服务API模块编译脚本"
    log "=========================================="
    echo ""
    
    # 设置Java 8
    setup_java8
    
    # 检查Maven
    if ! command -v mvn &> /dev/null; then
        error "未找到Maven，请先安装Maven 3.0或更高版本"
        exit 1
    fi
    
    log "Maven版本: $(mvn -version | head -1)"
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
    
    SUCCESS_COUNT=0
    FAILED_COUNT=0
    FAILED_MODULES=()
    
    for module_info in "${API_MODULES[@]}"; do
        IFS='|' read -r module_name module_path <<< "$module_info"
        
        if build_module "$module_name" "$module_path"; then
            ((SUCCESS_COUNT++))
        else
            ((FAILED_COUNT++))
            FAILED_MODULES+=("$module_name")
        fi
        echo ""
    done
    
    log "=========================================="
    log "编译完成！"
    log "=========================================="
    echo ""
    log "编译统计:"
    log "  成功: $SUCCESS_COUNT 个模块"
    log "  失败: $FAILED_COUNT 个模块"
    
    if [ ${#FAILED_MODULES[@]} -gt 0 ]; then
        echo ""
        error "失败的模块:"
        for module in "${FAILED_MODULES[@]}"; do
            echo "  - $module"
        done
    fi
    
    echo ""
    if [ $FAILED_COUNT -eq 0 ]; then
        log "✓ 所有API模块编译成功！"
    else
        error "⚠ 部分模块编译失败，请检查上面的错误信息"
        exit 1
    fi
    echo ""
}

# 运行主流程
main

