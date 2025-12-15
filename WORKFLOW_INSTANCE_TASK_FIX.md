# 流程实例和任务列表显示问题修复

## 问题描述
流程实例和任务列表界面不显示任何内容。

## 问题分析

### 1. 任务接口认证问题
- **问题**: 任务接口 (`/workflow/tasks/pageTodo`, `/workflow/tasks/pageDone`) 返回错误："找不到当前登录的信息"
- **原因**: `WorkflowTaskServiceImpl` 使用了 `SecurityUtils.getCurrentUsername()`，该方法依赖于 Spring Security 的 `SecurityContextHolder`，但系统实际使用 JWT token 认证
- **解决方案**: 将 `SecurityUtils` 替换为 `SecurityUtil`，后者支持从请求头获取 JWT token

### 2. 流程实例接口认证问题
- **问题**: "我发起的流程实例" 和 "我参与的流程实例" 接口也需要用户认证
- **原因**: 同样使用了 `SecurityUtils.getCurrentUsername()`
- **解决方案**: 同样替换为 `SecurityUtil`

## 修复内容

### 修改文件

1. **WorkflowTaskServiceImpl.java**
   - 将 `import cn.datax.common.utils.SecurityUtils;` 改为 `import cn.datax.common.utils.SecurityUtil;`
   - 将 `SecurityUtils.getCurrentUsername()` 改为 `SecurityUtil.getCurrentUsername()`（2处）

2. **WorkflowInstanceServiceImpl.java**
   - 将 `import cn.datax.common.utils.SecurityUtils;` 改为 `import cn.datax.common.utils.SecurityUtil;`
   - 将 `SecurityUtils.getCurrentUsername()` 改为 `SecurityUtil.getCurrentUsername()`（2处）

## 技术说明

### SecurityUtils vs SecurityUtil

- **SecurityUtils** (带s):
  - 依赖于 Spring Security 的 `SecurityContextHolder`
  - 期望从 `Authentication` 中获取 `UserDetails`
  - 适用于使用 Spring Security 认证机制的系统

- **SecurityUtil** (不带s):
  - 从 HTTP 请求头 `Authorization` 中获取 JWT token
  - 使用 `JwtUtil.getTokenSubjectObject()` 解析 token
  - 适用于使用 JWT token 认证的系统

## 测试结果

### 编译状态
```
BUILD SUCCESS
Total time: 11.524 s
```

### 服务状态
- 服务已重新编译并重启
- PID: 待确认
- 端口: 8810

## 下一步操作

1. **验证前端访问**
   - 刷新前端页面
   - 访问"待办任务"页面，应该能正常显示（如果有任务数据）
   - 访问"已办任务"页面，应该能正常显示（如果有任务数据）
   - 访问"我发起的流程实例"页面，应该能正常显示（如果有实例数据）
   - 访问"我参与的流程实例"页面，应该能正常显示（如果有实例数据）

2. **如果仍然显示空白**
   - 检查浏览器控制台是否有错误
   - 检查网络请求是否成功（状态码200）
   - 确认是否有实际的任务或实例数据
   - 检查前端代码是否正确处理空数据情况

## 注意事项

- 如果系统中没有流程实例或任务数据，列表会显示为空，这是正常的
- 需要先创建流程定义并启动流程实例，才会有数据显示
- 任务列表需要当前登录用户有分配的任务才会显示数据

## 相关文件

- `moat/studio/data-system-service-parent/data-system-service/src/main/java/cn/datax/service/system/service/impl/WorkflowTaskServiceImpl.java`
- `moat/studio/data-system-service-parent/data-system-service/src/main/java/cn/datax/service/system/service/impl/WorkflowInstanceServiceImpl.java`
- `moat/common/common-core/src/main/java/cn/datax/common/utils/SecurityUtil.java`
- `moat/common/common-core/src/main/java/cn/datax/common/utils/SecurityUtils.java`

