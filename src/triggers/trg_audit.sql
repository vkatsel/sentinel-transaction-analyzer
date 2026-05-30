CREATE OR REPLACE FUNCTION audit_table_changes()
RETURNS TRIGGER AS $$
DECLARE
    v_old_data JSONB := NULL;
    v_new_data JSONB := NULL;
    v_extracted_customer_id BIGINT := NULL;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_new_data := to_jsonb(NEW);
        v_extracted_customer_id := (v_new_data ->> 'customer_id')::BIGINT;
    ELSIF TG_OP = 'UPDATE' THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := to_jsonb(NEW);
        v_extracted_customer_id := (v_new_data->>'customer_id')::BIGINT;
    ELSIF TG_OP = 'DELETE' THEN
        v_old_data := to_jsonb(OLD);
        v_extracted_customer_id := (v_old_data->>'customer_id')::BIGINT;
    END IF;

    INSERT INTO audit_log (table_name, operation, old_value, new_value)
    VALUES (TG_TABLE_NAME, TG_OP, v_old_data, v_new_data);

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_customers
AFTER INSERT OR UPDATE OR DELETE ON customers
FOR EACH ROW
EXECUTE FUNCTION audit_table_changes();

CREATE TRIGGER trg_audit_accounts
AFTER INSERT OR UPDATE OR DELETE ON accounts
FOR EACH ROW
EXECUTE FUNCTION audit_table_changes();