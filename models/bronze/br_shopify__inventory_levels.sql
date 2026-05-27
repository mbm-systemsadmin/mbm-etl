{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='inventory_level_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as inventory_level_id,
    cast(inventory_item_id as string) as inventory_item_id,
    cast(location_id as string) as location_id,
    safe_cast(available as int64) as available_quantity,
    safe_cast(can_deactivate as bool) as can_deactivate,
    cast(deactivation_alert as string) as deactivation_alert,
    cast(inventory_history_url as string) as inventory_history_url,
    cast(shop_url as string) as shop_url,
    cast(admin_graphql_api_id as string) as admin_graphql_api_id,
    quantities as quantities_json,
    locations_count as locations_count_json,
    safe_cast(created_at as timestamp) as inventory_level_created_at,
    safe_cast(updated_at as timestamp) as inventory_level_updated_at
from `mbm-etl.shopify_raw.inventory_levels`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(inventory_level_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}