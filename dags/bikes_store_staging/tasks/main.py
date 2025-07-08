from airflow.decorators import task_group
from airflow.operators.python import PythonOperator
from airflow.models import Variable
from bikes_store_staging.tasks.components.extract import Extract
from bikes_store_staging.tasks.components.load import Load
from airflow.datasets import Dataset

# Task Group for Extract
@task_group
def extract_db(incremental):       
    tables_to_extract = eval(Variable.get('BIKES_STORE_STAGING__table_to_extract_and_load'))

    for table_name, (schema, _) in tables_to_extract.items():
        current_task = PythonOperator(
            task_id = f'{schema}.{table_name}',
            python_callable = Extract._bikes_store,
            trigger_rule = 'none_failed',
            outlets = [Dataset(f'postgres://bikes_store_db:5432/bikes_store_db.{table_name}')],
            op_kwargs = {
                'schema' : f'{schema}',
                'table_name': f'{table_name}',
                'incremental': incremental
            }
        )

        current_task

# Task Group for Load
@task_group
def load_db(incremental):
    table_pkey = eval(Variable.get("BIKES_STORE_STAGING__table_to_extract_and_load"))
    tables_to_load = list(table_pkey.keys())
    previous_task = None

    for table_name in tables_to_load:
        current_task = PythonOperator(
            task_id=f"{table_name}",
            python_callable=Load._bikes_store_db,
            trigger_rule="none_failed",
                # outlets=[Dataset(f'postgres://warehouse_pacflight:5432/warehouse_pacflight.stg.{table_name}')],
            op_kwargs={
                "table_name": table_name,
                "table_pkey": table_pkey,
                "incremental": incremental
            }
        )

        if previous_task:
            previous_task >> current_task

        previous_task = current_task