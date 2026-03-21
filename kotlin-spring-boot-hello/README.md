# kotlin-spring-boot-hello

| Component | Responsibility |
|---|---|
| **Build Tool** | Gradle (Kotlin DSL) |
| **Dependency file** | build.gradle.kts |
| **Source Code** | src/main/kotlin/ |
| **Language** | Kotlin 2.1.20 + JDK 21 |

## Dependencies

| Library | Purpose |
|---|---|
| spring-boot-starter-web | Web framework (embedded Tomcat) |
| spring-boot-starter-actuator | Health check endpoints |
| springdoc-openapi-starter-webmvc-ui | Swagger UI / OpenAPI documentation |
| jackson-module-kotlin | Kotlin data class JSON serialization |
| kotlin-reflect | Spring reflection support for Kotlin |
| logstash-logback-encoder | Structured JSON logging |

## Kotlin + Spring Boot — ข้อดีและข้อเสีย

### ข้อดี (Pros)

| ข้อดี | รายละเอียด |
|---|---|
| **Concise Syntax** | Kotlin มี data class, null safety, extension functions ทำให้เขียนโค้ดสั้นกว่า Java 30-40% โดยยังคง type safety |
| **Null Safety** | Kotlin compiler บังคับจัดการ nullable types (`?`) ลด NullPointerException ที่เป็นปัญหาหลักใน Java |
| **Spring Boot Ecosystem** | ใช้ Spring Boot ecosystem ทั้งหมดได้เลย: Spring Data, Spring Security, Spring Cloud — library สำเร็จรูปมากที่สุด |
| **Coroutines** | รองรับ coroutines สำหรับ async programming ที่เขียนง่ายกว่า Java CompletableFuture หรือ reactive streams |
| **Java Interop 100%** | เรียก Java library ได้ทุกตัวโดยไม่ต้องแปลง — ใช้ร่วมกับ Java code ใน project เดียวกันได้ |
| **Production Ready** | Spring Boot 3.x + Kotlin เป็น first-class citizen มี official support จาก Spring team |
| **Smart Casts** | Kotlin compiler ทำ smart cast อัตโนมัติหลัง type check ไม่ต้อง cast เอง |
| **Extension Functions** | เพิ่ม function ให้ class ที่มีอยู่แล้วได้โดยไม่ต้อง inherit หรือ wrap — เหมาะกับ utility functions |
| **DSL Support** | Kotlin syntax เหมาะกับการเขียน DSL เช่น Gradle Kotlin DSL, Ktor routing, Spring Bean DSL |

### ข้อเสีย (Cons)

| ข้อเสีย | รายละเอียด |
|---|---|
| **Build Time ช้ากว่า Java** | Kotlin compiler ช้ากว่า Java ประมาณ 10-20% โดยเฉพาะ incremental build ที่มี annotation processing |
| **Spring Boot Startup ช้า** | Spring Boot ใช้ reflection มาก ทำให้ startup time 2-5 วินาที ช้ากว่า framework อื่น (Go, Rust, Node.js) |
| **Memory Usage สูง** | JVM-based ใช้ memory เริ่มต้น 100-200MB ขึ้นไป สูงกว่า Go, Rust, Node.js มาก |
| **Docker Image ใหญ่** | ต้องมี JRE ใน runtime image ทำให้ image size 200-400MB ใหญ่กว่า Go (10-20MB) หรือ Rust (5-10MB) |
| **Learning Curve สองชั้น** | ต้องเรียนทั้ง Kotlin syntax และ Spring Boot framework พร้อมกัน — ซับซ้อนกว่าใช้ภาษาเดียว |
| **Annotation Heavy** | Spring Boot ใช้ annotation มาก (`@RestController`, `@GetMapping`, `@Configuration`) อาจรู้สึก "magic" เกินไป |
| **Kotlin-specific Issues** | บาง library ต้องใช้ `kotlin("plugin.spring")` เพื่อ open class, `@JvmStatic` สำหรับ companion object — มี gotchas |

---

