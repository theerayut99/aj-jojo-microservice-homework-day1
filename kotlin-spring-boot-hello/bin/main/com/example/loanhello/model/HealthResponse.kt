package com.example.loanhello.model

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Health check response")
data class HealthResponse(
    @Schema(example = "ok") val status: String,
    @Schema(example = "loan-service") val service: String,
    @Schema(example = "1.2.0") val version: String
)
