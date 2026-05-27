{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='refund_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as refund_id,
    cast(order_id as string) as order_id,
    cast(note as string) as refund_note,
    safe_cast(restock as bool) as is_restock,
    cast(user_id as string) as user_id,
    cast(shop_url as string) as shop_url,
    safe_cast(created_at as timestamp) as refund_created_at,
    safe_cast(processed_at as timestamp) as refund_processed_at,
    cast(JSON_VALUE(return, '$.id') as string) as return_id,
    cast(JSON_VALUE(return, '$.status') as string) as return_status,
    cast(JSON_VALUE(return, '$.name') as string) as return_name,
    safe_cast(JSON_VALUE(total_duties_set, '$.shop_money.amount') as numeric) as shop_total_duties_amount,
    cast(JSON_VALUE(total_duties_set, '$.shop_money.currency_code') as string) as shop_total_duties_currency,
    safe_cast(JSON_VALUE(total_duties_set, '$.presentment_money.amount') as numeric) as presentment_total_duties_amount,
    cast(JSON_VALUE(total_duties_set, '$.presentment_money.currency_code') as string) as presentment_total_duties_currency,
    cast(admin_graphql_api_id as string) as admin_graphql_api_id
from `mbm-etl.shopify_raw.order_refunds`
{% if is_incremental() %}
where coalesce(safe_cast(processed_at as timestamp), safe_cast(created_at as timestamp)) >= (
    select coalesce(max(coalesce(refund_processed_at, refund_created_at)), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}