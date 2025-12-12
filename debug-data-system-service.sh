#!/bin/bash
# 单独调试Data System Service启动问题

set -e

cd "$(dirname "$0")"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
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
    log "Java版本: $(java -version 2>&1 | head -n 1)"
}

# 检查Maven依赖
check_maven_dependency() {
    local groupId=$1
    local artifactId=$2
    local version=$3
    
    info "检查Maven依赖: $groupId:$artifactId:$version"
    
    if mvn dependency:get -DgroupId=$groupId -DartifactId=$artifactId -Dversion=$version -Dpackaging=jar -q 2>/dev/null; then
        log "✓ 依赖已存在: $groupId:$artifactId:$version"
        return 0
    else
        warning "✗ 依赖不存在: $groupId:$artifactId:$version"
        return 1
    fi
}

# 编译并安装模块
build_and_install_module() {
    local module_path=$1
    local module_name=$2
    
    log "=========================================="
    log "编译并安装模块: $module_name"
    log "路径: $module_path"
    log "=========================================="
    
    if [ ! -d "$module_path" ]; then
        error "模块路径不存在: $module_path"
        return 1
    fi
    
    cd "$module_path"
    
    # 优先使用本地优化的Maven settings（使用阿里云镜像）
    local settings_path="$PROJECT_ROOT/docker/maven-settings-local.xml"
    if [ ! -f "$settings_path" ]; then
        settings_path="$PROJECT_ROOT/docker/maven-settings.xml"
    fi
    
    info "执行: mvn clean install -DskipTests"
    info "使用Maven settings: $settings_path"
    info "使用镜像源: 阿里云 + 腾讯云（备用）"
    
    # 设置Maven选项以加快编译
    export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=512m"
    
    if mvn -s "$settings_path" clean install -DskipTests -U; then
        log "✓ $module_name 编译并安装成功"
        cd - > /dev/null
        return 0
    else
        error "✗ $module_name 编译失败"
        cd - > /dev/null
        return 1
    fi
}

# 主流程
main() {
    echo ""
    log "=========================================="
    log "Data System Service 调试脚本"
    log "=========================================="
    echo ""
    
    # 保存项目根目录绝对路径
    PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
    export PROJECT_ROOT
    
    # 检测并配置系统代理（如果存在）
    if [ -n "$HTTP_PROXY" ] || [ -n "$http_proxy" ]; then
        local proxy_url="${HTTP_PROXY:-$http_proxy}"
        log "检测到系统代理: $proxy_url"
        info "Maven将使用系统代理设置"
    elif [ -n "$HTTPS_PROXY" ] || [ -n "$https_proxy" ]; then
        local proxy_url="${HTTPS_PROXY:-$https_proxy}"
        log "检测到HTTPS代理: $proxy_url"
        info "Maven将使用系统代理设置"
    else
        log "未检测到系统代理，将使用国内镜像源（阿里云/腾讯云）"
    fi
    
    # 设置Java 8
    setup_java8
    
    # 检查基础服务
    log "检查基础服务状态..."
    if ! lsof -Pi :8610 -sTCP:LISTEN -t >/dev/null 2>&1; then
        error "Eureka未启动，请先启动Eureka服务"
        exit 1
    fi
    if ! lsof -Pi :8611 -sTCP:LISTEN -t >/dev/null 2>&1; then
        error "Config未启动，请先启动Config服务"
        exit 1
    fi
    log "✓ 基础服务检查通过"
    echo ""
    
    # 步骤1: 检查并编译studio父模块
    log "步骤1: 检查studio父模块"
    if ! check_maven_dependency "com.platform" "studio" "0.6.x"; then
        warning "studio父模块不存在，需要先编译"
        if build_and_install_module "moat/studio" "studio父模块"; then
            log "✓ studio父模块编译成功"
        else
            error "studio父模块编译失败，请检查错误信息"
            exit 1
        fi
    fi
    echo ""
    
    # 步骤2: 检查并编译data-system-service-parent父模块
    log "步骤2: 检查data-system-service-parent父模块"
    if ! check_maven_dependency "com.platform" "data-system-service-parent" "0.6.x"; then
        warning "data-system-service-parent父模块不存在，需要先编译"
        if build_and_install_module "moat/studio/data-system-service-parent" "data-system-service-parent"; then
            log "✓ data-system-service-parent父模块编译成功"
        else
            error "data-system-service-parent父模块编译失败，请检查错误信息"
            exit 1
        fi
    fi
    echo ""
    
    # 步骤3: 检查并编译data-system-service-api
    log "步骤3: 检查data-system-service-api模块"
    if ! check_maven_dependency "com.platform" "data-system-service-api" "0.6.x"; then
        warning "data-system-service-api模块不存在，需要先编译"
        if build_and_install_module "moat/studio/data-system-service-parent/data-system-service-api" "data-system-service-api"; then
            log "✓ data-system-service-api编译成功"
        else
            error "data-system-service-api编译失败，请检查错误信息"
            exit 1
        fi
    fi
    echo ""
    
    # 步骤4: 编译data-system-service
    log "步骤4: 编译data-system-service"
    if build_and_install_module "moat/studio/data-system-service-parent/data-system-service" "data-system-service"; then
        log "✓ data-system-service编译成功"
    else
        error "data-system-service编译失败，请检查错误信息"
        exit 1
    fi
    echo ""
    
    # 步骤5: 启动服务
    log "步骤5: 启动Data System Service"
    log "端口: 8810"
    log "主类: cn.datax.service.system.DataxSystemApplication"
    echo ""
    
    cd moat/studio/data-system-service-parent/data-system-service
    
    # 优先使用本地优化的Maven settings
    local settings_path="$PROJECT_ROOT/docker/maven-settings-local.xml"
    if [ ! -f "$settings_path" ]; then
        settings_path="$PROJECT_ROOT/docker/maven-settings.xml"
    fi
    
    info "启动命令: mvn spring-boot:run -DskipTests"
    info "使用Maven settings: $settings_path"
    info "日志将输出到控制台，按Ctrl+C停止服务"
    echo ""
    
    # 设置Maven选项
    export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=512m"
    
    # 直接在前台运行，方便查看日志
    mvn -s "$settings_path" spring-boot:run -DskipTests
}

main

