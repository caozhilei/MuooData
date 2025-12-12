#!/bin/bash
# 检查业务服务启动状态

cd "$(dirname "$0")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "业务服务启动状态检查"
echo "=========================================="
echo ""

# 服务列表（端口:服务名）
declare -A SERVICES=(
    ["8810"]="Data System Service"
    ["8811"]="File Service"
    ["8812"]="Email Service"
    ["8813"]="Quartz Service"
    ["8820"]="Data Metadata Service"
    ["8821"]="Data Metadata Console"
    ["8822"]="Data Market Service"
    ["8823"]="Data Market Mapping"
    ["8824"]="Data Market Integration"
    ["8825"]="Data Standard Service"
    ["8826"]="Data Quality Service"
    ["8827"]="Data Visual Service"
    ["8828"]="Data Masterdata Service"
    ["8096"]="Data Compare Service"
    ["9536"]="Service Data DTS"
)

echo "端口检查："
echo "----------------------------------------"
for port in $(printf '%s\n' "${!SERVICES[@]}" | sort -n); do
    service_name="${SERVICES[$port]}"
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} 端口 $port: $service_name - ${GREEN}运行中${NC}"
    else
        echo -e "${RED}✗${NC} 端口 $port: $service_name - ${RED}未启动${NC}"
    fi
done

echo ""
echo "Eureka注册情况："
echo "----------------------------------------"
if curl -s http://localhost:8610/eureka/apps 2>/dev/null | grep -q "application"; then
    echo "已注册的服务："
    curl -s http://localhost:8610/eureka/apps 2>/dev/null | grep -o '<name>[^<]*</name>' | sed 's/<name>\(.*\)<\/name>/\1/' | sort | uniq | while read service; do
        echo -e "  ${GREEN}✓${NC} $service"
    done
else
    echo -e "${YELLOW}无法连接到Eureka或暂无服务注册${NC}"
fi

echo ""
echo "进程检查："
echo "----------------------------------------"
ps aux | grep -E "java.*spring-boot:run" | grep -v grep | wc -l | xargs echo "正在运行的Spring Boot服务数量:"

echo ""
echo "日志文件："
echo "----------------------------------------"
ls -lh logs/*.log 2>/dev/null | tail -10 | awk '{print $9, "(" $5 ")"}'

echo ""
echo "=========================================="

