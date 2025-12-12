# AllData 服务状态清单

## 依赖编译状态

### ✅ 已编译的基础模块

| 模块 | 状态 | 说明 |
|------|------|------|
| aspose-words | ✅ 已安装 | 手动安装到本地Maven仓库 |
| common | ✅ 已编译 | 公共基础模块（包含11个子模块：common-core, common-database, common-dictionary, common-jasperreport, common-log, common-mybatis, common-office, common-qrcode, common-rabbitmq, common-redis, common-security, common-service-api） |
| generic | ✅ 已编译 | 通用模块 |
| logging | ✅ 已编译 | 日志模块 |
| box | ✅ 已编译 | 工具箱模块（包含common和logging） |

### 编译命令

```bash
# 编译基础依赖模块（必需）
./build-dependencies.sh

# 编译所有业务服务（可选）
./build-business-services-java8.sh
```

### 业务服务编译依赖要求

所有业务服务都需要先编译基础依赖模块（common、generic、logging、box），部分服务还需要先编译对应的服务API模块。

#### 基础依赖（所有服务必需）

- ✅ **common模块** - 包含所有common子模块（common-core, common-database, common-dictionary, common-jasperreport, common-log, common-mybatis, common-office, common-qrcode, common-rabbitmq, common-redis, common-security, common-service-api）
- ✅ **generic模块** - 通用工具模块
- ✅ **logging模块** - 日志模块
- ✅ **box模块** - 工具箱模块（依赖common和logging）

#### 服务API模块编译状态

**✅ 所有服务API模块已编译完成（12个模块）**

| API模块 | 状态 | 说明 |
|---------|------|------|
| data-system-service-api | ✅ 已编译 | Data System Service的API模块 |
| file-service-api | ✅ 已编译 | File Service的API模块 |
| email-service-api | ✅ 已编译 | Email Service的API模块 |
| quartz-service-api | ✅ 已编译 | Quartz Service的API模块 |
| data-metadata-service-api | ✅ 已编译 | Data Metadata Service的API模块 |
| data-market-service-api | ✅ 已编译 | Data Market Service的API模块 |
| data-standard-service-api | ✅ 已编译 | Data Standard Service的API模块 |
| data-quality-service-api | ✅ 已编译 | Data Quality Service的API模块 |
| data-visual-service-api | ✅ 已编译 | Data Visual Service的API模块 |
| data-masterdata-service-api | ✅ 已编译 | Data Masterdata Service的API模块 |
| service-data-rpc | ✅ 已编译 | Service Data DTS的RPC模块 |
| service-data-core | ✅ 已编译 | Service Data DTS的Core模块 |

**检查API模块编译状态：**
```bash
./check-api-modules.sh
```

**批量编译所有API模块：**
```bash
./build-api-modules.sh
```

#### 服务API模块编译顺序

部分服务包含API模块，需要先编译API模块再编译服务本身：

| 服务 | API模块 | 编译顺序 |
|------|---------|----------|
| System Service | 无 | 直接编译 |
| Data System Service | data-system-service-api | ✅ 先编译API，再编译服务 |
| File Service | file-service-api | ✅ 先编译API，再编译服务 |
| Email Service | email-service-api | ✅ 先编译API，再编译服务 |
| Quartz Service | quartz-service-api | ✅ 先编译API，再编译服务 |
| Data Metadata Service | data-metadata-service-api | ✅ 先编译API，再编译服务 |
| Data Market Service | data-market-service-api | ✅ 先编译API，再编译服务 |
| Data Standard Service | data-standard-service-api | ✅ 先编译API，再编译服务 |
| Data Quality Service | data-quality-service-api | ✅ 先编译API，再编译服务 |
| Data Visual Service | data-visual-service-api | ✅ 先编译API，再编译服务 |
| Data Masterdata Service | data-masterdata-service-api | ✅ 先编译API，再编译服务 |
| Data Compare Service | 无 | 直接编译 |
| Service Data DTS | service-data-rpc, service-data-core | ✅ 先编译rpc和core，再编译服务 |

#### 业务服务编译顺序（推荐）

根据依赖关系，建议按以下顺序编译业务服务：

