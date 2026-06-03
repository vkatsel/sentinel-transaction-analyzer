CREATE OR REPLACE PROCEDURE add_transaction(
    p_account_id BIGINT,
    p_amount DECIMAL,
    p_currency VARCHAR,
    p_merchant_category VARCHAR,
    p_merchant_country VARCHAR,
    p_card_id BIGINT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_transaction_id BIGINT;
BEGIN
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Transaction amount must be strictly positive.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM accounts WHERE account_id = p_account_id) THEN
        RAISE EXCEPTION 'Account with ID % does not exist.', p_account_id;
    END IF;
    
    IF p_currency NOT IN ('UAH', 'USD', 'EUR') THEN
        RAISE EXCEPTION 'Currency % is not supported. Use UAH, USD, or EUR.', p_currency;
    END IF;

    INSERT INTO transactions (
        account_id, card_id, amount, currency, 
        merchant_category, merchant_country, status, transaction_at
    )
    VALUES (
        p_account_id, p_card_id, p_amount, p_currency, 
        p_merchant_category, p_merchant_country, 'PENDING', CURRENT_TIMESTAMP
    )
    RETURNING transaction_id INTO v_transaction_id;

    RAISE NOTICE 'Transaction % created with PENDING status for Account %.', v_transaction_id, p_account_id;
END;
$$;
