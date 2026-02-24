<?php
return [
    'db' => [
        'host' => getenv('DB_HOST') ?: '10.0.0.7',
        'port' => getenv('DB_PORT') ?: '3306',
        'dbname' => getenv('DB_NAME') ?: 'oa_codex',
        'user' => getenv('DB_USER') ?: 'root',
        'pass' => getenv('DB_PASS') ?: '?(kFMNWb)5Fv+8-_uYwG',
        'charset' => 'utf8mb4',
    ],
    'app' => [
        'name' => 'Training OA',
        'jwt_secret' => getenv('JWT_SECRET') ?: 'change-this-secret-in-production',
        'token_ttl' => 3600 * 12,
    ],
];
