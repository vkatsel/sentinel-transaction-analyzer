CREATE OR REPLACE PROCEDURE add_customer(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_email VARCHAR,
    p_birth_date DATE,
    p_country_code VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM customers WHERE email = p_email) THEN
        RAISE EXCEPTION 'Customer with email % already exists.', p_email;
    END IF;

    INSERT INTO customers (first_name, last_name, email, birth_date, country_code)
    VALUES (p_first_name, p_last_name, p_email, p_birth_date, p_country_code);
    
    RAISE NOTICE 'Customer % % (%) has been successfully added.', p_first_name, p_last_name, p_email;
END;
$$;
