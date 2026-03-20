package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	_ "go-hello/docs"
)

// =============================================================================
// Factor 3: Store config in environment variables
// =============================================================================

type Config struct {
	Host           string
	Port           string
	ServiceName    string
	ServiceVersion string
	ServiceEnv     string
	LogLevel       string
}

func loadConfig() Config {
	return Config{
		Host:           getEnv("HOST", "0.0.0.0"),
		Port:           getEnv("PORT", "3000"),
		ServiceName:    getEnv("SERVICE_NAME", "loan-service"),
		ServiceVersion: getEnv("SERVICE_VERSION", "1.2.0"),
		ServiceEnv:     getEnv("SERVICE_ENV", "production"),
		LogLevel:       getEnv("LOG_LEVEL", "info"),
	}
}

func getEnv(key, fallback string) string {
	if val, ok := os.LookupEnv(key); ok {
		return val
	}
	return fallback
}

// Global config — loaded once at startup
var cfg Config

// =============================================================================
// Factor 11: Logs — treat logs as event streams (structured JSON to stdout)
// =============================================================================

var logLevelPriority = map[string]int{
	"DEBUG": 0,
	"INFO":  1,
	"WARN":  2,
	"ERROR": 3,
}

func logJSON(level, message string, extra map[string]interface{}) {
	// Log level filtering
	minLevel := strings.ToUpper(cfg.LogLevel)
	if logLevelPriority[strings.ToUpper(level)] < logLevelPriority[minLevel] {
		return
	}

	entry := map[string]interface{}{
		"timestamp": time.Now().UTC().Format(time.RFC3339Nano),
		"level":     strings.ToUpper(level),
		"service":   cfg.ServiceName,
		"version":   cfg.ServiceVersion,
		"message":   message,
	}
	for k, v := range extra {
		entry[k] = v
	}
	data, _ := json.Marshal(entry)
	fmt.Fprintln(os.Stdout, string(data))
}

// Factor 11: Request logging middleware — structured access log to stdout
func requestLogger() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.Request.URL.Path

		c.Next()

		logJSON("INFO", "HTTP request", map[string]interface{}{
			"method":      c.Request.Method,
			"path":        path,
			"status":      c.Writer.Status(),
			"duration_ms": time.Since(start).Milliseconds(),
			"ip":          c.ClientIP(),
			"user_agent":  c.Request.UserAgent(),
		})
	}
}

// =============================================================================
// Factor 9: Disposability — fast startup, graceful shutdown via SIGTERM/SIGINT
// =============================================================================

func gracefulShutdown(srv *http.Server, quit <-chan os.Signal) {
	<-quit
	logJSON("INFO", "Shutdown signal received, draining connections...", nil)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		logJSON("ERROR", "Forced shutdown", map[string]interface{}{
			"error": err.Error(),
		})
	}

	logJSON("INFO", "Server stopped", nil)
}

// =============================================================================
// Swagger models
// =============================================================================

// @title Loan Service API
// @version 1.2.0
// @description Go microservice that returns a sample loan-service JSON log entry
// @host localhost:3000
// @BasePath /

// ServiceInfo represents service metadata
type ServiceInfo struct {
	Name        string `json:"name" example:"loan-service"`
	Version     string `json:"version" example:"1.2.0"`
	Environment string `json:"environment" example:"production"`
}

// TraceInfo represents distributed tracing context
type TraceInfo struct {
	TraceID      string  `json:"trace_id" example:"abc123xyz"`
	SpanID       string  `json:"span_id" example:"span-001"`
	ParentSpanID *string `json:"parent_span_id" example:""`
}

// RequestHeaders represents HTTP request headers
type RequestHeaders struct {
	XRequestID string `json:"x-request-id" example:"abc123xyz"`
}

// RequestBody represents the request payload
type RequestBody struct {
	CustomerID int `json:"customer_id" example:"1001"`
}

// RequestInfo represents HTTP request details
type RequestInfo struct {
	Method    string         `json:"method" example:"POST"`
	Path      string         `json:"path" example:"/api/v1/loan/apply"`
	Query     map[string]any `json:"query"`
	Headers   RequestHeaders `json:"headers"`
	Body      RequestBody    `json:"body"`
	IP        string         `json:"ip" example:"10.0.0.1"`
	UserAgent string         `json:"user_agent" example:"PostmanRuntime/7.32"`
}

// ResponseBody represents the response payload
type ResponseBody struct {
	Result string `json:"result" example:"success"`
}

