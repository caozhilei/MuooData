package cn.datax.service.data.visual.service.impl;

import cn.datax.common.core.DataConstant;
import cn.datax.common.database.DataSourceFactory;
import cn.datax.common.database.DbQuery;
import cn.datax.common.database.constants.DbQueryProperty;
import cn.datax.common.exception.DataException;
import cn.datax.service.data.metadata.api.dto.DbSchema;
import cn.datax.service.data.metadata.api.entity.MetadataSourceEntity;
import cn.datax.service.data.metadata.api.feign.MetadataSourceServiceFeign;
import cn.datax.service.data.visual.api.dto.ChartItem;
import cn.datax.service.data.visual.api.dto.ChartConfig;
import cn.datax.service.data.visual.api.entity.BoardChartEntity;
import cn.datax.service.data.visual.api.entity.ChartEntity;
import cn.datax.service.data.visual.api.dto.ChartDto;
import cn.datax.service.data.visual.api.entity.DataSetEntity;
import cn.datax.service.data.visual.api.entity.ScreenChartEntity;
import cn.datax.service.data.visual.dao.BoardChartDao;
import cn.datax.service.data.visual.dao.DataSetDao;
import cn.datax.service.data.visual.dao.ScreenChartDao;
import cn.datax.service.data.visual.service.ChartService;
import cn.datax.service.data.visual.mapstruct.ChartMapper;
import cn.datax.service.data.visual.dao.ChartDao;
import cn.datax.common.base.BaseServiceImpl;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.date.DatePattern;
import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * <p>
 * 可视化图表配置信息表 服务实现类
 * </p>
 *
 * @author AllDataDC
 * @date 2022-11-04
 */
@Service
@Transactional(propagation = Propagation.SUPPORTS, readOnly = true, rollbackFor = Exception.class)
public class ChartServiceImpl extends BaseServiceImpl<ChartDao, ChartEntity> implements ChartService {

	private static final Logger log = LoggerFactory.getLogger(ChartServiceImpl.class);

	@Autowired
	private ChartDao chartDao;

	@Autowired
	private BoardChartDao boardChartDao;

	@Autowired
	private ScreenChartDao screenChartDao;

	@Autowired
	private ChartMapper chartMapper;

	@Autowired
	private DataSetDao dataSetDao;

	@Autowired
	private DataSourceFactory dataSourceFactory;

	@Autowired
	private MetadataSourceServiceFeign metadataSourceServiceFeign;

