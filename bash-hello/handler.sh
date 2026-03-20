#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# HTTP Request Handler — forked per connection by socat
# Factor 2: Dependencies — source shared config & logging library
# =============================================================================

SCRIPT_DIR="${SCRIPT_DIR:-.}"

# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

# --- Read HTTP request from stdin ---
read -r REQUEST_LINE || true
METHOD=$(echo "$REQUEST_LINE" | awk '{print $1}')
PATH_INFO=$(echo "$REQUEST_LINE" | awk '{print $2}')
# Strip query string
PATH_INFO="${PATH_INFO%%\?*}"

# Read headers (consume until empty line)
CONTENT_LENGTH=0
USER_AGENT=""
CLIENT_IP=""
while IFS= read -r header; do
  header="${header%%$'\r'}"
  [ -z "$header" ] && break
  case "$header" in
    Content-Length:*|content-length:*) CONTENT_LENGTH="${header#*: }" ;;
    User-Agent:*|user-agent:*) USER_AGENT="${header#*: }" ;;
    X-Forwarded-For:*|x-forwarded-for:*) CLIENT_IP="${header#*: }" ;;
  esac
done

# --- HTTP response helper ---
send_response() {
  local status_code="$1"
  local status_text="$2"
  local content_type="$3"
  local body="$4"

  local body_length=${#body}
  printf "HTTP/1.1 %s %s\r\n" "$status_code" "$status_text"
  printf "Content-Type: %s\r\n" "$content_type"
  printf "Content-Length: %d\r\n" "$body_length"
  printf "Access-Control-Allow-Origin: *\r\n"
  printf "Access-Control-Allow-Methods: GET, OPTIONS\r\n"
  printf "Access-Control-Allow-Headers: Content-Type\r\n"
  printf "Connection: close\r\n"
  printf "\r\n"
  printf "%s" "$body"
}

# --- Timing ---
START_TIME=$(date +%s%N 2>/dev/null || echo "0")

# =============================================================================
# Routes
# =============================================================================

case "$METHOD $PATH_INFO" in
  "OPTIONS "*)
    # --- CORS preflight ---
    send_response 204 "No Content" "text/plain" ""
    STATUS=204
    ;;

  "GET /"|"GET")
    # --- Loan service log route ---
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
    BODY=$(cat <<EOF
{
  "timestamp": "${TIMESTAMP}",
  "level": "INFO",
  "service": {
    "name": "${SERVICE_NAME}",
    "version": "${SERVICE_VERSION}",
    "environment": "${SERVICE_ENV}"
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
EOF
)
    send_response 200 "OK" "application/json" "$BODY"
    STATUS=200
    ;;

  "GET /health")
    # --- Health check route ---
    BODY=$(printf '{"status":"ok","service":"%s","version":"%s"}' "$SERVICE_NAME" "$SERVICE_VERSION")
    send_response 200 "OK" "application/json" "$BODY"
    STATUS=200
    ;;

  "GET /swagger"|"GET /swagger/"|"GET /swagger/index.html")
    # --- Swagger UI route ---
    SWAGGER_HTML=$(cat "${SCRIPT_DIR}/swagger.html")
    send_response 200 "OK" "text/html; charset=utf-8" "$SWAGGER_HTML"
    STATUS=200
    ;;

  "GET /swagger/doc.json"|"GET /openapi.json")
    # --- OpenAPI spec route ---
    SPEC=$(cat "${SCRIPT_DIR}/openapi.json")
    send_response 200 "OK" "application/json" "$SPEC"
    STATUS=200
    ;;

  *)
    # --- 404 Not Found ---
    BODY='{"error":"Not Found","status":404}'
    send_response 404 "Not Found" "application/json" "$BODY"
    STATUS=404
    ;;
esac

# --- Factor 11: Access log ---
END_TIME=$(date +%s%N 2>/dev/null || echo "0")
if [ "$START_TIME" != "0" ] && [ "$END_TIME" != "0" ]; then
  DURATION_MS=$(( (END_TIME - START_TIME) / 1000000 ))
else
  DURATION_MS=0
fi

log_json "INFO" "HTTP request" "\"method\":\"${METHOD}\",\"path\":\"${PATH_INFO}\",\"status\":${STATUS},\"duration_ms\":${DURATION_MS},\"user_agent\":\"${USER_AGENT}\""
