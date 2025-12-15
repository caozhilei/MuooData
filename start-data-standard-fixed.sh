#!/bin/bash

cd "$(dirname "$0")"

SERVICE_DIR="moat/studio/data-standard-service-parent/data-standard-service"
cd "$SERVICE_DIR"

echo "=========================================="
echo "启动数据标准服务（带Java反射修复）"
echo "=========================================="
echo ""

# 停止现有服务
PID=$(ps aux | grep "DataxStandardApplication" | grep -v grep | awk '{print $2}')
if [ -n "$PID" ]; then
    echo "停止现有服务 (PID: $PID)..."
    kill $PID
    sleep 2
fi

# 使用Maven启动，但指定主类
echo "启动服务..."
nohup mvn spring-boot:run \
    -DskipTests \
    -Dspring-boot.run.main-class=cn.datax.service.data.standard.DataxStandardApplication \
    -Dspring-boot.run.jvmArguments="--add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED" \
    > /tmp/data-standard-service.log 2>&1 &

echo ""
echo "服务正在启动..."
echo "查看日志: tail -f /tmp/data-standard-service.log"
echo ""

