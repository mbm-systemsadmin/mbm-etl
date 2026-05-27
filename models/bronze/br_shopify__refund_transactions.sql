{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['refund_id', 'transaction_id'],
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

with refunds as (
    select *
    from `mbm-etl.shopify_raw.order_refunds`
    {% if is_incremental() %}
    where safe_cast(processed_at as timestamp) >= (
        select coalesce(max(refund_processed_at), timestamp('1900-01-01'))
        from {{ this }}
    )
    {% endif %}
)

select
    cast(r.id as string) as refund_id,
    cast(r.order_id as string) as order_id,
    safe_cast(r.processed_at as timestamp) as refund_processed_at,
    cast(JSON_VALUE(t, '$.id') as string) as transaction_id,
    cast(JSON_VALUE(t, '$.kind') as string) as kind,
    cast(JSON_VALUE(t, '$.status') as string) as status,
    cast(JSON_VALUE(t, '$.gateway') as string) as gateway,
    cast(JSON_VALUE(t, '$.currency') as string) as currency,
    safe_cast(JSON_VALUE(t, '$.amount') as numeric) as amount,
    safe_cast(JSON_VALUE(t, '$.processed_at') as timestamp) as processed_at,
    cast(JSON_VALUE(t, '$.authorization') as string) as authorization
from refunds r
left join unnest(ifnull(JSON_EXTRACT_ARRAY(r.transactions), cast([] as array<json>))) as t
where JSON_VALUE(t, '$.id') is not null
