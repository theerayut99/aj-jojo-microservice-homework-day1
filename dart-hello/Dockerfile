# Build stage
FROM dart:stable AS build
WORKDIR /app
COPY . .

RUN dart pub get
RUN dart compile exe bin/main.dart -o bin/server

# Final stage
FROM alpine:latest

# Copy runtime dependencies
COPY --from=build /runtime/ /

# Copy compiled server executable
COPY --from=build /app/bin/server server

# Copy configuration files
COPY --from=build /app/config/ config/

# 12-Factor: configuration via environment variables
ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

# Graceful shutdown
STOPSIGNAL SIGTERM

EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

ENTRYPOINT ./server --mode=$runmode --server-id=$serverid --logging=$logging --role=$role
