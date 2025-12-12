# AllData 服务启动指南 - 按依赖顺序启动

## 启动顺序说明

服务必须按照以下依赖顺序启动：

```
1. Eureka (无依赖)
   ↓
2. Config (依赖: Eureka)
   ↓
3. Gateway (依赖: Eureka, Config)
   ↓
4. System Service (依赖: Eureka, Config)
   ↓
5. 其他业务服务 (依赖: Eureka, Config)
```

## 方式一：使用脚本自动启动（推荐）

### 启动所有基础服务

```bash
./start-services-sequential.sh
```

这个脚本会：
1. 按顺序启动 Eureka → Config → Gateway → System Service
2. 等待每个服务启动完成后再启动下一个
3. 自动检查服务健康状态
4. 将日志保存到 `logs/` 目录

### 启动单个服务

```bash
./start-service.sh <服务名> <主类> <模块路径> <端口> [健康检查URL]

# 示例：启动Eureka
./start-service.sh Eureka cn.datax.eureka.DataxEurekaApplication moat/eureka 8610 http://localhost:8610
```

## 方式二：在IDEA中手动启动（推荐用于开发）

### 第一步：启动 Eureka 注册中心

**主类**: `cn.datax.eureka.DataxEurekaApplication`  
**路径**: `moat/eureka/src/main/java/cn/datax/eureka/DataxEurekaApplication.java`  
**端口**: 8610

**操作步骤**:
1. 在IDEA中找到 `DataxEurekaApplication.java`
2. 右键 -> Run 'DataxEurekaApplication'
3. 等待启动完成（约10-30秒）
4. 验证: 访问 http://localhost:8610 应该能看到Eureka控制台

**启动成功的标志**:
- 控制台显示 "Started DataxEurekaApplication"
- 浏览器访问 http://localhost:8610 能看到Eureka界面

---

### 第二步：启动 Config 配置中心

**主类**: `cn.datax.config.DataxConfigApplication`  
**路径**: `moat/config/src/main/java/cn/datax/config/DataxConfigApplication.java`  
**端口**: 8611

**操作步骤**:
1. 在IDEA中找到 `DataxConfigApplication.java`
2. 右键 -> Run 'DataxConfigApplication'
3. 等待启动完成（约10-30秒）
4. 验证: 访问 http://localhost:8611/actuator/health

**启动成功的标志**:
- 控制台显示 "Started DataxConfigApplication"
- 在Eureka控制台（http://localhost:8610）能看到 CONFIG 服务注册

---

### 第三步：启动 Gateway 网关

**主类**: `cn.datax.gateway.DataxGatewayApplication`  
**路径**: `moat/gateway/src/main/java/cn/datax/gateway/DataxGatewayApplication.java`  
**端口**: 9538

**操作步骤**:
1. 在IDEA中找到 `DataxGatewayApplication.java`
2. 右键 -> Run 'DataxGatewayApplication'
3. 等待启动完成（约10-30秒）
4. 验证: 访问 http://localhost:9538/actuator/health

**启动成功的标志**:
- 控制台显示 "Started DataxGatewayApplication"
- 在Eureka控制台能看到 GATEWAY 服务注册

---

### 第四步：启动 System Service 系统服务（必需）

**主类**: `com.platform.SystemServiceApplication`  
**路径**: `moat/studio/system-service-parent/system-service/src/main/java/com/platform/SystemServiceApplication.java`  
**端口**: 8000

**操作步骤**:
1. 在IDEA中找到 `SystemServiceApplication.java`
2. 右键 -> Run 'SystemServiceApplication'
3. 等待启动完成（约30-60秒）
4. 验证: 访问 http://localhost:8000

**启动成功的标志**:
- 控制台显示 "Started SystemServiceApplication"
- 访问 http://localhost:8000 显示 "Studio service started successfully"
- 在Eureka控制台能看到 SERVICE-SYSTEM 服务注册

---

### 第五步：启动其他业务服务（可选）

