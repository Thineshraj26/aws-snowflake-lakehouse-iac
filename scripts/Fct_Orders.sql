USE ROLE ACCOUNTADMIN;
USE WAREHOUSE LAKEHOUSE_WH;
USE DATABASE LAKEHOUSE_DB;
USE SCHEMA SILVER;

CREATE OR REPLACE TABLE LAKEHOUSE_DB.SILVER.FCT_ORDERS AS
SELECT 
    order_id,
    customer_id,
    category,
    quantity,
    unit_price,
    total_amount,
    payment_method,
    order_status,
    created_at AS order_timestamp,
    DATE(created_at) AS order_date,
    _raw_file_name,
    _loaded_at
FROM LAKEHOUSE_DB.BRONZE.RAW_ORDERS
QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY ingested_at DESC) = 1;