DROP DATABASE IF EXISTS new_sevryukov_task;
CREATE DATABASE IF NOT EXISTS new_sevryukov_task
CHARACTER SET utf8
COLLATE utf8_general_ci;

USE new_sevryukov_task;

CREATE TABLE IF NOT EXISTS entities (
  id char(36) NOT NULL DEFAULT '1',
  type enum ('EMPLOYEE','CLIENT','COMPANY','SHOP','FOREMAN','MANAGER') NOT NULL,
  name varchar(200) NOT NULL,
  username varchar(200) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB
AVG_ROW_LENGTH = 2048
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS log (
  id char(36) NOT NULL,
  date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  description text NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB
AVG_ROW_LENGTH = 963
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS balance_per_day (
  id char(36) NOT NULL DEFAULT '1',
  entity_id char(36) NOT NULL,
  date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  balance decimal(10, 2) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT Balance_entities FOREIGN KEY (entity_id)
  REFERENCES entities (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
AVG_ROW_LENGTH = 1024
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS objects (
  id char(36) NOT NULL,
  entity_id char(36) NOT NULL,
  description text NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT objects_entities FOREIGN KEY (entity_id)
  REFERENCES entities (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS tickets (
  id char(36) NOT NULL,
  entity_id char(36) NOT NULL,
  description text NOT NULL,
  value decimal(10, 2) NOT NULL,
  status enum ('PENDING', 'ACCEPTED', 'REJECTED') NOT NULL,
  reason text DEFAULT NULL,
  PRIMARY KEY (id),
  CONSTRAINT tickets_entities FOREIGN KEY (entity_id)
  REFERENCES entities (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS transactions (
  id char(36) NOT NULL DEFAULT '1',
  from_entity_id char(36) NOT NULL,
  to_entity_id char(36) NOT NULL,
  type enum ('SALLARY', 'MATERIAL', 'CLIENT') NOT NULL,
  value decimal(10, 2) NOT NULL DEFAULT 0.00,
  description text NOT NULL,
  created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT transactions_entities1 FOREIGN KEY (from_entity_id)
  REFERENCES entities (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT transactions_entities2 FOREIGN KEY (to_entity_id)
  REFERENCES entities (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
AVG_ROW_LENGTH = 2048
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS assignments (
  entity_id char(36) NOT NULL,
  object_id char(36) NOT NULL,
  CONSTRAINT assignments_entities FOREIGN KEY (entity_id)
  REFERENCES entities (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT assignments_objects FOREIGN KEY (object_id)
  REFERENCES objects (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS permissions (
  entity_id char(36) NOT NULL,
  permission enum ('DELETE', 'INSERT', 'READ', 'UPDATE', 'UPDATE_SELF') DEFAULT NULL,
  object_id char(36) NOT NULL,
  CONSTRAINT permission_entities FOREIGN KEY (entity_id)
  REFERENCES entities (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT permission_objects FOREIGN KEY (object_id)
  REFERENCES objects (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS roles (
  id char(36) NOT NULL,
  entity_id char(36) NOT NULL,
  object_id char(36) NOT NULL,
  role enum ('FOREMAN', 'MANAGER','EMPLOYEE') NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT role_entities FOREIGN KEY (entity_id)
  REFERENCES entities (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT role_objects FOREIGN KEY (object_id)
  REFERENCES objects (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS stages (
  id char(36) NOT NULL,
  entity_id char(36) NOT NULL,
  object_id char(36) NOT NULL,
  description text NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT stages_entities FOREIGN KEY (entity_id)
  REFERENCES entities (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT stages_objects FOREIGN KEY (object_id)
  REFERENCES objects (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS elements (
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
  REFERENCES stages (id) ON DELETE RESTRICT ON UPDATE RESTRICT
)
ENGINE = INNODB
CHARACTER SET utf8
COLLATE utf8_general_ci;

DELIMITER $$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER BEFORE_INSERT_BALANCE_PER_DAY
BEFORE INSERT
ON balance_per_day
FOR EACH ROW
BEGIN
  SET NEW.id = UUID();
END
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER BEFORE_INSERT_ENTITIES
BEFORE INSERT
ON entities
FOR EACH ROW
BEGIN
  SET NEW.id = UUID();
END
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER BEFORE_INSERT_TRANSACTIONS
BEFORE INSERT
ON transactions
FOR EACH ROW
BEGIN
  SET NEW.id = UUID();
END
$$



DELIMITER ;
