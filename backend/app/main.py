import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text

from .db import Base, engine
from .routers.auth_router import router as auth_router
from .routers.todo_router import router as todo_router

app = FastAPI(title="todo-backend", version="0.1.0")

# Allow frontend on localhost:3000 during local dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/ping")
def ping():
    return {"status": "ok"}


@app.on_event("startup")
def on_startup():
    # Create tables if they don't exist (dev-only convenience)
    Base.metadata.create_all(bind=engine)


app.include_router(auth_router, prefix="/api")
app.include_router(todo_router, prefix="/api")


