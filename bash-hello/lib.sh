#!/usr/bin/env bash
# =============================================================================
# Shared library — sourced by server.sh and handler.sh
# Factor 2: Dependencies — internal shared module
# Factor 3: Config — centralized environment variable loading
# Factor 11: Logs — unified structured JSON logging
# =============================================================================

# --- Factor 3: Store config in environment variables ---
export HOST="${HOST:-0.0.0.0}"
export PORT="${PORT:-3000}"
export SERVICE_NAME="${SERVICE_NAME:-loan-service}"
export SERVICE_VERSION="${SERVICE_VERSION:-1.2.0}"
export SERVICE_ENV="${SERVICE_ENV:-production}"
export LOG_LEVEL="${LOG_LEVEL:-info}"

# --- Factor 11: Log level filtering ---
_LOG_PRIORITY_DEBUG=0
_LOG_PRIORITY_INFO=1
_LOG_PRIORITY_WARN=2
_LOG_PRIORITY_ERROR=3

_get_log_priority() {
  local level="$1"
  case "$level" in
    DEBUG) echo $_LOG_PRIORITY_DEBUG ;;
    INFO)  echo $_LOG_PRIORITY_INFO ;;
    WARN)  echo $_LOG_PRIORITY_WARN ;;
    ERROR) echo $_LOG_PRIORITY_ERROR ;;
    *)     echo $_LOG_PRIORITY_INFO ;;
  esac
}

# --- Factor 11: Structured JSON log to stdout ---
log_json() {
  local level="$1"
  local message="$2"
  local extra="${3:-}"

  local min_priority
  min_priority=$(_get_log_priority "$(echo "$LOG_LEVEL" | tr '[:lower:]' '[:upper:]')")
  local msg_priority
  msg_priority=$(_get_log_priority "$level")

  if [ "$msg_priority" -lt "$min_priority" ]; then
    return
  fi

  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

  local json
  json=$(printf '{"timestamp":"%s","level":"%s","service":"%s","version":"%s","message":"%s"' \
    "$timestamp" "$level" "$SERVICE_NAME" "$SERVICE_VERSION" "$message")

  if [ -n "$extra" ]; then
    json="${json},${extra}}"
  else
    json="${json}}"
  fi

  echo "$json" >&2
}
