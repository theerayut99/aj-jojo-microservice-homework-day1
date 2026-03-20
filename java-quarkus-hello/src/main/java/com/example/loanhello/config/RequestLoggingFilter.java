package com.example.loanhello.config;

import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerResponseContext;
import jakarta.ws.rs.container.ContainerResponseFilter;
import jakarta.ws.rs.ext.Provider;
import org.jboss.logging.Logger;

/**
 * Factor 11: Logs — structured access log for every request.
 * Logs method, path, status, duration_ms, ip, user_agent as structured fields.
 */
@Provider
public class RequestLoggingFilter implements ContainerResponseFilter {

    private static final Logger LOG = Logger.getLogger(RequestLoggingFilter.class);
    private static final String START_TIME = "request-start-time";

    @Override
    public void filter(ContainerRequestContext request, ContainerResponseContext response) {
        long start = (long) request.getProperty(START_TIME);
        long duration = System.currentTimeMillis() - start;
        String method = request.getMethod();
        String path = request.getUriInfo().getRequestUri().getPath();
        int status = response.getStatus();
        String ip = request.getHeaderString("X-Forwarded-For");
        if (ip == null) {
            ip = "unknown";
        }
        String userAgent = request.getHeaderString("User-Agent");

        LOG.infof("access_log method=%s path=%s status=%d duration_ms=%d ip=%s user_agent=%s",
                method, path, status, duration, ip, userAgent);
    }
}
