# ==============================================================================
# Factor 5: Build, Release, Run — Strictly separate build and run stages
# Factor 2: Dependencies — Explicitly declare and isolate dependencies
# ==============================================================================

# ---- Build Stage ----
# Factor 2: Dependencies — Maven manages all dependencies via pom.xml
FROM maven:3-eclipse-temurin-21-alpine AS builder

WORKDIR /app

# Factor 2: Dependencies — copy pom.xml first for layer caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build
COPY src ./src
# Factor 5: Build, release, run — compile to Quarkus fast-jar
RUN mvn package -DskipTests -B

# ---- Run Stage ----
# Factor 5: Build, release, run — minimal runtime image
FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

# Factor 1: Codebase — copy only the compiled Quarkus app
COPY --from=builder /app/target/quarkus-app/ /app/

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
CMD ["java", "-jar", "quarkus-run.jar"]