	@Override
	@Transactional(rollbackFor = Exception.class)
	public ChartEntity saveChart(ChartDto chartDto) {
		ChartEntity chart = chartMapper.toEntity(chartDto);
		chartDao.insert(chart);
		return chart;
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public ChartEntity updateChart(ChartDto chartDto) {
		ChartEntity chart = chartMapper.toEntity(chartDto);
		chartDao.updateById(chart);
		return chart;
	}

	@Override
	public ChartEntity getChartById(String id) {
		ChartEntity chartEntity = super.getById(id);
		return chartEntity;
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public void deleteChartById(String id) {
		//zrx check
		BoardChartEntity boardChartEntity = boardChartDao.selectOne(new QueryWrapper<BoardChartEntity>().eq("chart_id", id).last("limit 1"));
		if (boardChartEntity != null) {
			throw new RuntimeException("存在与之关联的看板，不允许删除！");
		}
		ScreenChartEntity screenChartEntity = screenChartDao.selectOne(new QueryWrapper<ScreenChartEntity>().eq("chart_id", id).last("limit 1"));
		if (screenChartEntity != null) {
			throw new RuntimeException("存在与之关联的酷屏，不允许删除！");
		}
		chartDao.deleteById(id);

	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public void deleteChartBatch(List<String> ids) {
		// zrx check
		for (String id : ids) {
			deleteChartById(id);
		}
		//chartDao.deleteBatchIds(ids);
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public void copyChart(String id) {
		ChartEntity chartEntity = Optional.ofNullable(super.getById(id)).orElseThrow(() -> new DataException("获取失败"));
		ChartEntity copy = new ChartEntity();
		copy.setChartName(chartEntity.getChartName() + "_副本" + DateUtil.format(LocalDateTime.now(), DatePattern.PURE_DATETIME_PATTERN));
		copy.setChartThumbnail(chartEntity.getChartThumbnail());
		copy.setChartConfig(chartEntity.getChartConfig());
		copy.setStatus(DataConstant.EnableState.ENABLE.getKey());
		chartDao.insert(copy);
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public void buildChart(ChartDto chartDto) {
		ChartEntity chart = chartMapper.toEntity(chartDto);
		chartDao.updateById(chart);
	}

	@Override
	public Map<String, Object> dataParser(ChartConfig chartConfig) {
		String datasetId = chartConfig.getDataSetId();
		DataSetEntity dataSetEntity = Optional.ofNullable(dataSetDao.selectById(datasetId)).orElseThrow(() -> new DataException("获取数据集失败"));
		MetadataSourceEntity metadataSourceEntity = Optional.ofNullable(metadataSourceServiceFeign.getMetadataSourceById(dataSetEntity.getSourceId())).orElseThrow(() -> new DataException("获取数据源失败"));
		DbSchema dbSchema = metadataSourceEntity.getDbSchema();
		DbQueryProperty dbQueryProperty = new DbQueryProperty(metadataSourceEntity.getDbType(), dbSchema.getHost(),
				dbSchema.getUsername(), dbSchema.getPassword(), dbSchema.getPort(), dbSchema.getDbName(), dbSchema.getSid());
		DbQuery dbQuery = Optional.ofNullable(dataSourceFactory.createDbQuery(dbQueryProperty)).orElseThrow(() -> new DataException("创建数据查询接口出错"));

		List<ChartItem> rows = chartConfig.getRows();
		List<ChartItem> columns = chartConfig.getColumns();
		List<ChartItem> measures = chartConfig.getMeasures();
		String setSql = dataSetEntity.getSetSql();
		StringBuilder sql = new StringBuilder();
		List<ChartItem> groups = new ArrayList<>();
		groups.addAll(rows);
		groups.addAll(columns);
		sql.append("SELECT");
		String groupJoining = null;
		String measureJoining = null;
		if (CollUtil.isNotEmpty(groups)) {
			groupJoining = groups.stream().map(s -> s.getCol()).collect(Collectors.joining(", ", " ", " "));
			sql.append(groupJoining);
		}
		if (CollUtil.isNotEmpty(measures)) {
			if (StrUtil.isNotBlank(groupJoining)) {
				sql.append(",");
			} else {
				sql.append(" ");
			}
			measureJoining = measures.stream().map(s -> new StringBuilder().append(s.getAggregateType()).append("(").append(s.getCol()).append(") AS ").append(s.getCol())).collect(Collectors.joining(", ", " ", " "));
			sql.append(measureJoining);
		}
		sql.append("FROM (").append(setSql).append(") TEMP_VIEW");
		if (CollUtil.isNotEmpty(groups)) {
			sql.append(" GROUP BY ").append(groups.stream().map(s -> s.getCol()).collect(Collectors.joining(", ")));
		}
		String finalSql = sql.toString();
		log.info("执行图表数据解析SQL: {}", finalSql);
		log.info("数据源配置: host={}, port={}, dbName={}, username={}", dbSchema.getHost(), dbSchema.getPort(), dbSchema.getDbName(), dbSchema.getUsername());
		List<Map<String, Object>> data = null;
		try {
			data = dbQuery.queryList(finalSql);
			log.info("SQL执行结果: 返回{}条数据", data != null ? data.size() : 0);
			if (data != null && data.size() > 0) {
				log.info("第一条数据示例: {}", data.get(0));
			} else {
				log.warn("SQL执行返回空数据，SQL: {}", finalSql);
				// 尝试移除数据库前缀后重新执行
				String sqlWithoutPrefix = finalSql.replaceAll("alldata\\.", "");
				log.info("尝试移除数据库前缀后执行SQL: {}", sqlWithoutPrefix);
				try {
					List<Map<String, Object>> retryData = dbQuery.queryList(sqlWithoutPrefix);
					log.info("移除前缀后SQL执行结果: 返回{}条数据", retryData != null ? retryData.size() : 0);
					if (retryData != null && retryData.size() > 0) {
						data = retryData;
						log.info("使用移除前缀后的SQL结果");
					}
				} catch (Exception e) {
					log.error("移除前缀后SQL执行失败: {}", e.getMessage(), e);
				}
			}
		} catch (Exception e) {
			log.error("SQL执行失败: {}", e.getMessage(), e);
			throw new DataException("SQL执行失败: " + e.getMessage());
		}
		Map<String, Object> map = new HashMap<>(2);
		map.put("data", data);
		map.put("sql", finalSql);
		return map;
	}
}
