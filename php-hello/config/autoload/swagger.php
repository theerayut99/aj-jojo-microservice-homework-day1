<?php

declare(strict_types=1);

return [
    'enable' => true,
    'port' => 9500,
    'json_dir' => BASE_PATH . '/storage/swagger',
    'html' => <<<'HTML'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="SwaggerUI" />
    <title>SwaggerUI</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui.css" />
  </head>
  <body>
  <div id="swagger-ui"></div>
  <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-bundle.js" crossorigin></script>
  <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-standalone-preset.js" crossorigin></script>
  <script>
    window.onload = () => {
      window.ui = SwaggerUIBundle({
        url: "/http.json",
        dom_id: '#swagger-ui',
        presets: [
          SwaggerUIBundle.presets.apis,
          SwaggerUIStandalonePreset
        ],
        layout: "StandaloneLayout",
      });
    };
  </script>
  </body>
</html>
HTML,
    'url' => '/swagger',
    'auto_generate' => true,
    'scan' => [
        'paths' => null,
    ],
    'processors' => [],
    'server' => [
        'http' => [
            'servers' => [
                [
                    'url' => 'http://127.0.0.1:9501',
                    'description' => 'Loan Service API',
                ],
            ],
            'info' => [
                'title' => 'PHP Hello - Loan Service API',
                'description' => 'Loan service microservice built with Hyperf',
                'version' => '1.0.0',
            ],
        ],
    ],
];
