# 数据资产服务重启说明

## 当前状态

服务已重启，但jar包中的修复代码可能尚未更新。

## 解决方案

由于Maven依赖问题导致无法重新打包，有以下几种解决方案：

### 方案1：修复Maven配置后重新编译（推荐）

1. 检查Maven settings.xml配置
2. 修复依赖仓库配置
3. 重新编译打包：
   ```bash
   cd moat/studio/data-masterdata-service-parent/data-masterdata-service
   mvn clean package -DskipTests
   ```

### 方案2：使用IDE编译

1. 在IDE中打开项目
2. 编译修改的文件
3. 重新打包jar文件

### 方案3：手动更新jar包（临时方案）

由于Spring Boot的fat jar结构复杂，手动更新class文件可能不会完全生效。

## 验证修复

修复生效后，测试接口应该不再返回 "columns is null" 错误：

```bash
curl -X POST "http://localhost:9538/data/masterdata/datas/page" \
  -H "Content-Type: application/json" \
  -d '{"pageNum":1,"pageSize":20,"tableName":"test","columns":[],"conditions":[]}'
```

## 当前服务状态

- 服务端口: 8828
- 进程ID: $(cat /tmp/data-masterdata-service.pid 2>/dev/null || echo "未知")
- 日志文件: /tmp/data-masterdata-service.log

