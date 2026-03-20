# ==============================================================================
# Factor 5: Build, Release, Run — Strictly separate build and run stages
# Factor 2: Dependencies — Explicitly declare and isolate dependencies
# ==============================================================================

# ---- Build Stage ----
# Factor 2: Dependencies — Gradle manages all dependencies via build.gradle
FROM gradle:8-jdk21-alpine AS builder

WORKDIR /app

# Factor 2: Dependencies — copy build files first for layer caching
COPY build.gradle settings.gradle ./
RUN gradle dependencies --no-daemon || true

# Copy source code and build
COPY src ./src
# Factor 5: Build, release, run — compile to JAR
RUN gradle build --no-daemon -x test

# ---- Run Stage ----
# Factor 5: Build, release, run — minimal runtime image
FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

# Factor 1: Codebase — copy only the compiled JAR
COPY --from=builder /app/build/libs/*.jar app.jar

# Factor 3: Config — environment variables with defaults
ENV PORT=8080
ENV SERVICE_NAME=loan-service
ENV SERVICE_VERSION=1.2.0
ENV SERVICE_ENV=production
ENV LOG_LEVEL=INFO

# Factor 7: Port binding
EXPOSE 8080

# Factor 6: Processes — stateless process
# Factor 9: Disposability — fast startup, graceful shutdown
STOPSIGNAL SIGTERM
CMD ["java", "-jar", "app.jar"]
