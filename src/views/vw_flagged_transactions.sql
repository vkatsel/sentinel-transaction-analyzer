CREATE OR REPLACE VIEW vw_flagged_transactions AS
    SELECT
        t.transaction_id,
        t.transaction_at,
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_full_name,
        c.email,
        t.amount,
        t.merchant_country,
        t.risk_score,
        t.status AS transaction_status,
        fa.reason AS fraud_alert_reason,
        fa.alert_status
    FROM transactions t
    JOIN accounts a USING (account_id)
    JOIN customers c USING (customer_id)
    LEFT JOIN fraud_alerts fa USING (transaction_id)
    WHERE t.status = 'FLAGGED' OR t.status = 'DECLINED' OR t.risk_score > 70;