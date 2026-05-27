{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='discount_application_row_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

with orders as (
    select *
    from `mbm-etl.shopify_raw.orders`
    {% if is_incremental() %}
    where safe_cast(updated_at as timestamp) >= (
        select coalesce(max(order_updated_at), timestamp('1900-01-01'))
        from {{ this }}
    )
    {% endif %}
)

select
    to_hex(md5(concat(
        cast(o.id as string), '|',
        coalesce(JSON_VALUE(d, '$.title'), ''), '|',
        coalesce(JSON_VALUE(d, '$.type'), ''), '|',
        coalesce(JSON_VALUE(d, '$.value'), '')
    ))) as discount_application_row_id,
    cast(o.id as string) as order_id,
    safe_cast(o.updated_at as timestamp) as order_updated_at,
    cast(JSON_VALUE(d, '$.code') as string) as discount_code,
    cast(JSON_VALUE(d, '$.title') as string) as discount_title,
    cast(JSON_VALUE(d, '$.type') as string) as discount_type,
    cast(JSON_VALUE(d, '$.allocation_method') as string) as allocation_method,
    cast(JSON_VALUE(d, '$.target_type') as string) as target_type,
    cast(JSON_VALUE(d, '$.target_selection') as string) as target_selection,
    cast(JSON_VALUE(d, '$.value_type') as string) as value_type,
    safe_cast(JSON_VALUE(d, '$.value') as numeric) as value
from orders o
left join unnest(ifnull(JSON_EXTRACT_ARRAY(o.discount_applications), cast([] as array<json>))) as d
where d is not null
