#!/bin/bash
# 启动单个AllData服务

set -e

cd "$(dirname "$0")"

SERVICE_NAME=$1
MAIN_CLASS=$2
MODULE_PATH=$3
PORT=$4
HEALTH_URL=$5

if [ -z "$SERVICE_NAME" ] || [ -z "$MAIN_CLASS" ] || [ -z "$MODULE_PATH" ] || [ -z "$PORT" ]; then
    echo "用法: $0 <服务名称> <主类> <模块路径> <端口> [健康检查URL]"
    echo ""
    echo "示例:"
    echo "  $0 Eureka cn.datax.eureka.DataxEurekaApplication moat/eureka 8610 http://localhost:8610"
    exit 1
fi

# 检查端口是否被占用
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "警告: 端口 $PORT 已被占用"
    echo "请先停止占用该端口的服务，或使用其他端口"
    exit 1
fi

# 检查模块路径
if [ ! -d "$MODULE_PATH" ]; then
    echo "错误: 模块路径不存在: $MODULE_PATH"
    exit 1
fi

cd "$MODULE_PATH"

# 检查是否已编译
if [ ! -d "target/classes" ] && [ ! -f "target/*.jar" ]; then
    echo "编译 $SERVICE_NAME..."
    mvn clean compile -DskipTests -q
fi

echo "=========================================="
echo "启动服务: $SERVICE_NAME"
echo "主类: $MAIN_CLASS"
echo "端口: $PORT"
echo "=========================================="
echo ""
echo "日志将输出到控制台"
echo "按 Ctrl+C 停止服务"
echo ""

# 启动服务（前台运行，方便查看日志）
mvn spring-boot:run -DskipTests

