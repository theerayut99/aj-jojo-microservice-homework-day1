# go-hello

| Component | Responsibility |
|---|---|
| **Package Manager** | go mod |
| **Dependency file** | go.mod / go.sum |
| **Source Code** | main.go |
| **OS executable file** | go build → server |

## Dependencies

| Package | Purpose |
|---|---|
| gin-gonic/gin | High-performance HTTP web framework |
| swaggo/gin-swagger | Swagger UI middleware for Gin |
| swaggo/swag | Swagger spec generator from Go annotations |

## Gin — ข้อดีและข้อเสีย

### ข้อดี (Pros)

| ข้อดี | รายละเอียด |
|---|---|
| **Performance สูงมาก** | ใช้ httprouter เป็น base ทำให้ routing เร็วกว่า net/http มาตรฐาน มี benchmark ดีมากเทียบกับ framework อื่น |
| **API ง่าย เรียนรู้เร็ว** | Syntax คล้าย Express.js ง่ายต่อการเริ่มต้น middleware pattern ชัดเจน |
| **Community ใหญ่มาก** | GitHub Stars 80k+ มี middleware plugin เยอะมาก documentation ครบ |
| **Middleware ยืดหยุ่น** | รองรับ middleware chain, group routing, custom middleware ได้ง่าย |
| **JSON rendering ในตัว** | `c.JSON()` serialize response เป็น JSON อัตโนมัติ ไม่ต้อง import library เพิ่ม |
| **Compile เป็น static binary** | Go compile เป็น single binary ไม่ต้องมี runtime dependency ทำให้ Docker image เล็กมาก |
| **Error recovery ในตัว** | `gin.Recovery()` middleware จับ panic ป้องกัน server crash |
| **Swagger integration ง่าย** | ใช้ swaggo/gin-swagger generate API docs จาก code annotations อัตโนมัติ |

### ข้อเสีย (Cons)

| ข้อเสีย | รายละเอียด |
|---|---|
| **ไม่มี built-in ORM** | ต้องใช้ library ภายนอก เช่น GORM, sqlx สำหรับ database interaction |
| **Error handling verbose** | Go error handling ต้องเขียน `if err != nil` ทุกจุด ทำให้ code ยาว |
| **ไม่มี built-in validation ครบ** | ต้องใช้ go-playground/validator หรือเขียน custom validation เอง |
| **Generics มาช้า** | Go มี generics ตั้งแต่ 1.18 แต่ ecosystem ยังไม่ใช้เต็มที่ |
| **ไม่มี hot reload ในตัว** | ต้องใช้ tool ภายนอก เช่น Air, CompileDaemon สำหรับ dev reload |
| **Dependency injection ไม่มีในตัว** | ต้องใช้ library เช่น Wire, Uber Fx หรือ manual injection |
| **Template engine จำกัด** | html/template ของ Go มี feature น้อยกว่า templating libraries ของ framework อื่น |

---

