# 数据大屏和数据看板显示问题修复

## 问题分析

1. **数据库连接数过多**：导致 dataParser API 返回 "Too many connections" 错误
2. **前端缺少错误处理**：当 dataParser API 失败时，图表一直处于 loading 状态，不显示任何内容

## 修复内容

### 1. 前端错误处理修复

#### 数据看板 (`DataBoardView.vue`)
- ✅ 添加了 `.catch()` 错误处理
- ✅ API失败时停止loading并显示错误信息
- ✅ 在界面上显示错误提示

#### 数据大屏 (`DataScreenView.vue`)
- ✅ 添加了 `.catch()` 错误处理
- ✅ API失败时停止loading并显示错误信息
- ✅ 在界面上显示错误提示

### 2. 数据库连接优化

- ✅ 重启MySQL服务
- ✅ 增加最大连接数到500

## 修改的文件

1. `moat_ui/src/views/visual/databoard/DataBoardView.vue`
2. `moat_ui/src/views/visual/datascreen/DataScreenView.vue`

## 测试验证

修复后：
1. 刷新浏览器页面
2. 打开数据大屏或数据看板
3. 如果数据加载失败，会显示错误信息而不是一直loading
4. 如果数据库连接正常，图表应该能正常显示

## 后续建议

1. **优化数据库连接池配置**：检查各服务的数据库连接池配置，避免连接泄漏
2. **监控数据库连接数**：定期检查连接数使用情况
3. **检查数据集配置**：确保测试样例中使用的数据集ID存在且可访问

