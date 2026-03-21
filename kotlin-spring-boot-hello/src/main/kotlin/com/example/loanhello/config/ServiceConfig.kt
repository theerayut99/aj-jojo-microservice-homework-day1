package com.example.loanhello.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "service")
data class ServiceConfig(
    val name: String = "loan-service",
    val version: String = "1.2.0",
    val environment: String = "production"
)
