package cn.datax.service.system.service.impl;

import cn.datax.common.base.BaseServiceImpl;
import cn.datax.service.system.api.entity.FlowCategoryEntity;
import cn.datax.service.system.dao.FlowCategoryDao;
import cn.datax.service.system.service.FlowCategoryService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * <p>
 * 流程分类表 服务实现类
 * </p>
 *
 * @author AllDataDC
 * @date 2022-11-26
 */
@Service
@Transactional(propagation = Propagation.SUPPORTS, readOnly = true, rollbackFor = Exception.class)
public class FlowCategoryServiceImpl extends BaseServiceImpl<FlowCategoryDao, FlowCategoryEntity> implements FlowCategoryService {

}

