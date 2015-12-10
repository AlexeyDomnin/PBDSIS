DROP PROCEDURE IF EXISTS add_new_element;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_new_element`(IN `stage_id` CHAR(36), IN `description` TEXT, IN `volume` DOUBLE, IN `price` DECIMAL(10,2), IN `price_client` DECIMAL(10,2), IN `room` VARCHAR(200))
    NO SQL
BEGIN
	DECLARE user CHAR(36);
	DECLARE owner_id CHAR(36);
	DECLARE user_id CHAR(36);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT id FROM entities WHERE username = user INTO user_id;
	SELECT entity_id FROM stages WHERE id = stage_id INTO owner_id;
	IF ((user_id = owner_id) OR (user='root')) THEN
		INSERT INTO elements (id, stage_id, description, volume, price, price_client, room, completed) VALUES (UUID(), stage_id, description, volume, price, price_client, room, 0);
	ELSE
		SELECT "Error";
	END IF;
END

DROP PROCEDURE IF EXISTS add_new_stage;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_new_stage`(IN `entity_id` VARCHAR(36), IN `object_id` VARCHAR(36), IN `description` TEXT)
    NO SQL
BEGIN
	DECLARE user CHAR(36);
        DECLARE user_id CHAR(36);
        DECLARE user_role VARCHAR(200);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT id FROM entities WHERE username = user INTO user_id;
        SELECT role FROM roles WHERE entity_id = user_id INTO user_role;
	IF ((user_role = 'FOREMAN') OR (user = 'root')) THEN
		INSERT INTO stages (id, entity_id, object_id, description) VALUES (UUID(), entity_id, object_id, description);
	ELSE
		SELECT "Error";
	END IF;
END

DROP PROCEDURE IF EXISTS complete_element;
CREATE DEFINER=`root`@`localhost` PROCEDURE `complete_element`(IN `element_id` CHAR(36))
    NO SQL
BEGIN
	DECLARE user CHAR(36);
        DECLARE tmp1 INT;
	DECLARE owner_id CHAR(36);
	DECLARE user_id CHAR(36);
        DECLARE stage_id CHAR(36);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT id FROM entities WHERE username = user INTO user_id;
        SELECT stage_id FROM elements WHERE id = element_id INTO stage_id;
	SELECT entity_id FROM stages WHERE id = stage_id INTO owner_id;
	IF ((user_id = owner_id) OR (user = 'root')) THEN
		UPDATE elements SET completed = 1 WHERE id=element_id;
	ELSE
		SELECT "Error";
	END IF;
        SELECT COUNT(*) FROM (SELECT * FROM elements WHERE stage_id = stage_id) AS el WHERE completed = 0 INTO tmp1;
        IF (tmp1 = 0) THEN
        	call create_tickets_auto(stage_id);
        END IF;
END

DROP PROCEDURE IF EXISTS delete_element;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_element`(IN `element_id` CHAR(36))
    NO SQL
BEGIN
	DECLARE user CHAR(36);
	DECLARE owner_id CHAR(36);
	DECLARE user_id CHAR(36);
        DECLARE stage_id CHAR(36);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT id FROM entities WHERE username = user INTO user_id;
        SELECT stage_id FROM elements WHERE id = element_id INTO stage_id;
	SELECT entity_id FROM stages WHERE id = stage_id INTO owner_id;
	IF ((user_id = owner_id) OR (user = 'root')) THEN
		DELETE FROM elements WHERE id=element_id;
	ELSE
		SELECT "Error";
	END IF;
END

DROP PROCEDURE IF EXISTS delete_stage;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_stage`(IN `stage_id` CHAR(36))
    NO SQL
BEGIN
	DECLARE user CHAR(36);
        DECLARE user_id CHAR(36);
        DECLARE user_role VARCHAR(200);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT id FROM entities WHERE username = user INTO user_id;
        SELECT role FROM roles WHERE entity_id = user_id INTO user_role;
	IF ((user_role = 'FOREMAN') OR (user = 'root')) THEN
		IF (SELECT COUNT(*) FROM elements WHERE ((stage_id = stage_id) AND (completed = 0)) > 0 ) THEN
			SELECT "not all elements completed";
		ELSE
                	DELETE FROM elements WHERE stage_id = stage_id;
			DELETE FROM stages WHERE id=stage_id;
		END IF;
	ELSE
		SELECT "Error";
	END IF;
END