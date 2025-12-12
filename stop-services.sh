#!/bin/bash
# 停止所有启动的AllData服务

set -e

cd "$(dirname "$0")"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log "=========================================="
log "停止AllData服务"
log "=========================================="
echo ""

# 停止通过PID文件管理的服务
if [ -d "logs" ]; then
    for pid_file in logs/*.pid; do
        if [ -f "$pid_file" ]; then
            service_name=$(basename "$pid_file" .pid)
            pid=$(cat "$pid_file")
            
            if ps -p "$pid" > /dev/null 2>&1; then
                log "停止服务: $service_name (PID: $pid)"
                kill "$pid" 2>/dev/null || true
                sleep 2
                # 如果还在运行，强制杀死
                if ps -p "$pid" > /dev/null 2>&1; then
                    kill -9 "$pid" 2>/dev/null || true
                fi
            fi
            rm -f "$pid_file"
        fi
    done
fi

# 停止占用特定端口的Java进程
for port in 8610 8611 9538 8000 8810 8811 8812 8813 8820 8821 8822 8823 8824 8825 8826 8827 8828 8096 9536; do
    pid=$(lsof -ti :$port 2>/dev/null || true)
    if [ -n "$pid" ]; then
        log "停止占用端口 $port 的进程 (PID: $pid)"
        kill "$pid" 2>/dev/null || true
        sleep 1
        if ps -p "$pid" > /dev/null 2>&1; then
            kill -9 "$pid" 2>/dev/null || true
        fi
    fi
done

log "所有服务已停止"
echo ""

