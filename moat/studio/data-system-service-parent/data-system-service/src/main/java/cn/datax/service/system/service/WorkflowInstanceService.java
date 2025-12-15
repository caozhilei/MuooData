package cn.datax.service.system.service;

import org.flowable.engine.runtime.ProcessInstance;

import java.util.Map;

/**
 * 工作流实例服务接口
 *
 * @author AllDataDC
 */
public interface WorkflowInstanceService {

    /**
     * 分页查询运行中的流程实例
     */
    Map<String, Object> pageRunning(int pageNum, int pageSize, String name);

    /**
     * 分页查询我发起的流程实例
     */
    Map<String, Object> pageMyStarted(int pageNum, int pageSize, String name);

    /**
     * 分页查询我参与的流程实例
     */
    Map<String, Object> pageMyInvolved(int pageNum, int pageSize, String name);

    /**
     * 删除流程实例
     */
    void deleteInstance(String processInstanceId);

    /**
     * 激活流程实例
     */
    void activateInstance(String processInstanceId);

    /**
     * 挂起流程实例
     */
    void suspendInstance(String processInstanceId);

    /**
     * 获取流程图
     */
    byte[] getProcessImage(String processInstanceId);

    /**
     * 启动流程实例
     */
    Map<String, Object> startInstance(String processDefinitionKey, String businessKey, String name, Map<String, Object> variables);
}
