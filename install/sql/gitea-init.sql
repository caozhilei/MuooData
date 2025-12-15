-- Gitea 数据库初始化脚本
-- 此脚本会在 MySQL 容器启动时自动执行

CREATE DATABASE IF NOT EXISTS `gitea` 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_general_ci;

-- 注意：Gitea 会在首次启动时自动创建所需的表结构
-- 此脚本仅负责创建数据库

