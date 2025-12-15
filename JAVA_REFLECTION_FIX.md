# Java反射访问问题修复指南

## 问题描述

错误信息：
```
java.lang.reflect.InaccessibleObjectException: Unable to make field protected java.lang.reflect.InvocationHandler java.lang.reflect.Proxy.h accessible: module java.base does not "opens java.lang.reflect" to unnamed module
```

## 问题原因

- **Java版本**: Java 21
- **原因**: Java 9+引入了模块系统，限制了反射访问
- **影响**: MyBatis等框架无法通过反射访问`java.lang.reflect`包

## 解决方案

需要添加以下JVM参数：
```bash
--add-opens=java.base/java.lang.reflect=ALL-UNNAMED
--add-opens=java.base/java.lang=ALL-UNNAMED
```

## 修复步骤

### 步骤1: 停止当前服务

```bash
# 查找服务进程
ps aux | grep "DataxStandardApplication" | grep -v grep

# 停止服务（替换PID为实际进程ID）
kill 20432
```

### 步骤2: 使用修复后的命令启动服务

#### 方式1: 使用Maven启动（推荐）

```bash
cd moat/studio/data-standard-service-parent/data-standard-service

mvn spring-boot:run \
    -DskipTests \
    -Dspring-boot.run.jvmArguments="--add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED"
```

#### 方式2: 使用提供的启动脚本

```bash
./start-data-standard-service-fixed.sh
```

#### 方式3: 使用Java命令启动

```bash
cd moat/studio/data-standard-service-parent/data-standard-service

java --add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
     --add-opens=java.base/java.lang=ALL-UNNAMED \
     -XX:TieredStopAtLevel=1 \
     -cp target/classes:$(mvn dependency:build-classpath -Dmdep.outputFile=/dev/stdout -q) \
     cn.datax.service.data.standard.DataxStandardApplication
```

## 永久修复方案

### 方案1: 修改Maven配置（推荐）

在 `moat/studio/data-standard-service-parent/data-standard-service/pom.xml` 中添加：

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
        <jvmArguments>
            --add-opens=java.base/java.lang.reflect=ALL-UNNAMED
            --add-opens=java.base/java.lang=ALL-UNNAMED
        </jvmArguments>
    </configuration>
</plugin>
```

### 方案2: 设置环境变量

```bash
export MAVEN_OPTS="--add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED"
```

### 方案3: 创建启动脚本

使用已创建的 `start-data-standard-service-fixed.sh` 脚本。

## 验证修复

启动服务后，检查：
1. 服务是否正常启动（无错误日志）
2. 前端页面是否能正常加载数据
3. 浏览器控制台是否还有反射访问错误

## 其他服务

如果其他服务也遇到类似问题，需要添加相同的JVM参数：
- 网关服务
- 元数据服务
- 主数据服务
- 等等

## 相关文件

- `fix-java-reflection-issue.sh` - 问题诊断脚本
- `start-data-standard-service-fixed.sh` - 修复后的启动脚本

