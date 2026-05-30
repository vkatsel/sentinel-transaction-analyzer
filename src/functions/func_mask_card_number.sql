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