from typing import List
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from .. import schemas
from ..auth import get_current_user
from ..db import get_db
from ..kafka_producer import emit_event
from ..models import Todo, User


router = APIRouter(prefix="/todos", tags=["todos"])


@router.get("/", response_model=List[schemas.TodoOut])
def list_todos(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    todos = db.query(Todo).filter(Todo.user_id == user.id).order_by(Todo.created_at.desc()).all()
    return [
        schemas.TodoOut(
            id=str(t.id),
            title=t.title,
            description=t.description,
            completed=t.completed,
            created_at=t.created_at,
            updated_at=t.updated_at,
        )
        for t in todos
    ]


@router.post("/", response_model=schemas.TodoOut)
def create_todo(payload: schemas.TodoCreate, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    todo = Todo(user_id=user.id, title=payload.title, description=payload.description or None)
    db.add(todo)
    db.commit()
    db.refresh(todo)
    emit_event({"type": "todo_created", "user_id": str(user.id), "todo_id": str(todo.id)})
    return schemas.TodoOut(
        id=str(todo.id),
        title=todo.title,
        description=todo.description,
        completed=todo.completed,
        created_at=todo.created_at,
        updated_at=todo.updated_at,
    )


@router.patch("/{todo_id}", response_model=schemas.TodoOut)
def update_todo(todo_id: UUID, payload: schemas.TodoUpdate, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    todo = db.query(Todo).filter(Todo.id == todo_id, Todo.user_id == user.id).first()
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    if payload.title is not None:
        todo.title = payload.title
    if payload.description is not None:
        todo.description = payload.description
    if payload.completed is not None:
        todo.completed = payload.completed
    db.commit()
    db.refresh(todo)
    emit_event({"type": "todo_updated", "user_id": str(user.id), "todo_id": str(todo.id)})
    return schemas.TodoOut(
        id=str(todo.id),
        title=todo.title,
        description=todo.description,
        completed=todo.completed,
        created_at=todo.created_at,
        updated_at=todo.updated_at,
    )


@router.delete("/{todo_id}")
def delete_todo(todo_id: UUID, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    todo = db.query(Todo).filter(Todo.id == todo_id, Todo.user_id == user.id).first()
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    db.delete(todo)
    db.commit()
    emit_event({"type": "todo_deleted", "user_id": str(user.id), "todo_id": str(todo.id)})
    return {"ok": True}