根据业务需求启动相应的服务。所有业务服务都依赖 Eureka 和 Config。

**常用业务服务**:

| 服务名称 | 主类 | 路径 | 端口 |
|---------|------|------|------|
| 数据集成 | `com.platform.DataDtsServiceApplication` | `moat/studio/service-data-dts-parent/service-data-dts` | 9536 |
| 元数据管理 | `cn.datax.service.metadata.DataxMetadataApplication` | `moat/studio/data-metadata-service-parent/data-metadata-service` | 8820 |
| 数据标准 | `cn.datax.service.standard.DataxStandardApplication` | `moat/studio/data-standard-service-parent/data-standard-service` | 8825 |
| 数据质量 | `cn.datax.service.quality.DataxQualityApplication` | `moat/studio/data-quality-service-parent/data-quality-service` | 8826 |
| 数据资产 | `cn.datax.service.masterdata.DataxMasterdataApplication` | `moat/studio/data-masterdata-service-parent/data-masterdata-service` | 8828 |
| 数据市场 | `cn.datax.service.market.DataxMarketApplication` | `moat/studio/data-market-service-parent/data-market-service` | 8822 |
| BI报表 | `cn.datax.service.visual.DataxVisualApplication` | `moat/studio/data-visual-service-parent/data-visual-service` | 8827 |

**启动方式**: 在IDEA中找到对应的Application类，右键运行即可。

## 验证服务状态

### 1. 检查Eureka注册中心

访问 http://localhost:8610，应该能看到所有已启动的服务列表。

### 2. 检查服务健康状态

```bash
# Config
curl http://localhost:8611/actuator/health

# Gateway
curl http://localhost:9538/actuator/health

# System Service
curl http://localhost:8000
```

### 3. 查看服务日志

- IDEA控制台：每个服务的启动日志会显示在对应的Run窗口中
- 脚本启动：日志保存在 `logs/` 目录下

## 停止服务

### 在IDEA中停止

- 点击每个Run窗口的停止按钮（红色方块）
- 或使用快捷键 Ctrl+F2

### 使用脚本停止

```bash
./stop-services.sh
```

## 常见问题

### 1. 服务启动失败 - 端口被占用

**错误**: `Address already in use`

**解决**:
```bash
# 查找占用端口的进程
lsof -i :端口号

# 停止进程
kill -9 <PID>
```

### 2. 服务无法连接到Eureka

**错误**: `Cannot execute request on any known server`

**解决**:
- 确认Eureka已启动: http://localhost:8610
- 检查 `bootstrap.yml` 中的Eureka地址配置
- 确认启动顺序正确（先启动Eureka）

### 3. 服务无法连接到Config

**错误**: `Could not locate PropertySource`

**解决**:
- 确认Config已启动: http://localhost:8611
- 确认Config已注册到Eureka
- 检查启动顺序（先Eureka，再Config）

### 4. 数据库连接失败

**错误**: `Communications link failure`

**解决**:
- 确认MySQL在Docker中运行: `docker ps | grep mysql`
- 检查数据库配置: `moat/config/src/main/resources/config/application-common-dev.yml`
- 确认数据库已初始化（执行了SQL脚本）

## 启动检查清单

- [ ] Docker基础服务运行中（MySQL、Redis、RabbitMQ）
- [ ] Eureka已启动并可以访问（http://localhost:8610）
- [ ] Config已启动并注册到Eureka
- [ ] Gateway已启动并注册到Eureka
- [ ] System Service已启动并注册到Eureka
- [ ] 在Eureka控制台能看到所有已启动的服务
- [ ] 根据需要启动其他业务服务

## 下一步

所有基础服务启动后，可以：

1. **启动前端服务**
   ```bash
   cd moat_ui
   npm install
   npm run dev
   ```

2. **访问系统**
   - 前端: http://localhost:8013
   - 用户名: admin
   - 密码: 123456

3. **根据业务需求启动相应的业务服务**

