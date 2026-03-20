package com.example.loanhello.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

import static net.logstash.logback.argument.StructuredArguments.kv;

/**
 * Factor 11: Logs — structured access log for every HTTP request to stdout.
 * Logs method, path, status, duration_ms, ip, user_agent as structured fields.
 */
@Component
public class RequestLoggingFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(RequestLoggingFilter.class);

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        long start = System.currentTimeMillis();

        filterChain.doFilter(request, response);

        long duration = System.currentTimeMillis() - start;

        log.info("HTTP request",
                kv("method", request.getMethod()),
                kv("path", request.getRequestURI()),
                kv("status", response.getStatus()),
                kv("duration_ms", duration),
                kv("ip", request.getRemoteAddr()),
                kv("user_agent", request.getHeader("User-Agent"))
        );
    }
}
