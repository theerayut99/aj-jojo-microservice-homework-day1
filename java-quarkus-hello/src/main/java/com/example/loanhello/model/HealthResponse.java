package com.example.loanhello.model;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Schema(description = "Health check response")
public record HealthResponse(
        @Schema(example = "ok") String status,
        @Schema(example = "loan-service") String service,
        @Schema(example = "1.2.0") String version
) {}
