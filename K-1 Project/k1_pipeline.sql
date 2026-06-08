-- ============================================
-- K-1 Data Processing Pipeline
-- Author: Prakash Karunanithi
-- Tools: MySQL
-- Description: Processes Schedule K-1 tax data
-- across 3 private investment funds, flags
-- data quality issues, and reconciles fund
-- manager reports against individual K-1 totals.
-- ============================================

-- STEP 1: Create Database
CREATE DATABASE IF NOT EXISTS k1_project;
USE k1_project;

-- STEP 2: Create K1 Data Table
CREATE TABLE k1_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fund_name VARCHAR(100),
    ein VARCHAR(20),
    tax_year INT,
    partner_name VARCHAR(100),
    partner_tin VARCHAR(20),
    partner_type VARCHAR(50),
    ordinary_income DECIMAL(15,2),
    net_rental_income DECIMAL(15,2),
    interest_income DECIMAL(15,2),
    capital_gains_long DECIMAL(15,2),
    distributions DECIMAL(15,2),
    review_flag VARCHAR(100)
);

-- STEP 3: Insert K-1 Records
INSERT INTO k1_data 
(fund_name, ein, tax_year, partner_name, partner_tin, partner_type, ordinary_income, net_rental_income, interest_income, capital_gains_long, distributions, review_flag)
VALUES
('Goldman Sachs Alternatives Fund I','81-4256789',2025,'James Whitfield','412-78-9034','Limited Partner',125000,0,3200,48000,75000,'Clean'),
('Goldman Sachs Alternatives Fund I','81-4256789',2025,'Priya Nambiar','532-91-4421','Limited Partner',98000,0,2800,31000,50000,'Clean'),
('Goldman Sachs Alternatives Fund I','81-4256789',2025,'Robert Chen','671-34-8821','General Partner',210000,15000,5400,92000,120000,'Clean'),
('Ultimus Private Equity Fund II','47-8931245',2024,'Sandra Moore','334-56-7890','Limited Partner',76000,8200,1500,22000,40000,'Clean'),
('Ultimus Private Equity Fund II','47-8931245',2024,'David Okafor','445-23-6712','Limited Partner',0,0,0,0,0,'All Zeros - Needs Review'),
('Ultimus Private Equity Fund II','47-8931245',2024,'Linda Zhao','556-78-3345','Limited Partner',143000,0,4100,67000,90000,'Clean'),
('Paul McCoy Family Office Fund III','63-7412890',2023,'Thomas McCoy','778-45-2310','General Partner',320000,42000,8900,175000,200000,'Clean'),
('Paul McCoy Family Office Fund III','63-7412890',2023,'Rachel McCoy','889-12-5567','Limited Partner',95000,18000,2200,43000,60000,'Clean'),
('Paul McCoy Family Office Fund III','63-7412890',2023,NULL,'901-34-7823','Limited Partner',61000,0,1800,28000,35000,'Missing Partner Name');

-- STEP 4: Create Fund Summary Table (Fund Manager Reports)
CREATE TABLE fund_summary (
    fund_name VARCHAR(100),
    tax_year INT,
    reported_total_income DECIMAL(15,2)
);

INSERT INTO fund_summary VALUES
('Goldman Sachs Alternatives Fund I', 2025, 435000.00),
('Ultimus Private Equity Fund II', 2024, 219000.00),
('Paul McCoy Family Office Fund III', 2023, 500000.00);

-- ============================================
-- ANALYSIS QUERIES
-- ============================================

-- Query 1: Total Income Per Fund
SELECT 
    fund_name,
    tax_year,
    COUNT(partner_name) AS total_partners,
    SUM(ordinary_income) AS total_ordinary_income,
    SUM(capital_gains_long) AS total_capital_gains,
    SUM(distributions) AS total_distributions
FROM k1_data
GROUP BY fund_name, tax_year
ORDER BY tax_year DESC;

-- Query 2: Flag Missing and Zero Records
SELECT 
    fund_name,
    partner_name,
    partner_tin,
    ordinary_income,
    CASE
        WHEN partner_name IS NULL THEN 'Missing Name'
        WHEN ordinary_income = 0 THEN 'Zero Income - Review'
        ELSE 'Clean'
    END AS review_flag
FROM k1_data;

-- Query 3: Reconciliation - Fund Manager vs K-1 Totals
SELECT 
    fs.fund_name,
    fs.tax_year,
    fs.reported_total_income AS fund_manager_reported,
    SUM(kd.ordinary_income) AS k1_actual_total,
    fs.reported_total_income - SUM(kd.ordinary_income) AS discrepancy,
    CASE
        WHEN fs.reported_total_income = SUM(kd.ordinary_income) THEN 'Match'
        ELSE 'Discrepancy Found'
    END AS status
FROM fund_summary fs
JOIN k1_data kd 
    ON fs.fund_name = kd.fund_name 
    AND fs.tax_year = kd.tax_year
GROUP BY fs.fund_name, fs.tax_year, fs.reported_total_income
ORDER BY fs.tax_year DESC;

-- Query 4: Partner Ranking by Total Income
SELECT 
    partner_name,
    fund_name,
    tax_year,
    ordinary_income,
    capital_gains_long,
    distributions,
    (ordinary_income + capital_gains_long) AS total_income,
    RANK() OVER (ORDER BY (ordinary_income + capital_gains_long) DESC) AS income_rank
FROM k1_data
WHERE partner_name IS NOT NULL
ORDER BY income_rank;

-- Query 5: Final Review Flag Summary
SELECT review_flag, COUNT(*) AS record_count
FROM k1_data
GROUP BY review_flag;