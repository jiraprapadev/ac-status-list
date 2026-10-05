from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from account_api import account_router

app = FastAPI()
app.include_router(account_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # อนุญาตทุก domain ในช่วงทดสอบ
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
