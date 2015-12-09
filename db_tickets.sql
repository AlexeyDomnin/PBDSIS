CREATE PROCEDURE create_ticket (IN account_id CHAR(36), IN descript text, IN val decimal(10,2), IN obj_id CHAR(36))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE isForeman tinyint(1);
	DECLARE hisAccount int;
	DECLARE hisObject int;
	DECLARE user_id CHAR(36);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT STRCMP(role,'FOREMAN') INTO isForeman FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
	SELECT id INTO user_id FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
	select count(*) into hisAccount from accounts inner join entities on accounts.entity_id=entities.id 
					where accounts.id=account_id and STRCMP(user,entities.username)=0;
	select count(*) into hisObject from roles where roles.role='FOREMAN' and roles.entity_id=user_id and roles.object_id=obj_id;
	IF (isForeman > 0 and hisAccount > 0 and hisObject >0) THEN
		insert into tickets values(UUID(), account_id, descript, val, obj_id, 'PENDING', '');
	ELSE
		SELECT "Error";
	END IF;
END;

CREATE PROCEDURE accept_ticket(IN t_id CHAR(36))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE isManager tinyint(1);
	DECLARE hisObject int;
	DECLARE user_id CHAR(36);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT STRCMP(role,'MANAGER') INTO isManager FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
	SELECT id INTO user_id FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
	select count(*) into hisObject from roles,tickets
					where roles.role='MANAGER' and roles.entity_id=user_id and 
                    			roles.object_id=tickets.object_id and
                    			tickets.id=t_id;
	IF (isManager > 0 and hisAccount > 0) THEN
    	begin
		update tickets set tickets.status = 'ACCEPTED' where tickets.id = t_id;
	end;
	ELSE
		SELECT "Error";
	END IF;
END;

CREATE PROCEDURE reject_ticket(IN t_id CHAR(36), IN reas text)
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE isForeman tinyint(1);
    	DECLARE hisObject int;
    	DECLARE user_id CHAR(36);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT STRCMP(role,'MANAGER') INTO isForeman FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
    	SELECT id INTO user_id FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
    	select count(*) into hisObject from roles,tickets
				    	where roles.role='MANAGER' and roles.entity_id=user_id and 
                    			roles.object_id=tickets.object_id and
                    			tickets.id=t_id;
	IF (isManager > 0 and hisAccount >0) THEN
		update tickets set tickets.status = 'REJECTED', tickets.reason=reas where tickets.id = t_id;
	ELSE
		SELECT "Error";
	END IF;
END;
