{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='location_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as location_id,
    cast(name as string) as location_name,
    cast(phone as string) as phone,
    safe_cast(active as bool) as is_active,
    safe_cast(legacy as bool) as is_legacy,
    cast(address1 as string) as address1,
    cast(address2 as string) as address2,
    cast(city as string) as city,
    cast(province as string) as province,
    cast(province_code as string) as province_code,
    cast(country as string) as country,
    cast(country_code as string) as country_code,
    cast(country_name as string) as country_name,
    cast(zip as string) as postal_code,
    cast(localized_country_name as string) as localized_country_name,
    cast(localized_province_name as string) as localized_province_name,
    cast(shop_url as string) as shop_url,
    cast(admin_graphql_api_id as string) as admin_graphql_api_id,
    safe_cast(created_at as timestamp) as location_created_at,
    safe_cast(updated_at as timestamp) as location_updated_at
from `mbm-etl.shopify_raw.locations`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(location_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}