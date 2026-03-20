# js-hello

| Component | Responsibility |
|---|---|
| **Package Manager** | npm |
| **Dependency file** | package.json |
| **Source Code** | src/main.ts |
| **Runtime** | Node.js (Express) |

## Dependencies

| Package | Purpose |
|---|---|
| @nestjs/core | NestJS core framework |
| @nestjs/platform-express | HTTP server (Express) |
| @nestjs/swagger | Swagger / OpenAPI documentation |
| nestjs-pino / pino | Structured JSON logging |
| rxjs | Reactive extensions |

## NestJS — ข้อดีและข้อเสีย

### ข้อดี (Pros)

| ข้อดี | รายละเอียด |
|---|---|
| **โครงสร้างชัดเจน** | ใช้ Module / Controller / Service pattern (คล้าย Angular) ทำให้โค้ดเป็นระเบียบ แยก concern ได้ดี เหมาะกับ project ขนาดใหญ่ |
| **TypeScript First** | สร้างมาเพื่อ TypeScript โดยเฉพาะ มี type safety, decorator, metadata reflection ช่วยลด bug ตั้งแต่ compile time |
| **Dependency Injection** | มี built-in DI container ทำให้ test ง่าย mock ง่าย และจัดการ dependency ระหว่าง module ได้สะดวก |
| **Ecosystem ครบ** | มี official module สำเร็จรูปสำหรับ database (TypeORM, Prisma), queue (Bull), WebSocket, GraphQL, gRPC, microservice transport |
| **Swagger Integration** | ใช้ `@nestjs/swagger` + decorator ได้เลย generate OpenAPI spec อัตโนมัติจาก code |
| **Testing Support** | มี `@nestjs/testing` สำหรับ unit test และ e2e test พร้อม Jest config ตั้งแต่ scaffold |
| **Middleware & Guards** | Middleware, Guards, Interceptors, Pipes, Filters — ครบทุก layer สำหรับ request lifecycle |
| **Active Community** | Community ใหญ่ มี documentation ดี มี official course และ enterprise support |

### ข้อเสีย (Cons)

| ข้อเสีย | รายละเอียด |
|---|---|
| **Overhead สำหรับ project เล็ก** | โครงสร้าง Module/Controller/Service หนักเกินไปสำหรับ simple API ที่มีไม่กี่ route |
| **Learning Curve** | ต้องเข้าใจ DI, decorator, module system, RxJS ซึ่งต่างจาก Express แบบดั้งเดิมมาก |
| **Performance ต่ำกว่า** | มี abstraction layer หลายชั้น ทำให้ช้ากว่า raw Express หรือ Fastify โดยเฉพาะ high-throughput scenario |
| **Decorator Magic** | Logic ซ่อนอยู่ใน decorator และ metadata reflection ทำให้ debug ยากเมื่อมีปัญหา |
| **Bundle Size ใหญ่** | `node_modules` ใหญ่ รวม devDependencies แล้วหลายร้อย MB เทียบกับ minimal framework อย่าง Fastify หรือ Koa |
| **Opinionated** | บังคับ pattern เยอะ ปรับแต่งโครงสร้างนอกแบบได้ยาก ไม่เหมาะกับคนที่ต้องการ flexibility สูง |
| **Version Compatibility** | Major version upgrade (v9 → v10 → v11) อาจมี breaking changes กับ third-party module |

---

