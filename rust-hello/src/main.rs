use axum::{routing::get, Json, Router};
use serde_json::{json, Value};
use utoipa::OpenApi;
use utoipa_swagger_ui::SwaggerUi;

#[derive(OpenApi)]
#[openapi(
    info(
        title = "Loan Service API",
        version = "1.2.0",
        description = "Rust microservice that returns a sample loan-service JSON log entry"
    ),
    paths(root)
)]
struct ApiDoc;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let app = Router::new()
        .route("/", get(root))
        .merge(SwaggerUi::new("/swagger-ui").url("/api-docs/openapi.json", ApiDoc::openapi()));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

#[utoipa::path(
    get,
    path = "/",
    responses(
        (status = 200, description = "Returns a sample structured JSON log for a loan application request", body = Value)
    )
)]
async fn root() -> Json<Value> {
    Json(json!({
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
    }))
}