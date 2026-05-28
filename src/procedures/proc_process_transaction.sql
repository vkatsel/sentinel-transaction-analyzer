CREATE OR REPLACE PROCEDURE process_transaction(p_transaction_id BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_account_id BIGINT;
    v_amount DECIMAL(15, 2);
    v_status VARCHAR(20);
    v_balance DECIMAL(15, 2);
BEGIN
    SELECT account_id, amount, status
    INTO v_account_id, v_amount, v_status
    FROM transactions
    WHERE transaction_id = p_transaction_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION  'Transaction % does not exist', p_transaction_id;
    END IF;

    IF v_status != 'PENDING' THEN
        RAISE NOTICE 'Transaction % is already processed. Current status: %', p_transaction_id, v_status;
        RETURN;
    END IF;

    SELECT balance
    INTO v_balance
    FROM accounts
    WHERE account_id = v_account_id
    FOR UPDATE;

    IF v_balance> v_amount THEN
        UPDATE transactions
        SET status = 'APPROVED'
        WHERE transaction_id = p_transaction_id;

        COMMIT;
    ELSE
        UPDATE transactions
        SET status = 'DECLINED'
        WHERE transaction_id = p_transaction_id;

        COMMIT ;
    END IF;
END;
$$;