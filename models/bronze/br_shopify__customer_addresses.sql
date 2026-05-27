{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='customer_address_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as customer_address_id,
    cast(customer_id as string) as customer_id,
    cast(first_name as string) as first_name,
    cast(last_name as string) as last_name,
    cast(name as string) as full_name,
    cast(company as string) as company,
    cast(phone as string) as phone,
    cast(address1 as string) as address1,
    cast(address2 as string) as address2,
    cast(city as string) as city,
    cast(province as string) as province,
    cast(province_code as string) as province_code,
    cast(country as string) as country,
    cast(country_code as string) as country_code,
    cast(country_name as string) as country_name,
    cast(zip as string) as postal_code,
    safe_cast(`default` as bool) as is_default_address,
    cast(shop_url as string) as shop_url,
    safe_cast(updated_at as timestamp) as customer_address_updated_at
from `mbm-etl.shopify_raw.customer_address`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(customer_address_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}