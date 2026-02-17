{{ config(materialized='table') }}

SELECT 
    table_id, TIMESTAMP_MILLIS(last_modified_time) as last_modified_time
FROM `fulfil-data-warehouse-227710.madebymary.__TABLES__`