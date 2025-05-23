CREATE EXTENSION dblink;

SELECT * FROM pg_extension WHERE extname = 'dblink';

SELECT dblink_connect('bank_accounts_conn','host=localhost port=5432 dbname=bank_accounts_db user=postgres password=admin');

SELECT
    c.first_name,
    c.last_name,
    c.email,
    a.account_number,
    a.account_type,
    a.balance,
    a.opened_date
FROM
    customers c
JOIN
    customer_account_junction caj ON c.customer_id = caj.customer_id
JOIN (
    SELECT
        account_id,
        account_number,
        account_type,
        balance,
        opened_date
    FROM dblink('bank_accounts_conn', 'SELECT account_id, account_number, account_type, balance, opened_date FROM accounts')
    AS accounts_from_remote(
        account_id INT,
        account_number VARCHAR(50),
        account_type VARCHAR(50),
        balance DECIMAL(15, 2),
        opened_date DATE
    )
) a ON caj.remote_account_id = a.account_id
ORDER BY
    c.last_name, c.first_name, a.account_number;

SELECT dblink_disconnect('bank_accounts_conn');