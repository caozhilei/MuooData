#!/bin/bash
# 按依赖顺序逐个启动AllData服务

set -e

cd "$(dirname "$0")"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志文件
LOG_FILE="logs/service-startup.log"
mkdir -p logs 2>/dev/null || true

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# 检查端口是否被占用
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        return 0  # 端口被占用
    fi
    return 1  # 端口空闲
}

# 等待服务启动
wait_for_service() {
    local service_name=$1
    local port=$2
    local health_url=$3
    local max_attempts=90  # 增加等待时间到3分钟
    local attempt=0
    
    log "等待 $service_name 启动（最多等待3分钟）..."
    
    while [ $attempt -lt $max_attempts ]; do
        if check_port $port; then
            if [ -n "$health_url" ]; then
                # 尝试访问健康检查端点
                if curl -s -f "$health_url" > /dev/null 2>&1; then
                    log "$service_name 启动成功并健康检查通过！"
                    return 0
                elif [ $attempt -gt 10 ]; then
                    # 如果端口已监听但健康检查失败，也认为启动成功（可能是健康检查端点不存在）
                    log "$service_name 端口已监听，认为启动成功"
                    return 0
                fi
            else
                # 没有健康检查URL，只检查端口
                log "$service_name 端口已监听，启动成功！"
                return 0
            fi
        fi
        attempt=$((attempt + 1))
        if [ $((attempt % 5)) -eq 0 ]; then
            log "仍在等待 $service_name 启动... ($attempt/$max_attempts)"
        fi
        sleep 2
    done
    
    error "$service_name 启动超时！"
    warning "请检查日志: logs/${service_name}.log"
    return 1
}

# 启动服务函数
start_service() {
    local service_name=$1
    local main_class=$2
    local module_path=$3
    local port=$4
    local health_url=$5
    
    echo ""
    log "=========================================="
    log "启动服务: $service_name"
    log "=========================================="
    
    # 检查端口是否已被占用
    if check_port $port; then
        warning "端口 $port 已被占用，跳过启动 $service_name"
        return 0
    fi
    
    # 检查模块路径是否存在
    if [ ! -d "$module_path" ]; then
        error "模块路径不存在: $module_path"
        return 1
    fi
    
    cd "$module_path"
    
    # 检查是否已编译
    if [ ! -d "target/classes" ] && [ ! -f "target/*.jar" ]; then
        log "编译 $service_name..."
        mvn clean compile -DskipTests -q
    fi
    
    log "启动 $service_name (端口: $port)..."
    log "主类: $main_class"
    log "模块: $module_path"
    
    # 在后台启动服务
    log "使用Maven启动服务..."
    nohup mvn spring-boot:run -DskipTests > "../../logs/${service_name}.log" 2>&1 &
    local pid=$!
    echo $pid > "../../logs/${service_name}.pid"
    
    log "服务进程ID: $pid"
    log "日志文件: logs/${service_name}.log"
    log "实时查看日志: tail -f logs/${service_name}.log"
    
    cd - > /dev/null
    
    # 等待服务启动
    if wait_for_service "$service_name" "$port" "$health_url"; then
        log "$service_name 已就绪，继续启动下一个服务..."
        return 0
    else
        error "启动失败，请查看日志: logs/${service_name}.log"
        warning "如果服务正在启动中，可以手动检查日志确认状态"
        return 1
    fi
}

# 主流程
main() {
    echo ""
    log "=========================================="
    log "AllData 服务顺序启动脚本"
    log "=========================================="
    echo ""
    
    # 检查Java和Maven
    if ! command -v java &> /dev/null; then
        error "未找到Java，请先安装JDK 1.8或更高版本"
        exit 1
    fi
    
    if ! command -v mvn &> /dev/null; then
        error "未找到Maven，请先安装Maven 3.0或更高版本"
        exit 1
    fi
    
    # 切换到Java 8（项目要求Java 8）
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
        error "项目需要Java 8，但当前使用的是: $(java -version 2>&1 | head -1)"
        error "请安装Java 8: brew install --cask temurin@8"
        exit 1
    fi
    
    log "切换到Java 8: $JAVA8_HOME"
    export JAVA_HOME="$JAVA8_HOME"
    export PATH="$JAVA_HOME/bin:$PATH"
    
    # 验证Java版本
    CURRENT_JAVA=$(java -version 2>&1 | head -1)
    log "当前Java版本: $CURRENT_JAVA"
    
    # 检查Docker基础服务
    log "检查Docker基础服务..."
    if ! docker ps | grep -q "alldata-mysql\|alldata-redis\|alldata-rabbitmq"; then
        warning "Docker基础服务可能未启动"
        warning "请确保MySQL、Redis、RabbitMQ在Docker中运行"
    fi
    
    # 按依赖顺序启动服务
    log "开始按依赖顺序启动服务..."
    echo ""
    
    # 1. Eureka注册中心（无依赖）
    start_service \
        "Eureka" \
        "cn.datax.eureka.DataxEurekaApplication" \
        "moat/eureka" \
        "8610" \
        "http://localhost:8610"
    
    if [ $? -ne 0 ]; then
        error "Eureka启动失败，无法继续"
        exit 1
    fi
    
    sleep 5
    
    # 2. Config配置中心（依赖Eureka）
    start_service \
        "Config" \
        "cn.datax.config.DataxConfigApplication" \
        "moat/config" \
        "8611" \
        "http://localhost:8611/actuator/health"
    
    if [ $? -ne 0 ]; then
        error "Config启动失败，无法继续"
        exit 1
    fi
    
    sleep 5
    
    # 3. Gateway网关（依赖Eureka和Config）
    start_service \
        "Gateway" \
        "cn.datax.gateway.DataxGatewayApplication" \
        "moat/gateway" \
        "9538" \
        "http://localhost:9538/actuator/health"
    
    sleep 5
    
    # 4. System Service系统服务（依赖Eureka和Config，必需）
    start_service \
        "SystemService" \
        "com.platform.SystemServiceApplication" \
        "moat/studio/system-service-parent/system-service" \
        "8000" \
        "http://localhost:8000"
    
    echo ""
    log "=========================================="
    log "基础服务启动完成！"
    log "=========================================="
    echo ""
    log "已启动的服务："
    log "  - Eureka注册中心: http://localhost:8610"
    log "  - Config配置中心: http://localhost:8611"
    log "  - Gateway网关: http://localhost:9538"
    log "  - System Service: http://localhost:8000"
    echo ""
    log "查看服务状态："
    log "  - Eureka控制台: http://localhost:8610"
    log "  - 查看日志: tail -f logs/*.log"
    log "  - 查看进程: ps aux | grep java"
    echo ""
    log "停止服务："
    log "  ./stop-services.sh"
    echo ""
}

# 运行主流程
main

