# dart-hello

| Component | Responsibility |
|---|---|
| **Package Manager** | dart pub |
| **Dependency file** | pubspec.yaml |
| **Source Code** | bin/main.dart |
| **OS executable file** | dart compile exe → server |

## Dependencies

| Package | Purpose |
|---|---|
| serverpod | Full-stack Dart web framework (HTTP server, routing, logging) |

## Serverpod — ข้อดีและข้อเสีย

### ข้อดี (Pros)

| ข้อดี | รายละเอียด |
|---|---|
| **Full-stack Dart framework** | ครบวงจรทั้ง server, client, serialization, ORM, caching, logging ในตัว ไม่ต้องหา library เพิ่มเอง |
| **Type-safe end-to-end** | สร้าง client SDK อัตโนมัติจาก server endpoints ช่วยลด bug ระหว่าง client-server |
| **Code generation** | generate model classes, serialization, endpoint dispatch อัตโนมัติจาก YAML definitions |
| **Built-in ORM** | มี PostgreSQL ORM ในตัว ไม่ต้องหา library ภายนอก |
| **Built-in logging & insights** | มี logging, health check, server insights มาพร้อม framework ไม่ต้อง setup เอง |
| **Dart ecosystem เดียวกับ Flutter** | ใช้ภาษาเดียวกับ Flutter ทำให้ share code ระหว่าง frontend/backend ได้ |
| **Active development** | Serverpod 3.x มี release ต่อเนื่อง มี roadmap ชัดเจน community กำลังโต |
| **Mini mode สำหรับ lightweight server** | ไม่จำเป็นต้องใช้ database ถ้าไม่ต้องการ เหมาะกับ microservice แบบ stateless |

### ข้อเสีย (Cons)

| ข้อเสีย | รายละเอียด |
|---|---|
| **Learning curve สูง** | ต้องเข้าใจ code generation, endpoint dispatch, protocol definitions ก่อนใช้งานจริง |
| **Ecosystem ยังเล็ก** | community เล็กกว่า Express, Spring, FastAPI มาก ตัวอย่างและ tutorial น้อย |
| **ต้องการ CLI + Flutter สำหรับ scaffold** | `serverpod create` ต้อง install Flutter SDK ทำให้ setup ใน CI/CD ยุ่งยาก |
| **Project structure ซับซ้อน** | สร้าง 3 packages (server, client, flutter) แม้ต้องการแค่ server |
| **Production references น้อย** | ยังไม่มี large-scale production case study ที่เป็นที่รู้จัก |
| **Docker image ใหญ่กว่า Shelf** | ต้องมี runtime dependencies ทำให้ image ~35 MB (vs ~17 MB สำหรับ Shelf AOT→scratch) |
| **Hiring ยากมาก** | หา Dart backend developer ที่เชี่ยวชาญ Serverpod ในตลาดแทบไม่มี |

---

