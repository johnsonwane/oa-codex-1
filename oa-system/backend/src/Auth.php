<?php

class Auth
{
    public static function issueToken(array $user, string $secret, int $ttl): string
    {
        $payload = [
            'uid' => (int)$user['id'],
            'username' => $user['username'],
            'company_id' => (int)$user['company_id'],
            'department_id' => (int)$user['department_id'],
            'level_id' => (int)$user['level_id'],
            'exp' => time() + $ttl,
        ];

        $body = base64_encode(json_encode($payload, JSON_UNESCAPED_UNICODE));
        $sig = hash_hmac('sha256', $body, $secret);
        return $body . '.' . $sig;
    }

    public static function verifyToken(?string $token, string $secret): ?array
    {
        if (!$token || strpos($token, '.') === false) {
            return null;
        }

        [$body, $sig] = explode('.', $token, 2);
        $expected = hash_hmac('sha256', $body, $secret);
        if (!hash_equals($expected, $sig)) {
            return null;
        }

        $payload = json_decode(base64_decode($body), true);
        if (!is_array($payload) || ($payload['exp'] ?? 0) < time()) {
            return null;
        }

        return $payload;
    }
}
