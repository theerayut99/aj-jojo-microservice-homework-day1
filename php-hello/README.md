# php-hello

| Component | Responsibility |
|---|---|
| **Package Manager** | composer |
| **Dependency file** | composer.json |
| **Source Code** | app/Controller/IndexController.php |
| **Runtime** | Swoole (PHP coroutine server) |

## Dependencies

| Package | Purpose |
|---|---|
| hyperf/framework | Hyperf core framework |
| hyperf/http-server | HTTP server (Swoole) |
| hyperf/swagger | Swagger / OpenAPI documentation |
| hyperf/config | Configuration management |
| hyperf/logger | Structured JSON logging (Monolog) |
| hyperf/database | Database ORM |
| hyperf/redis | Redis client |
| hyperf/cache | Cache management |

## Swoole — ข้อดีและข้อเสีย

### ข้อดี (Pros)

| ข้อดี | รายละเอียด |
|---|---|
| **Performance สูง** | Swoole เป็น C extension ที่รันเป็น long-running process ไม่ต้อง bootstrap ใหม่ทุก request เหมือน PHP-FPM ทำให้เร็วกว่าหลายเท่า |
| **Coroutine (Async I/O)** | รองรับ coroutine ทำ non-blocking I/O ได้ (DB, Redis, HTTP client) โดยไม่ต้องใช้ callback ซ้อนกัน เขียนโค้ดแบบ synchronous แต่ทำงานแบบ async |
| **Built-in HTTP Server** | ไม่ต้องพึ่ง Nginx/Apache — Swoole เป็น HTTP server ในตัว ลด infrastructure layer |
| **WebSocket & TCP support** | รองรับ WebSocket, TCP, UDP server ในตัว เหมาะกับ real-time application |
| **High Concurrency** | Worker + coroutine model รองรับ concurrent connections ได้หลายหมื่นพร้อมกัน ใช้ memory น้อยกว่า thread-per-request |
| **Connection Pool** | มี built-in connection pool สำหรับ DB/Redis ลด overhead ของการสร้าง connection ใหม่ทุก request |
| **Timer & Scheduler** | มี built-in timer สำหรับ cron job หรือ periodic task โดยไม่ต้องพึ่ง external tool |

### ข้อเสีย (Cons)

| ข้อเสีย | รายละเอียด |
|---|---|
| **Memory Leak ต้องระวัง** | เพราะเป็น long-running process ถ้าเขียนโค้ดไม่ดี (global variable, static cache) จะเกิด memory leak สะสม ต้อง restart worker เป็นระยะ |
| **Library compatibility** | PHP library บางตัวไม่รองรับ coroutine (ใช้ blocking I/O) ต้องใช้ Swoole-compatible version หรือ wrap ด้วย `Coroutine::create()` |
| **Learning curve** | ต้องเข้าใจ coroutine, channel, event loop ซึ่งต่างจาก PHP แบบดั้งเดิม (request-response lifecycle) |
| **Debugging ยากขึ้น** | Xdebug ใช้กับ Swoole ได้ยาก ต้องใช้ Swoole Tracker หรือ log-based debugging แทน |
| **Extension dependency** | ต้องติดตั้ง Swoole C extension ไม่สามารถใช้ shared hosting ทั่วไปได้ ต้อง compile หรือใช้ Docker |
| **Global State อันตราย** | ตัวแปร global/static ถูก share ระหว่าง request ใน worker เดียวกัน ถ้าไม่ระวังจะเกิด data leak ระหว่าง request |
| **Community เล็กกว่า** | เทียบกับ Laravel + PHP-FPM แล้ว community และ ecosystem ของ Swoole/Hyperf ยังเล็กกว่า resource และ tutorial น้อยกว่า |

---

