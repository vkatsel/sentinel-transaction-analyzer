# Sentinel: Banking Fraud Monitoring System

## 📌 Project Overview

**Sentinel** is a robust banking transaction monitoring and fraud detection system built on top of a **PostgreSQL** relational database. The system simulates a high-throughput transaction environment while enforcing strict financial controls, real-time risk evaluation, and automated responses to suspicious activities.

The project heavily leverages advanced PostgreSQL features: triggers, stored procedures, functions, materialized views, and JSONB capabilities to create a universal audit log.

---

## 🏗 Database Architecture (Based on ERD)

The database is designed to ensure data integrity and fast execution of analytical queries. The core entities can be divided into three logical blocks:

### 1. Core Banking System

- **`customers`**: Client information (Name, contacts, activity status).
- **`accounts`**: Bank accounts of the customers. Each customer can have multiple accounts in different currencies.
- **`cards`**: Payment cards linked to accounts. For security reasons (PCI-DSS compliance), only the hash of the card number is stored.
- **`transactions`**: All transactions within the system. It contains the amount, currency, merchant country, status, and a pre-calculated `risk_score`.

### 2. Fraud Detection Module

- **`fraud_rules`**: Security rule configurations (e.g., amount limits, prohibited transaction types).
- **`high_risk_countries`**: A directory of high-risk or sanctioned countries.
- **`fraud_alerts`**: Incident log. If a transaction receives a high risk score, the system automatically creates an alert (a record in this table).
- **`transaction_status_history`**: A table to track the lifecycle of a transaction (e.g., transition from `PENDING` to `FLAGGED` or `COMPLETED`).

### 3. Audit & Logging

- **`audit_log`**: A universal table for tracking all database modifications (INSERT, UPDATE, DELETE). Changes are recorded in `JSONB` format, which allows for a polymorphic log for any table without altering the schema.

### 4. Analytical Views

- **`vw_customer_accounts`**: Aggregated customer information (total number of accounts, total capital, active/frozen accounts).
- **`vw_recent_transactions`**: A user-friendly view of recent transactions with masked card details and calculated risk scores.
- **`vw_flagged_transactions`**: Detailed information on blocked/suspicious transactions for Compliance Officers.
- **`mv_daily_fraud_summary`**: A **Materialized View** for generating daily fraud reports (total volume, number of incidents, fraud percentage).

---

## ⚙️ Key Business Logic & Fraud Detection Mechanism

1. **Real-time Risk Evaluation (Triggers)**:
   When a new transaction is inserted, a trigger automatically fires to analyze the payment parameters:
   - If the merchant's country is listed in the `high_risk_countries` table, the `risk_score` increases.
   - If the transaction amount exceeds the allowed limits, additional risk points are added.
2. **Automated Blocking**:
   If the total `risk_score` exceeds a critical threshold, the system preemptively changes the transaction status to `FLAGGED` and generates a record in `fraud_alerts` for further manual review by personnel.
3. **Universal Audit**:
   Thanks to the `trg_audit` trigger, any modifications to critical tables are automatically recorded. The `JSONB` format allows for flexible historical data extraction (see the example in `demo.sql`).

---

## 📁 Project Structure

The project is organized into the following directories:

```text
banking_fraud_monitoring_system/
├── src/
│   ├── DDL & DML/         # Scripts for creating tables (`сreate_tables.sql`) and populating data (fill_tables.sql)
│   ├── functions/         # SQL functions for risk calculation and aggregations
│   ├── procedures/        # Stored procedures (e.g., for processing transactions)
│   ├── triggers/          # Triggers (trg_audit.sql, trg_evaluate_risk.sql, trg_transaction_lifecycle.sql)
│   └── views/             # Creation of standard and materialized views
├── data/                  # Data for import/export (if any)
├── demo.sql               # Demonstration script with analytical queries for testing the system
└── README.md              # Project documentation
```

---

## 🚀 Setup Instructions

To properly deploy the Sentinel database locally, you must execute the SQL scripts in a strict sequence to maintain referential integrity:

1. **Schema Initialization:** Execute the table creation script `src/DDL & DML/сreate_tables.sql`.
2. **Functions & Procedures:** Apply the scripts from the `src/functions/` and `src/procedures/` folders.
3. **Trigger Setup:** Execute the scripts from the `src/triggers/` folder to enable the risk evaluation and audit system.
4. **Create Views:** Execute the scripts from the `src/views/` folder to build analytical dashboards.
5. **Data Seeding:** Run the `src/DDL & DML/fill_tables.sql` script to populate the database with test customers, rules, and generate transactions.

### 📊 Demonstration

After deploying the database, open and execute the queries from the **`demo.sql`** script. It contains ready-to-use queries for:

- Viewing daily fraud statistics.
- Displaying the highest-risk transactions (for the Compliance Officer).
- Demonstrating the parsing of `JSONB` audit logs.
- Analyzing the customer account portfolio.
