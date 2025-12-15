package cn.datax.service.system.api.entity;

import cn.datax.common.base.BaseEntity;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;

/**
 * <p>
 * 流程分类表
 * </p>
 *
 * @author AllDataDC
 * @date 2022-11-26
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Accessors(chain = true)
@TableName(value = "flow_category", autoResultMap = true)
public class FlowCategoryEntity extends BaseEntity {

    private static final long serialVersionUID=1L;

    /**
     * 分类名称
     */
    private String name;
}

