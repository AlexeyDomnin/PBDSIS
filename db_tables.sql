DROP TABLE IF EXISTS `entities`;
CREATE TABLE `entities` (
  `id` char(36) NOT NULL,
  `type` enum('EMPLOYEE','CLIENT','COMPANY','SHOP') NOT NULL,
  `name` varchar(200) NOT NULL,
  `username` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Субъекты';

DROP TABLE IF EXISTS `accounts`;
CREATE TABLE `accounts` (
  `id` char(36) NOT NULL DEFAULT '1',
  `entity_id` char(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `account_entities` (`entity_id`),
  CONSTRAINT `account_entities` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Счета';

DROP TABLE IF EXISTS `balance_per_day`;
CREATE TABLE `balance_per_day` (
  `id` char(36) NOT NULL,
  `account_id` char(36) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `balance` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Balance_account` (`account_id`),
  CONSTRAINT `Balance_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `objects`;
СREATE TABLE `objects` (
  `id` char(36) NOT NULL,
  `entity_id` char(36) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `objects_entities` (`entity_id`),
  CONSTRAINT `objects_entities` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `stages`;
CREATE TABLE `stages` (
  `id` char(36) NOT NULL,
  `entity_id` char(36) NOT NULL,
  `object_id` char(36) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `stages_entities` (`entity_id`),
  KEY `stages_objects` (`object_id`),
  CONSTRAINT `stages_entities` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`),
  CONSTRAINT `stages_objects` FOREIGN KEY (`object_id`) REFERENCES `objects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `elements`;
CREATE TABLE `elements` (
  `id` char(36) NOT NULL,
  `stage_id` char(36) NOT NULL,
  `description` text NOT NULL,
  `volume` double NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `price_client` decimal(10,2) NOT NULL,
  `room` varchar(200) NOT NULL,
  `completed` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `elements_stages` (`stage_id`),
  CONSTRAINT `elements_stages` FOREIGN KEY (`stage_id`) REFERENCES `stages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `log`;
CREATE TABLE `log` (
  `id` char(36) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `description` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions` (
  `entity_id` char(36) NOT NULL,
  `permission` enum('DELETE','INSERT','READ','UPDATE','UPDATE_SELF') DEFAULT NULL,
  `object_id` char(36) NOT NULL,
  KEY `permission_entities` (`entity_id`),
  KEY `permission_objects` (`object_id`),
  CONSTRAINT `permission_entities` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`),
  CONSTRAINT `permission_objects` FOREIGN KEY (`object_id`) REFERENCES `objects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` char(36) NOT NULL,
  `entity_id` char(36) NOT NULL,
  `object_id` char(36) NOT NULL,
  `role` enum('FOREMAN','MANAGER','EMPLOYEE') NOT NULL,
  PRIMARY KEY (`id`),
  KEY `role_entities` (`entity_id`),
  KEY `role_objects` (`object_id`),
  CONSTRAINT `role_entities` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`),
  CONSTRAINT `role_objects` FOREIGN KEY (`object_id`) REFERENCES `objects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tickets`;
CREATE TABLE `tickets` (
  `id` char(36) NOT NULL,
  `account_id` char(36) NOT NULL,
  `description` text NOT NULL,
  `value` decimal(10,2) NOT NULL,
  `status` enum('PENDING','ACCEPTED','REJECTED') NOT NULL,
  `reason` text,
  PRIMARY KEY (`id`),
  KEY `tickets_accounts1` (`account_id`),
  CONSTRAINT `tickets_accounts1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `transactions`;
CREATE TABLE `transactions` (
  `id` char(36) NOT NULL,
  `from_account_id` char(36) NOT NULL,
  `to_account_id` char(36) NOT NULL,
  `value` decimal(10,2) NOT NULL,
  `description` text NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `transactions_accounts1` (`from_account_id`),
  KEY `transactions_accounts2` (`to_account_id`),
  CONSTRAINT `transactions_accounts1` FOREIGN KEY (`from_account_id`) REFERENCES `accounts` (`id`),
  CONSTRAINT `transactions_accounts2` FOREIGN KEY (`to_account_id`) REFERENCES `accounts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
