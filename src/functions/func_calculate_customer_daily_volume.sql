CREATE OR REPLACE FUNCTION calculate_customer_daily_volume(p_customer_id BIGINT, p_target_date DATE)
RETURNS DECIMAL(15, 2) AS $$
DECLARE
    v_customer_sum DECIMAL(15, 2);
BEGIN
    SELECT COALESCE(SUM(amount), 0.00)
    INTO v_customer_sum
    FROM transactions t
    JOIN accounts a USING (account_id)
    WHERE customer_id = p_customer_id AND transaction_at::DATE = p_target_date;

    RETURN v_customer_sum;
END;
$$ LANGUAGE plpgsql;