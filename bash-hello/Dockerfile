# Factor 5: Build, release, run — single stage (no compilation needed)
FROM alpine:3.20

# Factor 2: Dependencies — explicitly install bash and socat
RUN apk add --no-cache bash socat coreutils

WORKDIR /app

# Factor 1: Codebase — copy application scripts and static files
COPY server.sh handler.sh lib.sh swagger.html openapi.json ./
RUN chmod +x server.sh handler.sh lib.sh

# Factor 3: Config — environment variables with defaults
ENV HOST=0.0.0.0
ENV PORT=3000
ENV SERVICE_NAME=loan-service
ENV SERVICE_VERSION=1.2.0
ENV SERVICE_ENV=production
ENV LOG_LEVEL=info

# Factor 7: Port binding
EXPOSE 3000

# Factor 6: Processes — stateless process
# Factor 9: Disposability — fast startup, graceful shutdown
STOPSIGNAL SIGTERM
CMD ["./server.sh"]
