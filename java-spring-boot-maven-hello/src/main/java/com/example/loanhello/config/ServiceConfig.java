package com.example.loanhello.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

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
