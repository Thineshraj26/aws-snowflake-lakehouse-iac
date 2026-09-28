USE ROLE ACCOUNTADMIN;
USE WAREHOUSE LAKEHOUSE_WH;
USE DATABASE LAKEHOUSE_DB;
USE SCHEMA GOLD;

CREATE OR REPLACE TABLE LAKEHOUSE_DB.GOLD.DAILY_SALES_SUMMARY AS
SELECT 
    f.order_date,
    f.category,
    c.customer_country,
    COUNT(DISTINCT f.order_id)            AS total_orders,
    COUNT(DISTINCT f.customer_id)         AS active_customers,
    SUM(f.quantity)                       AS total_units_sold,
    ROUND(SUM(f.total_amount), 2)         AS gross_revenue,
    ROUND(AVG(f.total_amount), 2)         AS average_order_value,
    COUNT_IF(f.order_status = 'RETURNED') AS returned_orders
FROM LAKEHOUSE_DB.SILVER.FCT_ORDERS f
LEFT JOIN LAKEHOUSE_DB.SILVER.DIM_CUSTOMERS c
    ON f.customer_id = c.customer_id
GROUP BY 
    f.order_date,
    f.category,
    c.customer_country;