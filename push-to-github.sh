#!/bin/bash

# 推送到 GitHub 的脚本
# 使用方法：./push-to-github.sh

set -e

echo "=========================================="
echo "推送到 GitHub 仓库: MuooData"
echo "=========================================="

# 检查远程仓库配置
echo "检查远程仓库配置..."
git remote -v

# 检查当前分支
CURRENT_BRANCH=$(git branch --show-current)
echo "当前分支: $CURRENT_BRANCH"

# 检查是否有未提交的更改
if [ -n "$(git status --porcelain)" ]; then
    echo "警告: 检测到未提交的更改"
    read -p "是否先提交这些更改? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add .
        read -p "请输入提交信息: " COMMIT_MSG
        git commit -m "${COMMIT_MSG:-更新代码}"
    fi
fi

# 尝试推送
echo ""
echo "开始推送到 GitHub..."
echo ""

# 方法1: 尝试 SSH
echo "尝试使用 SSH 方式推送..."
if git push -u origin "$CURRENT_BRANCH" 2>&1 | grep -q "Permission denied"; then
    echo "SSH 方式失败，切换到 HTTPS..."
    git remote set-url origin https://github.com/andyapple/MuooData.git
    echo ""
    echo "请使用以下方式之一进行身份验证："
    echo "1. Personal Access Token (推荐)"
    echo "   - 访问: https://github.com/settings/tokens"
    echo "   - 创建新 token，权限选择 'repo'"
    echo "   - 推送时用户名: andyapple"
    echo "   - 密码: 粘贴你的 token"
    echo ""
    echo "2. 或者配置 SSH 密钥"
    echo "   - 访问: https://github.com/settings/keys"
    echo "   - 添加 SSH 公钥: ~/.ssh/id_ed25519.pub"
    echo ""
    read -p "按回车键继续推送 (将提示输入凭据)..."
    git push -u origin "$CURRENT_BRANCH"
else
    echo "✅ 推送成功！"
    echo "访问: https://github.com/andyapple/MuooData"
fi

echo ""
echo "完成！"

