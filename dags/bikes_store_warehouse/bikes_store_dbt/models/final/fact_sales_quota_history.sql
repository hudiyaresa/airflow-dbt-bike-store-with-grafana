with dim_date as (
    SELECT * FROM {{ref('dim_date')}}
),
dim_sales_person
as (
    SELECT * FROM {{ref('dim_sales_person')}}
)
SELECT 
    {{ dbt_utils.generate_surrogate_key( ["s.rowguid"] ) }} as sales_quota_history_id,
    s.rowguid as nk_sales_quota_history,
    dsp.sales_person_id as sales_person_id,
    dd.date_id as quota_date,
    s.salesquota as sales_quota,
    s.modifieddate as modified_date,
    {{ dbt_date.now() }} as created_at,
    {{ dbt_date.now() }} as updated_at
FROM {{source('bikes_store_staging', 'salespersonquotahistory')}} as s
LEFT join dim_sales_person as dsp on s.businessentityid = dsp.nk_sales_person
LEFT join dim_date as dd on s.quotadate = dd.date_actual