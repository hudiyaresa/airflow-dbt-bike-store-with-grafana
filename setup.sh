# start minio
docker compose -f ./setup/minio/docker-compose.yml down -v
docker compose -f ./setup/minio/docker-compose.yml up --build --detach

# start monitoring services
docker compose -f ./setup/monitoring/docker-compose.yml down -v
docker compose -f ./setup/monitoring/docker-compose.yml up --build --detach

# start airflow
docker compose -f ./setup/airflow/docker-compose.yml down -v
docker compose -f ./setup/airflow/docker-compose.yml up --build --detach

sleep 10

# import connections and variables
docker exec -it airflow-webserver airflow connections import /init/connections_and_variables/airflow_connections_init.yaml
docker exec -it airflow-webserver airflow variables import /init/connections_and_variables/airflow_variables_init.json