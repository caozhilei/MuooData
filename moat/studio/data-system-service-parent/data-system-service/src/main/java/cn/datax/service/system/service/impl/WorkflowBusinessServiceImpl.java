package cn.datax.service.system.service.impl;

import cn.datax.service.system.service.WorkflowBusinessService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * 工作流业务服务实现类
 *
 * @author AllDataDC
 */
@Slf4j
@Service
public class WorkflowBusinessServiceImpl implements WorkflowBusinessService {

    // TODO: 这里应该从数据库或配置中读取业务列表
    // 暂时使用内存存储作为示例
    private Map<String, Map<String, Object>> businessMap = new HashMap<>();

    @Override
    public void refreshBusiness() {
        // TODO: 从数据库或配置中刷新业务列表
        businessMap.clear();
    }

    @Override
    public Map<String, Object> pageBusiness(int pageNum, int pageSize, String name) {
        // TODO: 实现分页查询业务列表
        Map<String, Object> result = new HashMap<>();
        result.put("pageNum", pageNum);
        result.put("pageSize", pageSize);
        result.put("total", 0L);
        result.put("data", new ArrayList<>());
        return result;
    }

    @Override
    public Map<String, Object> getBusinessById(String id) {
        return businessMap.getOrDefault(id, new HashMap<>());
    }

    @Override
    public void deleteBusiness(String id) {
        businessMap.remove(id);
    }

    @Override
    public void addBusiness(Map<String, Object> business) {
        String id = (String) business.get("id");
        if (id != null) {
            businessMap.put(id, business);
        }
    }

    @Override
    public void updateBusiness(String id, Map<String, Object> business) {
        business.put("id", id);
        businessMap.put(id, business);
    }
}
