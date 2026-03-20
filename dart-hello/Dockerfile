# =============================================================================
# Factor 5: Build, release, run — strictly separate build and run stages
# =============================================================================

# --- Build stage ---
FROM dart:stable AS build
WORKDIR /app

# Factor 2: Dependencies — explicitly declared and isolated
COPY pubspec.yaml pubspec.lock* ./
RUN dart pub get
COPY . .
RUN dart compile exe bin/main.dart -o bin/server

# --- Run stage ---
FROM alpine:latest

# Copy runtime dependencies
COPY --from=build /runtime/ /

# Copy compiled server executable
COPY --from=build /app/bin/server server

# Factor 10: Dev/prod parity — same config mechanism, different values via env
COPY --from=build /app/config/ config/

# Factor 3: Store config in environment variables
ENV SERVICE_NAME=loan-service
ENV SERVICE_VERSION=1.2.0
ENV SERVICE_ENV=production
ENV LOG_LEVEL=info
ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

# Factor 9: Disposability — graceful shutdown via SIGTERM
STOPSIGNAL SIGTERM

# Factor 7: Port binding — export service via port binding
EXPOSE 8080 8081 8082

# Factor 12: Admin processes — run as one-off commands in identical environment
# docker exec <container> ./server --mode=production --role=maintenance

ENTRYPOINT ./server --mode=$runmode --server-id=$serverid --logging=$logging --role=$role
