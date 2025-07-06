With currency as (
    SELECT * FROM {{source('bikes_store_staging', 'currency')}}
)
SELECT 
    currencycode as currency_code,
    name,
    modifieddate as modified_date,
    {{ dbt_date.now() }} as created_at,
    {{ dbt_date.now() }} as updated_at
FROM currency