Kotlin microservice built with [Spring Boot](https://spring.io/projects/spring-boot) 3.4.4 that returns a sample loan-service JSON log entry.

## Prerequisites

- [JDK 21](https://adoptium.net/) (Eclipse Temurin recommended)
- [Gradle](https://gradle.org/) >= 8.x
- [Docker](https://www.docker.com/) (optional)

## Run

```bash
# Default (port 8080)
gradle bootRun

# Custom port / log level
PORT=9090 LOG_LEVEL=DEBUG gradle bootRun
```

Server starts at **http://localhost:8080**

## Swagger UI

Open **http://localhost:8080/swagger** in your browser to explore the API interactively.

The raw OpenAPI JSON spec is available at **http://localhost:8080/v3/api-docs**.

## Build

```bash
# Build JAR
gradle build

# Build without tests
gradle build -x test
```

## Docker

```bash
# Build image
docker build -t kotlin-spring-boot-hello .

# Run container
docker run -p 8080:8080 kotlin-spring-boot-hello

# Run with custom config
docker run -p 9090:9090 -e PORT=9090 -e LOG_LEVEL=DEBUG kotlin-spring-boot-hello
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8080` | Listen port |
| `SERVICE_NAME` | `loan-service` | Service name in response |
| `SERVICE_VERSION` | `1.2.0` | Service version in response |
| `SERVICE_ENV` | `production` | Environment name |
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
kotlin-spring-boot-hello/
├── src/main/kotlin/com/example/loanhello/
│   ├── LoanHelloApplication.kt       # Factor 9 (graceful shutdown via Spring)
│   ├── config/
│   │   ├── OpenApiConfig.kt          # Factor 12 (Swagger UI admin endpoint)
│   │   ├── RequestLoggingFilter.kt   # Factor 11 (structured JSON logging)
│   │   └── ServiceConfig.kt          # Factor 3 (env-based config via @ConfigurationProperties)
│   ├── controller/
│   │   ├── LoanController.kt         # Factor 6 (stateless), 7 (port binding)
│   │   └── SwaggerController.kt      # Factor 12 (/swagger redirect)
│   └── model/
│       ├── HealthResponse.kt         # Factor 12 (health check model)
│       └── LoanLogResponse.kt        # Data model with Kotlin data classes
├── src/main/resources/
│   ├── application.properties         # Factor 3 (env vars), 7 (port), 9 (graceful shutdown)
│   └── logback-spring.xml             # Factor 11 (JSON logs to stdout)
├── build.gradle.kts                   # Factor 2 (dependencies)
├── settings.gradle.kts                # Factor 2 (project settings)
├── Dockerfile                         # Factor 5 (build/release/run) — multi-stage
├── .env.example                       # Factor 3 (config documentation)
├── Procfile                           # Factor 5 (process declaration)
├── .dockerignore                      # Build optimization
└── .gitignore                         # VCS hygiene
```

แต่ละข้อของ [The Twelve-Factor App](https://12factor.net/) ถูกนำมาใช้ใน project นี้ดังนี้:

### 1. Codebase — One codebase tracked in revision control

- Source code อยู่ใน Git repository เดียว (`microservice/kotlin-spring-boot-hello`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`

### 2. Dependencies — Explicitly declare and isolate dependencies

- ประกาศ dependencies ทั้งหมดใน `build.gradle.kts` — Gradle จัดการ download + versioning
- ใช้ Spring BOM (`io.spring.dependency-management`) ควบคุม version ของ Spring dependencies
- Docker multi-stage build แยก build tools (Gradle + JDK) ออกจาก runtime (JRE only)

### 3. Config — Store config in the environment

- `PORT`, `SERVICE_NAME`, `SERVICE_VERSION`, `SERVICE_ENV`, `LOG_LEVEL` อ่านจาก environment variables
- `application.properties` ใช้ `${ENV_VAR:default}` syntax — Spring Boot resolve env vars อัตโนมัติ
- `ServiceConfig` ใช้ `@ConfigurationProperties` map env → Kotlin data class
- ไม่มี hardcode config ใน source code

### 4. Backing Services — Treat backing services as attached resources

- ปัจจุบัน project นี้ไม่มี backing service (database, cache, queue)
- หากเพิ่มในอนาคต จะใช้ env vars เช่น `DATABASE_URL`, `REDIS_URL` — Spring Boot auto-configure ได้

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: `gradle build` หรือ Docker multi-stage (`gradle:8-jdk21-alpine` → compile)
- **Release**: Docker image (`kotlin-spring-boot-hello:latest`) รวม JRE + app.jar + config
- **Run**: `docker run -p 8080:8080 kotlin-spring-boot-hello`
- Dockerfile แยก builder stage (Gradle + JDK) กับ runtime stage (`eclipse-temurin:21-jre-alpine`)

### 6. Processes — Execute the app as one or more stateless processes

- Application เป็น stateless process ตัวเดียว ไม่เก็บ state ใน memory หรือ disk
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage
- Spring Boot embedded Tomcat ทำงานเป็น single process

### 7. Port Binding — Export services via port binding

- Spring Boot bind port ผ่าน `server.port=${PORT:8080}` ใน application.properties
- Dockerfile ใช้ `EXPOSE 8080` และ run ด้วย `-p 8080:8080`
- เปลี่ยน port ได้ทันทีผ่าน `PORT=9090`

### 8. Concurrency — Scale out via the process model

- Spring Boot ใช้ thread pool (Tomcat) รองรับ concurrent requests ภายใน process เดียว
- Scale horizontally ได้โดยรัน Docker container หลาย instance ด้วย load balancer

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- Graceful shutdown ผ่าน `server.shutdown=graceful` + `spring.lifecycle.timeout-per-shutdown-phase=10s`
- Spring Boot รับ SIGTERM แล้วหยุดรับ request ใหม่ รอ request ที่กำลังทำอยู่จบก่อนปิด
- Dockerfile: `STOPSIGNAL SIGTERM`

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment
- Config ต่างกันเฉพาะ environment variables (`SERVICE_ENV=development` vs `SERVICE_ENV=production`)
- ไม่มี conditional code แยก dev/prod

### 11. Logs — Treat logs as event streams

- ใช้ `logstash-logback-encoder` ส่ง structured JSON logs ไปยัง stdout
- ควบคุม log level ผ่าน env `LOG_LEVEL` (เช่น `DEBUG`, `INFO`, `WARN`, `ERROR`)
- `RequestLoggingFilter` log ทุก HTTP request พร้อม method, path, status, duration_ms
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — health check สำหรับ Kubernetes liveness/readiness probe
- Swagger UI ที่ `/swagger` สำหรับ API documentation
- OpenAPI spec ที่ `/v3/api-docs` สำหรับ code generation
- Spring Actuator ที่ `/actuator/health` สำหรับ production monitoring
