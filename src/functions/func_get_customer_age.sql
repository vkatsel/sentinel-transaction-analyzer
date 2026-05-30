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