{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(order_id as string) as order_id,
    cast(shop_url as string) as shop_url,
    cast(admin_graphql_api_id as string) as admin_graphql_api_id,
    customer_journey_summary as customer_journey_summary_json,
    safe_cast(created_at as timestamp) as customer_journey_created_at,
    safe_cast(updated_at as timestamp) as customer_journey_updated_at
from `mbm-etl.shopify_raw.customer_journey_summary`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(customer_journey_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}