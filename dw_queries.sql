-- ============================================================
-- Part 3.2 — Data Warehouse Analytical Queries
-- File: part3-datawarehouse/dw_queries.sql
-- Runs on star schema defined in star_schema.sql
-- ============================================================

-- Q1: Total sales revenue by product category for each month
SELECT
    d.year,
    d.month_num,
    d.month_name,
    p.category,
    SUM(f.total_revenue)              AS total_revenue,
    SUM(f.units_sold)                 AS total_units_sold,
    COUNT(f.sale_id)                  AS num_transactions
FROM fact_sales   f
JOIN dim_date     d ON d.date_key    = f.date_key
JOIN dim_product  p ON p.product_key = f.product_key
GROUP BY d.year, d.month_num, d.month_name, p.category
ORDER BY d.year, d.month_num, p.category;


-- Q2: Top 2 performing stores by total revenue
SELECT
    s.store_name,
    s.store_city,
    SUM(f.total_revenue)   AS total_revenue,
    SUM(f.units_sold)      AS total_units_sold,
    COUNT(f.sale_id)       AS num_transactions
FROM fact_sales  f
JOIN dim_store   s ON s.store_key = f.store_key
GROUP BY s.store_key, s.store_name, s.store_city
ORDER BY total_revenue DESC
LIMIT 2;


-- Q3: Month-over-month sales trend across all stores
-- Uses a self-join / LAG approach to compare each month to the previous.
-- LAG() is ANSI SQL supported in MySQL 8+, PostgreSQL, SQLite 3.25+.
SELECT
    year,
    month_num,
    month_name,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY year, month_num)  AS prev_month_revenue,
    ROUND(
        100.0 * (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY year, month_num))
        / NULLIF(LAG(monthly_revenue) OVER (ORDER BY year, month_num), 0),
        2
    )                                                      AS mom_growth_pct
FROM (
    SELECT
        d.year,
        d.month_num,
        d.month_name,
        SUM(f.total_revenue) AS monthly_revenue
    FROM fact_sales f
    JOIN dim_date   d ON d.date_key = f.date_key
    GROUP BY d.year, d.month_num, d.month_name
) monthly_totals
ORDER BY year, month_num;
