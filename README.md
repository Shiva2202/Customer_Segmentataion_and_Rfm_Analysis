# Customer Analytics & RFM Segmentation – Online Retail

End-to-end customer analytics project: **SQL cleaning → Python RFM segmentation → Power BI dashboard**, built on the UCI *Online Retail II* transaction data (2009–2011). It identifies the customers who drive revenue, flags those at risk of churning, and recommends actions for each segment.

---

## Headline Results

| Metric | Value |
|---|---|
| Identified customers analysed | **5,881** |
| Valid invoices | **36,975** |
| Net positive revenue | **$17,374,770.65** |
| Churn rate (no purchase in 90+ days) | **50.86%** (2,991 customers) |
| Champions | 21.95% of customers → **68.13% of revenue** |
| Champions + Loyal | 46.03% of customers → **83.68% of revenue** |
| UK share of revenue | 82.81% (51.16% churn) |

Revenue is highly concentrated in a small group of customers, while half of the customer base has gone quiet. Win-back and retention efforts should be prioritised by customer value.

---

## Project Workflow

```
online_retail_II.csv (raw)
        │
        ▼
  SQL Server cleaning  (SQLQuery3.sql)
  - type-safe date/price conversion
  - data-quality checks
  - ROW_NUMBER() deduplication
        │
        ▼
  OnlineRetailCleaned.csv  (1,033,034 rows)
        │
        ▼
  Python / pandas  (OnlineRetail_RFM_Segmentation.ipynb)
  - filter valid customers & positive quantity
  - Recency, Frequency, Monetary
  - 1–5 quintile scoring + segment rules
  - churn flag (Recency > 90 days)
        │
        ▼
  OnlineRetailDashboardData.xlsx
        │
        ▼
  Power BI dashboard (.pbix)
```

---

## Repository Contents

| File | Description |
|---|---|
| `SQLQuery3.sql` | SQL Server script: safe type conversion, data-quality checks, deduplication, creates `OnlineRetailCleaned` |
| `OnlineRetail_RFM_Segmentation.ipynb` | Python notebook that computes RFM scores, segments, churn flag and exports dashboard data |
| `OnlineRetailDashboardData.xlsx` | Transaction-level data with RFM results merged in (Power BI source) |
| `OnlineRetailCleaned.csv` | Output of the SQL cleaning stage |
| `online_retail_II.csv` | Raw source data |
| `Customer_Segmentataion_and_Rfm_Analysis_Dashboard_updated.pbix` | Power BI dashboard |
| `01_home.png` to `05_rfm_country.png` | Dashboard page screenshots shown in this README |
| `Customer_Analytics_Executive_Summary.pdf` | Executive summary of findings and recommendations |

---

## Methodology

### 1. Data Cleaning (SQL Server)
- Converted dates (two formats handled via `TRY_CONVERT` styles 120 and 105) and prices to `DECIMAL(10,2)`.
- Audited missing Customer IDs, non-positive quantities, missing descriptions and exact duplicates.
- Removed exact duplicates with `ROW_NUMBER() OVER (PARTITION BY …)`.
- Result: **1,033,034** cleaned rows.

### 2. RFM Analysis (Python)
- **Cohort:** rows with a valid `Customer_ID` and `Quantity > 0` (779,493 rows).
- **Snapshot date:** 2011-12-10.
- **Recency:** days since last purchase. **Frequency:** distinct invoices. **Monetary:** sum of `Quantity × Price`.
- **Scoring:** quintiles (1–5) for each of R, F, M.

### 3. Segmentation Rules

| Segment | Rule |
|---|---|
| Champions | R ≥ 4, F ≥ 4, M ≥ 4 |
| Loyal | R ≥ 3, F ≥ 3 |
| At Risk | R ≤ 2, F ≥ 3 |
| New | R ≥ 4, F ≤ 2 |
| Needs Attention | R = 3, F ≤ 2 |
| Lost | Everything else |

**Churn flag:** `Recency > 90` days.

---

## Segment Summary

| Segment | Customers | Cust. Share | Revenue | Rev. Share | Avg. Recency | Avg. Freq. | Avg. Monetary | Churned |
|---|---|---|---|---|---|---|---|---|
| Champions | 1,291 | 21.95% | $11,836,614.14 | 68.13% | 20.3d | 17.14 | $9,168.56 | 0.00% |
| Loyal | 1,416 | 24.08% | $2,701,267.25 | 15.55% | 72.1d | 5.44 | $1,907.67 | 31.50% |
| At Risk | 821 | 13.96% | $1,586,359.12 | 9.13% | 370.3d | 4.94 | $1,932.23 | 100.00% |
| New | 442 | 7.52% | $392,021.57 | 2.26% | 28.5d | 1.46 | $886.93 | 0.00% |
| Needs Attention | 387 | 6.58% | $204,623.90 | 1.18% | 107.5d | 1.36 | $528.74 | 51.68% |
| Lost | 1,524 | 25.91% | $653,884.67 | 3.76% | 460.3d | 1.25 | $429.06 | 100.00% |
| **Total** | **5,881** | 100% | **$17,374,770.65** | 100% | 192.6d | 6.29 | $2,954.39 | **50.86%** |

