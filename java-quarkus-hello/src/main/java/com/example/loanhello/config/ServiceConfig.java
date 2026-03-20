package com.example.loanhello.config;

import io.smallrye.config.ConfigMapping;
import io.smallrye.config.WithDefault;

/**
 * Factor 3: Config — Store config in the environment.
 * All values read from environment variables at startup via MicroProfile Config.
 */
@ConfigMapping(prefix = "service")
public interface ServiceConfig {

    @WithDefault("loan-service")
    String name();

    @WithDefault("1.2.0")
    String version();

    @WithDefault("production")
    String environment();
}
