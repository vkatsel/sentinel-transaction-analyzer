CREATE OR REPLACE FUNCTION process_transaction_lifecycle()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO transaction_status_history (transaction_id, old_status, new_status, changed_by)
        VALUES (NEW.transaction_id, OLD.status, NEW.status, CURRENT_USER);
    END IF;

    IF NEW.status = 'APPROVED' AND OLD.status IS DISTINCT FROM 'APPROVED' THEN
        UPDATE accounts
        SET balance = balance - NEW.amount
        WHERE account_id = NEW.account_id;

        RAISE NOTICE 'Triggered balance update for account %: -%', NEW.account_id, NEW.amount;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_transaction_lifecycle
AFTER UPDATE ON transactions
FOR EACH ROW
EXECUTE FUNCTION process_transaction_lifecycle();