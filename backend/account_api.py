from fastapi import APIRouter, HTTPException, Query
from models import ItemDynamoDB, UpdateBuildingRequest, UserAccount, LoginRequest
import boto3
import datetime
from config import get_dynamo_table
from typing import Optional

account_router = APIRouter()


@account_router.post("/register")
def register(data: UserAccount):
    print("🔥 Received data UserAccount:", data)
    table = get_dynamo_table('dev-Account')

    table.put_item(
        Item={
            "user": data.user,
            "password": data.password,
            "created_at": datetime.datetime.utcnow().isoformat()
        }
    )

    return {
        "message": "✅ User registered successfully",
        "user": data.user
    }

@account_router.post("/login")
def login(data: LoginRequest):
    print("🔥 Received data LoginRequest", data)
    table = get_dynamo_table('dev-Account')
    # user_prefix = data.user.split("@")[0]
    res = table.get_item(Key={"user": data.user, "password": data.password})
    item = res.get("Item")
    if not item or item["password"] != data.password:
        raise HTTPException(status_code=401, detail="❌ Invalid credentials")
    return {
        "message": "✅ Login successful",
        "user": item["user"],
        "password": item["password"],
    }

@account_router.post("/add-device")
def add_device(data: UpdateBuildingRequest):
    print("🔥 Received ssidList:", data.ssidList)
    table = get_dynamo_table("dev-UserDevices")

    key = {"user": data.user, "building_name": data.building_name}

    # Check if record exists
    res = table.get_item(Key=key)
    existing_item = res.get("Item")

    if not existing_item:
        # Create new entry per building
        table.put_item(
            Item={
                "user": data.user,
                "building_name": data.building_name,
                "bid": data.bid,
                "ssidList": data.ssidList
            }
        )
    else:
        # current_ssids = existing_item.get("ssidList", [])
        # new_ssids = list(set(current_ssids + data.ssidList))  # merge และ remove duplicates

        # if new_ssids != current_ssids:

        # Replace ssidList completely
        table.update_item(
            Key=key,
            UpdateExpression="SET bid = :bid, ssidList = :s",
            ExpressionAttributeValues={
                ":bid": data.bid,
                ":s": data.ssidList
            }
        )

    return {
        "message": "✅ ssidList updated for building",
        "user": data.user,
        "ssid": data.ssidList,
        "ssidList": data.ssidList,
    }

@account_router.get("/check-ssid-owner")
def check_ssid_owner(user: str = Query(...), ssid: str = Query(...), building_name: str = Query(...),):
    if not user or not ssid:
        raise HTTPException(status_code=400, detail="❌ Missing user or ssid")
    
    table = get_dynamo_table("dev-UserDevices")

    try:
        response = table.query(
            KeyConditionExpression="#u = :u",
            ExpressionAttributeNames={"#u": "user"},  # ✅ map ชื่อจริง
            ExpressionAttributeValues={
                ":u": user,
            }
        )

    except Exception as e:
        print("❌ DynamoDB Query Error:", e)
        raise HTTPException(status_code=500, detail="❌ Error querying DynamoDB")

    items = response.get("Items", [])
    for item in items:
        ssids = item.get("ssidList", [])
        item_building = item.get("building_name", "")
        if ssid in ssids:
            if item_building != building_name:
                return {
                    "status": "conflict",
                    "message": f"❌ SSID {ssid} is already used in building {item_building}",
                    "building_name": item_building,
                    "bid": item.get("bid")
                }
            else:
                return {
                    "status": "same-building",
                    "message": f"✅ SSID is already in this building"
                }

    return {
        "status": "available",
        "message": f"✅ SSID {ssid} is available",
    }

@account_router.post("/item")
def loaditem(payload: ItemDynamoDB):
    print("📥 Payload:", payload)
    user_prefix = payload.user.split("@")[0]
    user_bid = f"{user_prefix}_{payload.bid}"
    table = get_dynamo_table('dev-RAConverterData')

    # กรณีเดียว: ssid
    if payload.ssid and payload.ssidList == None:
        try:
            response = table.get_item(
                Key={
                    "user_bid": user_bid,
                    "ssid": payload.ssid
                }
            )
            item = response.get("Item")
            if not item:
                raise HTTPException(status_code=404, detail="❌ Item not found")
            
            return {
                "message": "✅ Item get successful",
                "user_bid": item["user_bid"],
                "ssid": item["ssid"],
                "last_updated": item.get("last_updated"),
                "data": item.get("data")
            }
        except Exception as e:
            print("❌ DynamoDB access error:", e)
            raise HTTPException(status_code=500, detail="❌ Failed to access DynamoDB")

    # หลาย ssid
    elif payload.ssidList:
        results = []

        for ssid in payload.ssidList:
            try:
                response = table.get_item(
                    Key={
                        "user_bid": user_bid,
                        "ssid": ssid
                    }
                )
                item = response.get("Item")
                if item:
                    results.append({
                        "ssid": item["ssid"],
                        "last_updated": item["last_updated"],
                        "data": item.get("data")
                    })
            except Exception as e:
                print(f"❌ Error on ssid {ssid}:", e)
                continue

        if not results:
            raise HTTPException(status_code=404, detail="❌ No items found")

        return {
            "message": "✅ Items retrieved",
            "count": len(results),
            "items": results
        }
    
    else:
        raise HTTPException(status_code=400, detail="❌ Missing 'ssid' or 'ssidList'")