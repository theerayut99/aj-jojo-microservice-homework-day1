package com.example.loanhello.model

import com.fasterxml.jackson.annotation.JsonProperty
import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Loan service log response")
data class LoanLogResponse(
    @Schema(example = "2026-03-18T14:10:25.123Z")
    val timestamp: String,

    @Schema(example = "INFO")
    val level: String,

    val service: ServiceInfo,
    val trace: TraceInfo,
    val request: RequestInfo,
    val response: ResponseInfo,
    val user: UserInfo,

    @Schema(nullable = true)
    val error: Any?,

    @Schema(example = "Loan application processed successfully")
    val message: String,

    @Schema(example = "[\"loan\", \"apply\"]")
    val tags: List<String>,

    val extra: Map<String, Any>
) {
    companion object {
        fun create(serviceName: String, serviceVersion: String, serviceEnv: String) = LoanLogResponse(
            timestamp = java.time.Instant.now().toString(),
            level = "INFO",
            service = ServiceInfo(serviceName, serviceVersion, serviceEnv),
            trace = TraceInfo("abc123xyz", "span-001", null),
            request = RequestInfo(
                method = "POST",
                path = "/api/v1/loan/apply",
                query = emptyMap(),
                headers = RequestHeaders("abc123xyz"),
                body = RequestBody(1001),
                ip = "10.0.0.1",
                userAgent = "PostmanRuntime/7.32"
            ),
            response = ResponseInfo(200, ResponseBody("success"), 120),
            user = UserInfo("u-1001", "customer"),
            error = null,
            message = "Loan application processed successfully",
            tags = listOf("loan", "apply"),
            extra = emptyMap()
        )
    }
}

@Schema(description = "Service information")
data class ServiceInfo(
    @Schema(example = "loan-service") val name: String,
    @Schema(example = "1.2.0") val version: String,
    @Schema(example = "production") val environment: String
)

@Schema(description = "Distributed trace information")
data class TraceInfo(
    @get:JsonProperty("trace_id") @Schema(example = "abc123xyz") val traceId: String,
    @get:JsonProperty("span_id") @Schema(example = "span-001") val spanId: String,
    @get:JsonProperty("parent_span_id") @Schema(nullable = true) val parentSpanId: String?
)

@Schema(description = "Request information")
data class RequestInfo(
    @Schema(example = "POST") val method: String,
    @Schema(example = "/api/v1/loan/apply") val path: String,
    val query: Map<String, Any>,
    val headers: RequestHeaders,
    val body: RequestBody,
    @Schema(example = "10.0.0.1") val ip: String,
    @get:JsonProperty("user_agent") @Schema(example = "PostmanRuntime/7.32") val userAgent: String
)

@Schema(description = "Request headers")
data class RequestHeaders(
    @get:JsonProperty("x-request-id") @Schema(example = "abc123xyz") val xRequestId: String
)

@Schema(description = "Request body")
data class RequestBody(
    @get:JsonProperty("customer_id") @Schema(example = "1001") val customerId: Int
)

@Schema(description = "Response information")
data class ResponseInfo(
    @get:JsonProperty("status_code") @Schema(example = "200") val statusCode: Int,
    val body: ResponseBody,
    @get:JsonProperty("duration_ms") @Schema(example = "120") val durationMs: Int
)

@Schema(description = "Response body")
data class ResponseBody(
    @Schema(example = "success") val result: String
)

@Schema(description = "User information")
data class UserInfo(
    @Schema(example = "u-1001") val id: String,
    @Schema(example = "customer") val role: String
)
