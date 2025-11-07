-- 06_budget_optimization.sql
-- Task 6: Budget Optimization Insights
-- Includes:
--   (a) Spending patterns (consistency and variability)
--   (b) Efficiency curves (spend deciles vs average ROAS)
--   (c) Recommended budget allocation (expected impact)

-- =========================================================
-- (a) spending_patterns.csv
-- Channel-level spend consistency (avg, std, coeff_var)
-- =========================================================
DROP TABLE IF EXISTS A_spending_patterns;
CREATE TABLE A_spending_patterns AS
WITH daily_spend AS (
  SELECT
    channel,
    date,
    SUM(spend) AS spend
  FROM marketing_spend_long
  GROUP BY 1,2
)
SELECT
  channel,
  AVG(spend) AS avg_daily_spend,
  STDDEV(spend) AS std_spend,
  STDDEV(spend) / NULLIF(AVG(spend), 0) AS coeff_var,
  COUNT(*) AS days
FROM daily_spend
GROUP BY channel
ORDER BY coeff_var ASC;

-- =========================================================
-- (b) efficiency_curves.csv
-- Break spend into deciles and compute average ROAS per level.
-- =========================================================
DROP TABLE IF EXISTS B_efficiency_curves;
CREATE TABLE B_efficiency_curves AS
WITH base AS (
  SELECT
    m.date,
    m.channel,
    SUM(m.spend) AS spend,
    r.revenue
  FROM marketing_spend_long m
  JOIN revenue r USING(date)
  GROUP BY 1,2,4
),
dec AS (
  SELECT
    channel,
    NTILE(10) OVER (PARTITION BY channel ORDER BY spend) AS spend_decile,
    spend,
    revenue
  FROM base
)
SELECT
  channel,
  spend_decile,
  AVG(spend)   AS avg_spend,
  AVG(revenue) AS avg_revenue,
  CASE WHEN AVG(spend) > 0 THEN AVG(revenue) / AVG(spend) END AS avg_roas
FROM dec
GROUP BY channel, spend_decile
ORDER BY channel, spend_decile;

-- =========================================================
-- (c) recommended_allocation.csv
-- Reallocate total budget proportionally to observed ROAS.
-- =========================================================
DROP TABLE IF EXISTS C_recommended_allocation;
CREATE TABLE C_recommended_allocation AS
WITH roas AS (
  SELECT
    m.channel,
    SUM(m.spend) AS total_spend,
    SUM(r.revenue) AS total_revenue,
    SUM(r.revenue) / NULLIF(SUM(m.spend), 0) AS roas
  FROM marketing_spend_long m
  JOIN revenue r USING(date)
  GROUP BY m.channel
),
budget AS (SELECT SUM(total_spend) AS total_budget FROM roas)
SELECT
  r.channel,
  r.total_spend AS current_spend,
  ROUND((r.roas / SUM(r.roas) OVER()) * (SELECT total_budget FROM budget), 2) AS recommended_spend,
  ROUND((r.roas / SUM(r.roas) OVER()) * 100, 2) AS recommended_pct,
  ROUND((r.roas / SUM(r.roas) OVER()) * (SELECT total_budget FROM budget) - r.total_spend, 2) AS delta_spend,
  ROUND(r.roas * ((r.roas / SUM(r.roas) OVER()) * (SELECT total_budget FROM budget)), 2) AS expected_revenue
FROM roas r
ORDER BY recommended_spend DESC;

-- =========================================================
-- Preview tables (optional sanity checks)
-- =========================================================
-- SELECT * FROM A_spending_patterns;
-- SELECT * FROM B_efficiency_curves;
-- SELECT * FROM C_recommended_allocation;
