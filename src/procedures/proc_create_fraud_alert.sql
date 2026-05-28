CREATE OR REPLACE PROCEDURE create_fraud_alert(
    p_transaction_id BIGINT,
    p_rule_id BIGINT,
    p_reason TEXT,
    p_risk_score INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_account_id BIGINT;
BEGIN
    INSERT INTO fraud_alerts (transaction_id, rule_id, reason, risk_score, alert_status)
    VALUES (p_transaction_id, p_rule_id, p_reason, p_risk_score, 'NEW');

    IF p_risk_score >= 85 THEN
        SELECT account_id INTO v_account_id
        FROM transactions
        WHERE transaction_id = p_transaction_id;

        CALL freeze_account(v_account_id);

        RAISE NOTICE 'CRITICAL FRAUD: Alert create and account % frozen,', v_account_id;
    ELSE
        RAISE NOTICE 'WARNING: Alert created for transaction %.', p_transaction_id;
    END IF;
END;
$$