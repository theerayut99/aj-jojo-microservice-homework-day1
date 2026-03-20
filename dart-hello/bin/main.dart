import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import 'package:dart_hello_server/src/generated/protocol.dart';
import 'package:dart_hello_server/src/generated/endpoints.dart';

// =============================================================================
// Factor 3: Store config in environment variables
// =============================================================================
final _env = Platform.environment;
final _serviceName = _env['SERVICE_NAME'] ?? 'loan-service';
final _serviceVersion = _env['SERVICE_VERSION'] ?? '1.2.0';
final _serviceEnv = _env['SERVICE_ENV'] ?? 'production';
final _logLevel = _env['LOG_LEVEL'] ?? 'info';

// =============================================================================
// Factor 11: Logs — treat logs as event streams (structured JSON to stdout)
// =============================================================================
void _log(String level, String message, [Map<String, dynamic>? extra]) {
  final entry = {
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'level': level.toUpperCase(),
    'service': _serviceName,
    'version': _serviceVersion,
    'message': message,
    if (extra != null) ...extra,
  };
  stdout.writeln(jsonEncode(entry));
}

// =============================================================================
// Factor 9: Disposability — fast startup, graceful shutdown via SIGTERM/SIGINT
// =============================================================================
Future<void> _handleShutdown(Serverpod pod) async {
  _log('INFO', 'Shutting down gracefully...');
  await pod.shutdown();
  _log('INFO', 'Server stopped');
  exit(0);
}

// =============================================================================
// Routes
// =============================================================================

// --- Loan service route ---
class LoanRoute extends Route {
  LoanRoute() : super(path: '/');

  @override
  FutureOr<Result> handleCall(Session session, Request request) {
    // Factor 3: Config — service metadata from environment
    final body = {
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'level': 'INFO',
      'service': {
        'name': _serviceName,
        'version': _serviceVersion,
        'environment': _serviceEnv,
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
        jsonEncode({
          'status': 'ok',
          'service': _serviceName,
          'version': _serviceVersion,
        }),
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

// =============================================================================
// Main — Factor 7: Port binding (self-contained HTTP server)
// =============================================================================
void main(List<String> args) async {
  // Factor 11: Log startup
  _log('INFO', 'Starting server', {
    'environment': _serviceEnv,
    'log_level': _logLevel,
  });

  // Factor 2: Dependencies — declared in pubspec.yaml, isolated via dart pub get
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Factor 9: Disposability — graceful shutdown on SIGTERM / SIGINT
  ProcessSignal.sigterm.watch().listen((_) => _handleShutdown(pod));
  ProcessSignal.sigint.watch().listen((_) => _handleShutdown(pod));

  // Factor 7: Port binding — register web routes on self-contained HTTP server
  pod.webServer.addRoute(LoanRoute(), '/');
  pod.webServer.addRoute(HealthRoute(), '/health');
  pod.webServer.addRoute(OpenApiRoute(), '/openapi.json');
  pod.webServer.addRoute(SwaggerRoute(), '/swagger');

  await pod.start();

  // Factor 11: Log ready
  _log('INFO', 'Server started', {
    'ports': {'api': 8080, 'insights': 8081, 'web': 8082},
  });
}
