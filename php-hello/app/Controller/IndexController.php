<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://hyperf.wiki
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf/hyperf/blob/master/LICENSE
 */

namespace App\Controller;

use Hyperf\Swagger\Annotation as OA;
use Hyperf\HttpServer\Contract\RequestInterface;
use Hyperf\Di\Annotation\Inject;

#[OA\HyperfServer('http')]
class IndexController extends AbstractController
{
    #[Inject]
    protected RequestInterface $request;
    #[OA\Get(path: '/health', summary: 'Health check', tags: ['Health'])]
    #[OA\Response(response: 200, description: 'Service is healthy', content: new OA\JsonContent(
        properties: [
            new OA\Property(property: 'status', type: 'string', example: 'ok'),
        ]
    ))]
    public function health()
    {
        return ['status' => 'ok'];
    }

    #[OA\Get(path: '/', summary: 'Get loan service log entry', tags: ['Loan Service'])]
    #[OA\Response(response: 200, description: 'Loan application log entry', content: new OA\JsonContent(
        properties: [
            new OA\Property(property: 'timestamp', type: 'string', example: '2026-03-18T14:10:25.123Z'),
            new OA\Property(property: 'level', type: 'string', example: 'INFO'),
            new OA\Property(property: 'message', type: 'string', example: 'Loan application processed successfully'),
            new OA\Property(property: 'service', type: 'object', properties: [
                new OA\Property(property: 'name', type: 'string', example: 'loan-service'),
                new OA\Property(property: 'version', type: 'string', example: '1.2.0'),
                new OA\Property(property: 'environment', type: 'string', example: 'production'),
            ]),
            new OA\Property(property: 'trace', type: 'object', properties: [
                new OA\Property(property: 'trace_id', type: 'string', example: 'abc123xyz'),
                new OA\Property(property: 'span_id', type: 'string', example: 'span-001'),
                new OA\Property(property: 'parent_span_id', type: 'string', nullable: true),
            ]),
            new OA\Property(property: 'request', type: 'object'),
            new OA\Property(property: 'response', type: 'object'),
            new OA\Property(property: 'user', type: 'object'),
            new OA\Property(property: 'error', type: 'string', nullable: true),
            new OA\Property(property: 'tags', type: 'array', items: new OA\Items(type: 'string')),
            new OA\Property(property: 'extra', type: 'object'),
        ]
    ))]
    public function index()
    {
        return [
            'timestamp' => '2026-03-18T14:10:25.123Z',
            'level' => 'INFO',
            'service' => [
                'name' => 'loan-service',
                'version' => '1.2.0',
                'environment' => 'production',
            ],
            'trace' => [
                'trace_id' => 'abc123xyz',
                'span_id' => 'span-001',
                'parent_span_id' => null,
            ],
            'request' => [
                'method' => 'POST',
                'path' => '/api/v1/loan/apply',
                'query' => new \stdClass(),
                'headers' => [
                    'x-request-id' => 'abc123xyz',
                ],
                'body' => [
                    'customer_id' => 1001,
                ],
                'ip' => '10.0.0.1',
                'user_agent' => 'PostmanRuntime/7.32',
            ],
            'response' => [
                'status_code' => 200,
                'body' => [
                    'result' => 'success',
                ],
                'duration_ms' => 120,
            ],
            'user' => [
                'id' => 'u-1001',
                'role' => 'customer',
            ],
            'error' => null,
            'message' => 'Loan application processed successfully',
            'tags' => ['loan', 'apply'],
            'extra' => new \stdClass(),
        ];
    }
    }

    #[OA\Post(path: '/', summary: 'Receive loan service webhook', tags: ['Loan Service'])]
    #[OA\RequestBody(description: 'Webhook Event Payload', required: true, content: new OA\JsonContent())]
    #[OA\Response(response: 200, description: 'Webhook event processed successfully', content: new OA\JsonContent(
        properties: [
            new OA\Property(property: 'timestamp', type: 'string', example: '2026-03-18T14:10:25.123Z'),
            new OA\Property(property: 'level', type: 'string', example: 'INFO'),
            new OA\Property(property: 'message', type: 'string', example: 'Webhook event processed successfully'),
            new OA\Property(property: 'service', type: 'object'),
            new OA\Property(property: 'trace', type: 'object'),
            new OA\Property(property: 'request', type: 'object'),
            new OA\Property(property: 'response', type: 'object'),
            new OA\Property(property: 'user', type: 'object'),
            new OA\Property(property: 'error', type: 'string', nullable: true),
            new OA\Property(property: 'tags', type: 'array', items: new OA\Items(type: 'string')),
            new OA\Property(property: 'extra', type: 'object'),
        ]
    ))]
    public function postWebhook()
    {
        $payload = $this->request->all();

        return [
            'timestamp' => '2026-03-18T14:10:25.123Z',
            'level' => 'INFO',
            'service' => [
                'name' => 'loan-service',
                'version' => '1.2.0',
                'environment' => 'production',
            ],
            'trace' => [
                'trace_id' => 'abc123xyz',
                'span_id' => 'span-001',
                'parent_span_id' => null,
            ],
            'request' => [
                'method' => 'POST',
                'path' => '/api/v1/loan/apply',
                'query' => new \stdClass(),
                'headers' => [
                    'x-request-id' => 'abc123xyz',
                ],
                'body' => $payload ?: new \stdClass(),
                'ip' => '10.0.0.1',
                'user_agent' => 'PostmanRuntime/7.32',
            ],
            'response' => [
                'status_code' => 200,
                'body' => [
                    'result' => 'success',
                ],
                'duration_ms' => 120,
            ],
            'user' => [
                'id' => 'u-1001',
                'role' => 'customer',
            ],
            'error' => null,
            'message' => 'Webhook event processed successfully',
            'tags' => ['loan', 'webhook', 'apply'],
            'extra' => new \stdClass(),
        ];
    }
}
