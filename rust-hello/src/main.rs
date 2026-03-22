use axum::{routing::{get, post}, Json, Router};
use serde_json::{json, Value};
use std::env;
use tokio::signal;
use utoipa::OpenApi;
use utoipa_swagger_ui::SwaggerUi;

#[derive(OpenApi)]
#[openapi(
    info(
        title = "Loan Service API",
        version = "1.2.0",
        description = "Rust microservice that returns a sample loan-service JSON log entry"
    ),
    ),
    paths(root, health, post_webhook)
)]
struct ApiDoc;

#[tokio::main]
async fn main() {
    // Factor 11: Logs as event streams — structured JSON to stdout
    tracing_subscriber::fmt()
        .json()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("info")),
        )
        .init();

    // Factor 3: Store config in environment
    let host = env::var("HOST").unwrap_or_else(|_| "0.0.0.0".to_string());
    let port = env::var("PORT").unwrap_or_else(|_| "3000".to_string());
    let addr = format!("{host}:{port}");

    let app = Router::new()
        .route("/", get(root).post(post_webhook))
        .route("/health", get(health))
        .merge(SwaggerUi::new("/swagger-ui").url("/api-docs/openapi.json", ApiDoc::openapi()));

    let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
    tracing::info!(addr = %addr, "server started");

    // Factor 9: Disposability — graceful shutdown on SIGTERM/SIGINT
    axum::serve(listener, app)
        .with_graceful_shutdown(shutdown_signal())
        .await
        .unwrap();

    tracing::info!("server shut down gracefully");
}

async fn shutdown_signal() {
    let ctrl_c = async {
        signal::ctrl_c().await.expect("failed to install Ctrl+C handler");
    };

    #[cfg(unix)]
    let terminate = async {
        signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("failed to install SIGTERM handler")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => { tracing::info!("received SIGINT"); },
        _ = terminate => { tracing::info!("received SIGTERM"); },
    }
}

/// Health check endpoint
#[utoipa::path(
    get,
    path = "/health",
    responses(
        (status = 200, description = "Service is healthy", body = Value)
    )
)]
async fn health() -> Json<Value> {
    Json(json!({ "status": "ok" }))
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

#[utoipa::path(
    post,
    path = "/",
    request_body = Option<Value>,
    responses(
        (status = 200, description = "Webhook event processed successfully", body = Value)
    )
)]
async fn post_webhook(payload: Option<Json<Value>>) -> Json<Value> {
    let body_value = match payload {
        Some(Json(val)) => val,
        None => json!({}),
    };

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
            "body": body_value,
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
        "message": "Webhook event processed successfully",
        "tags": ["loan", "webhook", "apply"],
        "extra": {}
    }))
}