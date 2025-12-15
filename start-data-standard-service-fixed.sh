#!/bin/bash

# 修复后的数据标准服务启动脚本
# 添加了Java 9+模块系统所需的JVM参数

set -e

cd "$(dirname "$0")"

SERVICE_DIR="moat/studio/data-standard-service-parent/data-standard-service"
MAIN_CLASS="cn.datax.service.data.standard.DataxStandardApplication"

if [ ! -d "$SERVICE_DIR" ]; then
    echo "错误: 服务目录不存在: $SERVICE_DIR"
    exit 1
fi

cd "$SERVICE_DIR"

echo "=========================================="
echo "启动数据标准服务（修复版）"
echo "=========================================="
echo ""
echo "添加的JVM参数："
echo "  --add-opens=java.base/java.lang.reflect=ALL-UNNAMED"
echo "  --add-opens=java.base/java.lang=ALL-UNNAMED"
echo ""

# 检查是否已编译
if [ ! -d "target/classes" ]; then
    echo "编译服务..."
    mvn clean compile -DskipTests -q
fi

echo "启动服务..."
echo "按 Ctrl+C 停止服务"
echo ""

# 使用Maven启动，添加JVM参数
mvn spring-boot:run \
    -DskipTests \
    -Dspring-boot.run.jvmArguments="--add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED"

