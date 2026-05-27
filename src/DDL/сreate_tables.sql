CREATE TABLE customers (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL ,
    last_name VARCHAR(100) NOT NULL ,
    email VARCHAR(255) UNIQUE NOT NULL ,
    birth_date DATE NOT NULL ,
    country_code VARCHAR(3) NOT NULL ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE fraud_rules (
    rule_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rule_name VARCHAR UNIQUE NOT NULL,
    rule_type VARCHAR NOT NULL CHECK (rule_type IN ('VELOCITY', 'LOCATION', 'VOLUME', 'BLACKLIST')), ---Maybe some validation here?---
    threshold_value INT NOT NULL ,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE audit_log (
    audit_id BIGINT GENERATED ALWAYS AS IDENTITY  PRIMARY KEY,
    customer_id BIGINT REFERENCES  customers ON DELETE SET NULL,
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    old_value JSONB,
    new_value JSONB,
    changed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    account_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
    customer_id BIGINT REFERENCES customers ON DELETE RESTRICT,
    account_number VARCHAR(255) UNIQUE NOT NULL ,
    currency VARCHAR(3)  NOT NULL CHECK (currency IN ('UAH', 'USD', 'EUR')) ,
    balance DECIMAL(15, 2) DEFAULT 0.0 CHECK ( balance >= 0 ),
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),
    opened_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cards (
    card_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES accounts(account_id) ON DELETE CASCADE,
    card_number_hash VARCHAR(255) UNIQUE NOT NULL,
    card_type VARCHAR(20) NOT NULL CHECK (card_type IN ('DEBIT', 'CREDIT', 'PREPAID')),
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'BLOCKED', 'EXPIRED')),
    expiration_date DATE NOT NULL
);

CREATE TABLE transactions (
    transaction_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES accounts(account_id) ON DELETE RESTRICT,
    card_id BIGINT REFERENCES cards(card_id) ON DELETE SET NULL,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) NOT NULL CHECK (currency IN ('UAH', 'USD', 'EUR')),
    merchant_category VARCHAR(100),
    merchant_country VARCHAR(3),
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'APPROVED', 'DECLINED', 'FLAGGED')),
    risk_score INT DEFAULT 0 CHECK (risk_score >= 0 AND risk_score <= 100),
    transaction_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transaction_status_history (
    history_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_id BIGINT NOT NULL REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    changed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50) DEFAULT 'SYSTEM'
);

CREATE TABLE fraud_alerts (
    alert_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_id BIGINT NOT NULL REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    rule_id BIGINT NOT NULL REFERENCES fraud_rules(rule_id) ON DELETE RESTRICT,
    reason TEXT NOT NULL,
    risk_score INT NOT NULL,
    alert_status VARCHAR(20) DEFAULT 'NEW' CHECK (alert_status IN ('NEW', 'INVESTIGATING', 'RESOLVED', 'FALSE_POSITIVE')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE high_risk_countries (
    country_code VARCHAR(3) PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    added_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);



