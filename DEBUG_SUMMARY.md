# 数据图表空值问题调试总结

## 问题现象
- dataParser API返回 `success: true`
- 但 `data` 数组为空
- SQL语句是正确的，直接执行可以返回数据

## 调试步骤

### 1. 添加了详细日志
在 `ChartServiceImpl.dataParser` 方法中添加了：
- SQL执行日志
- 数据源配置日志
- SQL执行结果日志
- 异常捕获日志
- 移除数据库前缀的重试逻辑

### 2. 发现的问题
- SQL执行成功，但返回0条数据
- 数据源配置正确：host=localhost, port=3306, dbName=alldata, username=root
- HikariPool启动成功

### 3. 可能的原因
1. **数据库前缀问题**：SQL中使用了 `alldata.table_name`，但JDBC URL已经指定了数据库名称
2. **缓存问题**：CacheDbQueryFactoryBean可能缓存了空结果
3. **SQL执行环境问题**：数据可视化服务创建的连接可能有问题

### 4. 已添加的修复
- 添加了移除数据库前缀的重试逻辑
- 添加了详细的日志输出

## 下一步
1. 检查日志输出，确认是否执行了移除前缀的重试逻辑
2. 如果重试成功，说明是数据库前缀问题，需要修复SQL生成逻辑
3. 如果重试失败，需要进一步检查数据源连接配置

