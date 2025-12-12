package cn.datax.common.database.dialect;

import cn.datax.common.database.DbDialect;

/**
 * 方言抽象类
 *
 * @author AllDataDC
 * @date 2022-11-14
 */
public abstract class AbstractDbDialect implements DbDialect {

    @Override
    public String columns(String dbName, String tableName) {
        return "select column_name AS COLNAME, ordinal_position AS COLPOSITION, column_default AS DATADEFAULT, is_nullable AS NULLABLE, data_type AS DATATYPE, " +
                "character_maximum_length AS DATALENGTH, numeric_precision AS DATAPRECISION, numeric_scale AS DATASCALE, column_key AS COLKEY, column_comment AS COLCOMMENT " +
                "from information_schema.columns where table_schema = '" + dbName + "' and table_name = '" + tableName + "' order by ordinal_position ";
    }

    @Override
    public String tables(String dbName) {
        return "SELECT table_name AS TABLENAME, table_comment AS TABLECOMMENT FROM information_schema.tables where table_schema = '" + dbName + "' ";
    }

    @Override
    public String buildPaginationSql(String originalSql, long offset, long count) {
        // 获取 分页实际条数
        // 如果SQL中已经包含LIMIT，先移除它
        String sql = originalSql.trim();
        String sqlLower = sql.toLowerCase();
        int limitIndex = sqlLower.lastIndexOf(" limit ");
        if (limitIndex > 0) {
            // 找到最后一个LIMIT的位置，移除它及其后面的内容
            sql = sql.substring(0, limitIndex).trim();
        }
        StringBuilder sqlBuilder = new StringBuilder(sql);
        sqlBuilder.append(" LIMIT ").append(offset).append(" , ").append(count);
        return sqlBuilder.toString();
    }

    @Override
    public String count(String sql) {
        return "SELECT COUNT(*) FROM ( " + sql + " ) TEMP";
    }
}
