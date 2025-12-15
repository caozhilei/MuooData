#!/bin/bash

# 数据标准服务检查脚本
# 用于诊断数据标准模块无法加载数据的问题

echo "=========================================="
echo "数据标准服务诊断脚本"
echo "=========================================="
echo ""

# 1. 检查数据库表是否存在
echo "1. 检查数据库表..."
mysql -u root -p -e "
USE alldata;
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN CONCAT('✓ standard_type 表存在，有 ', COUNT(*), ' 条记录')
        ELSE '✗ standard_type 表不存在或为空'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'alldata' AND table_name = 'standard_type';

SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN CONCAT('✓ standard_contrast 表存在，有 ', COUNT(*), ' 条记录')
        ELSE '✗ standard_contrast 表不存在或为空'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'alldata' AND table_name = 'standard_contrast';

SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN CONCAT('✓ standard_dict 表存在，有 ', COUNT(*), ' 条记录')
        ELSE '✗ standard_dict 表不存在或为空'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'alldata' AND table_name = 'standard_dict';

SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN CONCAT('✓ standard_contrast_dict 表存在，有 ', COUNT(*), ' 条记录')
        ELSE '✗ standard_contrast_dict 表不存在或为空'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'alldata' AND table_name = 'standard_contrast_dict';
" 2>/dev/null || echo "✗ 无法连接数据库，请检查数据库配置"

echo ""
echo "2. 检查数据标准类别数据..."
mysql -u root -p -e "
USE alldata;
SELECT COUNT(*) as '启用状态的数据标准类别数量' FROM standard_type WHERE status = 1;
SELECT id, gb_type_code, gb_type_name, status FROM standard_type WHERE status = 1 LIMIT 10;
" 2>/dev/null || echo "✗ 无法查询数据"

echo ""
echo "3. 检查对照表数据..."
mysql -u root -p -e "
USE alldata;
SELECT COUNT(*) as '启用状态的对照表数量' FROM standard_contrast WHERE status = 1;
SELECT id, source_name, table_name, column_name FROM standard_contrast WHERE status = 1 LIMIT 10;
" 2>/dev/null || echo "✗ 无法查询数据"

echo ""
echo "4. 检查服务状态..."
echo "请检查以下服务是否运行："
echo "  - service-data-standard (数据标准服务)"
echo "  - service-gateway (网关服务)"
echo ""
echo "可以使用以下命令检查："
echo "  docker ps | grep standard"
echo "  或"
echo "  ps aux | grep data-standard"

echo ""
echo "5. 检查API接口..."
echo "请访问以下URL测试接口："
echo "  http://localhost:9999/data/standard/types/list"
echo "  http://localhost:9999/data/standard/contrasts/tree"
echo ""
echo "如果接口返回404，请检查："
echo "  1. 网关服务是否启动"
echo "  2. 数据标准服务是否注册到注册中心"
echo "  3. 网关路由配置是否正确"

echo ""
echo "=========================================="
echo "诊断完成"
echo "=========================================="
echo ""
echo "如果表不存在，请运行："
echo "  mysql -u root -p alldata < init-standard-tables.sql"
echo ""

