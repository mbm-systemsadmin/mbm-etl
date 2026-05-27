{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='fulfillment_order_id',
    schema='shopify_bronze',
    on_schema_change='sync_all_columns'
) }}

select
    cast(id as string) as fulfillment_order_id,
    cast(order_id as string) as order_id,
    cast(shop_id as string) as shop_id,
    cast(channel_id as string) as channel_id,
    cast(assigned_location_id as string) as assigned_location_id,
    cast(status as string) as fulfillment_order_status,
    cast(request_status as string) as request_status,
    cast(fulfill_by as string) as fulfill_by,
    cast(shop_url as string) as shop_url,
    cast(admin_graphql_api_id as string) as admin_graphql_api_id,
    line_items as line_items_json,
    destination as destination_json,
    delivery_method as delivery_method_json,
    assigned_location as assigned_location_json,
    fulfillment_holds as fulfillment_holds_json,
    merchant_requests as merchant_requests_json,
    supported_actions as supported_actions_json,
    safe_cast(created_at as timestamp) as fulfillment_order_created_at,
    safe_cast(updated_at as timestamp) as fulfillment_order_updated_at,
    safe_cast(fulfill_at as timestamp) as fulfill_at,
    safe_cast(fulfilled_at as timestamp) as fulfilled_at
from `mbm-etl.shopify_raw.fulfillment_orders`
{% if is_incremental() %}
where safe_cast(updated_at as timestamp) >= (
    select coalesce(max(fulfillment_order_updated_at), timestamp('1900-01-01'))
    from {{ this }}
)
{% endif %}