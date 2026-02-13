# Retail Sales Analysis (SQL Project)

**Author:** Ishank Thapa Magar  
**Database:** MySQL  
**Level:** Beginner to Intermediate  

---

## Project Overview

This project focuses on **data cleaning, exploration, and business analysis** using a retail sales dataset. The objective is to practice real-world SQL techniques used by data analysts to generate business insights.

**Database Name:** `retail_sales_analysis`  
**Table Name:** `sales`

This project demonstrates:
- Data cleaning and preparation
- Exploratory Data Analysis (EDA)
- Business-driven SQL queries
- Customer and sales insights

---

## Database Setup

```sql
CREATE DATABASE retail_sales_analysis;
USE retail_sales_analysis;

---

## Table Preparation

- Renamed raw table to sales
- Fixed encoding issue in column name
- Added primary key

```sql
RENAME TABLE `sql - retail sales analysis_utf` TO sales;

ALTER TABLE sales 
ADD PRIMARY KEY (transactions_id);

ALTER TABLE sales 
RENAME COLUMN ï»¿transactions_id TO transactions_id;

---

## Data Cleaning
Checking for Null Values
```sql
SELECT *
FROM sales
WHERE
    transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR quantiy IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;
### Removing Incomplete Records
```sql
DELETE FROM sales
WHERE
    transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR quantiy IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;

---

## Exploratory Data Analysis (EDA)

### Key Metrics
``` sql
-- Total Sales
SELECT COUNT(*) AS total_sales FROM sales;

-- Total Quantity Sold
SELECT SUM(quantiy) AS total_quantity_sold FROM sales;

-- Total Unique Customers
SELECT COUNT(DISTINCT customer_id) AS total_users FROM sales;

-- Category Distribution
SELECT category, COUNT(*) 
FROM sales
GROUP BY category;

## Business Analysis Queries
**1. Sales on a Specific Date**
```sql
SELECT *
FROM sales
WHERE sale_date = '2022-11-05';

**2. Clothing Transactions (Nov 2022, Quantity ≥ 4)**
```sql 
SELECT *
FROM sales
WHERE category = 'Clothing'
AND MONTH(sale_date) = 11
AND YEAR(sale_date) = 2022
AND quantiy >= 4;

**3. Total Sales by Category**
```sql
SELECT 
    category,
    SUM(total_sale) AS net_sales,
    COUNT(*) AS total_orders
FROM sales
GROUP BY category;

**4. Average Customer Age (Beauty Category)**
```sql
SELECT AVG(age) AS average_age
FROM sales
WHERE category = 'Beauty';

**5. High Value Transactions (> 1000)**
```sql
SELECT *
FROM sales
WHERE total_sale > 1000;

**6. Transactions by Gender and Category**
```sql
SELECT 
    gender,
    category,
    COUNT(DISTINCT transactions_id) AS total_orders
FROM sales
GROUP BY gender, category;

**7. Best Selling Month Each Year (Window Function)**
```sql
SELECT date_year, date_month, avg_sales
FROM (
    SELECT 
        YEAR(sale_date) AS date_year,
        MONTH(sale_date) AS date_month,
        AVG(total_sale) AS avg_sales,
        RANK() OVER (
            PARTITION BY YEAR(sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS rank_month
    FROM sales
    GROUP BY date_year, date_month
) t
WHERE rank_month = 1;

**8. Top 5 Customers by Total Sales**
```sql
SELECT 
    customer_id,
    SUM(total_sale) AS total_order_value
FROM sales
GROUP BY customer_id
ORDER BY total_order_value DESC
LIMIT 5;

**9. Unique Customers per Category**
```sql
SELECT 
    category,
    COUNT(DISTINCT customer_id) AS total_customers
FROM sales
GROUP BY category;

**10. Sales by Time Shift (CTE)**
Shift Categories:
- Morning: ≤ 12
- Afternoon: 12–17
- Evening: >17
```sql
WITH hourly_sales AS (
    SELECT *,
        CASE
            WHEN HOUR(sale_time) <= 12 THEN 'Morning'
            WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM sales
)
SELECT 
    shift,
    SUM(total_sale) AS total_revenue,
    COUNT(transactions_id) AS total_orders
FROM hourly_sales
GROUP BY shift;

---

## Key Insights

-Identified top revenue-generating customers
-Found high-value transactions
-Determined best-performing months
-Analyzed customer demographics by category
-Evaluated product category performance
-Identified peak sales time using shift analysis
