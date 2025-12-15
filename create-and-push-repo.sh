#!/bin/bash

# 自动创建 GitHub 仓库并推送代码
# 使用方法：./create-and-push-repo.sh

set -e

REPO_NAME="MuooData"
GITHUB_USER="caozhilei"

echo "=========================================="
echo "创建 GitHub 仓库并推送代码"
echo "=========================================="
echo ""

# 检查是否提供了 token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "请提供 GitHub Personal Access Token"
    echo ""
    echo "获取 Token 的方法："
    echo "1. 访问: https://github.com/settings/tokens"
    echo "2. 点击 'Generate new token' -> 'Generate new token (classic)'"
    echo "3. 权限选择: repo (完整仓库权限)"
    echo "4. 复制生成的 token"
    echo ""
    read -sp "请输入你的 GitHub Token: " GITHUB_TOKEN
    echo ""
    echo ""
fi

# 检查仓库是否已存在
echo "检查仓库是否已存在..."
REPO_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_USER/$REPO_NAME" 2>/dev/null || echo "000")

if [ "$REPO_EXISTS" = "200" ]; then
    echo "✅ 仓库已存在，跳过创建步骤"
else
    echo "创建新仓库: $GITHUB_USER/$REPO_NAME"
    
    # 创建仓库
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/user/repos" \
        -d "{\"name\":\"$REPO_NAME\",\"private\":false,\"auto_init\":false}" 2>/dev/null)
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "201" ]; then
        echo "✅ 仓库创建成功！"
    elif [ "$HTTP_CODE" = "422" ]; then
        echo "⚠️  仓库可能已存在，继续推送..."
    else
        echo "❌ 创建仓库失败 (HTTP $HTTP_CODE)"
        echo "响应: $BODY"
        exit 1
    fi
fi

echo ""
echo "开始推送代码..."

# 确保远程仓库配置正确
git remote set-url origin https://$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO_NAME.git

# 推送代码
if git push -u origin master 2>&1; then
    echo ""
    echo "✅ 推送成功！"
    echo "访问: https://github.com/$GITHUB_USER/$REPO_NAME"
else
    echo ""
    echo "❌ 推送失败"
    echo ""
    echo "请尝试以下方式："
    echo "1. 使用 SSH 方式（需要先添加 SSH 公钥到 GitHub）"
    echo "2. 或者手动在 GitHub 网页上创建仓库后推送"
    exit 1
fi

