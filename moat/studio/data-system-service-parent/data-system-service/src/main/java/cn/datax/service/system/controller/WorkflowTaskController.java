package cn.datax.service.system.controller;

import cn.datax.common.core.R;
import cn.datax.service.system.service.WorkflowTaskService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import cn.datax.common.base.BaseController;

import java.util.Map;

/**
 * 工作流任务控制器
 *
 * @author AllDataDC
 */
@Api(value="工作流任务管理接口", tags = {"工作流任务管理"})
@RestController
@RequestMapping("/workflow/tasks")
public class WorkflowTaskController extends BaseController {

    @Autowired
    private WorkflowTaskService workflowTaskService;

    @ApiOperation(value = "分页查询待办任务", notes = "")
    @GetMapping("/pageTodo")
    public R pageTodo(@RequestParam(defaultValue = "1") int pageNum,
                      @RequestParam(defaultValue = "20") int pageSize,
                      @RequestParam(required = false) String name) {
        Map<String, Object> result = workflowTaskService.pageTodo(pageNum, pageSize, name);
        return R.ok().setData(result);
    }

    @ApiOperation(value = "分页查询已办任务", notes = "")
    @GetMapping("/pageDone")
    public R pageDone(@RequestParam(defaultValue = "1") int pageNum,
                      @RequestParam(defaultValue = "20") int pageSize,
                      @RequestParam(required = false) String name) {
        Map<String, Object> result = workflowTaskService.pageDone(pageNum, pageSize, name);
        return R.ok().setData(result);
    }

    @ApiOperation(value = "执行任务", notes = "")
    @PostMapping("/execute/{taskId}")
    public R executeTask(@PathVariable String taskId, @RequestBody(required = false) Map<String, Object> variables) {
        if (variables == null) {
            variables = new java.util.HashMap<>();
        }
        workflowTaskService.executeTask(taskId, variables);
        return R.ok();
    }
}
