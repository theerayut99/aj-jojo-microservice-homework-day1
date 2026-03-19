# dart-hello

Loan service microservice built with **Dart** and **Shelf** framework.

## Components

| Component   | Technology                |
| ----------- | ------------------------- |
| Language    | Dart 3.x (stable)        |
| Framework   | Shelf + shelf_router      |
| Swagger     | Swagger UI 5 (CDN)       |
| Docker      | AOT compile → scratch     |
| Logging     | Structured JSON to stdout |

## Dependencies

| Package        | Purpose            |
| -------------- | ------------------ |
| shelf          | HTTP server        |
| shelf_router   | URL routing        |

## Dart + Shelf — Pros & Cons

### Pros

1. **AOT compilation ทำให้ได้ binary เดียว** — compile เป็น native binary ที่รันเร็วมาก ไม่ต้องพึ่ง runtime/VM
2. **Docker image เล็กมาก (scratch)** — AOT-compiled binary ใส่ใน scratch image ได้เลย ขนาดไม่กี่ MB
3. **Startup time เร็วมาก** — ไม่ต้อง warm up VM ทำให้เหมาะกับ serverless/container
4. **Type-safe language** — Dart มี sound null safety ช่วยลด runtime error ได้มาก
5. **Single language full-stack** — ใช้ Dart ได้ทั้ง frontend (Flutter) และ backend
6. **Built-in async/await** — รองรับ concurrency ดี เขียน async code ง่าย
7. **เรียนรู้ง่าย** — syntax คล้าย Java/TypeScript ทำให้ developer ส่วนใหญ่ปรับตัวได้เร็ว
8. **Tooling ดี** — dart format, dart analyze, dart test มาพร้อม SDK ไม่ต้องลง tool เพิ่ม

### Cons

1. **Ecosystem เล็กสำหรับ backend** — library/package สำหรับ server-side มีน้อยกว่า Node.js, Python, Java มาก
2. **Community เล็ก** — developer ส่วนใหญ่ใช้ Dart กับ Flutter ไม่ค่อยมีคนใช้ทำ backend
3. **ไม่มี Swagger library ที่ดี** — ไม่มี annotation-based Swagger generator เหมือน .NET/Java ต้องเขียน OpenAPI spec เอง
4. **Framework choices น้อย** — มีแค่ Shelf, Aqueduct (deprecated), Serverpod ไม่มี mature framework เทียบเท่า Express/Spring
5. **Hiring ยาก** — หา Dart backend developer ในตลาดยากมาก ส่วนใหญ่เป็น Flutter developer
6. **Production references น้อย** — มี case study ของ Dart backend ใน production น้อย ทำให้ขาดความมั่นใจ
7. **ORM/Database support จำกัด** — ไม่มี ORM ที่ mature เหมือน TypeORM, SQLAlchemy, Entity Framework

## Run

```bash
# ใช้ Docker (ไม่ต้องลง Dart SDK)
docker build -t dart-hello .
docker run -p 8080:8080 dart-hello

# ถ้าลง Dart SDK แล้ว
dart run bin/server.dart
```

## Swagger

เปิด browser ไปที่ http://localhost:8080/swagger

OpenAPI spec: http://localhost:8080/openapi.json

## Docker Build

```bash
docker build -t dart-hello .
docker run -d --name dart-hello -p 8080:8080 dart-hello
```

Image ใช้ **AOT compilation** — compile เป็น native binary แล้วใส่ใน `scratch` image (ไม่มี OS layer) ทำให้ image เล็กมาก

## Environment Variables

| Variable    | Default   | Description                |
| ----------- | --------- | -------------------------- |
| `HOST`      | `0.0.0.0` | Bind address               |
| `PORT`      | `8080`    | Server port                |
| `LOG_LEVEL` | `info`    | Log level (info / silent)  |

## API

| Method | Path            | Description            |
| ------ | --------------- | ---------------------- |
| GET    | `/`             | Loan service JSON log  |
| GET    | `/health`       | Health check           |
| GET    | `/swagger`      | Swagger UI             |
| GET    | `/openapi.json` | OpenAPI 3.0 spec       |

## 12-Factor App

| Factor                | Implementation                                           |
| --------------------- | -------------------------------------------------------- |
| I. Codebase           | Git monorepo, one codebase per service                   |
| II. Dependencies      | pubspec.yaml + dart pub get                              |
| III. Config           | Environment variables (HOST, PORT, LOG_LEVEL)            |
| IV. Backing services  | N/A (stateless demo)                                     |
| V. Build, release, run| Docker multi-stage: AOT compile → scratch image          |
| VI. Processes         | Stateless server, no shared state                        |
| VII. Port binding     | Self-contained HTTP server via shelf                     |
| VIII. Concurrency     | Dart isolates / container scaling                        |
| IX. Disposability     | SIGTERM/SIGINT graceful shutdown, fast AOT startup       |
| X. Dev/prod parity    | Same Docker image for all environments                   |
| XI. Logs              | Structured JSON to stdout                                |
| XII. Admin processes  | N/A                                                      |
