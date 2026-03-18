# php-hello

PHP microservice built with [Hyperf](https://hyperf.io/) framework (Swoole) that returns a sample loan-service JSON log entry.

## Prerequisites

- [Docker](https://www.docker.com/) (recommended)
- Or PHP >= 8.1 with Swoole extension >= 5.0

## Run

```bash
php bin/hyperf.php start
```

Server starts at **http://localhost:9501**

## Swagger UI

Open **http://localhost:9500/swagger** in your browser to explore the API interactively.

The raw OpenAPI JSON spec is available at **http://localhost:9500/http.json**.

## Docker

```bash
# Build image
docker build -t php-hello .

# Run container
docker run -p 9501:9501 -p 9500:9500 php-hello
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

| Package | Purpose |
|---|---|
| hyperf/framework | Hyperf core framework |
| hyperf/http-server | HTTP server (Swoole) |
| hyperf/swagger | Swagger / OpenAPI documentation |
| hyperf/config | Configuration management |
| hyperf/logger | Logging |
| hyperf/database | Database ORM |
| hyperf/redis | Redis client |
| hyperf/cache | Cache management |
