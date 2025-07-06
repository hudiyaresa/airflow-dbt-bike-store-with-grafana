from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.exceptions import AirflowSkipException, AirflowException
from helper.minio import CustomMinio
from pangres import upsert
from sqlalchemy import create_engine
from datetime import timedelta
import logging
import pandas as pd


class Load:
    @staticmethod
    def _bikes_store_db(table_name, incremental, **kwargs):
        """
        Load data from CSV in MinIO to staging PostgreSQL DB.
        """
        logging.info(f"[Load] Starting load for table: {table_name}")
        date = kwargs.get("ds")
        ti = kwargs["ti"]

        # Cek hasil extract
        extract_result = ti.xcom_pull(task_ids=f"extract.{table_name}")
        if extract_result is None:
            logging.warning(f"[Load] No extract result found for {table_name}. Skipping.")
            raise AirflowSkipException(f"[Load] Skipped {table_name} due to missing extract result.")
        
        logging.info(f"[Load] Extract result for {table_name}: {extract_result}")

        if extract_result.get("status") != "success":
            logging.info(f"[Load] Skipping {table_name} due to extract status: {extract_result}")
            raise AirflowSkipException(f"[Load] Skipped {table_name} because no data from extract result.")

        table_pkey = kwargs.get("table_pkey")
        object_date = (pd.to_datetime(date) - timedelta(days=1)).strftime("%Y-%m-%d")
        object_name = f"/temp/{table_name}-{object_date}.csv" if incremental else f"/temp/{table_name}.csv"
        bucket_name = "bikes-store"

        engine = create_engine(PostgresHook(postgres_conn_id="warehouse_pacflight").get_uri())

        try:
            logging.info(f"[Load] Downloading {object_name} from bucket {bucket_name}")
            df = CustomMinio._get_dataframe(bucket_name, object_name)

            if df.empty:
                logging.warning(f"[Load] Dataframe is empty for {table_name}. Skipping.")
                ti.xcom_push(key="return_value", value={"status": "skipped", "data_date": date})                
                raise AirflowSkipException(f"[Load] Skipping {table_name}: CSV is empty")

            # df = df.set_index(table_pkey)
            df = df.set_index(table_pkey[table_name])

            upsert(
                con=engine,
                df=df,
                table_name=table_name,
                schema="bikes_store_staging",
                if_row_exists="update"
            )

            logging.info(f"[Load] Load success for {table_name}, {len(df)} records inserted/updated.")
            ti.xcom_push(key="return_value", value={"status": "success", "data_date": date})            

        except AirflowSkipException as e:
            logging.warning(str(e))
            raise e

        except Exception as e:
            logging.error(f"[Load] Failed to load {table_name}: {str(e)}")
            raise AirflowException(f"[Load] Failed to load {table_name}: {str(e)}")

        finally:
            engine.dispose()

    @staticmethod
    def _bikes_store_api(ds):
        """
        Load data from Bikes Store API (currency data) into staging area.

        Args:
            ds (str): Date string for the data to load.
        """
        bucket_name = 'bikes-store'
        object_name = f'/temp/bikes_store_api_{(pd.to_datetime(ds) - timedelta(days=1)).strftime("%Y-%m-%d")}.json'

        try:
            engine = create_engine(PostgresHook(postgres_conn_id='bike_store_warehouse').get_uri())

            try:
                minio_client = MinioClient._get()

                try:
                    data = minio_client.get_object(bucket_name=bucket_name, object_name=object_name).read().decode('utf-8')
                except:
                    raise AirflowSkipException(f"bikes store_api (currency data) doesn't have new data. Skipped...")
                
                data = json.loads(data)
                df = pd.json_normalize(data)
                # df = df.set_index(['customer_id', 'order_id', 'orderline_id'])

                upsert(
                    con=engine,
                    df=df,
                    table_name='currency',
                    schema='bikes_store_staging',
                    if_row_exists='update'
                )
            except AirflowSkipException as e:
                engine.dispose()
                raise e
            
            except Exception as e:
                engine.dispose()
                raise AirflowException(f"Error when loading data from Bikes Store API (currency data): {str(e)}")
            
        except AirflowSkipException as e:
            raise e
            
        except Exception as e:
            raise e