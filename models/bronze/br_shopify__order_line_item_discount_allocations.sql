{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['order_id', 'line_item_id', 'discount_application_index'],
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
    cast(JSON_VALUE(li, '$.id') as string) as line_item_id,
    safe_cast(JSON_VALUE(da, '$.discount_application_index') as int64) as discount_application_index,
    safe_cast(JSON_VALUE(da, '$.amount') as numeric) as amount,
    cast(JSON_VALUE(da, '$.amount_set.shop_money.currency_code') as string) as shop_money_currency,
    safe_cast(JSON_VALUE(da, '$.amount_set.shop_money.amount') as numeric) as shop_money_amount,
    cast(JSON_VALUE(da, '$.amount_set.presentment_money.currency_code') as string) as presentment_currency,
    safe_cast(JSON_VALUE(da, '$.amount_set.presentment_money.amount') as numeric) as presentment_amount
from orders o
left join unnest(ifnull(JSON_EXTRACT_ARRAY(o.line_items), cast([] as array<json>))) as li
left join unnest(ifnull(JSON_EXTRACT_ARRAY(li, '$.discount_allocations'), cast([] as array<json>))) as da
where JSON_VALUE(li, '$.id') is not null
