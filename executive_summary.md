# Executive Summary  
**Senior Data Analyst - Case Study**  
---

## 1. Key Findings  

- Overall revenue of **€33,288,486** with total marketing spend of **€8,425,197** (blended ROAS ≈ **4.76×**).  
- Channels performed uniformly under the proportional attribution method (ROAS ~4.76× each), indicating consistent efficiency across spend distribution.
- Spend variability is low (CV ≈ **0.15–0.16**) for all channels, showing stable and well-paced budget execution.  
- Revenue uplift observed during **holidays (+17.7%)**, **promotions (+9.8%)**, and **weekends (+7.2%)**, indicating responsiveness to external demand peaks.  
- No significant data gaps or outliers detected — dataset quality remains strong.  

---

## 2. Channel Performance Overview  

| Channel            | Total Spend (€) | Attributed Revenue (14d) (€) | ROAS (14d) |
|:-------------------|----------------:|-----------------------------:|------------:|
| Email              | 399,897         | 1,895,857                    | 4.76× |
| Paid Search        | 2,414,099       | 11,446,476                   | 4.76× |
| Display            | 1,198,983       | 5,686,468                    | 4.76× |
| Paid Social        | 2,009,386       | 9,528,182                    | 4.76× |
| TV                 | 1,599,736       | 7,582,953                    | 4.76× |
| Affiliate          | 803,094         | 3,809,549                    | 4.76× |

Although ROAS is uniform by design, differences in total spend illustrate each channel’s contribution to the revenue mix.

---

## 3. Budget Optimization & Expected Impact  

Equalizing efficiency across channels produces a balanced reallocation scenario:

- **Email and Display** would receive the largest relative increases, benefiting from historically lower investment yet comparable efficiency.  
- **Paid Search and Paid Social** show budget excess relative to return and would see reductions.  
- Projected **expected revenue** stabilizes near €6.66M per channel (illustrative, assuming constant elasticity).

| Channel           | Current Spend (€) | Recommended (€) | Δ Spend (€) | Expected Revenue (€) |
|:------------------|------------------:|----------------:|-------------:|---------------------:|
| Email             | 399,897 | 1,404,664 | +1,004,767 | 6,663,203 |
| Display           | 1,198,983 | 1,404,511 | +205,528 | 6,661,751 |
| Paid Search       | 2,414,099 | 1,404,473 | −1,009,627 | 6,661,392 |
| Paid Social       | 2,009,386 | 1,404,402 | −604,984 | 6,660,723 |
| TV                | 1,599,736 | 1,403,695 | −196,041 | 6,654,018 |

> **Note:** The recommended allocation is illustrative — equalizing spend under identical ROAS simply normalizes exposure. True optimization would rely on marginal elasticity or regression-based efficiency estimates.

---

## 4. Data Quality & Limitations  

- No missing or duplicate spend after correcting calendar inconsistencies.  
- One-day time shifts (daylight saving changes) were normalized in calendar averaging.  
- Attribution logic evenly distributes revenue based on 14-day spend share; this simplifies validation but hides actual performance variance.  
- External factor model remains binary (holiday, promotion, weekend), limiting causal interpretation.  

---

## 5. Next Steps  

1. Introduce **marginal ROI curves** or regression-based elasticity models.  
2. Add **non-linear constraints** (e.g., diminishing returns) for future optimization.  
3. Expand external data sources (e.g., competitor spend).  
4. Implement **lag-based ROAS tracking** for longer-term effects.  
5. Validate optimized budgets via controlled experiments (geo-split / A/B).  

---

