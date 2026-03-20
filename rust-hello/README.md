# rust-hello

| Component | Responsibility |
|---|---|
| **Package Manager** | cargo |
| **Dependency file** | Cargo.toml |
| **Source Code** | main.rs |
| **OS executable file** | |

## Dependencies

| Crate | Purpose |
|---|---|
| axum | Web framework |
| tokio | Async runtime |
| serde / serde_json | JSON serialization |
| tracing / tracing-subscriber | Structured JSON logging |
| utoipa / utoipa-swagger-ui | Swagger / OpenAPI documentation |

## Axum — ข้อดีและข้อเสีย

### ข้อดี (Pros)

| ข้อดี | รายละเอียด |
|---|---|
| **Performance สูงมาก** | Axum รันบน Tokio async runtime ใช้ zero-cost abstractions ของ Rust ทำให้ throughput สูงและ latency ต่ำ ติดอันดับต้น ๆ ใน TechEmpower benchmarks |
| **Memory Safety** | Rust compiler รับประกัน memory safety ไม่มี null pointer, data race, buffer overflow — ลด bug ที่พบบ่อยใน C/C++ โดยไม่ต้องใช้ garbage collector |
| **Type-safe Routing** | Extractor pattern (`Path`, `Query`, `Json`) ทำให้ request parsing เป็น type-safe ถ้า type ไม่ตรงจะ compile error แทนที่จะ runtime error |
| **Tower Ecosystem** | ใช้ `tower::Service` trait เป็น middleware layer ทำให้ใช้ middleware ร่วมกับ ecosystem อื่น ๆ ได้ (tonic, hyper) และเขียน middleware ที่ reusable |
| **Minimal & Modular** | Framework ไม่บังคับ ORM, template engine หรือ pattern ใด ๆ เลือกใช้เฉพาะที่ต้องการ ไม่มี bloat |
| **Tokio Integration** | เป็น first-class citizen ของ Tokio ecosystem ใช้ร่วมกับ tokio, hyper, tonic ได้อย่าง seamless |
| **Compile-time Guarantees** | Handler ที่ signature ผิดจะ compile ไม่ผ่าน ลดข้อผิดพลาดที่จะไปเจอตอน runtime |
| **Single Binary Deployment** | Compile เป็น static binary ตัวเดียว ไม่ต้องติดตั้ง runtime, interpreter หรือ dependency บน server — deploy ง่าย image size เล็ก |

### ข้อเสีย (Cons)

| ข้อเสีย | รายละเอียด |
|---|---|
| **Learning Curve สูง** | ต้องเข้าใจ ownership, borrowing, lifetimes, async/await, trait system ของ Rust ก่อน ซึ่งยากกว่า framework อื่นมาก |
| **Compile Time นาน** | Rust compile ช้ากว่า Go, Node.js, PHP มาก โดยเฉพาะ full build ครั้งแรก (รวม dependencies) อาจใช้เวลาหลายนาที |
| **Error Messages ซับซ้อน** | Async + generic + trait bound ทำให้ compiler error ยาวและอ่านยาก โดยเฉพาะเมื่อ handler signature ไม่ตรง |
| **Ecosystem ยังเล็กกว่า** | เทียบกับ Express (Node.js), Spring (Java), Laravel (PHP) แล้ว library และ middleware สำเร็จรูปน้อยกว่า ต้องเขียนเองบ่อยกว่า |
| **Boilerplate มากกว่า** | Rust บังคับ explicit error handling (`Result<T, E>`) และ type annotation ทำให้โค้ดยาวกว่า dynamic language สำหรับงานง่าย ๆ |
| **Async Complexity** | `Pin`, `Future`, `Send + Sync` bounds อาจทำให้สับสน โดยเฉพาะเมื่อใช้ closure หรือ shared state ข้าม async boundary |
| **Rapid Evolution** | Axum ยังพัฒนาเร็ว มี breaking changes ระหว่าง major version (เช่น 0.6 → 0.7 → 0.8) ต้อง migrate โค้ดเมื่ออัปเดต |

---


