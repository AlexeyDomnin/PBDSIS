PROCEDURE balance_per_day()
BEGIN
  CREATE OR REPLACE VIEW income
  AS
  SELECT
    transactions.to_account_id,
    SUM(value) income
  FROM transactions
  GROUP BY transactions.to_account_id;
  CREATE OR REPLACE VIEW outcome
  AS
  SELECT
    transactions.from_account_id,
    SUM(value) outcome
  FROM transactions
  GROUP BY transactions.from_account_id;
  CREATE OR REPLACE VIEW account_balance
  AS
  SELECT
    a.id,
    IFNULL(i.income, 0) - IFNULL(o.outcome, 0) AS balance
  FROM accounts a
    LEFT JOIN income i
      ON a.id = i.to_account_id
    LEFT JOIN outcome o
      ON a.id = o.from_account_id;
  INSERT INTO balance_per_day (id,account_id, balance)
    SELECT
      UUID(),
      id,
      balance
    FROM account_balance;
  INSERT INTO log (id, date, description)
    VALUES (UUID(), NOW(), 'the balance for each account is calculated and added to the table balance_per_day');
END