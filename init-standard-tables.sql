-- ============================================
-- 数据标准模块表初始化脚本
-- ============================================

SET FOREIGN_KEY_CHECKS=0;

USE `alldata`;

-- ============================================
-- 1. 数据标准类别表 (standard_type)
-- ============================================

-- 检查表是否存在，不存在则创建
CREATE TABLE IF NOT EXISTS `standard_type` (
  `id` varchar(64) NOT NULL COMMENT '主键ID',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态（0禁用 1启用）',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_dept` varchar(64) DEFAULT NULL COMMENT '创建部门',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `gb_type_code` varchar(100) DEFAULT NULL COMMENT '标准类别编码',
  `gb_type_name` varchar(200) DEFAULT NULL COMMENT '标准类别名称',
  PRIMARY KEY (`id`),
  KEY `idx_gb_type_code` (`gb_type_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据标准类别表';

-- 检查是否有数据，如果没有则插入初始数据
INSERT INTO `standard_type` (`id`, `status`, `create_by`, `create_time`, `create_dept`, `update_by`, `update_time`, `remark`, `gb_type_code`, `gb_type_name`)
SELECT * FROM (SELECT '1303245849463218178' as `id`, 1 as `status`, '1214835832967581698' as `create_by`, '2020-09-08 16:16:38' as `create_time`, '1197789917762031617' as `create_dept`, '1214835832967581698' as `update_by`, '2020-09-08 16:16:38' as `update_time`, NULL as `remark`, 'GB/T 2261.1-2003' as `gb_type_code`, '人的性别代码' as `gb_type_name`) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM `standard_type` WHERE `id` = '1303245849463218178')
LIMIT 1;

INSERT INTO `standard_type` (`id`, `status`, `create_by`, `create_time`, `create_dept`, `update_by`, `update_time`, `remark`, `gb_type_code`, `gb_type_name`)
SELECT * FROM (SELECT '1303245946938843137' as `id`, 1 as `status`, '1214835832967581698' as `create_by`, '2020-09-08 16:17:02' as `create_time`, '1197789917762031617' as `create_dept`, '1214835832967581698' as `update_by`, '2020-09-08 16:17:02' as `update_time`, NULL as `remark`, 'GB/T 2261.2-2003' as `gb_type_code`, '婚姻状况代码' as `gb_type_name`) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM `standard_type` WHERE `id` = '1303245946938843137')
LIMIT 1;

INSERT INTO `standard_type` (`id`, `status`, `create_by`, `create_time`, `create_dept`, `update_by`, `update_time`, `remark`, `gb_type_code`, `gb_type_name`)
SELECT * FROM (SELECT '1303246143370682369' as `id`, 1 as `status`, '1214835832967581698' as `create_by`, '2020-09-08 16:17:48' as `create_time`, '1197789917762031617' as `create_dept`, '1214835832967581698' as `update_by`, '2020-09-08 16:17:48' as `update_time`, NULL as `remark`, 'GB/T 2261.4-2003' as `gb_type_code`, '从业状况(个人身份)代码' as `gb_type_name`) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM `standard_type` WHERE `id` = '1303246143370682369')
LIMIT 1;

INSERT INTO `standard_type` (`id`, `status`, `create_by`, `create_time`, `create_dept`, `update_by`, `update_time`, `remark`, `gb_type_code`, `gb_type_name`)
SELECT * FROM (SELECT '1303246245158051841' as `id`, 1 as `status`, '1214835832967581698' as `create_by`, '2020-09-08 16:18:13' as `create_time`, '1197789917762031617' as `create_dept`, '1214835832967581698' as `update_by`, '2020-09-08 16:18:13' as `update_time`, NULL as `remark`, 'GB/T 2261.5-2003' as `gb_type_code`, '港澳台侨属代码' as `gb_type_name`) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM `standard_type` WHERE `id` = '1303246245158051841')
LIMIT 1;

INSERT INTO `standard_type` (`id`, `status`, `create_by`, `create_time`, `create_dept`, `update_by`, `update_time`, `remark`, `gb_type_code`, `gb_type_name`)
SELECT * FROM (SELECT '1303246401513316353' as `id`, 1 as `status`, '1214835832967581698' as `create_by`, '2020-09-08 16:18:50' as `create_time`, '1197789917762031617' as `create_dept`, '1214835832967581698' as `update_by`, '2020-09-08 16:18:50' as `update_time`, NULL as `remark`, 'GB/T 2261.7-2003' as `gb_type_code`, '院士代码' as `gb_type_name`) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM `standard_type` WHERE `id` = '1303246401513316353')
LIMIT 1;

-- ============================================
-- 2. 数据标准字典表 (standard_dict)
-- ============================================

CREATE TABLE IF NOT EXISTS `standard_dict` (
  `id` varchar(64) NOT NULL COMMENT '主键ID',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态（0禁用 1启用）',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_dept` varchar(64) DEFAULT NULL COMMENT '创建部门',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `type_id` varchar(64) DEFAULT NULL COMMENT '所属类别',
  `gb_code` varchar(100) DEFAULT NULL COMMENT '标准编码',
  `gb_name` varchar(200) DEFAULT NULL COMMENT '标准名称',
  PRIMARY KEY (`id`),
  KEY `idx_type_id` (`type_id`),
  KEY `idx_gb_code` (`gb_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据标准字典表';

-- ============================================
-- 3. 对照表 (standard_contrast)
-- ============================================

CREATE TABLE IF NOT EXISTS `standard_contrast` (
  `id` varchar(64) NOT NULL COMMENT '主键ID',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态（0禁用 1启用）',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_dept` varchar(64) DEFAULT NULL COMMENT '创建部门',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `source_id` varchar(64) DEFAULT NULL COMMENT '数据源ID',
  `source_name` varchar(200) DEFAULT NULL COMMENT '数据源名称',
  `table_id` varchar(64) DEFAULT NULL COMMENT '数据表ID',
  `table_name` varchar(200) DEFAULT NULL COMMENT '数据表名称',
  `column_id` varchar(64) DEFAULT NULL COMMENT '字段ID',
  `column_name` varchar(200) DEFAULT NULL COMMENT '字段名称',
  `type_id` varchar(64) DEFAULT NULL COMMENT '标准类别ID',
  `gb_code` varchar(100) DEFAULT NULL COMMENT '标准编码',
  PRIMARY KEY (`id`),
  KEY `idx_source_id` (`source_id`),
  KEY `idx_table_id` (`table_id`),
  KEY `idx_column_id` (`column_id`),
  KEY `idx_type_id` (`type_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='对照表';

-- ============================================
-- 4. 对照字典表 (standard_contrast_dict)
-- ============================================

CREATE TABLE IF NOT EXISTS `standard_contrast_dict` (
  `id` varchar(64) NOT NULL COMMENT '主键ID',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态（0禁用 1启用）',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_dept` varchar(64) DEFAULT NULL COMMENT '创建部门',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `contrast_id` varchar(64) DEFAULT NULL COMMENT '对照表ID',
  `col_code` varchar(100) DEFAULT NULL COMMENT '字典编码',
  `col_name` varchar(200) DEFAULT NULL COMMENT '字典名称',
  `contrast_gb_id` varchar(64) DEFAULT NULL COMMENT '对照标准字典ID',
  PRIMARY KEY (`id`),
  KEY `idx_contrast_id` (`contrast_id`),
  KEY `idx_contrast_gb_id` (`contrast_gb_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='对照字典表';

SET FOREIGN_KEY_CHECKS=1;

-- ============================================
-- 验证数据
-- ============================================

-- 查询数据标准类别数量
SELECT COUNT(*) as '数据标准类别数量' FROM `standard_type` WHERE `status` = 1;

-- 查询对照表数量
SELECT COUNT(*) as '对照表数量' FROM `standard_contrast` WHERE `status` = 1;

-- 显示数据标准类别列表
SELECT `id`, `gb_type_code`, `gb_type_name`, `status` FROM `standard_type` WHERE `status` = 1 ORDER BY `create_time` DESC;

