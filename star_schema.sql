-- ============================================================
-- Part 3.1 — Star Schema Design
-- File: part3-datawarehouse/star_schema.sql
-- Source: retail_transactions.csv
-- ============================================================
-- Star Schema:
--   Fact Table  : fact_sales
--   Dimensions  : dim_date, dim_store, dim_product
--
-- ETL cleaning applied before INSERT:
--   1. Date formats normalized to YYYY-MM-DD
--   2. NULL store_city values inferred from store_name
--   3. Category casing standardized (Electronics, Grocery, Clothing)
-- ============================================================

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_product;

-- ============================================================
-- DIMENSION: dim_date
-- Pre-populated date dimension for 2023. Enables calendar-based
-- aggregations (month-over-month, quarterly) without date parsing
-- in every analytical query.
-- ============================================================
CREATE TABLE dim_date (
    date_key    INT          NOT NULL,   -- Surrogate key: YYYYMMDD integer
    full_date   DATE         NOT NULL,
    day_of_week VARCHAR(10)  NOT NULL,
    day_num     INT          NOT NULL,
    month_num   INT          NOT NULL,
    month_name  VARCHAR(15)  NOT NULL,
    quarter     INT          NOT NULL,
    year        INT          NOT NULL,
    CONSTRAINT pk_dim_date PRIMARY KEY (date_key)
);

-- ============================================================
-- DIMENSION: dim_store
-- Deduplicates store information. Each store has a stable
-- surrogate key so store renames don't break historical joins.
-- ============================================================
CREATE TABLE dim_store (
    store_key   INT          NOT NULL,   -- Surrogate key
    store_id    VARCHAR(20)  NOT NULL,   -- Natural key
    store_name  VARCHAR(100) NOT NULL,
    store_city  VARCHAR(100) NOT NULL,
    CONSTRAINT pk_dim_store PRIMARY KEY (store_key)
);

-- ============================================================
-- DIMENSION: dim_product
-- Deduplicates product and category data.
-- ============================================================
CREATE TABLE dim_product (
    product_key  INT          NOT NULL,  -- Surrogate key
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(100) NOT NULL,
    unit_price   DECIMAL(12,2) NOT NULL,
    CONSTRAINT pk_dim_product PRIMARY KEY (product_key)
);

-- ============================================================
-- FACT TABLE: fact_sales
-- Grain: one row per transaction.
-- Numeric measures: units_sold, unit_price, total_revenue.
-- ============================================================
CREATE TABLE fact_sales (
    sale_id        VARCHAR(15)   NOT NULL,
    date_key       INT           NOT NULL,
    store_key      INT           NOT NULL,
    product_key    INT           NOT NULL,
    customer_id    VARCHAR(20)   NOT NULL,
    units_sold     INT           NOT NULL,
    unit_price     DECIMAL(12,2) NOT NULL,
    total_revenue  DECIMAL(14,2) NOT NULL,  -- units_sold * unit_price
    CONSTRAINT pk_fact_sales       PRIMARY KEY (sale_id),
    CONSTRAINT fk_fact_date        FOREIGN KEY (date_key)    REFERENCES dim_date(date_key),
    CONSTRAINT fk_fact_store       FOREIGN KEY (store_key)   REFERENCES dim_store(store_key),
    CONSTRAINT fk_fact_product     FOREIGN KEY (product_key) REFERENCES dim_product(product_key)
);

-- ============================================================
-- INSERT: dim_date (months present in the dataset)
-- ============================================================
INSERT INTO dim_date (date_key, full_date, day_of_week, day_num, month_num, month_name, quarter, year) VALUES
(20230115, '2023-01-15', 'Sunday',    15, 1,  'January',   1, 2023),
(20230205, '2023-02-05', 'Sunday',     5, 2,  'February',  1, 2023),
(20230220, '2023-02-20', 'Monday',    20, 2,  'February',  1, 2023),
(20230307, '2023-03-07', 'Tuesday',    7, 3,  'March',     1, 2023),
(20230331, '2023-03-31', 'Friday',    31, 3,  'March',     1, 2023),
(20230418, '2023-04-18', 'Tuesday',   18, 4,  'April',     2, 2023),
(20230516, '2023-05-16', 'Tuesday',   16, 5,  'May',       2, 2023),
(20230604, '2023-06-04', 'Sunday',     4, 6,  'June',      2, 2023),
(20230809, '2023-08-09', 'Wednesday',  9, 8,  'August',    3, 2023),
(20230815, '2023-08-15', 'Tuesday',   15, 8,  'August',    3, 2023),
(20230829, '2023-08-29', 'Tuesday',   29, 8,  'August',    3, 2023),
(20231020, '2023-10-20', 'Friday',    20, 10, 'October',   4, 2023),
(20231026, '2023-10-26', 'Thursday',  26, 10, 'October',   4, 2023),
(20231118, '2023-11-18', 'Saturday',  18, 11, 'November',  4, 2023),
(20231208, '2023-12-08', 'Friday',     8, 12, 'December',  4, 2023),
(20231212, '2023-12-12', 'Tuesday',   12, 12, 'December',  4, 2023);

