from airflow.exceptions import AirflowException, AirflowSkipException
from airflow.providers.postgres.hooks.postgres import PostgresHook
from helper.minio import CustomMinio
import logging
import pandas as pd
import json
from airflow.models import Variable
from datetime import timedelta


class Extract:
    @staticmethod
    def _bikes_store_db(table_name, incremental, **kwargs):
        """
        Extract all data from Pacflight database (non-incremental).

        Args:
            table_name (str): Name of the table to extract data from.
            **kwargs: Additional keyword arguments.

        Raises:
            AirflowException: If failed to extract data from Pacflight database.
            AirflowSkipException: If no data is found.
        """
        logging.info(f"[Extract] Starting extraction for table: {table_name}")

        ti = kwargs["ti"]
        ds = kwargs["ds"]
                
        try:
            pg_hook = PostgresHook(postgres_conn_id='bikes_store_db')
            connection = pg_hook.get_conn()
            cursor = connection.cursor()
            table_pkey = kwargs.get('table_pkey')            

            query = ""
            if incremental:
                date = kwargs['ds']
                query = f"""
                    SELECT * FROM {table_pkey[table_name][0]}.{table_name}
                    WHERE created_at::DATE = '{date}'::DATE - INTERVAL '1 DAY' 
                    OR updated_at::DATE = '{date}'::DATE - INTERVAL '1 DAY' ;
                """
                object_name = f'/temp/{table_name}-{(pd.to_datetime(date) - timedelta(days=1)).strftime("%Y-%m-%d")}.csv'
            else:
                query = f"SELECT * FROM {table_pkey[table_name][0]}.{table_name};"
                object_name = f'/temp/{table_name}.csv'

            logging.info(f"[Extract] Executing query: {query}")
            cursor.execute(query)
            result = cursor.fetchall()

            column_list = [desc[0] for desc in cursor.description]
            cursor.close()
            connection.commit()
            connection.close()

            df = pd.DataFrame(result, columns=column_list)

            bucket_name = 'bikes-store'
            logging.info(f"[Extract] Writing data to MinIO bucket: {bucket_name}, object: {object_name}")
            CustomMinio._put_csv(df, bucket_name, object_name)

            result = {"status": "success", "data_date": ds}            
            logging.info(f"[Extract] Extraction completed for table: {table_name}")
            return result            

        except AirflowSkipException as e:
            logging.warning(f"[Extract] Skipped extraction for {table_name}: {str(e)}")
            raise e           
        
        except Exception as e:
            logging.error(f"[Extract] Failed extracting {table_name}: {str(e)}")
            raise AirflowException(f"Error when extracting {table_name} : {str(e)}")

    @staticmethod
    def _bikes_store_api(ds):
        """
        Extract data from Bikes Store API.

        Args:
            ds (str): Date string.

        Raises:
            AirflowException: If failed to fetch data from Bikes Store API.
            AirflowSkipException: If no new data is found.
        """
        try:
            response = requests.get(
                url=Variable.get('BIKES_STORE_API_URL'),
                params={"start_date": ds, "end_date": ds},
            )

            if response.status_code != 200:
                raise AirflowException(f"Failed to fetch data from Bikes Store API. Status code: {response.status_code}")

            json_data = response.json()
            if not json_data:
                raise AirflowSkipException("No new data in Bikes Store API. Skipped...")

            bucket_name = 'bikes-store'
            object_name = f'/temp/bikes_store_api_{(pd.to_datetime(ds) - timedelta(days=1)).strftime("%Y-%m-%d")}.json'
            CustomMinio._put_json(json_data, bucket_name, object_name)
        
        except AirflowSkipException as e:
            raise e
        
        except AirflowException as e:
            raise e
        
        except Exception as e:
            raise AirflowException(f"Error when extracting Bikes Store API: {str(e)}")
