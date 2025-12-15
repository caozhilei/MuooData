# MuooData数据中台

> 安智信科技有限公司

MuooData是一个企业级数据中台解决方案，提供完整的数据治理、数据质量、数据可视化、数据集成等核心功能，帮助企业构建统一的数据管理平台。

## 📋 项目简介

MuooData数据中台采用微服务架构设计，基于Spring Cloud生态构建，提供从数据采集、数据治理、数据质量、数据可视化到数据服务的全链路数据管理能力。系统支持多数据源接入、元数据管理、数据标准制定、数据质量监控、BI报表分析、数据集成等核心功能。

## 🏗️ 技术架构

### 后端技术栈
- **框架**: Spring Boot 2.2.6
- **微服务**: Spring Cloud (Eureka + Gateway + Config)
- **语言**: Java 8
- **构建工具**: Maven 3.0+
- **数据库**: MySQL 5.7+
- **缓存**: Redis 3.0+
- **消息队列**: RabbitMQ 3.0+
- **数据集成**: DataX

### 前端技术栈
- **框架**: Vue 2.6.14
- **UI组件**: Element UI 2.15.8
- **图表库**: ECharts 4.2.1
- **构建工具**: Vue CLI 3.5.3
- **Node版本**: >= 8.9

## 🎯 核心功能模块

### 1. 基础服务（必须启动）
- **Eureka注册中心** (8610) - 服务注册与发现
- **Config配置中心** (8611) - 统一配置管理
- **Gateway网关** (9538) - API网关路由
- **System Service系统服务** (8000) - 系统管理基础服务

### 2. 数据治理服务
- **Data System Service** (8810) - 数据系统基础服务
- **Data Metadata Service** (8820) - 元数据管理服务
- **Data Metadata Console** (8821) - 元数据管理控制台
- **Data Standard Service** (8825) - 数据标准服务
- **Data Quality Service** (8826) - 数据质量服务
- **Data Masterdata Service** (8828) - 主数据管理服务

### 3. 数据市场服务
- **Data Market Service** (8822) - 数据市场核心服务
- **Data Market Mapping** (8823) - 数据市场映射服务
- **Data Market Integration** (8824) - 数据市场集成服务

### 4. 数据可视化服务
- **Data Visual Service** (8827) - BI报表与数据可视化服务
  - 数据源管理
  - SQL解析与数据预览
  - 数据图表管理
  - 数据大屏管理
  - 数据看板管理

### 5. 数据集成服务
- **Service Data DTS** (9536) - 数据集成服务（基于DataX）
  - 数据源配置
  - 任务模板管理
  - 单任务/批量任务配置
  - 数据同步监控

### 6. 工具服务
- **File Service** (8811) - 文件管理服务
- **Email Service** (8812) - 邮件服务
- **Quartz Service** (8813) - 定时任务服务
- **Data Compare Service** (8096) - 数据对比服务

## 🚀 快速开始

### 环境要求

- JDK >= 1.8
- MySQL >= 5.7.0 (推荐5.7及以上版本)
- Redis >= 3.0
- Maven >= 3.0
- Node >= 10.15.3
- RabbitMQ >= 3.0.x

### 数据库初始化

```bash
# 1. 创建数据库
mysql -u root -p
CREATE DATABASE alldata DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

# 2. 导入SQL脚本
cd install/sql
mysql -u root -p alldata < alldata.sql
mysql -u root -p alldata < alldata-v0.x.x.sql

# 3. 导入BI相关SQL（可选）
# 参考 quickstart/quickstart_bi.md
```

### 配置修改

修改配置文件 `moat/config/src/main/resources/config/application-common-dev.yml`：

- 配置MySQL连接信息
- 配置Redis连接信息
- 配置RabbitMQ连接信息

### 启动后端服务

#### 方式一：使用脚本启动（推荐）

```bash
# 启动基础服务
# 1. 启动Eureka (8610)
# 2. 启动Config (8611)
# 3. 启动Gateway (9538)
# 4. 启动System Service (8000)

# 启动所有业务服务
./start-all-business-services.sh

# 检查服务状态
./check-business-services-status.sh
```

#### 方式二：IDEA中手动启动

按以下顺序启动：

1. **基础服务**（必须）
   - `DataxEurekaApplication.java` - Eureka注册中心
   - `DataxConfigApplication.java` - Config配置中心
   - `DataxGatewayApplication.java` - Gateway网关
   - `SystemServiceApplication.java` - System Service系统服务

2. **业务服务**（按需启动）
   - `DataxSystemApplication.java` - Data System Service (8810)
   - `DataxMetadataApplication.java` - Data Metadata Service (8820)
   - `DataxVisualApplication.java` - Data Visual Service (8827)
   - 其他服务根据需求启动

### 启动前端服务

```bash
cd moat_ui

# 安装依赖
npm install

# 开发环境启动
npm run start
# 或
npm run dev

# 生产环境构建
npm run build:prod
```

访问地址：http://localhost:8013

默认账号：`admin` / `123456`

## 📦 服务端口列表

