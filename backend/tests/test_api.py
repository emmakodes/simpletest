from fastapi.testclient import TestClient
from app.main import app


client = TestClient(app)


def test_healthz():
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json() == {"ok": True}


def test_todo_crud():
    # Create
    create_resp = client.post("/todos", json={"title": "Learn CI/CD", "done": False})
    assert create_resp.status_code == 201
    created = create_resp.json()
    assert created["title"] == "Learn CI/CD"

    # List and verify
    list_resp = client.get("/todos")
    assert list_resp.status_code == 200
    items = list_resp.json()
    assert any(t["id"] == created["id"] for t in items)

    # Delete
    del_resp = client.delete(f"/todos/{created['id']}")
    assert del_resp.status_code == 200

