package cn.datax.service.system.service.impl;

import cn.datax.service.system.service.WorkflowDefinitionService;
import lombok.extern.slf4j.Slf4j;
import org.flowable.engine.ProcessEngine;
import org.flowable.engine.RepositoryService;
import org.flowable.engine.repository.Deployment;
import org.flowable.engine.repository.ProcessDefinition;
import org.flowable.engine.repository.ProcessDefinitionQuery;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipInputStream;

/**
 * 工作流定义服务实现类
 *
 * @author AllDataDC
 */
@Slf4j
@Service
public class WorkflowDefinitionServiceImpl implements WorkflowDefinitionService {

    @Autowired
    private RepositoryService repositoryService;

    @Autowired
    private ProcessEngine processEngine;

    @Override
    public Map<String, Object> pageDefinition(int pageNum, int pageSize, String category) {
        ProcessDefinitionQuery query = repositoryService.createProcessDefinitionQuery();
        if (category != null && !category.isEmpty()) {
            query.processDefinitionCategory(category);
        }
        query.latestVersion();
        long total = query.count();
        List<ProcessDefinition> list = query.listPage((pageNum - 1) * pageSize, pageSize);
        
        List<Map<String, Object>> data = new ArrayList<>();
        for (ProcessDefinition definition : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", definition.getId());
            item.put("deploymentId", definition.getDeploymentId());
            item.put("name", definition.getName());
            item.put("key", definition.getKey());
            item.put("version", definition.getVersion());
            item.put("category", definition.getCategory());
            item.put("suspensionState", definition.isSuspended() ? "2" : "1");
            data.add(item);
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("pageNum", pageNum);
        result.put("pageSize", pageSize);
        result.put("total", total);
        result.put("data", data);
        return result;
    }

    @Override
    public void deleteDefinition(String deploymentId) {
        repositoryService.deleteDeployment(deploymentId, true);
    }

    @Override
    public void activateDefinition(String processDefinitionId) {
        repositoryService.activateProcessDefinitionById(processDefinitionId, true, null);
    }

    @Override
    public void suspendDefinition(String processDefinitionId) {
        repositoryService.suspendProcessDefinitionById(processDefinitionId, true, null);
    }

    @Override
    public void deployDefinition(MultipartFile file, String category, String name) {
        try {
            String fileName = file.getOriginalFilename();
            if (fileName != null && fileName.endsWith(".zip")) {
                ZipInputStream zipInputStream = new ZipInputStream(file.getInputStream());
                repositoryService.createDeployment()
                        .name(name)
                        .category(category)
                        .addZipInputStream(zipInputStream)
                        .deploy();
            } else if (fileName != null && fileName.endsWith(".bpmn20.xml")) {
                repositoryService.createDeployment()
                        .name(name)
                        .category(category)
                        .addInputStream(fileName, file.getInputStream())
                        .deploy();
            } else {
                throw new RuntimeException("不支持的文件格式，请上传.bpmn20.xml或.zip文件");
            }
        } catch (IOException e) {
            log.error("部署流程定义失败", e);
            throw new RuntimeException("部署流程定义失败：" + e.getMessage());
        }
    }

    @Override
    public byte[] getProcessResource(String processDefinitionId, String resType) {
        try {
            ProcessDefinition processDefinition = repositoryService.getProcessDefinition(processDefinitionId);
            InputStream inputStream;
            if ("image".equals(resType)) {
                inputStream = repositoryService.getProcessDiagram(processDefinitionId);
            } else {
                inputStream = repositoryService.getResourceAsStream(
                        processDefinition.getDeploymentId(),
                        processDefinition.getResourceName());
            }
            if (inputStream != null) {
                ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                byte[] data = new byte[1024];
                int nRead;
                while ((nRead = inputStream.read(data, 0, data.length)) != -1) {
                    buffer.write(data, 0, nRead);
                }
                return buffer.toByteArray();
            }
        } catch (Exception e) {
            log.error("获取流程资源失败", e);
        }
        return new byte[0];
    }
}
