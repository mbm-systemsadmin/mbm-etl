{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_risk_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as order_risk_id,
    cast(order_id as string) as order_id,
    cast(checkout_id as string) as checkout_id,
    safe_cast(score as numeric) as risk_score,
    cast(source as string) as risk_source,
    safe_cast(display as bool) as is_displayed,
    safe_cast(cause_cancel as bool) as should_cause_cancel,
    cast(message as string) as message,
    cast(recommendation as string) as recommendation,
    cast(merchant_message as string) as merchant_message,
    cast(shop_url as string) as shop_url,
    cast(admin_graphql_api_id as string) as admin_graphql_api_id,
    assessments as assessments_json,
    safe_cast(updated_at as timestamp) as risk_updated_at
from `mbm-etl.shopify_raw.order_risks`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(risk_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}