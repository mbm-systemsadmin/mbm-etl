{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['order_id', 'line_item_id'],
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
    safe_cast(o.number as int64) as order_number,
    safe_cast(o.updated_at as timestamp) as order_updated_at,
    safe_cast(o.processed_at as timestamp) as order_processed_at,
    cast(JSON_VALUE(li, '$.id') as string) as line_item_id,
    cast(JSON_VALUE(li, '$.name') as string) as line_item_name,
    cast(JSON_VALUE(li, '$.sku') as string) as sku,
    cast(JSON_VALUE(li, '$.title') as string) as title,
    cast(JSON_VALUE(li, '$.vendor') as string) as vendor,
    cast(JSON_VALUE(li, '$.product_id') as string) as product_id,
    cast(JSON_VALUE(li, '$.variant_id') as string) as variant_id,
    safe_cast(JSON_VALUE(li, '$.quantity') as int64) as quantity,
    safe_cast(JSON_VALUE(li, '$.price') as numeric) as unit_price,
    safe_cast(JSON_VALUE(li, '$.total_discount') as numeric) as line_total_discount,
    safe_cast(JSON_VALUE(li, '$.grams') as int64) as grams,
    safe_cast(JSON_VALUE(li, '$.taxable') as bool) as is_taxable,
    safe_cast(JSON_VALUE(li, '$.gift_card') as bool) as is_gift_card,
    cast(JSON_VALUE(li, '$.fulfillment_status') as string) as line_fulfillment_status,
    li as line_item_json
from orders o
left join unnest(ifnull(JSON_EXTRACT_ARRAY(o.line_items), cast([] as array<json>))) as li
where JSON_VALUE(li, '$.id') is not null
