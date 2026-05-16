-- Creating a staging layer to transform the data into something complete, valid, and ready for modelling (star schema): no duplicates, only valid records & reasonable values

-- Reset the staging tables so they can be re-run without errors 

DROP TABLE IF EXISTS stg_users;
DROP TABLE IF EXISTS stg_products;
DROP TABLE IF EXISTS stg_orders;

-- Creating user staging table in order to remove duplicate users, ensure all users have a valid ID, and prepare clean user data for dimension table

SELECT DISTINCT -- Removes duplicate users 
    user_id,
    user_name,
    onboarding_date
INTO stg_users -- Inserting data into new staging table
FROM raw_users -- Taking data from raw table
WHERE user_id IS NOT NULL; -- Removing NULLs so that all users can be identified 

-- Creating a staging products table to remove duplicate products, ensure valid product IDs and prices, and prevent invalid data e.g. negative prices 

SELECT DISTINCT
    product_id,
    product_name,
    prod_category,
    price
INTO stg_products
FROM raw_products
WHERE product_id IS NOT NULL -- Products must exist
    AND price >= 0; -- Ensures prices are not negative 

-- Creating a staging orders table to ensure orders are completed/valid, remove rows with missing key relationships, and prepare reliable data for fact table

SELECT
    order_id,
    user_id,
    product_id,
    order_date,
    amount
INTO stg_orders
FROM raw_orders
WHERE order_id IS NOT NULL -- Every order must exist 
    AND user_id IS NOT NULL -- Every order must belong to a user 
    AND product_id IS NOT NULL -- Every order must relate to a product
    AND amount IS NOT NULL -- Amounts must be present for analysis 
    AND amount >= 0; -- Ensures amounts are not negative 

-- Removes bad data (NULLs, negative values)
-- Deduplicates users/products
-- Prepares clean dataset for star schema