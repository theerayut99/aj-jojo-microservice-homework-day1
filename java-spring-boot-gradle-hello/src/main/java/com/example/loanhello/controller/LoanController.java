package com.example.loanhello.controller;

import com.example.loanhello.config.ServiceConfig;
import com.example.loanhello.model.HealthResponse;
import com.example.loanhello.model.LoanLogResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * Factor 7: Port Binding — endpoints exposed via embedded Tomcat.
 * Factor 6: Processes — stateless request handling, no session or local storage.
 * Factor 12: Admin Processes — /health for K8s probes.
 */
@RestController
public class LoanController {

    private final ServiceConfig config;

    public LoanController(ServiceConfig config) {
        this.config = config;
    }

    @Tag(name = "loan")
    @Operation(summary = "Get loan service log",
               description = "Returns a sample structured JSON log for a loan application request")
    @ApiResponse(responseCode = "200", description = "OK",
                 content = @Content(schema = @Schema(implementation = LoanLogResponse.class)))
    @GetMapping("/")
    public LoanLogResponse getLoanLog() {
        return LoanLogResponse.create(config.getName(), config.getVersion(), config.getEnvironment());
    }

    @Tag(name = "loan")
    @Operation(summary = "Receive loan service webhook",
               description = "Accepts an event payload and returns a webhook processed response")
    @ApiResponse(responseCode = "200", description = "OK",
                 content = @Content(schema = @Schema(implementation = LoanLogResponse.class)))
    @PostMapping("/")
    public LoanLogResponse postLoanLog(@RequestBody(required = false) java.util.Map<String, Object> payload) {
        return LoanLogResponse.createWebhookEvent(config.getName(), config.getVersion(), config.getEnvironment(), payload);
    }

    @Tag(name = "health")
    @Operation(summary = "Health check",
               description = "Health check endpoint for liveness/readiness probes")
    @ApiResponse(responseCode = "200", description = "OK",
                 content = @Content(schema = @Schema(implementation = HealthResponse.class)))
    @GetMapping("/health")
    public HealthResponse health() {
        return new HealthResponse("ok", config.getName(), config.getVersion());
    }
}