// ResponseInfo represents HTTP response details
type ResponseInfo struct {
	StatusCode int          `json:"status_code" example:"200"`
	Body       ResponseBody `json:"body"`
	DurationMs int          `json:"duration_ms" example:"120"`
}

// UserInfo represents authenticated user context
type UserInfo struct {
	ID   string `json:"id" example:"u-1001"`
	Role string `json:"role" example:"customer"`
}

// LoanLogResponse represents the full loan service log entry
type LoanLogResponse struct {
	Timestamp string         `json:"timestamp" example:"2026-03-20T01:22:47.948015Z"`
	Level     string         `json:"level" example:"INFO"`
	Service   ServiceInfo    `json:"service"`
	Trace     TraceInfo      `json:"trace"`
	Request   RequestInfo    `json:"request"`
	Response  ResponseInfo   `json:"response"`
	User      UserInfo       `json:"user"`
	Error     *string        `json:"error"`
	Message   string         `json:"message" example:"Loan application processed successfully"`
	Tags      []string       `json:"tags" example:"loan,apply"`
	Extra     map[string]any `json:"extra"`
}

// HealthResponse represents health check response
type HealthResponse struct {
	Status  string `json:"status" example:"ok"`
	Service string `json:"service" example:"loan-service"`
	Version string `json:"version" example:"1.2.0"`
}

// =============================================================================
// Routes
// =============================================================================

// getLoanLog godoc
// @Summary      Get loan service log
// @Description  Returns a sample structured JSON log for a loan application request
// @Tags         loan
// @Produce      json
// @Success      200 {object} LoanLogResponse
// @Router       / [get]
func getLoanLog(c *gin.Context) {
	// Factor 3: Config — service metadata from environment
	body := gin.H{
		"timestamp": time.Now().UTC().Format(time.RFC3339Nano),
		"level":     "INFO",
		"service": gin.H{
			"name":        cfg.ServiceName,
			"version":     cfg.ServiceVersion,
			"environment": cfg.ServiceEnv,
		},
		"trace": gin.H{
			"trace_id":       "abc123xyz",
			"span_id":        "span-001",
			"parent_span_id": nil,
		},
		"request": gin.H{
			"method": "POST",
			"path":   "/api/v1/loan/apply",
			"query":  gin.H{},
			"headers": gin.H{
				"x-request-id": "abc123xyz",
			},
			"body": gin.H{
				"customer_id": 1001,
			},
			"ip":         "10.0.0.1",
			"user_agent": "PostmanRuntime/7.32",
		},
		"response": gin.H{
			"status_code": 200,
			"body": gin.H{
				"result": "success",
			},
			"duration_ms": 120,
		},
		"user": gin.H{
			"id":   "u-1001",
			"role": "customer",
		},
		"error":   nil,
		"message": "Loan application processed successfully",
		"tags":    []string{"loan", "apply"},
		"extra":   gin.H{},
	}

	c.JSON(http.StatusOK, body)
}

// healthCheck godoc
// @Summary      Health check
// @Description  Health check endpoint for liveness/readiness probes
// @Tags         health
// @Produce      json
// @Success      200 {object} HealthResponse
// @Router       /health [get]
func healthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "ok",
		"service": cfg.ServiceName,
		"version": cfg.ServiceVersion,
	})
}

// =============================================================================
// Main — Factor 7: Port binding (self-contained HTTP server)
// =============================================================================

func main() {
	// Factor 3: Config from environment — centralized
	cfg = loadConfig()

	// Factor 10: Dev/prod parity — same binary, different env
	if cfg.ServiceEnv == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// Factor 11: Log startup
	logJSON("INFO", "Starting server", map[string]interface{}{
		"environment": cfg.ServiceEnv,
		"log_level":   cfg.LogLevel,
	})

	// Factor 2: Dependencies — declared in go.mod, isolated via go mod download
	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(requestLogger()) // Factor 11: structured access logs

	// Factor 7: Port binding — register routes on self-contained HTTP server
	r.GET("/", getLoanLog)
	r.GET("/health", healthCheck)
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Factor 7: Port binding — create http.Server for graceful shutdown support
	addr := fmt.Sprintf("%s:%s", cfg.Host, cfg.Port)
	srv := &http.Server{
		Addr:    addr,
		Handler: r,
	}

	// Factor 9: Disposability — graceful shutdown on SIGTERM / SIGINT
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	go gracefulShutdown(srv, quit)

	// Factor 7: Start listening
	logJSON("INFO", "Server started", map[string]interface{}{
		"address": addr,
	})
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		logJSON("ERROR", "Server failed", map[string]interface{}{
			"error": err.Error(),
		})
		os.Exit(1)
	}
}
