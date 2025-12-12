# 业务服务启动指南

## 概述

本文档说明如何按依赖顺序启动所有可选业务服务。

## 前提条件

1. **基础服务已启动**
   - Eureka (端口: 8610)
   - Config (端口: 8611)
   - Gateway (端口: 9538)
   - System Service (端口: 8000)

2. **数据库已初始化**
   - MySQL数据库 `alldata` 已创建并导入SQL脚本

3. **依赖模块已编译**
   - common
   - generic
   - logging
   - box

## 启动方式

### 方式一：使用脚本自动启动（推荐）

```bash
cd /Users/andyapple/Documents/Coding/alldata
./start-all-business-services.sh
```

脚本会按依赖顺序自动启动所有业务服务：

1. **第一组：核心依赖服务**
   - Data System Service (8810) - 被几乎所有服务依赖
   - Data Metadata Service (8820) - 被多个服务依赖

2. **第二组：依赖system-service的基础服务**
   - File Service (8811)
   - Email Service (8812)
   - Quartz Service (8813)

3. **第三组：依赖metadata-service的服务**
   - Data Metadata Console (8821)
   - Data Quality Service (8826)
   - Data Visual Service (8827)

4. **第四组：数据治理相关服务**
   - Data Standard Service (8825)
   - Data Masterdata Service (8828)

5. **第五组：数据市场相关服务**
   - Data Market Service (8822)
   - Data Market Mapping (8823) - 依赖Data Market Service
   - Data Market Integration (8824)

6. **第六组：其他独立服务**
   - Data Compare Service (8096)
   - Service Data DTS (9536)

### 方式二：在IDEA中手动启动

按照上述顺序，在IDEA中逐个启动各个服务的Application类。

## 服务端口列表

| 服务名称 | 端口 | 主类 |
|---------|------|------|
| Data System Service | 8810 | cn.datax.service.system.DataxSystemApplication |
| File Service | 8811 | cn.datax.service.file.DataxFileApplication |
| Email Service | 8812 | cn.datax.service.email.DataxMailApplication |
| Quartz Service | 8813 | cn.datax.service.quartz.DataxQuartzApplication |
| Data Metadata Service | 8820 | cn.datax.service.metadata.DataxMetadataApplication |
| Data Metadata Console | 8821 | cn.datax.service.console.DataxConsoleApplication |
| Data Market Service | 8822 | cn.datax.service.market.DataxMarketApplication |
| Data Market Mapping | 8823 | cn.datax.service.mapping.DataxMappingApplication |
| Data Market Integration | 8824 | cn.datax.service.integration.DataxIntegrationApplication |
| Data Standard Service | 8825 | cn.datax.service.standard.DataxStandardApplication |
| Data Quality Service | 8826 | cn.datax.service.quality.DataxQualityApplication |
| Data Visual Service | 8827 | cn.datax.service.visual.DataxVisualApplication |
| Data Masterdata Service | 8828 | cn.datax.service.masterdata.DataxMasterdataApplication |
| Data Compare Service | 8096 | cn.datax.service.compare.DataCompareApplication |
| Service Data DTS | 9536 | com.platform.DataDtsServiceApplication |

## 检查服务状态

使用提供的检查脚本：

```bash
./check-business-services-status.sh
```

或手动检查：

```bash
# 检查端口
lsof -i :8810

# 检查Eureka注册
curl http://localhost:8610/eureka/apps

# 查看日志
tail -f logs/DataSystemService.log
```

## 停止服务

```bash
./stop-services.sh
```

## 常见问题

### 1. 数据库连接失败

**错误**: `Unknown database 'studio'`

**解决方案**: 
- 确认 `moat/config/src/main/resources/config/application-common-dev.yml` 中所有数据库URL都指向 `alldata`
- 重启Config服务以加载新配置
- 确认数据库 `alldata` 已创建并导入SQL脚本

### 2. 服务启动超时

**问题**: 服务启动时间超过3分钟

**解决方案**:
- 检查日志文件: `logs/<服务名>.log`
- 确认基础服务（Eureka, Config）正常运行
- 检查端口是否被占用
- 确认依赖模块已正确编译

### 3. Feign客户端连接失败

**问题**: 服务启动后无法调用其他服务的Feign接口

**解决方案**:
- 确认被依赖的服务已启动（如Data System Service）
- 检查Eureka注册中心，确认服务已注册
- 检查服务间的网络连接

## 依赖关系说明

### Feign客户端依赖

- **大部分服务**依赖 `cn.datax.service.system.api.feign` → 需要先启动 Data System Service
- **部分服务**依赖 `cn.datax.service.data.metadata.api.feign` → 需要先启动 Data Metadata Service
- **Data Market Mapping**依赖 `cn.datax.service.data.market.api.feign` → 需要先启动 Data Market Service

### 数据库依赖

所有服务都使用 `alldata` 数据库，但使用不同的表。

## 启动时间估算

- 单个服务启动时间：约30-60秒
- 所有服务启动时间：约15-20分钟（按顺序启动）

## 下一步

服务全部启动后，可以：

1. 访问前端界面: http://localhost:8013
2. 通过Gateway访问API: http://localhost:9538
3. 查看Eureka控制台: http://localhost:8610

