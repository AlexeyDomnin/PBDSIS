CREATE TRIGGER on_insert_into_entities AFTER INSERT ON Entities FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),'new entity added in Entities');

CREATE TRIGGER on_insert_into_objects AFTER INSERT ON Objects FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),'new object added in Objects');

CREATE TRIGGER on_insert_into_assignments AFTER INSERT ON Assignments FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),'new assignment added in Assignments');

CREATE TRIGGER on_insert_into_permissions AFTER INSERT ON Permissions FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),'new permission added in Permissions');

CREATE TRIGGER on_update_entities AFTER UPDATE ON Entities FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),'some entity was updated in Entities');

CREATE TRIGGER on_update_objects AFTER UPDATE ON Objects FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),'some object was updated in Objects');

CREATE TRIGGER on_update_assignments AFTER UPDATE ON Assignments FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),'some assignment was updated in Assignments');

CREATE TRIGGER on_update_permissions AFTER UPDATE ON Permissions FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),'some permission was updated in Permissions');

CREATE TRIGGER on_delete_from_entities AFTER DELETE ON Entities FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),'some entity was deleted from Entities');

CREATE TRIGGER on_delete_from_objects AFTER DELETE ON Objects FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),'some object was deleted from Objects');

CREATE TRIGGER on_delete_from_assignment AFTER DELETE ON Assignment FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),'some assignment was deleted from Assignments');

CREATE TRIGGER on_delete_from_permissions AFTER DELETE ON Permissions FOR EACH ROW INSERT INTO Log(id,date,description) values(UUID(),NOW(),'some permission was deleted from Permissions');







