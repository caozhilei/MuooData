#!/bin/bash

# 重启数据标准服务脚本（带修复）

set -e

cd "$(dirname "$0")"

SERVICE_DIR="moat/studio/data-standard-service-parent/data-standard-service"
PID=$(ps aux | grep "DataxStandardApplication" | grep -v grep | awk '{print $2}')

echo "=========================================="
echo "重启数据标准服务"
echo "=========================================="
echo ""

# 停止现有服务
if [ -n "$PID" ]; then
    echo "1. 停止现有服务 (PID: $PID)..."
    kill $PID
    sleep 2
    
    # 检查是否已停止
    if ps -p $PID > /dev/null 2>&1; then
        echo "   强制停止服务..."
        kill -9 $PID
        sleep 1
    fi
    echo "   ✓ 服务已停止"
else
    echo "1. 未找到运行中的服务"
fi

echo ""

# 启动服务
echo "2. 启动服务（带Java反射修复）..."
cd "$SERVICE_DIR"

# 使用Maven启动，自动包含JVM参数
mvn spring-boot:run \
    -DskipTests \
    -Dspring-boot.run.jvmArguments="--add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED" &

echo ""
echo "服务正在启动..."
echo "查看日志确认服务是否正常启动"
echo ""

