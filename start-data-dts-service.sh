#!/bin/bash

# 数据集成服务启动脚本
# 服务端口: 9536
# 主类: com.platform.admin.DataDtsServiceApplication

SERVICE_NAME="数据集成服务"
SERVICE_DIR="/Users/andyapple/Documents/Coding/alldata/moat/studio/service-data-dts-parent/service-data-dts"
JAR_FILE="${SERVICE_DIR}/target/service-data-dts.jar"
MAIN_CLASS="com.platform.admin.DataDtsServiceApplication"
PORT=9536

# 设置Java环境
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export PATH=$JAVA_HOME/bin:$PATH

# 检查JAR文件是否存在
if [ ! -f "$JAR_FILE" ]; then
    echo "错误: JAR文件不存在: $JAR_FILE"
    echo "请先构建项目: cd $SERVICE_DIR && mvn clean package -DskipTests"
    exit 1
fi

# 检查端口是否被占用
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "警告: 端口 $PORT 已被占用"
    PID=$(lsof -ti:$PORT)
    echo "占用进程PID: $PID"
    read -p "是否停止该进程? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kill -9 $PID
        sleep 2
    else
        exit 1
    fi
fi

# 创建日志目录
LOG_DIR="${SERVICE_DIR}/logs"
mkdir -p "$LOG_DIR"

echo "=========================================="
echo "启动 $SERVICE_NAME"
echo "端口: $PORT"
echo "JAR文件: $JAR_FILE"
echo "日志目录: $LOG_DIR"
echo "=========================================="

# 启动服务
cd "$SERVICE_DIR"
nohup java -Xms512m -Xmx2048m \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=200 \
    -Dfile.encoding=UTF-8 \
    -Dspring.profiles.active=dev \
    -jar "$JAR_FILE" \
    --server.port=$PORT \
    > "$LOG_DIR/service-data-dts.log" 2>&1 &

PID=$!
echo "服务已启动，PID: $PID"
echo "日志文件: $LOG_DIR/service-data-dts.log"
echo ""
echo "查看日志: tail -f $LOG_DIR/service-data-dts.log"
echo "停止服务: kill $PID"

# 等待服务启动
sleep 5

# 检查服务是否启动成功
if ps -p $PID > /dev/null; then
    echo ""
    echo "✓ $SERVICE_NAME 启动成功"
    echo "访问地址: http://localhost:$PORT"
else
    echo ""
    echo "✗ $SERVICE_NAME 启动失败，请查看日志"
    exit 1
fi

