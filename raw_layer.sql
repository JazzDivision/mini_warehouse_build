-- As SQL Online Aide auto-creates tables when importing CSV files, I manually created raw tables out of them to copy my raw data into a starting point
-- Raw layer = untrusted data from source

SELECT * -- Copying everything
INTO raw_users -- Creating the new raw table
FROM users; -- From the original csv 

SELECT * 
INTO raw_orders
FROM orders;

SELECT * 
INTO raw_products
FROM products;
