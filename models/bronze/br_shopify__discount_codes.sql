{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='discount_code_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as discount_code_id,
    cast(price_rule_id as string) as price_rule_id,
    cast(code as string) as discount_code,
    cast(title as string) as discount_title,
    cast(status as string) as discount_status,
    cast(summary as string) as discount_summary,
    cast(typename as string) as typename,
    cast(discount_type as string) as discount_type,
    safe_cast(usage_count as int64) as usage_count,
    safe_cast(usage_limit as int64) as usage_limit,
    safe_cast(async_usage_count as int64) as async_usage_count,
    safe_cast(applies_once_per_customer as bool) as applies_once_per_customer,
    cast(shop_url as string) as shop_url,
    cast(admin_graphql_api_id as string) as admin_graphql_api_id,
    createdBy as created_by_json,
    codes_count as codes_count_json,
    total_sales as total_sales_json,
    safe_cast(starts_at as timestamp) as starts_at,
    safe_cast(ends_at as timestamp) as ends_at,
    safe_cast(created_at as timestamp) as discount_code_created_at,
    safe_cast(updated_at as timestamp) as discount_code_updated_at
from `mbm-etl.shopify_raw.discount_codes`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(discount_code_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}