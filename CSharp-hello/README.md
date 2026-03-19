# CSharp-hello

| Component | Responsibility |
|---|---|
| **Package Manager** | NuGet (dotnet CLI) |
| **Dependency file** | CSharp-hello.csproj |
| **Source Code** | Program.cs |
| **OS executable file** | CSharp-hello.dll |

## Dependencies

| Package | Purpose |
|---|---|
| Microsoft.AspNetCore.OpenApi | OpenAPI metadata for Minimal API |
| Swashbuckle.AspNetCore | Swagger UI / OpenAPI documentation |

## ASP.NET Core Minimal API — ข้อดีและข้อเสีย

### ข้อดี (Pros)

| ข้อดี | รายละเอียด |
|---|---|
| **Performance สูงมาก** | Kestrel web server เป็นหนึ่งใน web server ที่เร็วที่สุด ติดอันดับต้น ๆ ใน TechEmpower benchmarks รองรับ millions of requests/sec |
| **Type Safety** | C# เป็น statically typed language มี compile-time checking ช่วยจับ bug ก่อน runtime |
| **Minimal API** | .NET 6+ รองรับ Minimal API เขียนโค้ดสั้นกระชับเหมือน Express/FastAPI ไม่ต้องมี Controller class |
| **Ecosystem ใหญ่และ mature** | NuGet มี packages มากกว่า 300,000+ รองรับ Entity Framework, SignalR, gRPC, Identity ครบ built-in |
| **Cross-platform** | .NET 8 รันได้บน Windows, Linux, macOS ด้วย binary เดียวกัน Docker image ใช้ base image ขนาดเล็ก |
| **Built-in DI & Middleware** | Dependency Injection เป็น first-class citizen มี middleware pipeline ที่แข็งแกร่ง ไม่ต้องติดตั้ง library เพิ่ม |
| **Long-term Support** | Microsoft ให้ LTS 3 ปี (.NET 8 LTS ถึง 2026) มี enterprise support, security patches สม่ำเสมอ |
| **AOT Compilation** | .NET 8 รองรับ Native AOT compile เป็น native binary ได้ startup เร็ว memory ต่ำ เหมาะกับ serverless |

### ข้อเสีย (Cons)

| ข้อเสีย | รายละเอียด |
|---|---|
| **Learning Curve ปานกลาง** | ต้องเข้าใจ C# syntax, async/await, DI container, middleware pipeline ซึ่งซับซ้อนกว่า Node.js/Python |
| **Memory Usage สูงกว่า Go/Rust** | .NET runtime + GC ใช้ memory มากกว่า compiled language โดยเฉพาะ cold start |
| **Docker Image ใหญ่** | Base image `aspnet:8.0` มีขนาด ~220MB ใหญ่กว่า Go/Rust binary image มาก แม้ใช้ Alpine ก็ยังใหญ่ |
| **Versioning ซับซ้อน** | .NET มีหลาย SDK/Runtime version (.NET 6, 7, 8) และ breaking changes ระหว่าง major version ต้องจัดการ migration |
| **Cold Start ช้ากว่า native** | JIT compilation ทำให้ first request ช้ากว่า compiled binary (แก้ได้ด้วย AOT แต่ยังมีข้อจำกัด) |
| **Over-engineering ง่าย** | Ecosystem ที่ใหญ่ทำให้มักเพิ่ม abstraction layers มากเกินจำเป็น (Controller, Service, Repository pattern) |
| **Community เล็กกว่า Node.js/Python** | แม้จะใหญ่ แต่ community open-source น้อยกว่า JavaScript/Python โดยเฉพาะใน startup/cloud-native space |

---

C# microservice built with [ASP.NET Core Minimal API](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/minimal-apis) (.NET 8) that returns a sample loan-service JSON log entry.

## Prerequisites

