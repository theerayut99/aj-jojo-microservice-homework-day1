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

class IndexController extends AbstractController
{
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
