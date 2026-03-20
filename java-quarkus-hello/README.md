# java-quarkus-hello

| Component | Responsibility |
|---|---|
| **Package Manager** | Maven |
| **Dependency file** | pom.xml |
| **Source Code** | src/main/java/com/example/loanhello/ |
| **Config** | src/main/resources/application.properties |
| **OS executable file** | mvn package → target/quarkus-app/quarkus-run.jar |

## Dependencies

| Package | Purpose |
|---|---|
| quarkus-rest-jackson | RESTEasy Reactive + Jackson JSON serialization |
| quarkus-smallrye-health | Health check endpoints (liveness/readiness) |
| quarkus-smallrye-openapi | Swagger UI & OpenAPI spec generation |
| quarkus-logging-json | Structured JSON logging to stdout |

## Quarkus — ข้อดีและข้อเสีย

### ข้อดี (Pros)

| ข้อดี | รายละเอียด |
|---|---|
| **Startup เร็วมาก** | Quarkus ทำ build-time optimization ย้าย metadata processing ไปตอน compile ทำให้ startup เร็ว 0.5-2 วินาที เทียบกับ Spring Boot 2-5 วินาที |
| **Memory ต่ำ** | ใช้ memory น้อยกว่า Spring Boot 30-50% เนื่องจาก build-time augmentation ลด reflection และ class loading ตอน runtime |
| **GraalVM Native Image** | รองรับ native compilation เต็มรูปแบบ startup < 50ms, memory < 50MB เหมาะกับ serverless/FaaS |
| **Developer Joy** | Live reload ด้วย `quarkus dev` — แก้โค้ดแล้วเห็นผลทันทีไม่ต้อง restart, Dev UI ดู config/health/OpenAPI ในตัว |
| **MicroProfile Standard** | ใช้ MicroProfile APIs (Config, Health, OpenAPI, Metrics, JWT) ที่เป็น standard ไม่ lock-in กับ vendor |
| **CDI (Contexts & DI)** | Dependency Injection แบบ type-safe ใช้ ArC (build-time CDI) เร็วกว่า Spring reflection-based DI |
| **Reactive-first** | RESTEasy Reactive + Vert.x event loop ทำให้ non-blocking I/O ทำงานได้ดีกว่า thread-per-request model |
| **Extension Ecosystem** | 500+ extensions สำหรับ Kafka, gRPC, GraphQL, Hibernate, Redis, MongoDB ติดตั้งง่ายผ่าน `quarkus ext add` |
| **Kubernetes-native** | สร้าง Kubernetes manifests, Dockerfile อัตโนมัติ เหมาะกับ cloud-native deployment |

### ข้อเสีย (Cons)

| ข้อเสีย | รายละเอียด |
|---|---|
| **Community เล็กกว่า Spring** | Spring มี community ใหญ่กว่ามาก มี tutorials, Stack Overflow answers เยอะกว่า การหา solution อาจยากกว่า |
| **Library ไม่ครบเท่า** | Spring ecosystem มี library มากกว่า โดยเฉพาะ enterprise integrations บาง library ยังไม่มี Quarkus extension |
| **Learning curve สำหรับ Spring dev** | Developer ที่คุ้น Spring ต้องเรียนรู้ MicroProfile, CDI annotations, Quarkus-specific config ใหม่ |
| **Native build ช้ามาก** | GraalVM native image build ใช้เวลา 3-10 นาที, memory 5-8GB ไม่เหมาะกับ CI ที่ resource จำกัด |
| **Native ไม่รองรับทุก library** | Reflection-heavy libraries อาจไม่ทำงานกับ native image ต้อง configure registration hints เพิ่ม |
| **Documentation กระจัดกระจาย** | Documentation อยู่หลายที่ (Quarkus guides, MicroProfile spec, SmallRye docs) ต้องสลับไปมา |
| **Breaking changes บ่อย** | Quarkus ออก version ใหม่บ่อย (ทุก ~3 สัปดาห์) อาจมี breaking changes ต้อง update ถี่ |

---