1. **System Service** - 基础服务，无API依赖
2. **Data System Service** - 核心服务，被其他服务依赖
3. **Email Service** - 基础服务
4. **File Service** - 基础服务
5. **Quartz Service** - 定时任务服务
6. **Data Compare Service** - 独立服务
7. **Data Market Service** - 数据市场服务
8. **Data Masterdata Service** - 数据资产服务
9. **Data Metadata Service** - 元数据管理服务（被多个服务依赖）
10. **Data Quality Service** - 数据质量服务
11. **Data Standard Service** - 数据标准服务
12. **Data Visual Service** - 数据可视化服务
13. **Service Data DTS** - 数据集成服务

#### 编译依赖关系图

```
基础依赖模块（必须先编译）
├── aspose-words (手动安装)
├── common (包含11个子模块)
│   ├── common-core
│   ├── common-database
│   ├── common-dictionary
│   ├── common-jasperreport
│   ├── common-log
│   ├── common-mybatis
│   ├── common-office
│   ├── common-qrcode
│   ├── common-rabbitmq
│   ├── common-redis
│   ├── common-security
│   └── common-service-api
├── generic
├── logging
└── box (依赖common和logging)

业务服务编译（依赖基础模块）
├── 服务API模块（部分服务需要）
│   ├── data-system-service-api
│   ├── data-metadata-service-api
│   ├── data-market-service-api
│   ├── data-standard-service-api
│   ├── data-quality-service-api
│   ├── data-visual-service-api
│   ├── data-masterdata-service-api
│   ├── file-service-api
│   ├── email-service-api
│   ├── quartz-service-api
│   └── service-data-rpc, service-data-core
└── 业务服务本身
    ├── System Service (无API依赖)
    ├── Data System Service (依赖data-system-service-api)
    ├── File Service (依赖file-service-api)
    ├── Email Service (依赖email-service-api)
    ├── Quartz Service (依赖quartz-service-api)
    ├── Data Metadata Service (依赖data-metadata-service-api)
    ├── Data Market Service (依赖data-market-service-api)
    ├── Data Standard Service (依赖data-standard-service-api)
    ├── Data Quality Service (依赖data-quality-service-api)
    ├── Data Visual Service (依赖data-visual-service-api)
    ├── Data Masterdata Service (依赖data-masterdata-service-api)
    ├── Data Compare Service (无API依赖)
    └── Service Data DTS (依赖service-data-rpc和service-data-core)
```

## 服务启动状态

### 基础服务（必需）

| 服务名称 | 端口 | 主类 | 状态 | 说明 |
|---------|------|------|------|------|
| Eureka | 8610 | `cn.datax.eureka.DataxEurekaApplication` | ✅ 运行中 | 注册中心 |
| Config | 8611 | `cn.datax.config.DataxConfigApplication` | ✅ 运行中 | 配置中心 |
| Gateway | 9538 | `cn.datax.gateway.DataxGatewayApplication` | ✅ 运行中 | API网关 |
| System Service | 8000 | `com.platform.SystemServiceApplication` | ⏳ 启动中 | 系统服务（必需） |

### 业务服务（可选）

