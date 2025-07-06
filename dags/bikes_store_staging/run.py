from airflow.decorators import dag, task_group
from pendulum import datetime
from bikes_store_staging.tasks.main import extract_db, load_db
from helper.callbacks.slack_notifier import slack_notifier
from airflow.models.variable import Variable
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

# Default arguments for the DAG
default_args = {
    'on_failure_callback': slack_notifier
}

@dag(
    dag_id='bikes_store_staging',
    description='Extract data and load into staging area',
    start_date=datetime(2024, 9, 1),
    schedule="@daily",
    catchup=False,
    default_args=default_args
)
def bikes_store_staging():
    # Get incremental mode from Airflow Variable
    incremental_mode = eval(Variable.get('BIKES_STORE_STAGING_INCREMENTAL_MODE'))

    @task_group
    def extract(incremental):
        extract_db(incremental=incremental)

    @task_group
    def load(incremental):
        load_db(incremental=incremental)    

    trigger_warehouse = TriggerDagRunOperator(
    task_id='trigger_bikes_store_warehouse_pipeline',
    trigger_dag_id='bikes_store_warehouse_pipeline',  # DAG ID to trigger
    wait_for_completion=True
    )

    # Call task groups
    extract(incremental=incremental_mode) >> load(incremental=incremental_mode) >> trigger_warehouse

# Instantiate the DAG
bikes_store_staging()