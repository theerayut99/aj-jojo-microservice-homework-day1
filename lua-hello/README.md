# lua-hello

| Component | Responsibility |
|---|---|
| **Runtime** | OpenResty (Nginx + LuaJIT) |
| **Language** | Lua 5.1 (LuaJIT) |
| **Config file** | nginx.conf.template |
| **Source Code** | lua/app.lua |

## Dependencies

| Module | Purpose |
|---|---|
| openresty | Nginx + LuaJIT runtime |
| cjson | JSON encoding/decoding (bundled with OpenResty) |
| ngx (nginx) | HTTP server, request/response handling |

## OpenResty — ข้อดีและข้อเสีย

### ข้อดี (Pros)

| ข้อดี | รายละเอียด |
|---|---|
| **Performance สูงมาก** | ใช้ Nginx event-driven architecture + LuaJIT (near C speed) ทำให้รองรับ concurrent connections ได้หลายหมื่น โดยใช้ memory น้อยมาก |
| **Lightweight** | Docker image เล็กมาก (Alpine-based ~30MB) ไม่ต้องติดตั้ง runtime ใหญ่ ๆ เหมือน JVM หรือ .NET |
| **Non-blocking I/O** | ทุก operation เป็น non-blocking โดย Nginx event loop — ไม่ต้องจัดการ thread pool เอง |
| **Nginx Ecosystem** | ใช้ความสามารถทั้งหมดของ Nginx ได้เลย: load balancing, reverse proxy, SSL termination, rate limiting, caching |
| **Lua ง่ายต่อการเรียนรู้** | Lua เป็นภาษา scripting ที่เรียนรู้ได้เร็ว syntax น้อย ไม่ซับซ้อน เหมาะกับ web handler ง่าย ๆ |
| **Battle-tested** | OpenResty ถูกใช้ใน production ขนาดใหญ่โดย Cloudflare, Kong, และอีกหลายบริษัท |
| **Hot Reload** | สามารถ reload config ได้โดยไม่ต้อง restart process ด้วย `nginx -s reload` — zero downtime |
| **LuaJIT FFI** | สามารถเรียก C library ได้โดยตรงผ่าน LuaJIT FFI ทำให้ขยายความสามารถได้ง่าย |
| **Built-in Modules** | มาพร้อม cjson, resty.http, resty.redis, resty.mysql, resty.template ฯลฯ ไม่ต้องติดตั้งเพิ่ม |

### ข้อเสีย (Cons)

| ข้อเสีย | รายละเอียด |
|---|---|
| **Ecosystem เล็ก** | Lua library สำหรับ web น้อยกว่า Node.js, Python, Java มาก — ต้องเขียนเองบ่อย |
| **Debugging ยาก** | ไม่มี debugger ที่ดีเท่า language อื่น, error message จาก Nginx + Lua อาจอ่านยาก |
| **Lua 5.1 Only** | OpenResty ใช้ LuaJIT ซึ่ง compatible เฉพาะ Lua 5.1 — ไม่สามารถใช้ feature ใหม่ของ Lua 5.3+ |
| **Config ซับซ้อน** | ต้องเข้าใจทั้ง Nginx config syntax และ Lua — learning curve สูงกว่าใช้ framework เดียว |
| **Community เล็ก** | เทียบกับ Express, Spring, Laravel, Django แล้ว community น้อยกว่ามาก หาตัวอย่างหรือ Stack Overflow ยาก |
| **ไม่เหมาะกับ Complex App** | เหมาะกับ API gateway, proxy, simple API — ไม่เหมาะทำ full-featured web app ที่ต้องการ ORM, validation, auth ฯลฯ |
| **Testing ลำบาก** | ไม่มี testing framework มาตรฐานเท่า language อื่น ต้องใช้ `Test::Nginx` (Perl-based) หรือ test ผ่าน curl |

---

