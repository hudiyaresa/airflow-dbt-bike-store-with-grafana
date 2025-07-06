FROM apache/airflow:2.10.2
COPY requirements.txt /requirements.txt
COPY ./connections_and_variables /init/connections_and_variables
RUN pip install --no-cache-dir -r /requirements.txt

# install cosmos module
RUN pip install 'astronomer-cosmos[dbt.postgres]'

# prepare dbt virtual environment
COPY dbt-requirements.txt ./
RUN python -m virtualenv dbt_venv && source dbt_venv/bin/activate && \
    pip install --no-cache-dir -r dbt-requirements.txt && deactivate