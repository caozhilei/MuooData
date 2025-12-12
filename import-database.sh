#!/bin/bash
# 导入 AllData 数据库脚本到 Docker 中的 MySQL

set -e

echo "=========================================="
echo "导入 AllData 数据库脚本"
echo "=========================================="

# 数据库配置
DB_CONTAINER="alldata-mysql"
DB_NAME="alldata"
DB_USER="root"
DB_PASSWORD="123456"
SQL_DIR="$(cd "$(dirname "$0")/install/sql" && pwd)"

# 检查数据库容器是否运行
if ! docker ps --format "{{.Names}}" | grep -q "^${DB_CONTAINER}$"; then
    echo "错误: 数据库容器 ${DB_CONTAINER} 未运行"
    echo "请先启动数据库容器: docker start ${DB_CONTAINER}"
    exit 1
fi

echo "数据库容器: ${DB_CONTAINER}"
echo "数据库名: ${DB_NAME}"
echo "SQL 脚本目录: ${SQL_DIR}"
echo ""

# 检查 SQL 文件是否存在
SQL_FILES=(
    "alldata-install.sql"
    "alldata-v0.6.1.sql"
    "alldata-v0.6.2.sql"
    "alldata-v0.6.3.sql"
    "alldata-v0.6.4.sql"
)

for sql_file in "${SQL_FILES[@]}"; do
    if [ ! -f "${SQL_DIR}/${sql_file}" ]; then
        echo "错误: SQL 文件不存在: ${SQL_DIR}/${sql_file}"
        exit 1
    fi
done

# 检查是否需要清空数据库（默认清空）
CLEAR_DB=true
SKIP_CONFIRM=false

# 解析命令行参数
for arg in "$@"; do
    case $arg in
        --no-clear|-n)
            CLEAR_DB=false
            shift
            ;;
        --yes|-y)
            SKIP_CONFIRM=true
            shift
            ;;
        *)
            ;;
    esac
done

if [ "$CLEAR_DB" = true ] && [ "$SKIP_CONFIRM" = false ]; then
    echo "警告: 将清空数据库 ${DB_NAME} 的所有数据！"
    if [ -t 0 ]; then
        # 交互式终端
        read -p "确认继续? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            echo "已取消操作"
            exit 0
        fi
    else
        # 非交互式环境，默认继续
        echo "非交互式环境，将自动清空数据库..."
    fi
    echo ""
fi

echo "开始导入数据库脚本..."
echo ""

# 等待数据库就绪
echo "等待数据库就绪..."
for i in {1..30}; do
    if docker exec ${DB_CONTAINER} mysqladmin ping -h localhost -u${DB_USER} -p${DB_PASSWORD} --silent 2>/dev/null; then
        echo "数据库已就绪"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "错误: 数据库未就绪，请检查容器状态"
        exit 1
    fi
    sleep 1
done

echo ""

# 如果需要，先清空数据库
if [ "$CLEAR_DB" = true ]; then
    echo "=========================================="
    echo "清空数据库 ${DB_NAME}..."
    echo "=========================================="
    
    # 删除并重新创建数据库
    docker exec -i -e MYSQL_PWD=${DB_PASSWORD} ${DB_CONTAINER} \
        mysql -u${DB_USER} -e "DROP DATABASE IF EXISTS ${DB_NAME}; CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✓ 数据库已清空并重新创建"
    else
        echo "✗ 清空数据库失败"
        exit 1
    fi
    echo ""
fi

# 按顺序导入 SQL 文件
for sql_file in "${SQL_FILES[@]}"; do
    echo "=========================================="
    echo "正在导入: ${sql_file}"
    echo "=========================================="
    
    # 使用管道方式导入 SQL 文件
    # 将文件内容通过管道传递给容器内的 mysql 命令
    # 使用 MYSQL_PWD 环境变量避免密码在命令行中暴露
    OUTPUT=$(docker exec -i -e MYSQL_PWD=${DB_PASSWORD} ${DB_CONTAINER} \
        mysql -u${DB_USER} ${DB_NAME} < "${SQL_DIR}/${sql_file}" 2>&1)
    
    EXIT_CODE=$?
    
    # 过滤掉 "Using a password" 警告信息
    CLEAN_OUTPUT=$(echo "$OUTPUT" | grep -v "Using a password" || true)
    
    # 检查是否有错误
    if echo "$CLEAN_OUTPUT" | grep -qi "ERROR"; then
        ERROR_MSG=$(echo "$CLEAN_OUTPUT" | grep -i "ERROR" | head -1)
        # 检查是否是已知的可忽略错误
        if echo "$ERROR_MSG" | grep -qiE "(already exists|Duplicate.*constraint|Duplicate.*key|Duplicate foreign key)"; then
            echo "⚠ ${sql_file} 导入完成（有警告但可忽略）:"
            echo "  $ERROR_MSG"
        else
            echo "✗ ${sql_file} 导入失败:"
            echo "$CLEAN_OUTPUT" | grep -i "ERROR"
            exit 1
        fi
    elif [ $EXIT_CODE -eq 0 ]; then
        echo "✓ ${sql_file} 导入成功"
    else
        echo "✗ ${sql_file} 导入失败（退出码: ${EXIT_CODE}）"
        if [ -n "$CLEAN_OUTPUT" ]; then
            echo "$CLEAN_OUTPUT"
        fi
        exit 1
    fi
    
    echo ""
done

echo "=========================================="
echo "✓ 所有数据库脚本导入完成！"
echo "=========================================="
echo ""

# 验证数据库
TABLE_COUNT=$(docker exec -e MYSQL_PWD=${DB_PASSWORD} ${DB_CONTAINER} \
    mysql -u${DB_USER} ${DB_NAME} -Nse "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '${DB_NAME}';" 2>/dev/null || echo "0")

echo "数据库信息:"
echo "  数据库名: ${DB_NAME}"
echo "  容器名: ${DB_CONTAINER}"
echo "  表数量: ${TABLE_COUNT}"
echo ""
echo "可以验证数据库:"
echo "  docker exec -it ${DB_CONTAINER} mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e 'SHOW TABLES;'"
echo ""
echo "或者查看表数量:"
echo "  docker exec -e MYSQL_PWD=${DB_PASSWORD} ${DB_CONTAINER} mysql -u${DB_USER} ${DB_NAME} -e 'SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = \"${DB_NAME}\";'"
