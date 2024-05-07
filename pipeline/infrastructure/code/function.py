import os

import boto3



def obtain_current_timestamp(dynamodb_client, dynamodb_table_name, dyn_folder_name):

    dynamodb_response = dynamodb_client.get_item(
        TableName=dynamodb_table_name,
        Key={'ID': {'S': dyn_folder_name}}
    )
    return int(dynamodb_response.get('Item').get('TIMESTAMP').get('N')) 


def ingest_objects(s3_client, folder_name, source_bucket_name, destination_bucket_name, dynamodb_timestamp, response):
    
    # Copy each object to the destination bucket
    for obj in response.get('Contents', []): # The output is a JSON where the objects are in 'Contents' inside 'Key'
        key = obj['Key']

        last_modified_timestamp = obj['LastModified'].timestamp()

        # Skip if the object is the folder itself
        if key == folder_name:
            continue

        if last_modified_timestamp > dynamodb_timestamp:
            copy_source = {'Bucket': source_bucket_name, 'Key': key}
            s3_client.copy_object(CopySource=copy_source, Bucket=destination_bucket_name, Key=key)
    
    return 


def update_dynamo_timestamp(dynamodb_client, dynamodb_table_name, dyn_folder_name, response):
    # Update the timestamp in DynamoDB with the latest last modified date
    latest_last_modified = str(int(max(obj['LastModified'].timestamp() for obj in response.get('Contents', []))))
    dynamodb_client.put_item(
        TableName=dynamodb_table_name,
        Item={
            'ID': {'S': dyn_folder_name},
            'TIMESTAMP': {'N': latest_last_modified}
        }
    )

    return
    

def lambda_handler(event, context):
    source_bucket_name = os.environ['SOURCE_BUCKET_NAME']
    destination_bucket_name = os.environ['STORAGE_BUCKET_NAME']
    folder_name = os.environ['ING_FOLDER'] + '/'
    dynamodb_table_name = os.environ['DYNAMO_TABLE_NAME']
    dyn_folder_name = os.environ['ING_FOLDER']

    s3 = boto3.client('s3')
    dynamodb = boto3.client('dynamodb')

    dynamodb_timestamp = obtain_current_timestamp(dynamodb, dynamodb_table_name, dyn_folder_name)

    # List objects in the source folder
    response = s3.list_objects_v2(Bucket=source_bucket_name, Prefix=folder_name) # For example, It is going to list all objects with Prefix 'taxi/' (including the name of the folder)
                                                                                 # The output is a JSON file where the objects are in 'Contents' inside 'Key'

    ingest_objects(s3, folder_name, source_bucket_name, destination_bucket_name, dynamodb_timestamp, response)

    update_dynamo_timestamp(dynamodb, dynamodb_table_name, dyn_folder_name, response)

    return {
        'statusCode': 200,
        'body': 'Ingestion Successful'
    }