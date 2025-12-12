#!/bin/bash
# 本地启动AllData基础服务和业务服务脚本

set -e

cd "$(dirname "$0")"

echo "=========================================="
echo "AllData 本地服务启动脚本"
echo "=========================================="
echo ""

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "错误: 未找到Java，请先安装JDK 1.8或更高版本"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1)
echo "Java版本: $JAVA_VERSION"
echo ""

# 检查Maven环境
if ! command -v mvn &> /dev/null; then
    echo "错误: 未找到Maven，请先安装Maven 3.0或更高版本"
    exit 1
fi

MAVEN_VERSION=$(mvn -version | head -1)
echo "Maven版本: $MAVEN_VERSION"
echo ""

# 检查Docker基础服务（MySQL、Redis、RabbitMQ）
echo "检查Docker基础服务..."
if ! docker ps | grep -q "alldata-mysql\|alldata-redis\|alldata-rabbitmq"; then
    echo "警告: Docker基础服务（MySQL/Redis/RabbitMQ）可能未启动"
    echo "请先启动Docker基础服务："
    echo "  docker-compose up -d mysql redis rabbitmq"
    echo ""
    read -p "是否继续？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✓ Docker基础服务检查完成"
echo ""

# 检查端口占用
check_port() {
    local port=$1
    local service=$2
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo "警告: 端口 $port ($service) 已被占用"
        return 1
    fi
    return 0
}

echo "检查端口占用..."
check_port 8610 "Eureka" || echo "  Eureka端口8610被占用"
check_port 8611 "Config" || echo "  Config端口8611被占用"
check_port 9538 "Gateway" || echo "  Gateway端口9538被占用"
check_port 8000 "System Service" || echo "  System Service端口8000被占用"
echo ""

# 启动服务函数
start_service() {
    local service_name=$1
    local main_class=$2
    local module_path=$3
    
    echo "=========================================="
    echo "启动 $service_name"
    echo "=========================================="
    echo "主类: $main_class"
    echo "模块路径: $module_path"
    echo ""
    
    cd "$module_path"
    
    # 检查是否已编译
    if [ ! -d "target/classes" ] && [ ! -f "target/*.jar" ]; then
        echo "编译 $service_name..."
        mvn clean compile -DskipTests
    fi
    
    echo "启动 $service_name..."
    echo "提示: 请在IDEA中运行主类 $main_class"
    echo "或者使用命令: cd $module_path && mvn spring-boot:run"
    echo ""
    
    cd - > /dev/null
}

echo "=========================================="
echo "服务启动指南"
echo "=========================================="
echo ""
echo "请在IDEA中按以下顺序启动服务："
echo ""
echo "1. Eureka注册中心 (端口: 8610)"
echo "   主类: cn.datax.eureka.DataxEurekaApplication"
echo "   路径: moat/eureka"
echo ""
echo "2. Config配置中心 (端口: 8611)"
echo "   主类: cn.datax.config.DataxConfigApplication"
echo "   路径: moat/config"
echo ""
echo "3. Gateway网关 (端口: 9538)"
echo "   主类: cn.datax.gateway.DataxGatewayApplication"
echo "   路径: moat/gateway"
echo ""
echo "4. System Service系统服务 (端口: 8000) - 必需"
echo "   主类: com.platform.SystemServiceApplication"
echo "   路径: moat/studio/system-service-parent/system-service"
echo ""
echo "5. 其他业务服务（根据需要启动）"
echo "   参考: LOCAL_BUSINESS_SERVICES.md"
echo ""
echo "=========================================="
echo "验证服务"
echo "=========================================="
echo ""
echo "启动后，可以通过以下方式验证："
echo "  - Eureka控制台: http://localhost:8610"
echo "  - Config健康检查: http://localhost:8611/actuator/health"
echo "  - Gateway健康检查: http://localhost:9538/actuator/health"
echo "  - System Service: http://localhost:8000"
echo ""
echo "=========================================="

