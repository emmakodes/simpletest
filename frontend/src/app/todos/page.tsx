"use client";

import { useEffect, useState } from "react";
import { api, Todo } from "@/lib/api";
const getErrorMessage = (e: unknown) => (e instanceof Error ? e.message : String(e));

export default function TodosPage() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [lastOkAt, setLastOkAt] = useState<number>(0);
  const [lastErrAt, setLastErrAt] = useState<number>(0);

  const load = async () => {
    setError(null);
    try {
      const data = await api<Todo[]>("/todos/");
      setTodos(data);
      setLastOkAt(Date.now());
    } catch (e: unknown) {
      setError(getErrorMessage(e));
      setLastErrAt(Date.now());
    }
  };

  useEffect(() => {
    load();
  }, []);

  const createTodo = async () => {
    if (!title.trim()) return;
    setBusy(true);
    setError(null);
    try {
      await api<Todo>("/todos/", {
        method: "POST",
        body: JSON.stringify({ title, description }),
      });
      setTitle("");
      setDescription("");
      setError(null);
      setLastOkAt(Date.now());
      await load();
    } catch (e: unknown) {
      setError(getErrorMessage(e));
      setLastErrAt(Date.now());
    } finally {
      setBusy(false);
    }
  };

  const toggle = async (id: string, completed: boolean) => {
    setError(null);
    try {
      await api<Todo>(`/todos/${id}`, {
        method: "PATCH",
        body: JSON.stringify({ completed }),
      });
      setLastOkAt(Date.now());
      await load();
    } catch (e: unknown) {
      setError(getErrorMessage(e));
      setLastErrAt(Date.now());
    }
  };

  const del = async (id: string) => {
    setError(null);
    try {
      await api(`/todos/${id}`, { method: "DELETE" });
      setLastOkAt(Date.now());
      await load();
    } catch (e: unknown) {
      setError(getErrorMessage(e));
      setLastErrAt(Date.now());
    }
  };

  return (
    <main style={{ padding: 24, color: "#111" }}>
      <h1 style={{ marginBottom: 12 }}>Your Todos</h1>
      <div style={{ display: "flex", gap: 8, marginTop: 12 }}>
        <input
          placeholder="title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          style={{ padding: 8, border: "1px solid #ccc", borderRadius: 4, minWidth: 200 }}
        />
        <input
          placeholder="description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          style={{ padding: 8, border: "1px solid #ccc", borderRadius: 4, minWidth: 260 }}
        />
        <button onClick={createTodo} disabled={busy} style={{ padding: "8px 12px", background: busy ? "#555" : "#222", color: "#fff", borderRadius: 4, opacity: busy ? 0.7 : 1 }}>Add</button>
        <button onClick={() => { localStorage.removeItem("token"); window.location.href = "/login"; }} style={{ padding: "8px 12px", background: "#777", color: "#fff", borderRadius: 4 }}>Logout</button>
      </div>
      {error && lastErrAt > lastOkAt && (
        <div style={{ color: "#b00020", marginTop: 8 }}>{error}</div>
      )}
      <ul style={{ marginTop: 16 }}>
        {todos.map((t) => (
          <li key={t.id} style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 8 }}>
            <input type="checkbox" checked={t.completed} onChange={(e) => toggle(t.id, e.target.checked)} />
            <span style={{ fontWeight: 600 }}>{t.title || "(no title)"}</span>
            {t.description && <span style={{ color: "#555" }}>— {t.description}</span>}
            <button onClick={() => del(t.id)} style={{ marginLeft: "auto", padding: "6px 10px", background: "#c62828", color: "#fff", borderRadius: 4 }}>Delete</button>
          </li>
        ))}
      </ul>
    </main>
  );
}


