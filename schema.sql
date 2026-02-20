-- 培训项目协作平台 schema + 测试数据（MySQL 8.0）
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS training_collab DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE training_collab;

-- =========================
-- Drop tables (reverse order)
-- =========================
DROP TABLE IF EXISTS stat_snapshot;
DROP TABLE IF EXISTS report_config;
DROP TABLE IF EXISTS expense;
DROP TABLE IF EXISTS income;
DROP TABLE IF EXISTS invoice;
DROP TABLE IF EXISTS expense_channel;
DROP TABLE IF EXISTS income_channel;
DROP TABLE IF EXISTS delivery_progress;
DROP TABLE IF EXISTS course_chapter;
DROP TABLE IF EXISTS student_course;
DROP TABLE IF EXISTS student_material;
DROP TABLE IF EXISTS `order`;
DROP TABLE IF EXISTS follow_up;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS share_link;
DROP TABLE IF EXISTS study_material;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS asset_change_log;
DROP TABLE IF EXISTS fixed_asset;
DROP TABLE IF EXISTS asset_category;
DROP TABLE IF EXISTS purchase;
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS content_publish;
DROP TABLE IF EXISTS publish_platform;
DROP TABLE IF EXISTS document;
DROP TABLE IF EXISTS material;
DROP TABLE IF EXISTS material_category;
DROP TABLE IF EXISTS role_permission;
DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS user_level;
DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS company;

-- =========================
-- 1) 用户权限体系
-- =========================
CREATE TABLE company (
  id INT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(50) NOT NULL,
  description TEXT,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE department (
  id INT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(50) NOT NULL,
  parent_id INT NULL,
  description TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_department_parent FOREIGN KEY (parent_id) REFERENCES department(id)
) ENGINE=InnoDB;

CREATE TABLE user_level (
  id INT PRIMARY KEY AUTO_INCREMENT,
  department_id INT NOT NULL,
  code VARCHAR(20) NOT NULL,
  name VARCHAR(50) NOT NULL,
  level_rank INT NOT NULL,
  description TEXT,
  permissions JSON,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_level_dept_code (department_id, code),
  CONSTRAINT fk_user_level_department FOREIGN KEY (department_id) REFERENCES department(id)
) ENGINE=InnoDB;

CREATE TABLE `user` (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  real_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) UNIQUE,
  phone VARCHAR(20),
  company_id INT NOT NULL,
  department_id INT NOT NULL,
  level_id INT NOT NULL,
  avatar VARCHAR(255),
  status TINYINT NOT NULL DEFAULT 1,
  last_login_at DATETIME,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_user_department FOREIGN KEY (department_id) REFERENCES department(id),
  CONSTRAINT fk_user_level FOREIGN KEY (level_id) REFERENCES user_level(id)
) ENGINE=InnoDB;

CREATE TABLE role_permission (
  id INT PRIMARY KEY AUTO_INCREMENT,
  department_id INT NOT NULL,
  level_id INT NOT NULL,
  module_code VARCHAR(50) NOT NULL,
  page_code VARCHAR(50) NOT NULL,
  can_view BOOLEAN NOT NULL DEFAULT FALSE,
  can_create BOOLEAN NOT NULL DEFAULT FALSE,
  can_edit BOOLEAN NOT NULL DEFAULT FALSE,
  can_delete BOOLEAN NOT NULL DEFAULT FALSE,
  can_approve BOOLEAN NOT NULL DEFAULT FALSE,
  data_scope ENUM('SELF','DEPT','COMPANY','ALL') NOT NULL DEFAULT 'SELF',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_role_perm (department_id, level_id, module_code, page_code),
  CONSTRAINT fk_role_perm_department FOREIGN KEY (department_id) REFERENCES department(id),
  CONSTRAINT fk_role_perm_level FOREIGN KEY (level_id) REFERENCES user_level(id)
) ENGINE=InnoDB;

-- =========================
-- 2) 运营部
-- =========================
CREATE TABLE material_category (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  parent_id INT,
  sort_order INT NOT NULL DEFAULT 0,
  description TEXT,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_material_category_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_material_category_parent FOREIGN KEY (parent_id) REFERENCES material_category(id)
) ENGINE=InnoDB;

