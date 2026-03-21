# Microservice Monorepo

> microservice homework — 14 projects ใน 12 ภาษา/framework ส่งคืน JSON log entry เหมือนกันทุก service

## สรุป Component ของแต่ละ Project

### Java — Spring Boot (Maven)

| Component | Responsibility |
|---|---|
| **Package Manager** | Maven |
| **Dependency file** | pom.xml |
| **Source Code** | src/main/java/com/example/loanhello/ |
| **Config** | src/main/resources/application.properties |
| **OS executable file** | mvn package → target/*.jar |

### Java — Spring Boot (Gradle)

| Component | Responsibility |
|---|---|
| **Package Manager** | Gradle |
| **Dependency file** | build.gradle |
| **Source Code** | src/main/java/com/example/loanhello/ |
| **Config** | src/main/resources/application.properties |
| **OS executable file** | gradle build → build/libs/*.jar |

### Java — Quarkus

| Component | Responsibility |
|---|---|
| **Package Manager** | Maven |
| **Dependency file** | pom.xml |
| **Source Code** | src/main/java/com/example/loanhello/ |
| **Config** | src/main/resources/application.properties |
| **OS executable file** | mvn package → target/quarkus-app/quarkus-run.jar |

### JavaScript/TypeScript — NestJS

| Component | Responsibility |
|---|---|
| **Package Manager** | npm |
| **Dependency file** | package.json |
| **Source Code** | src/main.ts |
| **Runtime** | Node.js (Express) |

### PHP — Hyperf (Swoole)

| Component | Responsibility |
|---|---|
| **Package Manager** | composer |
| **Dependency file** | composer.json |
| **Source Code** | app/Controller/IndexController.php |
| **Runtime** | Swoole (PHP coroutine server) |

### Go — Gin

| Component | Responsibility |
|---|---|
| **Package Manager** | go mod |
| **Dependency file** | go.mod / go.sum |
| **Source Code** | main.go |
| **OS executable file** | go build → server |

### Dart — Serverpod

| Component | Responsibility |
|---|---|
| **Package Manager** | dart pub |
| **Dependency file** | pubspec.yaml |
| **Source Code** | bin/main.dart |
| **OS executable file** | dart compile exe → server |

### Python — FastAPI

| Component | Responsibility |
|---|---|
| **Package Manager** | pip |
| **Dependency file** | requirements.txt |
| **Source Code** | main.py |
| **OS executable file** | — (interpreted via Python) |

### C# — ASP.NET Core

| Component | Responsibility |
|---|---|
| **Package Manager** | NuGet (dotnet CLI) |
| **Dependency file** | CSharp-hello.csproj |
| **Source Code** | Program.cs |
| **OS executable file** | CSharp-hello.dll |

### Bash — socat

| Component | Responsibility |
|---|---|
| **Package Manager** | N/A (OS package: apk) |
| **Dependency file** | N/A (Dockerfile `apk add`) |
| **Source Code** | server.sh, handler.sh, lib.sh |
| **OS executable file** | bash scripts (interpreted) |

### Rust — Axum

| Component | Responsibility |
|---|---|
| **Package Manager** | cargo |
| **Dependency file** | Cargo.toml |
| **Source Code** | main.rs |
| **OS executable file** | cargo build → target/release/rust-hello |

### Kotlin — Spring Boot

| Component | Responsibility |
|---|---|
| **Build Tool** | Gradle (Kotlin DSL) |
| **Dependency file** | build.gradle.kts |
| **Source Code** | src/main/kotlin/ |
| **Language** | Kotlin 2.1.20 + JDK 21 |

### Scala — Pekko HTTP

| Component | Responsibility |
|---|---|
| **Build Tool** | sbt |
| **Dependency file** | build.sbt |
| **Source Code** | Main.scala, Routes.scala, Models.scala |
| **Fat JAR** | app.jar (sbt-assembly) |

### Lua — OpenResty

| Component | Responsibility |
|---|---|
| **Runtime** | OpenResty (Nginx + LuaJIT) |
| **Language** | Lua 5.1 (LuaJIT) |
| **Config file** | nginx.conf.template |
| **Source Code** | lua/app.lua |

---

## ตารางสรุปทุก Project

| # | Project | Language | Framework | Host Port | Container Port | URL |
|---|---|---|---|---|---|---|
| 1 | java-spring-boot-maven-hello | Java | Spring Boot 3.4 + Maven | 3001 | 8080 | http://localhost:3001 |
| 2 | java-spring-boot-gradle-hello | Java | Spring Boot 3.4 + Gradle | 3002 | 8080 | http://localhost:3002 |
| 3 | java-quarkus-hello | Java | Quarkus 3.17 | 3003 | 8080 | http://localhost:3003 |
| 4 | js-hello | TypeScript | NestJS (Express) | 3004 | 8080 | http://localhost:3004 |
| 5 | php-hello | PHP | Hyperf (Swoole) | 3005 | 8080 | http://localhost:3005 |
| 6 | go-hello | Go | Gin | 3007 | 3000 | http://localhost:3007 |
| 7 | dart-hello | Dart | Serverpod | 3008-3010 | 8080-8082 | http://localhost:3010 |
| 8 | python-hello | Python | FastAPI (Uvicorn) | 3011 | 9000 | http://localhost:3011 |
| 9 | CSharp-hello | C# | ASP.NET Core Minimal API | 3012 | 9090 | http://localhost:3012 |
| 10 | bash-hello | Bash | socat | 3013 | 3000 | http://localhost:3013 |
| 11 | rust-hello | Rust | Axum | 3014 | 8080 | http://localhost:3014 |
| 12 | kotlin-spring-boot-hello | Kotlin | Spring Boot 3.4.4 | 3015 | 9090 | http://localhost:3015 |
| 13 | Scala-hello | Scala | Apache Pekko HTTP | 3016 | 3000 | http://localhost:3016 |
| 14 | lua-hello | Lua (LuaJIT) | OpenResty (Nginx) | 3017 | 9090 | http://localhost:3017 |

> **หมายเหตุ**: php-hello ใช้ port เสริม 3006 → 9500 (Swagger), dart-hello ใช้ 3 ports (3008→8080 API, 3009→8081 Insights, 3010→8082 Web)

---

## Docker Orchestrator (`_docker-orchestrator`)

ใช้ `dockrun` CLI (เขียนด้วย Rust) เพื่อ start/stop ทุก service พร้อมกัน โดย **host port ไม่ซ้ำกัน**:

```bash
cd _docker-orchestrator
cargo build --release

# Start ทุก service
./target/release/dockrun up

# Start เฉพาะบาง service
./target/release/dockrun up -s rust-hello,go-hello

# ดูสถานะ
./target/release/dockrun status

# หยุดทุก service
./target/release/dockrun down
```

### Port Mapping (เรียงตาม Host Port)

| Host Port | Container Port | Service | URL |
|---|---|---|---|
| 3001 | 8080 | java-spring-boot-maven-hello | http://localhost:3001 |
| 3002 | 8080 | java-spring-boot-gradle-hello | http://localhost:3002 |
| 3003 | 8080 | java-quarkus-hello | http://localhost:3003 |
| 3004 | 8080 | js-hello | http://localhost:3004 |
| 3005 | 8080 | php-hello (API) | http://localhost:3005 |
| 3006 | 9500 | php-hello (Swagger) | http://localhost:3006 |
| 3007 | 3000 | go-hello | http://localhost:3007 |
| 3008 | 8080 | dart-hello (API) | http://localhost:3008 |
| 3009 | 8081 | dart-hello (Insights) | http://localhost:3009 |
| 3010 | 8082 | dart-hello (Web) | http://localhost:3010 |
| 3011 | 9000 | python-hello | http://localhost:3011 |
| 3012 | 9090 | csharp-hello | http://localhost:3012 |
| 3013 | 3000 | bash-hello | http://localhost:3013 |
| 3014 | 8080 | rust-hello | http://localhost:3014 |
| 3015 | 9090 | kotlin-spring-boot-hello | http://localhost:3015 |
| 3016 | 3000 | scala-hello | http://localhost:3016 |
| 3017 | 9090 | lua-hello | http://localhost:3017 |

### Docker Run — แต่ละ Project (host port unique)

```bash
# 1. Java Spring Boot (Maven)     — port 3001
docker run -d --name java-spring-boot-maven-hello \
  -p 3001:8080 -e SERVICE_NAME=my-service -e SERVICE_ENV=staging -e LOG_LEVEL=DEBUG \
  java-spring-boot-maven-hello

# 2. Java Spring Boot (Gradle)    — port 3002
docker run -d --name java-spring-boot-gradle-hello \
  -p 3002:8080 -e SERVICE_NAME=loan-service -e SERVICE_ENV=production -e LOG_LEVEL=INFO \
  java-spring-boot-gradle-hello

# 3. Java Quarkus                 — port 3003
docker run -d --name java-quarkus-hello \
  -p 3003:8080 -e SERVICE_NAME=loan-service -e SERVICE_ENV=production -e LOG_LEVEL=INFO \
  java-quarkus-hello

# 4. JavaScript/TypeScript NestJS — port 3004
docker run -d --name js-hello \
  -p 3004:8080 -e PORT=8080 -e LOG_LEVEL=debug \
  js-hello

# 5. PHP Hyperf (Swoole)          — port 3005 (API), 3006 (Swagger)
docker run -d --name php-hello \
  -p 3005:8080 -p 3006:9500 -e PORT=8080 -e LOG_LEVEL=debug \
  php-hello

# 6. Go Gin                       — port 3007
docker run -d --name go-hello \
  -p 3007:3000 -e SERVICE_NAME=my-service -e SERVICE_ENV=staging -e LOG_LEVEL=debug \
  go-hello

# 7. Dart Serverpod               — port 3008-3010
docker run -d --name dart-hello \
  -p 3008:8080 -p 3009:8081 -p 3010:8082 \
  -e SERVICE_NAME=my-service -e SERVICE_ENV=staging -e LOG_LEVEL=debug \
  dart-hello

# 8. Python FastAPI               — port 3011
docker run -d --name python-hello \
  -p 3011:9000 -e PORT=9000 -e LOG_LEVEL=debug \
  python-hello

# 9. C# ASP.NET Core              — port 3012
docker run -d --name csharp-hello \
  -p 3012:9090 -e PORT=9090 -e LOG_LEVEL=Debug \
  csharp-hello

# 10. Bash socat                  — port 3013
docker run -d --name bash-hello \
  -p 3013:3000 -e SERVICE_NAME=loan-service -e SERVICE_ENV=production -e LOG_LEVEL=info \
  bash-hello

# 11. Rust Axum                   — port 3014
docker run -d --name rust-hello \
  -p 3014:8080 -e PORT=8080 -e RUST_LOG=debug \
  rust-hello

# 12. Kotlin Spring Boot          — port 3015
docker run -d --name kotlin-spring-boot-hello \
  -p 3015:9090 -e PORT=9090 -e LOG_LEVEL=DEBUG \
  kotlin-spring-boot-hello

# 13. Scala Pekko HTTP            — port 3016
docker run -d --name scala-hello \
  -p 3016:3000 -e PORT=3000 -e LOG_LEVEL=DEBUG \
  scala-hello

# 14. Lua OpenResty               — port 3017
docker run -d --name lua-hello \
  -p 3017:9090 -e PORT=9090 -e SERVICE_NAME=my-service \
  lua-hello
```

---

## 12-Factor App — สรุป

ทุก project ใน monorepo นี้ออกแบบตามแนวคิด [The Twelve-Factor App](https://12factor.net/):

### 1. Codebase — One codebase tracked in revision control

- ทุก project อยู่ใน Git monorepo เดียว (`microservice/`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`
- แต่ละ project เป็น subdirectory ที่มี Dockerfile และ README เป็นของตัวเอง

### 2. Dependencies — Explicitly declare and isolate dependencies

| Project | Dependency File | Package Manager |
|---|---|---|
| java-spring-boot-maven-hello | pom.xml | Maven |
| java-spring-boot-gradle-hello | build.gradle | Gradle |
| java-quarkus-hello | pom.xml | Maven |
| js-hello | package.json | npm |
| php-hello | composer.json | Composer |
| go-hello | go.mod / go.sum | go mod |
| dart-hello | pubspec.yaml | dart pub |
| python-hello | requirements.txt | pip |
| CSharp-hello | CSharp-hello.csproj | NuGet |
| bash-hello | Dockerfile (apk add) | apk |
| rust-hello | Cargo.toml | cargo |
| kotlin-spring-boot-hello | build.gradle.kts | Gradle |
| Scala-hello | build.sbt | sbt |
| lua-hello | Dockerfile (apk add) | apk |

- ทุก project ประกาศ dependencies พร้อม version ที่ชัดเจน
- Docker multi-stage build แยก build tools ออกจาก runtime image

### 3. Config — Store config in the environment

- ทุก project อ่าน config จาก **environment variables** (PORT, LOG_LEVEL, SERVICE_NAME ฯลฯ)
- ไม่มี hardcode config ใน source code — มี default แต่ override ได้ผ่าน env
- แต่ละ project มี `.env.example` เป็น template

### 4. Backing Services — Treat backing services as attached resources

- ปัจจุบันทุก project ไม่มี backing service (database, cache, queue)
- ออกแบบให้พร้อมเพิ่ม — จะใช้ env vars สำหรับ connection string เช่น `DATABASE_URL`

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: Docker multi-stage build — stage 1 compile, stage 2 runtime image เท่านั้น
- **Release**: Docker image ที่รวม artifact + runtime + default config
- **Run**: `docker run` พร้อม env vars สำหรับ config เฉพาะ environment

| Project | Build Stage | Runtime Stage |
|---|---|---|
| Java (Maven) | eclipse-temurin + Maven | eclipse-temurin JRE |
| Java (Gradle) | eclipse-temurin + Gradle | eclipse-temurin JRE |
| Java (Quarkus) | eclipse-temurin + Maven | eclipse-temurin JRE |
| JS (NestJS) | node:22-alpine | node:22-alpine (slim) |
| PHP (Hyperf) | php:8.3-cli + Swoole | php:8.3-cli + Swoole |
| Go (Gin) | golang:alpine | alpine (static binary) |
| Dart (Serverpod) | dart:stable | alpine (native binary) |
| Python (FastAPI) | python:3.12-slim | python:3.12-slim |
| C# (ASP.NET) | dotnet/sdk | dotnet/aspnet |
| Bash (socat) | alpine (single stage) | alpine |
| Rust (Axum) | rust:alpine | alpine (static binary) |
| Kotlin (Spring Boot) | eclipse-temurin + Gradle | eclipse-temurin JRE |
| Scala (Pekko) | sbt + JDK 21 | eclipse-temurin JRE Alpine |
| Lua (OpenResty) | openresty/openresty:alpine | openresty/openresty:alpine |

### 6. Processes — Execute the app as one or more stateless processes

- ทุก service เป็น **stateless** — ไม่เก็บ state ใน memory หรือ disk
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage
- Scale ได้โดยรัน container หลาย instance

### 7. Port Binding — Export services via port binding

- ทุก service bind port ผ่าน env `PORT`
- Dockerfile ใช้ `EXPOSE` ตาม default port
- เปลี่ยน port ได้ทันทีผ่าน environment variable

### 8. Concurrency — Scale out via the process model

- ทุก service รันเป็น single process ใน Docker container
- Scale horizontally โดยรัน container หลาย instance ด้วย load balancer
- บาง framework มี built-in concurrency: Pekko Actor, Swoole coroutine, Go goroutine, Tokio async

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- ทุก project มี **graceful shutdown** — รับ SIGTERM แล้วปิด connection ก่อนจบ process
- Startup เร็ว — native binary (Go, Rust, Dart) < 10ms, JVM ~2-6s, Node.js ~1s
- Docker container ปิดได้ทันทีด้วย `docker stop`

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment (dev, staging, production)
- Config ต่างกันเฉพาะ environment variables
- ไม่มี conditional code แยก dev/prod

### 11. Logs — Treat logs as event streams

- ทุก service ส่ง **structured JSON logs** ไปยัง stdout
- ใช้ logging library ของแต่ละภาษา (Logback, Winston, Monolog, Zap, ฯลฯ)
- ควบคุม log level ผ่าน env `LOG_LEVEL`
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — health check สำหรับ Kubernetes liveness/readiness probe
- Swagger UI — ทุก project มี interactive API documentation
- OpenAPI spec — สำหรับ code generation และ API contract