- [.NET SDK](https://dotnet.microsoft.com/download) >= 8.0
- [Docker](https://www.docker.com/) (optional)

## Run

```bash
# Default (port 8080)
dotnet run

# Custom port / log level
HOST=0.0.0.0 PORT=9090 LOG_LEVEL=Debug dotnet run
```

Server starts at **http://localhost:8080**

## Swagger UI

Open **http://localhost:8080/swagger** in your browser to explore the API interactively.

The raw OpenAPI JSON spec is available at **http://localhost:8080/swagger/v1/swagger.json**.

## Build

```bash
# Debug
dotnet build

# Release
dotnet publish -c Release -o ./publish
```

## Docker

```bash
# Build image
docker build -t csharp-hello .

# Run container
docker run -p 8080:8080 csharp-hello

# Run with custom config
docker run -p 9090:9090 -e PORT=9090 -e LOG_LEVEL=Debug csharp-hello
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `HOST` | `0.0.0.0` | Bind address |
| `PORT` | `8080` | Listen port |
| `LOG_LEVEL` | `Information` | Log level (`Trace`, `Debug`, `Information`, `Warning`, `Error`, `Critical`) |

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

แต่ละข้อของ [The Twelve-Factor App](https://12factor.net/) ถูกนำมาใช้ใน project นี้ดังนี้:

### 1. Codebase — One codebase tracked in revision control

- Source code อยู่ใน Git repository เดียว (`microservice/CSharp-hello`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`

### 2. Dependencies — Explicitly declare and isolate dependencies

- ประกาศ dependencies ทั้งหมดใน `CSharp-hello.csproj` (NuGet packages)
- `dotnet restore` จะดึง packages จาก nuget.org โดยอัตโนมัติ
- Docker multi-stage build แยก SDK (build) กับ Runtime (run) ไม่มี dependency leak

### 3. Config — Store config in the environment

- `HOST`, `PORT`, `LOG_LEVEL` อ่านจาก environment variables ผ่าน `Environment.GetEnvironmentVariable()`
- ไม่มี hardcode config ใน source code — ทุกค่ามี default แต่ override ได้ผ่าน env
- Dockerfile กำหนด `ENV HOST=0.0.0.0`, `ENV PORT=8080`, `ENV LOG_LEVEL=Information`

### 4. Backing Services — Treat backing services as attached resources

- ปัจจุบัน project นี้ไม่มี backing service (database, cache, queue)
- หากเพิ่มในอนาคต จะใช้ env vars สำหรับ connection string เช่น `DATABASE_URL`

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: `dotnet publish -c Release` หรือ Docker multi-stage build (`sdk:8.0` → compile)
- **Release**: Docker image (`csharp-hello:latest`) รวม DLL + runtime config
- **Run**: `docker run -p 8080:8080 -e PORT=8080 csharp-hello`
- Dockerfile แยก build stage (`sdk:8.0`) กับ runtime stage (`aspnet:8.0`) ชัดเจน

### 6. Processes — Execute the app as one or more stateless processes

- Application เป็น stateless process ตัวเดียว ไม่เก็บ state ใน memory หรือ disk
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage

### 7. Port Binding — Export services via port binding

- Kestrel bind port ผ่าน `UseUrls()` ตาม env `PORT`
- Dockerfile ใช้ `EXPOSE 8080` และ run ด้วย `-p 8080:8080`
- เปลี่ยน port ได้ทันทีผ่าน `PORT=9090`

### 8. Concurrency — Scale out via the process model

- ใช้ Kestrel async I/O + ThreadPool รองรับ concurrent requests ภายใน process เดียว
- Scale horizontally ได้โดยรัน Docker container หลาย instance ด้วย load balancer

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- Startup เร็ว — Kestrel พร้อมรับ request ภายในไม่กี่วินาที
- Graceful shutdown รับ SIGTERM แล้ว Kestrel หยุดรับ request ใหม่ รอ request ที่กำลังทำอยู่จบก่อนปิด
- ใช้ `app.Lifetime.ApplicationStarted` / `ApplicationStopping` สำหรับ lifecycle events
- Dockerfile ใช้ `STOPSIGNAL SIGTERM`

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment
- Config ต่างกันเฉพาะ environment variables (`LOG_LEVEL=Debug` vs `LOG_LEVEL=Information`)
- ไม่มี conditional code แยก dev/prod (Swagger เปิดทุก environment)

### 11. Logs — Treat logs as event streams

- ใช้ `AddJsonConsole()` ส่ง structured JSON logs ไปยัง stdout
- ควบคุม log level ผ่าน env `LOG_LEVEL` (เช่น `Debug`, `Information`, `Warning`, `Error`)
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — health check สำหรับ Kubernetes liveness/readiness probe
- Swagger UI ที่ `/swagger` สำหรับ API documentation
- OpenAPI spec ที่ `/swagger/v1/swagger.json` สำหรับ code generation
