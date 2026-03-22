import logging
import os
import signal
import sys

from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from pythonjsonlogger import json as json_log

# --- I. Config: env vars ---
HOST = os.environ.get("HOST", "0.0.0.0")
PORT = int(os.environ.get("PORT", "8000"))
LOG_LEVEL = os.environ.get("LOG_LEVEL", "info").upper()

# --- XI. Logs: structured JSON to stdout ---
handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(json_log.JsonFormatter("%(asctime)s %(levelname)s %(name)s %(message)s"))
logging.basicConfig(level=LOG_LEVEL, handlers=[handler])
logger = logging.getLogger("python-hello")


# --- IX. Disposability: graceful shutdown ---
@asynccontextmanager
async def lifespan(application: FastAPI):
    logger.info("Application started", extra={"host": HOST, "port": PORT})
    yield
    logger.info("Application shutting down")


app = FastAPI(title="python-hello", version="1.0.0", lifespan=lifespan)


def _handle_signal(sig, _frame):
    logger.info("Received signal %s, shutting down", signal.Signals(sig).name)
    sys.exit(0)


signal.signal(signal.SIGTERM, _handle_signal)
signal.signal(signal.SIGINT, _handle_signal)


# --- VIII. Concurrency: stateless process ---
@app.get("/")
def get_loan_log():
    return {
        "timestamp": "2026-03-18T14:10:25.123Z",
        "level": "INFO",
        "service": {
            "name": "loan-service",
            "version": "1.2.0",
            "environment": "production",
        },
        "trace": {
            "trace_id": "abc123xyz",
            "span_id": "span-001",
            "parent_span_id": None,
        },
        "request": {
            "method": "POST",
            "path": "/api/v1/loan/apply",
            "query": {},
            "headers": {
                "x-request-id": "abc123xyz",
            },
            "body": {
                "customer_id": 1001,
            },
            "ip": "10.0.0.1",
            "user_agent": "PostmanRuntime/7.32",
        },
        "response": {
            "status_code": 200,
            "body": {
                "result": "success",
            },
            "duration_ms": 120,
        },
        "user": {
            "id": "u-1001",
            "role": "customer",
        },
        "error": None,
        "message": "Loan application processed successfully",
        "tags": ["loan", "apply"],
        "extra": {},
    }


@app.post("/")
async def post_loan_log(request: Request):
    try:
        payload = await request.json()
    except Exception:
        payload = {}
        
    return {
        "timestamp": "2026-03-18T14:10:25.123Z",
        "level": "INFO",
        "service": {
            "name": "loan-service",
            "version": "1.2.0",
            "environment": "production",
        },
        "trace": {
            "trace_id": "abc123xyz",
            "span_id": "span-001",
            "parent_span_id": None,
        },
        "request": {
            "method": "POST",
            "path": "/api/v1/loan/apply",
            "query": {},
            "headers": {
                "x-request-id": "abc123xyz",
            },
            "body": payload,
            "ip": "10.0.0.1",
            "user_agent": "PostmanRuntime/7.32",
        },
        "response": {
            "status_code": 200,
            "body": {
                "result": "success",
            },
            "duration_ms": 120,
        },
        "user": {
            "id": "u-1001",
            "role": "customer",
        },
        "error": None,
        "message": "Webhook event processed successfully",
        "tags": ["loan", "webhook", "apply"],
        "extra": {},
    }


# --- XII. Admin processes ---
@app.get("/health")
def health():
    return {"status": "ok"}
