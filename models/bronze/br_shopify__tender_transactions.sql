{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='tender_transaction_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as tender_transaction_id,
    cast(order_id as string) as order_id,
    cast(user_id as string) as user_id,
    cast(payment_method as string) as payment_method,
    cast(remote_reference as string) as remote_reference,
    cast(currency as string) as currency,
    safe_cast(amount as numeric) as amount,
    safe_cast(test as bool) as is_test,
    cast(JSON_VALUE(payment_details, '$.credit_card_company') as string) as credit_card_company,
    cast(JSON_VALUE(payment_details, '$.payment_method_name') as string) as payment_method_name,
    cast(shop_url as string) as shop_url,
    payment_details as payment_details_json,
    safe_cast(processed_at as timestamp) as tender_processed_at
from `mbm-etl.shopify_raw.tender_transactions`
{% if is_incremental() %}
where safe_cast(processed_at as timestamp) >= (
    select coalesce(max(tender_processed_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}