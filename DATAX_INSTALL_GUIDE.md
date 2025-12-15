# DataX 安装和配置指南

## 一、数据集成服务分析

### 1.1 服务要求

**数据集成服务 (Service Data DTS)**
- **服务端口**: 9536
- **主类**: `com.platform.admin.DataDtsServiceApplication`
- **模块路径**: `moat/studio/service-data-dts-parent/service-data-dts`
- **依赖服务**:
  - Eureka注册中心 (8610) ✅ 已运行
  - Config配置中心 (8611) ✅ 已运行
  - Gateway网关 (9538) ✅ 已运行
  - MySQL数据库 (alldata) ✅ 已配置

### 1.2 功能特性

- 数据源配置管理（支持MySQL、Oracle、PostgreSQL、SQL Server、Hive、HBase、MongoDB、ClickHouse等）
- 任务模板管理
- 单任务/批量任务配置
- 数据同步监控
- 基于DataX的数据同步执行

## 二、DataX 安装步骤

### 2.1 下载DataX

DataX已下载到: `~/datax/DataX-master`

**方式一：从GitHub下载（推荐）**
```bash
cd ~
mkdir -p datax
cd datax
# 下载源码
git clone https://github.com/alibaba/DataX.git
# 或下载预编译版本（如果有）
```

**方式二：下载预编译版本**
访问：https://github.com/alibaba/DataX/releases
下载对应操作系统的预编译版本

### 2.2 编译DataX（如果下载的是源码）

```bash
cd ~/datax/DataX-master
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
mvn clean package -DskipTests
```

编译完成后，会在 `target/datax` 目录生成可执行文件。

### 2.3 配置DataX路径

根据配置文件 `moat/config/src/main/resources/config/service-data-dts-dev.yml`，需要配置以下路径：

```yaml
dts:
  executor:
    dataxHome: /home/datax/datax/bin/datax.py      # DataX执行脚本路径
    dataxjsonPath: /home/datax/datax/job/          # DataX任务JSON文件路径
    dataxlogHome: /home/datax/datax/job-log        # DataX日志路径
```

**macOS配置示例**（修改配置文件）：
```yaml
dts:
  executor:
    dataxHome: /Users/andyapple/datax/DataX-master/bin/datax.py
    dataxjsonPath: /Users/andyapple/datax/job/
    dataxlogHome: /Users/andyapple/datax/job-log
```

### 2.4 创建必要目录

```bash
mkdir -p ~/datax/job
mkdir -p ~/datax/job-log
chmod +x ~/datax/DataX-master/bin/datax.py
```

### 2.5 验证DataX安装

```bash
cd ~/datax/DataX-master
python3 bin/datax.py --version
# 或测试一个简单的任务
python3 bin/datax.py job/job.json
```

## 三、数据集成服务启动

### 3.1 构建服务

```bash
cd /Users/andyapple/Documents/Coding/alldata/moat/studio/service-data-dts-parent
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
mvn clean package -DskipTests
```

### 3.2 启动服务

**方式一：使用启动脚本**
```bash
cd /Users/andyapple/Documents/Coding/alldata
./start-data-dts-service.sh
```

**方式二：手动启动**
```bash
cd /Users/andyapple/Documents/Coding/alldata/moat/studio/service-data-dts-parent/service-data-dts
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
java -Xms512m -Xmx2048m \
    -XX:+UseG1GC \
    -Dfile.encoding=UTF-8 \
    -Dspring.profiles.active=dev \
    -jar target/service-data-dts.jar \
    --server.port=9536
```

### 3.3 验证服务

- 访问服务: http://localhost:9536
- 检查Eureka注册: http://localhost:8610
- 查看日志: `logs/service-data-dts.log`

## 四、配置MySQL隔离级别（重要）

DataX同步MySQL需要设置隔离级别：

```sql
SET GLOBAL transaction_isolation='READ-COMMITTED';
```

## 五、使用说明

### 5.1 配置数据源

1. 登录系统
2. 进入"数据集成" -> "数据源管理"
3. 添加数据源（MySQL、Oracle等）

### 5.2 配置任务模板

1. 进入"任务模板管理"
2. 创建任务模板
3. 配置源数据库和目标数据库

### 5.3 创建同步任务

1. 进入"单任务管理"或"批量任务管理"
2. 选择数据源
3. 配置字段映射
4. 生成DataX JSON配置
5. 执行任务

## 六、注意事项

1. **Java版本**: 必须使用Java 8编译和运行
2. **Python版本**: DataX需要Python 2.x或3.x
3. **MySQL隔离级别**: 必须设置为READ-COMMITTED
4. **DataX路径**: 确保配置的路径正确且可执行
5. **权限问题**: 确保DataX脚本有执行权限

## 七、故障排查

### 7.1 服务无法启动
- 检查端口9536是否被占用
- 检查Eureka和Config服务是否运行
- 查看日志文件

### 7.2 DataX执行失败
- 检查DataX路径配置是否正确
- 检查Python环境
- 查看DataX日志: `~/datax/job-log/`

### 7.3 数据同步失败
- 检查数据源连接配置
- 检查MySQL隔离级别
- 查看任务执行日志

## 八、当前状态

✅ **服务构建**: 已完成
✅ **服务启动**: 已启动（端口9536）
⚠️ **DataX安装**: 已下载源码，需要编译和配置路径
⚠️ **DataX配置**: 需要修改配置文件中的路径

## 下一步操作

1. 编译DataX（如果下载的是源码）
2. 修改配置文件中的DataX路径
3. 创建必要的目录
4. 测试DataX功能
5. 配置数据源并创建同步任务

