DROP PROCEDURE IF EXISTS add_new_element;
CREATE DEFINER = 'root'@'localhost'
PROCEDURE add_new_element (IN `stage_id` CHAR(36) CHARSET utf32, IN `description` TEXT CHARSET utf8, IN `volume` DOUBLE, IN `price` DECIMAL(10,2), IN `price_client` DECIMAL(10,2), IN `room` VARCHAR(200) CHARSET utf8)
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE owner_id VARCHAR(200);
	DECLARE user_id VARCHAR(200);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT id FROM subjects WHERE username = user INTO user_id;
	SELECT subject_id FROM stages WHERE id = stage_id INTO owner_id;
	IF (subject_id = owner_id) THEN
		INSERT INTO elements (id, stage_id, description, volume, price, price_client, room, completed) VALUES (UUID(), stage_id, description, volume, price, price_client, room, 0);
	ELSE
		SELECT "Error";
	END IF;
END

DROP PROCEDURE IF EXISTS add_stage;
CREATE DEFINER=`root`@`localhost`
PROCEDURE add_stage (IN `subject_id` CHAR(36), IN `object_id` CHAR(36))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE isForeman TINYINT(1);
    DECLARE user_id VARCHAR(200);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT STRCMP(role,'FOREMAN') INTO isForeman FROM subjects WHERE STRCMP(user,subjects.username)=0 LIMIT 1;
	IF (isForeman > 0) THEN
		INSERT INTO stages (id, subject_id, object_id) VALUES (UUID(), subject_id, object_id);
	ELSE
		SELECT "Error";
	END IF;
END

DROP PROCEDURE IF EXISTS complete_element;
CREATE DEFINER=`root`@`localhost`
PROCEDURE complete_element (IN `el_id` CHAR(36))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE owner_id VARCHAR(200);
	DECLARE user_id VARCHAR(200);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT id FROM subjects WHERE username = user INTO user_id;
	SELECT subject_id FROM stages WHERE id = stage_id INTO owner_id;
	IF (subject_id = owner_id) THEN
		UPDATE elements SET completed = 1 WHERE id=el_id;
	ELSE
		SELECT "Error";
	END IF;		
END

DROP PROCEDURE IF EXISTS delete_element;
CREATE DEFINER=`root`@`localhost`
PROCEDURE delete_element (IN `el_id` CHAR(36))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE owner_id VARCHAR(200);
	DECLARE user_id VARCHAR(200);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT id FROM subjects WHERE username = user INTO user_id;
	SELECT subject_id FROM stages WHERE id = stage_id INTO owner_id;
	IF (subject_id = owner_id) THEN
		DELETE FROM elements WHERE id=el_id;
	ELSE
		SELECT "Error";
	END IF;		
END

DROP PROCEDURE IF EXISTS delete_stage;
CREATE DEFINER=`root`@`localhost` 
PROCEDURE delete_stage (IN `stg_id` CHAR(36))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE isForeman TINYINT(1);
    DECLARE user_id VARCHAR(200);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT STRCMP(role,'FOREMAN') INTO isForeman FROM subjects WHERE STRCMP(user,subjects.username)=0 LIMIT 1;
	IF (isForeman > 0) THEN
		IF (SELECT COUNT(*) FROM elements WHERE ((stage_id = stg_id) AND (completed = 0)) > 0 ) THEN
			SELECT "not all elements completed";
		ELSE
			DELETE FROM stages WHERE id=stg_id;
		END IF;
	ELSE
		SELECT "Error";
	END IF;
END