DELIMITER $$

CREATE DEFINER = 'root'@'localhost'
PROCEDURE new_sevryukov_task.accept_ticket (IN t_id char(36))
BEGIN
  DECLARE user varchar(200);
  DECLARE isForeman tinyint(1);
  DECLARE user_id varchar(200);
  SELECT
    SUBSTRING_INDEX(USER(), '@', 1) INTO user;
  SELECT
    STRCMP(role, 'MANAGER') INTO isForeman
  FROM subjects
  WHERE STRCMP(user, subjects.username) = 0 LIMIT 1;
  SELECT
    id INTO user_id
  FROM subjects
  WHERE STRCMP(user, subjects.username) = 0 LIMIT 1;
  IF (isManager > 0) THEN
    UPDATE tickets
    SET tickets.status = 'ACCEPTED'
    WHERE tickets.id = t_id;
  ELSE
    SELECT
      "Error";
  END IF;
END
$$

CREATE DEFINER = 'root'@'localhost'
PROCEDURE new_sevryukov_task.balance_per_day ()
BEGIN
  CREATE OR REPLACE VIEW income
  AS
  SELECT
    transactions.to_subject_id,
    SUM(value) income
  FROM transactions
  GROUP BY transactions.to_subject_id;
  CREATE OR REPLACE VIEW outcome
  AS
  SELECT
    transactions.from_subject_id,
    SUM(value) outcome
  FROM transactions
  GROUP BY transactions.from_subject_id;
  CREATE OR REPLACE VIEW account_balance
  AS
  SELECT
    e.id,
    IFNULL(i.income, 0) - IFNULL(o.outcome, 0) AS balance
  FROM subjects e
    LEFT JOIN income i
      ON e.id = i.to_subject_id
    LEFT JOIN outcome o
      ON e.id = o.from_subject_id;
  INSERT INTO balance_per_day (subject_id, balance)
    SELECT
      id,
      balance
    FROM account_balance;
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), 'the balance for each subject is calculated and added to the table balance_per_day');
END
$$

CREATE DEFINER = 'root'@'localhost'
PROCEDURE new_sevryukov_task.create_ticket (IN descript text, IN val decimal(10, 2))
BEGIN
  DECLARE user varchar(200);
  DECLARE isForeman tinyint(1);
  DECLARE user_id varchar(200);
  SELECT
    SUBSTRING_INDEX(USER(), '@', 1) INTO user;
  SELECT
    STRCMP(role, 'FOREMAN') INTO isForeman
  FROM subjects
  WHERE STRCMP(user, subjects.username) = 0 LIMIT 1;
  SELECT
    id INTO user_id
  FROM subjects
  WHERE STRCMP(user, subjects.username) = 0 LIMIT 1;
  IF (isForeman > 0) THEN
    INSERT INTO tickets
      VALUES (UUID(), user_id, descript, val, 'PENDING', '');
  ELSE
    SELECT
      "Error";
  END IF;
END
$$

CREATE DEFINER = 'root'@'localhost'
PROCEDURE new_sevryukov_task.delete_transaction (IN t_id char(36))
BEGIN
  DECLARE user varchar(200);
  DECLARE user_id varchar(200);
  DECLARE pCount int;
  SELECT
    SUBSTRING_INDEX(USER(), '@', 1) INTO user;
  SELECT
    id INTO user_id
  FROM subjects
  WHERE STRCMP(user, subjects.username) = 0 LIMIT 1;
  SELECT
    COUNT(*) INTO pCount
  FROM permissions
  WHERE STRCMP(subject_id, user_id) = 0
  AND STRCMP(object_id, (SELECT
      object_id
    FROM transactions
    WHERE STRCMP(t_id, transactions.id) = 0)) = 0
  AND permission = 'DELETE';
  IF (pCount > 0) THEN
    DELETE
      FROM transactions
    WHERE STRCMP(t_id, transactions.id) = 0;
  ELSE
    SELECT
      "Error";
  END IF;
