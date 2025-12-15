package cn.datax.service.system.service.impl;

import cn.datax.common.utils.SecurityUtils;
import cn.datax.service.system.service.WorkflowInstanceService;
import lombok.extern.slf4j.Slf4j;
import org.flowable.engine.ProcessEngine;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.history.HistoricProcessInstance;
import org.flowable.engine.history.HistoricProcessInstanceQuery;
import org.flowable.engine.runtime.ProcessInstance;
import org.flowable.engine.runtime.ProcessInstanceQuery;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 工作流实例服务实现类
 *
 * @author AllDataDC
 */
@Slf4j
@Service
public class WorkflowInstanceServiceImpl implements WorkflowInstanceService {

    @Autowired
    private RuntimeService runtimeService;

    @Autowired
    private ProcessEngine processEngine;

    @Override
    public Map<String, Object> pageRunning(int pageNum, int pageSize, String name) {
        ProcessInstanceQuery query = runtimeService.createProcessInstanceQuery();
        if (name != null && !name.isEmpty()) {
            query.processInstanceNameLike("%" + name + "%");
        }
        long total = query.count();
        List<ProcessInstance> list = query.listPage((pageNum - 1) * pageSize, pageSize);
        
        List<Map<String, Object>> data = new ArrayList<>();
        for (ProcessInstance instance : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", instance.getId());
            item.put("processDefinitionId", instance.getProcessDefinitionId());
            item.put("processDefinitionName", instance.getProcessDefinitionName());
            item.put("name", instance.getName());
            item.put("suspensionState", instance.isSuspended() ? "2" : "1");
            item.put("startTime", instance.getStartTime());
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
    public Map<String, Object> pageMyStarted(int pageNum, int pageSize, String name) {
        String currentUser = SecurityUtils.getCurrentUsername();
        HistoricProcessInstanceQuery query = processEngine.getHistoryService()
                .createHistoricProcessInstanceQuery()
                .startedBy(currentUser);
        if (name != null && !name.isEmpty()) {
            query.processInstanceNameLike("%" + name + "%");
        }
        long total = query.count();
        List<HistoricProcessInstance> list = query.listPage((pageNum - 1) * pageSize, pageSize);
        
        List<Map<String, Object>> data = new ArrayList<>();
        for (HistoricProcessInstance instance : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", instance.getId());
            item.put("processDefinitionId", instance.getProcessDefinitionId());
            item.put("processDefinitionName", instance.getProcessDefinitionName());
            item.put("name", instance.getName());
            item.put("suspensionState", instance.getEndTime() != null ? "3" : "1");
            item.put("startTime", instance.getStartTime());
            item.put("endTime", instance.getEndTime());
            // 计算耗时（毫秒）
            if (instance.getStartTime() != null && instance.getEndTime() != null) {
                long duration = instance.getDurationInMillis();
                item.put("durationInMillis", duration);
            } else if (instance.getStartTime() != null) {
                // 如果流程还在运行，计算到当前时间的耗时
                long duration = System.currentTimeMillis() - instance.getStartTime().getTime();
                item.put("durationInMillis", duration);
            } else {
                item.put("durationInMillis", 0L);
            }
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
    public Map<String, Object> pageMyInvolved(int pageNum, int pageSize, String name) {
        String currentUser = SecurityUtils.getCurrentUsername();
        HistoricProcessInstanceQuery query = processEngine.getHistoryService()
                .createHistoricProcessInstanceQuery()
                .involvedUser(currentUser);
        if (name != null && !name.isEmpty()) {
            query.processInstanceNameLike("%" + name + "%");
        }
        long total = query.count();
        List<HistoricProcessInstance> list = query.listPage((pageNum - 1) * pageSize, pageSize);
        
        List<Map<String, Object>> data = new ArrayList<>();
        for (HistoricProcessInstance instance : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", instance.getId());
            item.put("processDefinitionId", instance.getProcessDefinitionId());
            item.put("processDefinitionName", instance.getProcessDefinitionName());
            item.put("name", instance.getName());
            item.put("suspensionState", instance.getEndTime() != null ? "3" : "1");
            item.put("startTime", instance.getStartTime());
            item.put("endTime", instance.getEndTime());
            // 计算耗时（毫秒）
            if (instance.getStartTime() != null && instance.getEndTime() != null) {
                long duration = instance.getDurationInMillis();
                item.put("durationInMillis", duration);
            } else if (instance.getStartTime() != null) {
                // 如果流程还在运行，计算到当前时间的耗时
                long duration = System.currentTimeMillis() - instance.getStartTime().getTime();
                item.put("durationInMillis", duration);
            } else {
                item.put("durationInMillis", 0L);
            }
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
    public void deleteInstance(String processInstanceId) {
        runtimeService.deleteProcessInstance(processInstanceId, "用户删除");
    }

    @Override
    public void activateInstance(String processInstanceId) {
        runtimeService.activateProcessInstanceById(processInstanceId);
    }

    @Override
    public void suspendInstance(String processInstanceId) {
        runtimeService.suspendProcessInstanceById(processInstanceId);
    }

    @Override
    public byte[] getProcessImage(String processInstanceId) {
        try {
            ProcessInstance processInstance = runtimeService.createProcessInstanceQuery()
                    .processInstanceId(processInstanceId)
                    .singleResult();
            if (processInstance != null) {
                // 使用Flowable的DiagramGenerator生成流程图
                org.flowable.bpmn.model.BpmnModel bpmnModel = processEngine.getRepositoryService()
                        .getBpmnModel(processInstance.getProcessDefinitionId());
                java.util.List<String> activeActivityIds = processEngine.getRuntimeService()
                        .getActiveActivityIds(processInstanceId);
                InputStream inputStream = processEngine.getProcessEngineConfiguration()
                        .getProcessDiagramGenerator()
                        .generateDiagram(bpmnModel, "png", activeActivityIds, new java.util.ArrayList<String>(), false);
                if (inputStream != null) {
                    ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                    byte[] data = new byte[1024];
                    int nRead;
                    while ((nRead = inputStream.read(data, 0, data.length)) != -1) {
                        buffer.write(data, 0, nRead);
                    }
                    inputStream.close();
                    return buffer.toByteArray();
                }
            }
        } catch (Exception e) {
            log.error("获取流程图失败", e);
        }
        return new byte[0];
    }

    @Override
    public Map<String, Object> startInstance(String processDefinitionKey, String businessKey, String name, Map<String, Object> variables) {
        ProcessInstance processInstance;
        if (variables == null) {
            variables = new HashMap<>();
        }
        
        if (processDefinitionKey != null && !processDefinitionKey.isEmpty()) {
            // 使用ProcessInstanceBuilder构建流程实例
            org.flowable.engine.runtime.ProcessInstanceBuilder builder = runtimeService.createProcessInstanceBuilder()
                    .processDefinitionKey(processDefinitionKey)
                    .variables(variables);
            
            // 设置业务Key（如果提供）
            if (businessKey != null && !businessKey.isEmpty()) {
                builder.businessKey(businessKey);
            }
            
            // 设置流程实例名称（如果提供）
            if (name != null && !name.isEmpty()) {
                builder.name(name);
            }
            
            processInstance = builder.start();
        } else {
            throw new RuntimeException("流程定义Key不能为空");
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("id", processInstance.getId());
        result.put("processDefinitionId", processInstance.getProcessDefinitionId());
        result.put("processDefinitionName", processInstance.getProcessDefinitionName());
        result.put("name", processInstance.getName());
        result.put("businessKey", processInstance.getBusinessKey());
        return result;
    }
}
