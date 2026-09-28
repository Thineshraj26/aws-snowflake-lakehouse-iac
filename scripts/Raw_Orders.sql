USE ROLE ACCOUNTADMIN;
USE WAREHOUSE LAKEHOUSE_WH;
USE DATABASE LAKEHOUSE_DB;

USE SCHEMA BRONZE;

CREATE OR REPLACE TABLE LAKEHOUSE_DB.BRONZE.RAW_ORDERS (
    order_id         VARCHAR,
    customer_id      VARCHAR,
    customer_name    VARCHAR,
    customer_email   VARCHAR,
    customer_country VARCHAR(10),
    category         VARCHAR,
    quantity         INT,
    unit_price       FLOAT,
    total_amount     FLOAT,
    payment_method   VARCHAR,
    order_status     VARCHAR,
    created_at       TIMESTAMP_TZ,
    ingested_at      TIMESTAMP_TZ,
    _raw_file_name   VARCHAR,
    _loaded_at       TIMESTAMP_TZ DEFAULT CURRENT_TIMESTAMP()
);