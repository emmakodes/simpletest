"use client";

import { useEffect, useState } from "react";

export default function Home() {
  const [status, setStatus] = useState<string>("loading...");
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch("/ping")
      .then(async (r) => {
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        const data = await r.json();
        setStatus(JSON.stringify(data));
      })
      .catch((e) => setError(e.message));
  }, []);

  return (
    <main style={{ padding: 24, fontFamily: "system-ui, sans-serif" }}>
      <h1>Todo Monorepo</h1>
      <p>Backend /ping response:</p>
      <pre style={{ background: "#f5f5f5", padding: 12 }}>
        {error ? `Error: ${error}` : status}
      </pre>
    </main>
  );
}
