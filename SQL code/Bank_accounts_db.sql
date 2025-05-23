CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    account_number VARCHAR(50) UNIQUE NOT NULL,
    account_type VARCHAR(50) NOT NULL, -- e.g., 'Checking', 'Savings', 'Credit Card'
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    opened_date DATE NOT NULL DEFAULT CURRENT_DATE
);

INSERT INTO accounts (account_number, account_type, balance, opened_date) VALUES
('1234567890', 'Checking', 1500.75, '2022-01-15'),
('0987654321', 'Savings', 5000.00, '2021-05-20'),
('1122334455', 'Credit Card', -250.00, '2023-03-10'),
('5544332211', 'Checking', 300.50, '2024-02-01');

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INT NOT NULL REFERENCES accounts(account_id),
    transaction_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(15, 2) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL, -- e.g., 'Deposit', 'Withdrawal', 'Transfer'
    description TEXT
);

INSERT INTO transactions (account_id, amount, transaction_type, description) VALUES
(1, 100.00, 'Deposit', 'Payroll'),
(1, -50.00, 'Withdrawal', 'Groceries'),
(2, 500.00, 'Deposit', 'Transfer from checking'),
(3, -25.00, 'Purchase', 'Online shopping');

