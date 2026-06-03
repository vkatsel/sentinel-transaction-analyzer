CREATE OR REPLACE PROCEDURE onboard_customer(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_email VARCHAR,
    p_birth_date DATE,
    p_country_code VARCHAR,
    p_currency VARCHAR DEFAULT 'UAH',
    p_card_type VARCHAR DEFAULT 'DEBIT'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_customer_id BIGINT;
    v_account_id BIGINT;
    v_account_number VARCHAR;
    v_card_hash VARCHAR;
BEGIN
    INSERT INTO customers (first_name, last_name, email, birth_date, country_code)
    VALUES (p_first_name, p_last_name, p_email, p_birth_date, p_country_code)
    RETURNING customer_id INTO v_customer_id;

    v_account_number := 'UA' || floor(random() * 9000000000000000 + 1000000000000000)::TEXT;

    INSERT INTO accounts (customer_id, account_number, currency, balance, status)
    VALUES (v_customer_id, v_account_number, p_currency, 0.0, 'ACTIVE')
    RETURNING account_id INTO v_account_id;

    v_card_hash := md5(random()::TEXT || clock_timestamp()::TEXT);

    INSERT INTO cards (account_id, card_number_hash, card_type, status, expiration_date)
    VALUES (v_account_id, v_card_hash, p_card_type, 'ACTIVE', CURRENT_DATE + INTERVAL '3 years');

    RAISE NOTICE 'Successfully onboarded customer % % (ID: %). Account: %, Card Type: %', 
                 p_first_name, p_last_name, v_customer_id, v_account_number, p_card_type;
END;
$$;
