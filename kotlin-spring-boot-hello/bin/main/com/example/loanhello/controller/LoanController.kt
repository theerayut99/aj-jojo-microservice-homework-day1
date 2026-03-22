package com.example.loanhello.controller

import com.example.loanhello.config.ServiceConfig
import com.example.loanhello.model.HealthResponse
import com.example.loanhello.model.LoanLogResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@Tag(name = "Loan", description = "Loan service endpoints")
class LoanController(private val config: ServiceConfig) {

    @GetMapping("/")
    @Operation(summary = "Get loan log entry", description = "Returns a sample structured JSON log for a loan application request")
    @ApiResponse(responseCode = "200", description = "Successful response")
    fun index(): LoanLogResponse =
        LoanLogResponse.create(config.name, config.version, config.environment)

    @GetMapping("/health")
    @Operation(summary = "Health check", description = "Health check endpoint for liveness/readiness probes")
    @ApiResponse(responseCode = "200", description = "Service is healthy")
    @Tag(name = "Health")
    fun health(): HealthResponse =
        HealthResponse(status = "ok", service = config.name, version = config.version)
}
