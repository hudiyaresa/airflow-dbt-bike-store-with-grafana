SELECT 
    {{ dbt_utils.generate_surrogate_key( ["s.salesreasonid"] ) }} as sales_reason_id,
    s.salesreasonid as nk_sales_reason,
    reasontype as reason_type,
    s.modifieddate as modified_date,
    {{ dbt_date.now() }} as created_at,
    {{ dbt_date.now() }} as updated_at
FROM {{source('bikes_store_staging', 'salesreason')}} as s