Rust microservice built with [Axum](https://github.com/tokio-rs/axum) that returns a sample loan-service JSON log entry.

## Prerequisites

- [Rust](https://www.rust-lang.org/tools/install) >= 1.94.0
- [Docker](https://www.docker.com/) (optional)

## Run

```bash
# Default (port 3000)
cargo run

# Custom port / log level
PORT=8080 RUST_LOG=debug cargo run
```

Server starts at **http://localhost:3000**

## Swagger UI

Open **http://localhost:3000/swagger-ui** in your browser to explore the API interactively.

The raw OpenAPI JSON spec is available at **http://localhost:3000/api-docs/openapi.json**.

## Build

```bash
# Debug
cargo build

# Release
cargo build --release
```

## Docker

```bash
# Build image
docker build -t rust-hello .

# Run container
docker run -p 3000:3000 rust-hello

# Run with custom config
docker run -p 8080:8080 -e PORT=8080 -e RUST_LOG=debug rust-hello
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `HOST` | `0.0.0.0` | Bind address |
| `PORT` | `3000` | Listen port |
| `RUST_LOG` | `info` | Log level (`debug`, `info`, `warn`, `error`) |

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
rust-hello/
├── src/
│   └── main.rs            # Factor 3 (env vars), 7 (port binding), 9 (graceful shutdown), 11 (structured logs)
├── Cargo.toml             # Factor 2 (dependencies) — explicit declaration
├── Cargo.lock             # Factor 2 — lock file for reproducible builds
├── Dockerfile             # Factor 5 (build/release/run) — multi-stage build
└── .dockerignore          # Build optimization
```

แต่ละข้อของ [The Twelve-Factor App](https://12factor.net/) ถูกนำมาใช้ใน project นี้ดังนี้:

### 1. Codebase — One codebase tracked in revision control

- Source code อยู่ใน Git repository เดียว (`microservice/rust-hello`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`

### 2. Dependencies — Explicitly declare and isolate dependencies

- ประกาศ dependencies ทั้งหมดใน `Cargo.toml` พร้อม lock file `Cargo.lock`
- `cargo build` จะดึง dependencies จาก crates.io โดยอัตโนมัติ ไม่ต้องติดตั้งแยก
- Docker multi-stage build ทำให้ runtime image มีแค่ binary เดียว ไม่มี dependency leak

### 3. Config — Store config in the environment

- `HOST`, `PORT`, `RUST_LOG` อ่านจาก environment variables ผ่าน `std::env::var()`
- ไม่มี hardcode config ใน source code — ทุกค่ามี default แต่ override ได้ผ่าน env
- Dockerfile กำหนด `ENV HOST=0.0.0.0`, `ENV PORT=3000`, `ENV RUST_LOG=info`

### 4. Backing Services — Treat backing services as attached resources

- ปัจจุบัน project นี้ไม่มี backing service (database, cache, queue)
- หากเพิ่มในอนาคต จะใช้ env vars สำหรับ connection string เช่น `DATABASE_URL`

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: `cargo build --release` หรือ Docker multi-stage build (`rust:1.94-slim` → compile)
- **Release**: Docker image (`rust-hello:latest`) รวม binary + runtime config
- **Run**: `docker run -p 3000:3000 -e PORT=3000 rust-hello`
- Dockerfile แยก builder stage กับ runtime stage (`debian:bookworm-slim`) ชัดเจน

### 6. Processes — Execute the app as one or more stateless processes

- Application เป็น stateless process ตัวเดียว ไม่เก็บ state ใน memory หรือ disk
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage

### 7. Port Binding — Export services via port binding

- Axum bind port ผ่าน `TcpListener::bind()` ตาม env `PORT`
- Dockerfile ใช้ `EXPOSE 3000` และ run ด้วย `-p 3000:3000`
- เปลี่ยน port ได้ทันทีผ่าน `PORT=8080`

### 8. Concurrency — Scale out via the process model

- ใช้ Tokio async runtime รองรับ concurrent requests ภายใน process เดียว
- Scale horizontally ได้โดยรัน Docker container หลาย instance ด้วย load balancer

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- Startup เร็ว — binary เดียว ไม่มี warm-up
- Graceful shutdown รับ SIGTERM/SIGINT แล้วหยุดรับ request ใหม่ รอ request ที่กำลังทำอยู่จบก่อนปิด
- ใช้ `axum::serve().with_graceful_shutdown()` ร่วมกับ `tokio::signal`

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment
- Config ต่างกันเฉพาะ environment variables (`RUST_LOG=debug` vs `RUST_LOG=info`)
- ไม่มี conditional code แยก dev/prod

### 11. Logs — Treat logs as event streams

- ใช้ `tracing-subscriber` ส่ง structured JSON logs ไปยัง stdout
- ควบคุม log level ผ่าน env `RUST_LOG` (เช่น `debug`, `info`, `warn`, `error`)
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — health check สำหรับ Kubernetes liveness/readiness probe
- Swagger UI ที่ `/swagger-ui` สำหรับ API documentation
- OpenAPI spec ที่ `/api-docs/openapi.json` สำหรับ code generation
