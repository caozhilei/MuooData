# 数据标准服务重启状态

## 当前状态

服务重启遇到编译问题，原因是：
- Lombok在Java 21下需要额外的JVM参数才能编译
- Maven编译时也需要添加`--add-opens`参数

## 解决方案

### 方案1: 使用已编译的类文件直接启动（推荐）

如果target/classes目录下有已编译的类文件，可以直接使用Java命令启动：

```bash
cd moat/studio/data-standard-service-parent/data-standard-service
java --add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
     --add-opens=java.base/java.lang=ALL-UNNAMED \
     -cp "target/classes:$(mvn dependency:build-classpath -q -DincludeScope=compile | tail -1)" \
     cn.datax.service.data.standard.DataxStandardApplication \
     --server.port=8825
```

### 方案2: 配置Maven编译时添加JVM参数

在`~/.m2/settings.xml`或项目根目录的`.mvn/jvm.config`中添加：

```
--add-opens=java.base/java.lang.reflect=ALL-UNNAMED
--add-opens=java.base/java.lang=ALL-UNNAMED
```

### 方案3: 使用已存在的jar文件

如果有已打包的jar文件，直接使用jar启动：

```bash
java --add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
     --add-opens=java.base/java.lang=ALL-UNNAMED \
     -jar data-standard-service-0.6.x.jar \
     --server.port=8825
```

## 已完成的修复

1. ✅ pom.xml已添加JVM参数配置
2. ✅ 前端错误处理已完善
3. ⚠️ 服务重启需要解决编译问题

## 下一步

1. 检查是否有已编译的类文件
2. 如果有，使用方案1直接启动
3. 如果没有，需要先解决Maven编译问题

