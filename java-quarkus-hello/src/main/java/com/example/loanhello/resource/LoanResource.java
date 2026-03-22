package com.example.loanhello.resource;

import com.example.loanhello.config.ServiceConfig;
import com.example.loanhello.model.HealthResponse;
import com.example.loanhello.model.LoanLogResponse;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;

/**
 * Factor 7: Port Binding — endpoints exposed via embedded server.
 * Factor 6: Processes — stateless request handling.
 */
@Path("/")
@Produces(MediaType.APPLICATION_JSON)
public class LoanResource {

    @Inject
    ServiceConfig config;

    @GET
    @Tag(name = "loan")
    @Operation(summary = "Get loan service log",
               description = "Returns a sample structured JSON log for a loan application request")
    @APIResponse(responseCode = "200", description = "OK",
                 content = @Content(schema = @Schema(implementation = LoanLogResponse.class)))
    public LoanLogResponse getLoanLog() {
        return LoanLogResponse.create(config.name(), config.version(), config.environment());
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Tag(name = "loan")
    @Operation(summary = "Receive loan service webhook",
               description = "Accepts an event payload and returns a webhook processed response")
    @APIResponse(responseCode = "200", description = "OK",
                 content = @Content(schema = @Schema(implementation = LoanLogResponse.class)))
    public LoanLogResponse postLoanLog(java.util.Map<String, Object> payload) {
        return LoanLogResponse.createWebhookEvent(config.name(), config.version(), config.environment(), payload);
    }

    @GET
    @Path("/health")
    @Tag(name = "health")
    @Operation(summary = "Health check",
               description = "Health check endpoint for liveness/readiness probes")
    @APIResponse(responseCode = "200", description = "OK",
                 content = @Content(schema = @Schema(implementation = HealthResponse.class)))
    public HealthResponse health() {
        return new HealthResponse("ok", config.name(), config.version());
    }
}
