import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// --- Configuration from environment ---
final String host = Platform.environment['HOST'] ?? '0.0.0.0';
final int port = int.parse(Platform.environment['PORT'] ?? '8080');
final String logLevel = Platform.environment['LOG_LEVEL'] ?? 'info';

// --- Structured JSON logger ---
void logJson(String level, String message, [Map<String, dynamic>? extra]) {
  final entry = {
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'level': level.toUpperCase(),
    'message': message,
    if (extra != null) ...extra,
  };
  stdout.writeln(jsonEncode(entry));
}

// --- JSON logging middleware ---
Middleware jsonLogMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final sw = Stopwatch()..start();
      final response = await innerHandler(request);
      sw.stop();
      if (logLevel != 'silent') {
        logJson('info', 'HTTP request', {
          'method': request.method,
          'path': request.requestedUri.path,
          'status': response.statusCode,
          'duration_ms': sw.elapsedMilliseconds,
        });
      }
      return response;
    };
  };
}

// --- OpenAPI spec ---
final _openApiSpec = {
  'openapi': '3.0.3',
  'info': {
    'title': 'Dart Loan Service',
    'description': 'Loan service API built with Dart Shelf',
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

// --- Swagger UI HTML ---
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

// --- Routes ---
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/health', _healthHandler)
  ..get('/openapi.json', _openapiHandler)
  ..get('/swagger', _swaggerHandler);

Response _rootHandler(Request req) {
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
    jsonEncode(body),
    headers: {'Content-Type': 'application/json'},
  );
}

Response _healthHandler(Request req) {
  return Response.ok(
    jsonEncode({'status': 'ok'}),
    headers: {'Content-Type': 'application/json'},
  );
}

Response _openapiHandler(Request req) {
  return Response.ok(
    jsonEncode(_openApiSpec),
    headers: {'Content-Type': 'application/json'},
  );
}

Response _swaggerHandler(Request req) {
  return Response.ok(
    _swaggerHtml,
    headers: {'Content-Type': 'text/html'},
  );
}

// --- Main with graceful shutdown ---
void main(List<String> args) async {
  final ip = host == '0.0.0.0' ? InternetAddress.anyIPv4 : InternetAddress(host);

  final handler =
      Pipeline().addMiddleware(jsonLogMiddleware()).addHandler(_router.call);

  final server = await serve(handler, ip, port);
  logJson('info', 'Server started', {
    'host': host,
    'port': server.port,
    'log_level': logLevel,
  });

  // Graceful shutdown on SIGTERM / SIGINT
  void shutdown(String signal) {
    logJson('info', 'Shutting down', {'signal': signal});
    server.close().then((_) {
      logJson('info', 'Server stopped');
      exit(0);
    });
  }

  ProcessSignal.sigterm.watch().listen((_) => shutdown('SIGTERM'));
  ProcessSignal.sigint.watch().listen((_) => shutdown('SIGINT'));
}
