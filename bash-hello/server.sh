#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Factor 2: Dependencies — source shared config & logging library
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

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

log_json "INFO" "Starting server" "\"host\":\"$HOST\",\"port\":\"$PORT\",\"environment\":\"$SERVICE_ENV\",\"log_level\":\"$LOG_LEVEL\""

# Factor 7: Port binding — socat listens and forks handler.sh per connection
socat "TCP-LISTEN:${PORT},bind=${HOST},reuseaddr,fork" "SYSTEM:${SCRIPT_DIR}/handler.sh" &
SOCAT_PID=$!

log_json "INFO" "Server started" "\"address\":\"${HOST}:${PORT}\""

# Wait for socat process
wait "$SOCAT_PID"
