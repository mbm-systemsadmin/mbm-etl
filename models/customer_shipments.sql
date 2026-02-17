{{ config(materialized='table') }}

SELECT
  cs.id,
  cs.number,
  cs.state AS shipment_state,

  DATE(cs.shipped_at) AS shipped_at,      -- moved from Power Query
  cs.delivered_at,
  cs.picked_at,
  cs.packed_at,

  cs.picker,
  cs.packer,
  cs.shipper,
  cs.planned_date,
  cs.customer_name,
  cs.customer_id,
  cs.shipment_country_name,
  cs.shipment_region_name,
  cs.state,
  reference,

  cs_mo.id AS cs_mo_id,
  cs_mo.state AS cs_mo_state,
  cs_mo.order_id AS order_id,
  cs_mo.order_number AS order_number,
  cs_mo.quantity,
  cs_mo.product_code,
  cs_mo.order_line_id AS sale_line_id

FROM `fulfil-data-warehouse-227710.madebymary.shipments` cs
LEFT JOIN UNNEST(moves) cs_mo

WHERE DATE(cs.create_date) >= DATE_ADD(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL -2 YEAR)
  AND cs_mo.move_type = 'outgoing';