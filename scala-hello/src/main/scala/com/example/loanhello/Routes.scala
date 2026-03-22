package com.example.loanhello

import org.apache.pekko.http.scaladsl.server.Directives.*
import org.apache.pekko.http.scaladsl.server.Route
import org.apache.pekko.http.scaladsl.model.*
import spray.json.{DefaultJsonProtocol, JsonFormat, NullOptions, enrichAny}

import scala.io.Source

object Routes extends DefaultJsonProtocol with NullOptions:

  implicit val serviceInfoFormat: JsonFormat[ServiceInfo] = jsonFormat3(ServiceInfo.apply)
  implicit val traceInfoFormat: JsonFormat[TraceInfo] = jsonFormat3(TraceInfo.apply)
  implicit val requestHeadersFormat: JsonFormat[RequestHeaders] = jsonFormat1(RequestHeaders.apply)
  implicit val requestBodyFormat: JsonFormat[RequestBody] = jsonFormat1(RequestBody.apply)
  implicit val requestInfoFormat: JsonFormat[RequestInfo] = jsonFormat7(RequestInfo.apply)
  implicit val responseBodyFormat: JsonFormat[ResponseBody] = jsonFormat1(ResponseBody.apply)
  implicit val responseInfoFormat: JsonFormat[ResponseInfo] = jsonFormat3(ResponseInfo.apply)
  implicit val userInfoFormat: JsonFormat[UserInfo] = jsonFormat2(UserInfo.apply)
  implicit val healthResponseFormat: JsonFormat[HealthResponse] = jsonFormat3(HealthResponse.apply)
  implicit val loanLogResponseFormat: JsonFormat[LoanLogResponse] = jsonFormat11(LoanLogResponse.apply)

  private def jsonResponse[T: JsonFormat](value: T): HttpResponse =
    HttpResponse(entity = HttpEntity(ContentTypes.`application/json`, value.toJson.compactPrint))

  val swaggerHtml: String =
    """<!DOCTYPE html>
      |<html><head>
      |<title>Swagger UI</title>
      |<meta charset="utf-8"/>
      |<link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css"/>
      |</head><body>
      |<div id="swagger-ui"></div>
      |<script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
      |<script>SwaggerUIBundle({url:"/openapi.json",dom_id:"#swagger-ui"});</script>
      |</body></html>""".stripMargin

  private def loadOpenApiJson: String =
    val stream = getClass.getClassLoader.getResourceAsStream("openapi.json")
    if stream != null then
      try Source.fromInputStream(stream, "UTF-8").mkString
      finally stream.close()
    else """{"error":"openapi.json not found"}"""

  val routes: Route =
    pathSingleSlash {
      get {
        complete(jsonResponse(Models.createLoanLog))
      }
    } ~
    path("health") {
      get {
        complete(jsonResponse(HealthResponse("ok", "scala-hello", "1.0.0")))
      }
    } ~
    path("swagger") {
      get {
        complete(HttpEntity(ContentTypes.`text/html(UTF-8)`, swaggerHtml))
      }
    } ~
    path("openapi.json") {
      get {
        complete(HttpEntity(ContentType(MediaTypes.`application/json`), loadOpenApiJson))
      }
    }
