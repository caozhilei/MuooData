package cn.datax.service.system.api.vo;

import lombok.Data;

import java.io.Serializable;

/**
 * <p>
 * 流程分类VO
 * </p>
 *
 * @author AllDataDC
 * @date 2022-11-26
 */
@Data
public class FlowCategoryVo implements Serializable {

    private static final long serialVersionUID=1L;

    /**
     * 主键ID
     */
    private String id;

    /**
     * 状态（0不启用，1启用）
     */
    private Integer status;

    /**
     * 分类名称
     */
    private String name;

    /**
     * 备注
     */
    private String remark;
}

