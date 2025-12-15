package cn.datax.service.system.mapstruct;

import cn.datax.service.system.api.entity.FlowCategoryEntity;
import cn.datax.service.system.api.vo.FlowCategoryVo;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

/**
 * <p>
 * 流程分类表 转换器
 * </p>
 *
 * @author AllDataDC
 * @date 2022-11-26
 */
@Mapper(componentModel = "spring")
public interface FlowCategoryMapper {

    FlowCategoryVo toVO(FlowCategoryEntity entity);

    List<FlowCategoryVo> toVOList(List<FlowCategoryEntity> list);
}

