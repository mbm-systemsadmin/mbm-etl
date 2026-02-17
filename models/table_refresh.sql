{{ config(materialized='table') }}

SELECT
  INITCAP(REPLACE(table_id, '_', ' ')) AS `Table Name`,
  TIMESTAMP_MILLIS(last_modified_time) AS `Last Modified Time`
FROM `fulfil-data-warehouse-227710.madebymary.__TABLES__`;