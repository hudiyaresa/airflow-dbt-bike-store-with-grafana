With dim_date as (
    SELECT * FROM {{ref('dim_date')}}
),
dim_sales_person as (
    SELECT * FROM {{ref('dim_sales_person')}}
),
dim_sales_territory as (
    SELECT * FROM {{ref('dim_sales_territory')}}
)
SELECT 
    {{ dbt_utils.generate_surrogate_key( ["s.rowguid"] ) }} as sales_quota_history_id,
    s.rowguid as nk_sales_territory_history,
    dsp.sales_person_id as sales_person_id,
    dst.sales_teritory_id as sales_teritory_id,
    dd.date_id as start_date,
    dd1.date_id as end_date,
    s.modifieddate as modified_date,
    {{ dbt_date.now() }} as created_at,
    {{ dbt_date.now() }} as updated_at
FROM {{source('bikes_store_staging', 'salesterritoryhistory')}} as s
join dim_sales_person as dsp on s.businessentityid = dsp.nk_sales_person
join dim_date as dd on s.startdate = dd.date_actual
left join dim_date as dd1 on s.enddate = dd1.date_actual
join dim_sales_territory as dst on s.territoryid = dst.nk_territory