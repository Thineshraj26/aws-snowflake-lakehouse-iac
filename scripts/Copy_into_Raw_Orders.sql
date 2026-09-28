USE ROLE ACCOUNTADMIN;
USE WAREHOUSE LAKEHOUSE_WH;
USE DATABASE LAKEHOUSE_DB;
USE SCHEMA BRONZE;

COPY INTO LAKEHOUSE_DB.BRONZE.RAW_ORDERS (
    order_id,
    customer_id,
    customer_name,
    customer_email,
    customer_country,
    category,
    quantity,
    unit_price,
    total_amount,
    payment_method,
    order_status,
    created_at,
    ingested_at,
    _raw_file_name
)
FROM (
    SELECT 
        $1:order_id::STRING,
        $1:customer_id::STRING,
        $1:customer_name::STRING,
        $1:customer_email::STRING,
        $1:customer_country::STRING,
        $1:category::STRING,
        $1:quantity::INT,
        $1:unit_price::FLOAT,
        $1:total_amount::FLOAT,
        $1:payment_method::STRING,
        $1:order_status::STRING,
        $1:created_at::TIMESTAMP_TZ,
        $1:ingested_at::TIMESTAMP_TZ,
        METADATA$FILENAME
    FROM @s3_raw_stage
)
FILE_FORMAT = (TYPE = 'PARQUET')
ON_ERROR = 'CONTINUE';