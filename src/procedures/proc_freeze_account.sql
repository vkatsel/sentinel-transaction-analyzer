CREATE OR REPLACE PROCEDURE freeze_account(p_account_id BIGINT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE accounts
    SET status = 'FROZEN'
    WHERE p_account_id = account_id AND status = 'ACTIVE';

    IF NOT FOUND THEN
        RAISE NOTICE 'Account % is not found.', p_account_id;
        RETURN ;
    END IF;

    UPDATE transactions
    SET status = 'DECLINED'
    WHERE status = 'PENDING' and account_id = p_account_id;

    RAISE NOTICE 'Account % is successfully frozen. Pending transactions are set declined.', p_account_id;
END
$$;