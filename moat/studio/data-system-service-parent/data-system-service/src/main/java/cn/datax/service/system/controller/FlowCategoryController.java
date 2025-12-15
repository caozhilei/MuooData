package cn.datax.service.system.controller;

import cn.datax.common.core.DataConstant;
import cn.datax.common.core.R;
import cn.datax.service.system.api.entity.FlowCategoryEntity;
import cn.datax.service.system.api.vo.FlowCategoryVo;
import cn.datax.service.system.mapstruct.FlowCategoryMapper;
import cn.datax.service.system.service.FlowCategoryService;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import cn.datax.common.base.BaseController;

import java.util.List;
import java.util.stream.Collectors;

/**
 * <p>
 * 流程分类表 前端控制器
 * </p>
 *
 * @author AllDataDC
 * @date 2022-11-26
 */
@Api(value="工作流管理接口", tags = {"工作流管理"})
@RestController
@RequestMapping("/workflow/categorys")
public class FlowCategoryController extends BaseController {

    @Autowired
    private FlowCategoryService flowCategoryService;

    @Autowired
    private FlowCategoryMapper flowCategoryMapper;

    @ApiOperation(value = "获取流程分类列表", notes = "")
    @GetMapping("/list")
    public R getFlowCategoryList() {
        QueryWrapper<FlowCategoryEntity> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", DataConstant.EnableState.ENABLE.getKey());
        List<FlowCategoryEntity> list = flowCategoryService.list(queryWrapper);
        List<FlowCategoryVo> collect = list.stream().map(flowCategoryMapper::toVO).collect(Collectors.toList());
        return R.ok().setData(collect);
    }

    @ApiOperation(value = "获取流程分类详细信息", notes = "根据url的id来获取详细信息")
    @GetMapping("/{id}")
    public R getFlowCategoryById(@PathVariable String id) {
        FlowCategoryEntity entity = flowCategoryService.getById(id);
        return R.ok().setData(flowCategoryMapper.toVO(entity));
    }

    @ApiOperation(value = "创建流程分类", notes = "根据flowCategory对象创建流程分类")
    @PostMapping
    public R saveFlowCategory(@RequestBody FlowCategoryEntity flowCategory) {
        flowCategoryService.save(flowCategory);
        return R.ok().setData(flowCategoryMapper.toVO(flowCategory));
    }

    @ApiOperation(value = "更新流程分类详细信息", notes = "根据url的id来指定更新对象")
    @PutMapping("/{id}")
    public R updateFlowCategory(@PathVariable String id, @RequestBody FlowCategoryEntity flowCategory) {
        flowCategory.setId(id);
        flowCategoryService.updateById(flowCategory);
        return R.ok().setData(flowCategoryMapper.toVO(flowCategory));
    }

    @ApiOperation(value = "删除流程分类", notes = "根据url的id来指定删除对象")
    @DeleteMapping("/{id}")
    public R deleteFlowCategory(@PathVariable String id) {
        flowCategoryService.removeById(id);
        return R.ok();
    }
}

