SELECT 
    {{ dbt_utils.generate_surrogate_key( ["s.customerid"] ) }} as customer_id,
    s.customerid as nk_customer,
    ds.store_id as store_id,
    dsp.sales_teritory_id as sales_teritory_id,
    persontype as person_type,
    namestyle as name_style,
    title,
    firstname as first_name,
    middlename as middle_name,
    lastname as last_name,
    suffix,
    emailpromotion as email_promotion,
    additionalcontactinfo as additional_contact_info,
    p.demographics as demographics,
    s.modifieddate as modified_date,
    {{ dbt_date.now() }} as created_at,
    {{ dbt_date.now() }} as updated_at
FROM {{source('bikes_store_staging', 'customer')}} as s
LEFT join {{source('bikes_store_staging', 'person')}} as p on s.personid = p.businessentityid
LEFT join {{ref("dim_sales_territory")}} as dsp on s.territoryid = dsp.nk_territory
LEFT join {{ref("dim_store")}} as ds on s.storeid = ds.nk_store