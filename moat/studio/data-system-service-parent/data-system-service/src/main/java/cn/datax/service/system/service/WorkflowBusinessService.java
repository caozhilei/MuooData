package cn.datax.service.system.service;

import java.util.Map;

/**
 * 工作流业务服务接口
 *
 * @author AllDataDC
 */
public interface WorkflowBusinessService {

    /**
     * 刷新业务列表
     */
    void refreshBusiness();

    /**
     * 分页查询业务列表
     */
    Map<String, Object> pageBusiness(int pageNum, int pageSize, String name);

    /**
     * 根据ID获取业务
     */
    Map<String, Object> getBusinessById(String id);

    /**
     * 删除业务
     */
    void deleteBusiness(String id);

    /**
     * 新增业务
     */
    void addBusiness(Map<String, Object> business);

    /**
     * 更新业务
     */
    void updateBusiness(String id, Map<String, Object> business);
}
