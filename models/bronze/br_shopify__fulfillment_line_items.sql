{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='fulfillment_line_item_row_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

with fulfillments as (
    select *
    from `mbm-etl.shopify_raw.fulfillments`
    {% if is_incremental() %}
    where safe_cast(updated_at as timestamp) >= (
        select coalesce(max(fulfillment_updated_at), timestamp('1900-01-01'))
        from {{ this }}
    )
    {% endif %}
)

select
    to_hex(md5(concat(cast(f.id as string), '|', cast(line_item_position as string)))) as fulfillment_line_item_row_id,
    cast(f.id as string) as fulfillment_id,
    cast(f.order_id as string) as order_id,
    safe_cast(f.updated_at as timestamp) as fulfillment_updated_at,
    line_item_position,
    cast(JSON_VALUE(li, '$.id') as string) as line_item_id,
    cast(JSON_VALUE(li, '$.product_id') as string) as product_id,
    cast(JSON_VALUE(li, '$.variant_id') as string) as variant_id,
    cast(JSON_VALUE(li, '$.sku') as string) as sku,
    cast(JSON_VALUE(li, '$.name') as string) as line_item_name,
    cast(JSON_VALUE(li, '$.title') as string) as title,
    cast(JSON_VALUE(li, '$.vendor') as string) as vendor,
    safe_cast(JSON_VALUE(li, '$.quantity') as int64) as quantity,
    safe_cast(JSON_VALUE(li, '$.grams') as int64) as grams,
    li as line_item_json
from fulfillments f
left join unnest(ifnull(JSON_QUERY_ARRAY(f.line_items, '$'), cast([] as array<json>))) as li with offset as line_item_position
where li is not null