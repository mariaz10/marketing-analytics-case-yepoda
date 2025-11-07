-- 01_schema_setup.sql
-- Task 1: Load CSVs into DuckDB tables

PRAGMA threads = 4;

-- Load CSVs
CREATE OR REPLACE TABLE marketing_spend AS
SELECT * FROM read_csv_auto('data/marketing_spend.csv', DATEFORMAT='%Y-%m-%d', header = TRUE);

CREATE OR REPLACE TABLE revenue AS
SELECT * FROM read_csv_auto('data/revenue.csv', DATEFORMAT='%Y-%m-%d', header = TRUE);

CREATE OR REPLACE TABLE external_factors AS
SELECT * FROM read_csv_auto('data/external_factors.csv', DATEFORMAT='%Y-%m-%d', header = TRUE);

-- Ensure DATE types
UPDATE marketing_spend    SET date = CAST(date AS DATE);
UPDATE revenue            SET date = CAST(date AS DATE);
UPDATE external_factors   SET date = CAST(date AS DATE);

-- Long view with correct column names
DROP VIEW IF EXISTS marketing_spend_long;

CREATE VIEW marketing_spend_long AS
SELECT date, 'affiliate_spend'     AS channel, affiliate_spend     AS spend FROM marketing_spend
UNION ALL
SELECT date, 'display_spend'       AS channel, display_spend       AS spend FROM marketing_spend
UNION ALL
SELECT date, 'email_spend'         AS channel, email_spend         AS spend FROM marketing_spend
UNION ALL
SELECT date, 'paid_search_spend'   AS channel, paid_search_spend   AS spend FROM marketing_spend
UNION ALL
SELECT date, 'paid_social_spend'   AS channel, paid_social_spend   AS spend FROM marketing_spend
UNION ALL
SELECT date, 'tv_spend'            AS channel, tv_spend            AS spend FROM marketing_spend;
