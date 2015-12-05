CREATE TABLE `Entities` (
  `id` char(36) NOT NULL ,
  `type` `role` ENUM('EMPLOYEE','CLIENT','COMPANY','SHOP') NOT NULL,
  `name` varchar(200) NOT NULL,
  `username` varchar(200),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Objects` (
  `id` char(36) NOT NULL,
  `entity_id` char(36) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `objects_entities` FOREIGN KEY (`entity_id`) REFERENCES `Entities` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Assignments` (
  
  `entity_id` char(36) NOT NULL,
  `object_id` char(36) NOT NULL,
  CONSTRAINT `assignments_entities` FOREIGN KEY (`entity_id`) REFERENCES `Entities` (`id`),
  CONSTRAINT `assignments_objects` FOREIGN KEY (`object_id`) REFERENCES `Objects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Log` (
  `id` char(36) NOT NULL ,
  `date` timestamp NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Roles` (
  `id` char(36) NOT NULL,
  `entity_id` char(36) NOT NULL,
  `object_id` char(36) NOT NULL,
  `role` ENUM('FOREMAN', 'MANAGER') NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `role_entities` FOREIGN KEY (`entity_id`) REFERENCES `Entities` (`id`),
  CONSTRAINT `role_objects` FOREIGN KEY (`object_id`) REFERENCES `Objects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Permissions` (
  
  `entity_id` char(36) NOT NULL,
  `permission` ENUM('DELETE', 'INSERT', 'READ', 'UPDATE', 'UPDATE_SELF'),
  `object_id` char(36) NOT NULL,
  CONSTRAINT `permission_entities` FOREIGN KEY (`entity_id`) REFERENCES `Entities` (`id`),
  CONSTRAINT `permission_objects` FOREIGN KEY (`object_id`) REFERENCES `Objects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Stages` (
  `id` char(36) NOT NULL,
  `entity_id` char(36) NOT NULL,
  `object_id` char(36) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY(`id`),
  CONSTRAINT `stages_entities` FOREIGN KEY (`entity_id`) REFERENCES `Entities` (`id`),
  CONSTRAINT `stages_objects` FOREIGN KEY (`object_id`) REFERENCES `Objects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Elements` (
  `id` char(36) NOT NULL,
  `stage_id` char(36) NOT NULL,
  `description` text NOT NULL,
  `volume` double NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `price_client` decimal(10,2) NOT NULL,
  `room` varchar(200) NOT NULL,
  `completed` tinyint(1) NOT NULL,
  PRIMARY KEY(`id`),
  CONSTRAINT `elements_stages` FOREIGN KEY (`stage_id`) REFERENCES `Stages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Tickets` (
  `id` char(36) NOT NULL,
  `entity_id` char(36) NOT NULL,
  `description` text NOT NULL,
  `value` decimal(10,2) NOT NULL,
  `status` ENUM('PENDING','ACCEPTED','REJECTED') NOT NULL,
  `reason` text,
  PRIMARY KEY(`id`),
  CONSTRAINT `tickets_entities` FOREIGN KEY (`entity_id`) REFERENCES `Entities` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Transactions` (
  `id` char(36) NOT NULL,
  `from` char(36) NOT NULL,
  `to` char(36) NOT NULL,
  `type` varchar(200) NOT NULL,
  `value` decimal(10,2) NOT NULL,
  `description` text NOT NULL,
  `object_id` char(36) NOT NULL,
  `date` timestamp NOT NULL,
  PRIMARY KEY(`id`),
  CONSTRAINT `transactions_entities1` FOREIGN KEY (`from`) REFERENCES `Entities` (`id`),
  CONSTRAINT `transactions_entities2` FOREIGN KEY (`to`) REFERENCES `Entities` (`id`),
  CONSTRAINT `transactions_objects` FOREIGN KEY (`object_id`) REFERENCES `Objects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Balance_per_day` (
  `id` char(36) NOT NULL,
  `entity_id` char(36) NOT NULL,
  `date` timestamp NOT NULL,
  `balance` decimal(10,2) NOT NULL,
  PRIMARY KEY(`id`),
  CONSTRAINT `Balance_entities` FOREIGN KEY (`entity_id`) REFERENCES `Entities` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