---

## Key Insights

- **Revenue concentration:** Champions generate 68% of revenue from ~22% of customers.
- **Churn:** 2,991 customers (50.86%) are inactive for 90+ days, representing 19.52% of revenue.
- **Win-back priority:** At Risk customers (821 previously frequent buyers, $1.59M) offer the best reactivation ROI.
- **Seasonality:** Revenue surges every autumn (Nov 2010: $1.17M; Nov 2011: $1.16M) and drops sharply in Q1.
- **Year over year:** Jan–Nov 2010 vs. Jan–Nov 2011 revenue was flat (−0.06%); 62.86% of 2010 buyers purchased again in 2011.
- **Geography:** The UK accounts for 82.81% of revenue. International customers spend more than twice as much per customer ($5,645 vs. $2,688), reflecting wholesale and bulk accounts.

---

## Recommended Actions

| Segment | Action |
|---|---|
| Champions | Early Q4 catalogue access, dedicated account support, volume-tier rewards instead of blanket discounts |
| Loyal | Automated 60-day inactivity reminders; cross-sell complementary products |
| At Risk | Value-ranked win-back campaigns, highest-Monetary accounts first |
| New | Post-purchase onboarding within 30–45 days to drive a second order |
| Needs Attention | Time-bound seasonal offers before recency passes 120 days |
| Lost | Low-cost automated emails only; exclude from expensive campaigns |

---

## Limitations

- A uniform 90-day churn cutoff may over-flag wholesale/bulk buyers who have longer purchasing cycles. A bulk-buyer flag is recommended for future iterations.
- 235,151 rows without a Customer ID and 22,496 return/cancellation lines (Quantity ≤ 0) are excluded, so results reflect net positive identified spend only.
- 6,037 rows have zero or negative price; these remain in the source data and were only tracked during validation.

---

## Tools & Technologies

SQL Server (T-SQL) · Python (pandas) · Jupyter Notebook · Power BI · Excel

## How to Reproduce

1. Import `online_retail_II.csv` into SQL Server and run `SQLQuery3.sql` to create `OnlineRetailCleaned`.
2. Export the cleaned table to `OnlineRetailCleaned.csv`.
3. Run `OnlineRetail_RFM_Segmentation.ipynb` (requires `pandas` and `openpyxl`) to generate `OnlineRetailDashboardData.xlsx`.
4. Open the `.pbix` file in Power BI Desktop and refresh the data source path.

## Data Source

[UCI Machine Learning Repository – Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii): transactions from a UK-based online retailer, 2009–2011.

## Dashboard Screenshots

### 1. Home Page

![1. Home Page]((https://github.com/Shiva2202/Shiva2202-Customer_Segmentataion_and_Rfm_Analysis/blob/main/01_home.png?raw=true)

*Landing page with navigation to the Business Overview and RFM Analysis pages and a glossary of key metrics.*

### 2. Business Overview – Revenue

![2. Business Overview – Revenue](https://github.com/Shiva2202/Shiva2202-Customer_Segmentataion_and_Rfm_Analysis/blob/main/02_business_overview_revenue.png?raw=true)

*Revenue performance across the business.*

### 3. Business Overview – Customers

![3. Business Overview – Customers](https://github.com/Shiva2202/Shiva2202-Customer_Segmentataion_and_Rfm_Analysis/blob/main/03_business_overview_customers.png
?raw=true)

*Customer base and activity overview.*

### 4. RFM Analysis – Segments

![4. RFM Analysis – Segments](https://github.com/Shiva2202/Shiva2202-Customer_Segmentataion_and_Rfm_Analysis/blob/main/04_rfm_segment.png?raw=true)

*Customer segments (Champions, Loyal, At Risk, New, Needs Attention, Lost) based on Recency, Frequency and Monetary scores.*

### 5. RFM Analysis – Country

![5. RFM Analysis – Country](https://github.com/Shiva2202/Shiva2202-Customer_Segmentataion_and_Rfm_Analysis/blob/main/05_rfm_country.png?raw=true)

*Customer value and churn risk by geographic market.*

---

## Author

**Shiva Kumar**
