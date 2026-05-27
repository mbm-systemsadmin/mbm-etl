{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['order_id', 'shipping_line_id'],
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

with orders as (
    select *
    from `mbm-etl.shopify_raw.orders`
    {% if is_incremental() %}
    where safe_cast(updated_at as timestamp) >= (
        select coalesce(max(order_updated_at), timestamp('1900-01-01'))
        from {{ this }}
    )
    {% endif %}
)

select
    cast(o.id as string) as order_id,
    safe_cast(o.updated_at as timestamp) as order_updated_at,
    cast(JSON_VALUE(sl, '$.id') as string) as shipping_line_id,
    cast(JSON_VALUE(sl, '$.title') as string) as title,
    cast(JSON_VALUE(sl, '$.code') as string) as code,
    cast(JSON_VALUE(sl, '$.source') as string) as source,
    safe_cast(JSON_VALUE(sl, '$.price') as numeric) as price,
    safe_cast(JSON_VALUE(sl, '$.discounted_price') as numeric) as discounted_price,
    safe_cast(JSON_VALUE(sl, '$.phone') as string) as phone,
    cast(JSON_VALUE(sl, '$.delivery_category') as string) as delivery_category,
    cast(JSON_VALUE(sl, '$.carrier_identifier') as string) as carrier_identifier
from orders o
left join unnest(ifnull(JSON_EXTRACT_ARRAY(o.shipping_lines), cast([] as array<json>))) as sl
where JSON_VALUE(sl, '$.id') is not null
