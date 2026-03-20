# java-spring-boot-maven-hello

| Component | Responsibility |
|---|---|
| **Package Manager** | Maven |
| **Dependency file** | pom.xml |
| **Source Code** | src/main/java/com/example/loanhello/ |
| **Config** | src/main/resources/application.properties |
| **OS executable file** | mvn package → target/*.jar |

## Dependencies

| Package | Purpose |
|---|---|
| spring-boot-starter-web | Spring MVC + embedded Tomcat |
| spring-boot-starter-actuator | Health check & monitoring endpoints |
| springdoc-openapi-starter-webmvc-ui | Swagger UI & OpenAPI spec generation |
| logstash-logback-encoder | Structured JSON logging via Logback |

## Spring Boot — ข้อดีและข้อเสีย

### ข้อดี (Pros)

| ข้อดี | รายละเอียด |
|---|---|
| **Auto-configuration** | Spring Boot ตั้งค่า bean อัตโนมัติตาม classpath ไม่ต้องเขียน XML configuration ลด boilerplate code มหาศาล |
| **Ecosystem ใหญ่ที่สุด** | Spring ecosystem มี library ครอบคลุมทุกงาน — Security, Data, Cloud, Batch, Integration |
| **Production-ready** | Actuator ให้ health check, metrics, tracing ในตัว พร้อม deploy production ทันที |
| **Community & Documentation** | Community ใหญ่ที่สุดใน Java มี documentation ครบ, Stack Overflow, tutorials เยอะมาก |
| **Type safety** | Java เป็น statically typed ทำให้จับ bug ได้ตั้งแต่ compile time IDE support ดีเยี่ยม |
| **Maven/Gradle** | Build tool ที่ mature มี dependency management, plugin ecosystem, reproducible builds |
| **Embedded server** | Tomcat/Jetty/Undertow แบบ embedded ไม่ต้อง deploy WAR file ลง application server แยก |
| **Swagger ง่ายมาก** | springdoc-openapi scan annotations อัตโนมัติ ไม่ต้องเขียน spec file แยก |

### ข้อเสีย (Cons)

| ข้อเสีย | รายละเอียด |
|---|---|
| **Startup ช้า** | Spring Boot startup ช้ากว่า framework อื่น (1-5 วินาที) เพราะ component scanning & auto-configuration |
| **Memory usage สูง** | JVM ใช้ memory เยอะ (200MB+) เทียบกับ Go/Rust ที่ใช้ 10-30MB |
| **Docker image ใหญ่** | JRE + dependencies ทำให้ image 200-400MB เทียบกับ Go/Rust ที่ 10-30MB |
| **Boilerplate ยังเยอะ** | แม้มี auto-config แต่ Java ยังต้องเขียน annotations, getters/setters (record ช่วยได้บ้าง) |
| **Learning curve สูง** | Spring มี concept เยอะ — IoC, AOP, Bean lifecycle, auto-configuration magic |
| **Overhead จาก reflection** | Spring ใช้ reflection หนัก ทำให้ startup ช้าและ debug ยาก |
| **GraalVM native ยังไม่สมบูรณ์** | Native image ช่วยเรื่อง startup แต่ build ช้า และไม่รองรับ library ทุกตัว |

---

Java microservice built with [Spring Boot 3.4](https://spring.io/projects/spring-boot) + [Maven](https://maven.apache.org/) that returns a sample loan-service JSON log entry.

## Prerequisites

- [Docker](https://www.docker.com/) (recommended)
- [Java](https://adoptium.net/) >= 21 (optional, for local development)
- [Maven](https://maven.apache.org/) >= 3.9 (optional, for local development)

## Run

```bash
# Local development (requires Java SDK + Maven)
mvn spring-boot:run

# Using Docker (no Java SDK required)
docker build -t java-spring-boot-maven-hello .
docker run -p 8080:8080 java-spring-boot-maven-hello

# Custom config
docker run -p 8080:8080 \
  -e SERVICE_NAME=my-service \
  -e SERVICE_ENV=staging \
  -e LOG_LEVEL=DEBUG \
  java-spring-boot-maven-hello
```

Server starts at **http://localhost:8080**

## Swagger UI

Open **http://localhost:8080/swagger/index.html** in your browser to explore the API interactively.

The raw OpenAPI JSON spec is available at **http://localhost:8080/v3/api-docs**.

The static OpenAPI spec file is at [openapi.json](openapi.json).

## Build

```bash
# Development
mvn spring-boot:run

# Production (compile to JAR)
mvn package -DskipTests
java -jar target/*.jar
```

## Docker

```bash
# Build image
docker build -t java-spring-boot-maven-hello .

# Run container
docker run -p 8080:8080 java-spring-boot-maven-hello

# Run with custom config
docker run -p 8080:8080 \
  -e SERVICE_NAME=loan-service \
  -e SERVICE_ENV=production \
  -e LOG_LEVEL=INFO \
  java-spring-boot-maven-hello
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
java-spring-boot-maven-hello/
├── pom.xml                                          # Factor 2 (dependencies)
├── src/
│   └── main/
│       ├── java/com/example/loanhello/
│       │   ├── LoanHelloApplication.java            # Factor 9 (startup/shutdown logging)
│       │   ├── config/
│       │   │   ├── ServiceConfig.java               # Factor 3 (config from env)
│       │   │   ├── OpenApiConfig.java               # Swagger/OpenAPI config
│       │   │   └── RequestLoggingFilter.java        # Factor 11 (structured access logs)
│       │   ├── controller/
│       │   │   ├── LoanController.java              # Factor 7 (port binding), 6 (stateless), 12 (admin)
│       │   │   └── SwaggerController.java           # Swagger UI routing
│       │   └── model/
│       │       ├── LoanLogResponse.java             # Domain model (response DTO)
│       │       └── HealthResponse.java              # Health check DTO
│       └── resources/
│           ├── application.properties               # Factor 3 (config), 7 (port), 9 (graceful shutdown)
│           ├── logback-spring.xml                   # Factor 11 (structured JSON logs to stdout)
│           └── static/
│               └── swagger.html                     # Swagger UI (CDN-based, StandalonePreset)
├── openapi.json                                     # OpenAPI 3.0.3 spec (static)
├── Dockerfile                                       # Factor 5 (build/release/run) — multi-stage
├── Procfile                                         # Factor 6 (processes)
├── .env.example                                     # Factor 3 (config reference)
├── .gitignore
└── .dockerignore
```

แต่ละข้อของ [The Twelve-Factor App](https://12factor.net/) ถูกนำมาใช้ใน project นี้ดังนี้:

### 1. Codebase — One codebase tracked in revision control

- Source code อยู่ใน Git repository เดียว (`microservice/java-spring-boot-maven-hello`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`

### 2. Dependencies — Explicitly declare and isolate dependencies

- ประกาศ dependencies ทั้งหมดใน `pom.xml` (Maven) พร้อม version ชัดเจน
- Spring Boot parent POM จัดการ dependency versions ให้เข้ากันอัตโนมัติ
- Docker multi-stage build: builder stage ดึง dependencies, runtime stage มีแค่ JRE + JAR

### 3. Config — Store config in the environment

- `ServiceConfig` class อ่าน env vars ผ่าน Spring `@Value` annotations ตอน startup
- `PORT`, `SERVICE_NAME`, `SERVICE_VERSION`, `SERVICE_ENV`, `LOG_LEVEL` อ่านจาก environment variables
- ไม่มี hardcode config ใน source code — ทุกค่ามี default แต่ override ได้ผ่าน env
- `application.properties` ใช้ `${ENV_VAR:default}` syntax

### 4. Backing Services — Treat backing services as attached resources

- ปัจจุบัน project นี้ไม่มี backing service (database, cache, queue)
- หากเพิ่มในอนาคต จะใช้ Spring Boot auto-configuration + env vars สำหรับ connection string เช่น `SPRING_DATASOURCE_URL`

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: `mvn package` หรือ Docker multi-stage build (`maven:3-eclipse-temurin-21-alpine` → compile)
- **Release**: Docker image (`java-spring-boot-maven-hello:latest`) รวม JRE + JAR
- **Run**: `docker run -p 8080:8080 java-spring-boot-maven-hello`
- Dockerfile แยก builder stage กับ runtime stage (`eclipse-temurin:21-jre-alpine`) ชัดเจน

### 6. Processes — Execute the app as one or more stateless processes

- Application เป็น stateless process ตัวเดียว ไม่เก็บ state ใน memory หรือ disk
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage
- Procfile ประกาศ process type: `web: java -jar target/*.jar`

### 7. Port Binding — Export services via port binding

- ใช้ embedded Tomcat bind port ตาม env `PORT` (default 8080)
- Self-contained HTTP server — ไม่ต้อง deploy WAR ลง application server
- Dockerfile ใช้ `EXPOSE 8080` และ run ด้วย `-p 8080:8080`

### 8. Concurrency — Scale out via the process model

- Tomcat ใช้ thread pool รองรับ concurrent requests ภายใน process เดียว (default 200 threads)
- Scale horizontally ได้โดยรัน Docker container หลาย instance ด้วย load balancer
- Virtual threads (Java 21) สามารถเพิ่ม concurrency ได้อีกในอนาคต

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- Spring Boot 3.4 startup 1-3 วินาที — ยอมรับได้สำหรับ JVM application
- `server.shutdown=graceful` + `spring.lifecycle.timeout-per-shutdown-phase=10s` drain connections ภายใน 10 วินาทีก่อน shutdown
- Dockerfile ใช้ `STOPSIGNAL SIGTERM` ให้ Docker ส่ง SIGTERM แทน SIGKILL
- JVM handles SIGTERM → Spring ApplicationContext close → graceful shutdown
- `@EventListener(ApplicationReadyEvent.class)` และ `@EventListener(ContextClosedEvent.class)` log startup/shutdown events

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment
- Config ต่างกันเฉพาะ environment variables (`SERVICE_ENV=staging` vs `SERVICE_ENV=production`)
- Spring profiles สามารถใช้เพิ่มเติมได้ แต่ default ใช้ env vars ตาม 12-factor

### 11. Logs — Treat logs as event streams

- ใช้ `logstash-logback-encoder` ส่ง structured JSON logs ไปยัง stdout
- `logback-spring.xml` configure ConsoleAppender + LogstashEncoder
- `RequestLoggingFilter` บันทึก access log ทุก request (method, path, status, duration_ms, ip, user_agent) เป็น structured JSON
- `LoanHelloApplication` log startup/shutdown events พร้อม structured fields (port, environment, log_level)
- ควบคุม log level ผ่าน env `LOG_LEVEL` — filter ตาม priority: `DEBUG` < `INFO` < `WARN` < `ERROR`
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — health check สำหรับ Kubernetes liveness/readiness probe
- Spring Boot Actuator `/actuator/health` — built-in health endpoint
- Swagger UI ที่ `/swagger/index.html` สำหรับ API documentation
- OpenAPI spec ที่ `/v3/api-docs` สำหรับ code generation
