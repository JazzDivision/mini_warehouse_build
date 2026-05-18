-- Practice queries on mini warehouse build 

-- Basic table checks 

-- Q1: How many total orders are there? 
SELECT COUNT(order_id) AS total_order_count
FROM fact_order;

-- Q2: What is the total revenue?
SELECT SUM(amount) AS total_revenue 
FROM fact_order;

-- Q3: Show the top 10 orders by value
SELECT TOP 10 order_id, amount AS top_10_by_value
FROM fact_order
ORDER BY amount DESC;

-- Dimension lookups 

-- Q1: List all users
SELECT user_id, user_name AS users
FROM dim_user;

-- Q2: List all products & prices DESC 
SELECT product_name, price
FROM dim_product
ORDER BY price DESC;

-- Joins 

-- Q1: Show each order with the user name 
SELECT 
    u.user_name,
    f.order_id,
    p.product_name
FROM fact_order AS f
INNER JOIN dim_user AS u
ON f.user_id = u.user_id
INNER JOIN dim_product AS p
ON f.product_id = p.product_id;

-- Q2: Show each order with product name and price
SELECT 
    u.user_name,
    f.order_id,
    p.product_name,
    p.price
FROM fact_order AS f
INNER JOIN dim_user AS u
ON f.user_id = u.user_id
INNER JOIN dim_product AS p
ON f.product_id = p.product_id;

-- Q3: Show full order detail (user + product + order data) 
SELECT
    u.user_id,
    u.user_name,
    p.product_name,
    p.prod_category,
    f.order_id,
    f.order_date,
    f.amount
FROM fact_order AS f 
INNER JOIN dim_user AS u 
ON f.user_id = u.user_id
INNER JOIN dim_product AS p 
ON f.product_id = p.product_id;

-- In this result set, NULLs were discovered in the order_date field where some TRY_CONVERT(DATE) attempts failed (then became NULL) in staging. What should I do? 

-- Option 1: Leave as is and accept presence of NULLs 
-- Option 2: Filter it out in results using 'WHERE f.order_date IS NOT NULL' 
-- Option 3: Investigate further 

-- Further investigation of orders with NULL dates 
SELECT *
FROM fact_order
WHERE order_date IS NULL;

-- Practice queries cont.

-- Q1: Earliest and latest order dates
SELECT
    MIN(order_date) AS earliest_order_date,
    MAX (order_date) AS latest_order_date
FROM fact_order
WHERE order_date IS NOT NULL;

-- Q2: Count how many unique users have placed orders
SELECT
    COUNT(DISTINCT user_id) AS unique_users
FROM fact_order;

-- Q3: Count products ordered at least once 
SELECT
    COUNT(DISTINCT product_id)
FROM fact_order;

-- Q4: Number of orders per user 
SELECT
    u.user_name,
    COUNT(f.order_id) AS orders_placed
FROM fact_order AS f
INNER JOIN dim_user AS u 
ON f.user_id = u.user_id
GROUP BY u.user_name;

-- Simplified version of above 
SELECT
    user_id,
    COUNT(order_id) AS order_count -- Will count order_ids that are not NULL, while COUNT(*) will count all rows including NULLs 
FROM fact_order  
GROUP BY user_id;

-- Product with the highest total revenue 
SELECT TOP 1
    p.product_name,
    SUM(f.amount) AS revenue_per_product
FROM fact_order AS f
INNER JOIN dim_product AS p
ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue_per_product DESC;

-- Total revenue per product 
SELECT
    p.product_name,
    SUM(f.amount) AS revenue_per_product
FROM fact_order AS f
INNER JOIN dim_product AS p
ON f.product_id = p.product_id
GROUP BY p.product_name;

-- Users who placed at least 2 orders
SELECT
    u.user_name,
    COUNT(f.order_id)
FROM fact_order AS f 
INNER JOIN dim_user AS u 
ON f.user_id = u.user_id
GROUP BY u.user_name
HAVING COUNT(f.order_id) >= 2;

-- Number of unique products ordered per user 
SELECT
    user_id,
    COUNT(DISTINCT product_id) AS unique_products_ordered
FROM fact_order
GROUP BY user_id;

-- Products that have never been ordered
SELECT p.product_name
FROM dim_product p
LEFT JOIN fact_order f 
ON p.product_id = f.product_id
WHERE f.product_id IS NULL; -- Keeps only rows where there was no match in fact_order, as unmatched rows would otherwise show as NULL