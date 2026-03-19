# python-hello

| Component | Responsibility |
|---|---|
| **Package Manager** | pip |
| **Dependency file** | requirements.txt |
| **Source Code** | main.py |
| **OS executable file** | — (interpreted via Python) |

## Dependencies

| Package | Purpose |
|---|---|
| fastapi | Web framework (ASGI) |
| uvicorn | ASGI server |
| python-json-logger | Structured JSON logging |

## FastAPI — ข้อดีและข้อเสีย

### ข้อดี (Pros)

| ข้อดี | รายละเอียด |
|---|---|
| **Performance สูงสำหรับ Python** | ใช้ ASGI (async) + Uvicorn/Starlette เป็น base ทำให้เร็วกว่า Flask/Django หลายเท่า ติดอันดับต้น ๆ ใน Python web framework benchmarks |
| **Automatic API Docs** | สร้าง Swagger UI (`/docs`) และ ReDoc (`/redoc`) จาก type hints อัตโนมัติ ไม่ต้องเขียน spec แยก |
| **Type Hints & Validation** | ใช้ Pydantic + Python type hints ทำ request/response validation อัตโนมัติ ถ้า type ไม่ตรงจะ return 422 พร้อม error detail |
| **Developer Experience ดีเยี่ยม** | Hot reload, autocomplete, inline docs ทำงานดีกับ IDE โค้ดอ่านง่ายและเขียนน้อย |
| **Async & Sync รองรับทั้งคู่** | เขียน `async def` หรือ `def` ปกติก็ได้ FastAPI จัดการ thread pool ให้อัตโนมัติ |
| **Dependency Injection** | ระบบ `Depends()` ทำ dependency injection ได้ง่าย ใช้สำหรับ auth, database session, shared logic |
| **Ecosystem ใหญ่** | Python มี library มากที่สุดในโลก ใช้ร่วมกับ ML (scikit-learn, TensorFlow), data processing (pandas), cloud SDK ได้ทันที |
| **เรียนรู้ง่าย** | Python syntax เข้าใจง่าย FastAPI มี documentation ดีมาก พร้อมตัวอย่างครบ เหมาะกับทั้งผู้เริ่มต้นและผู้มีประสบการณ์ |

### ข้อเสีย (Cons)

| ข้อเสีย | รายละเอียด |
|---|---|
| **GIL (Global Interpreter Lock)** | Python มี GIL ทำให้ CPU-bound tasks ใช้ได้แค่ 1 core ต่อ process ต้องใช้ multiprocessing หรือ worker หลายตัวแก้ |
| **Performance ต่ำกว่า compiled language** | แม้จะเร็วในกลุ่ม Python แต่เทียบกับ Rust, Go, Java แล้วยังช้ากว่าหลายเท่าสำหรับ CPU-intensive workloads |
| **Runtime Errors** | Python เป็น dynamic typing แม้ใช้ type hints แต่ไม่มี compile-time check จริง ๆ — บาง bug จะเจอตอน runtime เท่านั้น |
| **Memory Usage สูง** | Python process ใช้ memory มากกว่า Go หรือ Rust อย่างมาก ทำให้ container resource ต้องจัดสรรมากขึ้น |
| **Dependency Management ซับซ้อน** | pip ไม่มี lock file ในตัว (ต้องใช้ pip-tools, poetry, pipenv) virtual environment ต้องจัดการเอง |
| **Cold Start ช้า** | Python interpreter ต้อง import modules ทุกครั้งที่เริ่ม ทำให้ cold start ช้ากว่า compiled binary โดยเฉพาะใน serverless |
| **ไม่เหมาะกับ CPU-bound** | สำหรับงาน computation-heavy ต้องใช้ library ที่เขียนด้วย C/Rust (NumPy, Polars) หรือ offload ไป worker แยก |

---

