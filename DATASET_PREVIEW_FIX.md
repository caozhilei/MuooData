# 数据集预览和数据图表显示问题修复

## 问题描述
1. 数据集中的测试数据无法预览
2. 数据图表没有内容

## 问题原因
1. **分页SQL问题**：`buildPaginationSql` 方法会在SQL后面直接追加 `LIMIT`，但如果SQL中已经包含 `LIMIT`，就会导致SQL语法错误
2. **数据图表返回空数据**：SQL正确但返回空数组

## 修复内容

### 1. 修复分页SQL构建逻辑
**文件**: `moat/common/common-database/src/main/java/cn/datax/common/database/dialect/AbstractDbDialect.java`

在 `buildPaginationSql` 方法中添加了逻辑，如果SQL中已经包含 `LIMIT`，先移除它再添加新的分页LIMIT：

```java
@Override
public String buildPaginationSql(String originalSql, long offset, long count) {
    String sql = originalSql.trim();
    String sqlLower = sql.toLowerCase();
    int limitIndex = sqlLower.lastIndexOf(" limit ");
    if (limitIndex > 0) {
        sql = sql.substring(0, limitIndex).trim();
    }
    StringBuilder sqlBuilder = new StringBuilder(sql);
    sqlBuilder.append(" LIMIT ").append(offset).append(" , ").append(count);
    return sqlBuilder.toString();
}
```

## 下一步操作
1. 重新编译 common-database 模块
2. 重启元数据服务和数据可视化服务
3. 测试数据集预览功能
4. 测试数据图表显示

