from airflow.decorators import dag, task
from airflow.models import Variable
from cosmos import DbtDag, DbtTaskGroup
from datetime import datetime
from cosmos.config import ProjectConfig, ProfileConfig, RenderConfig
from cosmos.profiles.postgres import PostgresUserPasswordProfileMapping
from cosmos.constants import TestBehavior
from helper.callbacks.slack_notifier import slack_notifier
import os

DBT_PROJECT_PATH = f"{os.environ['AIRFLOW_HOME']}/dags/bikes_store_warehouse/bikes_store_dbt"

project_config = ProjectConfig(
    dbt_project_path=DBT_PROJECT_PATH,
    project_name="bikes_store_warehouse",
    install_dbt_deps=True
)

profile_config = ProfileConfig(
    profile_name="warehouse",
    target_name="warehouse",
    profile_mapping=PostgresUserPasswordProfileMapping(
        conn_id='bikes_store_warehouse',
        profile_args={"schema": "bikes_store_warehouse"}
    )
)

render_config_init = RenderConfig(
    dbt_executable_path="/opt/airflow/dbt_venv/bin/dbt",
    emit_datasets=True, 
    test_behavior=TestBehavior.AFTER_ALL
)

render_config = RenderConfig(
    dbt_executable_path="/opt/airflow/dbt_venv/bin/dbt",
    emit_datasets=True, 
    test_behavior=TestBehavior.AFTER_ALL,
    exclude=["dim_date"]
)

default_args = {
    "on_failure_callback": slack_notifier
}

@dag(
    dag_id="bikes_store_warehouse",
    description="Transform data into warehouse",
    schedule=None,
    start_date=datetime(2024, 9, 1),
    catchup=False,
    default_args=default_args
)

def bikes_store_warehouse():
    @task.branch
    def check_is_warehouse_init():
        is_init = Variable.get("BIKES_STORE_WAREHOUSE_INIT", default_var="False").lower()
        return "warehouse" if is_init == "false" else "warehouse_init"

    warehouse_init = DbtTaskGroup(
            group_id="warehouse_init",
            project_config=project_config,
            profile_config=profile_config,
            render_config=render_config_init
            # install_dbt_deps=True,  # Install deps
        )

    warehouse = DbtTaskGroup(
            group_id="warehouse",
            project_config=project_config,
            profile_config=profile_config,
            render_config=render_config
            # install_deps=True,
            # exclude=["dim_date_seed"],
        )

    check_is_warehouse_init() >> [warehouse_init, warehouse]

# Run the DAG
bikes_store_warehouse()
