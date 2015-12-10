CREATE PROCEDURE create_ticket (IN account_id CHAR(36), IN descript text, IN val decimal(10,2), IN obj_id CHAR(36))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE isForeman tinyint(1);
	DECLARE hisAccount int;
	DECLARE hisObject int;
	DECLARE user_id CHAR(36);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT STRCMP(roles.role,'FOREMAN') INTO isForeman FROM roles inner join entities on roles.entity_id=entities.id 
						WHERE STRCMP(user,entities.username)=0 LIMIT 1;
	SELECT id INTO user_id FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
	select count(*) into hisAccount from accounts inner join entities on accounts.entity_id=entities.id 
					where accounts.id=account_id and STRCMP(user,entities.username)=0;
	select count(*) into hisObject from roles where roles.role='FOREMAN' and roles.entity_id=user_id and roles.object_id=obj_id;
	IF (isForeman = 0 and hisAccount > 0 and hisObject >0) THEN
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
	DECLARE CompanyId CHAR(36);
    
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT STRCMP(roles.role,'MANAGER') INTO isManager FROM roles inner join entities on roles.entity_id=entities.id 
						WHERE STRCMP(user,entities.username)=0 LIMIT 1;
	SELECT id INTO user_id FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
	SELECT id INTO CompanyId FROM entities WHERE entities.type='COMPANY' limit 1;
	select count(*) into hisObject from roles,tickets
					where roles.role='MANAGER' and roles.entity_id=user_id and 
                    			roles.object_id=tickets.object_id and
                    			tickets.id=t_id;
	IF (isManager = 0 and hisAccount > 0) THEN
    	begin
		update tickets set tickets.status = 'ACCEPTED' where tickets.id = t_id;
            	insert into transactions  
			select uuid(), CompanyId, tickets.account_id, tickets.value, tickets.description, tickets.object_id, now()
				from tikets where tickets.id = t_id;
		end;
	ELSE
		SELECT "Error";
	END IF;
END;

CREATE PROCEDURE reject_ticket(IN t_id CHAR(36), IN reas text)
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE isManager tinyint(1);
    	DECLARE hisObject int;
    	DECLARE user_id CHAR(36);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT STRCMP(roles.role,'MANAGER') INTO isManager FROM roles inner join entities on roles.entity_id=entities.id 
						WHERE STRCMP(user,entities.username)=0 LIMIT 1;
    	SELECT id INTO user_id FROM entities WHERE STRCMP(user,entities.username)=0 LIMIT 1;
    	select count(*) into hisObject from roles,tickets
				    	where roles.role='MANAGER' and roles.entity_id=user_id and 
                    			roles.object_id=tickets.object_id and
                    			tickets.id=t_id;
	IF (isManager = 0 and hisAccount >0) THEN
		update tickets set tickets.status = 'REJECTED', tickets.reason=reas where tickets.id = t_id;
	ELSE
		SELECT "Error";
	END IF;
END;

CREATE PROCEDURE create_tickets_auto(IN st_id CHAR(36))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE foreman_id CHAR(36);
	DECLARE acc_id CHAR(36);
	DECLARE obj_id CHAR(36);
	select objects.id into obj_id from stages inner join objects on stages.object_id=objects.id 
					where stages.id = st_id limit 1;
	select roles.entity_id into foreman_id from roles where roles.object_id=obj_id and roles.role='FOREMAN' limit 1;
	select accounts.id into acc_id from accounts where accounts.entity_id=foreman_id and accounts.name='SALARY' limit 1;
	insert into tickets
		select uuid(), acc_id, concat('Completed:', elements.description), elements.volume*elements.price, obj_id, 'PENDING', ''
			from elements where elements.stage_id=st_id;
end;
