package com.example.loanhello.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

/**
 * Factor 3: Config — Store config in the environment.
 * All service metadata is read from environment variables via Spring @Value.
 * No hardcoded values — every field has a default but can be overridden via env.
 */
@Configuration
public class ServiceConfig {

    @Value("${service.name:loan-service}")
    private String name;

    @Value("${service.version:1.2.0}")
    private String version;

    @Value("${service.environment:production}")
    private String environment;

    public String getName() { return name; }
    public String getVersion() { return version; }
    public String getEnvironment() { return environment; }
}
