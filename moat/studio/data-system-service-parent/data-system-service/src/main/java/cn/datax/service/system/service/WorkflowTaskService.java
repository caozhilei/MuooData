package cn.datax.service.system.service;

import java.util.Map;

/**
 * 工作流任务服务接口
 *
 * @author AllDataDC
 */
public interface WorkflowTaskService {

    /**
     * 分页查询待办任务
     */
    Map<String, Object> pageTodo(int pageNum, int pageSize, String name);

    /**
     * 分页查询已办任务
     */
    Map<String, Object> pageDone(int pageNum, int pageSize, String name);

    /**
     * 执行任务
     */
    void executeTask(String taskId, Map<String, Object> variables);
}
