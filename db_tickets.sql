
CREATE PROCEDURE create_ticket (IN descript text, IN val decimal(10,2))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE isForeman tinyint(1);
    DECLARE user_id varchar(200);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT STRCMP(role,'FOREMAN') INTO isForeman FROM subjects WHERE STRCMP(user,subjects.username)=0 LIMIT 1;
    SELECT id INTO user_id FROM subjects WHERE STRCMP(user,subjects.username)=0 LIMIT 1;
	IF (isForeman > 0) THEN
		insert into tickets values(UUID(), user_id, descript, val, 'PENDING', '');
	ELSE
		SELECT "Error";
	END IF;
END;

CREATE PROCEDURE accept_ticket(IN t_id CHAR(36))
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE isForeman tinyint(1);
    DECLARE user_id varchar(200);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT STRCMP(role,'MANAGER') INTO isForeman FROM subjects WHERE STRCMP(user,subjects.username)=0 LIMIT 1;
    SELECT id INTO user_id FROM subjects WHERE STRCMP(user,subjects.username)=0 LIMIT 1;
	IF (isManager > 0) THEN
		update tickets set tickets.status = 'ACCEPTED' where tickets.id = t_id;
	ELSE
		SELECT "Error";
	END IF;
END;

CREATE PROCEDURE reject_ticket(IN t_id CHAR(36), IN reas text)
BEGIN
	DECLARE user VARCHAR(200);
	DECLARE isForeman tinyint(1);
    DECLARE user_id varchar(200);
	SELECT SUBSTRING_INDEX(USER(),'@',1) INTO user;
	SELECT STRCMP(role,'MANAGER') INTO isForeman FROM subjects WHERE STRCMP(user,subjects.username)=0 LIMIT 1;
    SELECT id INTO user_id FROM subjects WHERE STRCMP(user,subjects.username)=0 LIMIT 1;
	IF (isManager > 0) THEN
		update tickets set tickets.status = 'REJECTED', tickets.reason=reas where tickets.id = t_id;
	ELSE
		SELECT "Error";
	END IF;
END;
