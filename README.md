# SQL Data Pipeline Project

## Introduction

A SQL-based mini data warehouse project demonstrating an end-to-end data pipeline, from raw CSV ingestion to a structured star schema for analysis.

I built this project to deepen my understanding of data warehousing concepts, particularly relationships between tables (using foreign keys), and how star schemas allow for optimised querying and analysis. I also wanted to practice moving data through an engineering pipeline, in addition to separating it into layers within the database.

The pipeline includes:

- Loading raw data from CSV files (raw layer)
- Cleaning and validating records (staging layer)
- Structuring the data into a star schema for analytical querying (output layer)

## Pipeline Overview

CSV files  
↓  
Raw tables (no transformation)  
↓  
Staging tables (cleaning & validation)  
↓  
Star schema (fact + dimension tables)  
↓  
Analytical queries  

---

## Design Approach

This project uses a layered approach to separate concerns:

- Raw layer preserves original data
- Staging layer handles cleaning and validation
- Final model (star schema) structures data for analysis

This makes the pipeline easier to debug, maintain, and extend.

---

## 1. Raw Layer

The first step in this project involved creating a raw layer within the database, where source data was loaded and kept as-is as a consolidated, reliable starting point that can be referred back to.

As SQL Online IDE auto-creates tables when importing CSVs, I manually copied the data from them into new ones explicitly labelled as raw tables:

- raw_users
- raw_orders
- raw_products

---

## 2. Staging Layer

As part of the warehouse design, staging tables were created to prepare raw data for reliable use in downstream modelling.

The purpose of the staging layer was to:

- Remove duplicate records
- Ensure key fields are present e.g. IDs
- Filter out invalid data
- Standardise the structure before loading into final tables

Each staging table was built directly from its corresponding raw table.

---

### Users Staging

The `stg_users` table was created from `raw_users` to ensure user data was clean and usable.

This included:

- Removing duplicate user records using DISTINCT
- Filtering out rows where `user_id` is NULL
- Retaining only essential fields required for downstream use e.g. user_name

This ensures all users can be uniquely identified and safely joined to other tables.

---

### Products Staging

The `stg_products` table was created from `raw_products` to clean and validate product data.

This included:

- Removing duplicate products using DISTINCT
- Filtering out NULL product IDs
- Ensuring prices are valid (non-negative)

This prevents invalid or unrealistic values from affecting analysis.

---

### Orders Staging

The `stg_orders` table was created from `raw_orders` to ensure only valid transactions are included.

This included:

- Removing rows with missing key fields (order_id, user_id, product_id)
- Filtering out NULL or negative amounts
- Ensuring each order can be linked to both a valid user and product

This prepares the data to be safely used in a fact table.

---

## Final Tables (Dimensional Model)

Following the staging layer, the cleaned data is loaded into final tables designed for analysis.

This layer separates data into:

- Dimension tables (descriptive data)
- A fact table (event data)

This structure allows for reliable joins and supports typical analytical query patterns.

---

### User Dimension (`dim_user`)

The `dim_user` table stores information about users who placed orders.

This includes:

- `user_id` (primary key)
- `user_name`
- `onboarding_date`

During loading:

- Duplicate records are removed using DISTINCT
- `user_id` is enforced as NOT NULL to ensure reliable joins
- `TRY_CONVERT` is used to safely convert date values, with invalid values defaulting to NULL

This ensures each user is uniquely identifiable and can be linked to orders.

---

### Product Dimension (`dim_product`)

The `dim_product` table stores information about products.

This includes:

- `product_id` (primary key)
- `product_name`
- `prod_category`
- `price`

During loading:

- Duplicate records are removed
- `product_id` is enforced as NOT NULL
- `TRY_CONVERT` is used to ensure prices are stored in a numeric format
- Invalid values are handled safely without breaking the pipeline

This ensures product data is consistent and suitable for reporting.

---

### Orders Fact Table (`fact_order`)

The `fact_order` table represents the core event in the dataset — orders placed by users.

This includes:

- `order_id` (primary key)
- `user_id` (foreign key)
- `product_id` (foreign key)
- `order_date`
- `amount`

During loading:

