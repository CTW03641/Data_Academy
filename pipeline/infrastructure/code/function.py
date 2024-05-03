import os
import urllib.request

import boto3
from botocore.exceptions import NoCredentialsError


# def upload_to_aws(local_file, bucket, s3_file):
#     s3 = boto3.client('s3')

#     try:
#         s3.upload_file(local_file, bucket, s3_file)
#         print("Upload Successful")
#         return True
#     except FileNotFoundError:
#         print("The file was not found")
#         return False
#     except NoCredentialsError:
#         print("Credentials not available")
#         return False


# def download_file(month: str, year: str) -> str:
#     url = f"https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_{year}-{month}.parquet"
#     with urllib.request.urlopen(url) as f:
#         data = f.read()
#     open(f"/tmp/data_{month}_{year}.parquet", 'wb').write(data)


def lambda_handler(event, context):
    # s3_bucket = os.getenv("S3_bucket", "data_academy_error")
    # months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    # if 'year' in event.keys():
    #     year = event["year"]
    #     if 'month' in event.keys() and event['month'] in months:
    #         month = event["month"]
    #         download_file(month, year)
    #         upload_to_aws(f"/tmp/data_{month}_{year}.parquet", s3_bucket, f'data_{month}_{year}.parquet')
    #     else:
    #         for count, month in enumerate(months):
    #             download_file(month, year)
    #             upload_to_aws(f"/tmp/data_{month}_{year}.parquet", s3_bucket, f'data_{month}_{year}.parquet')

    # else:
    #     raise ValueError("Year missing")

    # return {
    #     'message': "Upload to S3 complete"
    # }

    print("Hello World")

    return {
        'message': "Success"
    }
