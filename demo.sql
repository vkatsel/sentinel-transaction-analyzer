-- ==========================================
-- SENTINEL: ANALYTICAL DEMO QUERIES
-- ==========================================

-- 1. Executive Dashboard: Daily Fraud Summary
-- Demonstrates the aggregated data from the materialized view.
SELECT 
    report_date,
    total_transactions,
    total_volume,
    fraud_count,
    fraud_rate_percentage || '%' AS fraud_rate
FROM mv_daily_fraud_summary
ORDER BY report_date DESC
LIMIT 7;


-- 2. Compliance Officer View: Highest Risk Transactions Currently Pending
-- Highlights transactions that require immediate manual review.
SELECT 
    t.transaction_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    t.amount,
    t.merchant_country,
    t.risk_score
FROM transactions t
JOIN accounts a USING (account_id)
JOIN customers c USING (customer_id)
WHERE t.status = 'FLAGGED'
ORDER BY t.risk_score DESC
LIMIT 5;


-- 3. Audit Trail Extraction: JSONB Parsing Demonstration
-- Proves the capability to extract specific historical states from the JSONB audit log.
SELECT 
    audit_id,
    table_name,
    operation,
    changed_at,
    old_value->>'status' AS previous_status,
    new_value->>'status' AS new_status
FROM audit_log
WHERE table_name = 'transactions'
  AND operation = 'UPDATE'
  AND old_value->>'status' IS DISTINCT FROM new_value->>'status'
ORDER BY changed_at DESC
LIMIT 5;


-- 4. Customer Wealth Portfolio
-- Utilizes the operational view to display aggregated client capital.
SELECT 
    full_name,
    total_accounts,
    total_capital,
    active_accounts
FROM vw_customer_accounts
WHERE total_capital > 0
ORDER BY total_capital DESC
LIMIT 5;

