# 流程编排404问题修复指南

## 问题描述
刷新页面时显示"not found"（404错误），流程编排接口返回404。

## 问题分析

### 1. 网关路由配置 ✅
- 网关路由配置已正确添加
- 请求能够正确转发到 data-system-service
- 网关日志显示：`转发请求：lb://service-data-system/workflow/categorys/list --> 目标服务：service-workflow`

### 2. 后端服务问题 ❌
- data-system-service 服务返回 404
- 直接访问 `http://localhost:8810/workflow/categorys/list` 也返回 404
- 说明 workflow 控制器可能没有被正确加载或注册

## 解决方案

### 方案1：重启 data-system-service 服务（推荐）

workflow 控制器可能需要在服务启动时才能被正确扫描和注册。

**操作步骤：**

1. **停止 data-system-service**
```bash
# 查找进程ID
ps aux | grep DataxSystemApplication | grep -v grep

# 停止服务（替换PID为实际进程ID）
kill <PID>
# 或使用端口停止
lsof -ti :8810 | xargs kill
```

2. **重新启动 data-system-service**
```bash
cd /Users/andyapple/Documents/Coding/alldata/moat/studio/data-system-service-parent/data-system-service
mvn spring-boot:run -DskipTests
```

3. **等待服务完全启动**（约30-60秒）

4. **验证服务启动**
```bash
# 检查端口
lsof -i :8810

# 检查健康状态
curl http://localhost:8810/actuator/health
```

5. **测试 workflow 接口**
```bash
# 通过网关测试
curl http://localhost:9538/workflow/categorys/list

# 直接访问服务测试
curl http://localhost:8810/workflow/categorys/list
```

### 方案2：检查控制器包扫描配置

如果重启后仍然404，检查以下配置：

1. **检查主类包路径**
   - 主类：`cn.datax.service.system.DataxSystemApplication`
   - 控制器包：`cn.datax.service.system.controller`
   - 确保控制器在主类的子包下

2. **检查是否有组件扫描配置**
   - 查看是否有 `@ComponentScan` 注解
   - 检查是否有排除某些包的配置

3. **检查 application.yml 配置**
   - 查看是否有 `spring.mvc.path-matching` 配置
   - 检查是否有 servlet context-path 配置

### 方案3：检查依赖和编译

确保 workflow 相关的类已正确编译：

```bash
cd /Users/andyapple/Documents/Coding/alldata/moat/studio/data-system-service-parent/data-system-service
mvn clean compile -DskipTests
```

## 验证步骤

1. **检查服务状态**
```bash
# 所有相关服务都应该运行
lsof -i :8610  # Eureka
lsof -i :8611  # Config
lsof -i :9538  # Gateway
lsof -i :8810  # data-system-service
```

2. **检查网关路由**
```bash
# 查看网关日志
tail -f logs/gateway.log | grep workflow
```

3. **测试接口**
```bash
# 测试流程分类接口
curl http://localhost:9538/workflow/categorys/list

# 测试流程定义接口
curl http://localhost:9538/workflow/definitions/page
```

4. **前端测试**
   - 刷新前端页面
   - 登录系统
   - 访问流程编排相关页面
   - 检查浏览器控制台的网络请求

## 常见问题

### Q: 为什么直接访问服务也返回404？
A: 说明 workflow 控制器没有被正确注册。需要重启服务。

### Q: 重启后仍然404怎么办？
A: 
1. 检查控制器类是否在正确的包路径下
2. 检查是否有编译错误
3. 查看服务启动日志，确认控制器是否被扫描

### Q: 网关转发正常但后端404？
A: 这是典型的控制器未注册问题，重启 data-system-service 通常可以解决。

## 相关文件

- 网关配置：`moat/config/src/main/resources/config/gateway-dev.yml`
- 服务主类：`moat/studio/data-system-service-parent/data-system-service/src/main/java/cn/datax/service/system/DataxSystemApplication.java`
- Workflow控制器：`moat/studio/data-system-service-parent/data-system-service/src/main/java/cn/datax/service/system/controller/FlowCategoryController.java`

## 更新时间
2025-12-15 13:54

