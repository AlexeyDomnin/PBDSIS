DROP PROCEDURE IF EXISTS new_sevryukov_task.balance_per_day;
CREATE DEFINER = 'root'@'localhost'
PROCEDURE new_sevryukov_task.balance_per_day()
BEGIN
  create or replace view income as
    select transactions.to_entity_id, sum(value) income 
    from transactions
    group by transactions.to_entity_id;
  create or replace view outcome as
    select transactions.from_entity_id, sum(value) outcome 
    from transactions
    group by transactions.from_entity_id;
  create or replace view account_balance as 
    select e.id, IFNULL(i.income,0) - IFNULL(o.outcome,0) as balance
    from entities e 
    LEFT join income i 
    	on e.id = i.to_entity_id
    LEFT join outcome o 
    	on e.id = o.from_entity_id;
  INSERT INTO balance_per_day (entity_id,balance) SELECT id,balance FROM account_balance;
END
