/* 
04_channel_performance.sql
Task 4: Channel Performance

Assumption (didactic, for consistency across SQL):
Revenue is proportionally attributed to each channel based on its spend share
within a backward-looking window (t−n+1..t). The window total uses a global
rolling spend across all channels. This can yield similar ROAS across channels
when spend shares are stable — acceptable for this case study.
*/

-- 04_channel_performance.sql
-- Task 4: Channel Performance 
-- Includes:
--   (a) ROAS per channel with 7/14/30-day backward-inclusive windows (t-n+1..t)
--   (b) Identify top & bottom performing channels by total attributed revenue and efficiency (ROAS)
--   (c) Performance breakdowns by month/quarter, weekend vs weekday, promotional vs non-promotional

-- =====================================================================
-- Common reusable views
-- =====================================================================

-- Daily total spend across all channels (used in denominator windows)
CREATE OR REPLACE TEMP VIEW spend_daily AS
SELECT date, SUM(spend) AS total_spend_day
FROM marketing_spend_long
GROUP BY 1;

-- Total spend by channel for full period (used as ROAS denominator)
CREATE OR REPLACE TEMP VIEW spend_by_channel AS
SELECT channel, SUM(spend) AS total_spend
FROM marketing_spend_long
GROUP BY 1;

-- =====================================================================
-- (a) ROAS per channel with 7/14/30-day windows (backward-inclusive)
-- Attribution: revenue_t * (win_spend_c / win_spend_total)
-- ROAS = SUM(attributed_revenue) / SUM(spend_channel_full_period)
-- =====================================================================

