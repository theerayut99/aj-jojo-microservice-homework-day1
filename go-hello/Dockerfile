# ---- Build Stage ----
# Factor 2: Dependencies — ใช้ go mod สำหรับจัดการ dependencies
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Factor 2: Dependencies — copy go.mod/go.sum and download dependencies first (layer caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Factor 5: Build, release, run — compile static binary
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server .

# ---- Run Stage ----
# Factor 5: Build, release, run — minimal runtime image
FROM alpine:3.20

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

# Factor 1: Codebase — copy only the compiled binary
COPY --from=builder /app/server .

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
CMD ["./server"]
