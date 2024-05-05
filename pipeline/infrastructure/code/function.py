import os

import boto3
from botocore.exceptions import NoCredentialsError

def lambda_handler(event, context):
    source_bucket_name = os.environ['SOURCE_BUCKET_NAME']
    destination_bucket_name = os.environ['STORAGE_BUCKET_NAME']
    folder_name = os.environ['ING_FOLDER'] + '/'

    s3 = boto3.client('s3')

    # List objects in the source folder
    response = s3.list_objects_v2(Bucket=source_bucket_name, Prefix=folder_name) # For example, It is going to list all objects with Prefix 'taxi/' (including the name of the folder)
                                                                                 # The output is a JSON file where the objects are in 'Contents' inside 'Key'

    # Copy each object to the destination bucket
    for obj in response.get('Contents', []): # The output is a JSON where the objects are in 'Contents' inside 'Key'
        key = obj['Key']

        # Skip if the object is the folder itself
        if key == folder_name:
            continue
        copy_source = {'Bucket': source_bucket_name, 'Key': key} #The name of the source bucket, key name of the source object, and optional version ID of the source object
        s3.copy_object(CopySource=copy_source, Bucket=destination_bucket_name, Key=key) # Copy key to destination bucket inside a predefined folder

    return {
        'statusCode': 200,
        'body': 'Ingestion Successful'
    }