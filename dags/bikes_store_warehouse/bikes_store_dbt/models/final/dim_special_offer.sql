SELECT 
    {{ dbt_utils.generate_surrogate_key( ["s.specialofferid"] ) }} as special_offer_id,
    s.specialofferid as nk_special_offer,
    s.description as description,
    s.discountpct as discount_pct,
    s."type" as type,
    s.category as category,
    s.startdate as start_date,
    s.enddate as end_date,
    s.minqty as min_qty,
    s.maxqty as max_qty,
    s.modifieddate as modified_date,
    {{ dbt_date.now() }} as created_at,
    {{ dbt_date.now() }} as updated_at
FROM {{source('bikes_store_staging', 'specialoffer')}} as s
