CREATE MATERIALIZED VIEW mv_daily_fraud_summary AS
SELECT
        transaction_at::DATE AS report_date,
        count(transaction_id) AS total_transactions,
        COALESCE(SUM(amount), 0.00) AS total_volume,

        COUNT(CASE WHEN status = 'FLAGGED' OR  status = 'DECLINED' THEN 1 END) AS fraud_count,
        COALESCE(SUM(CASE WHEN status = 'FLAGGED' OR status = 'DECLINED' THEN amount END), 0.00) AS fraud_volume,

        ROUND(COUNT(CASE WHEN status = 'FLAGGED' OR status = 'DECLINED' THEN 1 END)::NUMERIC /
            NULLIF(COUNT(transaction_id), 0) * 100, 2) AS fraud_rate_percentage
FROM transactions
GROUP BY transaction_at::DATE
WITH DATA;

REFRESH MATERIALIZED VIEW mv_daily_fraud_summary;