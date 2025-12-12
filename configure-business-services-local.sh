#!/bin/bash
# 配置业务服务连接到Docker中的基础服务
# 将所有业务服务的eureka地址改为localhost:8610

set -e

cd "$(dirname "$0")"

echo "=========================================="
echo "配置业务服务连接到Docker基础服务"
echo "=========================================="

# 业务服务bootstrap.yml文件列表
BOOTSTRAP_FILES=(
  "moat/studio/data-compare-service-parent/data-compare-service/src/main/resources/bootstrap.yml"
  "moat/studio/data-market-service-parent/data-market-service/src/main/resources/bootstrap.yml"
  "moat/studio/data-market-service-parent/data-market-service-integration/src/main/resources/bootstrap.yml"
  "moat/studio/data-market-service-parent/data-market-service-mapping/src/main/resources/bootstrap.yml"
  "moat/studio/data-masterdata-service-parent/data-masterdata-service/src/main/resources/bootstrap.yml"
  "moat/studio/data-metadata-service-parent/data-metadata-service/src/main/resources/bootstrap.yml"
  "moat/studio/data-metadata-service-parent/data-metadata-service-console/src/main/resources/bootstrap.yml"
  "moat/studio/data-quality-service-parent/data-quality-service/src/main/resources/bootstrap.yml"
  "moat/studio/data-standard-service-parent/data-standard-service/src/main/resources/bootstrap.yml"
  "moat/studio/data-system-service-parent/data-system-service/src/main/resources/bootstrap.yml"
  "moat/studio/data-visual-service-parent/data-visual-service/src/main/resources/bootstrap.yml"
  "moat/studio/email-service-parent/email-service/src/main/resources/bootstrap.yml"
  "moat/studio/file-service-parent/file-service/src/main/resources/bootstrap.yml"
  "moat/studio/quartz-service-parent/quartz-service/src/main/resources/bootstrap.yml"
  "moat/studio/service-data-dts-parent/service-data-dts/src/main/resources/bootstrap.yml"
)

# 修改eureka地址和ip-address
for file in "${BOOTSTRAP_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "正在配置: $file"
    
    # 备份原文件
    cp "$file" "$file.bak"
    
    # 使用sed修改配置
    # 1. 将eureka地址改为localhost:8610
    sed -i '' 's|defaultZone: http://16gslave:8610/eureka|defaultZone: http://localhost:8610/eureka|g' "$file"
    
    # 2. 将ip-address改为localhost（如果存在16gmaster/16gslave/16gdata）
    sed -i '' 's|ip-address: 16gmaster|ip-address: localhost|g' "$file"
    sed -i '' 's|ip-address: 16gslave|ip-address: localhost|g' "$file"
    sed -i '' 's|ip-address: 16gdata|ip-address: localhost|g' "$file"
    
    echo "  ✓ 配置完成"
  else
    echo "  ⚠ 文件不存在: $file"
  fi
done

echo ""
echo "=========================================="
echo "配置完成！"
echo "=========================================="
echo ""
echo "已修改的业务服务配置："
echo "- Eureka地址: http://localhost:8610/eureka"
echo "- IP地址: localhost"
echo ""
echo "备份文件已保存为 *.bak"
echo ""
echo "现在可以启动业务服务了："
echo "1. 确保Docker中的基础服务已启动（eureka, config, gateway, system-service）"
echo "2. 在IDEA中运行各个业务服务的Application类"
echo ""

