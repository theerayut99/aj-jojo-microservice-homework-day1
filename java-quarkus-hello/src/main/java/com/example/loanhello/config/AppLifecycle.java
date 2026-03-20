package com.example.loanhello.config;

import io.quarkus.runtime.ShutdownEvent;
import io.quarkus.runtime.StartupEvent;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;

/**
 * Factor 9: Disposability — log startup/shutdown events.
 * Factor 11: Logs — structured event logging.
 */
@ApplicationScoped
public class AppLifecycle {

    private static final Logger LOG = Logger.getLogger(AppLifecycle.class);

    @Inject
    ServiceConfig config;

    @ConfigProperty(name = "quarkus.http.port", defaultValue = "8080")
    int port;

    @ConfigProperty(name = "quarkus.log.level", defaultValue = "INFO")
    String logLevel;

    void onStart(@Observes StartupEvent ev) {
        LOG.infof("Application started — port=%d, environment=%s, log_level=%s",
                port, config.environment(), logLevel);
    }

    void onStop(@Observes ShutdownEvent ev) {
        LOG.info("Application shutting down gracefully");
    }
}
