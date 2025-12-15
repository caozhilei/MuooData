#!/bin/bash

# 快速推送到 GitHub
# 使用方法：
#   方式1: GITHUB_TOKEN=你的token ./快速推送.sh
#   方式2: ./快速推送.sh （会提示输入token）

set -e

REPO_URL="https://github.com/caozhilei/MuooData.git"
GITHUB_USER="caozhilei"

echo "=========================================="
echo "推送到 GitHub: caozhilei/MuooData"
echo "=========================================="
echo ""

# 如果环境变量中没有 token，提示输入
if [ -z "$GITHUB_TOKEN" ]; then
    echo "请输入你的 GitHub Personal Access Token"
    echo "（获取方法: https://github.com/settings/tokens）"
    echo ""
    read -sp "Token: " GITHUB_TOKEN
    echo ""
    echo ""
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ 未提供 Token，无法推送"
    exit 1
fi

# 使用 token 配置远程 URL
git remote set-url origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/MuooData.git"

# 获取当前分支
CURRENT_BRANCH=$(git branch --show-current)

echo "正在推送分支: $CURRENT_BRANCH"
echo ""

# 推送代码
if git push -u origin "$CURRENT_BRANCH" 2>&1; then
    # 推送成功后，将 URL 改回不包含 token 的版本（安全考虑）
    git remote set-url origin "$REPO_URL"
    echo ""
    echo "✅ 推送成功！"
    echo "访问: https://github.com/${GITHUB_USER}/MuooData"
else
    # 即使失败也移除 token
    git remote set-url origin "$REPO_URL"
    echo ""
    echo "❌ 推送失败"
    echo "请检查："
    echo "1. Token 是否正确"
    echo "2. Token 是否有 'repo' 权限"
    echo "3. 网络连接是否正常"
    exit 1
fi

