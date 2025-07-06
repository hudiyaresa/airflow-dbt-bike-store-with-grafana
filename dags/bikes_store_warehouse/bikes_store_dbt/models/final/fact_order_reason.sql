with dim_date as (
    SELECT * FROM {{ref('dim_date')}}
),
dim_sales_reason as (
    SELECT * FROM {{ref('dim_sales_reason')}}
)
SELECT 
    {{ dbt_utils.generate_surrogate_key( ["s.salesorderid"] ) }} as sales_order_reason_id,
    s.salesorderid as nk_sales_order,
    dsr.sales_reason_id as sales_reason_id,
    dd.date_id as order_date,
    s.modifieddate as modified_date,
    {{ dbt_date.now() }} as created_at,
    {{ dbt_date.now() }} as updated_at
FROM {{ source('bikes_store_staging', 'salesorderheadersalesreason') }} as s
join {{source('bikes_store_staging', 'salesorderheader')}} as soh on s.salesorderid = soh.salesorderid
join dim_sales_reason as dsr on s.salesreasonid = dsr.nk_sales_reason
join dim_date as dd on soh.orderdate = dd.date_actual