CREATE TABLE material (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  file_path VARCHAR(500) NOT NULL,
  file_type VARCHAR(50) NOT NULL,
  file_size BIGINT,
  category_id INT,
  tags JSON,
  thumbnail VARCHAR(500),
  description TEXT,
  creator_id INT NOT NULL,
  download_count INT NOT NULL DEFAULT 0,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_material_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_material_category FOREIGN KEY (category_id) REFERENCES material_category(id),
  CONSTRAINT fk_material_creator FOREIGN KEY (creator_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

CREATE TABLE document (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  file_path VARCHAR(500) NOT NULL,
  file_type VARCHAR(50),
  category_id INT,
  version VARCHAR(20) NOT NULL DEFAULT '1.0',
  access_level TINYINT NOT NULL DEFAULT 1,
  description TEXT,
  creator_id INT NOT NULL,
  view_count INT NOT NULL DEFAULT 0,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_document_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_document_category FOREIGN KEY (category_id) REFERENCES material_category(id),
  CONSTRAINT fk_document_creator FOREIGN KEY (creator_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

CREATE TABLE publish_platform (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  platform_type VARCHAR(50) NOT NULL,
  account_name VARCHAR(100),
  account_id VARCHAR(100),
  follower_count INT NOT NULL DEFAULT 0,
  description TEXT,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_publish_platform_company FOREIGN KEY (company_id) REFERENCES company(id)
) ENGINE=InnoDB;

CREATE TABLE content_publish (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  platform_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  content_type VARCHAR(50) NOT NULL,
  publish_url VARCHAR(500),
  publish_time DATETIME NOT NULL,
  view_count INT NOT NULL DEFAULT 0,
  like_count INT NOT NULL DEFAULT 0,
  comment_count INT NOT NULL DEFAULT 0,
  share_count INT NOT NULL DEFAULT 0,
  collect_count INT NOT NULL DEFAULT 0,
  effect_score DECIMAL(5,2),
  tags JSON,
  description TEXT,
  creator_id INT NOT NULL,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_content_publish_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_content_publish_platform FOREIGN KEY (platform_id) REFERENCES publish_platform(id),
  CONSTRAINT fk_content_publish_creator FOREIGN KEY (creator_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

-- =========================
-- 3) 管理部
-- =========================
CREATE TABLE supplier (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  contact_person VARCHAR(50),
  contact_phone VARCHAR(20),
  address VARCHAR(500),
  business_scope TEXT,
  credit_level VARCHAR(20),
  bank_name VARCHAR(100),
  bank_account VARCHAR(50),
  tax_number VARCHAR(50),
  cooperation_years INT NOT NULL DEFAULT 0,
  description TEXT,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_supplier_company FOREIGN KEY (company_id) REFERENCES company(id)
) ENGINE=InnoDB;

CREATE TABLE purchase (
  id INT PRIMARY KEY AUTO_INCREMENT,
  purchase_no VARCHAR(50) UNIQUE,
  company_id INT NOT NULL,
  supplier_id INT,
  title VARCHAR(200) NOT NULL,
  purchase_type VARCHAR(50) NOT NULL,
  items JSON NOT NULL,
  total_amount DECIMAL(12,2) NOT NULL,
  purchase_date DATE NOT NULL,
  expected_date DATE,
  actual_date DATE,
  payment_status TINYINT NOT NULL DEFAULT 0,
  invoice_status TINYINT NOT NULL DEFAULT 0,
  approver_id INT,
  approve_time DATETIME,
  creator_id INT NOT NULL,
  status TINYINT NOT NULL DEFAULT 0,
  description TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_purchase_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_purchase_supplier FOREIGN KEY (supplier_id) REFERENCES supplier(id),
  CONSTRAINT fk_purchase_approver FOREIGN KEY (approver_id) REFERENCES `user`(id),
  CONSTRAINT fk_purchase_creator FOREIGN KEY (creator_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

CREATE TABLE asset_category (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  parent_id INT,
  code VARCHAR(50),
  depreciation_years INT,
  sort_order INT NOT NULL DEFAULT 0,
  description TEXT,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_asset_category_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_asset_category_parent FOREIGN KEY (parent_id) REFERENCES asset_category(id)
) ENGINE=InnoDB;

CREATE TABLE fixed_asset (
  id INT PRIMARY KEY AUTO_INCREMENT,
  asset_no VARCHAR(50) UNIQUE,
  company_id INT NOT NULL,
  category_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  specification VARCHAR(200),
  brand VARCHAR(100),
  unit VARCHAR(20),
  quantity INT NOT NULL DEFAULT 1,
  original_value DECIMAL(12,2) NOT NULL,
  net_value DECIMAL(12,2),
  purchase_date DATE NOT NULL,
  start_use_date DATE,
  depreciation_years INT,
  residual_value DECIMAL(12,2),
  location VARCHAR(200),
  department_id INT,
  user_id INT,
  purchase_id INT,
  status TINYINT NOT NULL DEFAULT 1,
  description TEXT,
  creator_id INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_fixed_asset_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_fixed_asset_category FOREIGN KEY (category_id) REFERENCES asset_category(id),
  CONSTRAINT fk_fixed_asset_department FOREIGN KEY (department_id) REFERENCES department(id),
  CONSTRAINT fk_fixed_asset_user FOREIGN KEY (user_id) REFERENCES `user`(id),
  CONSTRAINT fk_fixed_asset_purchase FOREIGN KEY (purchase_id) REFERENCES purchase(id),
  CONSTRAINT fk_fixed_asset_creator FOREIGN KEY (creator_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

CREATE TABLE asset_change_log (
  id INT PRIMARY KEY AUTO_INCREMENT,
  asset_id INT NOT NULL,
  company_id INT NOT NULL,
  change_type VARCHAR(50) NOT NULL,
  from_user_id INT,
  to_user_id INT,
  from_dept_id INT,
  to_dept_id INT,
  from_location VARCHAR(200),
  to_location VARCHAR(200),
  change_time DATETIME NOT NULL,
  reason TEXT,
  operator_id INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_asset_log_asset FOREIGN KEY (asset_id) REFERENCES fixed_asset(id),
  CONSTRAINT fk_asset_log_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_asset_log_from_user FOREIGN KEY (from_user_id) REFERENCES `user`(id),
  CONSTRAINT fk_asset_log_to_user FOREIGN KEY (to_user_id) REFERENCES `user`(id),
  CONSTRAINT fk_asset_log_from_dept FOREIGN KEY (from_dept_id) REFERENCES department(id),
  CONSTRAINT fk_asset_log_to_dept FOREIGN KEY (to_dept_id) REFERENCES department(id),
  CONSTRAINT fk_asset_log_operator FOREIGN KEY (operator_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

-- =========================
-- 4) 顾问部 / 交付部
-- =========================
CREATE TABLE course (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  course_type VARCHAR(50) NOT NULL,
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  original_price DECIMAL(10,2),
  duration INT,
  cover_image VARCHAR(500),
  description TEXT,
  content TEXT,
  teacher_id INT,
  category VARCHAR(100),
  tags JSON,
  sort_order INT NOT NULL DEFAULT 0,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_course_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_course_teacher FOREIGN KEY (teacher_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

CREATE TABLE study_material (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  material_type VARCHAR(50) NOT NULL,
  file_path VARCHAR(500) NOT NULL,
  file_size BIGINT,
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  course_id INT,
  cover_image VARCHAR(500),
  description TEXT,
  tags JSON,
  download_count INT NOT NULL DEFAULT 0,
  status TINYINT NOT NULL DEFAULT 1,
  creator_id INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_study_material_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_study_material_course FOREIGN KEY (course_id) REFERENCES course(id),
  CONSTRAINT fk_study_material_creator FOREIGN KEY (creator_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

CREATE TABLE share_link (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  link_code VARCHAR(50) NOT NULL UNIQUE,
  creator_id INT NOT NULL,
  department VARCHAR(50) NOT NULL,
  link_type VARCHAR(50) NOT NULL,
  target_id INT,
  title VARCHAR(200),
  expire_time DATETIME,
  max_visits INT,
  visit_count INT NOT NULL DEFAULT 0,
  register_count INT NOT NULL DEFAULT 0,
  order_count INT NOT NULL DEFAULT 0,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_share_link_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_share_link_creator FOREIGN KEY (creator_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

CREATE TABLE student (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(100),
  wechat VARCHAR(50),
  source VARCHAR(50) NOT NULL,
  source_link_id INT,
  consultant_id INT,
  delivery_id INT,
  status VARCHAR(50) NOT NULL DEFAULT 'lead',
  level VARCHAR(50),
  total_purchase DECIMAL(12,2) NOT NULL DEFAULT 0,
  last_contact_time DATETIME,
  next_follow_time DATETIME,
  tags JSON,
  remark TEXT,
  creator_id INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_student_company (company_id),
  KEY idx_student_consultant (consultant_id),
  KEY idx_student_delivery (delivery_id),
  CONSTRAINT fk_student_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_student_source_link FOREIGN KEY (source_link_id) REFERENCES share_link(id),
  CONSTRAINT fk_student_consultant FOREIGN KEY (consultant_id) REFERENCES `user`(id),
  CONSTRAINT fk_student_delivery FOREIGN KEY (delivery_id) REFERENCES `user`(id),
  CONSTRAINT fk_student_creator FOREIGN KEY (creator_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

CREATE TABLE follow_up (
  id INT PRIMARY KEY AUTO_INCREMENT,
  student_id INT NOT NULL,
  company_id INT NOT NULL,
  follower_id INT NOT NULL,
  follow_type VARCHAR(50) NOT NULL,
  follow_time DATETIME NOT NULL,
  content TEXT NOT NULL,
  student_feedback TEXT,
  result VARCHAR(50),
  next_follow_time DATETIME,
  next_follow_plan TEXT,
  attachment VARCHAR(500),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_follow_up_student FOREIGN KEY (student_id) REFERENCES student(id),
  CONSTRAINT fk_follow_up_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_follow_up_follower FOREIGN KEY (follower_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

CREATE TABLE `order` (
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_no VARCHAR(50) NOT NULL UNIQUE,
  company_id INT NOT NULL,
  student_id INT NOT NULL,
  sales_id INT NOT NULL,
  sales_dept VARCHAR(50) NOT NULL,
  order_type VARCHAR(50) NOT NULL,
  items JSON NOT NULL,
  total_amount DECIMAL(12,2) NOT NULL,
  discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  actual_amount DECIMAL(12,2) NOT NULL,
  payment_method VARCHAR(50),
  payment_channel VARCHAR(50),
  payment_time DATETIME,
  income_record_id INT,
  status TINYINT NOT NULL DEFAULT 0,
  remark TEXT,
  creator_id INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_order_company_status (company_id, status),
  KEY idx_order_student (student_id),
  KEY idx_order_sales (sales_id),
  CONSTRAINT fk_order_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_order_student FOREIGN KEY (student_id) REFERENCES student(id),
  CONSTRAINT fk_order_sales FOREIGN KEY (sales_id) REFERENCES `user`(id),
  CONSTRAINT fk_order_creator FOREIGN KEY (creator_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

CREATE TABLE student_material (
  id INT PRIMARY KEY AUTO_INCREMENT,
  student_id INT NOT NULL,
  material_id INT NOT NULL,
  company_id INT NOT NULL,
  sender_id INT NOT NULL,
  send_type VARCHAR(50) NOT NULL,
  order_id INT,
  send_time DATETIME NOT NULL,
  expire_time DATETIME,
  download_status TINYINT NOT NULL DEFAULT 0,
  download_time DATETIME,
  remark TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_student_material_student FOREIGN KEY (student_id) REFERENCES student(id),
  CONSTRAINT fk_student_material_material FOREIGN KEY (material_id) REFERENCES study_material(id),
  CONSTRAINT fk_student_material_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_student_material_sender FOREIGN KEY (sender_id) REFERENCES `user`(id),
  CONSTRAINT fk_student_material_order FOREIGN KEY (order_id) REFERENCES `order`(id)
) ENGINE=InnoDB;

CREATE TABLE student_course (
  id INT PRIMARY KEY AUTO_INCREMENT,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  company_id INT NOT NULL,
  order_id INT,
  assign_type VARCHAR(50) NOT NULL,
  progress DECIMAL(5,2) NOT NULL DEFAULT 0,
  start_time DATETIME,
  last_study_time DATETIME,
  expire_time DATETIME,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_student_course_student FOREIGN KEY (student_id) REFERENCES student(id),
  CONSTRAINT fk_student_course_course FOREIGN KEY (course_id) REFERENCES course(id),
  CONSTRAINT fk_student_course_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_student_course_order FOREIGN KEY (order_id) REFERENCES `order`(id)
) ENGINE=InnoDB;

CREATE TABLE course_chapter (
  id INT PRIMARY KEY AUTO_INCREMENT,
  course_id INT NOT NULL,
  parent_id INT,
  title VARCHAR(200) NOT NULL,
  chapter_type VARCHAR(50) NOT NULL,
  duration INT,
  video_url VARCHAR(500),
  content TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  is_free BOOLEAN NOT NULL DEFAULT FALSE,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_course_chapter_course FOREIGN KEY (course_id) REFERENCES course(id),
  CONSTRAINT fk_course_chapter_parent FOREIGN KEY (parent_id) REFERENCES course_chapter(id)
) ENGINE=InnoDB;

CREATE TABLE delivery_progress (
  id INT PRIMARY KEY AUTO_INCREMENT,
  student_course_id INT NOT NULL,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  company_id INT NOT NULL,
  chapter_id INT,
  chapter_name VARCHAR(200),
  total_lessons INT NOT NULL DEFAULT 0,
  completed_lessons INT NOT NULL DEFAULT 0,
  progress_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
  last_study_time DATETIME,
  study_duration INT NOT NULL DEFAULT 0,
  homework_status TINYINT NOT NULL DEFAULT 0,
  homework_score DECIMAL(5,2),
  deliverer_id INT NOT NULL,
  delivery_status VARCHAR(50) NOT NULL DEFAULT 'ongoing',
  completion_time DATETIME,
  remark TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_delivery_progress_student_course FOREIGN KEY (student_course_id) REFERENCES student_course(id),
  CONSTRAINT fk_delivery_progress_student FOREIGN KEY (student_id) REFERENCES student(id),
  CONSTRAINT fk_delivery_progress_course FOREIGN KEY (course_id) REFERENCES course(id),
  CONSTRAINT fk_delivery_progress_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_delivery_progress_chapter FOREIGN KEY (chapter_id) REFERENCES course_chapter(id),
  CONSTRAINT fk_delivery_progress_deliverer FOREIGN KEY (deliverer_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

-- =========================
-- 5) 财务部
-- =========================
CREATE TABLE income_channel (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  channel_type VARCHAR(50) NOT NULL,
  account_name VARCHAR(200),
  account_no VARCHAR(100),
  fee_rate DECIMAL(5,4) NOT NULL DEFAULT 0,
  settlement_cycle INT,
  description TEXT,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_income_channel_company FOREIGN KEY (company_id) REFERENCES company(id)
) ENGINE=InnoDB;

CREATE TABLE expense_channel (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  channel_type VARCHAR(50) NOT NULL,
  account_name VARCHAR(200),
  account_no VARCHAR(100),
  bank_name VARCHAR(100),
  budget_limit DECIMAL(12,2),
  description TEXT,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_expense_channel_company FOREIGN KEY (company_id) REFERENCES company(id)
) ENGINE=InnoDB;

CREATE TABLE invoice (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_id INT NOT NULL,
  invoice_type VARCHAR(50) NOT NULL,
  invoice_code VARCHAR(50) NOT NULL,
  invoice_no VARCHAR(50) NOT NULL,
  invoice_date DATE NOT NULL,
  issuer_name VARCHAR(200) NOT NULL,
  issuer_tax_no VARCHAR(50),
  amount DECIMAL(12,2) NOT NULL,
  tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_amount DECIMAL(12,2) NOT NULL,
  image_path VARCHAR(500),
  verify_status TINYINT NOT NULL DEFAULT 0,
  verify_time DATETIME,
  verify_result TEXT,
  description TEXT,
  status TINYINT NOT NULL DEFAULT 1,
  creator_id INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_invoice_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_invoice_creator FOREIGN KEY (creator_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

CREATE TABLE income (
  id INT PRIMARY KEY AUTO_INCREMENT,
  income_no VARCHAR(50) UNIQUE,
  company_id INT NOT NULL,
  order_id INT NOT NULL,
  channel_id INT NOT NULL,
  order_amount DECIMAL(12,2) NOT NULL,
  actual_amount DECIMAL(12,2) NOT NULL,
  fee_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  income_date DATE NOT NULL,
  income_time DATETIME,
  transaction_no VARCHAR(100),
  payer_name VARCHAR(100),
  sales_dept VARCHAR(50) NOT NULL,
  sales_id INT,
  verifier_id INT,
  verify_time DATETIME,
  status TINYINT NOT NULL DEFAULT 0,
  remark TEXT,
  creator_id INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_income_order (order_id),
  KEY idx_income_company_date (company_id, income_date),
  CONSTRAINT fk_income_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_income_order FOREIGN KEY (order_id) REFERENCES `order`(id),
  CONSTRAINT fk_income_channel FOREIGN KEY (channel_id) REFERENCES income_channel(id),
  CONSTRAINT fk_income_sales FOREIGN KEY (sales_id) REFERENCES `user`(id),
  CONSTRAINT fk_income_verifier FOREIGN KEY (verifier_id) REFERENCES `user`(id),
  CONSTRAINT fk_income_creator FOREIGN KEY (creator_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

CREATE TABLE expense (
  id INT PRIMARY KEY AUTO_INCREMENT,
  expense_no VARCHAR(50) UNIQUE,
  company_id INT NOT NULL,
  invoice_id INT NOT NULL,
  channel_id INT NOT NULL,
  expense_type VARCHAR(50) NOT NULL,
  purchase_id INT,
  asset_id INT,
  amount DECIMAL(12,2) NOT NULL,
  expense_date DATE NOT NULL,
  payee_name VARCHAR(100),
  payee_account VARCHAR(100),
  applicant_id INT NOT NULL,
  approver_id INT,
  approve_time DATETIME,
  payer_id INT,
  pay_time DATETIME,
  status TINYINT NOT NULL DEFAULT 0,
  remark TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_expense_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_expense_invoice FOREIGN KEY (invoice_id) REFERENCES invoice(id),
  CONSTRAINT fk_expense_channel FOREIGN KEY (channel_id) REFERENCES expense_channel(id),
  CONSTRAINT fk_expense_purchase FOREIGN KEY (purchase_id) REFERENCES purchase(id),
  CONSTRAINT fk_expense_asset FOREIGN KEY (asset_id) REFERENCES fixed_asset(id),
  CONSTRAINT fk_expense_applicant FOREIGN KEY (applicant_id) REFERENCES `user`(id),
  CONSTRAINT fk_expense_approver FOREIGN KEY (approver_id) REFERENCES `user`(id),
  CONSTRAINT fk_expense_payer FOREIGN KEY (payer_id) REFERENCES `user`(id)
) ENGINE=InnoDB;

-- 回填 order -> income 关联
ALTER TABLE `order`
  ADD CONSTRAINT fk_order_income_record FOREIGN KEY (income_record_id) REFERENCES income(id);

-- =========================
-- 6) 老板/统计
-- =========================
CREATE TABLE report_config (
  id INT PRIMARY KEY AUTO_INCREMENT,
  report_code VARCHAR(50) NOT NULL UNIQUE,
  report_name VARCHAR(100) NOT NULL,
  report_type VARCHAR(50) NOT NULL,
  data_source VARCHAR(100) NOT NULL,
  dimensions JSON,
  metrics JSON,
  filters JSON,
  chart_config JSON,
  refresh_cycle VARCHAR(20),
  department_scope VARCHAR(100),
  sort_order INT NOT NULL DEFAULT 0,
  status TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE stat_snapshot (
  id INT PRIMARY KEY AUTO_INCREMENT,
  report_id INT NOT NULL,
  company_id INT,
  department_id INT,
  snapshot_date DATE NOT NULL,
  snapshot_time DATETIME NOT NULL,
  dimension_values JSON,
  metric_values JSON NOT NULL,
  data_count INT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_snapshot_report_date (report_id, snapshot_date),
  KEY idx_snapshot_company (company_id),
  CONSTRAINT fk_stat_snapshot_report FOREIGN KEY (report_id) REFERENCES report_config(id),
  CONSTRAINT fk_stat_snapshot_company FOREIGN KEY (company_id) REFERENCES company(id),
  CONSTRAINT fk_stat_snapshot_department FOREIGN KEY (department_id) REFERENCES department(id)
) ENGINE=InnoDB;

-- =========================
-- 测试数据
-- =========================
INSERT INTO company (id, code, name, description) VALUES
(1,'HAGUANG','哈广','哈哈哈心理咨询（广州）有限公司'),
(2,'LEWU','乐悟','乐悟心理咨询（广州）有限公司'),
(3,'HABEI','哈北','北京分公司'),
(4,'HAXIA','哈厦','厦门分公司'),
(5,'ERBAI','尔白','广州尔白文化传播有限公司'),
(6,'WAIXIE','外协','外部协作单位'),
(7,'OTHER','其他','其他合作单位或未分类主体');

INSERT INTO department (id, code, name, description, sort_order) VALUES
(1,'BOSS','老板','全局统计',1),
(2,'ADMIN','管理部','采购与资产',2),
(3,'OPERATION','运营部','内容运营',3),
(4,'CONSULTANT','顾问部','销售与跟进',4),
(5,'DELIVERY','交付部','课程交付',5),
(6,'FINANCE','财务部','收支与票据',6),
(7,'OTHER','其他','临时职能',7);

INSERT INTO user_level (id, department_id, code, name, level_rank, permissions) VALUES
(1,1,'OWNER','老板',100, JSON_OBJECT('scope','ALL')),
(2,2,'MANAGER','主管',80, JSON_OBJECT('approve',true)),
(3,3,'SPECIALIST','专员',50, JSON_OBJECT('publish',true)),
(4,4,'CONSULTANT','顾问',50, JSON_OBJECT('sell',true)),
(5,5,'DELIVERER','交付',50, JSON_OBJECT('deliver',true)),
(6,6,'ACCOUNTANT','会计',70, JSON_OBJECT('verify',true));

INSERT INTO `user` (id, username, password, real_name, email, phone, company_id, department_id, level_id) VALUES
(1,'boss_hg','$2b$10$demo','张总','boss@demo.com','13800000001',1,1,1),
(2,'admin_hg','$2b$10$demo','王主管','admin@demo.com','13800000002',1,2,2),
(3,'ops_hg','$2b$10$demo','李运营','ops@demo.com','13800000003',1,3,3),
(4,'consult_hg','$2b$10$demo','赵顾问','consult@demo.com','13800000004',1,4,4),
(5,'delivery_hg','$2b$10$demo','钱交付','delivery@demo.com','13800000005',1,5,5),
(6,'finance_hg','$2b$10$demo','孙会计','finance@demo.com','13800000006',1,6,6);

INSERT INTO role_permission (department_id, level_id, module_code, page_code, can_view, can_create, can_edit, can_delete, can_approve, data_scope) VALUES
(1,1,'dashboard','global_overview',1,0,0,0,0,'ALL'),
(3,3,'operation','content_publish',1,1,1,0,0,'COMPANY'),
(4,4,'consultant','student',1,1,1,0,0,'SELF'),
(5,5,'delivery','delivery_progress',1,1,1,0,0,'SELF'),
(6,6,'finance','income_expense',1,1,1,0,1,'COMPANY');

INSERT INTO material_category (id, company_id, name, sort_order, description) VALUES
(1,1,'活动海报',1,'运营素材分类');

INSERT INTO material (company_id, title, file_path, file_type, file_size, category_id, tags, thumbnail, description, creator_id)
VALUES (1,'春季活动主视觉','/files/material/spring-main.jpg','image',2097152,1,JSON_ARRAY('活动','海报'),'/thumb/spring-main.jpg','2026春季活动主图',3);

INSERT INTO document (company_id, title, file_path, file_type, category_id, version, access_level, description, creator_id)
VALUES (1,'运营手册V1','/files/docs/operation-v1.pdf','pdf',1,'1.0',1,'运营内部手册',3);

INSERT INTO publish_platform (id, company_id, name, platform_type, account_name, account_id, follower_count, description)
VALUES (1,1,'哈广公众号','wechat','哈广心理','gh_xxx',12000,'微信公众号');

INSERT INTO content_publish (company_id, platform_id, title, content_type, publish_url, publish_time, view_count, like_count, comment_count, share_count, collect_count, effect_score, tags, description, creator_id)
VALUES (1,1,'春季公开课预告','article','https://example.com/post/1','2026-02-10 10:00:00',3500,220,45,60,80,89.50,JSON_ARRAY('公开课','引流'),'公众号图文发布',3);

INSERT INTO supplier (id, company_id, name, contact_person, contact_phone, business_scope, credit_level)
VALUES (1,1,'广州优采科技','刘经理','13900000001','办公设备与服务','A');

INSERT INTO purchase (id, purchase_no, company_id, supplier_id, title, purchase_type, items, total_amount, purchase_date, payment_status, invoice_status, approver_id, approve_time, creator_id, status, description)
VALUES (1,'PO202602001',1,1,'采购办公电脑','equipment',JSON_ARRAY(JSON_OBJECT('name','笔记本电脑','qty',3,'price',5500)),16500.00,'2026-02-12',1,1,2,'2026-02-12 15:00:00',2,1,'运营扩编采购');

INSERT INTO asset_category (id, company_id, name, code, depreciation_years, sort_order, description)
VALUES (1,1,'电子设备','ELEC',3,1,'可折旧电子资产');

INSERT INTO fixed_asset (id, asset_no, company_id, category_id, name, specification, brand, unit, quantity, original_value, net_value, purchase_date, start_use_date, depreciation_years, residual_value, location, department_id, user_id, purchase_id, status, description, creator_id)
VALUES (1,'FA202602001',1,1,'运营部笔记本电脑','ThinkPad X1','Lenovo','台',1,5500.00,5000.00,'2026-02-12','2026-02-13',3,500.00,'广州办公室A区',3,3,1,1,'用于内容制作',2);

INSERT INTO asset_change_log (asset_id, company_id, change_type, from_user_id, to_user_id, from_dept_id, to_dept_id, from_location, to_location, change_time, reason, operator_id)
VALUES (1,1,'receive',NULL,3,NULL,3,NULL,'广州办公室A区','2026-02-13 09:30:00','新资产领用',2);

INSERT INTO course (id, company_id, name, course_type, price, original_price, duration, description, content, teacher_id, category, tags, sort_order)
VALUES (1,1,'情绪管理入门','normal',999.00,1299.00,20,'帮助学员建立情绪调节能力','模块1-认知情绪；模块2-行为训练',4,'心理成长',JSON_ARRAY('情绪管理','入门'),1);

INSERT INTO study_material (id, company_id, title, material_type, file_path, file_size, price, course_id, description, tags, creator_id)
VALUES (1,1,'情绪管理电子讲义','ebook','/files/study/emotion-book.pdf',1048576,0,1,'课程配套讲义',JSON_ARRAY('讲义','免费'),4);

INSERT INTO share_link (id, company_id, link_code, creator_id, department, link_type, target_id, title, expire_time, max_visits, visit_count, register_count, order_count)
VALUES (1,1,'SL202602001',4,'consultant','course',1,'情绪管理课程推广链接','2026-12-31 23:59:59',10000,350,80,15);

INSERT INTO student (id, company_id, name, phone, email, wechat, source, source_link_id, consultant_id, delivery_id, status, level, total_purchase, last_contact_time, next_follow_time, tags, remark, creator_id)
VALUES (1,1,'陈学员','13600000001','student1@example.com','chenxueyuan','link',1,4,5,'customer','A',999.00,'2026-02-14 18:00:00','2026-02-20 10:00:00',JSON_ARRAY('意向高','在学'),'首单已成交',4);

INSERT INTO follow_up (student_id, company_id, follower_id, follow_type, follow_time, content, student_feedback, result, next_follow_time, next_follow_plan)
VALUES (1,1,4,'wechat','2026-02-14 18:00:00','介绍课程大纲及学习收益','希望先试听公开课','interested','2026-02-20 10:00:00','跟进试听反馈并推进复购');

INSERT INTO `order` (id, order_no, company_id, student_id, sales_id, sales_dept, order_type, items, total_amount, discount_amount, actual_amount, payment_method, payment_channel, payment_time, status, remark, creator_id)
VALUES (1,'SO202602001',1,1,4,'consultant','course',JSON_ARRAY(JSON_OBJECT('course_id',1,'name','情绪管理入门','qty',1,'price',999.00)),999.00,0.00,999.00,'wechat','wechatpay','2026-02-15 10:00:00',1,'首单成交',4);

INSERT INTO student_material (student_id, material_id, company_id, sender_id, send_type, order_id, send_time, expire_time, download_status, download_time, remark)
VALUES (1,1,1,4,'wechat',1,'2026-02-15 11:00:00','2026-12-31 23:59:59',1,'2026-02-15 11:30:00','已发送课程讲义');

INSERT INTO student_course (id, student_id, course_id, company_id, order_id, assign_type, progress, start_time, last_study_time, expire_time, status)
VALUES (1,1,1,1,1,'purchase',30.00,'2026-02-15 12:00:00','2026-02-18 21:00:00','2027-02-15 00:00:00',1);

INSERT INTO course_chapter (id, course_id, title, chapter_type, duration, content, sort_order, is_free)
VALUES (1,1,'第一章：认识情绪','chapter',45,'讲解情绪的来源和分类',1,1);

INSERT INTO delivery_progress (student_course_id, student_id, course_id, company_id, chapter_id, chapter_name, total_lessons, completed_lessons, progress_percent, last_study_time, study_duration, homework_status, homework_score, deliverer_id, delivery_status, remark)
VALUES (1,1,1,1,1,'第一章：认识情绪',10,3,30.00,'2026-02-18 21:00:00',180,1,92.00,5,'ongoing','学习状态良好');

INSERT INTO income_channel (id, company_id, name, channel_type, account_name, account_no, fee_rate, settlement_cycle, description)
VALUES (1,1,'微信支付','wechat','哈广收款主账户','wx_001',0.0060,1,'线上收款');

INSERT INTO expense_channel (id, company_id, name, channel_type, account_name, account_no, bank_name, budget_limit, description)
VALUES (1,1,'公司对公账户','bank','哈广对公户','622200000001','招商银行',500000.00,'日常采购与费用支付');

INSERT INTO invoice (id, company_id, invoice_type, invoice_code, invoice_no, invoice_date, issuer_name, issuer_tax_no, amount, tax_amount, total_amount, image_path, verify_status, verify_time, verify_result, description, creator_id)
VALUES (1,1,'vat_normal','4400191130','02123456','2026-02-13','广州优采科技有限公司','91440101XXXXXX',14601.77,1898.23,16500.00,'/files/invoice/02123456.jpg',1,'2026-02-13 16:00:00','验真通过','采购办公电脑发票',6);

INSERT INTO income (id, income_no, company_id, order_id, channel_id, order_amount, actual_amount, fee_amount, income_date, income_time, transaction_no, payer_name, sales_dept, sales_id, verifier_id, verify_time, status, remark, creator_id)
VALUES (1,'IN202602001',1,1,1,999.00,993.01,5.99,'2026-02-15','2026-02-15 10:01:00','WX20260215001','陈学员','consultant',4,6,'2026-02-15 12:00:00',1,'订单到账并审核',6);

UPDATE `order` SET income_record_id = 1 WHERE id = 1;

INSERT INTO expense (expense_no, company_id, invoice_id, channel_id, expense_type, purchase_id, asset_id, amount, expense_date, payee_name, payee_account, applicant_id, approver_id, approve_time, payer_id, pay_time, status, remark)
VALUES ('EX202602001',1,1,1,'purchase',1,1,16500.00,'2026-02-16','广州优采科技有限公司','622202020202',2,6,'2026-02-16 09:30:00',6,'2026-02-16 14:00:00',2,'采购款支付完成');

INSERT INTO report_config (id, report_code, report_name, report_type, data_source, dimensions, metrics, filters, chart_config, refresh_cycle, department_scope, sort_order)
VALUES (1,'FIN_DASH_001','财务总览','dashboard','income,expense',JSON_ARRAY('company','date'),JSON_ARRAY('total_income','total_expense','cash_flow'),JSON_OBJECT('company_id',1),JSON_OBJECT('chart','line+bar'),'daily','finance,boss',1);

INSERT INTO stat_snapshot (report_id, company_id, department_id, snapshot_date, snapshot_time, dimension_values, metric_values, data_count)
VALUES (1,1,6,'2026-02-19','2026-02-19 00:05:00',JSON_OBJECT('company','哈广','date','2026-02-19'),JSON_OBJECT('total_income',999.00,'total_expense',16500.00,'cash_flow',-15501.00),2);

SET FOREIGN_KEY_CHECKS = 1;
