#!/bin/bash
# 验证数据资产服务的数据管理接口是否正常

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
GATEWAY_URL="http://localhost:9538"
MASTERDATA_SERVICE_URL="http://localhost:8828"
BASE_API_URL="${GATEWAY_URL}/data/masterdata"

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 打印函数
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# 检查服务是否运行
check_service() {
    print_header "检查服务状态"
    
    # 检查网关
    if curl -s -f "${GATEWAY_URL}/actuator/health" > /dev/null 2>&1; then
        print_success "网关服务 (${GATEWAY_URL}) 运行正常"
    else
        print_info "网关健康检查端点不可用，尝试直接检查端口..."
        if lsof -i :9538 > /dev/null 2>&1; then
            print_success "网关端口 9538 正在监听"
        else
            print_error "网关服务未运行"
            return 1
        fi
    fi
    
    # 检查数据资产服务
    if lsof -i :8828 > /dev/null 2>&1; then
        print_success "数据资产服务端口 8828 正在监听"
    else
        print_error "数据资产服务未运行"
        return 1
    fi
}

# 测试接口
test_api() {
    local method=$1
    local url=$2
    local data=$3
    local description=$4
    local expect_business_success=${5:-false}  # 是否期望业务逻辑成功
    
    print_info "测试: ${description}"
    print_info "请求: ${method} ${url}"
    
    if [ -n "$data" ]; then
        print_info "数据: ${data}"
        response=$(curl -s -w "\n%{http_code}" -X ${method} \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -d "${data}" \
            "${url}" 2>&1)
    else
        response=$(curl -s -w "\n%{http_code}" -X ${method} \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            "${url}" 2>&1)
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    # 检查HTTP状态码
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        # 检查业务逻辑是否成功
        business_success=$(echo "$body" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null || echo "false")
        
        if [ "$business_success" = "True" ] || [ "$business_success" = "true" ]; then
            print_success "${description} (HTTP ${http_code}, 业务成功)"
            echo "$body" | python3 -m json.tool 2>/dev/null | head -30 || echo "$body" | head -30
            return 0
        else
            # HTTP成功但业务失败
            if [ "$expect_business_success" = "true" ]; then
                print_error "${description} (HTTP ${http_code}, 但业务逻辑失败)"
                echo "$body" | python3 -m json.tool 2>/dev/null | head -30 || echo "$body" | head -30
                return 1
            else
                # 不期望业务成功，只检查接口可访问性
                print_success "${description} (HTTP ${http_code}, 接口可访问)"
                error_msg=$(echo "$body" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('msg', ''))" 2>/dev/null || echo "")
                if [ -n "$error_msg" ]; then
                    print_info "业务错误信息: ${error_msg}"
                fi
                echo "$body" | python3 -m json.tool 2>/dev/null | head -20 || echo "$body" | head -20
                return 0
            fi
        fi
    elif [ "$http_code" -eq 401 ] || [ "$http_code" -eq 403 ]; then
        print_info "${description} - 需要认证 (HTTP ${http_code})，这是正常的"
        return 0
    else
        print_error "${description} (HTTP ${http_code})"
        echo "响应: $body" | head -10
        return 1
    fi
}

# 获取模型列表
get_models() {
    print_header "获取数据模型列表"
    
    response=$(curl -s -w "\n%{http_code}" -X GET \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        "${BASE_API_URL}/models/list" 2>&1)
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        print_success "获取模型列表成功 (HTTP ${http_code})"
        # 尝试提取第一个模型ID
        model_id=$(echo "$body" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('data', [{}])[0].get('id', ''))" 2>/dev/null || echo "")
        if [ -n "$model_id" ] && [ "$model_id" != "None" ]; then
            echo "找到模型ID: $model_id"
            echo "$model_id" > /tmp/masterdata_model_id.txt
            return 0
        else
            print_info "未找到可用的模型ID，将使用测试ID"
            echo "test_model_id" > /tmp/masterdata_model_id.txt
            return 0
        fi
    elif [ "$http_code" -eq 401 ] || [ "$http_code" -eq 403 ]; then
        print_info "获取模型列表需要认证 (HTTP ${http_code})"
        echo "test_model_id" > /tmp/masterdata_model_id.txt
        return 0
    else
        print_error "获取模型列表失败 (HTTP ${http_code})"
        echo "响应: $body" | head -10
        echo "test_model_id" > /tmp/masterdata_model_id.txt
        return 1
    fi
}

