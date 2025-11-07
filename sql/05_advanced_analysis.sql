-- 05_advanced_analysis.sql
-- Task 5: Advanced Analysis
-- Includes:
--   (a) Correlation between channel spend and revenue
--   (b) Revenue lift from holidays, promotions, and weekends
--   (c) Seasonality lift by month
--   (d) Incrementality: zero vs spend days
--   (e) Incrementality by spend quartiles
--   (f) Cohort efficiency over time (ROAS by month)

-- =========================================================
-- (a) correlation_spend_revenue.csv
-- Correlation between each channel's spend and total revenue.
-- =========================================================
DROP TABLE IF EXISTS correlation_spend_revenue;
CREATE TABLE correlation_spend_revenue AS
SELECT
  channel,
  corr(spend, revenue) AS corr_spend_revenue
FROM (
  SELECT 
    m.date,
    m.channel,
    SUM(m.spend) AS spend,
    r.revenue
  FROM marketing_spend_long m
  JOIN revenue r ON m.date = r.date
  GROUP BY 1,2,4
) t
GROUP BY channel
ORDER BY corr_spend_revenue DESC;

-- =========================================================
-- (b) revenue_lift_external.csv
-- Impact of holidays, promotions, and weekends on revenue.
-- =========================================================
DROP TABLE IF EXISTS revenue_lift_external;
CREATE TABLE revenue_lift_external AS
WITH joined AS (
  SELECT
    CAST(r.date AS DATE)                       AS date,
    CAST(r.revenue AS DOUBLE)                  AS revenue,
    COALESCE(CAST(e.is_holiday AS INTEGER), 0)       AS is_holiday,
    COALESCE(CAST(e.promotion_active AS INTEGER), 0) AS is_promo,
    CASE WHEN EXTRACT(ISODOW FROM r.date) IN (6,7) THEN 1 ELSE 0 END AS is_weekend
  FROM revenue r
  JOIN external_factors e
    ON CAST(e.date AS DATE) = CAST(r.date AS DATE)
),
base AS (
  SELECT AVG(revenue) AS base_rev
  FROM joined
)
SELECT 'holiday' AS factor,
       AVG(CASE WHEN is_holiday = 1 THEN revenue END) / (SELECT base_rev FROM base) - 1 AS revenue_lift
FROM joined
UNION ALL
SELECT 'promo',
       AVG(CASE WHEN is_promo = 1 THEN revenue END) / (SELECT base_rev FROM base) - 1
FROM joined
UNION ALL
SELECT 'weekend',
       AVG(CASE WHEN is_weekend = 1 THEN revenue END) / (SELECT base_rev FROM base) - 1
FROM joined
ORDER BY factor;

-- =========================================================
-- (c) seasonality_lift.csv
-- Monthly revenue vs overall average (seasonality effect).
-- =========================================================
DROP TABLE IF EXISTS seasonality_lift;
CREATE TABLE seasonality_lift AS
WITH joined AS (
  SELECT
    CAST(r.date AS DATE)       AS date,
    CAST(r.revenue AS DOUBLE)  AS revenue
  FROM revenue r
  JOIN external_factors e
    ON CAST(e.date AS DATE) = CAST(r.date AS DATE)
),
monthly AS (
  SELECT 
    EXTRACT(MONTH FROM date) AS month,
    AVG(revenue)             AS avg_rev
  FROM joined
  GROUP BY 1
),
annual AS (
  SELECT AVG(revenue) AS annual_avg
  FROM joined
)
SELECT
  month,
  avg_rev,
  avg_rev / (SELECT annual_avg FROM annual) - 1 AS lift_vs_annual
FROM monthly
ORDER BY month;

-- =========================================================
-- (d) incrementality_zero_vs_spend.csv
-- Compare days with spend vs no-spend for each channel.
-- =========================================================
DROP TABLE IF EXISTS incrementality_zero_vs_spend;
CREATE TABLE incrementality_zero_vs_spend AS
WITH base AS (
  SELECT 
    m.date,
    m.channel,
    SUM(m.spend) AS spend,
    r.revenue
  FROM marketing_spend_long m
  JOIN revenue r ON m.date = r.date
  GROUP BY 1,2,4
)
SELECT
  channel,
  AVG(CASE WHEN spend = 0 THEN revenue END) AS avg_revenue_zero_spend,
  AVG(CASE WHEN spend > 0 THEN revenue END) AS avg_revenue_has_spend,
  (AVG(CASE WHEN spend > 0 THEN revenue END)
   - AVG(CASE WHEN spend = 0 THEN revenue END)) AS abs_lift,
  CASE
    WHEN AVG(CASE WHEN spend = 0 THEN revenue END) IS NULL
         OR AVG(CASE WHEN spend = 0 THEN revenue END) = 0
    THEN NULL
    ELSE (AVG(CASE WHEN spend > 0 THEN revenue END)
          / AVG(CASE WHEN spend = 0 THEN revenue END) - 1)
  END AS rel_lift
FROM base
GROUP BY channel
ORDER BY channel;

-- =========================================================
-- (e) incrementality_quartiles.csv
-- Marginal returns: average revenue and spend by quartile.
-- =========================================================
DROP TABLE IF EXISTS incrementality_quartiles;
CREATE TABLE incrementality_quartiles AS
WITH base AS (
  SELECT 
    m.date,
    m.channel,
    SUM(m.spend) AS spend,
    r.revenue
  FROM marketing_spend_long m
  JOIN revenue r ON m.date = r.date
  GROUP BY 1,2,4
),
q AS (
  SELECT
    channel,
    NTILE(4) OVER (PARTITION BY channel ORDER BY spend) AS spend_quartile,
    spend,
    revenue
  FROM base
)
SELECT
  channel,
  spend_quartile,
  AVG(spend)   AS avg_spend,
  AVG(revenue) AS avg_revenue,
  AVG(revenue) / NULLIF(AVG(spend), 0) AS avg_revenue_per_dollar
FROM q
GROUP BY 1,2
ORDER BY channel, spend_quartile;

-- =========================================================
-- (f) cohort_efficiency.csv
-- ROAS per channel by month (marketing efficiency over time).
-- =========================================================
DROP TABLE IF EXISTS cohort_efficiency;
CREATE TABLE cohort_efficiency AS
WITH spend_rev AS (
  SELECT
    date_trunc('month', m.date) AS month,
    m.channel,
    SUM(m.spend)   AS total_spend,
    SUM(r.revenue) AS total_revenue
  FROM marketing_spend_long m
  JOIN revenue r ON m.date = r.date
  GROUP BY 1,2
)
SELECT
  month,
  channel,
  total_spend,
  total_revenue,
  CASE WHEN total_spend > 0 THEN total_revenue / total_spend ELSE NULL END AS roas
FROM spend_rev
ORDER BY month, channel;

-- =========================================================
-- Preview tables (optional sanity checks)
-- Uncomment the lines below to preview results after running
-- =========================================================
-- SELECT 'A_correlation_spend_revenue'    AS table_name, * FROM correlation_spend_revenue;
-- SELECT 'B_revenue_lift_external'        AS table_name, * FROM revenue_lift_external;
-- SELECT 'C_seasonality_lift'             AS table_name, * FROM seasonality_lift;
-- SELECT 'D_incrementality_zero_vs_spend' AS table_name, * FROM incrementality_zero_vs_spend;
-- SELECT 'E_incrementality_quartiles'     AS table_name, * FROM incrementality_quartiles;
-- SELECT 'F_cohort_efficiency'            AS table_name, * FROM cohort_efficiency;