Dart microservice built with [Serverpod](https://serverpod.dev/) that returns a sample loan-service JSON log entry.

## Prerequisites

- [Docker](https://www.docker.com/) (recommended)
- [Dart](https://dart.dev/get-dart) >= 3.8.0 (optional, for local development)

## Run

```bash
# Default (port 8082 for web routes)
dart pub get
dart run bin/main.dart --mode development

# Using Docker (no Dart SDK required)
docker build -t dart-hello .
docker run -p 8080:8080 -p 8081:8081 -p 8082:8082 dart-hello

# Custom config
docker run -p 8080:8080 -p 8081:8081 -p 8082:8082 \
  -e SERVICE_NAME=my-service \
  -e SERVICE_ENV=staging \
  -e LOG_LEVEL=debug \
  dart-hello
```

Server starts at **http://localhost:8082**

## Swagger UI

Open **http://localhost:8082/swagger** in your browser to explore the API interactively.

The raw OpenAPI JSON spec is available at **http://localhost:8082/openapi.json**.

## Build

```bash
# Development
dart pub get
dart run bin/main.dart --mode development

# Production (compile to native executable)
dart compile exe bin/main.dart -o bin/server
```

## Docker

```bash
# Build image
docker build -t dart-hello .

# Run container
docker run -p 8080:8080 -p 8081:8081 -p 8082:8082 dart-hello

# Run with custom config
docker run -p 8080:8080 -p 8081:8081 -p 8082:8082 \
  -e SERVICE_NAME=loan-service \
  -e SERVICE_ENV=production \
  -e LOG_LEVEL=info \
  dart-hello
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `SERVICE_NAME` | `loan-service` | Service name in logs & response |
| `SERVICE_VERSION` | `1.2.0` | Service version in logs & response |
| `SERVICE_ENV` | `production` | Environment name (`production`, `staging`, `development`) |
| `LOG_LEVEL` | `info` | Log level (`debug`, `info`, `warn`, `error`) |
| `runmode` | `production` | Serverpod run mode |
| `serverid` | `default` | Server identifier |
| `logging` | `normal` | Serverpod logging mode |
| `role` | `monolith` | Server role |

## API

Serverpod runs **3 servers** — custom REST routes are on the **Web Server (port 8082)**:

| Server | Port | Purpose |
|---|---|---|
| API | 8080 | RPC-style endpoint calls |
| Insights | 8081 | Server monitoring & health |
| Web | 8082 | HTTP routes (our REST endpoints) |

### `GET /`

Returns a sample structured JSON log for a loan application request.

**Response** `200 OK`

```json
{
  "timestamp": "2026-03-20T01:22:47.948015Z",
  "level": "INFO",
  "service": {
    "name": "loan-service",
    "version": "1.2.0",
    "environment": "production"
  },
  "trace": {
    "trace_id": "abc123xyz",
    "span_id": "span-001",
    "parent_span_id": null
  },
  "request": {
    "method": "POST",
    "path": "/api/v1/loan/apply",
    "query": {},
    "headers": {
      "x-request-id": "abc123xyz"
    },
    "body": {
      "customer_id": 1001
    },
    "ip": "10.0.0.1",
    "user_agent": "PostmanRuntime/7.32"
  },
  "response": {
    "status_code": 200,
    "body": {
      "result": "success"
    },
    "duration_ms": 120
  },
  "user": {
    "id": "u-1001",
    "role": "customer"
  },
  "error": null,
  "message": "Loan application processed successfully",
  "tags": ["loan", "apply"],
  "extra": {}
}
```

### `GET /health`

Health check endpoint for liveness/readiness probes.

**Response** `200 OK`

```json
{ "status": "ok", "service": "loan-service", "version": "1.2.0" }
```
## 12-Factor App

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

แต่ละข้อของ [The Twelve-Factor App](https://12factor.net/) ถูกนำมาใช้ใน project นี้ดังนี้:

### 1. Codebase — One codebase tracked in revision control

- Source code อยู่ใน Git repository เดียว (`microservice/dart-hello`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`

### 2. Dependencies — Explicitly declare and isolate dependencies

- ประกาศ dependencies ทั้งหมดใน `pubspec.yaml` พร้อม lock file `pubspec.lock`
- `dart pub get` จะดึง dependencies จาก pub.dev โดยอัตโนมัติ ไม่ต้องติดตั้งแยก
- Docker multi-stage build ทำให้ runtime image มีแค่ compiled binary ไม่มี dependency leak

### 3. Config — Store config in the environment

- `SERVICE_NAME`, `SERVICE_VERSION`, `SERVICE_ENV`, `LOG_LEVEL` อ่านจาก environment variables ผ่าน `Platform.environment`
- ไม่มี hardcode config ใน source code — ทุกค่ามี default แต่ override ได้ผ่าน env
- Dockerfile กำหนด `ENV SERVICE_NAME=loan-service`, `ENV SERVICE_ENV=production`, `ENV LOG_LEVEL=info`

### 4. Backing Services — Treat backing services as attached resources

- ปัจจุบัน project นี้ไม่มี backing service (database, cache, queue) — ใช้ Mini mode
- หากเพิ่มในอนาคต จะใช้ env vars สำหรับ connection string เช่น `DATABASE_URL`

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: `dart compile exe bin/main.dart -o bin/server` หรือ Docker multi-stage build (`dart:stable` → compile)
- **Release**: Docker image (`dart-hello:latest`) รวม binary + config
- **Run**: `docker run -p 8080:8080 -p 8081:8081 -p 8082:8082 dart-hello`
- Dockerfile แยก builder stage กับ runtime stage (`alpine:latest`) ชัดเจน

### 6. Processes — Execute the app as one or more stateless processes

- Application เป็น stateless process ตัวเดียว ไม่เก็บ state ใน memory หรือ disk
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage

### 7. Port Binding — Export services via port binding

- Serverpod bind 3 ports: API (8080), Insights (8081), Web (8082)
- Dockerfile ใช้ `EXPOSE 8080 8081 8082` และ run ด้วย `-p 8080:8080 -p 8081:8081 -p 8082:8082`
- Config port ผ่าน Serverpod YAML config files (`config/production.yaml`)

### 8. Concurrency — Scale out via the process model

- ใช้ Dart async/await + event loop รองรับ concurrent requests ภายใน process เดียว
- Scale horizontally ได้โดยรัน Docker container หลาย instance ด้วย load balancer
- Dart isolates สำหรับ vertical scaling

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- Startup เร็ว — compiled binary เดียว ไม่มี warm-up
- Graceful shutdown รับ SIGTERM/SIGINT ผ่าน `ProcessSignal.sigterm/sigint` listeners
- ใช้ `STOPSIGNAL SIGTERM` ใน Dockerfile และ `_handleShutdown()` สำหรับ cleanup

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment
- Config ต่างกันเฉพาะ environment variables (`SERVICE_ENV=staging` vs `SERVICE_ENV=production`)
- Serverpod config files (`development.yaml`, `production.yaml`) ใช้โครงสร้างเดียวกัน

### 11. Logs — Treat logs as event streams

- ใช้ `_log()` ส่ง structured JSON logs ไปยัง stdout
- ควบคุม log level ผ่าน env `LOG_LEVEL` (เช่น `debug`, `info`, `warn`, `error`)
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — health check สำหรับ Kubernetes liveness/readiness probe
- Swagger UI ที่ `/swagger` สำหรับ API documentation
- OpenAPI spec ที่ `/openapi.json` สำหรับ code generation
