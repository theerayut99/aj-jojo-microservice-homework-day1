package com.example.loanhello

case class ServiceInfo(name: String, version: String, environment: String)
case class TraceInfo(trace_id: String, span_id: String, parent_span_id: Option[String])
case class RequestHeaders(`x-request-id`: String)
case class RequestInfo(method: String, path: String, query: Map[String, String], headers: RequestHeaders, body: spray.json.JsValue, ip: String, user_agent: String)
case class ResponseBody(result: String)
case class ResponseInfo(status_code: Int, body: ResponseBody, duration_ms: Int)
case class UserInfo(id: String, role: String)
case class HealthResponse(status: String, service: String, version: String)

case class LoanLogResponse(
  timestamp: String,
  level: String,
  service: ServiceInfo,
  trace: TraceInfo,
  request: RequestInfo,
  response: ResponseInfo,
  user: UserInfo,
  error: Option[String],
  message: String,
  tags: List[String],
  extra: Map[String, String]
)

object Models:
  def createLoanLog: LoanLogResponse = LoanLogResponse(
    timestamp = "2026-03-18T14:10:25.123Z",
    level = "INFO",
    service = ServiceInfo("loan-service", "1.2.0", "production"),
    trace = TraceInfo("abc123xyz", "span-001", None),
    request = RequestInfo(
      method = "POST",
      path = "/api/v1/loan/apply",
      query = Map.empty,
      headers = RequestHeaders("abc123xyz"),
      body = spray.json.JsObject("customer_id" -> spray.json.JsNumber(1001)),
      ip = "10.0.0.1",
      user_agent = "PostmanRuntime/7.32"
    ),
    response = ResponseInfo(200, ResponseBody("success"), 120),
    user = UserInfo("u-1001", "customer"),
    error = None,
    message = "Loan application processed successfully",
    tags = List("loan", "apply"),
    extra = Map.empty
  )

  def createWebhookEvent(payload: spray.json.JsValue): LoanLogResponse = createLoanLog.copy(
    message = "Webhook event processed successfully",
    tags = List("loan", "webhook", "apply"),
    request = createLoanLog.request.copy(body = payload)
  )
