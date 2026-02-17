{{ config(materialized='table') }}

SELECT
    t.*EXCEPT(channel_mapping),
    -- Segment mapping based on channel_mapping
    CASE
        WHEN t.channel_mapping = 'Amazon' THEN 'Amazon'
        WHEN t.channel_mapping IN ('Magnolia', 'Faire', 'Wholesale - Other') THEN 'Wholesale'
        WHEN t.channel_mapping IN ('Target +', 'Nordstrom') THEN 'Marketplace'
        WHEN t.channel_mapping = 'Website' THEN 'Website'
        ELSE 'Other'
    END AS sales_channel, channel_mapping as channel_segment
FROM (
    SELECT
        so.order_date,
        so.order_id, 
        so.order_number, 
        TRIM(so.channel_name) AS channel_name,
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
        lines.unit_price AS unit_price,

        -- Channel Mapping
        CASE
            WHEN LOWER(invoice_address_name) LIKE '%nordstrom%' 
              OR LOWER(invoice_address_business_name) LIKE '%nordstrom%' 
              OR LOWER(shipment_address_name) LIKE '%nordstrom%' 
              OR LOWER(shipment_address_business_name) LIKE '%nordstrom%' 
              OR LOWER(customer_name) = 'nordstrom'
              OR LOWER(channel_segment) = 'nordstrom'
            THEN 'Nordstrom'

            WHEN LOWER(invoice_address_name) LIKE '%magnolia%' 
              OR LOWER(invoice_address_business_name) LIKE '%magnolia%' 
              OR LOWER(shipment_address_name) LIKE '%magnolia%' 
              OR LOWER(shipment_address_business_name) LIKE '%magnolia%' 
              OR LOWER(customer_name) = 'magnolia'
            THEN 'Magnolia'

            WHEN TRIM(LOWER(channel_segment)) = 'faire' 
              OR TRIM(LOWER(channel_name)) = 'faire'
            THEN 'Faire'

            WHEN channel_name = 'Marketplaces - Shopify' AND order_reference LIKE '#MKT%'
            THEN 'Target +'

            WHEN LOWER(channel_name) LIKE '%wholesale%'
            THEN 'Wholesale - Other'

            WHEN channel_name = 'Shopify'
            THEN 'Website'

            WHEN channel_name = 'Amazon'
            THEN 'Amazon'

            ELSE 'Other'
        END AS channel_mapping
    FROM `fulfil-data-warehouse-227710.madebymary.sales_orders` so
    LEFT JOIN UNNEST(lines) AS lines
    WHERE so.order_date BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 2 YEAR) 
                            AND CURRENT_DATE()
) t