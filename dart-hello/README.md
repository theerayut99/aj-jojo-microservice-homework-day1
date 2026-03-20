# dart-hello

Loan service microservice built with **Dart** and **Serverpod** web framework.

## Components

| Component   | Technology                       |
| ----------- | -------------------------------- |
| Language    | Dart 3.x (stable)               |
| Framework   | Serverpod 3.4.4                  |
| Swagger     | Swagger UI 5 (CDN)              |
| Docker      | exe compile → Alpine             |
| Logging     | Serverpod built-in logging       |

## Dependencies

| Package      | Purpose                              |
| ------------ | ------------------------------------ |
| serverpod    | Full-stack Dart web framework        |

## Serverpod — Pros & Cons

### Pros

1. **Full-stack Dart framework** — ครบวงจรทั้ง server, client, serialization, ORM, caching, logging ในตัว
2. **Type-safe end-to-end** — สร้าง client SDK อัตโนมัติจาก server endpoints ช่วยลด bug ระหว่าง client-server
3. **Code generation** — generate model classes, serialization, endpoint dispatch อัตโนมัติจาก YAML definitions
4. **Built-in ORM** — มี PostgreSQL ORM ในตัว ไม่ต้องหา library ภายนอก
5. **Built-in logging & insights** — มี logging, health check, server insights มาพร้อม framework
6. **Dart ecosystem เดียวกับ Flutter** — ใช้ภาษาเดียวกับ Flutter ทำให้ share code ระหว่าง frontend/backend ได้
7. **Active development** — Serverpod 3.x มี release ต่อเนื่อง มี roadmap ชัดเจน
8. **Mini mode สำหรับ lightweight server** — ไม่จำเป็นต้องใช้ database ถ้าไม่ต้องการ

### Cons

1. **Learning curve สูง** — ต้องเข้าใจ code generation, endpoint dispatch, protocol definitions
2. **Ecosystem ยังเล็ก** — community เล็กกว่า Express, Spring, FastAPI มาก ตัวอย่างน้อย
3. **ต้องการ CLI + Flutter สำหรับ scaffold** — `serverpod create` ต้อง install Flutter SDK ทำให้ setup ใน CI/CD ยุ่งยาก
4. **Project structure ซับซ้อน** — สร้าง 3 packages (server, client, flutter) แม้ต้องการแค่ server
5. **Production references น้อย** — ยังไม่มี large-scale production case study ที่เป็นที่รู้จัก
6. **Docker image ใหญ่กว่า Shelf** — ต้องมี runtime dependencies ทำให้ image ~35 MB (vs ~17 MB สำหรับ Shelf AOT→scratch)
7. **Hiring ยากมาก** — หา Dart backend developer ที่เชี่ยวชาญ Serverpod ในตลาดแทบไม่มี

## Architecture

Serverpod runs **3 servers**:

| Server   | Port | Purpose                              |
| -------- | ---- | ------------------------------------ |
| API      | 8080 | RPC-style endpoint calls             |
| Insights | 8081 | Server monitoring & health           |
| Web      | 8082 | HTTP routes (our REST endpoints)     |

## Run

```bash
# ใช้ Docker (ไม่ต้องลง Dart SDK)
docker build -t dart-hello .
docker run -p 8080:8080 -p 8082:8082 dart-hello

# ถ้าลง Dart SDK แล้ว
dart pub get
dart run bin/main.dart --mode development
```

## Swagger

เปิด browser ไปที่ http://localhost:8082/swagger

OpenAPI spec: http://localhost:8082/openapi.json

## Docker Build

```bash
docker build -t dart-hello .
docker run -d --name dart-hello \
  -p 8080:8080 -p 8081:8081 -p 8082:8082 \
  dart-hello
```

Image ใช้ `dart compile exe` แล้วรันบน Alpine Linux

## Environment Variables

| Variable   | Default      | Description                    |
| ---------- | ------------ | ------------------------------ |
| `runmode`  | `production` | Serverpod run mode             |
| `serverid` | `default`    | Server identifier              |
| `logging`  | `normal`     | Logging mode                   |
| `role`     | `monolith`   | Server role                    |

## API (Web Server — port 8082)

| Method | Path            | Description            |
| ------ | --------------- | ---------------------- |
| GET    | `/`             | Loan service JSON log  |
| GET    | `/health`       | Health check           |
| GET    | `/swagger`      | Swagger UI             |
| GET    | `/openapi.json` | OpenAPI 3.0 spec       |

## 12-Factor App

| Factor                | Implementation                                              |
| --------------------- | ----------------------------------------------------------- |
| I. Codebase           | Git monorepo, one codebase per service                      |
| II. Dependencies      | pubspec.yaml + dart pub get                                 |
| III. Config           | Environment variables (runmode, serverid, logging, role)    |
| IV. Backing services  | N/A (Mini mode, no database)                                |
| V. Build, release, run| Docker multi-stage: compile exe → Alpine image              |
| VI. Processes         | Stateless server, no shared state                           |
| VII. Port binding     | Self-contained HTTP servers (3 ports)                       |
| VIII. Concurrency     | Dart isolates / container scaling                           |
| IX. Disposability     | SIGTERM graceful shutdown (STOPSIGNAL)                      |
| X. Dev/prod parity    | Same Docker image, config via run mode                      |
| XI. Logs              | Serverpod built-in structured logging to stdout             |
| XII. Admin processes  | N/A                                                         |
