# GitHub 发布指南 - MuooData

## 当前状态

✅ 已完成：
- 所有更改已提交到本地仓库
- 远程仓库 URL 已更新为：`https://github.com/caozhilei/MuooData.git`

## 下一步操作

### 步骤 1：在 GitHub 上创建仓库

1. 访问 https://github.com/new
2. 仓库名称填写：`MuooData`
3. 选择 Public 或 Private（根据你的需求）
4. **不要**初始化 README、.gitignore 或 license（因为本地已有代码）
5. 点击 "Create repository"

### 步骤 2：配置身份验证（选择一种方式）

#### 方式 A：使用 SSH（推荐）

1. **生成 SSH 密钥**（如果还没有）：
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# 按回车使用默认路径，可以设置密码或留空
```

2. **添加 SSH 密钥到 ssh-agent**：
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

3. **复制公钥**：
```bash
cat ~/.ssh/id_ed25519.pub
```

4. **添加到 GitHub**：
   - 访问 https://github.com/settings/keys
   - 点击 "New SSH key"
   - 粘贴公钥内容
   - 点击 "Add SSH key"

5. **更新远程仓库为 SSH 地址**：
```bash
cd /Users/andyapple/Documents/Coding/alldata
git remote set-url origin git@github.com:andyapple/MuooData.git
git push -u origin master
```

#### 方式 B：使用 Personal Access Token（HTTPS）

1. **创建 Personal Access Token**：
   - 访问 https://github.com/settings/tokens
   - 点击 "Generate new token" -> "Generate new token (classic)"
   - 设置过期时间和权限（至少需要 `repo` 权限）
   - 复制生成的 token（只显示一次，请保存好）

2. **推送代码**：
```bash
cd /Users/andyapple/Documents/Coding/alldata
git push -u origin master
# 用户名：andyapple
# 密码：粘贴你的 Personal Access Token
```

### 步骤 3：验证

推送成功后，访问 https://github.com/andyapple/MuooData 查看你的代码。

## 注意事项

- 如果仓库已存在但为空，直接推送即可
- 如果仓库已存在且有内容，可能需要先拉取：`git pull origin master --allow-unrelated-histories`
- 建议添加 `.gitignore` 文件来忽略不必要的文件（如 `node_modules/`, `target/`, `*.log` 等）

