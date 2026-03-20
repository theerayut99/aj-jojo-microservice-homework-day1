# bash-hello

| Component | Responsibility |
|---|---|
| **Package Manager** | N/A (OS package: apk) |
| **Dependency file** | N/A (Dockerfile `apk add`) |
| **Source Code** | server.sh, handler.sh |
| **OS executable file** | bash scripts (interpreted) |

## Dependencies

| Package | Purpose |
|---|---|
| bash | Shell interpreter for application scripts |
| socat | Multipurpose relay — TCP listener with fork for HTTP serving |
| coreutils | GNU core utilities (date with nanoseconds for timing) |

## Bash + socat — ข้อดีและข้อเสีย

### ข้อดี (Pros)

| ข้อดี | รายละเอียด |
|---|---|
| **Zero compilation** | ไม่ต้อง compile เลย — แก้ script แล้วรันได้ทันที เหมาะกับ prototype และ debugging |
| **Minimal image size** | Alpine + bash + socat = ~8 MB ขนาดเล็กมากเมื่อเทียบกับ framework อื่น |
| **Ubiquitous** | Bash มีในทุก Linux distro — ไม่ต้องติดตั้ง runtime เพิ่ม |
| **Simple concurrency** | socat `fork` option สร้าง child process ต่อ connection ทำ concurrency ง่ายมาก |
| **Easy to understand** | โครงสร้างง่าย — อ่าน request จาก stdin, เขียน response ไป stdout เหมือน CGI |
| **Portable** | ทำงานได้บนทุก POSIX system ที่มี bash และ socat |
| **No dependency hell** | ไม่มี package manager, lock file, หรือ dependency conflict |
| **Great for learning** | เห็น HTTP protocol ใกล้ชิดที่สุด — ต้อง parse request line, headers เอง |

### ข้อเสีย (Cons)

| ข้อเสีย | รายละเอียด |
|---|---|
| **ไม่เหมาะกับ production** | ไม่มี thread pool, connection limit, timeout handling — จะล่มง่ายเมื่อรับ traffic จริง |
| **Performance ต่ำมาก** | fork process ทุก request, ไม่มี keep-alive, string processing ช้ามาก |
| **ไม่มี HTTP framework** | ต้อง parse HTTP request line, headers, body เอง — error-prone มาก |
| **Security concerns** | Bash injection, ไม่มี input sanitization ในตัว — ต้องระวังเรื่อง command injection |
| **ไม่มี middleware** | ไม่มี CORS, authentication, rate limiting — ต้องเขียนเองทั้งหมด |
| **ไม่มี routing library** | Route matching ใช้ case statement — ไม่รองรับ path parameters, regex |
| **JSON handling ยากลำบาก** | Bash ไม่มี JSON parser ในตัว ต้องใช้ string concatenation หรือ jq |
| **Hiring เป็นไปไม่ได้** | ไม่มีใครรับสมัครตำแหน่ง "Bash backend developer" |

---

