package com.example.loanhello;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.EventListener;

import static net.logstash.logback.argument.StructuredArguments.kv;

// Factor 1: Codebase — single entry point for the application
@SpringBootApplication
public class LoanHelloApplication {

    private static final Logger log = LoggerFactory.getLogger(LoanHelloApplication.class);

    public static void main(String[] args) {
        SpringApplication.run(LoanHelloApplication.class, args);
    }

    // Factor 9: Disposability — log startup for observability
    // Factor 11: Logs — structured startup event to stdout
    @EventListener(ApplicationReadyEvent.class)
    public void onStartup() {
        log.info("Server started",
                kv("port", System.getenv().getOrDefault("PORT", "8080")),
                kv("environment", System.getenv().getOrDefault("SERVICE_ENV", "production")),
                kv("log_level", System.getenv().getOrDefault("LOG_LEVEL", "INFO"))
        );
    }

    // Factor 9: Disposability — log graceful shutdown
    @EventListener(ContextClosedEvent.class)
    public void onShutdown() {
        log.info("Shutdown signal received, draining connections...");
    }
}
