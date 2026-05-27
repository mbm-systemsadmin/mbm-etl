{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['refund_id', 'order_adjustment_id'],
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
    cast(JSON_VALUE(oa, '$.id') as string) as order_adjustment_id,
    cast(JSON_VALUE(oa, '$.kind') as string) as kind,
    cast(JSON_VALUE(oa, '$.reason') as string) as reason,
    safe_cast(JSON_VALUE(oa, '$.amount') as numeric) as amount,
    safe_cast(JSON_VALUE(oa, '$.tax_amount') as numeric) as tax_amount,
    cast(JSON_VALUE(oa, '$.amount_set.shop_money.currency_code') as string) as shop_money_currency,
    safe_cast(JSON_VALUE(oa, '$.amount_set.shop_money.amount') as numeric) as shop_money_amount,
    cast(JSON_VALUE(oa, '$.amount_set.presentment_money.currency_code') as string) as presentment_currency,
    safe_cast(JSON_VALUE(oa, '$.amount_set.presentment_money.amount') as numeric) as presentment_amount
from refunds r
left join unnest(ifnull(JSON_EXTRACT_ARRAY(r.order_adjustments), cast([] as array<json>))) as oa
where JSON_VALUE(oa, '$.id') is not null