Lua microservice built with [OpenResty](https://openresty.org/) (Nginx + LuaJIT) that returns a sample loan-service JSON log entry.

## Prerequisites

- [Docker](https://www.docker.com/)
- [OpenResty](https://openresty.org/) (optional, for local development)

## Run

```bash
# Docker (recommended)
docker build -t lua-hello .
docker run -p 8080:8080 lua-hello
```

Server starts at **http://localhost:8080**

## Swagger UI

Open **http://localhost:8080/swagger** in your browser to explore the API interactively.

The raw OpenAPI JSON spec is available at **http://localhost:8080/openapi.json**.

## Build

```bash
# Build Docker image
docker build -t lua-hello .
```

## Docker

```bash
# Build image
docker build -t lua-hello .

# Run container
docker run -p 8080:8080 lua-hello

# Run with custom config
docker run -p 9090:9090 -e PORT=9090 -e SERVICE_NAME=my-service lua-hello
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8080` | Listen port |
| `SERVICE_NAME` | `loan-service` | Service name in response |
| `SERVICE_VERSION` | `1.2.0` | Service version in response |
| `SERVICE_ENV` | `production` | Environment name |

## API

### `GET /`

Returns a sample structured JSON log for a loan application request.

**Response** `200 OK`

```json
{
  "timestamp": "2026-03-18T14:10:25.123Z",
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
lua-hello/
├── lua/
│   ├── app.lua                # Factor 3 (env vars), 6 (stateless), 7 (port binding), 11 (logs to stdout)
│   └── swagger.lua            # Factor 12 (admin: Swagger UI + OpenAPI spec)
├── nginx.conf.template        # Factor 3 (config template), 7 (port binding)
├── entrypoint.sh              # Factor 5 (build/release/run), 3 (env substitution)
├── openapi.json               # Factor 12 (OpenAPI 3.0.3 spec)
├── Dockerfile                 # Factor 2 (dependencies), 5 (build/release/run)
├── .env.example               # Factor 3 (config documentation)
├── Procfile                   # Factor 5 (process declaration)
├── .dockerignore              # Build optimization
└── .gitignore                 # VCS hygiene
```

แต่ละข้อของ [The Twelve-Factor App](https://12factor.net/) ถูกนำมาใช้ใน project นี้ดังนี้:

### 1. Codebase — One codebase tracked in revision control

- Source code อยู่ใน Git repository เดียว (`microservice/lua-hello`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`

### 2. Dependencies — Explicitly declare and isolate dependencies

- ใช้ OpenResty Docker image (`openresty/openresty:1.27.1.2-alpine`) ที่มี LuaJIT + cjson มาให้ครบ
- ไม่มี external dependency ที่ต้องติดตั้งเพิ่ม — ทุกอย่างอยู่ใน base image
- Dockerfile ระบุ version ชัดเจน ทำ reproducible builds ได้

### 3. Config — Store config in the environment

- `PORT`, `SERVICE_NAME`, `SERVICE_VERSION`, `SERVICE_ENV` อ่านจาก environment variables
- `nginx.conf.template` ใช้ `envsubst` แทนค่า `${PORT}` ตอน runtime
- Lua code ใช้ `os.getenv()` อ่าน config — ไม่มี hardcode ใน source code
- Nginx directive `env SERVICE_NAME;` pass env vars เข้าสู่ Lua context

### 4. Backing Services — Treat backing services as attached resources

- ปัจจุบัน project นี้ไม่มี backing service (database, cache, queue)
- หากเพิ่มในอนาคต จะใช้ env vars สำหรับ connection string เช่น `REDIS_URL`, `DATABASE_URL`
- OpenResty มี `resty.redis`, `resty.mysql` พร้อมใช้ผ่าน env config

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: `docker build -t lua-hello .` — copy source + install dependencies
- **Release**: Docker image (`lua-hello:latest`) รวม OpenResty + Lua code + config template
- **Run**: `docker run -p 8080:8080 lua-hello` — `entrypoint.sh` ทำ envsubst แล้วเริ่ม OpenResty
- แยก build/release/run ผ่าน Docker + entrypoint.sh

### 6. Processes — Execute the app as one or more stateless processes

- Application เป็น stateless process — ไม่เก็บ state ใน memory หรือ disk
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage
- Nginx worker processes เป็น stateless ทั้งหมด

### 7. Port Binding — Export services via port binding

- OpenResty bind port ผ่าน `listen ${PORT}` ใน nginx.conf
- Dockerfile ใช้ `EXPOSE 8080` และ run ด้วย `-p 8080:8080`
- เปลี่ยน port ได้ทันทีผ่าน `PORT=9090`

### 8. Concurrency — Scale out via the process model

- Nginx ใช้ event-driven model รองรับ concurrent connections หลายหมื่นภายใน process เดียว
- `worker_processes auto` ใช้ CPU cores ทั้งหมด
- Scale horizontally ได้โดยรัน Docker container หลาย instance ด้วย load balancer

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- Startup เร็วมาก — OpenResty พร้อมรับ request ภายใน milliseconds
- Graceful shutdown ด้วย `SIGQUIT` (Dockerfile: `STOPSIGNAL SIGQUIT`) — รอ request ที่กำลังทำอยู่จบก่อนปิด
- Nginx master process จัดการ worker graceful shutdown โดยอัตโนมัติ

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment
- Config ต่างกันเฉพาะ environment variables (`SERVICE_ENV=development` vs `SERVICE_ENV=production`)
- ไม่มี conditional code แยก dev/prod

### 11. Logs — Treat logs as event streams

- `access_log /dev/stdout` — HTTP access logs ส่งไปยัง stdout
- `error_log /dev/stderr info` — error logs ส่งไปยัง stderr
- `ngx.log()` เขียน log ไปยัง error_log (stderr → stdout ผ่าน Docker)
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — health check สำหรับ Kubernetes liveness/readiness probe
- Swagger UI ที่ `/swagger` สำหรับ API documentation
- OpenAPI spec ที่ `/openapi.json` สำหรับ code generation
- `nginx -s reload` — hot reload config โดยไม่ต้อง restart
- `nginx -t` — test config syntax ก่อน deploy
