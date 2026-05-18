-- Allows for re-run without errors

DROP TABLE IF EXISTS fact_order;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_user;

-- Creating the user dimension table (who placed orders)

CREATE TABLE dim_user (
    user_id INT NOT NULL,
    user_name NVARCHAR(100) NOT NULL,
    onboarding_date DATE NULL,
    CONSTRAINT pk_dim_user PRIMARY KEY (user_id)
);

-- Load users data into users dimension table, from the raw staging table

INSERT INTO dim_user (user_id, user_name, onboarding_date)
SELECT DISTINCT
    user_id,
    user_name,
    TRY_CONVERT(DATE, onboarding_date) -- Converts valid text dates & invalid ones become NULL
FROM stg_users
WHERE user_id IS NOT NULL;

-- Creating the products dimension table (what was sold) 

CREATE TABLE dim_product (
    product_id INT NOT NULL,
    product_name NVARCHAR(100) NOT NULL,
    prod_category NVARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NULL,
    CONSTRAINT pk_dim_product PRIMARY KEY (product_id)
);

-- Loading product data into the products dimension table, from the raw staging table

INSERT INTO dim_product (product_id, product_name, prod_category, price)
SELECT DISTINCT
    product_id,
    product_name,
    prod_category,
    TRY_CONVERT(DECIMAL(10,2), price) AS price
FROM stg_products
WHERE product_id IS NOT NULL;

-- Creating the orders fact table (the event - orders that were made)

CREATE TABLE fact_order (
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    order_date DATE NULL,
    amount DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_fact_order PRIMARY KEY (order_id)
);

INSERT INTO fact_order (order_id, user_id, product_id, order_date, amount)
SELECT
    order_id,
    user_id,
    product_id,
    TRY_CONVERT(DATE, order_date) AS order_date,
    TRY_CONVERT(DECIMAL(10,2), amount) AS amount
FROM stg_orders
WHERE order_id IS NOT NULL
  AND user_id  IS NOT NULL
  AND product_id IS NOT NULL
  AND TRY_CONVERT(DECIMAL(10,2), amount) IS NOT NULL;

-- Adding FKs after data is loaded to make things simpler/more readable personally

ALTER TABLE fact_order
ADD CONSTRAINT fk_fact_order_user
FOREIGN KEY (user_id) REFERENCES dim_user(user_id);

ALTER TABLE fact_order
ADD CONSTRAINT fk_fact_order_product
FOREIGN KEY (product_id) REFERENCES dim_product(product_id);
