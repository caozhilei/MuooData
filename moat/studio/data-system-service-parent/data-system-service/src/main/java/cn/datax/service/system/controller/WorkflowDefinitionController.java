package cn.datax.service.system.controller;

import cn.datax.common.core.R;
import cn.datax.service.system.service.WorkflowDefinitionService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import cn.datax.common.base.BaseController;

import java.util.Map;

/**
 * 工作流定义控制器
 *
 * @author AllDataDC
 */
@Api(value="工作流定义管理接口", tags = {"工作流定义管理"})
@RestController
@RequestMapping("/workflow/definitions")
public class WorkflowDefinitionController extends BaseController {

    @Autowired
    private WorkflowDefinitionService workflowDefinitionService;

    @ApiOperation(value = "分页查询流程定义", notes = "")
    @GetMapping("/page")
    public R pageDefinition(@RequestParam(defaultValue = "1") int pageNum,
                            @RequestParam(defaultValue = "20") int pageSize,
                            @RequestParam(required = false) String category) {
        Map<String, Object> result = workflowDefinitionService.pageDefinition(pageNum, pageSize, category);
        return R.ok().setData(result);
    }

    @ApiOperation(value = "删除流程定义", notes = "")
    @DeleteMapping("/delete/{deploymentId}")
    public R deleteDefinition(@PathVariable String deploymentId) {
        workflowDefinitionService.deleteDefinition(deploymentId);
        return R.ok();
    }

    @ApiOperation(value = "激活流程定义", notes = "")
    @PutMapping("/activate/{processDefinitionId}")
    public R activateDefinition(@PathVariable String processDefinitionId) {
        workflowDefinitionService.activateDefinition(processDefinitionId);
        return R.ok();
    }

    @ApiOperation(value = "挂起流程定义", notes = "")
    @PutMapping("/suspend/{processDefinitionId}")
    public R suspendDefinition(@PathVariable String processDefinitionId) {
        workflowDefinitionService.suspendDefinition(processDefinitionId);
        return R.ok();
    }

    @ApiOperation(value = "部署流程定义", notes = "")
    @PostMapping("/import/file")
    public R deployDefinition(@RequestParam("file") MultipartFile file,
                              @RequestParam(required = false) String category,
                              @RequestParam(required = false) String name) {
        String fileName = file.getOriginalFilename();
        if (name == null || name.isEmpty()) {
            name = fileName != null ? fileName.substring(0, fileName.lastIndexOf('.')) : "未命名流程";
        }
        workflowDefinitionService.deployDefinition(file, category, name);
        return R.ok();
    }

    @ApiOperation(value = "获取流程资源", notes = "")
    @GetMapping("/resource")
    public byte[] flowResource(@RequestParam String processDefinitionId,
                                @RequestParam(defaultValue = "image") String resType) {
        return workflowDefinitionService.getProcessResource(processDefinitionId, resType);
    }
}
