{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='event_detailed_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as event_detailed_id,
    cast(type as string) as event_type,
    safe_cast(datetime as timestamp) as event_datetime,
    cast(JSON_VALUE(attributes, '$.name') as string) as event_name,
    cast(JSON_VALUE(attributes, '$.status') as string) as event_status,
    links as links_json,
    attributes as attributes_json,
    relationships as relationships_json
from `mbm-etl.shopify_raw.events_detailed`
{% if is_incremental() %}
where safe_cast(datetime as timestamp) >= (
    select coalesce(max(event_datetime), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}