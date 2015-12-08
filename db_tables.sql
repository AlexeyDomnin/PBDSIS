DROP DATABASE IF EXISTS new_sevryukov_task;
CREATE DATABASE IF NOT EXISTS new_sevryukov_task
CHARACTER SET utf8
COLLATE utf8_general_ci;

USE new_sevryukov_task;

CREATE TABLE IF NOT EXISTS new_sevryukov_task.log (
  id char(36) NOT NULL,
  date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  description text NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB
AVG_ROW_LENGTH = 963
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS new_sevryukov_task.subjects (
  id char(36) NOT NULL DEFAULT '1',
  type enum ('EMPLOYEE', 'CLIENT', 'COMPANY', 'SHOP', 'FOREMAN', 'MANAGER') NOT NULL,
  name varchar(200) NOT NULL,
  username varchar(200) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB
AVG_ROW_LENGTH = 2048
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS new_sevryukov_task.account (
  id char(32) NOT NULL DEFAULT '1',
  subject_id char(32) DEFAULT NULL,
  PRIMARY KEY (id),
  CONSTRAINT FK_account_subjects_id FOREIGN KEY (subject_id)
  REFERENCES new_sevryukov_task.subjects (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS new_sevryukov_task.objects (
  id char(36) NOT NULL,
  subject_id char(36) NOT NULL,
  description text NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT objects_subjects FOREIGN KEY (subject_id)
  REFERENCES new_sevryukov_task.subjects (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS new_sevryukov_task.tickets (
  id char(36) NOT NULL,
  subject_id char(36) NOT NULL,
  description text NOT NULL,
  value decimal(10, 2) NOT NULL,
  status enum ('PENDING', 'ACCEPTED', 'REJECTED') NOT NULL,
  reason text DEFAULT NULL,
  PRIMARY KEY (id),
  CONSTRAINT tickets_subjects FOREIGN KEY (subject_id)
  REFERENCES new_sevryukov_task.subjects (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS new_sevryukov_task.assignments (
  subject_id char(36) NOT NULL,
  object_id char(36) NOT NULL,
  CONSTRAINT assignments_objects FOREIGN KEY (object_id)
  REFERENCES new_sevryukov_task.objects (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT assignments_subjects FOREIGN KEY (subject_id)
  REFERENCES new_sevryukov_task.subjects (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS new_sevryukov_task.balance_per_day (
  id char(36) NOT NULL DEFAULT '1',
  account_id char(36) NOT NULL,
  date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  balance decimal(10, 2) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT FK_balance_per_day_account_id FOREIGN KEY (account_id)
  REFERENCES new_sevryukov_task.account (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)
ENGINE = INNODB
AVG_ROW_LENGTH = 1024
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS new_sevryukov_task.permissions (
  subject_id char(36) NOT NULL,
  permission enum ('DELETE', 'INSERT', 'READ', 'UPDATE', 'UPDATE_SELF') DEFAULT NULL,
  object_id char(36) NOT NULL,
  CONSTRAINT permission_objects FOREIGN KEY (object_id)
  REFERENCES new_sevryukov_task.objects (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT permission_subjects FOREIGN KEY (subject_id)
  REFERENCES new_sevryukov_task.subjects (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS new_sevryukov_task.roles (
  id char(36) NOT NULL,
  subject_id char(36) NOT NULL,
  object_id char(36) NOT NULL,
  role enum ('FOREMAN', 'MANAGER', 'EMPLOYEE') NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT role_objects FOREIGN KEY (object_id)
  REFERENCES new_sevryukov_task.objects (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT role_subjects FOREIGN KEY (subject_id)
  REFERENCES new_sevryukov_task.subjects (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS new_sevryukov_task.stages (
  id char(36) NOT NULL,
  subject_id char(36) NOT NULL,
  object_id char(36) NOT NULL,
  description text NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT stages_objects FOREIGN KEY (object_id)
  REFERENCES new_sevryukov_task.objects (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT stages_subjects FOREIGN KEY (subject_id)
  REFERENCES new_sevryukov_task.subjects (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS new_sevryukov_task.transactions (
  id char(36) NOT NULL DEFAULT '1',
  from_account_id char(36) NOT NULL,
  to_account_id char(36) NOT NULL,
  type enum ('SALLARY', 'MATERIAL', 'CLIENT') NOT NULL,
  value decimal(10, 2) NOT NULL DEFAULT 0.00,
  description text NOT NULL,
  created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT FK_transactions_from_account_id FOREIGN KEY (from_account_id)
  REFERENCES new_sevryukov_task.account (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT FK_transactions_to_account_id FOREIGN KEY (to_account_id)
  REFERENCES new_sevryukov_task.account (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)
ENGINE = INNODB
AVG_ROW_LENGTH = 2048
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS new_sevryukov_task.elements (
  id char(36) NOT NULL,
  stage_id char(36) NOT NULL,
  description text NOT NULL,
  volume double NOT NULL,
  price decimal(10, 2) NOT NULL,
  price_client decimal(10, 2) NOT NULL,
  room varchar(200) NOT NULL,
  completed tinyint(1) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT elements_stages FOREIGN KEY (stage_id)
  REFERENCES new_sevryukov_task.stages (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

