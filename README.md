# SQL Data Pipeline Project

## Introduction

A SQL-based mini data warehouse project demonstrating an end-to-end data pipeline from raw CSV ingestion to a structured star schema for analysis.

This project demonstrates how raw data can be transformed into an analysis-ready data model using SQL.

The pipeline includes:

- Loading raw data from CSV files
- Cleaning and validating records
- Structuring the data into a star schema for analytical querying

## Pipeline Overview

CSV Files  
↓  
Raw Tables (no transformation)  
↓  
Staging Tables (cleaning & validation)  
↓  
Star Schema (fact + dimension tables)  
↓  
Analytical Queries  

---

## Design Approach

This project uses a layered approach to separate concerns:

- Raw layer preserves original data
- Staging layer handles cleaning and validation
- Final model structures data for analysis

This makes the pipeline easier to debug, maintain, and extend.

---

### 1. Raw Layer

Tables:

- raw_users
- raw_orders
- raw_products

What happens:

- Data is copied directly from the imported CSV tables into raw tables
- No cleaning or validation is applied

Purpose:

- Preserve the original data as a reliable starting point

---

### 2. Staging Layer

Tables:

- stg_users
- stg_orders
- stg_products

What happens:

- Duplicate records are removed using DISTINCT
- Rows with missing key fields (e.g. IDs) are filtered out
- Invalid values are removed (e.g. negative prices or amounts)

Examples:

- Users without a user_id are excluded
- Orders without a user_id or product_id are excluded
- Negative values are filtered out

Purpose:

- Ensure the data is clean, consistent, and usable

---

### 3. Final Model (Star Schema)

Tables:

- dim_user --> user details (who placed orders)
- dim_product --> product details (what was sold)
- fact_order --> order transactions (what orders were placed)

What happens:

- Clean data from staging tables is loaded into structured tables
- Data types are corrected where needed (e.g. converting text to DATE or DECIMAL), as this was missed in the staging layer

---

## Data Model (Star Schema)

The final schema follows a **star schema design**:

- **Fact table (`fact_order`)** --> records transactions/events  
- **Dimension tables (`dim_user`, `dim_product`)** --> provide descriptive context  

This structure simplifies querying and is optimised for analytical workloads.

---

## Relationships

Primary and foreign keys are used to maintain data integrity:

- Primary keys ensure each record is unique (e.g. dim_user.user_id)
- Foreign keys enforce valid relationships (e.g. fact_order.user_id --> dim_user.user_id)

This prevents invalid data, such as orders referencing non-existent users or products.

- fact_order.user_id --> dim_user.user_id
- fact_order.product_id --> dim_product.product_id

These relationships are enforced using foreign keys.

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

When importing the CSV files, some fields (such as dates and numeric values) were automatically loaded as text (`VARCHAR`). This caused issues when inserting into the final model, as the target tables expected proper data types like `DATE` and `DECIMAL`.

**To fix this, I:**

- Used `TRY_CONVERT()` when loading data into the final tables  
- This allowed valid values to be converted, while preventing the process from failing on invalid data  

This reinforced the importance of checking and correcting data types when working with raw data.

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
