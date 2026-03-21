# --- Build stage ---
FROM sbtscala/scala-sbt:eclipse-temurin-21.0.8_9_1.12.6_3.3.7 AS builder

WORKDIR /app

COPY project/build.properties project/plugins.sbt project/
COPY build.sbt .
RUN sbt update

COPY src/ src/
RUN sbt assembly

# --- Runtime stage ---
FROM eclipse-temurin:21-jre-alpine

RUN addgroup -S app && adduser -S app -G app
WORKDIR /app

COPY --from=builder /app/target/scala-3.3.7/app.jar app.jar

ENV HOST=0.0.0.0
ENV PORT=8080
ENV LOG_LEVEL=INFO

EXPOSE 8080

USER app

ENTRYPOINT ["java", "-jar", "app.jar"]
