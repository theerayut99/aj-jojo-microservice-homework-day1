#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Factor 3: Store config in environment variables
# =============================================================================
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-3000}"
export SERVICE_NAME="${SERVICE_NAME:-loan-service}"
export SERVICE_VERSION="${SERVICE_VERSION:-1.2.0}"
export SERVICE_ENV="${SERVICE_ENV:-production}"
export LOG_LEVEL="${LOG_LEVEL:-info}"

# =============================================================================
# Factor 11: Logs — treat logs as event streams (structured JSON to stdout)
# =============================================================================
LOG_LEVELS="DEBUG:0 INFO:1 WARN:2 ERROR:3"

get_level_priority() {
  local level="$1"
  for entry in $LOG_LEVELS; do
    if [ "${entry%%:*}" = "$level" ]; then
      echo "${entry##*:}"
      return
    fi
  done
  echo "1"
}

log_json() {
  local level="$1"
  local message="$2"
  local extra="${3:-}"

  local min_priority
  min_priority=$(get_level_priority "$(echo "$LOG_LEVEL" | tr '[:lower:]' '[:upper:]')")
  local msg_priority
  msg_priority=$(get_level_priority "$level")

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

  echo "$json"
}

# =============================================================================
# Factor 9: Disposability — fast startup, graceful shutdown via SIGTERM/SIGINT
# =============================================================================
SOCAT_PID=""

shutdown_handler() {
  log_json "INFO" "Shutdown signal received, stopping server..."
  if [ -n "$SOCAT_PID" ] && kill -0 "$SOCAT_PID" 2>/dev/null; then
    kill "$SOCAT_PID" 2>/dev/null || true
    wait "$SOCAT_PID" 2>/dev/null || true
  fi
  log_json "INFO" "Server stopped"
  exit 0
}

trap shutdown_handler SIGTERM SIGINT

# =============================================================================
# Main — Factor 7: Port binding (self-contained HTTP server via socat)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

log_json "INFO" "Starting server" "\"environment\":\"$SERVICE_ENV\",\"log_level\":\"$LOG_LEVEL\""

# Factor 7: Port binding — socat listens and forks handler.sh per connection
socat "TCP-LISTEN:${PORT},bind=${HOST},reuseaddr,fork" "SYSTEM:${SCRIPT_DIR}/handler.sh" &
SOCAT_PID=$!

log_json "INFO" "Server started" "\"address\":\"${HOST}:${PORT}\""

# Wait for socat process
wait "$SOCAT_PID"
