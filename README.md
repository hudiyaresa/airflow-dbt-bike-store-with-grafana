# Bikes Store Data Pipeline

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Objectives](#objectives)
4. [Setup Instructions](#setup-instructions)
5. [Environment Variables](#environment-variables)
6. [How to Run](#how-to-run)
7. [DAGs Overview](#dags-overview)
8. [Monitoring & Logging](#monitoring--logging)
9. [Documentations](#documentations)

---

## Overview

The Bikes Store Data Pipeline is an orchestration project built to extract, load, and transform data from transactional databases and external APIs into a structured warehouse. This pipeline uses Apache Airflow with CeleryExecutor, PostgreSQL, MinIO, and DBT, and is instrumented with monitoring tools like Prometheus and Grafana.

---

## Architecture

* **Orchestration**: Apache Airflow 2.10.2 (CeleryExecutor)
* **Monitoring**: StatsD Exporter, Prometheus, Grafana
* **Source DB**: PostgreSQL (`bikes_store_db`)
* **Data Lake**: MinIO
* **Warehouse**: PostgreSQL (`bikes_store_warehouse`)
* **Logging**: Remote logging to S3 (`airflow-logs`)
* **Transformation**: DBT (via Airflow Cosmos)
* **API Source**: Currency API returning JSON

---

## Objectives

* Set up an orchestration platform with Airflow
* Enable remote logging and metric monitoring
* Build modular ETL pipelines with two DAGs:

  * `bikes_store_staging`: Extract & Load data to staging
  * `bikes_store_warehouse`: Transform data into warehouse schema
* Use DBT for warehouse modeling and test automation
* Trigger warehouse transformation after staging is complete

---


## Setup Instructions

1. Clone the repository.

2. Configure your `.env` with the values above.

3. Initialize Airflow **connections and variables** from:

   * `setup/airflow/connections_and_variables/airflow_connections_init.yaml`
   * `setup/airflow/connections_and_variables/airflow_variables_init.json`

4. These will be automatically loaded during setup using the `start.sh` script.

5. You must validate:

  * DAGs appear in Airflow UI
  * All services run correctly
  * Data is loaded and transformed end-to-end
  * Failures trigger Slack alerts (make sure your Slack Webhook connection is set)

---

## Environment Variables

Ensure the following environment variables are defined in your `.env` file:

```env
AIRFLOW_UID=50000
AIRFLOW_FERNET_KEY=YOUR_FERNET_KEY
AIRFLOW_WEBSERVER_SECRET_KEY=YOUR_SECRET_KEY

AIRFLOW_DB_URI=postgresql+psycopg2://airflow:airflow@airflow-metadata-8/airflow
AIRFLOW_CELERY_RESULT_BACKEND=db+postgresql://airflow:airflow@airflow-metadata-8/airflow
AIRFLOW_CELERY_BROKER_URL=redis://:@redis:6379/0

AIRFLOW_DB_USER=airflow
AIRFLOW_DB_PASSWORD=YOUR_PASSWORD
AIRFLOW_DB_NAME=airflow

AIRFLOW_USER=airflow
AIRFLOW_PASSWORD=YOUR_PASSWORD

AIRFLOW_LOGGING_REMOTE_BASE_LOG_FOLDER=s3://airflow-logs/
AIRFLOW_LOGGING_REMOTE_LOG_CONN_ID=s3-conn

AIRFLOW_METRICS_STATSD_HOST=statsd-exporter
AIRFLOW_METRICS_STATSD_PORT=8125

BIKES_STORE_DB_USER=postgres
BIKES_STORE_DB_PASSWORD=YOUR_PASSWORD
BIKES_STORE_DB_NAME=bikes_store_db

WAREHOUSE_DB_USER=postgres
WAREHOUSE_DB_PASSWORD=YOUR_PASSWORD
WAREHOUSE_DB_NAME=bikes_store_warehouse
```

---

## How to Run

1. From the root project directory:

```bash
cd my-project/setup
chmod +x setup.sh
./setup.sh
```

2. The script will:

   * Build and start all required services via Docker Compose
   * Load Airflow connections and variables
   * Set up monitoring tools
   * Start the Airflow scheduler, workers, webserver, Redis, PostgreSQL, MinIO and monitoring tools

3. Access Airflow UI at:

   ```
   http://localhost:8080
   Username: airflow
   Password: YOUR_PASSWORD (as in .env)
   ```

---

## DAGs Overview

### 1. `bikes_store_staging`

* **Purpose**: Extract data from databases and API, save to MinIO, and load into staging schema.
* **Schedule**: Daily
* **Tasks**:

  * `extract`: parallel extraction from DB and API
  * `load`: load CSVs from MinIO to PostgreSQL
  * `trigger_bikes_store_warehouse`: triggers transformation DAG

### 2. `bikes_store_warehouse`

* **Purpose**: Run DBT transformations from staging to warehouse schema.
* **Trigger**: Manually or via staging DAG
* **Dynamic Behavior**:

  * `check_is_warehouse_init`: determines if init or update
  * `warehouse_init`: runs full DBT models
  * `warehouse`: runs incremental transformations (excludes `dim_date`)

---

## Monitoring & Logging

The system includes integrated monitoring tools:

* **StatsD Exporter** → Prometheus → Grafana
* **Grafana Dashboards**: Use existing templates or custom boards
* **Remote Logs**: All logs are saved to `s3://airflow-logs/` via `s3-conn`

Ensure the corresponding Grafana dashboards and data sources are correctly configured.

---

## Documentations
