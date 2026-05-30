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