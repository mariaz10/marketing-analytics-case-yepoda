-- 03_exploratory_analysis.sql
-- Task 3: Exploratory Data Analysis

-- (a) Summary statistics — spend per channel
SELECT
  channel,
  COUNT(*)                      AS n_days,
  SUM(spend)                    AS total_spend,
  AVG(spend)                    AS avg_spend,
  MEDIAN(spend)                 AS median_spend,
  STDDEV_POP(spend)             AS std_spend,
  MIN(spend)                    AS min_spend,
  MAX(spend)                    AS max_spend
FROM marketing_spend_long
GROUP BY channel
ORDER BY channel;

-- (b) Summary statistics — revenue
SELECT
  COUNT(*)                  AS n_days,
  SUM(revenue)              AS total_revenue,
  AVG(revenue)              AS avg_revenue,
  MEDIAN(revenue)           AS median_revenue,
  STDDEV_POP(revenue)       AS std_revenue,
  MIN(revenue)              AS min_revenue,
  MAX(revenue)              AS max_revenue
FROM revenue;

-- (c) Monthly trends — total spend and revenue per month
WITH spend_daily AS (
  SELECT date, SUM(spend) AS total_spend
  FROM marketing_spend_long
  GROUP BY date
)
SELECT
  date_trunc('month', r.date) AS month,
  SUM(r.revenue)              AS revenue,
  SUM(s.total_spend)          AS spend
FROM revenue r
JOIN spend_daily s ON s.date = r.date
GROUP BY 1
ORDER BY 1;

-- (d) Day-of-week patterns — average spend and revenue
WITH spend_daily AS (
  SELECT date, SUM(spend) AS total_spend
  FROM marketing_spend_long
  GROUP BY date
)
SELECT
  EXTRACT(ISODOW FROM r.date) AS dow_iso,
  AVG(r.revenue)              AS avg_revenue,
  AVG(s.total_spend)          AS avg_spend
FROM revenue r
JOIN spend_daily s ON s.date = r.date
GROUP BY 1
ORDER BY 1;

-- (e) Seasonality — average revenue by month of year
SELECT
  EXTRACT(MONTH FROM date) AS month_of_year,
  AVG(revenue)             AS avg_revenue
FROM revenue
GROUP BY 1
ORDER BY 1;
