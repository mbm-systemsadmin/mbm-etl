{{ config(materialized='table') }}

select 
    ai.id,
    ai.invoice_number,
    ai.invoice_date,
    ai.invoice_type,
    ai.tax_amount
FROM `fulfil-data-warehouse-227710.madebymary.account_invoices` ai