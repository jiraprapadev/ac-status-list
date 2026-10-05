from pydantic import BaseModel
from typing import Optional, List

class UserAccount(BaseModel):
    user: str
    password: str
    created_at: str

class LoginRequest(BaseModel):
    user: str
    password: str

class ItemDynamoDB(BaseModel):
    user: str
    bid: str
    ssid: Optional[str] = None
    ssidList: Optional[List[str]] = None

class UpdateBuildingRequest(BaseModel):
    user: str
    building_name: str
    bid: str
    ssidList: list[str]
