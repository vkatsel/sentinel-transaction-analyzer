CREATE OR REPLACE PROCEDURE add_account(
    p_customer_id BIGINT,
    p_account_number VARCHAR,
    p_currency VARCHAR,
    p_initial_balance DECIMAL DEFAULT 0.0
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = p_customer_id) THEN
        RAISE EXCEPTION 'Customer with ID % does not exist.', p_customer_id;
    END IF;

    IF p_currency NOT IN ('UAH', 'USD', 'EUR') THEN
        RAISE EXCEPTION 'Currency % is not supported. Use UAH, USD, or EUR.', p_currency;
    END IF;

    IF EXISTS (SELECT 1 FROM accounts WHERE account_number = p_account_number) THEN
        RAISE EXCEPTION 'Account number % already exists.', p_account_number;
    END IF;

    INSERT INTO accounts (customer_id, account_number, currency, balance, status)
    VALUES (p_customer_id, p_account_number, p_currency, p_initial_balance, 'ACTIVE');

    RAISE NOTICE 'Account % (Currency: %) successfully created for Customer % with initial balance %', 
        p_account_number, p_currency, p_customer_id, p_initial_balance;
END;
$$;
