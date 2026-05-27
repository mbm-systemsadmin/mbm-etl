{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='inventory_item_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as inventory_item_id,
    cast(sku as string) as sku,
    safe_cast(cost as numeric) as cost,
    safe_cast(tracked as bool) as is_tracked,
    safe_cast(requires_shipping as bool) as requires_shipping,
    safe_cast(duplicate_sku_count as int64) as duplicate_sku_count,
    cast(currency_code as string) as currency_code,
    cast(country_code_of_origin as string) as country_code_of_origin,
    cast(province_code_of_origin as string) as province_code_of_origin,
    cast(harmonized_system_code as string) as harmonized_system_code,
    cast(shop_url as string) as shop_url,
    cast(admin_graphql_api_id as string) as admin_graphql_api_id,
    country_harmonized_system_codes as country_harmonized_system_codes_json,
    safe_cast(created_at as timestamp) as inventory_item_created_at,
    safe_cast(updated_at as timestamp) as inventory_item_updated_at
from `mbm-etl.shopify_raw.inventory_items`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(inventory_item_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}