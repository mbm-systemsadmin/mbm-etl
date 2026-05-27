{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='fulfillment_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as fulfillment_id,
    cast(order_id as string) as order_id,
    cast(location_id as string) as location_id,
    cast(name as string) as fulfillment_name,
    cast(status as string) as fulfillment_status,
    cast(service as string) as fulfillment_service,
    safe_cast(notify_customer as bool) as notify_customer,
    cast(shipment_status as string) as shipment_status,
    cast(tracking_number as string) as tracking_number,
    cast(tracking_company as string) as tracking_company,
    cast(tracking_url as string) as tracking_url,
    cast(shop_url as string) as shop_url,
    cast(admin_graphql_api_id as string) as admin_graphql_api_id,
    duties as duties_json,
    receipt as receipt_json,
    tracking_urls as tracking_urls_json,
    tracking_numbers as tracking_numbers_json,
    origin_address as origin_address_json,
    safe_cast(created_at as timestamp) as fulfillment_created_at,
    safe_cast(updated_at as timestamp) as fulfillment_updated_at
from `mbm-etl.shopify_raw.fulfillments`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(fulfillment_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}