-- ============================================================
-- Part 1.3 — SQL Queries
-- File: part1-rdbms/queries.sql
-- Runs on the 3NF schema defined in schema_design.sql
-- Tables: customers, products, sales_reps, orders
-- ============================================================

-- Q1: List all customers from Mumbai along with their total order value
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_email,
    SUM(o.quantity * p.unit_price) AS total_order_value
FROM customers c
JOIN orders   o ON o.customer_id = c.customer_id
JOIN products p ON p.product_id  = o.product_id
WHERE c.customer_city = 'Mumbai'
GROUP BY c.customer_id, c.customer_name, c.customer_email
ORDER BY total_order_value DESC;


-- Q2: Find the top 3 products by total quantity sold
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(o.quantity) AS total_quantity_sold
FROM products p
JOIN orders o ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_quantity_sold DESC
LIMIT 3;


-- Q3: List all sales representatives and the number of unique customers they have handled
SELECT
    sr.sales_rep_id,
    sr.sales_rep_name,
    sr.sales_rep_email,
    COUNT(DISTINCT o.customer_id) AS unique_customers_handled
FROM sales_reps sr
LEFT JOIN orders o ON o.sales_rep_id = sr.sales_rep_id
GROUP BY sr.sales_rep_id, sr.sales_rep_name, sr.sales_rep_email
ORDER BY unique_customers_handled DESC;


-- Q4: Find all orders where the total value exceeds 10,000, sorted by value descending
SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    o.quantity,
    p.unit_price,
    (o.quantity * p.unit_price) AS order_total_value,
    o.order_date,
    sr.sales_rep_name
FROM orders    o
JOIN customers  c  ON c.customer_id  = o.customer_id
JOIN products   p  ON p.product_id   = o.product_id
JOIN sales_reps sr ON sr.sales_rep_id = o.sales_rep_id
WHERE (o.quantity * p.unit_price) > 10000
ORDER BY order_total_value DESC;


-- Q5: Identify any products that have never been ordered
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price
FROM products p
LEFT JOIN orders o ON o.product_id = p.product_id
WHERE o.order_id IS NULL;
