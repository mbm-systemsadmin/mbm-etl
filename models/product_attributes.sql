{{ config(materialized='table') }}

SELECT
    product.id,
    product.code AS product_code,
    REGEXP_REPLACE(REGEXP_REPLACE(INITCAP(REGEXP_REPLACE(attr.attribute_name, r'[_-]', ' ')), r'\bSku\b', 'SKU'), r'\bBa\b', 'BA') AS attribute_name,
    attr.value AS attribute_value
FROM `fulfil-data-warehouse-227710.madebymary.products` product
    LEFT JOIN UNNEST(attributes) AS attr
WHERE category_root_name NOT IN ('SERVICE', 'To be Classified', 'PACKAGING', 'OPTIONS_HIDDEN_PRODUCT')