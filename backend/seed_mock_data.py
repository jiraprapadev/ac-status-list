"""Create the local DynamoDB tables and fill them with mock data.

Run:  venv/bin/python seed_mock_data.py
Safe to run again: tables are created only if missing, items are overwritten.
"""
import datetime
import json

import boto3

from config import BID, BID_C, BID_D, PASSWORD, USERNAME

dynamodb = boto3.resource(
    'dynamodb',
    endpoint_url="http://localhost:8000",
    aws_access_key_id="fakeMyKeyId",
    aws_secret_access_key="fakeSecretKey",
    region_name="us-east-1"
)

# table name -> (partition key, sort key)
TABLES = {
    "dev-Account": ("user", "password"),
    "dev-UserDevices": ("user", "building_name"),
    "dev-RAConverterData": ("user_bid", "ssid"),
}


def create_tables():
    existing = dynamodb.meta.client.list_tables()["TableNames"]
    for name, (hash_key, range_key) in TABLES.items():
        if name in existing:
            print(f"✔ {name} already exists")
            continue
        dynamodb.create_table(
            TableName=name,
            KeySchema=[
                {"AttributeName": hash_key, "KeyType": "HASH"},
                {"AttributeName": range_key, "KeyType": "RANGE"},
            ],
            AttributeDefinitions=[
                {"AttributeName": hash_key, "AttributeType": "S"},
                {"AttributeName": range_key, "AttributeType": "S"},
            ],
            BillingMode="PAY_PER_REQUEST",
        ).wait_until_exists()
        print(f"✅ Created {name}")


def equipment(equipment_id, room, temp):
    return {
        "equipmentId": equipment_id,
        "room": room,
        "status": "ON",
        "mode": "COOL",
        "setTemp": 25,
        "roomTemp": temp,
        "fanSpeed": "AUTO",
    }


def seed():
    now = datetime.datetime.now(datetime.timezone.utc).isoformat()
    user_prefix = USERNAME.split("@")[0]

    dynamodb.Table("dev-Account").put_item(
        Item={"user": USERNAME, "password": PASSWORD, "created_at": now}
    )

    # Must match deviceOptions in frontend/lib/screens/setting_screen.dart
    all_devices = ["AC-Unit-01", "AC-Unit-02", "AC-Unit-03", "AC-Unit-04"]
    buildings = {
        "Building A": (BID, ["AC-Unit-01", "AC-Unit-02"]),
        "Building B": (BID_C, ["AC-Unit-03"]),
        "Building C": (BID_D, ["AC-Unit-04"]),
    }
    devices = dynamodb.Table("dev-UserDevices")
    converter = dynamodb.Table("dev-RAConverterData")

    for building_name, (bid, ssids) in buildings.items():
        devices.put_item(Item={
            "user": USERNAME,
            "building_name": building_name,
            "bid": bid,
            "ssidList": ssids,
        })
        # Data for every device in every building, so any selection in the app shows equipment
        for ssid in all_devices:
            data = [
                equipment(f"{ssid}-EQ1", "Meeting Room", "26.5"),
                equipment(f"{ssid}-EQ2", "Office", "24.0"),
            ]
            converter.put_item(Item={
                "user_bid": f"{user_prefix}_{bid}",
                "ssid": ssid,
                "last_updated": now,
                "data": json.dumps(data),  # dashboard decodes a JSON string
            })

    print(f"✅ Seeded mock data for {USERNAME} / {PASSWORD}")


if __name__ == "__main__":
    create_tables()
    seed()
