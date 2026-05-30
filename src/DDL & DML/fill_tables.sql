-- FILL HELPER TABLES
INSERT INTO fraud_rules (rule_name, rule_type, threshold_value, is_active) VALUES
    ('High Risk Country Rule', 'LOCATION', 40, true),
    ('Abnormal Volume Rule', 'VOLUME', 30, true),
    ('Daily Velocity Limit', 'VELOCITY', 30, true);


INSERT INTO high_risk_countries (country_code, country_name) VALUES
    ('PRK', 'North Korea'),
    ('IRN', 'Iran'),
    ('RUS', 'Russian Federation');

-- FILL CUSTOMERS AND ACCOUNTS
INSERT INTO customers (first_name, last_name, email, birth_date, country_code, is_active)
SELECT
    'Customer_' || id,
    'Gen_' || id,
    'user_' || id || '@kse.test.com',
    CURRENT_DATE - (random() * 15000 + 6500)::INT,
    (ARRAY['UKR', 'USA', 'POL', 'GBR'])[floor(random()*4)+1],
    true
FROM generate_series(1, 100) AS id;


INSERT INTO accounts (customer_id, account_number, currency, balance, status)
SELECT
    id,
    'UA' || floor(random() * 9000000000000000 + 1000000000000000)::TEXT, -- імітація IBAN
    (ARRAY['UAH', 'USD', 'EUR'])[floor(random()*3)+1],
    (random() * 100000)::NUMERIC(15,2),
    'ACTIVE'
FROM generate_series(1, 100) AS id;

-- CREATE CARDS AND TRANSACTIONS
INSERT INTO cards (account_id, card_number_hash, card_type, status, expiration_date)
SELECT
    account_id,
    md5(random()::TEXT),
    (ARRAY['DEBIT', 'CREDIT', 'PREPAID'])[floor(random()*2)+1],
    'ACTIVE',
    CURRENT_DATE + (random() * 1000 + 365)::INT
FROM accounts;


WITH card_acc_mapping AS (
    SELECT c.card_id, c.account_id
    FROM cards c
)
INSERT INTO transactions (
    account_id, card_id, amount, currency,
    merchant_category, merchant_country, status, transaction_at
)
SELECT
    m.account_id,
    m.card_id,
    (random() * 15000)::NUMERIC(15,2),
    'UAH',
    (ARRAY['RETAIL', 'TRAVEL', 'GAMBLING', 'GROCERY'])[floor(random()*4)+1],
    (ARRAY['UKR', 'USA', 'POL', 'GBR', 'IRN', 'PRK'])[floor(random()*6)+1],
    'PENDING',
    CURRENT_TIMESTAMP - (random() * interval '30 days')
FROM generate_series(1, 1000)
JOIN LATERAL (
    SELECT card_id, account_id
    FROM card_acc_mapping
    ORDER BY random()
    LIMIT 1
) m ON true;

COMMIT;

SELECT * FROM transactions