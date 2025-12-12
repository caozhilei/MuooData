#!/bin/bash
# 使用Java 8构建业务服务脚本（不包括基础服务 eureka, gateway, config）

set -e

cd "$(dirname "$0")"

echo "=========================================="
echo "本地构建AllData业务服务（Java 8，不包括基础服务）"
echo "=========================================="

# 检查Java 8
JAVA8_HOME=""
if [ -d "/Library/Java/JavaVirtualMachines" ]; then
    # 查找所有可能的 Java 8 安装
    for jdk in /Library/Java/JavaVirtualMachines/*; do
        if [[ "$jdk" =~ "temurin-8" ]] || [[ "$jdk" =~ "temurin@8" ]] || \
           [[ "$jdk" =~ "jdk-8" ]] || [[ "$jdk" =~ "jdk1.8" ]] || \
           [[ "$jdk" =~ "1.8" ]] || [[ "$jdk" =~ "8.jdk" ]]; then
            if [ -d "$jdk/Contents/Home" ]; then
                JAVA8_HOME="$jdk/Contents/Home"
                # 验证是否为 Java 8
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

# 如果环境变量已设置，优先使用
if [ -n "$JAVA8_HOME_ENV" ] && [ -d "$JAVA8_HOME_ENV" ]; then
    JAVA8_HOME="$JAVA8_HOME_ENV"
fi

if [ -z "$JAVA8_HOME" ] || [ ! -d "$JAVA8_HOME" ]; then
    echo "错误: 未找到Java 8安装"
    echo "请安装Java 8或设置JAVA8_HOME环境变量"
    echo ""
    echo "可以使用以下命令安装Java 8:"
    echo "  brew install --cask temurin@8"
    exit 1
fi

echo "使用Java 8: $JAVA8_HOME"
export JAVA_HOME="$JAVA8_HOME"
export PATH="$JAVA_HOME/bin:$PATH"

# 设置代理环境变量
export HTTP_PROXY="http://127.0.0.1:7890"
export HTTPS_PROXY="http://127.0.0.1:7890"
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"

# 使用Maven settings文件（如果存在）
MAVEN_SETTINGS=""
PROJECT_ROOT="$(pwd)"
if [ -f "$PROJECT_ROOT/maven-settings-local.xml" ]; then
    MAVEN_SETTINGS="-s $PROJECT_ROOT/maven-settings-local.xml"
    echo "使用 Maven settings: $PROJECT_ROOT/maven-settings-local.xml"
fi

echo "Java版本:"
java -version

# 检查Maven
if ! command -v mvn &> /dev/null; then
    echo "错误: 未找到Maven，请先安装Maven"
    exit 1
fi

echo ""
echo "Maven版本:"
mvn --version | head -1
echo ""

# 第一步: 安装根POM和moat POM
echo "=========================================="
echo "第一步: 安装根POM (alldata) 和 moat POM..."
echo "=========================================="
mvn $MAVEN_SETTINGS clean install -N -DskipTests || exit 1
cd moat
mvn $MAVEN_SETTINGS clean install -N -DskipTests || exit 1
cd ..

# 第二步: 安装common-service-api（其他模块依赖它）
echo ""
echo "=========================================="
echo "第二步: 安装common-service-api..."
echo "=========================================="
cd moat/common/common-service-api
mvn $MAVEN_SETTINGS clean install -DskipTests || exit 1
cd ../../..

# 第三步: 安装generic模块
echo ""
echo "=========================================="
echo "第三步: 安装generic模块..."
echo "=========================================="
cd moat/generic
mvn $MAVEN_SETTINGS clean install -DskipTests || exit 1
cd ../..

# 第四步: 构建common模块（处理循环依赖）
echo ""
echo "=========================================="
echo "第四步: 构建common模块..."
echo "=========================================="
cd moat/common
mvn $MAVEN_SETTINGS clean install -DskipTests || exit 1
cd ../..

# 第五步: 安装logging模块
echo ""
echo "=========================================="
echo "第五步: 安装logging模块..."
echo "=========================================="
cd moat/logging
mvn $MAVEN_SETTINGS clean install -DskipTests || exit 1
cd ../..

# 第六步: 安装box模块
echo ""
echo "=========================================="
echo "第六步: 安装box模块..."
echo "=========================================="
cd moat/box
mvn $MAVEN_SETTINGS clean install -DskipTests || exit 1
cd ../..

# 第七步: 构建所有业务服务（studio目录下的服务）
echo ""
echo "=========================================="
echo "第七步: 构建所有业务服务..."
echo "=========================================="
cd moat/studio

# 业务服务列表（按依赖顺序）
BUSINESS_SERVICES=(
    "system-service-parent"
    "data-system-service-parent"
    "email-service-parent"
    "file-service-parent"
    "quartz-service-parent"
    "data-compare-service-parent"
    "data-market-service-parent"
    "data-masterdata-service-parent"
    "data-metadata-service-parent"
    "data-quality-service-parent"
    "data-standard-service-parent"
    "data-visual-service-parent"
    "service-data-dts-parent"
)

SUCCESS_COUNT=0
FAILED_COUNT=0
FAILED_SERVICES=()

for service in "${BUSINESS_SERVICES[@]}"; do
    if [ -d "$service" ]; then
        echo ""
        echo "----------------------------------------"
        echo "构建 $service..."
        echo "----------------------------------------"
        cd "$service"
        
        if mvn $MAVEN_SETTINGS clean package -DskipTests 2>&1; then
            echo "✓ $service 构建成功"
            ((SUCCESS_COUNT++))
        else
            EXIT_CODE=$?
            echo "✗ $service 构建失败（退出码: $EXIT_CODE）"
            ((FAILED_COUNT++))
            FAILED_SERVICES+=("$service")
            # 继续构建其他服务，不退出
        fi
        cd ..
    else
        echo "⚠ 跳过: $service 目录不存在"
    fi
done

cd ../..

echo ""
echo "=========================================="
echo "构建完成！"
echo "=========================================="
echo ""
echo "构建统计:"
echo "  成功: $SUCCESS_COUNT 个服务"
echo "  失败: $FAILED_COUNT 个服务"

if [ ${#FAILED_SERVICES[@]} -gt 0 ]; then
    echo ""
    echo "失败的服务:"
    for service in "${FAILED_SERVICES[@]}"; do
        echo "  - $service"
    done
    echo ""
    echo "可以单独重新构建失败的服务:"
    for service in "${FAILED_SERVICES[@]}"; do
        echo "  cd moat/studio/$service && mvn $MAVEN_SETTINGS clean package -DskipTests"
    done
fi

echo ""
echo "构建的JAR文件位置:"
for service in "${BUSINESS_SERVICES[@]}"; do
    if [ -d "moat/studio/$service" ]; then
        JAR_FILE=$(find "moat/studio/$service" -name "*.jar" -path "*/target/*" ! -name "*-sources.jar" ! -name "*-javadoc.jar" 2>/dev/null | head -1)
        if [ -n "$JAR_FILE" ]; then
            echo "  $service: $JAR_FILE"
        fi
    fi
done

if [ $FAILED_COUNT -eq 0 ]; then
    echo ""
    echo "✓ 所有业务服务构建成功！"
    exit 0
else
    echo ""
    echo "⚠ 部分服务构建失败，请检查上面的错误信息"
    exit 1
fi