# 主测试流程
main() {
    print_header "数据资产服务 - 数据管理接口验证"
    echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # 检查服务
    if ! check_service; then
        print_error "服务检查失败，请确保服务已启动"
        exit 1
    fi
    
    # 获取模型ID
    get_models
    MODEL_ID=$(cat /tmp/masterdata_model_id.txt 2>/dev/null || echo "test_model_id")
    print_info "使用模型ID: ${MODEL_ID}"
    
    # 测试数据管理接口
    print_header "测试数据管理接口"
    
    # 1. 测试分页查询接口
    PAGE_DATA=$(cat <<EOF
{
    "pageNum": 1,
    "pageSize": 10,
    "tableName": "dynamic_test"
}
EOF
)
    test_api "POST" "${BASE_API_URL}/datas/page" "${PAGE_DATA}" "分页查询数据" false
    
    # 2. 测试获取数据详情接口（使用测试ID）
    test_api "GET" "${BASE_API_URL}/datas/test_data_id?tableName=dynamic_test" "" "获取数据详情" false
    
    # 3. 测试添加数据接口
    ADD_DATA=$(cat <<EOF
{
    "tableName": "dynamic_test",
    "datas": {
        "id": "test_$(date +%s)",
        "name": "测试数据",
        "status": "1"
    }
}
EOF
)
    test_api "POST" "${BASE_API_URL}/datas/addData" "${ADD_DATA}" "添加数据" false
    
    # 4. 测试更新数据接口
    UPDATE_DATA=$(cat <<EOF
{
    "tableName": "dynamic_test",
    "datas": {
        "id": "test_data_id",
        "name": "更新后的测试数据",
        "status": "1"
    }
}
EOF
)
    test_api "PUT" "${BASE_API_URL}/datas/updateData/test_data_id" "${UPDATE_DATA}" "更新数据" false
    
    # 5. 测试删除数据接口
    DELETE_DATA=$(cat <<EOF
{
    "tableName": "dynamic_test"
}
EOF
)
    test_api "POST" "${BASE_API_URL}/datas/delData/test_data_id" "${DELETE_DATA}" "删除数据" false
    
    # 测试直接访问服务（不通过网关）
    print_header "测试直接访问服务接口"
    test_api "GET" "${MASTERDATA_SERVICE_URL}/models/list" "" "直接访问模型列表接口" false
    
    # 测试健康检查
    print_header "测试服务健康状态"
    test_api "GET" "${MASTERDATA_SERVICE_URL}/actuator/health" "" "服务健康检查" false || print_info "健康检查端点可能不存在，这是正常的"
    
    # 清理临时文件
    rm -f /tmp/masterdata_model_id.txt
    
    # 输出测试结果
    print_header "测试结果汇总"
    echo "总测试数: ${TOTAL_TESTS}"
    echo -e "${GREEN}通过: ${PASSED_TESTS}${NC}"
    echo -e "${RED}失败: ${FAILED_TESTS}${NC}"
    echo "结束时间: $(date '+%Y-%m-%d %H:%M:%S')"
    
    if [ ${FAILED_TESTS} -eq 0 ]; then
        echo ""
        print_success "所有接口测试通过！"
        exit 0
    else
        echo ""
        print_error "部分接口测试失败，请检查日志"
        exit 1
    fi
}

# 运行主函数
main "$@"

