#!/bin/bash

# DataX 安装脚本
# 适用于 macOS 系统

set -e

DATAX_HOME="$HOME/datax"
DATAX_DIR="$DATAX_HOME/datax"

echo "=========================================="
echo "DataX 安装脚本"
echo "=========================================="

# 创建目录
echo "1. 创建目录结构..."
mkdir -p "$DATAX_DIR"/{bin,lib,conf,job,job-log,log}
echo "✓ 目录创建完成"

# 复制datax.py脚本
echo "2. 配置datax.py脚本..."
if [ -f "/Users/andyapple/Documents/Coding/alldata/moat/studio/service-data-dts-parent/service-data-dts/src/main/shell/datax.py" ]; then
    cp "/Users/andyapple/Documents/Coding/alldata/moat/studio/service-data-dts-parent/service-data-dts/src/main/shell/datax.py" "$DATAX_DIR/bin/datax.py"
    chmod +x "$DATAX_DIR/bin/datax.py"
    echo "✓ datax.py脚本已配置"
else
    echo "⚠ 未找到项目中的datax.py脚本"
fi

# 检查DataX是否已安装
echo "3. 检查DataX安装..."
if [ -d "$DATAX_HOME/DataX" ] && [ -f "$DATAX_HOME/DataX/core/src/main/bin/datax.py" ]; then
    echo "✓ 找到DataX源码"
    
    # 尝试编译DataX核心模块
    echo "4. 编译DataX核心模块..."
    cd "$DATAX_HOME/DataX"
    export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
    
    # 只编译core和common模块
    if mvn clean package -DskipTests -pl core,common -am 2>&1 | tail -5 | grep -q "BUILD SUCCESS"; then
        echo "✓ DataX核心模块编译成功"
        
        # 复制编译后的jar包
        if [ -d "core/target/datax" ]; then
            echo "5. 复制DataX文件..."
            cp -r core/target/datax/* "$DATAX_DIR/" 2>/dev/null || true
            cp core/src/main/bin/datax.py "$DATAX_DIR/bin/datax.py" 2>/dev/null || true
            chmod +x "$DATAX_DIR/bin/datax.py"
            echo "✓ DataX文件复制完成"
        fi
    else
        echo "⚠ DataX编译失败，将使用简化版本"
    fi
else
    echo "⚠ 未找到DataX源码，将使用简化版本"
fi

# 创建logback配置文件
echo "6. 创建logback配置..."
cat > "$DATAX_DIR/conf/logback.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>
    
    <root level="INFO">
        <appender-ref ref="STDOUT" />
    </root>
</configuration>
EOF
echo "✓ logback配置已创建"

# 验证安装
echo ""
echo "7. 验证安装..."
if [ -f "$DATAX_DIR/bin/datax.py" ]; then
    echo "✓ datax.py脚本存在: $DATAX_DIR/bin/datax.py"
else
    echo "✗ datax.py脚本不存在"
fi

if [ -d "$DATAX_DIR/lib" ]; then
    JAR_COUNT=$(find "$DATAX_DIR/lib" -name "*.jar" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$JAR_COUNT" -gt 0 ]; then
        echo "✓ 找到 $JAR_COUNT 个JAR文件"
    else
        echo "⚠ 未找到JAR文件，需要手动安装DataX"
    fi
else
    echo "⚠ lib目录不存在"
fi

echo ""
echo "=========================================="
echo "DataX 安装完成"
echo "=========================================="
echo "DataX路径: $DATAX_DIR"
echo "配置文件路径: $DATAX_DIR/bin/datax.py"
echo ""
echo "注意:"
echo "1. 如果JAR文件不存在，需要手动下载DataX预编译版本"
echo "2. 下载地址: https://github.com/alibaba/DataX/releases"
echo "3. 或访问: http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz"
echo "4. 解压后将lib目录复制到 $DATAX_DIR/lib"
echo ""

