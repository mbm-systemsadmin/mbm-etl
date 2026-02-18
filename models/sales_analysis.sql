{{ config(materialized='table') }}

SELECT
  so.order_date,
  so.order_id, 
  so.order_number, 
  TRIM(so.channel_name) AS channel_name,
  m.sales_channel,
  m.channel_segment, 
  lines.product_code, 
  so.warehouse, 
  so.state,
  so.shipping_start_date,
  so.shipping_end_date,
  so.payment_term_id,
  so.payment_term_name,
  lines.return_reason,
  lines.line_type AS sale_type, 
  lines.quantity,
  lines.untaxed_amount_cpny_ccy_cache AS gross_sales, 
  lines.gross_profit_cpny_ccy_cache AS gross_profit,
  lines.cost_price_cpny_ccy_cache,
  lines.product_id,
  lines.id AS sale_line_id,
  so.customer_id, 
  so.customer_name, 
  so.shipment_address_city, 
  so.shipment_region_code, 
  so.shipment_region_name, 
  so.shipment_address_zip,
  so.shipment_country_code, 
  so.shipment_country_name,
  so.sales_person_name,
  lines.list_price AS list_price,
  lines.unit_price AS unit_price
FROM `fulfil-data-warehouse-227710.madebymary.sales_orders` so
    LEFT JOIN UNNEST(lines) AS lines
    LEFT JOIN `mbm-etl.demand_prediction_views.sales_order_channel_mappings` m on so.order_id = m.order_id
WHERE so.order_date BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 2 YEAR) AND CURRENT_DATE()
