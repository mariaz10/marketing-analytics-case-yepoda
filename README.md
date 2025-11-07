#  Marketing Performance Analysis — SQL Case Study  
---

###  Overview  
This project evaluates multi-channel marketing performance entirely in **SQL**.  
It focuses on data quality validation, temporal trends, channel efficiency (ROAS), incrementality, and budget optimization.  
All queries are fully reproducible in **DuckDB**, with results exported as `.csv` files and summarized in `executive_summary.md`.

---

###  Database Setup  

1. **Create and load base tables** in DuckDB:  

   ```sql
   CREATE TABLE marketing_spend_long AS 
   SELECT * FROM read_csv_auto('marketing_spend_long.csv');

   CREATE TABLE revenue AS 
   SELECT * FROM read_csv_auto('revenue.csv');

   CREATE TABLE external_factors AS 
   SELECT * FROM read_csv_auto('external_factors.csv');
   ```

2. **Confirm table integrity (optional sanity checks):**  

   ```sql
   SELECT COUNT(*) FROM marketing_spend_long;
   SELECT COUNT(*) FROM revenue;
   SELECT COUNT(*) FROM external_factors;
   ```

---

###  SQL Dialect  
- **Dialect:** DuckDB (syntax compatible with PostgreSQL / SQLite)  
- **Core features used:**  
  - `CTE` (Common Table Expressions)  
  - `Window functions` for rolling calculations  
  - `Aggregate and analytic functions`  
  - `JOINs` and `CASE` logic  
- **Optimization principle:** clarity and reproducibility > brevity  

---

###  Files & Execution Order (matches this repo)  

| Step | File | What it does |
|---|---|---|
| 1️⃣ | `01_schema_setup.sql` | Loads CSVs, enforces types, builds `marketing_spend_long` view. |
| 2️⃣ | `02_data_quality.sql` | Completeness/duplicates, calendar gaps, IQR outlier scans, basic date bounds. |
| 3️⃣ | `03_exploratory_analysis.sql` | Correlations and external-factor effects (holiday / promo / weekend), seasonality, DoW/Month summaries. |
| 4️⃣ | `04_channel_performance.sql` | ROAS per channel for 7/14/30-day backward-inclusive windows; rankings and time breakdowns. |
| 5️⃣ | `05_advanced_analysis.sql` | Builds reusable daily tables (spend & attributed revenue 14d), incrementality (zero vs spend, quartiles), cohort efficiency; exports CSV-equivalent tables. |
| 6️⃣ | `06_budget_optimization.sql` | Spend variability (consistency vs volatility), decile efficiency curves, and a reallocation recommendation with expected impact. |

**Run in this order** after loading the base tables.  



---

### Key Assumptions  
- **Attribution logic:** Revenue is proportionally distributed across channels by **spend share** within a backward-looking window (t−n+1..t).  
- **Spend stability:** Channel spend shares are relatively stable across the period.  
- **Temporal coverage:** DST/calendar quirks are negligible.  
- **External factors:** Limited to `holiday`, `promotion_active`, `weekend`.  
- **Data quality:** No nulls or duplicates after load; types are enforced in `01_schema_setup.sql`.

---

### Results & Insights  
See **`executive_summary.md`** for:  
- Key findings (3–5 bullets)  
- Channel rankings (spend, attributed revenue, ROAS)  
- Budget optimization plan & expected revenue impact  
- Data quality notes & limitations  
- Next steps

---

### Deliverables  
- All **SQL scripts** (01–06), reproducible end-to-end  
- **CSV exports** under `results/` 
- **Executive summary** and this **README** for documentation
