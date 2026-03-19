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
$logLevel = match (strtolower(getenv('LOG_LEVEL') ?: 'info')) {
    'debug' => Monolog\Logger::DEBUG,
    'warning', 'warn' => Monolog\Logger::WARNING,
    'error' => Monolog\Logger::ERROR,
    default => Monolog\Logger::INFO,
};

return [
    'default' => [
        'handler' => [
            'class' => Monolog\Handler\StreamHandler::class,
            'constructor' => [
                'stream' => 'php://stdout',
                'level' => $logLevel,
            ],
        ],
        'formatter' => [
            'class' => Monolog\Formatter\JsonFormatter::class,
        ],
    ],
];
