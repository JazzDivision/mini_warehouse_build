# SQL Data Pipeline Project

## Overview

This project builds a simple SQL data pipeline using a small dataset of users, orders, and products. The goal was to take raw data, clean it, and organise it into a structured format that is easy to query and analyse.

This project takes messy data and turns it into something usable. It does this in three steps:

1. Store the data as-is (raw layer)
2. Clean the data (staging layer)
3. Organise the data into connected tables (final model - star schema)

---

## Step 1: Raw Layer

Tables:

- raw_users
- raw_orders
- raw_products

What took place during this stage:

- Data is loaded directly from CSV files
- No cleaning or validation is applied

Example:

- Dates may be stored as text
- Duplicate rows may exist
- Missing values may exist

Purpose: Capture the original data exactly as it arrives.

---

## Step 2: Staging Layer

Tables:

- stg_users
- stg_orders
- stg_products

What took place during this stage:

- Remove rows with missing IDs
- Remove duplicate records
- Remove invalid values (e.g. negative amounts)
- Keep only usable data

Purpose: Make the data safe to use.

---

## Step 3: Final Model (Star Schema)

Tables:

- dim_user (users)
- dim_product (products)
- fact_order (orders)

### Explanation

Instead of one messy dataset, the data is split into:

- One table for users (who made orders)
- One table for products (what was ordered)
- One table for orders (orders that took place)

The orders table connects to users and products using IDs.

---

## Relationships

- fact_order.user_id → dim_user.user_id
- fact_order.product_id → dim_product.product_id

This ensures:

- Every order belongs to a valid user
- Every order references a valid product

---

## Why This Structure Is Used

This structure makes querying easier. Instead of repeating user and product details in every row:

- They are stored once
- Orders just reference them using IDs

---

## Example Query

```sql
SELECT 
    u.user_name,
    p.product_name,
    f.amount
FROM fact_order AS f
JOIN dim_user AS u
ON f.user_id = u.user_id
JOIN dim_product AS p
ON f.product_id = p.product_id;
