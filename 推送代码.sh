#!/bin/bash

# 推送到 GitHub 仓库 caozhilei/MuooData
# 使用方法：./推送代码.sh

set -e

REPO_URL="https://github.com/caozhilei/MuooData.git"
REPO_NAME="caozhilei/MuooData"

echo "=========================================="
echo "推送到 GitHub 仓库: $REPO_NAME"
echo "=========================================="
echo ""

# 确保远程仓库配置正确
git remote set-url origin "$REPO_URL"
echo "✅ 远程仓库已配置: $REPO_URL"
echo ""

# 检查当前分支
CURRENT_BRANCH=$(git branch --show-current)
echo "当前分支: $CURRENT_BRANCH"
echo ""

# 检查是否有未提交的更改
if [ -n "$(git status --porcelain)" ]; then
    echo "检测到未提交的更改，正在提交..."
    git add .
    git commit -m "更新代码 $(date '+%Y-%m-%d %H:%M:%S')"
    echo "✅ 更改已提交"
    echo ""
fi

# 显示最近的提交
echo "最近的提交："
git log --oneline -5
echo ""

# 推送代码
echo "开始推送到 GitHub..."
echo ""
echo "提示：如果提示输入用户名和密码"
echo "  - 用户名: caozhilei"
echo "  - 密码: 使用 GitHub Personal Access Token（不是账户密码）"
echo "  - 获取 Token: https://github.com/settings/tokens"
echo ""

if git push -u origin "$CURRENT_BRANCH" 2>&1; then
    echo ""
    echo "✅ 推送成功！"
    echo "访问: https://github.com/$REPO_NAME"
else
    echo ""
    echo "❌ 推送失败"
    echo ""
    echo "请尝试以下方式之一："
    echo ""
    echo "方式 1：使用 Personal Access Token"
    echo "  1. 访问: https://github.com/settings/tokens"
    echo "  2. 创建新 token，权限选择 'repo'"
    echo "  3. 推送时："
    echo "     - 用户名: caozhilei"
    echo "     - 密码: 粘贴你的 token"
    echo ""
    echo "方式 2：使用 GitHub CLI"
    echo "  gh auth login"
    echo "  git push -u origin $CURRENT_BRANCH"
    echo ""
    exit 1
fi

