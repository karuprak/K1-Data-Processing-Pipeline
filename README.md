# K-1 Data Processing Pipeline

## Overview
A SQL-based pipeline that processes Schedule K-1 private investment tax data 
across three funds — modeled after real Arch clients: Goldman Sachs, Ultimus, 
and Paul McCoy Family Office.

---

## Problem Statement
Private investment firms receive K-1 tax documents from multiple funds every year. 
This data must be extracted, validated, and reconciled before it reaches the client. 
Errors or missing data directly impact client reporting accuracy.

---

## Funds Processed
| Fund | Tax Year | Partners |
|---|---|---|
| Goldman Sachs Alternatives Fund I | 2025 | 3 |
| Ultimus Private Equity Fund II | 2024 | 3 |
| Paul McCoy Family Office Fund III | 2023 | 3 |

---

## Tools Used
- MySQL — database and SQL analysis
- CSV — raw data ingestion
- IRS Schedule K-1 Form 1065 — real form structure reference

---

## Database Schema

### Table 1 — k1_data (Individual Partner K-1 Records)
| Column | Description |
|---|---|
| fund_name | Name of the private investment fund |
| ein | Fund's Employer Identification Number |
| tax_year | Tax year of the K-1 |
| partner_name | Name of the partner/investor |
| partner_tin | Partner's Tax Identification Number |
| partner_type | General or Limited Partner |
| ordinary_income | Box 1 — Ordinary business income |
| net_rental_income | Box 2 — Net rental income |
| interest_income | Box 5 — Interest income |
| capital_gains_long | Box 9a — Long-term capital gains |
| distributions | Box 19 — Cash distributions |
| review_flag | Data quality classification |

### Table 2 — fund_summary (Fund Manager Reported Totals)
| Column | Description |
|---|---|
| fund_name | Name of the fund |
| tax_year | Tax year |
| reported_ordinary_income | Fund manager reported ordinary income |
| reported_rental_income | Fund manager reported rental income |
| reported_capital_gains | Fund manager reported capital gains |
| reported_distributions | Fund manager reported distributions |

---

## Step 1 — Raw Data Overview
All 9 K-1 records loaded across 3 funds and 3 tax years.

![K1 Data Overview](K-1%20Project/k1_data_overview.png)

---

## Step 2 — Data Quality Flags
Every record classified automatically — Clean, Missing Partner Name, or All Zeros Needs Review.

![Data Quality Flags](K-1%20Project/data_quality_flags.png)

---

## Step 3 — Detailed Reconciliation
Each income field compared separately against fund manager reported figures.

![Reconciliation](K-1%20Project/descrepancies.png)

---

## Step 4 — Partner Ranking
All partners ranked by total income using SQL RANK() window function.

![Partner Ranking](K-1%20Project/partner_ranking.png)

---

## Key Findings
| Finding | Detail |
|---|---|
| Goldman Sachs 2025 | $2,000 discrepancy in ordinary income vs fund manager report |
| Paul McCoy 2023 | $24,000 discrepancy in ordinary income vs fund manager report |
| Ultimus 2024 | Perfect match across all fields ✅ |
| Missing partner name | Paul McCoy fund — TIN 901-34-7823 has no name |
| All zeros record | David Okafor, Ultimus — all financial fields are zero |

---

## Recommended Actions
| Record | Issue | Action |
|---|---|---|
| Goldman Sachs 2025 | $2,000 discrepancy | Re-request confirmation from fund manager |
| Paul McCoy 2023 | $24,000 discrepancy | Escalate to senior analyst for immediate reconciliation |
| Paul McCoy 2023 | Missing partner name | Contact fund administrator for legal name matching TIN 901-34-7823 |
| David Okafor, Ultimus 2024 | All zeros | Verify with fund manager whether data was submitted |

---

## Processing Status Summary
| Status | Count |
|---|---|
| Clean — Ready for client reporting | 7 |
| Flagged — Pending review | 2 |
| Discrepancies requiring reconciliation | 2 |
| Total records processed | 9 |
