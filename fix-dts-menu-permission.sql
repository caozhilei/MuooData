-- 为数据集成菜单分配权限
-- 此脚本将为所有角色（特别是管理员角色）分配数据集成菜单及其子菜单的权限

-- 1. 检查数据集成菜单是否存在
SELECT menu_id, title, pid FROM sys_menu WHERE menu_id = 159 OR title = '数据集成';

-- 2. 为管理员角色（role_id=1）分配数据集成菜单权限
-- 包括主菜单和所有子菜单
INSERT INTO sys_roles_menus (menu_id, role_id) VALUES
(159, 1),  -- 数据集成主菜单
(160, 1),  -- 数据源管理
(161, 1),  -- 项目管理
(162, 1),  -- 资源管理
(163, 1),  -- 任务详情
(164, 1),  -- 任务模板
(165, 1),  -- 运行日志
(166, 1),  -- 单任务
(167, 1),  -- 多任务
(168, 1),  -- 任务管理
(169, 1)   -- 注册中心
ON DUPLICATE KEY UPDATE menu_id=menu_id;  -- 如果已存在则忽略

-- 3. 为普通用户角色（role_id=2）也分配权限（如果需要）
INSERT INTO sys_roles_menus (menu_id, role_id) VALUES
(159, 2),
(160, 2),
(161, 2),
(162, 2),
(163, 2),
(164, 2),
(165, 2),
(166, 2),
(167, 2),
(168, 2),
(169, 2)
ON DUPLICATE KEY UPDATE menu_id=menu_id;

-- 4. 验证权限分配
SELECT rm.role_id, r.name as role_name, rm.menu_id, m.title as menu_title 
FROM sys_roles_menus rm 
JOIN sys_role r ON rm.role_id = r.role_id 
JOIN sys_menu m ON rm.menu_id = m.menu_id 
WHERE m.menu_id IN (159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169)
ORDER BY rm.role_id, rm.menu_id;

