from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List


app = FastAPI(title="Todo API", version="1.0.0")

# For demo purposes, allow all origins. Restrict in production.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class TodoCreate(BaseModel):
    title: str
    done: bool = False


class Todo(BaseModel):
    id: int
    title: str
    done: bool = False


todos: List[Todo] = []
next_id: int = 1


@app.get("/healthz")
def healthz() -> dict:
    return {"ok": True}


@app.get("/todos", response_model=List[Todo])
def list_todos() -> List[Todo]:
    return todos


@app.post("/todos", response_model=Todo, status_code=201)
def add_todo(payload: TodoCreate) -> Todo:
    global next_id
    todo = Todo(id=next_id, title=payload.title, done=payload.done)
    next_id += 1
    todos.append(todo)
    return todo


@app.delete("/todos/{todo_id}")
def delete_todo(todo_id: int) -> dict:
    global todos
    before_count = len(todos)
    todos = [t for t in todos if t.id != todo_id]
    if len(todos) == before_count:
        raise HTTPException(status_code=404, detail="Not found")
    return {"deleted": True}


