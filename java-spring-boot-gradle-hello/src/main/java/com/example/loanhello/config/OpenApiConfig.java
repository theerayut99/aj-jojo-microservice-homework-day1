package com.example.loanhello.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI loanServiceOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Loan Service API")
                        .description("Spring Boot (Gradle) microservice that returns a sample loan-service JSON log entry")
                        .version("1.2.0"))
                .servers(List.of(new Server().url("http://localhost:8080")));
    }
}
