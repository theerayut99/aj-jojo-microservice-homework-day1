package com.example.loanhello.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.time.Instant;
import java.util.List;
import java.util.Map;

@Schema(description = "Loan service log response")
public record LoanLogResponse(
        @Schema(example = "2026-03-18T14:10:25.123Z")
        String timestamp,

        @Schema(example = "INFO")
        String level,

        ServiceInfo service,
        TraceInfo trace,
        RequestInfo request,
        ResponseInfo response,
        UserInfo user,

        @Schema(nullable = true)
        Object error,

        @Schema(example = "Loan application processed successfully")
        String message,

        @Schema(example = "[\"loan\", \"apply\"]")
        List<String> tags,

        Map<String, Object> extra
) {
    public static LoanLogResponse create(String serviceName, String serviceVersion, String serviceEnv) {
        return new LoanLogResponse(
                Instant.now().toString(),
                "INFO",
                new ServiceInfo(serviceName, serviceVersion, serviceEnv),
                new TraceInfo("abc123xyz", "span-001", null),
                new RequestInfo(
                        "POST",
                        "/api/v1/loan/apply",
                        Map.of(),
                        new RequestHeaders("abc123xyz"),
                        new RequestBody(1001),
                        "10.0.0.1",
                        "PostmanRuntime/7.32"
                ),
                new ResponseInfo(200, new ResponseBody("success"), 120),
                new UserInfo("u-1001", "customer"),
                null,
                "Loan application processed successfully",
                List.of("loan", "apply"),
                Map.of()
        );
    }

    public static LoanLogResponse createWebhookEvent(String serviceName, String serviceVersion, String serviceEnv, Object payload) {
        return new LoanLogResponse(
                Instant.now().toString(),
                "INFO",
                new ServiceInfo(serviceName, serviceVersion, serviceEnv),
                new TraceInfo("abc123xyz", "span-001", null),
                new RequestInfo(
                        "POST",
                        "/api/v1/loan/apply",
                        Map.of(),
                        new RequestHeaders("abc123xyz"),
                        payload != null ? payload : Map.of(),
                        "10.0.0.1",
                        "PostmanRuntime/7.32"
                ),
                new ResponseInfo(200, new ResponseBody("success"), 120),
                new UserInfo("u-1001", "customer"),
                null,
                "Webhook event processed successfully",
                List.of("loan", "webhook", "apply"),
                Map.of()
        );
    }

    @Schema(description = "Service information")
    public record ServiceInfo(
            @Schema(example = "loan-service") String name,
            @Schema(example = "1.2.0") String version,
            @Schema(example = "production") String environment
    ) {}

    @Schema(description = "Distributed trace information")
    public record TraceInfo(
            @JsonProperty("trace_id") @Schema(example = "abc123xyz") String traceId,
            @JsonProperty("span_id") @Schema(example = "span-001") String spanId,
            @JsonProperty("parent_span_id") @Schema(nullable = true) String parentSpanId
    ) {}

    @Schema(description = "Request information")
    public record RequestInfo(
            @Schema(example = "POST") String method,
            @Schema(example = "/api/v1/loan/apply") String path,
            Map<String, Object> query,
            RequestHeaders headers,
            Object body,
            @Schema(example = "10.0.0.1") String ip,
            @JsonProperty("user_agent") @Schema(example = "PostmanRuntime/7.32") String userAgent
    ) {}

    @Schema(description = "Request headers")
    public record RequestHeaders(
            @JsonProperty("x-request-id") @Schema(example = "abc123xyz") String xRequestId
    ) {}

    @Schema(description = "Request body")
    public record RequestBody(
            @JsonProperty("customer_id") @Schema(example = "1001") int customerId
    ) {}

    @Schema(description = "Response information")
    public record ResponseInfo(
            @JsonProperty("status_code") @Schema(example = "200") int statusCode,
            ResponseBody body,
            @JsonProperty("duration_ms") @Schema(example = "120") int durationMs
    ) {}

    @Schema(description = "Response body")
    public record ResponseBody(
            @Schema(example = "success") String result
    ) {}

    @Schema(description = "User information")
    public record UserInfo(
            @Schema(example = "u-1001") String id,
            @Schema(example = "customer") String role
    ) {}
}
