# rust-hello

Package Manager: cargo
Dependency file: Cargo.toml
Source Code: main.rs
OS executable file


Rust microservice built with [Axum](https://github.com/tokio-rs/axum) that returns a sample loan-service JSON log entry.

## Prerequisites

- [Rust](https://www.rust-lang.org/tools/install) >= 1.94.0

## Run

```bash
cargo run
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
```

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

## Dependencies

| Crate | Purpose |
|---|---|
| axum | Web framework |
| tokio | Async runtime |
| serde / serde_json | JSON serialization |
| tracing / tracing-subscriber | Logging |
| utoipa / utoipa-swagger-ui | Swagger / OpenAPI documentation |
