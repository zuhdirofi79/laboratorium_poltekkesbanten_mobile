<?php
require_once __DIR__ . '/security.php';
require_once __DIR__ . '/audit_logger.php';
require_once __DIR__ . '/../middleware/cors.php';
require_once __DIR__ . '/../middleware/api_rate_limit.php';

AuditLogger::initRequestId();

CorsMiddleware::handle();

if ($_SERVER['REQUEST_METHOD'] !== 'OPTIONS') {
    SecurityConfig::validatePayloadSize();
    ApiRateLimit::check();
}
