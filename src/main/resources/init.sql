-- =============================================================
--  OceanView Resort Database Initialization Script
--  Run this script in MySQL Workbench or MySQL CLI before
--  starting the application.
-- =============================================================

CREATE DATABASE IF NOT EXISTS OceanViewResort_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE OceanViewResort_db;

-- -------------------------------------------------------------
--  Users Table
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(50)  UNIQUE NOT NULL,
    password    VARCHAR(255) NOT NULL,          -- BCrypt hashed
    full_name   VARCHAR(100),
    email       VARCHAR(100),
    role        ENUM('ADMIN','STAFF','RECEPTIONIST') DEFAULT 'STAFF',
    is_active   BOOLEAN DEFAULT TRUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------
--  NOTE: The admin user (admin / admin123) is inserted
--  automatically by the application on first startup
--  via AppInitServlet.java. You do NOT need to insert
--  the admin manually here.
-- -------------------------------------------------------------
