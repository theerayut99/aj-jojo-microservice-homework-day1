import 'dart:async';
import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import 'package:dart_hello_server/src/generated/protocol.dart';
import 'package:dart_hello_server/src/generated/endpoints.dart';

// --- Loan service route ---
class LoanRoute extends Route {
  LoanRoute() : super(path: '/');

  @override
  FutureOr<Result> handleCall(Session session, Request request) {
    final body = {
      'timestamp': '2026-03-18T14:10:25.123Z',
      'level': 'INFO',
      'service': {
        'name': 'loan-service',
        'version': '1.2.0',
        'environment': 'production',
      },
      'trace': {
        'trace_id': 'abc123xyz',
        'span_id': 'span-001',
        'parent_span_id': null,
      },
      'request': {
        'method': 'POST',
        'path': '/api/v1/loan/apply',
        'query': {},
        'headers': {
          'x-request-id': 'abc123xyz',
        },
        'body': {
          'customer_id': 1001,
        },
        'ip': '10.0.0.1',
        'user_agent': 'PostmanRuntime/7.32',
      },
      'response': {
        'status_code': 200,
        'body': {
          'result': 'success',
        },
        'duration_ms': 120,
      },
      'user': {
        'id': 'u-1001',
        'role': 'customer',
      },
      'error': null,
      'message': 'Loan application processed successfully',
      'tags': ['loan', 'apply'],
      'extra': {},
    };
    return Response.ok(
      body: Body.fromString(jsonEncode(body), mimeType: MimeType.json),
    );
  }
}

// --- Health check route ---
class HealthRoute extends Route {
  HealthRoute() : super(path: '/');

  @override
  FutureOr<Result> handleCall(Session session, Request request) {
    return Response.ok(
      body: Body.fromString(
        jsonEncode({'status': 'ok'}),
        mimeType: MimeType.json,
      ),
    );
  }
}

// --- OpenAPI spec route ---
final _openApiSpec = {
  'openapi': '3.0.3',
  'info': {
    'title': 'Dart Loan Service (Serverpod)',
    'description': 'Loan service API built with Dart Serverpod',
    'version': '1.0.0',
  },
  'paths': {
    '/': {
      'get': {
        'summary': 'Get loan service log',
        'operationId': 'getLoanLog',
        'responses': {
          '200': {
            'description': 'Loan service log entry',
            'content': {
              'application/json': {
                'schema': {'\$ref': '#/components/schemas/LoanLog'},
              },
            },
          },
        },
      },
    },
    '/health': {
      'get': {
        'summary': 'Health check',
        'operationId': 'healthCheck',
        'responses': {
          '200': {
            'description': 'Service health status',
            'content': {
              'application/json': {
                'schema': {
                  'type': 'object',
                  'properties': {
                    'status': {'type': 'string', 'example': 'ok'},
                  },
                },
              },
            },
          },
        },
      },
    },
  },
  'components': {
    'schemas': {
      'LoanLog': {
        'type': 'object',
        'properties': {
          'timestamp': {'type': 'string'},
          'level': {'type': 'string'},
          'service': {
            'type': 'object',
            'properties': {
              'name': {'type': 'string'},
              'version': {'type': 'string'},
              'environment': {'type': 'string'},
            },
          },
          'message': {'type': 'string'},
          'tags': {
            'type': 'array',
            'items': {'type': 'string'},
          },
        },
      },
    },
  },
};

class OpenApiRoute extends Route {
  OpenApiRoute() : super(path: '/');

  @override
  FutureOr<Result> handleCall(Session session, Request request) {
    return Response.ok(
      body: Body.fromString(jsonEncode(_openApiSpec), mimeType: MimeType.json),
    );
  }
}

// --- Swagger UI route ---
final _swaggerHtml = '''
<!DOCTYPE html>
<html>
<head>
  <title>Dart Loan Service - Swagger UI</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui.css" />
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
  <script>
    SwaggerUIBundle({ url: '/openapi.json', dom_id: '#swagger-ui' });
  </script>
</body>
</html>
''';

class SwaggerRoute extends Route {
  SwaggerRoute() : super(path: '/');

  @override
  FutureOr<Result> handleCall(Session session, Request request) {
    return Response.ok(
      body: Body.fromString(_swaggerHtml, mimeType: MimeType.html),
    );
  }
}

void main(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Register web routes
  pod.webServer.addRoute(LoanRoute(), '/');
  pod.webServer.addRoute(HealthRoute(), '/health');
  pod.webServer.addRoute(OpenApiRoute(), '/openapi.json');
  pod.webServer.addRoute(SwaggerRoute(), '/swagger');

  await pod.start();
}
