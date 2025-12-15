package cn.datax.service.system.service.impl;

import cn.datax.common.utils.SecurityUtils;
import cn.datax.service.system.service.WorkflowTaskService;
import lombok.extern.slf4j.Slf4j;
import org.flowable.engine.ProcessEngine;
import org.flowable.engine.TaskService;
import org.flowable.task.api.Task;
import org.flowable.task.api.TaskQuery;
import org.flowable.task.api.history.HistoricTaskInstance;
import org.flowable.task.api.history.HistoricTaskInstanceQuery;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 工作流任务服务实现类
 *
 * @author AllDataDC
 */
@Slf4j
@Service
public class WorkflowTaskServiceImpl implements WorkflowTaskService {

    @Autowired
    private TaskService taskService;

    @Autowired
    private ProcessEngine processEngine;

    @Override
    public Map<String, Object> pageTodo(int pageNum, int pageSize, String name) {
        String currentUser = SecurityUtils.getCurrentUsername();
        // 查询已分配给当前用户的任务
        TaskQuery assignedQuery = taskService.createTaskQuery()
                .taskAssignee(currentUser);
        if (name != null && !name.isEmpty()) {
            assignedQuery.taskNameLike("%" + name + "%");
        }
        
        // 查询候选任务（未签收的任务）
        TaskQuery candidateQuery = taskService.createTaskQuery()
                .taskCandidateUser(currentUser);
        if (name != null && !name.isEmpty()) {
            candidateQuery.taskNameLike("%" + name + "%");
        }
        
        // 合并两个查询结果
        List<Task> assignedList = assignedQuery.list();
        List<Task> candidateList = candidateQuery.list();
        
        // 使用Set去重（基于任务ID）
        Map<String, Task> taskMap = new HashMap<>();
        for (Task task : assignedList) {
            taskMap.put(task.getId(), task);
        }
        for (Task task : candidateList) {
            taskMap.put(task.getId(), task);
        }
        
        List<Task> allTasks = new ArrayList<>(taskMap.values());
        long total = allTasks.size();
        
        // 手动分页
        int start = (pageNum - 1) * pageSize;
        int end = Math.min(start + pageSize, allTasks.size());
        List<Task> list = allTasks.subList(start, end);
        
        List<Map<String, Object>> data = new ArrayList<>();
        for (Task task : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", task.getId());
            item.put("name", task.getName());
            item.put("processInstanceId", task.getProcessInstanceId());
            item.put("createTime", task.getCreateTime());
            item.put("dueDate", task.getDueDate());
            item.put("assignee", task.getAssignee());
            
            // 获取流程实例信息以获取业务信息
            if (task.getProcessInstanceId() != null) {
                try {
                    org.flowable.engine.runtime.ProcessInstance processInstance = processEngine.getRuntimeService()
                            .createProcessInstanceQuery()
                            .processInstanceId(task.getProcessInstanceId())
                            .singleResult();
                    if (processInstance != null) {
                        String businessKey = processInstance.getBusinessKey();
                        if (businessKey != null && !businessKey.isEmpty()) {
                            item.put("businessCode", businessKey);
                            item.put("businessName", businessKey); // 如果没有业务名称映射，使用businessKey
                        }
                    }
                } catch (Exception e) {
                    log.warn("获取流程实例业务信息失败: {}", e.getMessage());
                }
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
    public Map<String, Object> pageDone(int pageNum, int pageSize, String name) {
        String currentUser = SecurityUtils.getCurrentUsername();
        HistoricTaskInstanceQuery query = processEngine.getHistoryService()
                .createHistoricTaskInstanceQuery()
                .taskAssignee(currentUser)
                .finished();
        if (name != null && !name.isEmpty()) {
            query.taskNameLike("%" + name + "%");
        }
        long total = query.count();
        List<HistoricTaskInstance> list = query.listPage((pageNum - 1) * pageSize, pageSize);
        
        List<Map<String, Object>> data = new ArrayList<>();
        for (HistoricTaskInstance task : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", task.getId());
            item.put("name", task.getName());
            item.put("processInstanceId", task.getProcessInstanceId());
            item.put("createTime", task.getCreateTime());
            item.put("endTime", task.getEndTime());
            item.put("assignee", task.getAssignee());
            
            // 计算耗时（毫秒）
            if (task.getCreateTime() != null && task.getEndTime() != null) {
                long duration = task.getDurationInMillis();
                item.put("durationInMillis", duration);
            } else {
                item.put("durationInMillis", 0L);
            }
            
            // 获取流程实例信息以获取业务信息
            if (task.getProcessInstanceId() != null) {
                try {
                    org.flowable.engine.history.HistoricProcessInstance historicProcessInstance = processEngine.getHistoryService()
                            .createHistoricProcessInstanceQuery()
                            .processInstanceId(task.getProcessInstanceId())
                            .singleResult();
                    if (historicProcessInstance != null) {
                        String businessKey = historicProcessInstance.getBusinessKey();
                        if (businessKey != null && !businessKey.isEmpty()) {
                            item.put("businessCode", businessKey);
                            item.put("businessName", businessKey); // 如果没有业务名称映射，使用businessKey
                        }
                    }
                } catch (Exception e) {
                    log.warn("获取历史流程实例业务信息失败: {}", e.getMessage());
                }
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
    public void executeTask(String taskId, Map<String, Object> variables) {
        taskService.complete(taskId, variables);
    }
}
