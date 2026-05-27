{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as order_id,
    safe_cast(number as int64) as order_number,
    cast(name as string) as order_name,
    cast(email as string) as order_email,
    cast(source_name as string) as source_name,
    cast(financial_status as string) as financial_status,
    cast(fulfillment_status as string) as fulfillment_status,
    cast(currency as string) as currency,
    cast(cancel_reason as string) as cancel_reason,
    cast(tags as string) as tags,
    safe_cast(location_id as int64) as location_id,
    safe_cast(total_price as numeric) as total_price,
    safe_cast(subtotal_price as numeric) as subtotal_price,
    safe_cast(total_tax as numeric) as total_tax,
    safe_cast(total_discounts as numeric) as total_discounts,
    cast(JSON_VALUE(customer, '$.id') as string) as customer_id,
    cast(JSON_VALUE(customer, '$.email') as string) as customer_email,
    safe_cast(test as bool) as is_test,
    safe_cast(created_at as timestamp) as created_at,
    safe_cast(updated_at as timestamp) as updated_at,
    safe_cast(processed_at as timestamp) as processed_at,
    safe_cast(cancelled_at as timestamp) as cancelled_at,
    safe_cast(closed_at as timestamp) as closed_at
from `mbm-etl.shopify_raw.orders`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}
