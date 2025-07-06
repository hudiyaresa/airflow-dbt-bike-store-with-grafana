SELECT 
    {{ dbt_utils.generate_surrogate_key( ["s.currencyrateid"] ) }} as currency_rate_id,
    s.currencyrateid as nk_currency_rate,
    currencyratedate as currency_rate_date,
    fromcurrencycode as from_currency_code,
    tocurrencycode as to_currency_code, 
    s.modifieddate as modified_date,
    {{ dbt_date.now() }} as created_at,
    {{ dbt_date.now() }} as updated_at
FROM {{source('bikes_store_staging', 'currencyrate')}} as s