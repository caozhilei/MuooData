package cn.datax.service.system.service;

import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

/**
 * 工作流定义服务接口
 *
 * @author AllDataDC
 */
public interface WorkflowDefinitionService {

    /**
     * 分页查询流程定义
     */
    Map<String, Object> pageDefinition(int pageNum, int pageSize, String category);

    /**
     * 删除流程定义
     */
    void deleteDefinition(String deploymentId);

    /**
     * 激活流程定义
     */
    void activateDefinition(String processDefinitionId);

    /**
     * 挂起流程定义
     */
    void suspendDefinition(String processDefinitionId);

    /**
     * 部署流程定义
     */
    void deployDefinition(MultipartFile file, String category, String name);

    /**
     * 获取流程资源
     */
    byte[] getProcessResource(String processDefinitionId, String resType);
}
