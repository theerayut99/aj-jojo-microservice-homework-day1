var builder = WebApplication.CreateBuilder(args);

var host = Environment.GetEnvironmentVariable("HOST") ?? "0.0.0.0";
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";

builder.WebHost.UseUrls($"http://{host}:{port}");

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapGet("/", () => new
{
    timestamp = "2026-03-18T14:10:25.123Z",
    level = "INFO",
    service = new
    {
        name = "loan-service",
        version = "1.2.0",
        environment = "production"
    },
    trace = new
    {
        trace_id = "abc123xyz",
        span_id = "span-001",
        parent_span_id = (string?)null
    },
    request = new
    {
        method = "POST",
        path = "/api/v1/loan/apply",
        query = new { },
        headers = new { x_request_id = "abc123xyz" },
        body = new { customer_id = 1001 },
        ip = "10.0.0.1",
        user_agent = "PostmanRuntime/7.32"
    },
    response = new
    {
        status_code = 200,
        body = new { result = "success" },
        duration_ms = 120
    },
    user = new
    {
        id = "u-1001",
        role = "customer"
    },
    error = (string?)null,
    message = "Loan application processed successfully",
    tags = new[] { "loan", "apply" },
    extra = new { }
})
.WithName("GetLoanLog")
.WithOpenApi();

app.MapGet("/health", () => new { status = "ok" })
    .WithName("HealthCheck")
    .WithOpenApi();

app.Run();
