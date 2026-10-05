DEV_MODE = True
USERNAME = "admin@example.com"
PASSWORD = "1234"
BID = "c65d9dbc-3a80-11ef-8e66-c7237fdde60b"
BID_C = "c65d9dbc-3a80-11ef-8e66-c7237fdde60c"
BID_D = "c65d9dbc-3a80-11ef-8e66-c7237fdde60d"

BUILDING_MAPPING = {
    "Building A": BID,
    "Building B": BID_C,
    "Building C": BID_D
}

import boto3

def get_dynamo_table(table_name: str):
    dynamodb = boto3.resource(
        'dynamodb',
        endpoint_url="http://localhost:8000",
        aws_access_key_id="fakeMyKeyId",
        aws_secret_access_key="fakeSecretKey",
        region_name="us-east-1"
    )
    # return dynamodb.Table('dev-Account')
    return dynamodb.Table(table_name)
