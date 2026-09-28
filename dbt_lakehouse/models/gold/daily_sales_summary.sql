{{ config(materialized='table', schema='GOLD') }}

select
    f.order_date,
    f.category,
    c.customer_country,
    count(distinct f.order_id)            as total_orders,
    count(distinct f.customer_id)         as active_customers,
    sum(f.quantity)                       as total_units_sold,
    round(sum(f.total_amount), 2)         as gross_revenue,
    round(avg(f.total_amount), 2)         as average_order_value,
    count_if(f.order_status = 'RETURNED') as returned_orders
from {{ ref('fct_orders') }} f
left join {{ ref('dim_customers') }} c
    on f.customer_id = c.customer_id
group by
    f.order_date,
    f.category,
    c.customer_country