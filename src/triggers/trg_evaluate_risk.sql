CREATE OR REPLACE FUNCTION evaluate_transaction_risk()
RETURNS TRIGGER AS $$
DECLARE
    v_calculated_risk INT;
BEGIN
    v_calculated_risk := calculate_transaction_risk_score(NEW.transaction_id);

    UPDATE transactions
    SET risk_score = v_calculated_risk
    WHERE transaction_id = NEW.transaction_id;

    IF v_calculated_risk > 70 THEN
        UPDATE transactions
        SET status = 'FLAGGED'
        WHERE transaction_id = NEW.transaction_id;

        INSERT INTO fraud_alerts (transaction_id, rule_id, reason, risk_score)
        VALUES (NEW.transaction_id, 1, 'Automated Risk Evaluation Threshold Exceeded', v_calculated_risk);

        RAISE NOTICE 'Fraud alert auto-generated for transaction % with score %', NEW.transaction_id, v_calculated_risk;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_evaluate_risk
AFTER INSERT ON transactions
FOR EACH ROW
EXECUTE FUNCTION evaluate_transaction_risk();


