USE `new_sevryukov_task`;


-- Дамп структуры для процедура new_sevryukov_task.test
DROP PROCEDURE IF EXISTS `test`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `test`(IN `test_type` INT)
BEGIN
	################################################
	##Запускаем "CALL test(param)", где param 0..3##
	################################################

	DECLARE total_test_procedures INT;
	DECLARE i INT;
	DECLARE current_procedure_name VARCHAR(64);

	DROP TEMPORARY TABLE IF EXISTS test_results;
	CREATE TEMPORARY TABLE test_results (
		id INT AUTO_INCREMENT,
		name VARCHAR(200) NOT NULL, 
		description TEXT,
		success TINYINT(1) NOT NULL,
      PRIMARY KEY (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	
	#Логгируем
	INSERT INTO log(id, date, description) VALUES (UUID(), NOW(), CONCAT('test has been started (with param=', test_type, ')'));
	
	/*
	#Ищем все процедуры в нашей бд
	SELECT COUNT(*) INTO total_test_procedures FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_SCHEMA = DATABASE();

	#Извлекаем все процедуры с test_ и запускаем их
	SET i = 0;
	WHILE (i < total_test_procedures) DO
		SET current_procedure_name = "";
		SELECT ROUTINE_NAME INTO current_procedure_name FROM INFORMATION_SCHEMA.ROUTINES limit i,1;
		SET i = i + 1;
		
		IF LOCATE('test_', current_procedure_name) THEN
			SET @stored_procedure = CONCAT("CALL ", current_procedure_name);
			PREPARE Query FROM @stored_procedure;
			EXECUTE Query;
			DEALLOCATE PREPARE Query;
		END IF;
		
	END WHILE;
	*/
	
	CASE test_type
		WHEN 0 THEN
			BEGIN
				#Общий тест
				CALL test_get_object_transactions;
				CALL test_get_all_transactions;
				CALL test_insert_transaction;
				CALL test_delete_transaction;
				CALL test_add_new_stage;
				CALL test_delete_stage;
				CALL test_add_new_element;
				CALL test_delete_element;
				CALL test_complete_element;
				CALL test_views;
			END;
		WHEN 1 THEN
			BEGIN
				#Тест хранимых процедур
				#Тестируем транзакции (Андрей)
				CALL test_get_object_transactions;
				CALL test_get_all_transactions;
				CALL test_insert_transaction;
				CALL test_delete_transaction;
				#Тестируем этапы (Юля)
				CALL test_add_new_stage;
				CALL test_delete_stage;
				CALL test_add_new_element;
				CALL test_delete_element;
				CALL test_complete_element;
			END;
		WHEN 2 THEN
			BEGIN
				#Автоматический тест вьюх (Алеха Домнин)
				CALL test_views;
			END;
		WHEN 3 THEN
			BEGIN
				#Тест триггеров
				#Скоро
			END;
		ELSE
			BEGIN
				SELECT "Argument error";
			END;
	END CASE;
	
	SELECT * FROM test_results;
END//
DELIMITER ;


-- Дамп структуры для процедура new_sevryukov_task.test_add_new_element
DROP PROCEDURE IF EXISTS `test_add_new_element`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_add_new_element`()
BEGIN
		DECLARE temp_1 char(36);
		
		INSERT INTO entities values (uuid(),'EMPLOYEE', 'Emp_1', 'emp_1'),
									(uuid(),'EMPLOYEE', 'Emp_2', 'root'),
									(uuid(),'CLIENT', 'Clt_1', 'clt_1');
		insert into objects select uuid() as id,
							(select id from entities where name = 'Clt_1') as entity_id, 
							'Obj_1' as description;	
		insert into roles select uuid() as id,
						  (select id from entities where name = 'Emp_2') as entity_id, 
						  (select id from objects where description = 'Obj_1') as object_id, 
						  'FOREMAN' as role;
		insert into stages select uuid() as id,
				  (select id from entities where name = 'Emp_1') as entity_id, 
				  (select id from objects where description = 'Obj_1') as object_id, 
				  'Stage_1' as description;
		select id into temp_1 from stages where description = 'Stage_1';
		call add_new_element (temp_1, 'Element_1', '3', '100', '250', 'bedroom');
		if (select count(*) from elements where 
				stage_id = temp_1 and
				description = 'Element_1' and
				volume = 3 and
				price = 100 and
				price_client = 250 and
				room = 'bedroom') = 1
		then
				INSERT INTO test_results(name, description, success) VALUES('add_new_element', 'Creation element.', 1);
		else
				INSERT INTO test_results(name, description, success) VALUES('add_new_element', 'Creation element.', 0);
		end if;

		delete from elements where description = 'Element_1';
		delete from stages where description = 'Stage_1';
		select id into temp_1 from objects where description = 'Obj_1';
		delete from roles where object_id = temp_1;
		delete from objects where description = 'Obj_1';
		delete from entities where name = 'Emp_1' OR name = 'Emp_2' or name = 'Clt_1';

    END//
DELIMITER ;


-- Дамп структуры для процедура new_sevryukov_task.test_add_new_stage
DROP PROCEDURE IF EXISTS `test_add_new_stage`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_add_new_stage`()
BEGIN
		DECLARE temp_1 char(36);
		DECLARE temp_2 char(36);
		
		INSERT INTO entities values (uuid(),'EMPLOYEE', 'Emp_1', 'emp_1'),
									(uuid(),'EMPLOYEE', 'Emp_2', 'root'),
									(uuid(),'CLIENT', 'Clt_1', 'clt_1');
		insert into objects select uuid() as id,
							(select id from entities where name = 'Clt_1') as entity_id, 
							'Obj_1' as description;	
		insert into roles select uuid() as id,
						  (select id from entities where name = 'Emp_2') as entity_id, 
						  (select id from objects where description = 'Obj_1') as object_id, 
						  'FOREMAN' as role;
		select id into temp_1 from entities where name = 'Emp_1';
		select id into temp_2 from objects where description = 'Obj_1';
		call add_new_stage(temp_1, temp_2, 'Stage_1');

		if (select count(*) from stages where entity_id = temp_1 and object_id = temp_2 and description = 'Stage_1') = 1 then
				INSERT INTO test_results(name, description, success) VALUES('add_new_stage', 'Creation stage.', 1);
		else
				INSERT INTO test_results(name, description, success) VALUES('add_new_stage', 'Creation stage.', 0);
		end if;
		
		delete from stages where description = 'Stage_1';
		select id into temp_1 from objects where description = 'Obj_1';
		delete from roles where object_id = temp_1;
		delete from objects where description = 'Obj_1';
		delete from entities where name = 'Emp_1' OR name = 'Emp_2' or name = 'Clt_1';
    END//
DELIMITER ;


-- Дамп структуры для процедура new_sevryukov_task.test_complete_element
DROP PROCEDURE IF EXISTS `test_complete_element`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_complete_element`()
BEGIN
		DECLARE temp_1 char(36);
		INSERT INTO entities values (uuid(),'EMPLOYEE', 'Emp_1', 'emp_1'),
									(uuid(),'EMPLOYEE', 'Emp_2', 'root'),
									(uuid(),'CLIENT', 'Clt_1', 'clt_1');
		insert into objects select uuid() as id,
							(select id from entities where name = 'Clt_1') as entity_id, 
							'Obj_1' as description;	
		insert into roles select uuid() as id,
						  (select id from entities where name = 'Emp_2') as entity_id, 
						  (select id from objects where description = 'Obj_1') as object_id, 
						  'FOREMAN' as role;
		insert into stages select uuid() as id,
				  (select id from entities where name = 'Emp_1') as entity_id, 
				  (select id from objects where description = 'Obj_1') as object_id, 
				  'Stage_1' as description;
		insert into elements select uuid() as id,
				  (select id from stages where description = 'Stage_1') as stage_id,  
				  'Element_1' as description,
				  '2' as volume,
				  '50' as price,
				  '80' as price_client,
				  'bedroom' as room,
				  '0' as completed;

		select id into temp_1 from elements where description = 'Element_1';
		call complete_element(temp_1);
				
		if (select completed from elements where description = 'Element_1') = 1 then
				INSERT INTO test_results(name, description, success) VALUES('complete_element', 'Complete element.', 1);
		else
				INSERT INTO test_results(name, description, success) VALUES('complete_element', 'Complete element.', 0);
		end if;
		delete from elements where description = 'Element_1';
		delete from stages where description = 'Stage_1';
		select id into temp_1 from objects where description = 'Obj_1';
		delete from roles where object_id = temp_1;
		delete from objects where description = 'Obj_1';
		delete from entities where name = 'Emp_1' OR name = 'Emp_2' or name = 'Clt_1';
    END//
DELIMITER ;


-- Дамп структуры для процедура new_sevryukov_task.test_delete_element
DROP PROCEDURE IF EXISTS `test_delete_element`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_delete_element`()
BEGIN
		DECLARE temp_1 char(36);
		
		INSERT INTO entities values (uuid(),'EMPLOYEE', 'Emp_1', 'emp_1'),
									(uuid(),'EMPLOYEE', 'Emp_2', 'root'),
									(uuid(),'CLIENT', 'Clt_1', 'clt_1');
		insert into objects select uuid() as id,
							(select id from entities where name = 'Clt_1') as entity_id, 
							'Obj_1' as description;	
		insert into roles select uuid() as id,
						  (select id from entities where name = 'Emp_2') as entity_id, 
						  (select id from objects where description = 'Obj_1') as object_id, 
						  'FOREMAN' as role;
		insert into stages select uuid() as id,
				  (select id from entities where name = 'Emp_1') as entity_id, 
				  (select id from objects where description = 'Obj_1') as object_id, 
				  'Stage_1' as description;
		insert into elements select uuid() as id,
				  (select id from stages where description = 'Stage_1') as stage_id,  
				  'Element_1' as description,
				  '2' as volume,
				  '50' as price,
				  '80' as price_client,
				  'bedroom' as room,
				  '0' as completed;

		select id into temp_1 from elements where description = 'Element_1';
		call delete_element(temp_1);
		
		if (select count(*) from elements where description = 'Element_1') = 0 then
				INSERT INTO test_results(name, description, success) VALUES('delete_element', 'Delete element.', 1);
		else
				INSERT INTO test_results(name, description, success) VALUES('delete_element', 'Delete element.', 0);
		end if;
		delete from elements where description = 'Element_1';
		delete from stages where description = 'Stage_1';
		select id into temp_1 from objects where description = 'Obj_1';
		delete from roles where object_id = temp_1;
		delete from objects where description = 'Obj_1';
		delete from entities where name = 'Emp_1' OR name = 'Emp_2' or name = 'Clt_1';
    END//
DELIMITER ;


-- Дамп структуры для процедура new_sevryukov_task.test_delete_stage
DROP PROCEDURE IF EXISTS `test_delete_stage`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_delete_stage`()
BEGIN
		DECLARE temp_1 char(36);
		INSERT INTO entities values (uuid(),'EMPLOYEE', 'Emp_1', 'emp_1'),
									(uuid(),'EMPLOYEE', 'Emp_2', 'root'),
									(uuid(),'CLIENT', 'Clt_1', 'clt_1');
		insert into objects select uuid() as id,
							(select id from entities where name = 'Clt_1') as entity_id, 
							'Obj_1' as description;	
		insert into roles select uuid() as id,
						  (select id from entities where name = 'Emp_2') as entity_id, 
						  (select id from objects where description = 'Obj_1') as object_id, 
						  'FOREMAN' as role;
		insert into stages select uuid() as id,
				  (select id from entities where name = 'Emp_1') as entity_id, 
				  (select id from objects where description = 'Obj_1') as object_id, 
				  'Stage_1' as description;
		select id into temp_1 from stages where description = 'Stage_1';
		call delete_stage(temp_1);
		
		if (select count(*) from stages where description = 'Stage_1') = 0 then
				INSERT INTO test_results(name, description, success) VALUES('delete_stage', 'Delete stage.', 1);
		else
				INSERT INTO test_results(name, description, success) VALUES('delete_stage', 'Delete stage.', 0);
		end if;
		
		delete from stages where description = 'Stage_1';
		select id into temp_1 from objects where description = 'Obj_1';
		delete from roles where object_id = temp_1;
		delete from objects where description = 'Obj_1';
		delete from entities where name = 'Emp_1' OR name = 'Emp_2' or name = 'Clt_1';
    END//
DELIMITER ;


-- Дамп структуры для процедура new_sevryukov_task.test_delete_transaction
DROP PROCEDURE IF EXISTS `test_delete_transaction`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_delete_transaction`()
BEGIN
	DECLARE test_id CHAR(36) DEFAULT uuid();
	DECLARE test_user VARCHAR(200);
	DECLARE real_transaction_count INT;
	
	IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_SCHEMA = DATABASE() AND ROUTINE_NAME = 'delete_transaction') > 0 THEN
		#Получаем имя текущего пользователя
		SELECT SUBSTRING_INDEX(USER(),'@',1) INTO test_user;
		
		#Вставляем тестовые данные
		INSERT INTO entities(id, type, name, username) VALUES(test_id, 'CLIENT', 'test name', test_user);
		INSERT INTO objects(id, entity_id, description) VALUES(test_id, test_id, 'test description');
		INSERT INTO accounts(id, entity_id, name) VALUES(test_id, test_id, 'OTHER');
		INSERT INTO permissions(entity_id, permission, object_id) VALUES(test_id, 'DELETE', test_id);
		INSERT INTO transactions(id, from_account_id, to_account_id, value, description, object_id) VALUES(test_id, test_id, test_id, 300, 'test description', test_id);
		
		#Вызываем процедуру и считаем вывод
		CALL delete_transaction(test_id);
		
		SELECT COUNT(*) INTO real_transaction_count FROM transactions WHERE id = test_id;
		
		#Проверяем корректность
		IF (real_transaction_count = 0) THEN
			INSERT INTO test_results(name, description, success) VALUES('delete_transaction', 'adding and removing 1 row', 1);
		ELSE
			INSERT INTO test_results(name, description, success) VALUES('delete_transaction', 'adding and removing 1 row', 0);
		END IF;
		
		#Удаляем данные
		DELETE FROM transactions WHERE id = test_id;
		DELETE FROM permissions WHERE object_id = test_id;
		DELETE FROM objects WHERE id = test_id;
		DELETE FROM accounts WHERE id = test_id;
		DELETE FROM entities WHERE id = test_id;
	END IF;
END//
DELIMITER ;


-- Дамп структуры для процедура new_sevryukov_task.test_get_all_transactions
DROP PROCEDURE IF EXISTS `test_get_all_transactions`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_get_all_transactions`()
BEGIN
	DECLARE test_id CHAR(36) DEFAULT uuid();
	DECLARE test_id_second CHAR(36) DEFAULT uuid();
	DECLARE test_user VARCHAR(200);
	DECLARE test_transaction_count INT;
	DECLARE real_transaction_count INT;
	
	IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_SCHEMA = DATABASE() AND ROUTINE_NAME = 'get_all_transactions') > 0 THEN
		#Получаем имя текущего пользователя
		SELECT SUBSTRING_INDEX(USER(),'@',1) INTO test_user;
		
		#Считаем сколько транзакций было до теста
		SELECT COUNT(*) INTO real_transaction_count FROM transactions WHERE transactions.object_id IN (SELECT object_id FROM permissions WHERE STRCMP(entity_id,test_id)=0 AND permission='READ');
		
		#Вставляем тестовые данные
		INSERT INTO entities(id, type, name, username) VALUES(test_id, 'CLIENT', 'test name', test_user);
		INSERT INTO objects(id, entity_id, description) VALUES(test_id, test_id, 'test description');
		INSERT INTO accounts(id, entity_id, name) VALUES(test_id, test_id, 'OTHER');
		INSERT INTO permissions(entity_id, permission, object_id) VALUES(test_id, 'READ', test_id);
		INSERT INTO transactions(id, from_account_id, to_account_id, value, description, object_id) VALUES(test_id, test_id, test_id, 100, 'test description', test_id);
		INSERT INTO transactions(id, from_account_id, to_account_id, value, description, object_id) VALUES(test_id_second, test_id, test_id, 100, 'test description', test_id);
		
		#Вызываем процедуру и считаем вывод
		CALL get_all_transactions;
		SELECT FOUND_ROWS() INTO test_transaction_count;
		
		#Проверяем корректность
		IF (real_transaction_count + 2 = test_transaction_count) THEN
			INSERT INTO test_results(name, description, success) VALUES('get_all_transactions', 'adding 2 rows into transactions table', 1);
		ELSE
			INSERT INTO test_results(name, description, success) VALUES('get_all_transactions', 'adding 2 rows into transactions table', 0);
		END IF;
		
		#Удаляем данные
		DELETE FROM transactions WHERE id = test_id;
		DELETE FROM transactions WHERE id = test_id_second;
		DELETE FROM permissions WHERE object_id = test_id;
		DELETE FROM accounts WHERE id = test_id;
		DELETE FROM objects WHERE id = test_id;
		DELETE FROM entities WHERE id = test_id;
	END IF;
END//
DELIMITER ;


-- Дамп структуры для процедура new_sevryukov_task.test_get_object_transactions
DROP PROCEDURE IF EXISTS `test_get_object_transactions`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_get_object_transactions`()
BEGIN
	DECLARE test_id CHAR(36) DEFAULT uuid();
	DECLARE test_id_second CHAR(36) DEFAULT uuid();
	DECLARE test_user VARCHAR(200);
	DECLARE test_transaction_count INT;
	
	IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_SCHEMA = DATABASE() AND ROUTINE_NAME = 'get_object_transactions') > 0 THEN
		#Получаем имя текущего пользователя
		SELECT SUBSTRING_INDEX(USER(),'@',1) INTO test_user;
		
		#Вставляем тестовые данные
		INSERT INTO entities(id, type, name, username) VALUES(test_id, 'CLIENT', 'test name', test_user);
		INSERT INTO objects(id, entity_id, description) VALUES(test_id, test_id, 'test description');
		INSERT INTO accounts(id, entity_id, name) VALUES(test_id, test_id, 'OTHER');
		INSERT INTO permissions(entity_id, permission, object_id) VALUES(test_id, 'READ', test_id);
		INSERT INTO transactions(id, from_account_id, to_account_id, value, description, object_id) VALUES(test_id, test_id, test_id, 100, 'test description', test_id);
		INSERT INTO transactions(id, from_account_id, to_account_id, value, description, object_id) VALUES(test_id_second, test_id, test_id, 100, 'test description', test_id);
		
		#Вызываем процедуру и считаем вывод
		CALL get_object_transactions(test_id);
		SELECT FOUND_ROWS() INTO test_transaction_count;
		
		#Проверяем корректность
		IF (test_transaction_count = 2) THEN
			INSERT INTO test_results(name, description, success) VALUES('get_object_transactions', 'adding 2 rows into transactions table', 1);
		ELSE
			INSERT INTO test_results(name, description, success) VALUES('get_object_transactions', 'adding 2 rows into transactions table', 0);
		END IF;
		
		#Удаляем данные
		DELETE FROM transactions WHERE id = test_id;
		DELETE FROM transactions WHERE id = test_id_second;
		DELETE FROM permissions WHERE object_id = test_id;
		DELETE FROM accounts WHERE id = test_id;
		DELETE FROM objects WHERE id = test_id;
		DELETE FROM entities WHERE id = test_id;
	END IF;
