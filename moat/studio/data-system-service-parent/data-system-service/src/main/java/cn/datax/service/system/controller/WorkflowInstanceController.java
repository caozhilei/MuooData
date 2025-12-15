package cn.datax.service.system.controller;

import cn.datax.common.core.R;
import cn.datax.service.system.service.WorkflowInstanceService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import cn.datax.common.base.BaseController;

import java.util.Map;

/**
 * 工作流实例控制器
 *
 * @author AllDataDC
 */
@Api(value="工作流实例管理接口", tags = {"工作流实例管理"})
@RestController
@RequestMapping("/workflow/instances")
public class WorkflowInstanceController extends BaseController {

    @Autowired
    private WorkflowInstanceService workflowInstanceService;

    @ApiOperation(value = "分页查询运行中的流程实例", notes = "")
    @GetMapping("/pageRunning")
    public R pageRunning(@RequestParam(defaultValue = "1") int pageNum,
                         @RequestParam(defaultValue = "20") int pageSize,
                         @RequestParam(required = false) String name) {
        Map<String, Object> result = workflowInstanceService.pageRunning(pageNum, pageSize, name);
        return R.ok().setData(result);
    }

    @ApiOperation(value = "分页查询我发起的流程实例", notes = "")
    @GetMapping("/pageMyStarted")
    public R pageMyStarted(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "20") int pageSize,
                           @RequestParam(required = false) String name) {
        Map<String, Object> result = workflowInstanceService.pageMyStarted(pageNum, pageSize, name);
        return R.ok().setData(result);
    }

    @ApiOperation(value = "分页查询我参与的流程实例", notes = "")
    @GetMapping("/pageMyInvolved")
    public R pageMyInvolved(@RequestParam(defaultValue = "1") int pageNum,
                            @RequestParam(defaultValue = "20") int pageSize,
                            @RequestParam(required = false) String name) {
        Map<String, Object> result = workflowInstanceService.pageMyInvolved(pageNum, pageSize, name);
        return R.ok().setData(result);
    }

    @ApiOperation(value = "删除流程实例", notes = "")
    @DeleteMapping("/{processInstanceId}")
    public R deleteInstance(@PathVariable String processInstanceId) {
        workflowInstanceService.deleteInstance(processInstanceId);
        return R.ok();
    }

    @ApiOperation(value = "激活流程实例", notes = "")
    @PutMapping("/activate/{processInstanceId}")
    public R activateInstance(@PathVariable String processInstanceId) {
        workflowInstanceService.activateInstance(processInstanceId);
        return R.ok();
    }

    @ApiOperation(value = "挂起流程实例", notes = "")
    @PutMapping("/suspend/{processInstanceId}")
    public R suspendInstance(@PathVariable String processInstanceId) {
        workflowInstanceService.suspendInstance(processInstanceId);
        return R.ok();
    }

    @ApiOperation(value = "获取流程图", notes = "")
    @GetMapping("/track")
    public byte[] flowTrack(@RequestParam String processInstanceId) {
        return workflowInstanceService.getProcessImage(processInstanceId);
    }

    @ApiOperation(value = "启动流程实例", notes = "")
    @PostMapping("/start")
    public R startInstance(@RequestParam String processDefinitionKey,
                          @RequestParam(required = false) String businessKey,
                          @RequestParam(required = false) String name,
                          @RequestBody(required = false) Map<String, Object> variables) {
        Map<String, Object> result = workflowInstanceService.startInstance(processDefinitionKey, businessKey, name, variables);
        return R.ok().setData(result);
    }
}