- Rows with missing key relationships are removed
- `TRY_CONVERT` is used to validate dates and numeric values
- Invalid or NULL amounts are excluded to ensure accurate analysis

---

### Relationships

Foreign key constraints were added *after* loading the data to simplify the loading process and avoid insert failures, then enforce relationships once the data was in place. Personally, I also find it to be more easily readable/cleaner in the script.

- `fact_order.user_id --> dim_user.user_id`
- `fact_order.product_id --> dim_product.product_id`

These constraints ensure:

- All orders relate to a valid user and product
- Data integrity is maintained across the model

This layer transforms cleaned staging data into a structured, query-ready format.

The separation into dimension and fact tables:

- Supports efficient joins
- Improves data clarity
- Aligns with common data warehousing practices

The overall approach ensures that data is both reliable and easy to analyse.

---

## Skills Demonstrated

- SQL data transformation
- Data cleaning and validation
- ETL concepts (Extract, Transform, Load)
- Data modelling (star schema)
- Use of primary and foreign keys
- Pipeline design (layered architecture)

---

## Key Concepts & Learnings

- How to load and structure data in SQL
- How to clean and validate raw datasets
- The importance of data types (e.g. converting text to DATE)
- How primary and foreign keys enforce data integrity
- How to organise data into a simple analytical model (star schema)
- Star schemas simplify analytical queries and reduce redundancy
- Data quality must be validated before enforcing relationships

---

## Challenges I Faced

### 1. Data Types from CSV Imports

When importing the CSV files, some fields (such as dates) were automatically loaded as text (`VARCHAR`). This caused issues when inserting into the final model, as the target tables expected proper data types like `DATE` and `DECIMAL`.

**To fix this:**

- Used `TRY_CONVERT()` when loading data into the final tables  
- This allowed valid values to be converted, while preventing the process from failing on invalid data  

This reinforced the importance of checking and correcting data types when working with raw data. In future, I would take extra care to catch this during staging.

---

### Additional Data Validation Observation

While querying the final model, I identified **NULL values in the `order_date` column** within the `fact_order` table.

This occurred because:

- Some source data contained missing or invalid date values  
- During transformation, `TRY_CONVERT()` returned `NULL` for any values that could not be converted to a valid `DATE`  

This highlights an important aspect of data engineering:

- Not all source data is clean or valid  
- Pipelines should handle invalid data without breaking  
- Additional validation or filtering may be required depending on business needs  

In a production scenario, these records could be:

- Filtered out  
- Flagged for further investigation  
- Or handled based on business requirements

---

### 2. Understanding and Applying Keys

Initially, I found it difficult to understand how primary keys and foreign keys worked in practice. Through building the model, I learned that:

- Primary keys ensure each row is unique and identifiable
- Foreign keys enforce relationships between tables and prevent invalid references

For example:

- Each user in `dim_user` must have a unique `user_id`
- Each order in `fact_order` must reference a valid user and product

This helped me understand how databases maintain data integrity.

---

### 3. Handling Invalid or Incomplete Data

The raw data contained:

- Missing IDs
- Duplicate records
- Invalid values (e.g. negative amounts)

These issues would cause problems later when applying keys or running queries.

To address this:

- Filtered out rows with NULL IDs
- Removed duplicates using DISTINCT
- Applied validation rules (e.g. amount >= 0)

This showed how important it is to clean data before building relationships.

---

### 4. Building and Understanding the Star Schema

I initially found the concept of a star schema difficult, as it introduced new terminology - such as fact and dimension tables.

By implementing it step by step, I understood that:

- The fact table represents events (orders)
- Dimension tables provide descriptive context (users and products)
- The structure makes queries clearer and avoids repeating data

This helped me move from simple joins to a more structured approach to organising data.

---

### 5. Ordering the Pipeline Steps Correctly

I also encountered issues when trying to apply relationships before the data was fully prepared.

For example:

- Foreign key constraints would fail if the referenced data had not been loaded yet

I resolved this by:

- Loading dimension tables first
- Loading the fact table afterwards
- Adding foreign keys only after the data was successfully inserted

This improved my understanding of how data pipelines need to be built in the correct sequence.

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