| 服务名称 | 端口 | 主类 | 说明 |
|---------|------|------|------|
| Eureka | 8610 | DataxEurekaApplication | 注册中心（必须） |
| Config | 8611 | DataxConfigApplication | 配置中心（必须） |
| Gateway | 9538 | DataxGatewayApplication | API网关（必须） |
| System Service | 8000 | SystemServiceApplication | 系统管理（必须） |
| Data System Service | 8810 | DataxSystemApplication | 数据系统基础服务 |
| File Service | 8811 | DataxFileApplication | 文件管理服务 |
| Email Service | 8812 | DataxMailApplication | 邮件服务 |
| Quartz Service | 8813 | DataxQuartzApplication | 定时任务服务 |
| Data Metadata Service | 8820 | DataxMetadataApplication | 元数据管理服务 |
| Data Metadata Console | 8821 | DataxConsoleApplication | 元数据管理控制台 |
| Data Market Service | 8822 | DataxMarketApplication | 数据市场服务 |
| Data Market Mapping | 8823 | DataxMappingApplication | 数据市场映射服务 |
| Data Market Integration | 8824 | DataxIntegrationApplication | 数据市场集成服务 |
| Data Standard Service | 8825 | DataxStandardApplication | 数据标准服务 |
| Data Quality Service | 8826 | DataxQualityApplication | 数据质量服务 |
| Data Visual Service | 8827 | DataxVisualApplication | BI报表服务 |
| Data Masterdata Service | 8828 | DataxMasterdataApplication | 主数据管理服务 |
| Data Compare Service | 8096 | DataCompareApplication | 数据对比服务 |
| Service Data DTS | 9536 | DataDtsServiceApplication | 数据集成服务 |

## 📚 项目结构

```
alldata/
├── moat/                          # 后端项目
│   ├── common/                   # 公共模块
│   │   ├── common-core/          # 核心工具类
│   │   ├── common-mybatis/       # MyBatis配置
│   │   ├── common-security/       # 安全模块
│   │   ├── common-redis/         # Redis配置
│   │   └── ...
│   ├── config/                    # 配置中心
│   ├── eureka/                    # 注册中心
│   ├── gateway/                   # API网关
│   └── studio/                    # 业务服务模块
│       ├── system-service-parent/         # 系统管理服务
│       ├── data-system-service-parent/   # 数据系统服务
│       ├── data-metadata-service-parent/ # 元数据管理服务
│       ├── data-quality-service-parent/  # 数据质量服务
│       ├── data-standard-service-parent/ # 数据标准服务
│       ├── data-masterdata-service-parent/ # 主数据服务
│       ├── data-market-service-parent/   # 数据市场服务
│       ├── data-visual-service-parent/   # 数据可视化服务
│       ├── service-data-dts-parent/      # 数据集成服务
│       ├── file-service-parent/          # 文件服务
│       ├── email-service-parent/         # 邮件服务
│       ├── quartz-service-parent/        # 定时任务服务
│       └── data-compare-service-parent/  # 数据对比服务
├── moat_ui/                       # 前端项目
│   ├── src/                       # 源代码
│   ├── public/                    # 静态资源
│   └── package.json
├── install/                       # 安装脚本和SQL
│   ├── sql/                       # 数据库脚本
│   └── ...
├── docker/                        # Docker部署相关
└── quickstart/                    # 快速开始指南
    ├── quickstart_studio.md       # Studio快速开始
    ├── quickstart_bi.md           # BI模块快速开始
    └── quickstart_dts.md          # 数据集成快速开始
```

## 📖 相关文档

- [部署指南](install/install.md) - 详细的部署说明
- [业务服务启动指南](BUSINESS_SERVICES_STARTUP.md) - 业务服务启动说明
- [BI模块配置流程](quickstart/quickstart_bi.md) - BI报表配置教程
- [数据集成配置教程](quickstart/quickstart_dts.md) - 数据集成配置教程
- [Docker部署指南](docker/README.md) - Docker容器化部署

## 🔧 开发指南

### 编译项目

```bash
# 编译公共模块
cd moat/common
mvn clean install -DskipTests

# 编译整个项目
cd moat
mvn clean package -DskipTests
```

### 依赖安装

如果遇到 `aspose-words` 依赖问题，需要手动安装：

```bash
cd moat/common
mvn install:install-file -Dfile=aspose-words-20.3.jar \
  -DgroupId=com.aspose \
  -DartifactId=aspose-words \
  -Dversion=20.3 \
  -Dpackaging=jar
```

## 🌐 访问地址

- **前端界面**: http://localhost:8013
- **API网关**: http://localhost:9538
- **Eureka控制台**: http://localhost:8610
- **Config配置中心**: http://localhost:8611

## 📝 许可证

本项目采用 GPL-V3 许可证。

## 👥 贡献

欢迎提交 Issue 和 Pull Request！

## 📧 联系方式

- 公司：安智信科技有限公司
- 项目地址：https://github.com/caozhilei/MuooData

---

**注意**: 使用MySQL 8的用户需要注意导入数据时的编码格式问题。建议使用MySQL 5.7及以上版本。
