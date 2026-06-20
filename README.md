# K-1 Data Processing Pipeline

## Overview
A SQL-based data processing pipeline that ingests, classifies, and reconciles 
Schedule K-1 private investment tax data across three funds — modeled after 
real Arch clients: Goldman Sachs, Ultimus, and Paul McCoy Family Office.

## Problem Statement
Private investment firms receive Schedule K-1 forms from multiple funds every 
year. This data must be extracted, validated, and reconciled against fund 
manager reports before it can be delivered to clients. Errors or missing data 
can directly impact client reporting accuracy.

## What This Pipeline Does
- Ingests K-1 partner data across 3 funds and 3 tax years (2023, 2024, 2025)
- Classifies each record with a data quality review flag
- Reconciles individual K-1 totals against fund manager reported figures
- Identifies discrepancies, missing records, and zero-income anomalies

## Tools Used
- MySQL — database and SQL analysis
- CSV — raw data ingestion
- IRS Schedule K-1 Form 1065 — real form structure reference

## Database Schema
**k1_data** — Individual partner K-1 records
| Column | Description |
|---|---|
| fund_name | Name of the private investment fund |
| ein | Fund's Employer Identification Number |
| tax_year | Tax year of the K-1 |
| partner\_name | Name of the partner/investor |
| partner_tin | Partner's Tax Identification Number |
| partner_type | General or Limited Partner |
| ordinary_income | Box 1 — Ordinary business income |
| net_rental_income | Box 2 — Net rental income |
| interest_income | Box 5 — Interest income |
| capital_gains_long | Box 9a — Long-term capital gains |
| distributions | Box 19 — Cash distributions |
| review_flag | Data quality classification |

**fund_summary** — Fund manager reported totals for reconciliation

## Key SQL Queries
1. **Fund Level Summary** — Total income and distributions per fund per year
2. **Data Quality Flags** — Identifies missing names and zero-income records
3. **Reconciliation** — Compares K-1 totals vs fund manager reports
4. **Partner Ranking** — Ranks all partners by total income using RANK()
5. **Flag Update** — Writes review classifications back to the database

 ## Query Results

### Fund Level Summary
![Fund Summary](K-1%20Project/fund_summary.png)

### Data Quality Review Flags
![Review Flags](K-1%20Project/review_flags.png)

### Discrepancy
![discrepancy](K-1%20Project/discrepancy.png)

## Key Findings
- Goldman Sachs 2025: **$2,000 discrepancy** vs fund manager report
- Paul McCoy 2023: **$24,000 discrepancy** vs fund manager report
- Ultimus 2024: **Perfect match** ✅
- 1 record flagged: Missing partner name (Paul McCoy fund)
- 1 record flagged: All zeros — needs review (David Okafor, Ultimus)

## Recommended Actions

| Record | Issue | Recommended Action |
|---|---|---|
| Goldman Sachs Alternatives Fund I (2025) | $2,000 discrepancy vs fund manager report | Re-request confirmation from fund manager. Verify if amended K-1 is pending |
| Paul McCoy Family Office Fund III (2023) | $24,000 discrepancy vs fund manager report | Escalate to senior analyst. Gap exceeds $10,000 threshold, requires immediate reconciliation |
| Paul McCoy Family Office Fund III (2023) | Missing partner name | Contact fund administrator to provide full legal name matching TIN 901-34-7823 |
| David Okafor — Ultimus Private Equity Fund II (2024) | All zeros across all financial fields | Verify with fund manager whether partner had zero activity or if data was not submitted |

## Processing Status Summary

| Status | Count |
|---|---|
| Clean — Ready for client reporting | 7 |
| Flagged — Pending review | 2 |
| Discrepancies requiring reconciliation | 2 |
| Total records processed | 9 |


## Funds Processed
| Fund | Tax Year | Partners |
|---|---|---|
| Goldman Sachs Alternatives Fund I | 2025 | 3 |
| Ultimus Private Equity Fund II | 2024 | 3 |
| Paul McCoy Family Office Fund III | 2023 | 3 |