Go microservice built with [Gin](https://gin-gonic.com/) that returns a sample loan-service JSON log entry.

## Prerequisites

- [Docker](https://www.docker.com/) (recommended)
- [Go](https://go.dev/) >= 1.23 (optional, for local development)

## Run

```bash
# Local development (requires Go SDK)
go mod tidy
go run .

# Using Docker (no Go SDK required)
docker build -t go-hello .
docker run -p 3000:3000 go-hello

# Custom config
docker run -p 3000:3000 \
  -e SERVICE_NAME=my-service \
  -e SERVICE_ENV=staging \
  -e LOG_LEVEL=debug \
  go-hello
```

Server starts at **http://localhost:3000**

## Swagger UI

Open **http://localhost:3000/swagger/index.html** in your browser to explore the API interactively.

The raw Swagger JSON spec is available at **http://localhost:3000/swagger/doc.json**.

## Build

```bash
# Development
go run .

# Production (compile to native binary)
CGO_ENABLED=0 GOOS=linux go build -o server .
```

## Docker

```bash
# Build image
docker build -t go-hello .

# Run container
docker run -p 3000:3000 go-hello

# Run with custom config
docker run -p 3000:3000 \
  -e SERVICE_NAME=loan-service \
  -e SERVICE_ENV=production \
  -e LOG_LEVEL=info \
  go-hello
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `HOST` | `0.0.0.0` | Server bind address |
| `PORT` | `3000` | Server listen port |
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
go-hello/
├── main.go                # Factor 3 (env vars), 7 (port binding), 9 (graceful shutdown), 11 (structured logs)
├── docs/                  # Swagger API documentation (generated)
│   ├── docs.go
│   └── swagger.json
├── go.mod                 # Factor 2 (dependencies) — explicit declaration
├── go.sum                 # Factor 2 (dependencies) — dependency lock file
├── Dockerfile             # Factor 5 (build/release/run) — multi-stage build
├── Procfile               # Factor 6 (processes) — process type declaration
├── .env.example           # Factor 3 (config) — env var reference
└── .gitignore
```

แต่ละข้อของ [The Twelve-Factor App](https://12factor.net/) ถูกนำมาใช้ใน project นี้ดังนี้:

### 1. Codebase — One codebase tracked in revision control

- Source code อยู่ใน Git repository เดียว (`microservice/go-hello`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`

### 2. Dependencies — Explicitly declare and isolate dependencies

- ประกาศ dependencies ทั้งหมดใน `go.mod` พร้อม lock file `go.sum`
- `go mod download` จะดึง dependencies จาก Go module proxy โดยอัตโนมัติ
- Docker multi-stage build ทำให้ runtime image มีแค่ compiled binary ไม่มี dependency leak

### 3. Config — Store config in the environment

- Centralized `Config` struct + `loadConfig()` อ่าน env vars ทั้งหมดครั้งเดียวตอน startup
- `HOST`, `PORT`, `SERVICE_NAME`, `SERVICE_VERSION`, `SERVICE_ENV`, `LOG_LEVEL` อ่านจาก environment variables ผ่าน `os.LookupEnv()`
- ไม่มี hardcode config ใน source code — ทุกค่ามี default แต่ override ได้ผ่าน env
- Dockerfile กำหนด `ENV SERVICE_NAME=loan-service`, `ENV SERVICE_ENV=production`, `ENV LOG_LEVEL=info`

### 4. Backing Services — Treat backing services as attached resources

- ปัจจุบัน project นี้ไม่มี backing service (database, cache, queue)
- หากเพิ่มในอนาคต จะใช้ env vars สำหรับ connection string เช่น `DATABASE_URL`

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: `go build -o server .` หรือ Docker multi-stage build (`golang:1.23-alpine` → compile)
- **Release**: Docker image (`go-hello:latest`) รวม binary + ca-certificates
- **Run**: `docker run -p 3000:3000 go-hello`
- Dockerfile แยก builder stage กับ runtime stage (`alpine:3.20`) ชัดเจน

### 6. Processes — Execute the app as one or more stateless processes

- Application เป็น stateless process ตัวเดียว ไม่เก็บ state ใน memory หรือ disk
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage
- Procfile ประกาศ process type: `web: ./server`

### 7. Port Binding — Export services via port binding

- ใช้ `http.Server{Addr: addr, Handler: r}` bind port ตาม env `HOST` + `PORT`
- Self-contained HTTP server — ไม่ต้องมี reverse proxy ข้างหน้า
- Dockerfile ใช้ `EXPOSE 3000` และ run ด้วย `-p 3000:3000`

### 8. Concurrency — Scale out via the process model

- Go ใช้ goroutines รองรับ concurrent requests ภายใน process เดียว (lightweight threads)
- Scale horizontally ได้โดยรัน Docker container หลาย instance ด้วย load balancer
- ไม่ต้อง thread pool — Go runtime จัดการ goroutine scheduling อัตโนมัติ

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- Startup เร็ว — compiled binary เดียว ไม่มี warm-up หรือ JIT
- Graceful shutdown ผ่าน `gracefulShutdown()` รับ SIGTERM/SIGINT → `srv.Shutdown(ctx)` drain connections ภายใน 10 วินาที
- Dockerfile ใช้ `STOPSIGNAL SIGTERM` ให้ Docker ส่ง SIGTERM แทน SIGKILL
- `gin.Recovery()` middleware จับ panic ป้องกัน server crash

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment
- Config ต่างกันเฉพาะ environment variables (`SERVICE_ENV=staging` vs `SERVICE_ENV=production`)
- Gin mode ปรับอัตโนมัติ: production → `gin.ReleaseMode`, development → `gin.DebugMode`

### 11. Logs — Treat logs as event streams

- ใช้ `logJSON()` ส่ง structured JSON logs ไปยัง stdout พร้อม log level filtering ตาม `LOG_LEVEL`
- `requestLogger()` middleware บันทึก access log ทุก request (method, path, status, duration_ms, ip, user_agent)
- ควบคุม log level ผ่าน env `LOG_LEVEL` — filter ตาม priority: `DEBUG` < `INFO` < `WARN` < `ERROR`
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — health check สำหรับ Kubernetes liveness/readiness probe
- Swagger UI ที่ `/swagger/index.html` สำหรับ API documentation