-- ============================================================
-- INSERT: dim_store (5 unique stores from dataset)
-- NULL city values resolved via store_name mapping
-- ============================================================
INSERT INTO dim_store (store_key, store_id, store_name, store_city) VALUES
(1, 'STR001', 'Chennai Anna',    'Chennai'),
(2, 'STR002', 'Delhi South',     'Delhi'),
(3, 'STR003', 'Bangalore MG',    'Bangalore'),
(4, 'STR004', 'Pune FC Road',    'Pune'),
(5, 'STR005', 'Mumbai Central',  'Mumbai');

-- ============================================================
-- INSERT: dim_product (unique products from dataset)
-- Category standardized: 'electronics' → 'Electronics', 'Groceries' → 'Grocery'
-- ============================================================
INSERT INTO dim_product (product_key, product_name, category, unit_price) VALUES
(1,  'Speaker',     'Electronics', 49262.78),
(2,  'Tablet',      'Electronics', 23226.12),
(3,  'Phone',       'Electronics', 48703.39),
(4,  'Smartwatch',  'Electronics', 58851.01),
(5,  'Atta 10kg',   'Grocery',     52464.00),
(6,  'Jeans',       'Clothing',     2317.47),
(7,  'Biscuits',    'Grocery',     27469.99),
(8,  'Jacket',      'Clothing',    30187.24),
(9,  'Laptop',      'Electronics', 42343.15),
(10, 'Milk 1L',     'Grocery',     43374.39),
(11, 'Saree',       'Clothing',    15000.00),
(12, 'Headphones',  'Electronics', 35000.00),
(13, 'Pulses 1kg',  'Grocery',      8500.00),
(14, 'T-Shirt',     'Clothing',     1200.00),
(15, 'Rice 5kg',    'Grocery',     25000.00),
(16, 'Oil 1L',      'Grocery',      9800.00);

-- ============================================================
-- INSERT: fact_sales (15 cleaned rows from retail_transactions.csv)
-- All dates normalized, NULL cities resolved, categories standardized
-- ============================================================
INSERT INTO fact_sales (sale_id, date_key, store_key, product_key, customer_id, units_sold, unit_price, total_revenue) VALUES
('TXN5000', 20230829, 1,  1,  'CUST045', 3,  49262.78,  147788.34),
('TXN5001', 20231212, 1,  2,  'CUST021', 11, 23226.12,  255487.32),
('TXN5002', 20230205, 1,  3,  'CUST019', 20, 48703.39,  974067.80),
('TXN5003', 20230220, 2,  2,  'CUST007', 14, 23226.12,  325165.68),
('TXN5004', 20230115, 1,  4,  'CUST004', 10, 58851.01,  588510.10),
('TXN5005', 20230809, 3,  5,  'CUST027', 12, 52464.00,  629568.00),
('TXN5006', 20230331, 4,  4,  'CUST025', 6,  58851.01,  353106.06),
('TXN5007', 20231026, 4,  6,  'CUST041', 16, 2317.47,    37079.52),
('TXN5008', 20231208, 3,  7,  'CUST030', 9,  27469.99,  247229.91),
('TXN5009', 20230815, 3,  4,  'CUST020', 3,  58851.01,  176553.03),
('TXN5010', 20230604, 1,  8,  'CUST031', 15, 30187.24,  452808.60),
('TXN5011', 20231020, 5,  6,  'CUST045', 13, 2317.47,    30127.11),
('TXN5012', 20230516, 3,  9,  'CUST044', 13, 42343.15,  550461.00),
('TXN5013', 20230418, 5,  10, 'CUST015', 10, 43374.39,  433743.90),
('TXN5014', 20231118, 2,  8,  'CUST042', 5,  30187.24,  150936.20);
