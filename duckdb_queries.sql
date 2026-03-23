-- ============================================================
-- Part 5.1 — Data Lake: Cross-Format DuckDB Queries
-- File: part5-datalake/duckdb_queries.sql
--
-- Files read directly (no pre-loading into tables):
--   customers  → datasets/customers.csv
--   orders     → datasets/orders.json
--   products   → datasets/products.parquet
--
-- Run with: duckdb < duckdb_queries.sql
-- Or paste each query into the DuckDB CLI / Python duckdb session.
-- ============================================================

-- Q1: List all customers along with the total number of orders they have placed
SELECT
    c.customer_id,
    c.name                         AS customer_name,
    c.city,
    COUNT(o.order_id)              AS total_orders
FROM read_csv_auto('datasets/customers.csv')            AS c
LEFT JOIN read_json_auto('datasets/orders.json')        AS o
       ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name, c.city
ORDER BY total_orders DESC, c.customer_id;


-- Q2: Find the top 3 customers by total order value
SELECT
    c.customer_id,
    c.name                         AS customer_name,
    c.city,
    SUM(o.total_amount)            AS total_order_value
FROM read_csv_auto('datasets/customers.csv')            AS c
JOIN read_json_auto('datasets/orders.json')             AS o
  ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name, c.city
ORDER BY total_order_value DESC
LIMIT 3;


-- Q3: List all products purchased by customers from Bangalore
-- products.parquet schema: line_item_id, order_id, product_id,
--                          product_name, category, quantity, unit_price, total_price
SELECT DISTINCT
    p.product_id,
    p.product_name,
    p.category
FROM read_csv_auto('datasets/customers.csv')            AS c
JOIN read_json_auto('datasets/orders.json')             AS o
  ON o.customer_id = c.customer_id
JOIN read_parquet('datasets/products.parquet')          AS p
  ON p.order_id = o.order_id
WHERE c.city = 'Bangalore'
ORDER BY p.category, p.product_name;


-- Q4: Join all three files to show: customer name, order date, product name, and quantity
SELECT
    c.name                         AS customer_name,
    c.city                         AS customer_city,
    o.order_id,
    o.order_date,
    p.product_name,
    p.category,
    p.quantity
FROM read_csv_auto('datasets/customers.csv')            AS c
JOIN read_json_auto('datasets/orders.json')             AS o
  ON o.customer_id = c.customer_id
JOIN read_parquet('datasets/products.parquet')          AS p
  ON p.order_id = o.order_id
ORDER BY o.order_date DESC, c.name;
