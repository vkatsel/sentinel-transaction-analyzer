CREATE OR REPLACE VIEW vw_customer_accounts AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    c.email,
    COUNT(a.account_id) AS total_accounts,
    COALESCE(SUM(a.balance), 0.00) AS total_capital,
    COUNT(CASE WHEN a.status = 'ACTIVE' THEN 1 END ) AS active_accounts,
    COUNT(CASE WHEN a.status = 'FROZEN' THEN 1 END ) AS frozen_accounts,
    COUNT(CASE WHEN a.status = 'CLOSED' THEN 1 END ) AS closed_accounts
FROM customers c
LEFT JOIN accounts a USING (customer_id)
GROUP BY c.customer_id
