-- 02_data_quality.sql
-- Task 2: Data Quality Checks

-- (a) Missing values summary per table
WITH checks AS (
  SELECT 'marketing_spend' AS table_name, COUNT(*) AS rows_total,
         SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_date
  FROM marketing_spend
  UNION ALL
  SELECT 'revenue', COUNT(*), SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END)
  FROM revenue
  UNION ALL
  SELECT 'external_factors', COUNT(*), SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END)
  FROM external_factors
)
SELECT * FROM checks;

-- (b) Date range and calendar completeness check
WITH bounds AS (
  SELECT
    LEAST(
      (SELECT MIN(date) FROM marketing_spend),
      (SELECT MIN(date) FROM revenue),
      (SELECT MIN(date) FROM external_factors)
    ) AS min_d,
    GREATEST(
      (SELECT MAX(date) FROM marketing_spend),
      (SELECT MAX(date) FROM revenue),
      (SELECT MAX(date) FROM external_factors)
    ) AS max_d
)
SELECT * FROM bounds;

-- Generate daily calendar and check missing dates per table
CREATE OR REPLACE TEMP VIEW calendar AS
SELECT (d)::DATE AS d
FROM range(
  (SELECT min_d FROM bounds),
  (SELECT max_d FROM bounds) + INTERVAL 1 DAY,
  INTERVAL 1 DAY
) AS t(d);

SELECT c.d AS missing_date
FROM calendar c
LEFT JOIN revenue r ON r.date = c.d
WHERE r.date IS NULL
ORDER BY 1;

-- (c) Duplicated dates
SELECT date, COUNT(*) AS count
FROM revenue
GROUP BY date
HAVING COUNT(*) > 1
ORDER BY date;

-- (d) Outliers – IQR method
-- Revenue
WITH s AS (
  SELECT CAST(revenue AS DOUBLE) AS x, date
  FROM revenue
  WHERE revenue IS NOT NULL
),
q AS (
  SELECT quantile_cont(x, 0.25) AS q1, quantile_cont(x, 0.75) AS q3 FROM s
)
SELECT s.date, s.x AS revenue
FROM s, q
WHERE (q.q3 > q.q1)
  AND (s.x < (q.q1 - 1.5*(q.q3 - q.q1)) OR s.x > (q.q3 + 1.5*(q.q3 - q.q1)))
ORDER BY s.date;

-- Spend per channel
WITH s AS (
  SELECT channel, CAST(spend AS DOUBLE) AS x, date
  FROM marketing_spend_long
  WHERE spend IS NOT NULL
),
q AS (
  SELECT channel,
         quantile_cont(x, 0.25) AS q1,
         quantile_cont(x, 0.75) AS q3
  FROM s
  GROUP BY channel
)
SELECT s.date, s.channel, s.x AS spend
FROM s
JOIN q USING(channel)
WHERE (q.q3 > q.q1)
  AND (s.x < (q.q1 - 1.5*(q.q3 - q.q1)) OR s.x > (q.q3 + 1.5*(q.q3 - q.q1)))
ORDER BY s.channel, s.date;