END//
DELIMITER ;


-- Дамп структуры для процедура new_sevryukov_task.test_insert_transaction
DROP PROCEDURE IF EXISTS `test_insert_transaction`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_insert_transaction`()
BEGIN
	DECLARE test_id CHAR(36) DEFAULT uuid();
	DECLARE test_user VARCHAR(200);
	DECLARE real_transaction_count INT;
	
	IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_SCHEMA = DATABASE() AND ROUTINE_NAME = 'insert_transaction') > 0 THEN
		#Получаем имя текущего пользователя
		SELECT SUBSTRING_INDEX(USER(),'@',1) INTO test_user;
		
		#Вставляем тестовые данные
		INSERT INTO entities(id, type, name, username) VALUES(test_id, 'CLIENT', 'test name', test_user);
		INSERT INTO objects(id, entity_id, description) VALUES(test_id, test_id, 'test description');
		INSERT INTO accounts(id, entity_id, name) VALUES(test_id, test_id, 'OTHER');
		INSERT INTO permissions(entity_id, permission, object_id) VALUES(test_id, 'INSERT', test_id);
		
		#Вызываем процедуру и считаем вывод
		CALL insert_transaction(test_id, test_id, 200, 'test insert_transaction', test_id);
		
		SELECT COUNT(*) INTO real_transaction_count FROM transactions WHERE object_id = test_id;
		
		#Проверяем корректность
		IF (real_transaction_count = 1) THEN
			INSERT INTO test_results(name, description, success) VALUES('insert_transaction', 'adding 1 row from stored procedure', 1);
		ELSE
			INSERT INTO test_results(name, description, success) VALUES('insert_transaction', 'adding 1 row from stored procedure', 0);
		END IF;
		
		#Удаляем данные
		DELETE FROM transactions WHERE object_id = test_id;
		DELETE FROM permissions WHERE object_id = test_id;
		DELETE FROM objects WHERE id = test_id;
		DELETE FROM accounts WHERE id = test_id;
		DELETE FROM entities WHERE id = test_id;
	END IF;
END//
DELIMITER ;


-- Дамп структуры для процедура new_sevryukov_task.test_views
DROP PROCEDURE IF EXISTS `test_views`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_views`()
BEGIN
	DECLARE total int;
	DECLARE i int;
	DECLARE temp varchar (64);
	SET i = 0;
	SELECT count(*) INTO total FROM information_schema.views where TABLE_SCHEMA = DATABASE();
	WHILE (i < total) DO
		SET temp = "";
		SELECT TABLE_NAME INTO temp FROM information_schema.views limit i,1;
		SET i = i + 1;
		SET @Query = CONCAT("select count(*) into @total_rows_count from ", temp);
		
		PREPARE Query FROM @Query;
		EXECUTE Query;
		
		IF @total_rows_count > 0 THEN
			INSERT INTO test_results(name, description, success) VALUES('view test', temp, 1);
		ELSE
			INSERT INTO test_results(name, description, success) VALUES('view test', temp, 0);
		END IF;
		
		DEALLOCATE PREPARE Query;
	END WHILE;
END//
DELIMITER ;


-- Дамп структуры для представление new_sevryukov_task.view_entities_count
DROP VIEW IF EXISTS `view_entities_count`;
-- Создание временной таблицы для обработки ошибок зависимостей представлений
CREATE TABLE `view_entities_count` (
	`id` CHAR(36) NOT NULL COLLATE 'utf8_general_ci',
	`type` ENUM('EMPLOYEE','CLIENT','COMPANY','SHOP') NOT NULL COLLATE 'utf8_general_ci',
	`name` VARCHAR(200) NOT NULL COLLATE 'utf8_general_ci',
	`username` VARCHAR(200) NULL COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;


-- Дамп структуры для представление new_sevryukov_task.view_entities_count
DROP VIEW IF EXISTS `view_entities_count`;
-- Удаление временной таблицы и создание окончательной структуры представления
DROP TABLE IF EXISTS `view_entities_count`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `view_entities_count` AS SELECT * FROM `entities` ;