Node.js microservice built with [NestJS](https://nestjs.com/) framework (TypeScript) that returns a sample loan-service JSON log entry.

## Prerequisites

- [Node.js](https://nodejs.org/) >= 18
- [Docker](https://www.docker.com/) (optional)

## Run

```bash
# Default (port 3000)
npm run start

# Custom port / log level
PORT=8080 LOG_LEVEL=debug npm run start
```

Server starts at **http://localhost:3000**

## Swagger UI

Open **http://localhost:3000/swagger** in your browser to explore the API interactively.

The raw OpenAPI JSON spec is available at **http://localhost:3000/swagger-json**.

## Build

```bash
# Compile TypeScript
npm run build

# Run production
node dist/main
```

## Docker

```bash
# Build image
docker build -t js-hello .

# Run container
docker run -p 3000:3000 js-hello

# Run with custom config
docker run -p 8080:8080 -e PORT=8080 -e LOG_LEVEL=debug js-hello
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `HOST` | `0.0.0.0` | Bind address |
| `PORT` | `3000` | Listen port |
| `LOG_LEVEL` | `info` | Log level (`debug`, `info`, `warn`, `error`) |
| `NODE_ENV` | `production` | Application environment |

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
js-hello/
├── src/
│   ├── main.ts              # Factor 3 (env vars), 7 (port binding), 9 (graceful shutdown)
│   ├── app.module.ts        # Factor 2 (dependencies) — NestJS module with pino logger (Factor 11)
│   ├── app.controller.ts    # API route handlers
│   └── app.service.ts       # Business logic (stateless — Factor 6)
├── Dockerfile               # Factor 5 (build/release/run) — multi-stage build
├── package.json             # Factor 2 (dependencies) — explicit declaration
├── package-lock.json        # Factor 2 — lock file for reproducible builds
├── tsconfig.json            # TypeScript config
└── dist/                    # Compiled JavaScript output
```

แต่ละข้อของ [The Twelve-Factor App](https://12factor.net/) ถูกนำมาใช้ใน project นี้ดังนี้:

### 1. Codebase — One codebase tracked in revision control

- Source code อยู่ใน Git repository เดียว (`microservice/js-hello`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`

### 2. Dependencies — Explicitly declare and isolate dependencies

- ประกาศ dependencies ทั้งหมดใน `package.json` พร้อม lock file `package-lock.json`
- `npm ci` จะดึง dependencies จาก npm registry โดยอัตโนมัติ
- Docker multi-stage build แยก devDependencies ออก runtime image มีแค่ production deps

### 3. Config — Store config in the environment

- `HOST`, `PORT`, `LOG_LEVEL`, `NODE_ENV` อ่านจาก `process.env`
- ไม่มี hardcode config ใน source code — ทุกค่ามี default แต่ override ได้ผ่าน env
- Dockerfile กำหนด `ENV HOST=0.0.0.0`, `ENV PORT=3000`, `ENV LOG_LEVEL=info`

### 4. Backing Services — Treat backing services as attached resources

- ปัจจุบัน project นี้ไม่มี backing service (database, cache, queue)
- หากเพิ่มในอนาคต จะใช้ env vars สำหรับ connection string เช่น `DATABASE_URL`

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: `npm run build` (TypeScript → JavaScript) ภายใน Docker builder stage
- **Release**: Docker image (`js-hello:latest`) รวม dist + node_modules (production only)
- **Run**: `docker run -p 3000:3000 -e PORT=3000 js-hello`
- Dockerfile แยก builder stage (compile) กับ runtime stage (node:18-alpine) ชัดเจน

### 6. Processes — Execute the app as one or more stateless processes

- Application เป็น stateless process ตัวเดียว ไม่เก็บ state ใน memory หรือ disk
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage

### 7. Port Binding — Export services via port binding

- NestJS bind port ผ่าน `app.listen(port, host)` ตาม env `PORT`
- Dockerfile ใช้ `EXPOSE 3000` และ run ด้วย `-p 3000:3000`
- เปลี่ยน port ได้ทันทีผ่าน `PORT=8080`

### 8. Concurrency — Scale out via the process model

- ใช้ Node.js event loop รองรับ concurrent requests ภายใน process เดียว
- Scale horizontally ได้โดยรัน Docker container หลาย instance ด้วย load balancer

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- Startup เร็ว — Node.js ไม่มี compile step ตอน runtime
- Graceful shutdown ผ่าน `app.enableShutdownHooks()` รับ SIGTERM/SIGINT แล้วหยุดรับ request ใหม่ รอ request เดิมจบก่อนปิด
- Dockerfile กำหนด `STOPSIGNAL SIGTERM`

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment
- Config ต่างกันเฉพาะ environment variables (`LOG_LEVEL=debug` vs `LOG_LEVEL=info`)
- ไม่มี conditional code แยก dev/prod

### 11. Logs — Treat logs as event streams

- ใช้ `nestjs-pino` ส่ง structured JSON logs ไปยัง stdout
- ทุก request log มี method, url, statusCode, responseTime ครบ
- ควบคุม log level ผ่าน env `LOG_LEVEL` (เช่น `debug`, `info`, `warn`, `error`)
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — health check สำหรับ Kubernetes liveness/readiness probe
- Swagger UI ที่ `/swagger` สำหรับ API documentation
- OpenAPI spec ที่ `/swagger-json` สำหรับ code generation
