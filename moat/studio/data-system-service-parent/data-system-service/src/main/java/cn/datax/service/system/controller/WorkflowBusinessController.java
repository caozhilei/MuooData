package cn.datax.service.system.controller;

import cn.datax.common.core.R;
import cn.datax.service.system.service.WorkflowBusinessService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import cn.datax.common.base.BaseController;

import java.util.Map;

/**
 * 工作流业务控制器
 *
 * @author AllDataDC
 */
@Api(value="工作流业务管理接口", tags = {"工作流业务管理"})
@RestController
@RequestMapping("/workflow/business")
public class WorkflowBusinessController extends BaseController {

    @Autowired
    private WorkflowBusinessService workflowBusinessService;

    @ApiOperation(value = "刷新业务列表", notes = "")
    @GetMapping("/refresh")
    public R refreshBusiness() {
        workflowBusinessService.refreshBusiness();
        return R.ok();
    }

    @ApiOperation(value = "分页查询业务列表", notes = "")
    @GetMapping("/page")
    public R pageBusiness(@RequestParam(defaultValue = "1") int pageNum,
                          @RequestParam(defaultValue = "20") int pageSize,
                          @RequestParam(required = false) String name) {
        Map<String, Object> result = workflowBusinessService.pageBusiness(pageNum, pageSize, name);
        return R.ok().setData(result);
    }

    @ApiOperation(value = "获取业务详细信息", notes = "")
    @GetMapping("/{id}")
    public R getBusiness(@PathVariable String id) {
        Map<String, Object> business = workflowBusinessService.getBusinessById(id);
        return R.ok().setData(business);
    }

    @ApiOperation(value = "删除业务", notes = "")
    @DeleteMapping("/{id}")
    public R deleteBusiness(@PathVariable String id) {
        workflowBusinessService.deleteBusiness(id);
        return R.ok();
    }

    @ApiOperation(value = "新增业务", notes = "")
    @PostMapping
    public R addBusiness(@RequestBody Map<String, Object> business) {
        workflowBusinessService.addBusiness(business);
        return R.ok();
    }

    @ApiOperation(value = "更新业务", notes = "")
    @PutMapping("/{id}")
    public R updateBusiness(@PathVariable String id, @RequestBody Map<String, Object> business) {
        workflowBusinessService.updateBusiness(id, business);
        return R.ok();
    }
}