Bash microservice built with [socat](http://www.dest-unreach.org/socat/) that returns a sample loan-service JSON log entry.

## Prerequisites

- [Docker](https://www.docker.com/) (recommended)
- [Bash](https://www.gnu.org/software/bash/) >= 4.0 + [socat](http://www.dest-unreach.org/socat/) (optional, for local development)

## Run

```bash
# Local (requires bash + socat installed)
chmod +x server.sh handler.sh
./server.sh

# Using Docker (no local dependencies required)
docker build -t bash-hello .
docker run -p 3000:3000 bash-hello

# Custom config
docker run -p 3000:3000 \
  -e SERVICE_NAME=my-service \
  -e SERVICE_ENV=staging \
  -e LOG_LEVEL=debug \
  bash-hello
```

Server starts at **http://localhost:3000**

## Swagger UI

Open **http://localhost:3000/swagger** in your browser to explore the API interactively.

The raw OpenAPI JSON spec is available at **http://localhost:3000/swagger/doc.json**.

## Build

```bash
# No build step required — scripts are interpreted
# Just ensure scripts are executable:
chmod +x server.sh handler.sh
```

## Docker

```bash
# Build image
docker build -t bash-hello .

# Run container
docker run -p 3000:3000 bash-hello

# Run with custom config
docker run -p 3000:3000 \
  -e SERVICE_NAME=loan-service \
  -e SERVICE_ENV=production \
  -e LOG_LEVEL=info \
  bash-hello
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `HOST` | `0.0.0.0` | Bind address |
| `PORT` | `3000` | Listen port |
| `SERVICE_NAME` | `loan-service` | Service name in logs & response |
| `SERVICE_VERSION` | `1.2.0` | Service version in logs & response |
| `SERVICE_ENV` | `production` | Environment name (`production`, `staging`, `development`) |
| `LOG_LEVEL` | `info` | Log level (`debug`, `info`, `warn`, `error`) |

## API

### `GET /`

Returns a sample structured JSON log for a loan application request.

**Response** `200 OK`

```json
{
  "timestamp": "2026-03-20T01:22:47.948Z",
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
bash-hello/
├── server.sh        # Factor 3 (env vars), 7 (port binding), 9 (graceful shutdown), 11 (structured logs)
├── handler.sh       # HTTP request handler — routes, response, access logging
├── swagger.html     # Swagger UI (static HTML)
├── openapi.json     # OpenAPI 3.0.3 spec
├── Dockerfile       # Factor 5 (build/release/run) — single-stage Alpine image
├── Procfile         # Factor 6 (processes) — process type declaration
├── .env.example     # Factor 3 (config) — env var reference
└── .gitignore       # Version control ignore rules
```

แต่ละข้อของ [The Twelve-Factor App](https://12factor.net/) ถูกนำมาใช้ใน project นี้ดังนี้:

### 1. Codebase — One codebase tracked in revision control

- Source code อยู่ใน Git repository เดียว (`microservice/bash-hello`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`

### 2. Dependencies — Explicitly declare and isolate dependencies

- Dependencies ประกาศใน Dockerfile ผ่าน `apk add --no-cache bash socat coreutils`
- ไม่มี package manager แยก — ใช้ OS-level package management ของ Alpine
- Docker image รวม dependencies ทั้งหมดไว้ใน layer เดียว

### 3. Config — Store config in the environment

- `HOST`, `PORT`, `SERVICE_NAME`, `SERVICE_VERSION`, `SERVICE_ENV`, `LOG_LEVEL` อ่านจาก environment variables
- ไม่มี hardcode config ใน script — ทุกค่ามี default ผ่าน `${VAR:-default}` syntax
- Dockerfile กำหนด `ENV` สำหรับทุก config variable

### 4. Backing Services — Treat backing services as attached resources

- ปัจจุบัน project นี้ไม่มี backing service (database, cache, queue)
- หากเพิ่มในอนาคต จะใช้ env vars สำหรับ connection string เช่น `DATABASE_URL`

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: `docker build -t bash-hello .` — สร้าง Alpine image พร้อม scripts
- **Release**: Docker image (`bash-hello:latest`) รวม scripts + config
- **Run**: `docker run -p 3000:3000 bash-hello`
- ไม่มี compilation step — scripts ถูก copy และ chmod ใน Dockerfile

### 6. Processes — Execute the app as one or more stateless processes

- Application เป็น stateless process — socat fork handler.sh ต่อ connection
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage
- `Procfile` กำหนด process type: `web: ./server.sh`

### 7. Port Binding — Export services via port binding

- socat bind TCP port โดยตรง: `TCP-LISTEN:${PORT},bind=${HOST},reuseaddr,fork`
- Dockerfile ใช้ `EXPOSE 3000` และ run ด้วย `-p 3000:3000`
- Port config ผ่าน env var `PORT`

### 8. Concurrency — Scale out via the process model

- socat ใช้ `fork` option สร้าง child process ต่อ connection
- Scale horizontally ได้โดยรัน Docker container หลาย instance ด้วย load balancer
- แต่ละ container เป็น independent process

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- Startup เร็วมาก — แค่ start socat process (ไม่มี compilation, warm-up)
- Graceful shutdown รับ SIGTERM/SIGINT ผ่าน `trap shutdown_handler SIGTERM SIGINT`
- `shutdown_handler()` kill socat PID และ wait จนจบ
- Dockerfile ใช้ `STOPSIGNAL SIGTERM`

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment
- Config ต่างกันเฉพาะ environment variables (`SERVICE_ENV=staging` vs `SERVICE_ENV=production`)
- Local development ใช้ script เดียวกับใน Docker

### 11. Logs — Treat logs as event streams

- ใช้ `log_json()` ส่ง structured JSON logs ไปยัง stdout (server.sh) และ stderr (handler.sh)
- ควบคุม log level ผ่าน env `LOG_LEVEL` (เช่น `debug`, `info`, `warn`, `error`)
- Access log แสดง method, path, status, duration_ms ในรูปแบบ JSON
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — health check สำหรับ Kubernetes liveness/readiness probe
- Swagger UI ที่ `/swagger` สำหรับ API documentation
- OpenAPI spec ที่ `/swagger/doc.json` หรือ `/openapi.json` สำหรับ code generation
