CREATE OR REPLACE FUNCTION calculate_transaction_risk_score(p_transaction_id BIGINT)
RETURNS INT AS $$
DECLARE
    v_transaction_risk INT := 0;
    v_transaction_sum DECIMAL(15, 2);
    v_customer_daily_volume DECIMAL(15, 2);
    v_merchant_country VARCHAR(3);
    v_customer_id BIGINT;
    v_transaction_date DATE;
BEGIN
    SELECT a.customer_id, t.amount, t.merchant_country, t.transaction_at::DATE
    INTO v_customer_id, v_transaction_sum, v_merchant_country, v_transaction_date
    FROM transactions t
    JOIN accounts a USING (account_id)
    WHERE t.transaction_id = p_transaction_id;

    IF v_customer_id IS NULL THEN
        RETURN 0;
    END IF;

    IF is_high_risk_country(v_merchant_country) THEN
        v_transaction_risk := v_transaction_risk + 40;
    END IF;

    IF v_transaction_sum > 10000.00 THEN
        v_transaction_risk := v_transaction_risk + 30;
    END IF;

    v_customer_daily_volume := calculate_customer_daily_volume(v_customer_id, v_transaction_date);
    IF v_customer_daily_volume > 50000.00 THEN
        v_transaction_risk := v_transaction_risk+ 30;
    END IF;

    RETURN LEAST(v_transaction_risk, 100);
END;
$$ LANGUAGE plpgsql;