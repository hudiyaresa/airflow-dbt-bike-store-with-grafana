from airflow.hooks.base import BaseHook
from minio import Minio
from io import BytesIO
import pandas as pd
import json

class MinioClient:
    @staticmethod
    def _get():
        minio = BaseHook.get_connection('minio')
        client = Minio(
            endpoint = minio.extra_dejson['endpoint_url'],
            access_key = minio.login,
            secret_key = minio.password,
            secure = False
        )

        return client
    
class CustomMinio:
    @staticmethod
    def _put_csv(dataframe, bucket_name, object_name):
        csv_bytes = dataframe.to_csv(index=False).encode('utf-8')
        csv_buffer = BytesIO(csv_bytes)

        minio_client = MinioClient._get()
        minio_client.put_object(
            bucket_name = bucket_name,
            object_name = object_name,
            data = csv_buffer,
            length = len(csv_bytes),
            content_type = 'application/csv'
        )

    @staticmethod
    def _put_json(json_data, bucket_name, object_name):
        json_string = json.dumps(json_data)
        json_bytes = json_string.encode('utf-8')
        json_buffer = BytesIO(json_bytes)

        minio_client = MinioClient._get()
        minio_client.put_object(
            bucket_name = bucket_name,
            object_name = object_name,
            data = json_buffer,
            length = len(json_bytes),
            content_type = 'application/json'
        )

    @staticmethod
    def _get_dataframe(bucket_name, object_name):
        minio_client = MinioClient._get()
        data = minio_client.get_object(
            bucket_name = bucket_name,
            object_name = object_name
        )

        df = pd.read_csv(data)

        return df 