# AllData 依赖编译指南

## 依赖关系分析

根据项目结构分析，编译顺序如下：

### 依赖关系图

```
1. common模块（基础）
   ├── common-service-api
   ├── common-core
   ├── common-log
   ├── common-redis
   ├── common-mybatis（依赖common-core）
   ├── common-security
   ├── common-database
   ├── common-dictionary
   ├── common-qrcode
   ├── common-jasperreport
   ├── common-rabbitmq
   └── common-office（需要手动安装aspose-words）
   
2. generic模块（依赖common-core）

3. logging模块（依赖common-core, common-mybatis, generic）

4. box模块（依赖logging, common-mybatis）

5. studio模块（业务服务，依赖common, box, logging等）
```

## 编译步骤

### 方式一：使用自动编译脚本（推荐）

```bash
./build-dependencies.sh
```

脚本会自动：
1. 切换到Java 8
2. 安装aspose-words到本地仓库
3. 按顺序编译所有基础模块

### 方式二：手动编译

#### 步骤1: 安装aspose-words

```bash
cd moat/common
mvn install:install-file \
    -Dfile=aspose-words-20.3.jar \
    -DgroupId=com.aspose \
    -DartifactId=aspose-words \
    -Dversion=20.3 \
    -Dpackaging=jar
cd ../..
```

#### 步骤2: 编译common模块

```bash
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH

cd moat/common
mvn -s ../../docker/maven-settings.xml clean install -DskipTests
cd ../..
```

#### 步骤3: 编译generic模块

```bash
cd moat/generic
mvn -s ../../docker/maven-settings.xml clean install -DskipTests
cd ../..
```

#### 步骤4: 编译logging模块

```bash
cd moat/logging
mvn -s ../../docker/maven-settings.xml clean install -DskipTests
cd ../..
```

#### 步骤5: 编译box模块

```bash
cd moat/box
mvn -s ../../docker/maven-settings.xml clean install -DskipTests
cd ../..
```

## 编译清单

### 必需编译的模块（按顺序）

| 序号 | 模块名称 | 路径 | 说明 |
|------|---------|------|------|
| 0 | aspose-words | moat/common/aspose-words-20.3.jar | 手动安装到本地仓库 |
| 1 | common | moat/common | 公共基础模块（包含11个子模块） |
| 2 | generic | moat/generic | 通用模块 |
| 3 | logging | moat/logging | 日志模块 |
| 4 | box | moat/box | 工具箱模块 |

### 可选编译的模块

| 模块名称 | 路径 | 说明 |
|---------|------|------|
| eureka | moat/eureka | 注册中心（已启动） |
| config | moat/config | 配置中心（已启动） |
| gateway | moat/gateway | 网关（已启动） |

### 业务服务模块（studio）

业务服务模块会在启动时自动编译，但建议先编译基础依赖模块以避免启动时的依赖问题。

## 验证编译结果

编译完成后，检查本地Maven仓库：

```bash
ls -la ~/.m2/repository/com/platform/
```

应该能看到以下模块：
- common-core-0.6.x.jar
- common-mybatis-0.6.x.jar
- common-security-0.6.x.jar
- generic-0.6.x.jar
- logging-0.6.x.jar
- box-0.6.x.jar

## 常见问题

### 1. 编译失败 - aspose-words未安装

**错误**: `Could not find artifact com.aspose:aspose-words:jar:20.3`

**解决**: 先执行步骤1安装aspose-words

### 2. 编译失败 - Java版本错误

**错误**: `Fatal error compiling: java.lang.IllegalAccessError`

**解决**: 确保使用Java 8，脚本会自动切换

### 3. 编译失败 - Maven仓库连接问题

**错误**: `Could not transfer artifact`

**解决**: 使用docker/maven-settings.xml配置文件，脚本会自动使用

### 4. 编译失败 - 依赖模块未编译

**错误**: `Could not find artifact com.platform:common-core`

**解决**: 确保按顺序编译，先编译common模块

## 编译后启动服务

编译完成后，可以启动业务服务：

```bash
# 启动System Service
cd moat/studio/system-service-parent/system-service
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH
mvn -s ../../../docker/maven-settings.xml spring-boot:run -DskipTests
```

或使用启动脚本：

```bash
./start-services-sequential.sh
```

