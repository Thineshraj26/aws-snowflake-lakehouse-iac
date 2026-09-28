{{ config(materialized='table', schema='SILVER') }}

with deduplicated_orders as (
    select
        order_id,
        customer_id,
        category,
        quantity,
        unit_price,
        total_amount,
        payment_method,
        order_status,
        created_at as order_timestamp,
        date(created_at) as order_date,
        _raw_file_name,
        _loaded_at,
        row_number() over (partition by order_id order by ingested_at desc) as rn
    from {{ source('bronze', 'raw_orders') }}
)

select
    order_id,
    customer_id,
    category,
    quantity,
    unit_price,
    total_amount,
    payment_method,
    order_status,
    order_timestamp,
    order_date,
    _raw_file_name,
    _loaded_at
from deduplicated_orders
where rn = 1