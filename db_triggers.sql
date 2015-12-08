
DELIMITER $$
CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.BEFORE_INSERT_BALANCE_PER_DAY
BEFORE INSERT
ON new_sevryukov_task.balance_per_day
FOR EACH ROW
BEGIN
  SET NEW.id = UUID();
END
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.BEFORE_INSERT_subjects
BEFORE INSERT
ON new_sevryukov_task.subjects
FOR EACH ROW
BEGIN
  SET NEW.id = UUID();
END
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.BEFORE_INSERT_TRANSACTIONS
BEFORE INSERT
ON new_sevryukov_task.transactions
FOR EACH ROW
BEGIN
  SET NEW.id = UUID();
END
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.ins
AFTER INSERT
ON new_sevryukov_task.roles
FOR EACH ROW
BEGIN
  IF NEW.role = 'MANAGER' THEN
    INSERT INTO permissions
      VALUES (NEW.subject_id, 'DELETE', NEW.object_id), (NEW.subject_id, 'UPDATE', NEW.object_id), (NEW.subject_id, 'READ', NEW.object_id);
  END IF;
  IF NEW.role = 'FOREMAN' THEN
    INSERT INTO permissions
      VALUES (NEW.subject_id, 'INSERT', NEW.object_id), (NEW.subject_id, 'UPDATE_SELF', NEW.object_id), (NEW.subject_id, 'READ', NEW.object_id);
  END IF;
END
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_delete_from_assignments
AFTER DELETE
ON new_sevryukov_task.assignments
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("assignment ", OLD.subject_id, " - ", OLD.object_id, " deleted from Assignments by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_delete_from_elements
AFTER DELETE
ON new_sevryukov_task.elements
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("element ", OLD.id, " deleted from Elements by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_delete_from_objects
AFTER DELETE
ON new_sevryukov_task.objects
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("object ", OLD.id, " deleted from Objectss by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_delete_from_permissions
AFTER DELETE
ON new_sevryukov_task.permissions
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("permission ", OLD.subject_id, " : ", OLD.permission, " : ", OLD.object_id, " deleted from Permissions by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_delete_from_stages
AFTER DELETE
ON new_sevryukov_task.stages
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("stage ", OLD.id, " deleted from Stages by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_delete_from_subjects
AFTER DELETE
ON new_sevryukov_task.subjects
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("subject ", OLD.id, " deleted from subjects by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_insert_into_assignments
AFTER INSERT
ON new_sevryukov_task.assignments
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("new assignment ", NEW.subject_id, " - ", NEW.object_id, " added in Assignments by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_insert_into_elements
AFTER INSERT
ON new_sevryukov_task.elements
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("new element ", NEW.id, " added in Elements by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_insert_into_objects
AFTER INSERT
ON new_sevryukov_task.objects
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("new object ", NEW.id, " added in Objects by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_insert_into_permissions
AFTER INSERT
ON new_sevryukov_task.permissions
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("new permission ", NEW.subject_id, " : ", NEW.permission, " : ", NEW.object_id, " added in Permissions by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_insert_into_stages
AFTER INSERT
ON new_sevryukov_task.stages
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("new stage ", NEW.id, " added in Stages by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_insert_into_subjects
AFTER INSERT
ON new_sevryukov_task.subjects
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("new subject ", NEW.id, " added in subjects by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_update_assignments
AFTER UPDATE
ON new_sevryukov_task.assignments
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("assignment ", OLD.subject_id, " - ", OLD.object_id, " updated to ", OLD.subject_id, " - ", OLD.object_id, " in Assignments by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_update_objects
AFTER UPDATE
ON new_sevryukov_task.objects
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("object ", NEW.id, " updated in Objects by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_update_permissions
AFTER UPDATE
ON new_sevryukov_task.permissions
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("permission ", OLD.subject_id, " : ", OLD.permission, " : ", OLD.object_id, " updated to ", NEW.subject_id, " : ", NEW.permission, " : ", NEW.object_id, " in Permissions by ", USER()))
$$

CREATE
DEFINER = 'root'@'localhost'
TRIGGER new_sevryukov_task.on_update_subjects
AFTER UPDATE
ON new_sevryukov_task.subjects
FOR EACH ROW
  INSERT INTO Log (id, date, description)
    VALUES (UUID(), NOW(), CONCAT("subject ", NEW.id, " updated in subjects by ", USER()))
$$
DELIMITER ;