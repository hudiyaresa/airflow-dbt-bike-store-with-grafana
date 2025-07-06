With dim_currency as (
    SELECT * FROM {{ref('dim_currency_rate')}}
), 
dim_sales_person as (
    SELECT * FROM {{ref('dim_sales_person')}}
),
dim_sales_territory as (
    SELECT * FROM {{ref('dim_sales_territory')}}
),
dim_customer as (
    SELECT * FROM {{ref('dim_customer')}}
),
dim_ship_method as (
    SELECT * FROM {{ref('dim_ship_method')}}
),
dim_special_offer as (
    SELECT * FROM {{ref('dim_special_offer')}}
),
dim_product as (
    SELECT * FROM {{ref('dim_product')}}
),
dim_date as (
    SELECT * FROM {{ref('dim_date')}}
)

SELECT 
    {{ dbt_utils.generate_surrogate_key( ["s.salesorderid", "salesorderdetailid"] ) }} as sales_order_id,
    s.salesorderid as nk_sales_order,
    sd.salesorderdetailid as nk_sales_order_detail,
    s.revisionnumber as revision_number,
    dd1.date_id as order_date,
    dd2.date_id as due_date,
    dd3.date_id as ship_date,
    s.status,
    s.onlineorderflag,
    s.purchaseordernumber,
    s.accountnumber,
    dc.customer_id as customer_id,
    dsp.sales_person_id as sales_person_id,
    dst.sales_teritory_id as sales_teritory_id,
    s.billtoaddressid as bill_to_address_id,
    s.shiptoaddressid as ship_to_address_id,
    dsm.ship_method_id as ship_method_id,
    s.creditcardid as credit_card_id,
    s.creditcardapprovalcode as credit_card_approval_code,
    dcu.currency_rate_id as currency_rate_id,
    s.subtotal as sub_total,
    s.taxamt as tax_amount,
    s.freight as freight,
    s.totaldue as total_due,
    s.comment as comment,
    sd.carriertrackingnumber as carrier_tracking_number,
    sd.orderqty as order_qty,
    dp.product_id as product_id,
    dso.special_offer_id as special_offer_id,
    sd.unitprice as unit_price,
    sd.unitpricediscount as unit_price_discount,
    sd.modifieddate as modified_date,
    {{ dbt_date.now() }} as created_at,
    {{ dbt_date.now() }} as updated_at
FROM {{source('bikes_store_staging', 'salesorderheader')}} as s
join {{ source('bikes_store_staging', 'salesorderdetail') }} as sd on s.salesorderid = sd.salesorderid
join dim_date as dd1 on s.orderdate = dd1.date_actual
join dim_date as dd2 on s.duedate = dd2.date_actual
join dim_date as dd3 on s.shipdate = dd3.date_actual
join dim_customer as dc on s.customerid = dc.nk_customer
join dim_sales_person as dsp on s.salespersonid = dsp.nk_sales_person
join dim_sales_territory as dst on s.territoryid = dst.nk_territory
join dim_ship_method as dsm on s.shipmethodid = dsm.nk_ship_method
join dim_currency as dcu on s.currencyrateid = dcu.nk_currency_rate
join dim_special_offer as dso on sd.specialofferid = dso.nk_special_offer
join dim_product as dp on sd.productid = dp.nk_product
