CREATE TRIGGER on_insert_into_subjects AFTER INSERT ON subjects FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("new subject ",NEW.id," added in subjects by ",USER()));

CREATE TRIGGER on_insert_into_objects AFTER INSERT ON Objects FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("new object ",NEW.id," added in Objects by ",USER()));

CREATE TRIGGER on_insert_into_assignments AFTER INSERT ON Assignments FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("new assignment ",NEW.subject_id," - ",NEW.object_id," added in Assignments by ",USER()));

CREATE TRIGGER on_insert_into_permissions AFTER INSERT ON Permissions FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("new permission ",NEW.subject_id," : ",NEW.permission," : ",NEW.object_id," added in Permissions by ",USER()));

CREATE TRIGGER on_insert_into_stages AFTER INSERT ON Stages FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("new stage ",NEW.id," added in Stages by ",USER()));

CREATE TRIGGER on_insert_into_elements AFTER INSERT ON Elements FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("new element ",NEW.id," added in Elements by ",USER()));

CREATE TRIGGER on_update_subjects AFTER UPDATE ON subjects FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("subject ",NEW.id," updated in subjects by ",USER()));

CREATE TRIGGER on_update_objects AFTER UPDATE ON Objects FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("object ",NEW.id," updated in Objects by ",USER()));

CREATE TRIGGER on_update_assignments AFTER UPDATE ON Assignments FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("assignment ",OLD.subject_id," - ",OLD.object_id," updated to ",OLD.subject_id," - ",OLD.object_id, " in Assignments by ",USER()));

CREATE TRIGGER on_update_permissions AFTER UPDATE ON Permissions FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("permission ",OLD.subject_id," : ",OLD.permission," : ",OLD.object_id, " updated to ",NEW.subject_id," : ",NEW.permission," : ",NEW.object_id," in Permissions by ",USER()));

CREATE TRIGGER on_delete_from_subjects AFTER DELETE ON subjects FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("subject ",OLD.id," deleted from subjects by ",USER()));

CREATE TRIGGER on_delete_from_objects AFTER DELETE ON Objects FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("object ",OLD.id," deleted from Objectss by ",USER()));

CREATE TRIGGER on_delete_from_assignments AFTER DELETE ON Assignments FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("assignment ",OLD.subject_id," - ",OLD.object_id," deleted from Assignments by ",USER()));

CREATE TRIGGER on_delete_from_permissions AFTER DELETE ON Permissions FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("permission ",OLD.subject_id," : ",OLD.permission," : ",OLD.object_id, " deleted from Permissions by ",USER()));

CREATE TRIGGER on_delete_from_stages AFTER DELETE ON Stages FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("stage ",OLD.id, " deleted from Stages by ",USER()));

CREATE TRIGGER on_delete_from_elements AFTER DELETE ON Elements FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),CONCAT("element ",OLD.id, " deleted from Elements by ",USER()));






