# Scala-hello

| Component | Responsibility |
|---|---|
| **Build Tool** | sbt |
| **Dependency file** | build.sbt |
| **Source Code** | Main.scala, Routes.scala, Models.scala |
| **Fat JAR** | app.jar (sbt-assembly) |

## Dependencies

| Library | Purpose |
|---|---|
| pekko-http | HTTP server (Apache Pekko HTTP) |
| pekko-actor-typed | Actor system runtime |
| pekko-stream | Reactive streams |
| pekko-http-spray-json | JSON marshalling for Pekko HTTP |
| spray-json | JSON serialization |
| logback-classic | Logging implementation |
| logstash-logback-encoder | Structured JSON logging |

## Pekko HTTP — ข้อดีและข้อเสีย

### ข้อดี (Pros)

| ข้อดี | รายละเอียด |
|---|---|
| **Reactive & Non-blocking** | สร้างบน Pekko Streams ใช้ backpressure อัตโนมัติ รองรับ concurrent connections สูงโดยไม่ block thread |
| **Type-safe DSL** | Route DSL เป็น type-safe — directive composition ตรวจสอบ type ตอน compile ลด runtime error |
| **Apache License** | เป็น open-source ภายใต้ Apache 2.0 (fork จาก Akka) ไม่มีปัญหา licensing เหมือน Akka ใหม่ |
| **Scala 3 Support** | รองรับ Scala 3 เต็มรูปแบบ ใช้ syntax ใหม่ (given, using, extension methods) ได้ |
| **Streaming First-class** | HTTP streaming (chunked transfer, SSE, WebSocket) เป็น built-in ไม่ต้องใช้ library เพิ่ม |
| **Testkit ดี** | `pekko-http-testkit` ให้ test routes ได้ง่ายโดยไม่ต้อง start server จริง |
| **Modular Architecture** | แยก module ชัดเจน (actor, stream, http) เลือกใช้เฉพาะที่ต้องการ ไม่มี bloat |
| **JVM Ecosystem** | รันบน JVM ใช้ library Java/Scala ทั้งหมดได้ เช่น JDBC, gRPC, Kafka client |
| **Pattern Matching** | Scala pattern matching ทำให้ route handling และ error handling อ่านง่ายและปลอดภัย |

### ข้อเสีย (Cons)

| ข้อเสีย | รายละเอียด |
|---|---|
| **Learning Curve สูง** | ต้องเข้าใจ Actor model, Streams, implicit/given, type system ของ Scala ซึ่งซับซ้อนกว่า framework อื่น |
| **Compile Time ช้า** | Scala compiler ช้ากว่า Java/Kotlin มาก โดยเฉพาะ project ใหญ่ที่มี implicit/macro เยอะ |
| **Community เล็กกว่า** | เทียบกับ Spring (Java), Express (Node.js) แล้ว community และ tutorial น้อยกว่ามาก |
| **Boilerplate สำหรับ JSON** | ต้องเขียน JsonFormat implicit/given สำหรับทุก case class ด้วยตัวเอง (ไม่มี auto-derive แบบ circe) |
| **Memory Usage สูง** | JVM + Actor system ใช้ memory มากกว่า Go, Rust, Node.js สำหรับ simple service |
| **Fat JAR ใหญ่** | sbt-assembly สร้าง fat JAR ที่รวม dependencies ทั้งหมด ทำให้ไฟล์ใหญ่และ Docker image ใหญ่กว่า native binary |
| **Migration จาก Akka** | แม้จะ fork มาจาก Akka แต่ package name เปลี่ยน ต้อง migrate code ถ้าย้ายจาก Akka HTTP |

---

