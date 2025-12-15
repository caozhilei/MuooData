#!/bin/bash

# 测试数据标准API接口的脚本

echo "=========================================="
echo "测试数据标准API接口"
echo "=========================================="
echo ""

# 检查网关是否可访问
echo "1. 检查网关服务..."
if curl -s http://localhost:9999/actuator/health > /dev/null 2>&1; then
    echo "✓ 网关服务可访问"
else
    echo "✗ 网关服务不可访问 (http://localhost:9999)"
    echo "  请确保网关服务已启动"
    exit 1
fi

echo ""
echo "2. 测试数据标准类别接口..."
echo "请求: GET http://localhost:9999/data/standard/types/list"
echo ""

# 注意：这里需要token，如果没有token会返回401
response=$(curl -s -w "\nHTTP_CODE:%{http_code}" http://localhost:9999/data/standard/types/list)
http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_CODE/d')

if [ "$http_code" = "200" ]; then
    echo "✓ 接口返回200"
    echo "响应内容:"
    echo "$body" | head -20
elif [ "$http_code" = "401" ]; then
    echo "⚠ 接口返回401 (需要认证token)"
    echo "这是正常的，说明接口存在但需要登录"
elif [ "$http_code" = "404" ]; then
    echo "✗ 接口返回404 (未找到)"
    echo "可能原因："
    echo "  1. 数据标准服务未启动"
    echo "  2. 服务未注册到注册中心"
    echo "  3. 网关路由配置错误"
else
    echo "✗ 接口返回 $http_code"
    echo "响应内容:"
    echo "$body" | head -10
fi

echo ""
echo "3. 测试对照表树接口..."
echo "请求: GET http://localhost:9999/data/standard/contrasts/tree"
echo ""

response=$(curl -s -w "\nHTTP_CODE:%{http_code}" http://localhost:9999/data/standard/contrasts/tree)
http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_CODE/d')

if [ "$http_code" = "200" ]; then
    echo "✓ 接口返回200"
    echo "响应内容:"
    echo "$body" | head -20
elif [ "$http_code" = "401" ]; then
    echo "⚠ 接口返回401 (需要认证token)"
    echo "这是正常的，说明接口存在但需要登录"
elif [ "$http_code" = "404" ]; then
    echo "✗ 接口返回404 (未找到)"
    echo "可能原因："
    echo "  1. 数据标准服务未启动"
    echo "  2. 服务未注册到注册中心"
    echo "  3. 网关路由配置错误"
else
    echo "✗ 接口返回 $http_code"
    echo "响应内容:"
    echo "$body" | head -10
fi

echo ""
echo "=========================================="
echo "测试完成"
echo "=========================================="
echo ""
echo "如果接口返回401，这是正常的，说明："
echo "  1. 接口存在且可访问"
echo "  2. 需要在前端登录后使用token访问"
echo ""
echo "如果接口返回404，请检查："
echo "  1. 数据标准服务是否启动"
echo "  2. 查看服务日志: docker logs <service-container-id>"
echo "  3. 检查Eureka注册中心: http://localhost:8761"

