# DataX 安装完成指南

## 一、当前安装状态

✅ **目录结构**: 已创建
- DataX路径: `/Users/andyapple/datax/datax`
- 脚本路径: `/Users/andyapple/datax/datax/bin/datax.py`
- 任务目录: `/Users/andyapple/datax/datax/job/`
- 日志目录: `/Users/andyapple/datax/datax/job-log/`

✅ **配置文件**: 已更新
- 配置文件: `moat/config/src/main/resources/config/service-data-dts-dev.yml`
- DataX路径已配置为: `/Users/andyapple/datax/datax/bin/datax.py`

⚠️ **JAR文件**: 需要手动下载

## 二、下载DataX预编译版本（推荐）

### 方式一：从阿里云OSS下载（推荐）

```bash
cd ~/datax
# 下载DataX预编译版本（约1.6GB）
curl -L http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz -o datax.tar.gz

# 解压
tar -xzf datax.tar.gz

# 复制文件到目标目录
cp -r datax/* ~/datax/datax/

# 确保脚本可执行
chmod +x ~/datax/datax/bin/datax.py
```

### 方式二：从GitHub Releases下载

访问: https://github.com/alibaba/DataX/releases
下载最新版本的预编译包，解压后复制到 `~/datax/datax/` 目录

### 方式三：使用Docker（如果已安装Docker）

```bash
docker pull registry.cn-hangzhou.aliyuncs.com/datax/datax:latest
```

## 三、验证安装

### 3.1 检查文件结构

```bash
cd ~/datax/datax
ls -la bin/datax.py          # 应该存在
ls -la lib/*.jar | head -5   # 应该看到多个JAR文件
ls -la conf/logback.xml      # 配置文件应该存在
```

### 3.2 测试DataX

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

## 四、配置MySQL隔离级别（重要）

DataX同步MySQL需要设置隔离级别：

```sql
-- 连接到MySQL
mysql -u root -p

-- 设置隔离级别
SET GLOBAL transaction_isolation='READ-COMMITTED';

-- 验证设置
SELECT @@GLOBAL.transaction_isolation;
```

## 五、重启数据集成服务

配置更新后，需要重启数据集成服务以使配置生效：

```bash
cd /Users/andyapple/Documents/Coding/alldata

# 停止服务
ps aux | grep DataDtsServiceApplication | grep -v grep | awk '{print $2}' | xargs kill -9

# 启动服务
./start-data-dts-service.sh
```

## 六、使用说明

### 6.1 前端访问

1. 登录系统: http://localhost:8013
2. 进入"数据集成"菜单
3. 配置数据源
4. 创建同步任务

### 6.2 任务执行流程

1. **配置数据源**: 在"数据源管理"中添加源数据库和目标数据库
2. **创建任务模板**: 定义同步规则
3. **创建单任务**: 选择数据源，配置字段映射，生成DataX JSON
4. **执行任务**: 点击执行，系统会调用DataX进行数据同步
5. **查看日志**: 在任务详情中查看执行日志

## 七、故障排查

### 7.1 DataX执行失败

**问题**: 找不到DataX JAR文件
**解决**: 
- 检查 `~/datax/datax/lib/` 目录是否有JAR文件
- 如果没有，按照"二、下载DataX预编译版本"重新下载

**问题**: Python脚本执行错误
**解决**:
- 检查Python版本: `python3 --version` (需要2.x或3.x)
- 检查脚本权限: `chmod +x ~/datax/datax/bin/datax.py`

### 7.2 数据同步失败

**问题**: MySQL连接失败
**解决**:
- 检查数据源配置
- 检查MySQL隔离级别是否设置为READ-COMMITTED
- 检查网络连接和防火墙设置

**问题**: 字段映射错误
**解决**:
- 检查源表和目标表的字段类型是否兼容
- 检查字段名称是否正确

## 八、当前配置

### 8.1 DataX路径配置

配置文件: `moat/config/src/main/resources/config/service-data-dts-dev.yml`

```yaml
dts:
  executor:
    dataxHome: /Users/andyapple/datax/datax/bin/datax.py
    dataxjsonPath: /Users/andyapple/datax/datax/job/
    dataxlogHome: /Users/andyapple/datax/datax/job-log
```

### 8.2 目录结构

```
~/datax/datax/
├── bin/
│   └── datax.py          # DataX执行脚本 ✅
├── lib/                  # DataX JAR文件目录 ⚠️ 需要下载
├── conf/
│   └── logback.xml       # 日志配置 ✅
├── job/                  # 任务JSON文件目录 ✅
├── job-log/              # 任务日志目录 ✅
└── log/                  # DataX日志目录 ✅
```

## 九、下一步操作

1. ✅ **目录结构**: 已完成
2. ✅ **脚本配置**: 已完成
3. ✅ **配置文件**: 已更新
4. ⚠️ **下载JAR文件**: 需要手动下载DataX预编译版本
5. ⚠️ **配置MySQL**: 需要设置隔离级别
6. ⚠️ **重启服务**: 配置更新后需要重启

## 十、快速安装命令（一键执行）

```bash
# 下载并安装DataX（需要网络连接）
cd ~/datax
curl -L http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz -o datax.tar.gz
tar -xzf datax.tar.gz
cp -r datax/* ~/datax/datax/
chmod +x ~/datax/datax/bin/datax.py

# 验证安装
ls -la ~/datax/datax/lib/*.jar | wc -l  # 应该显示多个JAR文件

# 重启数据集成服务
cd /Users/andyapple/Documents/Coding/alldata
ps aux | grep DataDtsServiceApplication | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
./start-data-dts-service.sh
```

## 十一、注意事项

1. **网络要求**: 下载DataX需要稳定的网络连接（文件约1.6GB）
2. **磁盘空间**: 确保有至少2GB的可用磁盘空间
3. **Java版本**: DataX需要Java 8，已配置
4. **Python版本**: 需要Python 2.x或3.x，系统已安装Python 3.9.6
5. **权限问题**: 确保脚本有执行权限

## 十二、完成状态

- ✅ 数据集成服务: 已构建并启动（端口9536）
- ✅ DataX目录结构: 已创建
- ✅ DataX脚本: 已配置
- ✅ 配置文件: 已更新路径
- ⚠️ DataX JAR文件: 需要手动下载（约1.6GB）
- ⚠️ MySQL隔离级别: 需要手动配置

**总结**: DataX的基础安装已完成，只需要下载JAR文件即可使用。如果网络条件允许，可以执行"十、快速安装命令"完成完整安装。

