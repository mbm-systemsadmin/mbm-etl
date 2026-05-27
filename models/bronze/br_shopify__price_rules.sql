{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='price_rule_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as price_rule_id,
    cast(title as string) as title,
    safe_cast(value as numeric) as value,
    cast(value_type as string) as value_type,
    cast(target_type as string) as target_type,
    cast(target_selection as string) as target_selection,
    cast(allocation_method as string) as allocation_method,
    cast(customer_selection as string) as customer_selection,
    safe_cast(usage_limit as int64) as usage_limit,
    safe_cast(allocation_limit as int64) as allocation_limit,
    safe_cast(once_per_customer as bool) as once_per_customer,
    cast(shop_url as string) as shop_url,
    cast(admin_graphql_api_id as string) as admin_graphql_api_id,
    entitled_country_ids as entitled_country_ids_json,
    entitled_product_ids as entitled_product_ids_json,
    entitled_variant_ids as entitled_variant_ids_json,
    entitled_collection_ids as entitled_collection_ids_json,
    prerequisite_product_ids as prerequisite_product_ids_json,
    prerequisite_variant_ids as prerequisite_variant_ids_json,
    safe_cast(starts_at as timestamp) as starts_at,
    safe_cast(ends_at as timestamp) as ends_at,
    safe_cast(created_at as timestamp) as price_rule_created_at,
    safe_cast(updated_at as timestamp) as price_rule_updated_at,
    safe_cast(deleted_at as timestamp) as price_rule_deleted_at
from `mbm-etl.shopify_raw.price_rules`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(price_rule_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}