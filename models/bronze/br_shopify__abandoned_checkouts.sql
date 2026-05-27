{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='abandoned_checkout_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as abandoned_checkout_id,
    cast(name as string) as checkout_name,
    cast(email as string) as checkout_email,
    cast(phone as string) as checkout_phone,
    cast(note as string) as checkout_note,
    cast(token as string) as checkout_token,
    cast(cart_token as string) as cart_token,
    cast(source as string) as source,
    cast(source_name as string) as source_name,
    cast(source_url as string) as source_url,
    cast(landing_site as string) as landing_site,
    cast(gateway as string) as gateway,
    cast(currency as string) as currency,
    cast(shop_url as string) as shop_url,
    cast(user_id as string) as user_id,
    cast(device_id as string) as device_id,
    cast(location_id as string) as location_id,
    cast(JSON_VALUE(customer, '$.id') as string) as customer_id,
    cast(JSON_VALUE(customer, '$.email') as string) as customer_email,
    safe_cast(total_price as numeric) as total_price,
    safe_cast(total_tax as numeric) as total_tax,
    array_length(ifnull(JSON_QUERY_ARRAY(line_items, '$'), cast([] as array<json>))) as line_items_count,
    safe_cast(created_at as timestamp) as abandoned_checkout_created_at,
    safe_cast(updated_at as timestamp) as abandoned_checkout_updated_at,
    safe_cast(completed_at as timestamp) as completed_at,
    safe_cast(closed_at as timestamp) as closed_at
from `mbm-etl.shopify_raw.abandoned_checkouts`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(abandoned_checkout_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}