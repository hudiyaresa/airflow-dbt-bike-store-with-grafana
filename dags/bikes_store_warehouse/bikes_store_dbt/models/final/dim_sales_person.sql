with stg_sales_territory as (
    SELECT * FROM {{source('bikes_store_staging', 'salesterritory')}}
)
SELECT 
    {{ dbt_utils.generate_surrogate_key( ["ssp.businessentityid"] ) }} as sales_person_id,
    ssp.businessentityid as nk_sales_person,
    dst.sales_teritory_id as sales_teritory_id,
    nationalidnumber as national_id_number,
    loginid as login_id,
    persontype as person_type,
    p.namestyle as name_style,
    p.title as title,
    p.firstname as first_name,
    p.middlename as middle_name,
    p.lastname as last_name,
    p.suffix as suffix,
    jobtitle as job_title,
    birthdate as birth_date,
    p.demographics as demographics,
    maritalstatus as marital_status,
    gender,
    salariedflag as salaried_flag,
    vacationhours as vacation_hours,
    sickleavehours as sick_leave_hours,
    currentflag as current_flag,
    organizationnode as organization_node,
    ssp.salesquota as sales_quota,
    ssp.bonus as bonus,
    ssp.commissionpct as commission_pct,
    ssp.salesytd as sales_ytd,
    ssp.saleslastyear as sales_last_year,
    p.modifieddate as modified_date,
    {{ dbt_date.now() }} as created_at,
    {{ dbt_date.now() }} as updated_at
FROM {{source('bikes_store_staging', 'salesperson')}} as ssp 
LEFT join {{source('bikes_store_staging', 'employee')}} as e on ssp.businessentityid = e.businessentityid
LEFT join {{source('bikes_store_staging', 'person')}} as p on e.businessentityid = p.businessentityid
LEFT join stg_sales_territory as sst on ssp.territoryid = sst.territoryid
LEFT join {{ref("dim_sales_territory")}} as dst on sst.territoryid = dst.nk_territory