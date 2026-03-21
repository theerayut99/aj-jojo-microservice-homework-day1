package com.example.loanhello.config

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.slf4j.LoggerFactory
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter

@Component
@Order(1)
class RequestLoggingFilter : OncePerRequestFilter() {

    private val log = LoggerFactory.getLogger(javaClass)

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val start = System.currentTimeMillis()
        filterChain.doFilter(request, response)
        val duration = System.currentTimeMillis() - start

        log.info(
            "method={} path={} status={} duration_ms={} ip={} user_agent={}",
            request.method,
            request.requestURI,
            response.status,
            duration,
            request.remoteAddr,
            request.getHeader("User-Agent") ?: "-"
        )
    }
}
