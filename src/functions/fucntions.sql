CREATE OR REPLACE FUNCTION get_customer_age(p_customer_id BIGINT)
RETURNS INT AS $$
DECLARE
    v_age INT;
BEGIN
    SELECT EXTRACT(YEAR FROM age(CURRENT_DATE, birth_date)) INTO v_age
    FROM customers
    WHERE customer_id = p_customer_id;

    RETURN v_age;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mask_card_number(p_card_number VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    IF length(p_card_number) >=16 THEN
        RETURN left(p_card_number, 4) || '********' || right(p_card_number, 4);
    ELSE
        RETURN 'INVALID_FORMAT';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_high_risk_country(p_country_code VARCHAR(3))
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS(
        SELECT 1
        FROM high_risk_countries
        WHERE country_code = p_country_code
    );
END;
$$ LANGUAGE plpgsql;

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