Scala microservice built with [Apache Pekko HTTP](https://pekko.apache.org/) that returns a sample loan-service JSON log entry.

## Prerequisites

- [JDK](https://adoptium.net/) >= 21
- [sbt](https://www.scala-sbt.org/) >= 1.10
- [Docker](https://www.docker.com/) (optional)

## Run

```bash
# Default (port 8080)
sbt run

# Custom port / log level
PORT=3000 LOG_LEVEL=DEBUG sbt run
```

Server starts at **http://localhost:8080**

## Swagger UI

Open **http://localhost:8080/swagger** in your browser to explore the API interactively.

The raw OpenAPI JSON spec is available at **http://localhost:8080/openapi.json**.

## Build

```bash
# Compile
sbt compile

# Fat JAR
sbt assembly
```

## Docker

```bash
# Build image
docker build -t scala-hello .

# Run container
docker run -p 8080:8080 scala-hello

# Run with custom config
docker run -p 3000:3000 -e PORT=3000 -e LOG_LEVEL=DEBUG scala-hello
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `HOST` | `0.0.0.0` | Bind address |
| `PORT` | `8080` | Listen port |
| `LOG_LEVEL` | `INFO` | Log level (`DEBUG`, `INFO`, `WARN`, `ERROR`) |

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
{ "status": "ok", "service": "scala-hello", "version": "1.0.0" }
```

## 12-Factor App

```
Scala-hello/
├── src/
│   └── main/
│       ├── scala/
│       │   └── com/example/loanhello/
│       │       ├── Main.scala        # Factor 3 (env vars), 7 (port binding), 9 (graceful shutdown)
│       │       ├── Routes.scala      # Factor 6 (stateless), 12 (admin — health, swagger)
│       │       └── Models.scala      # Domain models + JSON formats
│       └── resources/
│           ├── logback.xml           # Factor 11 (structured JSON logs)
│           └── openapi.json          # Factor 12 (API documentation)
├── build.sbt                         # Factor 2 (dependencies)
├── project/
│   ├── build.properties              # Factor 2 — sbt version lock
│   └── plugins.sbt                   # Factor 2 — sbt plugins
├── Dockerfile                        # Factor 5 (build/release/run)
├── .dockerignore                     # Build optimization
├── .env.example                      # Factor 3 — env template
└── Procfile                          # Factor 5 — process declaration
```

แต่ละข้อของ [The Twelve-Factor App](https://12factor.net/) ถูกนำมาใช้ใน project นี้ดังนี้:

### 1. Codebase — One codebase tracked in revision control

- Source code อยู่ใน Git repository เดียว (`microservice/Scala-hello`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`

### 2. Dependencies — Explicitly declare and isolate dependencies

- ประกาศ dependencies ทั้งหมดใน `build.sbt` พร้อม version ที่ชัดเจน
- sbt ดึง dependencies จาก Maven Central อัตโนมัติ ไม่ต้องติดตั้งแยก
- `sbt-assembly` สร้าง fat JAR ที่รวม dependencies ทั้งหมดในไฟล์เดียว
- Docker multi-stage build แยก build tools ออกจาก runtime image

### 3. Config — Store config in the environment

- `HOST`, `PORT`, `LOG_LEVEL` อ่านจาก environment variables ผ่าน `sys.env.getOrElse()`
- ไม่มี hardcode config ใน source code — ทุกค่ามี default แต่ override ได้ผ่าน env
- Dockerfile กำหนด `ENV HOST=0.0.0.0`, `ENV PORT=8080`, `ENV LOG_LEVEL=INFO`

### 4. Backing Services — Treat backing services as attached resources

- ปัจจุบัน project นี้ไม่มี backing service (database, cache, queue)
- หากเพิ่มในอนาคต จะใช้ env vars สำหรับ connection string เช่น `DATABASE_URL`

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: `sbt assembly` หรือ Docker multi-stage build (sbt image → compile + assembly)
- **Release**: Docker image (`scala-hello:latest`) รวม fat JAR + JRE + runtime config
- **Run**: `docker run -p 8080:8080 -e PORT=8080 scala-hello`
- Dockerfile แยก builder stage (sbt + JDK) กับ runtime stage (JRE Alpine) ชัดเจน

### 6. Processes — Execute the app as one or more stateless processes

- Application เป็น stateless process ตัวเดียว ไม่เก็บ state ใน memory หรือ disk
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage

### 7. Port Binding — Export services via port binding

- Pekko HTTP bind port ผ่าน `Http().newServerAt(host, port).bind()` ตาม env `PORT`
- Dockerfile ใช้ `EXPOSE 8080` และ run ด้วย `-p 8080:8080`
- เปลี่ยน port ได้ทันทีผ่าน `PORT=3000`

### 8. Concurrency — Scale out via the process model

- ใช้ Pekko Actor system + Streams รองรับ concurrent requests ภายใน process เดียว
- Reactive backpressure ป้องกัน overload อัตโนมัติ
- Scale horizontally ได้โดยรัน Docker container หลาย instance ด้วย load balancer

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- Startup เร็ว — JVM + fat JAR ไม่มี warm-up ที่ซับซ้อน
- Graceful shutdown ผ่าน `sys.addShutdownHook` รับ SIGTERM แล้ว terminate Actor system
- Pekko HTTP จะรอ request ที่กำลังทำอยู่จบก่อนปิด

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment
- Config ต่างกันเฉพาะ environment variables (`LOG_LEVEL=DEBUG` vs `LOG_LEVEL=INFO`)
- ไม่มี conditional code แยก dev/prod

### 11. Logs — Treat logs as event streams

- ใช้ Logback + LogstashEncoder ส่ง structured JSON logs ไปยัง stdout
- ควบคุม log level ผ่าน env `LOG_LEVEL` (เช่น `DEBUG`, `INFO`, `WARN`, `ERROR`)
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — health check สำหรับ Kubernetes liveness/readiness probe
- Swagger UI ที่ `/swagger` สำหรับ API documentation
- OpenAPI spec ที่ `/openapi.json` สำหรับ code generation
