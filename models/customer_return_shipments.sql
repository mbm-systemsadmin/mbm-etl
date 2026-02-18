{{ config(materialized='table') }}

SELECT
    crs.id,
    crs.number,
    crs.state AS shipment_state,
    crs.shelved_date,
    crs.planned_date,
    crs.customer_name,
    crs.customer_id,
    crs.shipment_country_name,
    crs.shipment_region_name,
    crs.state,
    crs.reference,
    crs_mo.id AS crs_id,
    crs_mo.quantity,
    crs_mo.product_code,
    crs_mo.sale_line_id AS sale_line_id
FROM `fulfil-data-warehouse-227710.madebymary.customer_return_shipments` crs
    LEFT JOIN UNNEST(moves) crs_mo
WHERE crs.shelved_date between DATE_TRUNC(DATE_ADD(current_date(), INTERVAL -2 YEAR), YEAR) and current_date()