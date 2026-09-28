{{ config(materialized='table', schema='SILVER') }}

with ranked_customers as (
    select
        customer_id,
        customer_name,
        customer_email,
        customer_country,
        min(created_at) over (partition by customer_id) as first_order_at,
        max(created_at) over (partition by customer_id) as last_order_at,
        row_number() over (partition by customer_id order by created_at desc) as rn
    from {{ source('bronze', 'raw_orders') }}
    where customer_id is not null
)

select
    customer_id,
    customer_name,
    customer_email,
    customer_country,
    first_order_at,
    last_order_at,
    current_timestamp() as dwh_updated_at
from ranked_customers
where rn = 1