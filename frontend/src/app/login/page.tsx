"use client";

import { useState } from "react";
import { api } from "@/lib/api";
const getErrorMessage = (e: unknown) => (e instanceof Error ? e.message : String(e));

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);

  const register = async () => {
    setError(null);
    try {
      await api("/auth/register", {
        method: "POST",
        body: JSON.stringify({ email, password }),
      });
      await login();
    } catch (e: unknown) {
      setError(getErrorMessage(e));
    }
  };

  const login = async () => {
    setError(null);
    try {
      const res = await api<{ access_token: string }>("/auth/login", {
        method: "POST",
        body: JSON.stringify({ email, password }),
      });
      localStorage.setItem("token", res.access_token);
      window.location.href = "/todos";
    } catch (e: unknown) {
      setError(getErrorMessage(e));
    }
  };

  return (
    <main style={{ padding: 24, color: "#111" }}>
      <h1 style={{ marginBottom: 12 }}>Login / Register</h1>
      <div style={{ display: "flex", flexDirection: "column", gap: 8, maxWidth: 360 }}>
        <input
          placeholder="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          style={{ padding: 8, border: "1px solid #ccc", borderRadius: 4 }}
        />
        <input
          placeholder="password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          style={{ padding: 8, border: "1px solid #ccc", borderRadius: 4 }}
        />
        <div style={{ display: "flex", gap: 8 }}>
          <button onClick={login} style={{ padding: "8px 12px", background: "#222", color: "#fff", borderRadius: 4 }}>Login</button>
          <button onClick={register} style={{ padding: "8px 12px", background: "#555", color: "#fff", borderRadius: 4 }}>Register</button>
        </div>
        {error && <div style={{ color: "#b00020" }}>{error}</div>}
      </div>
    </main>
  );
}


