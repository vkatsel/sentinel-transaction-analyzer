CREATE OR REPLACE VIEW vw_recent_transactions AS
SELECT
    t.transaction_id,
    t.transaction_at,
    c.first_name || ' ' || c.last_name AS customer_name,
    ca.card_type,
    t.merchant_country,
    t.amount,
    t.status AS transaction_status,
    t.risk_score
FROM transactions t
JOIN accounts a USING (account_id)
JOIN customers c USING (customer_id)
JOIN cards ca USING (account_id)
WHERE t.transaction_at >= CURRENT_DATE - INTERVAL '7 days'