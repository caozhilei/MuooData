# DataX 快速安装指南

## 当前安装状态

✅ **已完成**:
- 目录结构已创建: `/Users/andyapple/datax/datax`
- 脚本文件已配置: `~/datax/datax/bin/datax.py`
- 配置文件已更新: `moat/config/src/main/resources/config/service-data-dts-dev.yml`
- 数据集成服务已启动: 端口9536

⚠️ **待完成**:
- DataX JAR文件需要手动下载（约1.6GB）

## 方式一：手动下载安装（推荐）

### 步骤1：下载DataX

由于网络限制，请使用以下方式之一下载：

**选项A：浏览器下载**
1. 打开浏览器访问: `http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz`
2. 下载文件到 `~/datax/` 目录

**选项B：使用wget（如果可用）**
```bash
cd ~/datax
wget http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz
```

**选项C：从GitHub下载**
访问: https://github.com/alibaba/DataX/releases
下载最新版本的预编译包

### 步骤2：解压并安装

```bash
cd ~/datax

# 解压
tar -xzf datax.tar.gz

# 复制文件到目标目录
cp -r datax/* ~/datax/datax/

# 确保脚本可执行
chmod +x ~/datax/datax/bin/datax.py

# 验证安装
ls -la ~/datax/datax/lib/*.jar | wc -l
# 应该显示多个JAR文件（通常>100个）
```

## 方式二：从源码编译（如果下载失败）

如果无法下载预编译版本，可以从源码编译：

```bash
cd ~/datax/DataX

# 设置Java 8
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

# 编译核心模块（跳过有问题的transformer模块）
mvn clean package -DskipTests -Dmaven.test.skip=true \
    -pl '!datax-transformer' \
    -am

# 查找编译后的文件
find . -path "*/target/datax/lib/*.jar" | head -5

# 如果编译成功，复制文件
if [ -d "core/target/datax" ]; then
    cp -r core/target/datax/* ~/datax/datax/
    cp core/src/main/bin/datax.py ~/datax/datax/bin/datax.py
    chmod +x ~/datax/datax/bin/datax.py
fi
```

## 方式三：使用Docker（如果已安装Docker）

```bash
# 拉取DataX镜像
docker pull registry.cn-hangzhou.aliyuncs.com/datax/datax:latest

# 运行容器并复制文件
docker run --rm -v ~/datax/datax:/output registry.cn-hangzhou.aliyuncs.com/datax/datax:latest \
    sh -c "cp -r /opt/datax/* /output/"
```

## 验证安装

安装完成后，执行以下命令验证：

```bash
cd ~/datax/datax

# 检查JAR文件
JAR_COUNT=$(ls -1 lib/*.jar 2>/dev/null | wc -l | tr -d ' ')
echo "JAR文件数量: $JAR_COUNT"

# 检查脚本
if [ -f "bin/datax.py" ]; then
    echo "✓ datax.py脚本存在"
    chmod +x bin/datax.py
fi

# 检查配置文件
if [ -f "conf/logback.xml" ]; then
    echo "✓ logback.xml配置文件存在"
fi

# 如果JAR文件数量>50，说明安装成功
if [ "$JAR_COUNT" -gt 50 ]; then
    echo "✅ DataX安装成功！"
else
    echo "⚠️ DataX安装不完整，JAR文件数量: $JAR_COUNT"
fi
```

## 测试DataX

创建一个测试JSON文件 `~/datax/datax/job/test.json`:

```json
{
  "job": {
    "content": [
      {
        "reader": {
          "name": "streamreader",
          "parameter": {
            "column": [
              {
                "value": "DataX",
                "type": "string"
              }
            ],
            "sliceRecordCount": 10
          }
        },
        "writer": {
          "name": "streamwriter",
          "parameter": {
            "print": true
          }
        }
      }
    ],
    "setting": {
      "speed": {
        "channel": 1
      }
    }
  }
}
```

运行测试:
```bash
cd ~/datax/datax
python3 bin/datax.py job/test.json job-log/test.log
```

如果看到输出，说明DataX安装成功。

## 配置MySQL隔离级别

DataX同步MySQL需要设置隔离级别：

```sql
mysql -u root -p

SET GLOBAL transaction_isolation='READ-COMMITTED';
SELECT @@GLOBAL.transaction_isolation;
```

## 重启数据集成服务

配置更新后，重启服务使配置生效：

```bash
cd /Users/andyapple/Documents/Coding/alldata

# 停止服务
ps aux | grep DataDtsServiceApplication | grep -v grep | awk '{print $2}' | xargs kill -9

# 启动服务
./start-data-dts-service.sh
```

## 当前配置

配置文件: `moat/config/src/main/resources/config/service-data-dts-dev.yml`

```yaml
dts:
  executor:
    dataxHome: /Users/andyapple/datax/datax/bin/datax.py
    dataxjsonPath: /Users/andyapple/datax/datax/job/
    dataxlogHome: /Users/andyapple/datax/datax/job-log
```

## 故障排查

### 问题1：下载失败
- **原因**: 网络限制或访问权限问题
- **解决**: 使用浏览器手动下载，或尝试其他下载源

### 问题2：JAR文件不存在
- **原因**: 文件未正确解压或复制
- **解决**: 检查 `~/datax/datax/lib/` 目录，确保JAR文件存在

### 问题3：脚本执行错误
- **原因**: Python版本或权限问题
- **解决**: 
  - 检查Python版本: `python3 --version`
  - 添加执行权限: `chmod +x ~/datax/datax/bin/datax.py`

## 一键安装脚本

如果下载成功，可以使用以下脚本快速安装：

```bash
#!/bin/bash
cd ~/datax

# 检查文件是否存在
if [ ! -f "datax.tar.gz" ]; then
    echo "请先下载datax.tar.gz文件到 ~/datax/ 目录"
    exit 1
fi

# 解压
echo "解压DataX..."
tar -xzf datax.tar.gz

# 复制文件
echo "复制文件..."
cp -r datax/* ~/datax/datax/

# 设置权限
chmod +x ~/datax/datax/bin/datax.py

# 验证
JAR_COUNT=$(ls -1 ~/datax/datax/lib/*.jar 2>/dev/null | wc -l | tr -d ' ')
if [ "$JAR_COUNT" -gt 50 ]; then
    echo "✅ DataX安装成功！JAR文件数量: $JAR_COUNT"
else
    echo "⚠️ 安装可能不完整，JAR文件数量: $JAR_COUNT"
fi
```

## 总结

DataX的基础安装已完成：
- ✅ 目录结构已创建
- ✅ 脚本文件已配置
- ✅ 配置文件已更新
- ✅ 服务已启动

**下一步**: 下载DataX JAR文件（约1.6GB）即可完成安装。

下载地址:
- http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz
- https://github.com/alibaba/DataX/releases

