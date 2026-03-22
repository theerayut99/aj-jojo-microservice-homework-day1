local cjson = require "cjson"

local _M = {}

function _M.index()
    ngx.header["Content-Type"] = "application/json"

    local method = ngx.req.get_method()
    local payload = { customer_id = 1001 }

    if method == "POST" then
        ngx.req.read_body()
        local req_body = ngx.req.get_body_data()
        if req_body then
            local success, parsed = pcall(cjson.decode, req_body)
            if success and type(parsed) == "table" then
                payload = parsed
            end
        end
    end

    local response = {
        timestamp = "2026-03-18T14:10:25.123Z",
        level = "INFO",
        service = {
            name = "loan-service",
            version = "1.2.0",
            environment = "production"
        },
        trace = {
            trace_id = "abc123xyz",
            span_id = "span-001",
            parent_span_id = cjson.null
        },
        request = {
            method = "POST",
            path = "/api/v1/loan/apply",
            query = {},
            headers = {
                ["x-request-id"] = "abc123xyz"
            },
            body = payload,
            ip = "10.0.0.1",
            user_agent = "PostmanRuntime/7.32"
        },
        response = {
            status_code = 200,
            body = {
                result = "success"
            },
            duration_ms = 120
        },
        user = {
            id = "u-1001",
            role = "customer"
        },
        error = cjson.null,
        error = cjson.null,
        message = method == "POST" and "Webhook event processed successfully" or "Loan application processed successfully",
        tags = method == "POST" and { "loan", "webhook", "apply" } or { "loan", "apply" },
        extra = {}
    }

    -- cjson encodes empty table as array [] by default, force as object {}
    cjson.encode_empty_table_as_object(true)
    -- query and extra should be objects {}
    -- but tags should be array [] — we handle this by structure (sequential keys)

    local json_str = cjson.encode(response)
    ngx.say(json_str)
end

function _M.health()
    ngx.header["Content-Type"] = "application/json"

    local service_name = os.getenv("SERVICE_NAME") or "loan-service"
    local service_version = os.getenv("SERVICE_VERSION") or "1.2.0"

    local health = {
        status = "ok",
        service = service_name,
        version = service_version
    }

    ngx.say(cjson.encode(health))
end

return _M
