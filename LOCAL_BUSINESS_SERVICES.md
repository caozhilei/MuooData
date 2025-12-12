# 本地服务部署指南

## 前提条件

1. **Docker基础服务已启动**（MySQL、Redis、RabbitMQ）
   ```bash
   docker ps | grep -E "mysql|redis|rabbitmq"
   ```
   如果未启动，请执行：
   ```bash
   docker-compose up -d mysql redis rabbitmq
   ```

2. **本地环境要求**
   - JDK >= 1.8
   - Maven >= 3.0
   - IDE (推荐IntelliJ IDEA)

3. **数据库和中间件**
   - MySQL (已在Docker中运行，端口: 3306)
   - Redis (已在Docker中运行，端口: 6379)
   - RabbitMQ (已在Docker中运行，端口: 5672)

## 启动顺序

**重要**: 必须按照以下顺序启动服务！

### 第一步：启动Eureka注册中心

**端口**: 8610

**主类**: `cn.datax.eureka.DataxEurekaApplication`

**路径**: `moat/eureka/src/main/java/cn/datax/eureka/DataxEurekaApplication.java`

**启动方式**:
1. 在IDEA中打开项目
2. 找到 `moat/eureka/src/main/java/cn/datax/eureka/DataxEurekaApplication.java`
3. 右键 -> Run 'DataxEurekaApplication'
4. 等待启动完成（约10-30秒）

**验证**: 访问 http://localhost:8610 应该能看到Eureka控制台

### 第二步：启动Config配置中心

**端口**: 8611

**主类**: `cn.datax.config.DataxConfigApplication`

**路径**: `moat/config/src/main/java/cn/datax/config/DataxConfigApplication.java`

**启动方式**:
1. 在IDEA中运行 `DataxConfigApplication`
2. 等待启动完成（约10-30秒）

**验证**: 
- 访问 http://localhost:8611/actuator/health
- 在Eureka控制台（http://localhost:8610）中应该能看到CONFIG服务

### 第三步：启动Gateway网关

**端口**: 9538

**主类**: `cn.datax.gateway.DataxGatewayApplication`

**路径**: `moat/gateway/src/main/java/cn/datax/gateway/DataxGatewayApplication.java`

**启动方式**:
1. 在IDEA中运行 `DataxGatewayApplication`
2. 等待启动完成（约10-30秒）

**验证**: 
- 访问 http://localhost:9538/actuator/health
- 在Eureka控制台中应该能看到GATEWAY服务

### 第四步：启动System Service系统服务（必需）

**端口**: 8000

**主类**: `com.platform.SystemServiceApplication`

**路径**: `moat/studio/system-service-parent/system-service/src/main/java/com/platform/SystemServiceApplication.java`

**启动方式**:
1. 在IDEA中运行 `SystemServiceApplication`
2. 等待启动完成（约30-60秒）

**验证**: 
- 访问 http://localhost:8000
- 应该看到 "Studio service started successfully"
- 在Eureka控制台中应该能看到SERVICE-SYSTEM服务

2. **本地环境要求**
   - JDK >= 1.8
   - Maven >= 3.0
   - IDE (推荐IntelliJ IDEA)

3. **数据库和中间件**
   - MySQL (已在Docker中运行，端口: 3306)
   - Redis (已在Docker中运行，端口: 6379)
   - RabbitMQ (已在Docker中运行，端口: 5672)

## 配置说明

所有服务的配置已经自动修改为本地连接：

- **Eureka地址**: `http://localhost:8610/eureka`
- **IP地址**: `localhost`

配置文件位置：
- 基础服务: `moat/eureka|config|gateway/src/main/resources/bootstrap.yml`
- 业务服务: `moat/studio/*/src/main/resources/bootstrap.yml`

## 启动业务服务

**前提**: 确保Eureka、Config、Gateway、System Service都已启动并正常运行

### 方式一：在IDEA中启动（推荐）

1. **导入项目到IDEA**
   - File -> Open -> 选择项目根目录 `/Users/andyapple/Documents/Coding/alldata`
   - 等待Maven依赖下载完成（首次可能需要较长时间）

