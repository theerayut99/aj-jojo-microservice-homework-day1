# dart-hello

Loan service microservice built with **Dart** and **Serverpod** web framework.

## Components

| Component   | Technology                       |
| ----------- | -------------------------------- |
| Language    | Dart 3.x (stable)               |
| Framework   | Serverpod 3.4.4                  |
| Swagger     | Swagger UI 5 (CDN)              |
| Docker      | exe compile → Alpine             |
| Logging     | Serverpod built-in logging       |

## Dependencies

| Package      | Purpose                              |
| ------------ | ------------------------------------ |
| serverpod    | Full-stack Dart web framework        |

## Serverpod — Pros & Cons

### Pros

1. **Full-stack Dart framework** — ครบวงจรทั้ง server, client, serialization, ORM, caching, logging ในตัว
2. **Type-safe end-to-end** — สร้าง client SDK อัตโนมัติจาก server endpoints ช่วยลด bug ระหว่าง client-server
3. **Code generation** — generate model classes, serialization, endpoint dispatch อัตโนมัติจาก YAML definitions
4. **Built-in ORM** — มี PostgreSQL ORM ในตัว ไม่ต้องหา library ภายนอก
5. **Built-in logging & insights** — มี logging, health check, server insights มาพร้อม framework
6. **Dart ecosystem เดียวกับ Flutter** — ใช้ภาษาเดียวกับ Flutter ทำให้ share code ระหว่าง frontend/backend ได้
7. **Active development** — Serverpod 3.x มี release ต่อเนื่อง มี roadmap ชัดเจน
8. **Mini mode สำหรับ lightweight server** — ไม่จำเป็นต้องใช้ database ถ้าไม่ต้องการ

### Cons

1. **Learning curve สูง** — ต้องเข้าใจ code generation, endpoint dispatch, protocol definitions
2. **Ecosystem ยังเล็ก** — community เล็กกว่า Express, Spring, FastAPI มาก ตัวอย่างน้อย
3. **ต้องการ CLI + Flutter สำหรับ scaffold** — `serverpod create` ต้อง install Flutter SDK ทำให้ setup ใน CI/CD ยุ่งยาก
4. **Project structure ซับซ้อน** — สร้าง 3 packages (server, client, flutter) แม้ต้องการแค่ server
5. **Production references น้อย** — ยังไม่มี large-scale production case study ที่เป็นที่รู้จัก
6. **Docker image ใหญ่กว่า Shelf** — ต้องมี runtime dependencies ทำให้ image ~35 MB (vs ~17 MB สำหรับ Shelf AOT→scratch)
7. **Hiring ยากมาก** — หา Dart backend developer ที่เชี่ยวชาญ Serverpod ในตลาดแทบไม่มี

## Architecture

Serverpod runs **3 servers**:

| Server   | Port | Purpose                              |
| -------- | ---- | ------------------------------------ |
| API      | 8080 | RPC-style endpoint calls             |
| Insights | 8081 | Server monitoring & health           |
| Web      | 8082 | HTTP routes (our REST endpoints)     |

## Run

```bash
# ใช้ Docker (ไม่ต้องลง Dart SDK)
docker build -t dart-hello .
docker run -p 8080:8080 -p 8082:8082 dart-hello

# ถ้าลง Dart SDK แล้ว
dart pub get
dart run bin/main.dart --mode development
```

## Swagger

เปิด browser ไปที่ http://localhost:8082/swagger

OpenAPI spec: http://localhost:8082/openapi.json

## Docker Build

```bash
docker build -t dart-hello .
docker run -d --name dart-hello \
  -p 8080:8080 -p 8081:8081 -p 8082:8082 \
  -e SERVICE_NAME=loan-service \
  -e SERVICE_ENV=production \
  -e LOG_LEVEL=info \
  dart-hello
```

Image ใช้ `dart compile exe` แล้วรันบน Alpine Linux

## Environment Variables

| Variable          | Default        | Description                              |
| ----------------- | -------------- | ---------------------------------------- |
| `SERVICE_NAME`    | `loan-service` | Service name in logs & response          |
| `SERVICE_VERSION` | `1.2.0`        | Service version in logs & response       |
| `SERVICE_ENV`     | `production`   | Environment name (production/staging)    |
| `LOG_LEVEL`       | `info`         | Log level (debug/info/warn/error)        |
| `runmode`         | `production`   | Serverpod run mode                       |
| `serverid`        | `default`      | Server identifier                        |
| `logging`         | `normal`       | Serverpod logging mode                   |
| `role`            | `monolith`     | Server role                              |

## API (Web Server — port 8082)

| Method | Path            | Description            |
| ------ | --------------- | ---------------------- |
| GET    | `/`             | Loan service JSON log  |
| GET    | `/health`       | Health check           |
| GET    | `/swagger`      | Swagger UI             |
| GET    | `/openapi.json` | OpenAPI 3.0 spec       |

## 12-Factor App

| Factor                 | Implementation                                                                                       |
| ---------------------- | ---------------------------------------------------------------------------------------------------- |
| I. Codebase            | Git monorepo — one codebase tracked in version control, many deploys                                 |
| II. Dependencies       | `pubspec.yaml` + `dart pub get` — explicitly declared and isolated                                   |
| III. Config            | Environment variables (`SERVICE_NAME`, `SERVICE_ENV`, `LOG_LEVEL`, etc.) — never hardcoded in source |
| IV. Backing services   | N/A (Mini mode, no database) — ready to attach via env vars when needed                              |
| V. Build, release, run | Docker multi-stage: `dart compile exe` → Alpine image — strict separation                            |
| VI. Processes          | Stateless server — no shared in-memory state between requests                                        |
| VII. Port binding      | Self-contained HTTP servers via Serverpod (API:8080, Insights:8081, Web:8082)                        |
| VIII. Concurrency      | Horizontal scaling via containers; Dart isolates for vertical scaling                                |
| IX. Disposability      | `ProcessSignal.sigterm/sigint` listeners + `STOPSIGNAL SIGTERM` — fast startup, graceful shutdown    |
| X. Dev/prod parity     | Same Docker image across environments — config differs only via env vars                             |
| XI. Logs               | Structured JSON log events written to `stdout` via `_log()` — no log files                           |
| XII. Admin processes   | Run one-off commands in same container: `docker exec <c> ./server --mode=production --role=maintenance` |

### โครงสร้าง 12-Factor ใน Code

```
dart-hello/
├── bin/main.dart          # Factor 3 (env vars), 7 (port binding), 9 (graceful shutdown), 11 (structured logs)
├── config/                # Factor 10 (dev/prod parity) — Serverpod YAML configs
│   ├── development.yaml
│   ├── production.yaml
│   └── passwords.yaml
├── Dockerfile             # Factor 5 (build/release/run) — multi-stage build
├── Procfile               # Factor 6 (processes) — process type declaration
├── .env.example           # Factor 3 (config) — env var reference
├── pubspec.yaml           # Factor 2 (dependencies) — explicit declaration
└── lib/src/generated/     # Factor 2 — internal dependency (Serverpod stubs)
```
