{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='customer_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as customer_id,
    cast(email as string) as customer_email,
    cast(phone as string) as customer_phone,
    cast(first_name as string) as first_name,
    cast(last_name as string) as last_name,
    cast(state as string) as customer_state,
    cast(tags as string) as tags,
    cast(currency as string) as currency,
    cast(shop_url as string) as shop_url,
    cast(note as string) as customer_note,
    safe_cast(tax_exempt as bool) as is_tax_exempt,
    safe_cast(verified_email as bool) as is_verified_email,
    safe_cast(accepts_marketing as bool) as accepts_marketing,
    cast(marketing_opt_in_level as string) as marketing_opt_in_level,
    safe_cast(total_spent as numeric) as total_spent,
    safe_cast(orders_count as int64) as orders_count,
    cast(last_order_id as string) as last_order_id,
    cast(last_order_name as string) as last_order_name,
    cast(JSON_VALUE(default_address, '$.id') as string) as default_address_id,
    cast(JSON_VALUE(default_address, '$.city') as string) as default_address_city,
    cast(JSON_VALUE(default_address, '$.province_code') as string) as default_address_province_code,
    cast(JSON_VALUE(default_address, '$.country_code') as string) as default_address_country_code,
    cast(JSON_VALUE(sms_marketing_consent, '$.state') as string) as sms_marketing_state,
    cast(JSON_VALUE(sms_marketing_consent, '$.opt_in_level') as string) as sms_marketing_opt_in_level,
    safe_cast(JSON_VALUE(sms_marketing_consent, '$.consent_updated_at') as timestamp) as sms_marketing_consent_updated_at,
    cast(admin_graphql_api_id as string) as admin_graphql_api_id,
    safe_cast(created_at as timestamp) as customer_created_at,
    safe_cast(updated_at as timestamp) as customer_updated_at
from `mbm-etl.shopify_raw.customers`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(customer_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}