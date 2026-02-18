{{ config(materialized='table') }}

SELECT 
  DISTINCT 
  product.id,
  product.code AS product_code,
  product.variant_name,
  product.template_name,
  product.category_name,
  product.brand_name,
  product.product_type,
  (
    SELECT attr.value 
    FROM UNNEST(product.attributes) AS attr 
    WHERE attr.attribute_name = 'Product Type' 
    LIMIT 1
  ) AS product_type_value,
  product.active,
  product.is_salable,
  product.is_gift_card,
  co.cost AS cost_price,
  lp.list_price AS list_price
FROM `fulfil-data-warehouse-227710.madebymary.products` product 
LEFT JOIN UNNEST(product.costs) AS co 
LEFT JOIN UNNEST(product.list_prices) AS lp
WHERE category_root_name NOT IN ('SERVICE','To be Classified','PACKAGING','OPTIONS_HIDDEN_PRODUCT')