2. **启动业务服务**

   #### 必需服务（必须先启动）
   - **System Service** (已在第四步启动)
   
   #### 可选业务服务（根据需要启动）
   
   以下服务可以根据业务需求选择性启动：
   ```
   **数据集成服务** (端口: 9536)
   - 主类: `com.platform.DataDtsServiceApplication`
   - 路径: `moat/studio/service-data-dts-parent/service-data-dts`
   
   **元数据管理服务** (端口: 8820)
   - 主类: `cn.datax.service.metadata.DataxMetadataApplication`
   - 路径: `moat/studio/data-metadata-service-parent/data-metadata-service`
   
   **元数据管理控制台** (端口: 8821)
   - 主类: `cn.datax.service.console.DataxConsoleApplication`
   - 路径: `moat/studio/data-metadata-service-parent/data-metadata-service-console`
   
   **数据标准服务** (端口: 8825)
   - 主类: `cn.datax.service.standard.DataxStandardApplication`
   - 路径: `moat/studio/data-standard-service-parent/data-standard-service`
   
   **数据质量服务** (端口: 8826)
   - 主类: `cn.datax.service.quality.DataxQualityApplication`
   - 路径: `moat/studio/data-quality-service-parent/data-quality-service`
   
   **数据资产服务** (端口: 8828)
   - 主类: `cn.datax.service.masterdata.DataxMasterdataApplication`
   - 路径: `moat/studio/data-masterdata-service-parent/data-masterdata-service`
   
   **数据市场服务** (端口: 8822)
   - 主类: `cn.datax.service.market.DataxMarketApplication`
   - 路径: `moat/studio/data-market-service-parent/data-market-service`
   
   **数据市场集成服务** (端口: 8824)
   - 主类: `cn.datax.service.integration.DataxIntegrationApplication`
   - 路径: `moat/studio/data-market-service-parent/data-market-service-integration`
   
   **数据市场映射服务** (端口: 8823)
   - 主类: `cn.datax.service.mapping.DataxMappingApplication`
   - 路径: `moat/studio/data-market-service-parent/data-market-service-mapping`
   
   **数据对比服务** (端口: 8096)
   - 主类: `cn.datax.service.compare.DataCompareApplication`
   - 路径: `moat/studio/data-compare-service-parent/data-compare-service`
   
   **BI报表服务** (端口: 8827)
   - 主类: `cn.datax.service.visual.DataxVisualApplication`
   - 路径: `moat/studio/data-visual-service-parent/data-visual-service`
   
   **定时任务服务** (端口: 8813)
   - 主类: `cn.datax.service.quartz.DataxQuartzApplication`
   - 路径: `moat/studio/quartz-service-parent/quartz-service`
   
   **邮件服务** (端口: 8812)
   - 主类: `cn.datax.service.email.DataxMailApplication`
   - 路径: `moat/studio/email-service-parent/email-service`
   
   **文件服务** (端口: 8811)
   - 主类: `cn.datax.service.file.DataxFileApplication`
   - 路径: `moat/studio/file-service-parent/file-service`
   ```

### 方式二：使用Maven命令启动

```bash
# 进入项目根目录
cd /Users/andyapple/Documents/Coding/alldata

# 启动系统服务（必需）
cd moat/studio/system-service-parent/system-service
mvn spring-boot:run

# 启动其他业务服务（在对应的服务目录下执行）
cd moat/studio/data-metadata-service-parent/data-metadata-service
mvn spring-boot:run
```

## 服务端口列表

| 服务名称 | 端口 | 说明 |
|---------|------|------|
| system-service | 8000 | 系统管理服务（必需） |
| data-system-service | 8810 | 数据系统服务 |
| file-service | 8811 | 文件服务 |
| email-service | 8812 | 邮件服务 |
| quartz-service | 8813 | 定时任务服务 |
| data-metadata-service | 8820 | 元数据管理服务 |
| data-metadata-service-console | 8821 | 元数据管理控制台 |
| data-market-service | 8822 | 数据市场服务 |
| data-market-service-mapping | 8823 | 数据市场映射服务 |
| data-market-service-integration | 8824 | 数据市场集成服务 |
| data-standard-service | 8825 | 数据标准服务 |
| data-quality-service | 8826 | 数据质量服务 |
| data-visual-service | 8827 | 数据可视化服务 |
| data-masterdata-service | 8828 | 数据资产服务 |
| data-compare-service | 8096 | 数据对比服务 |
| service-data-dts | 9536 | 数据集成服务 |

