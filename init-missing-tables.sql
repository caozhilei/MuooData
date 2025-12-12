SET FOREIGN_KEY_CHECKS=0;

USE `alldata`;

-- ============================================
-- Quartz 表初始化
-- ============================================

-- QRTZ_JOB_DETAILS 表（必须先创建，因为有外键依赖）
CREATE TABLE IF NOT EXISTS `QRTZ_JOB_DETAILS` (
    `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
    `job_name` varchar(200) NOT NULL COMMENT '任务名称',
    `job_group` varchar(200) NOT NULL COMMENT '任务组名',
    `description` varchar(250) DEFAULT NULL COMMENT '相关介绍',
    `job_class_name` varchar(250) NOT NULL COMMENT '执行任务类名称',
    `is_durable` varchar(1) NOT NULL COMMENT '是否持久化',
    `is_nonconcurrent` varchar(1) NOT NULL COMMENT '是否并发',
    `is_update_data` varchar(1) NOT NULL COMMENT '是否更新数据',
    `requests_recovery` varchar(1) NOT NULL COMMENT '是否接受恢复执行',
    `job_data` blob COMMENT '存放持久化job对象',
    PRIMARY KEY (`sched_name`,`job_name`,`job_group`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务详细信息表';

-- QRTZ_TRIGGERS 表
CREATE TABLE IF NOT EXISTS `QRTZ_TRIGGERS` (
    `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
    `trigger_name` varchar(200) NOT NULL COMMENT '触发器的名字',
    `trigger_group` varchar(200) NOT NULL COMMENT '触发器所属组的名字',
    `job_name` varchar(200) NOT NULL COMMENT 'qrtz_job_details表job_name的外键',
    `job_group` varchar(200) NOT NULL COMMENT 'qrtz_job_details表job_group的外键',
    `description` varchar(250) DEFAULT NULL COMMENT '相关介绍',
    `next_fire_time` bigint(13) DEFAULT NULL COMMENT '上一次触发时间（毫秒）',
    `prev_fire_time` bigint(13) DEFAULT NULL COMMENT '下一次触发时间（默认为-1表示不触发）',
    `priority` int(11) DEFAULT NULL COMMENT '优先级',
    `trigger_state` varchar(16) NOT NULL COMMENT '触发器状态',
    `trigger_type` varchar(8) NOT NULL COMMENT '触发器的类型',
    `start_time` bigint(13) NOT NULL COMMENT '开始时间',
    `end_time` bigint(13) DEFAULT NULL COMMENT '结束时间',
    `calendar_name` varchar(200) DEFAULT NULL COMMENT '日程表名称',
    `misfire_instr` smallint(2) DEFAULT NULL COMMENT '补偿执行的策略',
    `job_data` blob COMMENT '存放持久化job对象',
    PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
    KEY `sched_name` (`sched_name`,`job_name`,`job_group`),
    CONSTRAINT `QRTZ_TRIGGERS_ibfk_1` FOREIGN KEY (`sched_name`, `job_name`, `job_group`) REFERENCES `QRTZ_JOB_DETAILS` (`sched_name`, `job_name`, `job_group`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='触发器详细信息表';

-- QRTZ_LOCKS 表（Quartz Service 需要）
CREATE TABLE IF NOT EXISTS `QRTZ_LOCKS` (
    `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
    `lock_name` varchar(40) NOT NULL COMMENT '悲观锁名称',
    PRIMARY KEY (`sched_name`,`lock_name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='存储的悲观锁信息表';

-- QRTZ_PAUSED_TRIGGER_GRPS 表
CREATE TABLE IF NOT EXISTS `QRTZ_PAUSED_TRIGGER_GRPS` (
    `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
    `trigger_group` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
    PRIMARY KEY (`sched_name`,`trigger_group`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='暂停的触发器表';

-- QRTZ_SCHEDULER_STATE 表
CREATE TABLE IF NOT EXISTS `QRTZ_SCHEDULER_STATE` (
    `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
    `instance_name` varchar(200) NOT NULL COMMENT '实例名称',
    `last_checkin_time` bigint(13) NOT NULL COMMENT '上次检查时间',
    `checkin_interval` bigint(13) NOT NULL COMMENT '检查间隔时间',
    PRIMARY KEY (`sched_name`,`instance_name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='调度器状态表';

-- QRTZ_SIMPLE_TRIGGERS 表
CREATE TABLE IF NOT EXISTS `QRTZ_SIMPLE_TRIGGERS` (
    `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
    `trigger_name` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
    `trigger_group` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
    `repeat_count` bigint(7) NOT NULL COMMENT '重复的次数统计',
    `repeat_interval` bigint(12) NOT NULL COMMENT '重复的间隔时间',
    `times_triggered` bigint(10) NOT NULL COMMENT '已经触发的次数',
    PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
    CONSTRAINT `QRTZ_SIMPLE_TRIGGERS_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `QRTZ_TRIGGERS` (`sched_name`, `trigger_name`, `trigger_group`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='简单触发器的信息表';

-- QRTZ_CRON_TRIGGERS 表
CREATE TABLE IF NOT EXISTS `QRTZ_CRON_TRIGGERS` (
    `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
    `trigger_name` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
    `trigger_group` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
    `cron_expression` varchar(200) NOT NULL COMMENT 'cron表达式',
    `time_zone_id` varchar(80) DEFAULT NULL COMMENT '时区',
    PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
    CONSTRAINT `QRTZ_CRON_TRIGGERS_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `QRTZ_TRIGGERS` (`sched_name`, `trigger_name`, `trigger_group`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Cron类型的触发器表';

-- QRTZ_BLOB_TRIGGERS 表
CREATE TABLE IF NOT EXISTS `QRTZ_BLOB_TRIGGERS` (
    `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
    `trigger_name` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
    `trigger_group` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
    `blob_data` blob COMMENT '存放持久化Trigger对象',
    PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
    CONSTRAINT `QRTZ_BLOB_TRIGGERS_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `QRTZ_TRIGGERS` (`sched_name`, `trigger_name`, `trigger_group`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Blob类型的触发器表';

-- QRTZ_SIMPROP_TRIGGERS 表
CREATE TABLE IF NOT EXISTS `QRTZ_SIMPROP_TRIGGERS` (
    `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
    `trigger_name` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
    `trigger_group` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
    `str_prop_1` varchar(512) DEFAULT NULL COMMENT 'String类型的trigger的第一个参数',
    `str_prop_2` varchar(512) DEFAULT NULL COMMENT 'String类型的trigger的第二个参数',
    `str_prop_3` varchar(512) DEFAULT NULL COMMENT 'String类型的trigger的第三个参数',
    `int_prop_1` int(11) DEFAULT NULL COMMENT 'int类型的trigger的第一个参数',
    `int_prop_2` int(11) DEFAULT NULL COMMENT 'int类型的trigger的第二个参数',
    `long_prop_1` bigint(20) DEFAULT NULL COMMENT 'long类型的trigger的第一个参数',
    `long_prop_2` bigint(20) DEFAULT NULL COMMENT 'long类型的trigger的第二个参数',
    `dec_prop_1` decimal(13,4) DEFAULT NULL COMMENT 'decimal类型的trigger的第一个参数',
    `dec_prop_2` decimal(13,4) DEFAULT NULL COMMENT 'decimal类型的trigger的第二个参数',
    `bool_prop_1` varchar(1) DEFAULT NULL COMMENT 'Boolean类型的trigger的第一个参数',
    `bool_prop_2` varchar(1) DEFAULT NULL COMMENT 'Boolean类型的trigger的第二个参数',
    PRIMARY KEY (`sched_name`,`trigger_name`,`trigger_group`),
    CONSTRAINT `QRTZ_SIMPROP_TRIGGERS_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `QRTZ_TRIGGERS` (`sched_name`, `trigger_name`, `trigger_group`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='同步机制的行锁表';

-- QRTZ_CALENDARS 表
CREATE TABLE IF NOT EXISTS `QRTZ_CALENDARS` (
    `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
    `calendar_name` varchar(200) NOT NULL COMMENT '日历名称',
    `calendar` blob NOT NULL COMMENT '存放持久化calendar对象',
    PRIMARY KEY (`sched_name`,`calendar_name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='日历信息表';

-- QRTZ_FIRED_TRIGGERS 表
CREATE TABLE IF NOT EXISTS `QRTZ_FIRED_TRIGGERS` (
    `sched_name` varchar(120) NOT NULL COMMENT '调度名称',
    `entry_id` varchar(95) NOT NULL COMMENT '调度器实例id',
    `trigger_name` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
    `trigger_group` varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
    `instance_name` varchar(200) NOT NULL COMMENT '调度器实例名',
    `fired_time` bigint(13) NOT NULL COMMENT '触发的时间',
    `sched_time` bigint(13) NOT NULL COMMENT '定时器制定的时间',
    `priority` int(11) NOT NULL COMMENT '优先级',
    `state` varchar(16) NOT NULL COMMENT '状态',
    `job_name` varchar(200) DEFAULT NULL COMMENT '任务名称',
    `job_group` varchar(200) DEFAULT NULL COMMENT '任务组名',
    `is_nonconcurrent` varchar(1) DEFAULT NULL COMMENT '是否并发',
    `requests_recovery` varchar(1) DEFAULT NULL COMMENT '是否接受恢复执行',
    PRIMARY KEY (`sched_name`,`entry_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='已触发的触发器表';

-- ============================================
-- Data Compare Service 表初始化
-- ============================================

-- system_dc_dict_data 表（Data Compare Service 需要）
CREATE TABLE IF NOT EXISTS `system_dc_dict_data` (
    `dict_code` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '字典编码',
    `dict_sort` int(4) DEFAULT '0' COMMENT '字典排序',
    `dict_label` varchar(100) DEFAULT '' COMMENT '字典标签',
    `dict_value` varchar(100) DEFAULT '' COMMENT '字典键值',
    `dict_type` varchar(100) DEFAULT '' COMMENT '字典类型',
    `css_class` varchar(100) DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
    `list_class` varchar(100) DEFAULT NULL COMMENT '表格回显样式',
    `is_default` char(1) DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
    `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1停用）',
    `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
    `create_time` datetime DEFAULT NULL COMMENT '创建时间',
    `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
    `update_time` datetime DEFAULT NULL COMMENT '更新时间',
    `remark` varchar(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`dict_code`)
    ) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8 COMMENT='字典数据表';

-- system_dc_dict_type 表
CREATE TABLE IF NOT EXISTS `system_dc_dict_type` (
    `dict_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '字典主键',
    `dict_name` varchar(100) DEFAULT '' COMMENT '字典名称',
    `dict_type` varchar(100) DEFAULT '' COMMENT '字典类型',
    `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1停用）',
    `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
    `create_time` datetime DEFAULT NULL COMMENT '创建时间',
    `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
    `update_time` datetime DEFAULT NULL COMMENT '更新时间',
    `remark` varchar(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`dict_id`),
    UNIQUE KEY `dict_type` (`dict_type`)
    ) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8 COMMENT='字典类型表';

-- system_dc_job 表（Data Compare Service 需要）
CREATE TABLE IF NOT EXISTS `system_dc_job` (
    `job_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '任务ID',
    `job_name` varchar(64) NOT NULL DEFAULT '' COMMENT '任务名称',
    `job_group` varchar(64) NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
    `invoke_target` varchar(500) NOT NULL COMMENT '调用目标字符串',
    `cron_expression` varchar(255) DEFAULT '' COMMENT 'cron执行表达式',
    `misfire_policy` varchar(20) DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
    `concurrent` char(1) DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
    `status` char(1) DEFAULT '0' COMMENT '状态（0正常 1暂停）',
    `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
    `create_time` datetime DEFAULT NULL COMMENT '创建时间',
    `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
    `update_time` datetime DEFAULT NULL COMMENT '更新时间',
    `remark` varchar(500) DEFAULT '' COMMENT '备注信息',
    PRIMARY KEY (`job_id`,`job_name`,`job_group`)
    ) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8 COMMENT='定时任务调度表';

-- system_dc_job_log 表
CREATE TABLE IF NOT EXISTS `system_dc_job_log` (
    `job_log_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
    `job_name` varchar(64) NOT NULL COMMENT '任务名称',
    `job_group` varchar(64) NOT NULL COMMENT '任务组名',
    `invoke_target` varchar(500) NOT NULL COMMENT '调用目标字符串',
    `job_message` varchar(500) DEFAULT NULL COMMENT '日志信息',
    `status` char(1) DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
    `exception_info` varchar(2000) DEFAULT '' COMMENT '异常信息',
    `create_time` datetime DEFAULT NULL COMMENT '创建时间',
    PRIMARY KEY (`job_log_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='定时任务调度日志表';

SET FOREIGN_KEY_CHECKS=1;

