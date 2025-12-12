#!/bin/bash
# 按依赖顺序编译AllData项目的基础模块

set -e

cd "$(dirname "$0")"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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
    local description=$3
    
    log "=========================================="
    log "编译模块: $module_name"
    log "描述: $description"
    log "路径: $module_path"
    log "=========================================="
    
    if [ ! -d "$module_path" ]; then
        error "模块路径不存在: $module_path"
        return 1
    fi
    
    cd "$module_path"
    
    # 使用docker/maven-settings.xml（如果存在）
    MAVEN_OPTS="-s ../../docker/maven-settings.xml"
    if [ ! -f "../../docker/maven-settings.xml" ]; then
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
    log "AllData 依赖模块编译脚本"
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
    
    # 步骤1: 安装aspose-words到本地仓库
    log "=========================================="
    log "步骤1: 安装aspose-words到本地仓库"
    log "=========================================="
    if [ -f "moat/common/aspose-words-20.3.jar" ]; then
        log "安装aspose-words-20.3.jar..."
        cd moat/common
        mvn install:install-file \
            -Dfile=aspose-words-20.3.jar \
            -DgroupId=com.aspose \
            -DartifactId=aspose-words \
            -Dversion=20.3 \
            -Dpackaging=jar
        cd - > /dev/null
        log "aspose-words安装完成"
    else
        warning "aspose-words-20.3.jar不存在，跳过安装"
    fi
    echo ""
    
    # 步骤2: 编译common模块（基础模块）
    if ! build_module "common" "moat/common" "公共基础模块（包含所有common子模块）"; then
        error "common模块编译失败，无法继续"
        exit 1
    fi
    echo ""
    
    # 步骤3: 编译generic模块
    if ! build_module "generic" "moat/generic" "通用模块"; then
        error "generic模块编译失败，无法继续"
        exit 1
    fi
    echo ""
    
    # 步骤4: 编译logging模块
    if ! build_module "logging" "moat/logging" "日志模块"; then
        error "logging模块编译失败，无法继续"
        exit 1
    fi
    echo ""
    
    # 步骤5: 编译box模块
    if ! build_module "box" "moat/box" "工具箱模块"; then
        error "box模块编译失败，无法继续"
        exit 1
    fi
    echo ""
    
    log "=========================================="
    log "所有基础依赖模块编译完成！"
    log "=========================================="
    echo ""
    log "已编译的模块："
    log "  ✓ common（公共基础模块）"
    log "  ✓ generic（通用模块）"
    log "  ✓ logging（日志模块）"
    log "  ✓ box（工具箱模块）"
    echo ""
    log "现在可以启动业务服务了！"
    echo ""
}

# 运行主流程
main

