SELECT 
     {{ dbt_utils.generate_surrogate_key( ["territoryid"] ) }} as sales_teritory_id,
    territoryid as nk_territory, 
    name, 
    countryregioncode as country_region_code, 
    "group", 
    modifieddate as modified_date,
    {{ dbt_date.now() }} as created_at,
    {{ dbt_date.now() }} as updated_at
FROM {{source('bikes_store_staging', 'salesterritory')}}