Python microservice built with [FastAPI](https://fastapi.tiangolo.com/) that returns a sample loan-service JSON log entry.

## Prerequisites

- [Python](https://www.python.org/) >= 3.12
- [Docker](https://www.docker.com/) (optional)

## Run

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Default (port 8000)
uvicorn main:app --host 0.0.0.0 --port 8000

# Custom port / log level
PORT=9000 LOG_LEVEL=debug uvicorn main:app --host 0.0.0.0 --port 9000 --log-level debug
```

Server starts at **http://localhost:8000**

## Swagger UI

Open **http://localhost:8000/docs** in your browser to explore the API interactively.

ReDoc is also available at **http://localhost:8000/redoc**.

The raw OpenAPI JSON spec is available at **http://localhost:8000/openapi.json**.

## Docker

```bash
# Build image
docker build -t python-hello .

# Run container
docker run -p 8000:8000 python-hello

# Run with custom config
docker run -p 9000:9000 -e PORT=9000 -e LOG_LEVEL=debug python-hello
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `HOST` | `0.0.0.0` | Bind address |
| `PORT` | `8000` | Listen port |
| `LOG_LEVEL` | `info` | Log level (`debug`, `info`, `warning`, `error`, `critical`) |

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

- Source code อยู่ใน Git repository เดียว (`microservice/python-hello`)
- Push ไปยัง GitHub: `theerayut99/aj-jojo-microservice-homework-day1`

### 2. Dependencies — Explicitly declare and isolate dependencies

- ประกาศ dependencies ทั้งหมดใน `requirements.txt`
- ใช้ virtual environment (`python -m venv .venv`) แยก dependencies ของแต่ละ project
- Docker image ติดตั้ง dependencies ผ่าน `pip install --no-cache-dir -r requirements.txt`

### 3. Config — Store config in the environment

- `HOST`, `PORT`, `LOG_LEVEL` อ่านจาก environment variables ผ่าน `os.environ.get()`
- ไม่มี hardcode config ใน source code — ทุกค่ามี default แต่ override ได้ผ่าน env
- Dockerfile กำหนด `ENV HOST=0.0.0.0`, `ENV PORT=8000`, `ENV LOG_LEVEL=info`

### 4. Backing Services — Treat backing services as attached resources

- ปัจจุบัน project นี้ไม่มี backing service (database, cache, queue)
- หากเพิ่มในอนาคต จะใช้ env vars สำหรับ connection string เช่น `DATABASE_URL`

### 5. Build, Release, Run — Strictly separate build and run stages

- **Build**: `pip install -r requirements.txt` หรือ Docker build (`python:3.12-slim` → install deps)
- **Release**: Docker image (`python-hello:latest`) รวม source + dependencies + runtime config
- **Run**: `docker run -p 8000:8000 -e PORT=8000 python-hello`
- Dockerfile แยก dependency install กับ source copy เพื่อ layer caching

### 6. Processes — Execute the app as one or more stateless processes

- Application เป็น stateless process ตัวเดียว ไม่เก็บ state ใน memory หรือ disk
- ทุก request ได้ response เดียวกัน ไม่มี session หรือ local storage

### 7. Port Binding — Export services via port binding

- Uvicorn bind port ตาม env `PORT` ผ่าน `--port` flag
- Dockerfile ใช้ `EXPOSE 8000` และ run ด้วย `-p 8000:8000`
- เปลี่ยน port ได้ทันทีผ่าน `PORT=9000`

### 8. Concurrency — Scale out via the process model

- ใช้ Uvicorn ASGI server รองรับ async concurrent requests ภายใน process เดียว
- Scale horizontally ได้โดยรัน Docker container หลาย instance ด้วย load balancer
- หรือใช้ `uvicorn --workers N` เพื่อ spawn หลาย worker processes

### 9. Disposability — Maximize robustness with fast startup and graceful shutdown

- Startup เร็ว — Uvicorn พร้อมรับ request ภายในไม่กี่วินาที
- Graceful shutdown รับ SIGTERM/SIGINT ผ่าน signal handler แล้ว log และ exit gracefully
- ใช้ FastAPI `lifespan` context manager สำหรับ startup/shutdown events
- Dockerfile ใช้ `STOPSIGNAL SIGTERM`

### 10. Dev/Prod Parity — Keep development, staging, and production as similar as possible

- ใช้ Docker image เดียวกันทุก environment
- Config ต่างกันเฉพาะ environment variables (`LOG_LEVEL=debug` vs `LOG_LEVEL=info`)
- ไม่มี conditional code แยก dev/prod

### 11. Logs — Treat logs as event streams

- ใช้ `python-json-logger` ส่ง structured JSON logs ไปยัง stdout
- ควบคุม log level ผ่าน env `LOG_LEVEL` (เช่น `debug`, `info`, `warning`, `error`)
- ไม่เขียน log file — ให้ log collector (Docker, CloudWatch, ELK) จัดการ

### 12. Admin Processes — Run admin/management tasks as one-off processes

- `GET /health` — health check สำหรับ Kubernetes liveness/readiness probe
- Swagger UI ที่ `/docs` สำหรับ API documentation
- ReDoc ที่ `/redoc` สำหรับ API reference
- OpenAPI spec ที่ `/openapi.json` สำหรับ code generation
