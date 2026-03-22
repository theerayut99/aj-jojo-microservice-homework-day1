package com.example.loanhello.config

import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.oas.models.info.Info
import io.swagger.v3.oas.models.servers.Server
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
@EnableConfigurationProperties(ServiceConfig::class)
class OpenApiConfig(private val serviceConfig: ServiceConfig) {

    @Bean
    fun customOpenAPI(): OpenAPI = OpenAPI()
        .info(
            Info()
                .title("Loan Service API")
                .description("Kotlin + Spring Boot microservice that returns a sample loan-service JSON log entry")
                .version(serviceConfig.version)
        )
        .servers(listOf(Server().url("/").description("Current server")))
}