| 服务名称 | 端口 | 主类 | 状态 | 运行依赖 | 编译依赖 | 说明 |
|---------|------|------|------|----------|----------|------|
| Data System Service | 8810 | `cn.datax.service.system.DataxSystemApplication` | ✅ 运行中 | Eureka, Config | common, generic, logging, box, data-system-service-api | 数据系统服务（核心服务，被其他服务依赖） |
| File Service | 8811 | `cn.datax.service.file.DataxFileApplication` | ✅ 运行中 | Eureka, Config, System Service | common, generic, logging, box, file-service-api | 文件服务 |
| Email Service | 8812 | `cn.datax.service.email.DataxMailApplication` | ✅ 运行中 | Eureka, Config, System Service | common, generic, logging, box, email-service-api | 邮件服务（已修复邮件健康检查问题） |
| Quartz Service | 8813 | `cn.datax.service.quartz.DataxQuartzApplication` | ✅ 运行中 | Eureka, Config, System Service | common, generic, logging, box, quartz-service-api | 定时任务服务（数据库表已初始化） |
| Data Metadata Service | 8820 | `cn.datax.service.metadata.DataxMetadataApplication` | ✅ 运行中 | Eureka, Config | common, generic, logging, box, data-metadata-service-api | 元数据管理服务（核心服务，被其他服务依赖） |
| Data Metadata Console | 8821 | `cn.datax.service.console.DataxConsoleApplication` | ✅ 运行中 | Eureka, Config, Data Metadata Service | common, generic, logging, box, data-metadata-service-api | 元数据管理控制台 |
| Data Market Service | 8822 | `cn.datax.service.market.DataxMarketApplication` | ✅ 运行中 | Eureka, Config | common, generic, logging, box, data-market-service-api | 数据市场服务（需先启动） |
| Data Market Mapping | 8823 | `cn.datax.service.mapping.DataxMappingApplication` | ✅ 运行中 | Eureka, Config, Data Market Service, Data Metadata Service | common, generic, logging, box, data-market-service-api, data-metadata-service-api | 数据市场映射服务 |
| Data Market Integration | 8824 | `cn.datax.service.integration.DataxIntegrationApplication` | ✅ 运行中 | Eureka, Config, Data Market Service | common, generic, logging, box, data-market-service-api | 数据市场集成服务 |
| Data Standard Service | 8825 | `cn.datax.service.standard.DataxStandardApplication` | ✅ 运行中 | Eureka, Config | common, generic, logging, box, data-standard-service-api | 数据标准服务 |
| Data Quality Service | 8826 | `cn.datax.service.quality.DataxQualityApplication` | ✅ 运行中 | Eureka, Config, Data Metadata Service | common, generic, logging, box, data-quality-service-api | 数据质量服务（已修复 Lambda 查询问题） |
| Data Visual Service | 8827 | `cn.datax.service.visual.DataxVisualApplication` | ✅ 运行中 | Eureka, Config, Data Metadata Service | common, generic, logging, box, data-visual-service-api | 数据可视化服务（已修复 MapStruct 编译问题） |
| Data Masterdata Service | 8828 | `cn.datax.service.masterdata.DataxMasterdataApplication` | ✅ 运行中 | Eureka, Config | common, generic, logging, box, data-masterdata-service-api | 数据资产服务 |
| Data Compare Service | 8096 | `com.platform.DataCompareApplication` | ✅ 运行中 | Eureka, Config | common, generic, logging, box | 数据对比服务（数据库表已初始化） |
| Service Data DTS | 9536 | `com.platform.admin.DataDtsServiceApplication` | ✅ 运行中 | Eureka, Config | common, generic, logging, box, service-data-rpc, service-data-core | 数据集成服务（已修复 Groovy 兼容性问题） |

## 启动顺序

### 第一步：编译基础依赖（已完成）

```bash
./build-dependencies.sh
```

### 第二步：启动基础服务（进行中）

1. ✅ Eureka - 已启动
2. ✅ Config - 已启动  
3. ✅ Gateway - 已启动
4. ⏳ System Service - 启动中

### 第三步：启动业务服务（待启动）

根据业务需求启动相应的业务服务。**注意：所有业务服务都依赖 Eureka 和 Config，部分服务还有额外的依赖要求。**

#### 业务服务依赖关系

**第一组：核心依赖服务（建议优先启动）**
- **Data System Service (8810)** - 被几乎所有其他服务依赖
- **Data Metadata Service (8820)** - 被多个服务依赖

**第二组：基础服务（依赖 System Service）**
- File Service (8811)
- Email Service (8812)
- Quartz Service (8813)

**第三组：元数据相关服务（依赖 Data Metadata Service）**
- Data Metadata Console (8821)
- Data Quality Service (8826)
- Data Visual Service (8827)

**第四组：数据市场相关服务**
- Data Market Service (8822) - 需先启动
- Data Market Mapping (8823) - 依赖 Data Market Service 和 Data Metadata Service
- Data Market Integration (8824) - 依赖 Data Market Service

**第五组：独立服务（仅依赖基础服务）**
- Data Standard Service (8825)
- Data Masterdata Service (8828)
- Data Compare Service (8096)
- Service Data DTS (9536)

