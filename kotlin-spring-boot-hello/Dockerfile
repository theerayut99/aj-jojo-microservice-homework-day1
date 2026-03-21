FROM gradle:8-jdk21-alpine AS builder

WORKDIR /app

COPY build.gradle.kts settings.gradle.kts ./
RUN gradle dependencies --no-daemon || true

COPY src ./src
RUN gradle build --no-daemon -x test

FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

COPY --from=builder /app/build/libs/app.jar app.jar

ENV PORT=8080
ENV SERVICE_NAME=loan-service
ENV SERVICE_VERSION=1.2.0
ENV SERVICE_ENV=production
ENV LOG_LEVEL=INFO

EXPOSE 8080

STOPSIGNAL SIGTERM
CMD ["java", "-jar", "app.jar"]
