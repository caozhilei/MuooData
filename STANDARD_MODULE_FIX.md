# 数据标准模块数据加载问题修复指南

## 问题描述
数据标准模块的几个页面（数据标准类别、对照表）无法加载数据，只显示UI框架。

## 可能的原因

1. **数据库表不存在或没有数据**
   - `standard_type` 表不存在或为空
   - `standard_contrast` 表不存在或为空

2. **后端服务未启动或未注册**
   - `service-data-standard` 服务未启动
   - 服务未注册到注册中心（Eureka）

3. **网关路由配置问题**
   - 网关服务未启动
   - 路由配置错误

4. **API接口响应格式问题**
   - 后端返回的数据格式不正确
   - 前端未正确处理错误响应

## 解决步骤

### 步骤1: 检查数据库表和数据

运行诊断脚本：
```bash
./check-standard-service.sh
```

或者手动检查：
```sql
-- 检查表是否存在
SHOW TABLES LIKE 'standard_%';

-- 检查数据标准类别数据
SELECT COUNT(*) FROM standard_type WHERE status = 1;
SELECT * FROM standard_type WHERE status = 1 LIMIT 10;

-- 检查对照表数据
SELECT COUNT(*) FROM standard_contrast WHERE status = 1;
SELECT * FROM standard_contrast WHERE status = 1 LIMIT 10;
```

### 步骤2: 初始化数据库表和数据

如果表不存在或没有数据，运行初始化脚本：
```bash
mysql -u root -p alldata < init-standard-tables.sql
```

或者手动执行SQL：
```sql
USE alldata;
SOURCE init-standard-tables.sql;
```

### 步骤3: 检查服务状态

检查数据标准服务是否运行：
```bash
# Docker环境
docker ps | grep standard

# 本地环境
ps aux | grep data-standard

# 检查服务注册
curl http://localhost:8761/eureka/apps/service-data-standard
```

### 步骤4: 检查API接口

测试API接口是否正常：
```bash
# 测试数据标准类别接口
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:9999/data/standard/types/list

# 测试对照表树接口
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:9999/data/standard/contrasts/tree
```

### 步骤5: 检查浏览器控制台

打开浏览器开发者工具（F12），查看：
1. **Network标签**：检查API请求是否发送成功
2. **Console标签**：查看是否有错误信息
3. **Response**：检查API返回的数据格式

## 已修复的问题

### 1. 前端错误处理增强
- ✅ 添加了API调用的错误处理（`.catch()`）
- ✅ 添加了响应格式验证
- ✅ 改进了错误提示信息
- ✅ 添加了空数据时的默认显示

### 2. 修复的文件
- `moat_ui/src/views/standard/datadict/DataDictList.vue`
- `moat_ui/src/views/standard/dictcontrast/DictContrastList.vue`
- `moat_ui/src/views/standard/dictmapping/index.vue`
- `moat_ui/src/views/standard/contraststat/ContrastStatList.vue`
- 以及相关的Add、Edit、Detail页面

## 常见错误及解决方案

### 错误1: 404 Not Found
**原因**：服务未启动或路由配置错误
**解决**：
1. 检查 `service-data-standard` 服务是否启动
2. 检查网关路由配置 `gateway-dev.yml` 中的 `/data/standard/**` 路由

### 错误2: 500 Internal Server Error
**原因**：数据库连接问题或SQL错误
**解决**：
1. 检查数据库连接配置
2. 检查表结构是否正确
3. 查看后端服务日志

### 错误3: 返回空数组 []
**原因**：数据库表中没有启用状态的数据
**解决**：
1. 检查 `standard_type` 表中是否有 `status = 1` 的数据
2. 如果没有，运行 `init-standard-tables.sql` 初始化数据

### 错误4: CORS错误
**原因**：跨域配置问题
**解决**：
1. 检查网关的CORS配置
2. 检查前端请求的baseURL配置

## 验证修复

修复后，请验证以下功能：

1. **数据标准类别页面**
   - 左侧树应该显示"数据标准类别"根节点
   - 根节点下应该显示标准类别列表
   - 点击类别节点应该能加载对应的标准字典列表

2. **对照表页面**
   - 左侧树应该显示"对照表"根节点
   - 根节点下应该显示数据源、数据表、字段的层级结构
   - 点击字段节点应该能加载对应的对照字典列表

3. **对照统计页面**
   - 应该能正常显示对照统计列表

4. **字典映射页面**
   - 左侧树应该正常显示
   - 选择字段后应该能加载左右两侧的字典数据

## 相关文件

- `init-standard-tables.sql` - 数据库表初始化脚本
- `check-standard-service.sh` - 服务诊断脚本
- `moat/config/src/main/resources/config/gateway-dev.yml` - 网关路由配置
- `moat/studio/data-standard-service-parent/` - 数据标准服务代码

## 联系支持

如果问题仍未解决，请提供以下信息：
1. 浏览器控制台的错误信息
2. 后端服务的日志
3. 数据库表结构和数据情况
4. 服务运行状态

