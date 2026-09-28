USE ROLE ACCOUNTADMIN;
USE WAREHOUSE LAKEHOUSE_WH;
USE DATABASE LAKEHOUSE_DB;
USE SCHEMA SILVER;

CREATE OR REPLACE TABLE LAKEHOUSE_DB.SILVER.DIM_CUSTOMERS AS
SELECT 
    customer_id,
    customer_name,
    customer_email,
    customer_country,
    first_order_at,
    last_order_at,
    CURRENT_TIMESTAMP() AS dwh_updated_at
FROM (
    SELECT 
        customer_id,
        customer_name,
        customer_email,
        customer_country,
        MIN(created_at) OVER (PARTITION BY customer_id) AS first_order_at,
        MAX(created_at) OVER (PARTITION BY customer_id) AS last_order_at,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at DESC) AS rn
    FROM LAKEHOUSE_DB.BRONZE.RAW_ORDERS
    WHERE customer_id IS NOT NULL
)
WHERE rn = 1;