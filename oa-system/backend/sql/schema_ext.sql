-- OA 扩展表：操作日志 + 消息通知（基于 oa_codex）
USE oa_codex;

CREATE TABLE IF NOT EXISTS operation_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  company_id INT,
  user_id INT NOT NULL,
  action VARCHAR(50) NOT NULL,
  module_code VARCHAR(50) NOT NULL,
  target_type VARCHAR(50),
  target_id INT,
  request_path VARCHAR(255),
  detail JSON,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_oplog_user_time (user_id, created_at),
  KEY idx_oplog_company_time (company_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS notification (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  company_id INT,
  receiver_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  content TEXT,
  notice_type VARCHAR(50) NOT NULL DEFAULT 'system',
  is_read TINYINT NOT NULL DEFAULT 0,
  read_at DATETIME,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_notification_receiver_read (receiver_id, is_read, created_at)
) ENGINE=InnoDB;