-- -----------------------
-- 7-day window (t-6..t)
-- -----------------------
CREATE OR REPLACE TEMP VIEW win_spend_channel_7d AS
SELECT
  date,
  channel,
  SUM(spend) OVER (
    PARTITION BY channel
    ORDER BY date
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS win_spend_c
FROM marketing_spend_long;

CREATE OR REPLACE TEMP VIEW win_spend_total_7d AS
SELECT
  date,
  SUM(total_spend_day) OVER (
    ORDER BY date
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS win_spend_total
FROM spend_daily;

CREATE OR REPLACE TEMP VIEW joined_7d AS
SELECT
  r.date,
  wl.channel,
  wl.win_spend_c,
  wt.win_spend_total,
  r.revenue,
  CASE WHEN wt.win_spend_total > 0
       THEN r.revenue * (wl.win_spend_c / wt.win_spend_total)
       ELSE 0 END AS attributed_revenue
FROM revenue r
JOIN win_spend_channel_7d wl USING(date)
JOIN win_spend_total_7d   wt USING(date);

-- Final ROAS 7d (as a temp view for easy export)
CREATE OR REPLACE TEMP VIEW roas_7d AS
SELECT
  j.channel,
  SUM(j.attributed_revenue) AS attributed_revenue_7d,
  s.total_spend,
  CASE WHEN s.total_spend > 0
       THEN SUM(j.attributed_revenue) / s.total_spend
       ELSE NULL END AS roas_7d
FROM joined_7d j
JOIN spend_by_channel s USING(channel)
GROUP BY j.channel, s.total_spend;

-- ------------------------
-- 14-day window (t-13..t)
-- ------------------------
CREATE OR REPLACE TEMP VIEW win_spend_channel_14d AS
SELECT
  date,
  channel,
  SUM(spend) OVER (
    PARTITION BY channel
    ORDER BY date
    ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
  ) AS win_spend_c
FROM marketing_spend_long;

CREATE OR REPLACE TEMP VIEW win_spend_total_14d AS
SELECT
  date,
  SUM(total_spend_day) OVER (
    ORDER BY date
    ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
  ) AS win_spend_total
FROM spend_daily;

CREATE OR REPLACE TEMP VIEW joined_14d AS
SELECT
  r.date,
  wl.channel,
  wl.win_spend_c,
  wt.win_spend_total,
  r.revenue,
  CASE WHEN wt.win_spend_total > 0
       THEN r.revenue * (wl.win_spend_c / wt.win_spend_total)
       ELSE 0 END AS attributed_revenue
FROM revenue r
JOIN win_spend_channel_14d wl USING(date)
JOIN win_spend_total_14d   wt USING(date);

-- Final ROAS 14d (as a temp view for easy export)
CREATE OR REPLACE TEMP VIEW roas_14d AS
SELECT
  j.channel,
  SUM(j.attributed_revenue) AS attributed_revenue_14d,
  s.total_spend,
  CASE WHEN s.total_spend > 0
       THEN SUM(j.attributed_revenue) / s.total_spend
       ELSE NULL END AS roas_14d
FROM joined_14d j
JOIN spend_by_channel s USING(channel)
GROUP BY j.channel, s.total_spend;

-- ------------------------
-- 30-day window (t-29..t)
-- ------------------------
CREATE OR REPLACE TEMP VIEW win_spend_channel_30d AS
SELECT
  date,
  channel,
  SUM(spend) OVER (
    PARTITION BY channel
    ORDER BY date
    ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
  ) AS win_spend_c
FROM marketing_spend_long;

CREATE OR REPLACE TEMP VIEW win_spend_total_30d AS
SELECT
  date,
  SUM(total_spend_day) OVER (
    ORDER BY date
    ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
  ) AS win_spend_total
FROM spend_daily;

CREATE OR REPLACE TEMP VIEW joined_30d AS
SELECT
  r.date,
  wl.channel,
  wl.win_spend_c,
  wt.win_spend_total,
  r.revenue,
  CASE WHEN wt.win_spend_total > 0
       THEN r.revenue * (wl.win_spend_c / wt.win_spend_total)
       ELSE 0 END AS attributed_revenue
FROM revenue r
JOIN win_spend_channel_30d wl USING(date)
JOIN win_spend_total_30d   wt USING(date);

-- Final ROAS 30d (as a temp view for easy export)
CREATE OR REPLACE TEMP VIEW roas_30d AS
SELECT
  j.channel,
  SUM(j.attributed_revenue) AS attributed_revenue_30d,
  s.total_spend,
  CASE WHEN s.total_spend > 0
       THEN SUM(j.attributed_revenue) / s.total_spend
       ELSE NULL END AS roas_30d
FROM joined_30d j
JOIN spend_by_channel s USING(channel)
GROUP BY j.channel, s.total_spend;

-- =====================================================================
-- Build a common 14d daily attributed table for rankings & breakdowns
-- =====================================================================
CREATE OR REPLACE TEMP VIEW _win_spend_channel_14 AS
SELECT
  date,
  channel,
  SUM(spend) OVER (
    PARTITION BY channel
    ORDER BY date
    ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
  ) AS win_spend_c
FROM marketing_spend_long;

CREATE OR REPLACE TEMP VIEW _win_spend_total_14 AS
SELECT
  date,
  SUM(total_spend_day) OVER (
    ORDER BY date
    ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
  ) AS win_spend_total
FROM spend_daily;

CREATE OR REPLACE TEMP VIEW daily_attr_14 AS
SELECT
  r.date,
  wl.channel,
  CASE WHEN wt.win_spend_total > 0
       THEN r.revenue * (wl.win_spend_c / wt.win_spend_total)
       ELSE 0 END AS attributed_revenue_14
FROM revenue r
JOIN _win_spend_channel_14 wl USING(date)
JOIN _win_spend_total_14   wt USING(date);

-- Helper: daily spend by channel (pair with attributed revenue when needed)
CREATE OR REPLACE TEMP VIEW spend_by_day_channel AS
SELECT date, channel, SUM(spend) AS spend_day
FROM marketing_spend_long
GROUP BY 1,2;

-- =====================================================================
-- (b) Identify top & bottom performing channels (14d)
--     (i) By total attributed revenue
--     (ii) By efficiency (ROAS 14d = attributed_revenue / total_spend)
-- =====================================================================

-- Top by total attributed revenue (14d)
WITH sums AS (
  SELECT channel, SUM(attributed_revenue_14) AS attributed_revenue_14
  FROM daily_attr_14
  GROUP BY 1
)
SELECT *
FROM sums
ORDER BY attributed_revenue_14 DESC;

-- Bottom by total attributed revenue (14d)
WITH sums AS (
  SELECT channel, SUM(attributed_revenue_14) AS attributed_revenue_14
  FROM daily_attr_14
  GROUP BY 1
)
SELECT *
FROM sums
ORDER BY attributed_revenue_14 ASC;

-- Top by efficiency (ROAS 14d)
WITH sums AS (
  SELECT channel, SUM(attributed_revenue_14) AS attributed_revenue_14
  FROM daily_attr_14
  GROUP BY 1
),
roas AS (
  SELECT
    s.channel,
    s.attributed_revenue_14,
    b.total_spend,
    CASE WHEN b.total_spend > 0
         THEN s.attributed_revenue_14 / b.total_spend
         ELSE NULL END AS roas_14
  FROM sums s
  JOIN spend_by_channel b USING(channel)
)
SELECT *
FROM roas
ORDER BY roas_14 DESC NULLS LAST;

-- Bottom by efficiency (ROAS 14d)
WITH sums AS (
  SELECT channel, SUM(attributed_revenue_14) AS attributed_revenue_14
  FROM daily_attr_14
  GROUP BY 1
),
roas AS (
  SELECT
    s.channel,
    s.attributed_revenue_14,
    b.total_spend,
    CASE WHEN b.total_spend > 0
         THEN s.attributed_revenue_14 / b.total_spend
         ELSE NULL END AS roas_14
  FROM sums s
  JOIN spend_by_channel b USING(channel)
)
SELECT *
FROM roas
ORDER BY roas_14 ASC NULLS LAST;

-- =====================================================================
-- (c) Performance breakdowns (14d attribution base)
-- =====================================================================

-- Monthly breakdown
SELECT
  date_trunc('month', d.date) AS month,
  d.channel,
  SUM(d.attributed_revenue_14) AS attr_rev_14,
  SUM(s.spend_day)             AS spend
FROM daily_attr_14 d
JOIN spend_by_day_channel s
  ON s.date = d.date AND s.channel = d.channel
GROUP BY 1,2
ORDER BY 1,2;

-- Quarterly breakdown
WITH base AS (
  SELECT
    d.date,
    d.channel,
    d.attributed_revenue_14,
    s.spend_day
  FROM daily_attr_14 d
  JOIN spend_by_day_channel s
    ON s.date = d.date AND s.channel = d.channel
)
SELECT
  strftime('%Y', date)       AS year,
  EXTRACT(QUARTER FROM date) AS quarter,
  channel,
  SUM(attributed_revenue_14) AS attr_rev_14,
  SUM(spend_day)             AS spend
FROM base
GROUP BY 1,2,3
ORDER BY 1,2,3;

-- Weekend vs weekday (ISO: 6,7 = weekend)
WITH base AS (
  SELECT
    d.date,
    d.channel,
    d.attributed_revenue_14,
    s.spend_day,
    EXTRACT(ISODOW FROM d.date) AS dow
  FROM daily_attr_14 d
  JOIN spend_by_day_channel s
    ON s.date = d.date AND s.channel = d.channel
)
SELECT
  CASE WHEN dow IN (6,7) THEN 'weekend' ELSE 'weekday' END AS period,
  channel,
  AVG(attributed_revenue_14) AS avg_attr_rev_14,
  AVG(spend_day)             AS avg_spend
FROM base
GROUP BY 1,2
ORDER BY 1,2;

-- Promotional vs non-promotional periods
WITH base AS (
  SELECT
    d.date,
    d.channel,
    d.attributed_revenue_14,
    s.spend_day,
    COALESCE(CAST(e.promotion_active AS INTEGER), 0) AS is_promo
  FROM daily_attr_14 d
  JOIN spend_by_day_channel s
    ON s.date = d.date AND s.channel = d.channel
  LEFT JOIN external_factors e ON e.date = d.date
)
SELECT
  CASE WHEN is_promo = 1 THEN 'promo' ELSE 'non_promo' END AS period,
  channel,
  AVG(attributed_revenue_14) AS avg_attr_rev_14,
  AVG(spend_day)             AS avg_spend
FROM base
GROUP BY 1,2
ORDER BY 1,2;

-- =====================================================================
-- Notes:
-- • Windows are backward-inclusive (t-n+1..t), meaning each day's revenue
--   includes spend from the previous n-1 days plus the current day.
-- • ROAS denominator is the full-period channel spend to reflect overall efficiency.
-- • Adjust window size by editing the ROWS frame definitions above (7/14/30 days).
-- =====================================================================

-- Optional quick checks (commented)
-- SELECT * FROM roas_7d  ORDER BY roas_7d  DESC NULLS LAST;
-- SELECT * FROM roas_14d ORDER BY roas_14d DESC NULLS LAST;
-- SELECT * FROM roas_30d ORDER BY roas_30d DESC NULLS LAST;
