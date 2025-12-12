#!/bin/bash
# 按依赖顺序启动所有可选业务服务

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
    local max_attempts=90
    local attempt=0
    
    log "等待 $service_name 启动（最多等待3分钟）..."
    
    while [ $attempt -lt $max_attempts ]; do
        if check_port $port; then
            log "$service_name 端口已监听，启动成功！"
            return 0
        fi
        attempt=$((attempt + 1))
        if [ $((attempt % 10)) -eq 0 ]; then
            log "仍在等待 $service_name 启动... ($attempt/$max_attempts)"
        fi
        sleep 2
    done
    
    error "$service_name 启动超时！"
    warning "请检查日志: logs/${service_name}.log"
    return 1
}

# 启动业务服务函数
start_business_service() {
    local service_name=$1
    local main_class=$2
    local module_path=$3
    local port=$4
    
    log "=========================================="
    log "启动业务服务: $service_name"
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
    
    # 确保logs目录存在（从 moat/studio/*/ 目录回到项目根目录）
    mkdir -p "../../../../logs" 2>/dev/null || true
    
    log "启动 $service_name (端口: $port)..."
    log "主类: $main_class"
    log "模块: $module_path"
    
    # 在后台启动服务
    # 从 moat/studio/*/ 目录，需要回到项目根目录才能访问 docker/maven-settings.xml
    nohup mvn -s ../../../../docker/maven-settings.xml spring-boot:run -DskipTests > "../../../../logs/${service_name}.log" 2>&1 &
    local pid=$!
    echo $pid > "../../../../logs/${service_name}.pid"
    
    log "服务进程ID: $pid"
    log "日志文件: logs/${service_name}.log"
    
    cd - > /dev/null
    
    # 等待服务启动
    if wait_for_service "$service_name" "$port"; then
        log "$service_name 已就绪，继续启动下一个服务..."
        sleep 3  # 服务间间隔
        return 0
    else
        error "启动失败，请查看日志: logs/${service_name}.log"
        warning "继续启动下一个服务..."
        return 1
    fi
}

# 主流程
main() {
    echo ""
    log "=========================================="
    log "AllData 业务服务顺序启动脚本"
    log "=========================================="
    echo ""
    
    # 设置Java 8
    setup_java8
    
    # 检查基础服务
    log "检查基础服务状态..."
    if ! check_port 8610; then
        error "Eureka未启动，请先启动基础服务"
        exit 1
    fi
    if ! check_port 8611; then
        error "Config未启动，请先启动基础服务"
        exit 1
    fi
    if ! check_port 8000; then
        error "System Service未启动，请先启动基础服务"
        exit 1
    fi
    log "基础服务检查通过"
    echo ""
    
    # 按依赖顺序启动业务服务
    # 注意：这些服务主要依赖common/box/logging模块（已编译），相互之间依赖较少
    # 可以并行启动，但为了稳定性，我们按顺序启动
    
    log "开始按依赖顺序启动业务服务..."
    echo ""
    
    # 第一组：核心依赖服务（被其他服务依赖）
    # data-system-service 被几乎所有服务依赖
    start_business_service \
        "DataSystemService" \
        "cn.datax.service.system.DataxSystemApplication" \
        "moat/studio/data-system-service-parent/data-system-service" \
        "8810"
    
    # data-metadata-service 被多个服务依赖
    start_business_service \
        "DataMetadataService" \
        "cn.datax.service.metadata.DataxMetadataApplication" \
        "moat/studio/data-metadata-service-parent/data-metadata-service" \
        "8820"
    
    # 第二组：依赖system-service的基础服务
    start_business_service \
        "FileService" \
        "cn.datax.service.file.DataxFileApplication" \
        "moat/studio/file-service-parent/file-service" \
        "8811"
    
    start_business_service \
        "EmailService" \
        "cn.datax.service.email.DataxMailApplication" \
        "moat/studio/email-service-parent/email-service" \
        "8812"
    
    start_business_service \
        "QuartzService" \
        "cn.datax.service.quartz.DataxQuartzApplication" \
        "moat/studio/quartz-service-parent/quartz-service" \
        "8813"
    
    # 第三组：依赖metadata-service的服务
    start_business_service \
        "DataMetadataConsole" \
        "cn.datax.service.console.DataxConsoleApplication" \
        "moat/studio/data-metadata-service-parent/data-metadata-service-console" \
        "8821"
    
    start_business_service \
        "DataQualityService" \
        "cn.datax.service.quality.DataxQualityApplication" \
        "moat/studio/data-quality-service-parent/data-quality-service" \
        "8826"
    
    start_business_service \
        "DataVisualService" \
        "cn.datax.service.visual.DataxVisualApplication" \
        "moat/studio/data-visual-service-parent/data-visual-service" \
        "8827"
    
    # 第四组：数据治理相关服务
    start_business_service \
        "DataStandardService" \
        "cn.datax.service.standard.DataxStandardApplication" \
        "moat/studio/data-standard-service-parent/data-standard-service" \
        "8825"
    
    start_business_service \
        "DataMasterdataService" \
        "cn.datax.service.masterdata.DataxMasterdataApplication" \
        "moat/studio/data-masterdata-service-parent/data-masterdata-service" \
        "8828"
    
    # 第五组：数据市场相关服务（market-service需要先启动，mapping依赖它）
    start_business_service \
        "DataMarketService" \
        "cn.datax.service.market.DataxMarketApplication" \
        "moat/studio/data-market-service-parent/data-market-service" \
        "8822"
    
    start_business_service \
        "DataMarketMapping" \
        "cn.datax.service.mapping.DataxMappingApplication" \
        "moat/studio/data-market-service-parent/data-market-service-mapping" \
        "8823"
    
    start_business_service \
        "DataMarketIntegration" \
        "cn.datax.service.integration.DataxIntegrationApplication" \
        "moat/studio/data-market-service-parent/data-market-service-integration" \
        "8824"
    
    # 第六组：其他独立服务
    start_business_service \
        "DataCompareService" \
        "cn.datax.service.compare.DataCompareApplication" \
        "moat/studio/data-compare-service-parent/data-compare-service" \
        "8096"
    
    start_business_service \
        "ServiceDataDTS" \
        "com.platform.DataDtsServiceApplication" \
        "moat/studio/service-data-dts-parent/service-data-dts" \
        "9536"
    
    echo ""
    log "=========================================="
    log "所有业务服务启动完成！"
    log "=========================================="
    echo ""
    log "已启动的业务服务："
    log "  - Data System Service (8810)"
    log "  - File Service (8811)"
    log "  - Email Service (8812)"
    log "  - Quartz Service (8813)"
    log "  - Data Metadata Service (8820)"
    log "  - Data Metadata Console (8821)"
    log "  - Data Market Service (8822)"
    log "  - Data Market Mapping (8823)"
    log "  - Data Market Integration (8824)"
    log "  - Data Standard Service (8825)"
    log "  - Data Quality Service (8826)"
    log "  - Data Visual Service (8827)"
    log "  - Data Masterdata Service (8828)"
    log "  - Data Compare Service (8096)"
    log "  - Service Data DTS (9536)"
    echo ""
    log "查看服务状态："
    log "  - Eureka控制台: http://localhost:8610"
    log "  - 查看日志: tail -f logs/*.log"
    log "  - 查看进程: ps aux | grep java"
    echo ""
    log "停止所有服务："
    log "  ./stop-services.sh"
    echo ""
}

# 运行主流程
main

