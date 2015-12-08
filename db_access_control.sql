CREATE PROCEDURE get_object_transactions (IN obj CHAR(36))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE user_id VARCHAR(200);
	DECLARE pCount INT;
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT id INTO user_id FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
	SELECT count(*) INTO pCount FROM permissions WHERE STRCMP(entity_id,user_id)=0 AND STRCMP(object_id,obj)=0 AND permission='READ';
	IF (pCount > 0) THEN
		SELECT * FROM transactions WHERE STRCMP(transactions.object_id,obj)=0;
	ELSE
		SELECT "Error";
	END IF;
END;

CREATE PROCEDURE get_all_transactions ()
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE user_id VARCHAR(200);
	DECLARE pCount INT;
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT id INTO user_id FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
	SELECT count(*) INTO pCount FROM permissions WHERE STRCMP(entity_id,user_id)=0 AND permission='READ';
	IF (pCount > 0) THEN
		SELECT * FROM transactions WHERE transactions.object_id IN (SELECT object_id FROM permissions WHERE STRCMP(entity_id,user_id)=0 AND permission='READ');
	ELSE
		SELECT "Error";
	END IF;
END;

CREATE PROCEDURE insert_transaction(IN f CHAR(36), IN t CHAR(36), IN ty VARCHAR(200), IN val DECIMAL(10,2), IN descr TEXT, IN obj char(36))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE user_id VARCHAR(200);
	DECLARE pCount INT;
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT id INTO user_id FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
	SELECT count(*) INTO pCount FROM permissions WHERE STRCMP(entity_id,user_id)=0 AND STRCMP(object_id,obj)=0 AND permission='INSERT';
	IF (pCount > 0) THEN
		INSERT INTO transactions VALUES (UUID(), f, t, ty, val, descr,obj,now());
	ELSE
		SELECT "Error";
	END IF;
END;

CREATE PROCEDURE delete_transaction(IN t_id CHAR(36))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE user_id VARCHAR(200);
	DECLARE pCount INT;
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT id INTO user_id FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
	SELECT count(*) INTO pCount FROM permissions WHERE STRCMP(entity_id,user_id)=0 AND STRCMP(object_id,(SELECT object_id FROM transactions WHERE STRCMP(t_id,transactions.id)=0))=0 AND permission='DELETE';
	IF (pCount > 0) THEN
		DELETE FROM transactions WHERE STRCMP(t_id,transactions.id)=0;
	ELSE
		SELECT "Error";
	END IF;
END;

CREATE TRIGGER ins AFTER INSERT ON roles
FOR EACH ROW
BEGIN
	IF NEW.role = 'MANAGER' THEN
		INSERT INTO permissions VALUES (NEW.entity_id,'DELETE',NEW.object_id), (NEW.entity_id,'UPDATE',NEW.object_id), (NEW.entity_id,'READ',NEW.object_id);
	END IF;
	IF NEW.role = 'FOREMAN' THEN
		INSERT INTO permissions VALUES (NEW.entity_id,'INSERT',NEW.object_id), (NEW.entity_id,'UPDATE_SELF',NEW.object_id), (NEW.entity_id,'READ',NEW.object_id);
	END IF;
END;
