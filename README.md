# Todo Monorepo (Phase 1 - Local Scaffold)

Monorepo containing:
- backend: FastAPI (Python 3.11) dev server.
- frontend: Next.js (TS, App Router) dev server.
- docker-compose: local dev orchestration.
- infra: Terraform (Phase 4).

## Prereqs
- Docker Desktop
- macOS/Linux shell

## First run
1. docker compose up --build
2. Visit:
   - Backend: http://localhost:8000/ping  (should return {"status":"ok"})
   - Frontend: http://localhost:3000       (renders backend response)

## What could go wrong
- Port conflicts on 3000/8000/5432/6379 -> stop other services or change mappings in docker-compose.yml
- Slow cold start: first run installs NPM/Pip deps inside containers
- Node/npm version mismatch if you run frontend outside Docker -> prefer Docker

## Next
- Phase 2: add auth + CRUD + Kafka (local: Redpanda) and wire Postgres/Redis


