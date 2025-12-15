#!/bin/bash

# 使用Java 8启动数据标准服务

cd "$(dirname "$0")"

SERVICE_DIR="moat/studio/data-standard-service-parent/data-standard-service"
JAVA8_HOME="/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home"
LOG_FILE="/tmp/data-standard-service.log"

echo "=========================================="
echo "启动数据标准服务（Java 8）"
echo "=========================================="
echo ""

# 检查Java 8是否存在
if [ ! -d "$JAVA8_HOME" ]; then
    echo "错误: Java 8未找到，路径: $JAVA8_HOME"
    exit 1
fi

# 停止现有服务
PID=$(ps aux | grep "DataxStandardApplication" | grep -v grep | awk '{print $2}')
if [ -n "$PID" ]; then
    echo "停止现有服务 (PID: $PID)..."
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
    echo "未找到运行中的服务"
fi

echo ""

# 设置Java环境
export JAVA_HOME="$JAVA8_HOME"
export PATH="$JAVA_HOME/bin:$PATH"
unset MAVEN_OPTS

# 切换到服务目录
cd "$SERVICE_DIR"

echo "使用Java版本:"
java -version
echo ""

# 启动服务
echo "启动服务..."
nohup mvn spring-boot:run -DskipTests > "$LOG_FILE" 2>&1 &

NEW_PID=$!
echo ""
echo "服务启动命令已执行，后台进程ID: $NEW_PID"
echo "日志文件: $LOG_FILE"
echo ""
echo "查看日志: tail -f $LOG_FILE"
echo "检查服务状态: curl http://localhost:8825/actuator/health"
echo ""

