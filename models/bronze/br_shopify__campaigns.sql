{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='campaign_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as campaign_id,
    cast(type as string) as campaign_type,
    cast(JSON_VALUE(attributes, '$.name') as string) as campaign_name,
    cast(JSON_VALUE(attributes, '$.status') as string) as campaign_status,
    links as links_json,
    attributes as attributes_json,
    relationships as relationships_json,
    safe_cast(updated_at as timestamp) as campaign_updated_at
from `mbm-etl.shopify_raw.campaigns`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(campaign_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}