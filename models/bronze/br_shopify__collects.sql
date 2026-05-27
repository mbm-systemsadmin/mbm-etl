{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='collect_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as collect_id,
    cast(collection_id as string) as collection_id,
    cast(product_id as string) as product_id,
    safe_cast(position as int64) as position,
    cast(sort_value as string) as sort_value,
    cast(shop_url as string) as shop_url,
    safe_cast(created_at as timestamp) as collect_created_at,
    safe_cast(updated_at as timestamp) as collect_updated_at
from `mbm-etl.shopify_raw.collects`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(collect_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}