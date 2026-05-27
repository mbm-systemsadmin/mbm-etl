{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='transaction_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as transaction_id,
    cast(order_id as string) as order_id,
    cast(parent_id as string) as parent_transaction_id,
    cast(user_id as string) as user_id,
    cast(location_id as string) as location_id,
    cast(payment_id as string) as payment_id,
    cast(kind as string) as transaction_kind,
    cast(status as string) as transaction_status,
    cast(gateway as string) as gateway,
    cast(source_name as string) as source_name,
    cast(message as string) as message,
    cast(error_code as string) as error_code,
    cast(authorization as string) as authorization,
    cast(currency as string) as currency,
    safe_cast(amount as numeric) as amount,
    safe_cast(test as bool) as is_test,
    safe_cast(JSON_VALUE(amount_set, '$.shop_money.amount') as numeric) as shop_money_amount,
    cast(JSON_VALUE(amount_set, '$.shop_money.currency_code') as string) as shop_money_currency,
    safe_cast(JSON_VALUE(amount_set, '$.presentment_money.amount') as numeric) as presentment_money_amount,
    cast(JSON_VALUE(amount_set, '$.presentment_money.currency_code') as string) as presentment_money_currency,
    cast(JSON_VALUE(payment_details, '$.credit_card_company') as string) as credit_card_company,
    cast(shop_url as string) as shop_url,
    fees as fees_json,
    receipt as receipt_json,
    payment_details as payment_details_json,
    safe_cast(created_at as timestamp) as transaction_created_at,
    safe_cast(processed_at as timestamp) as transaction_processed_at
from `mbm-etl.shopify_raw.transactions`
{% if is_incremental() %}
where coalesce(safe_cast(processed_at as timestamp), safe_cast(created_at as timestamp)) >= (
    select coalesce(max(coalesce(transaction_processed_at, transaction_created_at)), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}