{{ config(materialized='table') }}

SELECT 
    inv.id as invoice_id, invoice_date, invoice_number, invoice_reference, state,
    sales_person_name, invoice_address_phone_number, invoice_address_city, 
    invoice_region_code, invoice_region_name, invoice_country_name, 
    lines.type as line_type, lines.product_code, lines.quantity, lines.cost_price_cpny_ccy,
    lines.unit_price, lines.amount, lines.account_name, lines.sale_line_id,
    sales.* except (sale_line_id), payment_term_id, payment_term_name
FROM `fulfil-data-warehouse-227710.madebymary.account_invoices`  inv
    LEFT JOIN UNNEST(lines) as lines
    LEFT JOIN (
        SELECT 
            lines_s.id as sale_line_id, order_id, order_number, order_date, order_reference, confirmation_time, 
            shipping_start_date, shipping_end_date, customer_name, customer_id, channel_name, 
            so.warehouse_name, so.shipment_region_code, so.shipment_region_name, so.shipment_country_code, 
            so.shipment_country_name
        FROM `fulfil-data-warehouse-227710.madebymary.sales_orders` so,
            UNNEST(lines) as lines_s
    ) sales ON lines.sale_line_id = sales.sale_line_id
WHERE invoice_type = 'out'
    AND invoice_date between DATE_TRUNC(DATE_ADD(current_date(), INTERVAL -2 YEAR), YEAR) 
    AND current_date()