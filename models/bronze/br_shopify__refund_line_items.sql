{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['refund_id', 'refund_line_item_id'],
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

with refunds as (
    select *
    from `mbm-etl.shopify_raw.order_refunds`
    {% if is_incremental() %}
    where safe_cast(processed_at as timestamp) >= (
        select coalesce(max(refund_processed_at), timestamp('1900-01-01'))
        from {{ this }}
    )
    {% endif %}
)

select
    cast(r.id as string) as refund_id,
    cast(r.order_id as string) as order_id,
    safe_cast(r.processed_at as timestamp) as refund_processed_at,
    cast(JSON_VALUE(ri, '$.id') as string) as refund_line_item_id,
    cast(JSON_VALUE(ri, '$.line_item.id') as string) as line_item_id,
    cast(JSON_VALUE(ri, '$.line_item.sku') as string) as sku,
    cast(JSON_VALUE(ri, '$.line_item.title') as string) as title,
    cast(JSON_VALUE(ri, '$.line_item.product_id') as string) as product_id,
    cast(JSON_VALUE(ri, '$.line_item.variant_id') as string) as variant_id,
    safe_cast(JSON_VALUE(ri, '$.quantity') as int64) as quantity,
    safe_cast(JSON_VALUE(ri, '$.subtotal') as numeric) as subtotal,
    safe_cast(JSON_VALUE(ri, '$.total_tax') as numeric) as total_tax,
    cast(JSON_VALUE(ri, '$.restock_type') as string) as restock_type
from refunds r
left join unnest(ifnull(JSON_QUERY_ARRAY(r.refund_line_items, '$'), cast([] as array<json>))) as ri
where JSON_VALUE(ri, '$.id') is not null
