from fastapi import FastAPI

app = FastAPI(title="python-hello", version="1.0.0")


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