#### 推荐启动顺序

```bash
# 方式一：使用脚本自动启动所有业务服务（推荐）
./start-all-business-services.sh

# 方式二：手动按依赖顺序启动
# 1. 先启动核心服务
# 2. 再启动依赖这些核心服务的其他服务
```

## 验证方法

### 检查Eureka注册中心

访问 http://localhost:8610，应该能看到所有已注册的服务。

### 检查服务健康状态

```bash
# Config
curl http://localhost:8611/actuator/health

# Gateway
curl http://localhost:9538/actuator/health

# System Service
curl http://localhost:8000
```

### 查看服务日志

```bash
# 查看启动日志
tail -f logs/SystemService.log

# 查看所有服务日志
ls -la logs/*.log
```

## 服务依赖关系图

```
基础服务（必需）
├── Eureka (8610) - 无依赖
├── Config (8611) - 依赖: Eureka
├── Gateway (9538) - 依赖: Eureka, Config
└── System Service (8000) - 依赖: Eureka, Config

业务服务（可选）
├── 核心服务
│   ├── Data System Service (8810) - 依赖: Eureka, Config
│   └── Data Metadata Service (8820) - 依赖: Eureka, Config
│
├── 基础服务（依赖 System Service）
│   ├── File Service (8811) - 依赖: Eureka, Config, System Service
│   ├── Email Service (8812) - 依赖: Eureka, Config, System Service
│   └── Quartz Service (8813) - 依赖: Eureka, Config, System Service
│
├── 元数据相关（依赖 Data Metadata Service）
│   ├── Data Metadata Console (8821) - 依赖: Eureka, Config, Data Metadata Service
│   ├── Data Quality Service (8826) - 依赖: Eureka, Config, Data Metadata Service
│   └── Data Visual Service (8827) - 依赖: Eureka, Config, Data Metadata Service
│
├── 数据市场相关
│   ├── Data Market Service (8822) - 依赖: Eureka, Config
│   ├── Data Market Mapping (8823) - 依赖: Eureka, Config, Data Market Service, Data Metadata Service
│   └── Data Market Integration (8824) - 依赖: Eureka, Config, Data Market Service
│
└── 独立服务（仅依赖基础服务）
    ├── Data Standard Service (8825) - 依赖: Eureka, Config
    ├── Data Masterdata Service (8828) - 依赖: Eureka, Config
    ├── Data Compare Service (8096) - 依赖: Eureka, Config
    └── Service Data DTS (9536) - 依赖: Eureka, Config
```

## 数据库表初始化

部分服务需要初始化数据库表才能完全正常工作：

### Quartz Service (8813)
需要初始化 Quartz 相关表（QRTZ_*）：
```bash
# MySQL 在 Docker 中，使用以下命令：
docker exec -i alldata-mysql mysql -uroot -p123456 alldata < init-missing-tables.sql

# 或者执行完整脚本：
docker exec -i alldata-mysql mysql -uroot -p123456 alldata < install/sql/alldata-v0.6.2.sql
```

### Data Compare Service (8096)
需要初始化 Data Compare Service 相关表（system_dc_*）：
```bash
# MySQL 在 Docker 中，使用以下命令：
docker exec -i alldata-mysql mysql -uroot -p123456 alldata < init-missing-tables.sql

# 或者执行完整脚本：
docker exec -i alldata-mysql mysql -uroot -p123456 alldata < install/sql/alldata-v0.6.2.sql
```

**注意**：
- MySQL 在 Docker 容器 `alldata-mysql` 中运行，使用 `docker exec` 命令执行 SQL 脚本
- 已创建 `init-missing-tables-only.sql` 脚本，只创建缺失的表，避免外键约束冲突
- ✅ **已完成**：数据库表已初始化，服务已重启验证，无数据库表未初始化警告

## 下一步操作

1. **初始化数据库表**：执行 `init-missing-tables.sql` 或 `install/sql/alldata-v0.6.2.sql` 初始化缺失的表
2. 等待System Service启动完成
3. 根据业务需求启动相应的业务服务（注意依赖关系）
4. 启动前端服务（如果需要）

