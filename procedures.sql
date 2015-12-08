DROP PROCEDURE IF EXISTS new_sevryukov_task.balance_per_day;
CREATE DEFINER = 'root'@'localhost'
PROCEDURE new_sevryukov_task.balance_per_day()
BEGIN
  create or replace view income as
    select transactions.to_subject_id, sum(value) income 
    from transactions
    group by transactions.to_subject_id;
  create or replace view outcome as
    select transactions.from_subject_id, sum(value) outcome 
    from transactions
    group by transactions.from_subject_id;
  create or replace view account_balance as 
    select e.id, IFNULL(i.income,0) - IFNULL(o.outcome,0) as balance
    from subjects e 
    LEFT join income i 
    	on e.id = i.to_subject_id
    LEFT join outcome o 
    	on e.id = o.from_subject_id;
  INSERT INTO balance_per_day (subject_id,balance) SELECT id,balance FROM account_balance;
  INSERT INTO Log (id, date, description) VALUES (UUID(), NOW(), 'the balance for each subject is calculated and added to the table balance_per_day');
END
