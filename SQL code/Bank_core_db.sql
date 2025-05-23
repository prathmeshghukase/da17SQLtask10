CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE
);

INSERT INTO customers (first_name, last_name, email) VALUES
('John', 'Doe', 'john.doe@example.com'),
('Jane', 'Smith', 'jane.smith@example.com'),
('Peter', 'Jones', 'peter.jones@example.com');

CREATE TABLE customer_addresses (
    address_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    street_address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    address_type VARCHAR(50) -- e.g., 'Home', 'Mailing'
);

INSERT INTO customer_addresses (customer_id, street_address, city, state, zip_code, address_type) VALUES
(1, '123 Main St', 'Anytown', 'CA', '90210', 'Home'),
(2, '789 Oak Ave', 'Otherville', 'NY', '10001', 'Home'),
(3, '101 Pine Ln', 'Smalltown', 'TX', '75001', 'Home');


-- Create the junction table for the many-to-many relationship
CREATE TABLE customer_account_junction (
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    remote_account_id INT NOT NULL, -- This will reference account_id in bank_accounts_db.accounts
    PRIMARY KEY (customer_id, remote_account_id)
);

INSERT INTO customer_account_junction (customer_id, remote_account_id) VALUES
(1, 1), 
(1, 2), 
(2, 1), 
(2, 3), 
(3, 4);

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