
{% snapshot dim_product %}

{{
    config(
      target_database='postgres',
      target_schema='bikes_store_warehouse',
      unique_key='product_id',

      strategy='check',
      check_cols=[
			'subq.standard_cost'
		]
    )
}}

SELECT 
     {{ dbt_utils.generate_surrogate_key( ["productid"] ) }} as product_id,
    productid as nk_product, 
    name, 
    productnumber as product_number,
    makeflag as make_flag,
    finishedgoodsflag as finished_goods_flag,
    color,
    safetystocklevel as safety_stock_level,
    reorderpoint as reorder_point,
    standardcost as standard_cost,
    listprice as list_price,
    size,
    sizeunitmeasurecode as size_unit_measure_code,
    weightunitmeasurecode as weight_unit_measure_code,
    weight,
    daystomanufacture as days_to_manufacture,
    productline as product_line,
    "class",
    "style",
    productsubcategoryid as product_subcategory_id,
    productmodelid as product_model_id,
    sellstartdate as sell_start_date,
    sellenddate as sell_end_date,
    discontinueddate as discontinued_date,
    modifieddate as modified_date,
    {{ dbt_date.now() }} as created_at,
    {{ dbt_date.now() }} as updated_at
from {{ source('bikes_store_staging_snapshot', 'product') }}

{% endsnapshot %}