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

CREATE PROCEDURE insert_transaction(IN f CHAR(36), IN t CHAR(36), IN val DECIMAL(10,2), IN descr TEXT, IN obj char(36))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE user_id VARCHAR(200);
	DECLARE pCount INT;
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT id INTO user_id FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
	SELECT count(*) INTO pCount FROM permissions WHERE STRCMP(entity_id,user_id)=0 AND STRCMP(object_id,obj)=0 AND permission='INSERT';
	IF (pCount > 0) THEN
		INSERT INTO transactions VALUES (UUID(), f, t, val, descr,obj,now());
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

CREATE TRIGGER role_del AFTER DELETE ON roles
FOR EACH ROW
BEGIN
	DELETE FROM permissions WHERE permissions.entity_id=OLD.entity_id AND permissions.object_id=OLD.object_id;
END;

CREATE TRIGGER roles_reject_non_employees BEFORE INSERT ON roles
FOR EACH ROW
BEGIN
	IF (SELECT count(*) FROM entities WHERE NEW.entity_id=entities.id AND entities.type='EMPLOYEE')=0 THEN
		INSERT INTO roles VALUES (NULL,NULL,NULL,NULL);
	END IF;
	if (not (select count(*) from roles where NEW.role='FOREMAN' and roles.role='FOREMAN' and new.object_id=roles.object_id)=0) then
		INSERT INTO roles VALUES (NULL,NULL,NULL,NULL);
	end if;
	if (not (select count(*) from roles where NEW.role='MANAGER' and roles.role='MANAGER' and new.object_id=roles.object_id)=0) then
		INSERT INTO roles VALUES (NULL,NULL,NULL,NULL);
	end if;
END;

CREATE TRIGGER objects_reject_non_clients BEFORE INSERT ON objects
FOR EACH ROW
BEGIN
	IF (SELECT count(*) FROM entities WHERE NEW.entity_id=entities.id AND entities.type='CLIENT')=0 THEN
		INSERT INTO objects VALUES (NULL,NULL,NULL);
	END IF;
END;
