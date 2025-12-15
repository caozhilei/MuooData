#!/bin/bash

# 修复Java反射访问问题的脚本
# 解决: java.lang.reflect.InaccessibleObjectException

echo "=========================================="
echo "修复Java反射访问问题"
echo "=========================================="
echo ""

# 检查Java版本
echo "1. 检查Java版本..."
JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)
echo "Java版本: $JAVA_VERSION"

if [ "$JAVA_VERSION" -lt 9 ]; then
    echo "✓ Java版本 < 9，不需要修复"
    exit 0
fi

echo "⚠ Java版本 >= 9，需要添加JVM参数"
echo ""

# 查找数据标准服务进程
echo "2. 查找数据标准服务进程..."
PID=$(ps aux | grep "DataxStandardApplication" | grep -v grep | awk '{print $2}')

if [ -z "$PID" ]; then
    echo "✗ 未找到数据标准服务进程"
    echo ""
    echo "请使用以下方式启动服务："
    echo ""
    echo "方式1: 使用Maven启动（推荐）"
    echo "  cd moat/studio/data-standard-service-parent/data-standard-service"
    echo "  mvn spring-boot:run -Dspring-boot.run.jvmArguments=\"--add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED\""
    echo ""
    echo "方式2: 使用Java命令启动"
    echo "  java --add-opens=java.base/java.lang.reflect=ALL-UNNAMED \\"
    echo "       --add-opens=java.base/java.lang=ALL-UNNAMED \\"
    echo "       -jar data-standard-service.jar"
    echo ""
    exit 1
fi

echo "找到进程 PID: $PID"
echo ""

# 显示当前启动命令
echo "3. 当前启动命令："
ps -p $PID -o command= | head -1
echo ""

echo "4. 修复方案："
echo ""
echo "需要重启服务并添加以下JVM参数："
echo "  --add-opens=java.base/java.lang.reflect=ALL-UNNAMED"
echo "  --add-opens=java.base/java.lang=ALL-UNNAMED"
echo ""
echo "执行以下步骤："
echo "1. 停止当前服务: kill $PID"
echo "2. 使用修复后的启动命令重新启动服务"
echo ""

# 生成修复后的启动命令
echo "=========================================="
echo "修复后的启动命令示例："
echo "=========================================="
echo ""
echo "Maven方式："
echo "cd moat/studio/data-standard-service-parent/data-standard-service"
echo "mvn spring-boot:run -Dspring-boot.run.jvmArguments=\"--add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED\""
echo ""
echo "Java命令方式："
echo "java --add-opens=java.base/java.lang.reflect=ALL-UNNAMED \\"
echo "     --add-opens=java.base/java.lang=ALL-UNNAMED \\"
echo "     -cp target/classes:target/dependency/* \\"
echo "     cn.datax.service.data.standard.DataxStandardApplication"
echo ""

