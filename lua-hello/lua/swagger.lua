local _M = {}

function _M.ui()
    ngx.header["Content-Type"] = "text/html"
    ngx.say([[<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Loan Service - Swagger UI</title>
    <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5.18.2/swagger-ui.css">
</head>
<body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5.18.2/swagger-ui-bundle.js"></script>
    <script>
        SwaggerUIBundle({
            url: '/openapi.json',
            dom_id: '#swagger-ui',
            presets: [
                SwaggerUIBundle.presets.apis,
                SwaggerUIBundle.SwaggerUIStandalonePreset
            ],
            layout: "BaseLayout"
        });
    </script>
</body>
</html>]])
end

function _M.spec()
    ngx.header["Content-Type"] = "application/json"
    local f = io.open("/app/openapi.json", "r")
    if not f then
        ngx.status = 404
        ngx.say('{"error":"openapi.json not found"}')
        return
    end
    local content = f:read("*a")
    f:close()
    ngx.say(content)
end

return _M
