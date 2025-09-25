import { useEffect, useState } from "react"

type Todo = { id: number; title: string; done: boolean }

const API = "/api"

export default function App() {
  const [todos, setTodos] = useState<Todo[]>([])
  const [title, setTitle] = useState("")
  const [loading, setLoading] = useState(false)

  const fetchTodos = async () => {
    setLoading(true)
    try {
      const r = await fetch(`${API}/todos`)
      const data = await r.json()
      setTodos(data)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchTodos()
  }, [])

  const add = async () => {
    const trimmed = title.trim()
    if (!trimmed) return
    await fetch(`${API}/todos`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title: trimmed, done: false }),
    })
    setTitle("")
    fetchTodos()
  }

  const del = async (id: number) => {
    await fetch(`${API}/todos/${id}`, { method: "DELETE" })
    fetchTodos()
  }

  return (
    <div style={{ maxWidth: 560, margin: "2rem auto", fontFamily: "system-ui" }}>
      <h1>Todo</h1>
      <div style={{ display: "flex", gap: 8 }}>
        <input
          placeholder="New todo"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          style={{ flex: 1 }}
        />
        <button onClick={add}>Add</button>
      </div>
      {loading ? (
        <p>Loading...</p>
      ) : (
        <ul>
          {todos.map((t) => (
            <li key={t.id} style={{ display: "flex", justifyContent: "space-between" }}>
              <span>{t.title}</span>
              <button onClick={() => del(t.id)}>Delete</button>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}