PHP microservice built with [Hyperf (ไฮเพิร์ฟ)](https://hyperf.io/) framework (Swoole) that returns a sample loan-service JSON log entry.

## Prerequisites

- [Docker](https://www.docker.com/) (recommended)
- Or PHP >= 8.1 with Swoole extension >= 5.0

## Run

```bash
# Default (port 9501)
php bin/hyperf.php start

# Custom port / log level
PORT=8080 LOG_LEVEL=debug php bin/hyperf.php start
```

Server starts at **http://localhost:9501**

## Swagger UI

Open **http://localhost:9500/swagger** in your browser to explore the API interactively.

The raw OpenAPI JSON spec is available at **http://localhost:9500/http.json**.

## Build

```bash
# Development
composer install
php bin/hyperf.php start

# Production (optimized autoload)
composer install --no-dev -o
php bin/hyperf.php start
```

## Docker

```bash
# Build image
docker build -t php-hello .

# Run container
docker run -p 9501:9501 -p 9500:9500 php-hello

# Run with custom config
docker run -p 8080:8080 -p 9500:9500 -e PORT=8080 -e LOG_LEVEL=debug php-hello
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `HOST` | `0.0.0.0` | Bind address |
| `PORT` | `9501` | Listen port |
| `SWAGGER_PORT` | `9500` | Swagger UI port |
| `LOG_LEVEL` | `info` | Log level (`debug`, `info`, `warn`, `error`) |
| `APP_ENV` | `prod` | Application environment |

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
{ "status": "ok" }
```

## 12-Factor App

```
php-hello/
├── app/
│   └── Controller/
│       └── IndexController.php  # Factor 3 (env vars), 7 (port binding), 11 (structured logs)
├── config/
│   ├── autoload/
│   │   ├── server.php           # Factor 7 (port binding) — Swoole server config
│   │   ├── databases.php        # Factor 4 (backing services) — DB via env vars
│   │   ├── redis.php            # Factor 4 (backing services) — Redis via env vars
│   │   ├── logger.php           # Factor 11 (logs) — Monolog JSON to stdout
│   │   └── swagger.php          # Swagger UI config
│   └── routes.php               # Route definitions
├── Dockerfile                   # Factor 5 (build/release/run) — single-stage build
├── docker-compose.yml           # Local development environment
├── .env.example                 # Factor 3 (config) — env var reference
├── composer.json                # Factor 2 (dependencies) — explicit declaration
├── composer.lock                # Factor 2 — lock file for reproducible builds
└── bin/hyperf.php               # Factor 9 (disposability) — entry point with signal handling
```

แต่ละข้อของ [The Twelve-Factor App](https://12factor.net/) ถูกนำมาใช้ใน project นี้ดังนี้:

### 1. Codebase — One codebase tracked in revision control

- Source code อยู่ใน Git repository เดียว (`microservice/php-hello`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`

### 2. Dependencies — Explicitly declare and isolate dependencies

- ประกาศ dependencies ทั้งหมดใน `composer.json` พร้อม lock file `composer.lock`
- `composer install` จะดึง dependencies จาก Packagist โดยอัตโนมัติ
- Docker image รวม vendor ทั้งหมดไว้ภายใน ไม่มี dependency leak

### 3. Config — Store config in the environment

- `HOST`, `PORT`, `SWAGGER_PORT`, `LOG_LEVEL`, `APP_ENV` อ่านจาก environment variables ผ่าน `getenv()`
- ไม่มี hardcode config ใน source code — ทุกค่ามี default แต่ override ได้ผ่าน env
- Dockerfile กำหนด `ENV HOST=0.0.0.0`, `ENV PORT=9501`, `ENV LOG_LEVEL=info`

### 4. Backing Services — Treat backing services as attached resources

- Database config (`DB_HOST`, `DB_PORT`, `DB_DATABASE`) อ่านจาก env vars ใน `config/autoload/databases.php`
- Redis config (`REDIS_HOST`, `REDIS_PORT`, `REDIS_AUTH`) อ่านจาก env vars ใน `config/autoload/redis.php`
- เปลี่ยน backing service ได้ทันทีผ่าน env โดยไม่ต้องแก้โค้ด

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: `composer install --no-dev -o` + `php bin/hyperf.php` ภายใน Docker build
- **Release**: Docker image (`php-hello:latest`) รวม source + vendor + runtime config
- **Run**: `docker run -p 9501:9501 -e PORT=9501 php-hello`
- Dockerfile แยก build step (composer install) กับ runtime (ENTRYPOINT) ชัดเจน

### 6. Processes — Execute the app as one or more stateless processes

- Application เป็น stateless process ไม่เก็บ state ใน memory หรือ disk
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage

### 7. Port Binding — Export services via port binding

- Swoole bind port ตาม env `PORT` ใน `config/autoload/server.php`
- Swagger UI bind port ตาม env `SWAGGER_PORT` ใน `config/autoload/swagger.php`
- Dockerfile ใช้ `EXPOSE 9501 9500` และ run ด้วย `-p 9501:9501 -p 9500:9500`

### 8. Concurrency — Scale out via the process model

- ใช้ Swoole coroutine รองรับ concurrent requests ภายใน process เดียว
- Worker num ตั้งตาม CPU cores (`swoole_cpu_num()`)
- Scale horizontally ได้โดยรัน Docker container หลาย instance ด้วย load balancer

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- Startup เร็ว — Swoole server พร้อมรับ request ภายในไม่กี่วินาที
- Graceful shutdown รับ SIGTERM แล้ว Swoole หยุดรับ connection ใหม่ รอ request เดิมจบก่อนปิด
- Dockerfile กำหนด `STOPSIGNAL SIGTERM`

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment
- Config ต่างกันเฉพาะ environment variables (`LOG_LEVEL=debug` vs `LOG_LEVEL=info`)
- ไม่มี conditional code แยก dev/prod

### 11. Logs — Treat logs as event streams

- ใช้ Monolog ส่ง structured JSON logs ไปยัง `php://stdout`
- ควบคุม log level ผ่าน env `LOG_LEVEL` (เช่น `debug`, `info`, `warn`, `error`)
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — health check สำหรับ Kubernetes liveness/readiness probe
- Swagger UI ที่ `/swagger` (port 9500) สำหรับ API documentation
- OpenAPI spec ที่ `/http.json` (port 9500) สำหรับ code generation