END
$$

CREATE DEFINER = 'root'@'localhost'
PROCEDURE new_sevryukov_task.get_all_transactions ()
BEGIN
  DECLARE user varchar(200);
  DECLARE user_id varchar(200);
  DECLARE pCount int;
  SELECT
    SUBSTRING_INDEX(USER(), '@', 1) INTO user;
  SELECT
    id INTO user_id
  FROM subjects
  WHERE STRCMP(user, subjects.username) = 0 LIMIT 1;
  SELECT
    COUNT(*) INTO pCount
  FROM permissions
  WHERE STRCMP(subject_id, user_id) = 0
  AND permission = 'READ';
  IF (pCount > 0) THEN
    SELECT
      *
    FROM transactions
    WHERE transactions.object_id IN (SELECT
        object_id
      FROM permissions
      WHERE STRCMP(subject_id, user_id) = 0
      AND permission = 'READ');
  ELSE
    SELECT
      "Error";
  END IF;
END
$$

CREATE DEFINER = 'root'@'localhost'
PROCEDURE new_sevryukov_task.get_object_transactions (IN obj char(36))
BEGIN
  DECLARE user varchar(200);
  DECLARE user_id varchar(200);
  DECLARE pCount int;
  SELECT
    SUBSTRING_INDEX(USER(), '@', 1) INTO user;
  SELECT
    id INTO user_id
  FROM subjects
  WHERE STRCMP(user, subjects.username) = 0 LIMIT 1;
  SELECT
    COUNT(*) INTO pCount
  FROM permissions
  WHERE STRCMP(subject_id, user_id) = 0
  AND STRCMP(object_id, obj) = 0
  AND permission = 'READ';
  IF (pCount > 0) THEN
    SELECT
      *
    FROM transactions
    WHERE STRCMP(transactions.object_id, obj) = 0;
  ELSE
    SELECT
      "Error";
  END IF;
END
$$

CREATE DEFINER = 'root'@'localhost'
PROCEDURE new_sevryukov_task.insert_transaction (IN f char(36), IN t char(36), IN ty varchar(200), IN val decimal(10, 2), IN descr text, IN obj char(36))
BEGIN
  DECLARE user varchar(200);
  DECLARE user_id varchar(200);
  DECLARE pCount int;
  SELECT
    SUBSTRING_INDEX(USER(), '@', 1) INTO user;
  SELECT
    id INTO user_id
  FROM subjects
  WHERE STRCMP(user, subjects.username) = 0 LIMIT 1;
  SELECT
    COUNT(*) INTO pCount
  FROM permissions
  WHERE STRCMP(subject_id, user_id) = 0
  AND STRCMP(object_id, obj) = 0
  AND permission = 'INSERT';
  IF (pCount > 0) THEN
    INSERT INTO transactions
      VALUES (UUID(), f, t, ty, val, descr, obj, NOW());
  ELSE
    SELECT
      "Error";
  END IF;
END
$$

CREATE DEFINER = 'root'@'localhost'
PROCEDURE new_sevryukov_task.reject_ticket (IN t_id char(36), IN reas text)
BEGIN
  DECLARE user varchar(200);
  DECLARE isForeman tinyint(1);
  DECLARE user_id varchar(200);
  SELECT
    SUBSTRING_INDEX(USER(), '@', 1) INTO user;
  SELECT
    STRCMP(role, 'MANAGER') INTO isForeman
  FROM subjects
  WHERE STRCMP(user, subjects.username) = 0 LIMIT 1;
  SELECT
    id INTO user_id
  FROM subjects
  WHERE STRCMP(user, subjects.username) = 0 LIMIT 1;
  IF (isManager > 0) THEN
    UPDATE tickets
    SET tickets.status = 'REJECTED',
        tickets.reason = reas
    WHERE tickets.id = t_id;
  ELSE
    SELECT
      "Error";
  END IF;
END
$$


DELIMITER ;