Java microservice built with [Quarkus 3.17](https://quarkus.io/) that returns a sample loan-service JSON log entry.

## Prerequisites

- [Docker](https://www.docker.com/) (recommended)
- [Java](https://adoptium.net/) >= 21 (optional, for local development)
- [Maven](https://maven.apache.org/) >= 3.9 (optional, for local development)

## Run

```bash
# Default (port 8080, with live reload)
mvn quarkus:dev

# Custom port / config
PORT=9090 SERVICE_ENV=staging LOG_LEVEL=DEBUG mvn quarkus:dev
```

Server starts at **http://localhost:8080**

## Swagger UI

Open **http://localhost:8080/swagger** in your browser to explore the API interactively.

The raw OpenAPI spec is available at **http://localhost:8080/q/openapi**.

The static OpenAPI spec file is at [openapi.json](openapi.json).

## Build

```bash
# Development (with live reload)
mvn quarkus:dev

# Production (compile to fast-jar)
mvn package -DskipTests
java -jar target/quarkus-app/quarkus-run.jar
```

## Docker

```bash
# Build image
docker build -t java-quarkus-hello .

# Run container
docker run -p 8080:8080 java-quarkus-hello

# Run with custom config
docker run -p 8080:8080 \
  -e SERVICE_NAME=loan-service \
  -e SERVICE_ENV=production \
  -e LOG_LEVEL=INFO \
  java-quarkus-hello
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8080` | Server listen port |
| `SERVICE_NAME` | `loan-service` | Service name in logs & response |
| `SERVICE_VERSION` | `1.2.0` | Service version in logs & response |
| `SERVICE_ENV` | `production` | Environment name (`production`, `staging`, `development`) |
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
{ "status": "ok", "service": "loan-service", "version": "1.2.0" }
```

## 12-Factor App

```
java-quarkus-hello/
├── pom.xml                                          # Factor 2 (dependencies)
├── src/
│   └── main/
│       ├── java/com/example/loanhello/
│       │   ├── config/
│       │   │   ├── ServiceConfig.java               # Factor 3 (config from env)
│       │   │   ├── AppLifecycle.java                # Factor 9 (startup/shutdown logging)
│       │   │   ├── RequestLoggingFilter.java        # Factor 11 (structured access logs)
│       │   │   └── RequestTimingFilter.java         # Factor 11 (request timing)
│       │   ├── resource/
│       │   │   └── LoanResource.java                # Factor 7 (port binding), 6 (stateless), 12 (admin)
│       │   └── model/
│       │       ├── LoanLogResponse.java             # Domain model (response DTO)
│       │       └── HealthResponse.java              # Health check DTO
│       └── resources/
│           └── application.properties               # Factor 3 (config), 7 (port), 9 (graceful shutdown)
├── openapi.json                                     # OpenAPI 3.0.3 spec (static)
├── Dockerfile                                       # Factor 5 (build/release/run) — multi-stage
├── Procfile                                         # Factor 6 (processes)
├── .env.example                                     # Factor 3 (config reference)
├── .gitignore
└── .dockerignore
```

แต่ละข้อของ [The Twelve-Factor App](https://12factor.net/) ถูกนำมาใช้ใน project นี้ดังนี้:

### 1. Codebase — One codebase tracked in revision control

- Source code อยู่ใน Git repository เดียว (`microservice/java-quarkus-hello`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`

### 2. Dependencies — Explicitly declare and isolate dependencies

- ประกาศ dependencies ทั้งหมดใน `pom.xml` (Maven) พร้อม Quarkus BOM จัดการ version ให้เข้ากันอัตโนมัติ
- `mvn package` ดึง dependencies จาก Maven Central โดยอัตโนมัติ
- Docker multi-stage build: builder stage ดึง dependencies, runtime stage มีแค่ JRE + fast-jar

### 3. Config — Store config in the environment

- `ServiceConfig` interface อ่าน env vars ผ่าน MicroProfile Config (`@ConfigMapping`) ตอน startup
- `PORT`, `SERVICE_NAME`, `SERVICE_VERSION`, `SERVICE_ENV`, `LOG_LEVEL` อ่านจาก environment variables
- ไม่มี hardcode config ใน source code — ทุกค่ามี default แต่ override ได้ผ่าน env
- `application.properties` ใช้ `${ENV_VAR:default}` syntax

### 4. Backing Services — Treat backing services as attached resources

- ปัจจุบัน project นี้ไม่มี backing service (database, cache, queue)
- หากเพิ่มในอนาคต จะใช้ Quarkus extensions + env vars สำหรับ connection string เช่น `QUARKUS_DATASOURCE_JDBC_URL`

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: `mvn package` หรือ Docker multi-stage build (`maven:3-eclipse-temurin-21-alpine` → compile)
- **Release**: Docker image (`java-quarkus-hello:latest`) รวม JRE + fast-jar
- **Run**: `docker run -p 8080:8080 java-quarkus-hello`
- Dockerfile แยก builder stage กับ runtime stage (`eclipse-temurin:21-jre-alpine`) ชัดเจน

### 6. Processes — Execute the app as one or more stateless processes

- Application เป็น stateless process ตัวเดียว ไม่เก็บ state ใน memory หรือ disk
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage
- Procfile ประกาศ process type: `web: java -jar target/quarkus-app/quarkus-run.jar`

### 7. Port Binding — Export services via port binding

- ใช้ Vert.x HTTP server bind port ตาม env `PORT` (default 8080)
- Self-contained HTTP server — ไม่ต้อง deploy WAR ลง application server
- Dockerfile ใช้ `EXPOSE 8080` และ run ด้วย `-p 8080:8080`

### 8. Concurrency — Scale out via the process model

- Quarkus ใช้ Vert.x event loop + worker thread pool รองรับ concurrent requests
- RESTEasy Reactive ทำงานบน I/O thread โดยตรง — ไม่ต้อง switch thread pool
- Scale horizontally ได้โดยรัน Docker container หลาย instance ด้วย load balancer

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- Quarkus startup 0.5-2 วินาที — เร็วกว่า Spring Boot เพราะ build-time augmentation
- `quarkus.shutdown.timeout=10s` drain connections ภายใน 10 วินาทีก่อน shutdown
- Dockerfile ใช้ `STOPSIGNAL SIGTERM` ให้ Docker ส่ง SIGTERM แทน SIGKILL
- `AppLifecycle` class observe `StartupEvent` และ `ShutdownEvent` สำหรับ logging

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment
- Config ต่างกันเฉพาะ environment variables (`SERVICE_ENV=staging` vs `SERVICE_ENV=production`)
- Quarkus profiles สามารถใช้เพิ่มเติมได้ แต่ default ใช้ env vars ตาม 12-factor

### 11. Logs — Treat logs as event streams

- ใช้ `quarkus-logging-json` ส่ง structured JSON logs ไปยัง stdout
- `RequestLoggingFilter` + `RequestTimingFilter` บันทึก access log ทุก request (method, path, status, duration_ms, ip, user_agent)
- `AppLifecycle` log startup/shutdown events
- ควบคุม log level ผ่าน env `LOG_LEVEL` — filter ตาม priority: `DEBUG` < `INFO` < `WARN` < `ERROR`
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — custom health check endpoint
- SmallRye Health `/q/health` — built-in liveness/readiness probes
- Swagger UI ที่ `/swagger` สำหรับ API documentation
- OpenAPI spec ที่ `/q/openapi` สำหรับ code generation