## 验证服务启动

### 1. 检查Eureka注册中心
访问 http://localhost:8610，应该能看到所有已启动的服务：
- EUREKA (注册中心本身)
- CONFIG (配置中心)
- GATEWAY (网关)
- SERVICE-SYSTEM (系统服务)
- 其他已启动的业务服务

### 2. 检查服务健康状态
- Config: http://localhost:8611/actuator/health
- Gateway: http://localhost:9538/actuator/health
- System Service: http://localhost:8000

### 3. 检查服务日志
在IDEA的控制台查看启动日志，确认：
- 没有连接Eureka失败的错误
- 没有连接Config失败的错误
- 没有数据库连接失败的错误
- 服务成功注册到Eureka

### 4. 测试服务接口
- 通过Gateway网关访问: http://localhost:9538
- 或直接访问服务端口

## 常见问题

### 1. 服务无法连接到Eureka

**问题**: 启动时报错无法连接到Eureka

**解决方案**:
- **确认Eureka服务已启动**: 访问 http://localhost:8610 应该能看到Eureka控制台
- **检查启动顺序**: 必须先启动Eureka，再启动其他服务
- **检查Eureka地址配置**: 确认 `bootstrap.yml` 中 `defaultZone: http://localhost:8610/eureka`
- **确认端口8610未被占用**: `lsof -i :8610`

### 2. 服务无法连接到Config配置中心

**问题**: 启动时报错无法连接到Config

**解决方案**:
- **确认Config服务已启动**: 访问 http://localhost:8611/actuator/health
- **检查启动顺序**: 必须先启动Eureka，再启动Config
- **检查Config是否注册到Eureka**: 在Eureka控制台查看是否有CONFIG服务
- **确认端口8611未被占用**: `lsof -i :8611`

### 3. 数据库连接失败

**问题**: 启动时报错数据库连接失败

**解决方案**:
- **确认MySQL服务已启动**: `docker ps | grep mysql`
- **检查数据库配置**: `moat/config/src/main/resources/config/application-common-dev.yml`
  - 确认数据库地址: `localhost:3306`
  - 确认用户名和密码正确
- **确认数据库已初始化**: 执行了 `install/sql/alldata-install.sql` 和 `install/sql/alldata-v0.6.x.sql`
- **测试数据库连接**: `mysql -h localhost -P 3306 -u root -p123456`

### 4. 端口被占用

**问题**: 启动时报错端口已被占用

**解决方案**:
- 检查端口占用: `lsof -i :端口号`
- 停止占用端口的进程或修改服务端口配置

## 恢复配置

如果需要恢复到服务器集群配置，可以使用备份文件：

```bash
# 恢复所有配置
find moat/studio -name "bootstrap.yml.bak" -exec sh -c 'mv "$1" "${1%.bak}"' _ {} \;
```

## 快速启动脚本

运行启动脚本查看详细启动指南：
```bash
./start-local-services.sh
```

## 下一步

配置完成后，可以：

1. **启动前端服务**（如果还没有启动）
   ```bash
   cd moat_ui
   npm install
   npm run dev
   ```

2. **访问前端界面**: http://localhost:8013
   - 用户名: admin
   - 密码: 123456

3. **根据业务需求启动相应的业务服务**

## 服务启动检查清单

- [ ] Docker基础服务（MySQL、Redis、RabbitMQ）已启动
- [ ] Eureka注册中心已启动（http://localhost:8610）
- [ ] Config配置中心已启动（http://localhost:8611）
- [ ] Gateway网关已启动（http://localhost:9538）
- [ ] System Service系统服务已启动（http://localhost:8000）
- [ ] 在Eureka控制台能看到所有已启动的服务
- [ ] 根据需要启动其他业务服务

