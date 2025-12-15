# DataX 下载和安装指南

## 当前状态

✅ **已完成**:
- 目录结构已创建: `/Users/andyapple/datax/datax`
- 脚本文件已配置: `~/datax/datax/bin/datax.py`
- 配置文件已更新
- 数据集成服务已启动（端口9536）

⚠️ **待完成**: 下载DataX JAR文件（约1.6GB）

## 下载方式（按推荐顺序）

### 方式1：浏览器下载（最推荐）

由于OSS链接有访问限制，建议使用浏览器下载：

1. **打开浏览器**，访问以下任一地址：
   - `http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz`
   - `https://github.com/alibaba/DataX/releases` (查找预编译版本)
   - `https://gitee.com/alibaba/DataX/releases` (国内镜像)

2. **下载文件**到 `~/datax/` 目录

3. **运行安装脚本**:
   ```bash
   cd ~/datax
   ./install-datax-complete.sh
   ```

### 方式2：使用下载工具

如果浏览器下载较慢，可以使用下载工具：

**迅雷/IDM等工具**:
- 添加下载链接: `http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz`
- 下载到: `~/datax/datax.tar.gz`
- 运行: `~/datax/install-datax-complete.sh`

### 方式3：从GitHub下载源码并编译

如果无法下载预编译版本，可以从源码编译：

```bash
cd ~/datax

# 如果已有DataX源码
cd DataX

# 设置Java 8
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

# 编译（跳过有问题的模块）
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
    echo "✅ 编译安装完成"
fi
```

### 方式4：使用Docker（如果已安装Docker）

```bash
# 拉取DataX镜像
docker pull registry.cn-hangzhou.aliyuncs.com/datax/datax:latest

# 运行容器并复制文件
docker run --rm -v ~/datax/datax:/output registry.cn-hangzhou.aliyuncs.com/datax/datax:latest \
    sh -c "cp -r /opt/datax/* /output/"
```

### 方式5：从其他镜像站下载

**华为云镜像**:
```bash
# 需要查找具体的镜像地址
```

**清华大学镜像**:
```bash
# 需要查找具体的镜像地址
```

## 安装步骤

### 步骤1：下载文件

选择上述任一方式下载 `datax.tar.gz` 文件到 `~/datax/` 目录

### 步骤2：验证文件

```bash
cd ~/datax
ls -lh datax.tar.gz
# 文件大小应该约1.6GB
```

### 步骤3：运行安装脚本

```bash
cd ~/datax
./install-datax-complete.sh
```

### 步骤4：验证安装

```bash
cd ~/datax
JAR_COUNT=$(find datax/lib -name "*.jar" 2>/dev/null | wc -l | tr -d ' ')
echo "JAR文件数量: $JAR_COUNT"
# 应该显示>50个JAR文件
```

## 手动安装步骤

如果安装脚本无法使用，可以手动安装：

```bash
cd ~/datax

# 1. 解压
tar -xzf datax.tar.gz

# 2. 查找解压后的datax目录
DATAX_SOURCE=$(find . -maxdepth 2 -type d -name "datax" -exec sh -c '[ -d "$1/lib" ] && echo "$1"' _ {} \; | head -1)

# 3. 复制文件
cp -r "$DATAX_SOURCE"/* ~/datax/datax/

# 4. 设置权限
chmod +x ~/datax/datax/bin/datax.py

# 5. 验证
ls -la ~/datax/datax/lib/*.jar | wc -l
```

## 测试DataX

安装完成后，可以测试DataX是否正常工作：

```bash
cd ~/datax/datax

# 创建测试JSON文件
cat > job/test.json << 'EOF'
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
EOF

# 运行测试
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

## 故障排查

### 问题1：下载失败
- **原因**: OSS链接有访问限制
- **解决**: 使用浏览器或下载工具下载

### 问题2：文件大小异常
- **原因**: 下载不完整或下载了错误页面
- **解决**: 重新下载，确保文件大小约1.6GB

### 问题3：解压失败
- **原因**: 文件损坏或格式不对
- **解决**: 检查文件格式: `file datax.tar.gz`，应该显示 `gzip compressed data`

### 问题4：JAR文件不存在
- **原因**: 文件未正确复制
- **解决**: 检查 `~/datax/datax/lib/` 目录，确保JAR文件存在

## 当前配置

配置文件: `moat/config/src/main/resources/config/service-data-dts-dev.yml`

```yaml
dts:
  executor:
    dataxHome: /Users/andyapple/datax/datax/bin/datax.py
    dataxjsonPath: /Users/andyapple/datax/datax/job/
    dataxlogHome: /Users/andyapple/datax/datax/job-log
```

## 总结

DataX的基础安装已完成，只需要：
1. 下载 `datax.tar.gz` 文件（约1.6GB）
2. 运行 `~/datax/install-datax-complete.sh` 完成安装

**推荐方式**: 使用浏览器访问 `http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz` 下载文件。

