# 流程实例页面完全空白问题排查

## 问题现象
流程实例页面完全空白，没有任何UI元素显示

## 已添加的调试日志

### 1. 组件生命周期日志
- `RunningInstance组件已创建` - 父组件创建时输出
- `RunningInstance组件已挂载` - 父组件挂载时输出
- `RunningInstanceList组件已创建` - 子组件创建时输出
- `RunningInstanceList组件已挂载` - 子组件挂载时输出，包含数据状态

### 2. API请求日志
- `流程实例列表响应:` - API的完整响应
- `流程实例数据:` - 解析后的数据对象
- `设置后的数据:` - 最终设置到页面的数据

## 排查步骤

### 步骤1: 检查浏览器控制台
1. 打开浏览器开发者工具（F12）
2. 切换到 **Console** 标签
3. 刷新页面
4. 查看是否有以下日志：
   - `RunningInstance组件已创建`
   - `RunningInstance组件已挂载`
   - `RunningInstanceList组件已创建`
   - `RunningInstanceList组件已挂载`
   - `流程实例列表响应:`

### 步骤2: 根据日志判断问题

#### 情况A: 没有任何日志输出
**可能原因**:
- 路由配置问题，组件未加载
- 页面路径错误
- 权限问题，路由被拦截

**解决方法**:
- 检查浏览器地址栏的URL是否正确
- 检查是否有权限访问该页面
- 检查路由配置

#### 情况B: 只有父组件日志，没有子组件日志
**可能原因**:
- 子组件导入失败
- 子组件有语法错误
- 组件注册问题

**解决方法**:
- 检查 `RunningInstanceList.vue` 文件是否存在
- 检查导入路径是否正确
- 查看是否有JavaScript错误

#### 情况C: 有组件日志，但没有API请求日志
**可能原因**:
- API请求失败
- 请求被拦截
- 网络问题

**解决方法**:
- 切换到 **Network** 标签
- 查找 `/workflow/instances/pageRunning` 请求
- 查看请求状态和响应

#### 情况D: 有所有日志，但页面仍空白
**可能原因**:
- CSS样式问题
- 元素被隐藏
- 渲染问题

**解决方法**:
- 检查元素是否在DOM中（Elements标签）
- 检查CSS样式
- 检查是否有错误信息

### 步骤3: 检查网络请求
1. 切换到 **Network** 标签
2. 刷新页面
3. 查找 `/workflow/instances/pageRunning` 请求
4. 检查：
   - **Status**: 应该是 200
   - **Response**: 应该包含JSON数据
   - **Request Headers**: 应该包含 `Authorization` token

### 步骤4: 检查元素
1. 切换到 **Elements** 标签
2. 查找 `<div class="app-container">` 元素
3. 检查是否有内容
4. 检查是否有 `display: none` 或其他隐藏样式

## 常见问题

### Q1: 控制台没有任何日志
**原因**: 组件未加载
**解决**: 检查路由配置和页面路径

### Q2: 控制台有错误信息
**原因**: JavaScript错误
**解决**: 根据错误信息修复代码

### Q3: API请求返回401或403
**原因**: 认证或权限问题
**解决**: 检查token是否有效，检查用户权限

### Q4: API请求返回500
**原因**: 后端服务错误
**解决**: 检查后端服务日志

## 对比流程定义页面

流程定义页面能正常显示，说明：
- ✅ 前端服务正常
- ✅ 路由系统正常
- ✅ 权限系统正常

流程实例页面空白，可能是：
- ❌ 组件加载问题
- ❌ 路由配置问题
- ❌ JavaScript错误

## 下一步操作

1. **刷新浏览器页面**（硬刷新：Ctrl+Shift+R 或 Cmd+Shift+R）
2. **打开浏览器控制台**（F12）
3. **查看Console标签**，记录所有日志
4. **查看Network标签**，检查API请求
5. **提供以下信息**：
   - 控制台中的所有日志
   - 是否有错误信息
   - Network中API请求的状态和响应

## 相关文件

- `/moat_ui/src/views/workflow/instance/running/index.vue` - 父组件
- `/moat_ui/src/views/workflow/instance/running/RunningInstanceList.vue` - 子组件
- `/moat_ui/src/api/workflow/instance.js` - API接口定义

