<?php
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../config/bootstrap.php';
require_once __DIR__ . '/../middleware/cors.php';
require_once __DIR__ . '/../middleware/rate_limit.php';
require_once __DIR__ . '/../middleware/request_validator.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/audit_logger.php';

CorsMiddleware::handle();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed. Only POST method is accepted.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $input = RequestValidator::validateJsonInput();
    RequestValidator::validateRequired($input, ['username', 'password']);
    
    $username = trim($input['username']);
    $password = $input['password'];
    
    if (empty($username) || empty($password)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Username and password are required'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    RateLimiter::checkLoginLimit($username);
    
    $db = Database::getInstance()->getConnection();
    
    $stmt = $db->prepare("
        SELECT 
            id, name, email, username, foto_profile, 
            jenis_kelamin, no_hp, jurusan, role, password
        FROM users 
        WHERE username = :username
        LIMIT 1
    ");
    
    $stmt->execute(['username' => $username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    require_once __DIR__ . '/../config/security_helpers.php';
    $clientIp = SecurityHelpers::getClientIp();
    $userAgent = SecurityHelpers::getUserAgent();
    
    if (!$user || empty($user['password'])) {
        RateLimiter::recordFailedAttempt($username);
        AuditLogger::loginFail($username, $clientIp, $userAgent, 'user_not_found');
        
        require_once __DIR__ . '/../config/alert_engine.php';
        AlertEngine::check('AUTH_FAILURE', [
            'ip_address' => $clientIp,
            'endpoint' => '/auth/login.php',
            'status' => 'FAIL'
        ]);
        
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Username atau password salah'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    if (!password_verify($password, $user['password'])) {
        RateLimiter::recordFailedAttempt($username);
        AuditLogger::invalidCredentials($username, $clientIp, $userAgent);
        
        require_once __DIR__ . '/../config/alert_engine.php';
        AlertEngine::check('AUTH_FAILURE', [
            'ip_address' => $clientIp,
            'endpoint' => '/auth/login.php',
            'status' => 'FAIL'
        ]);
        
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Username atau password salah'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    RateLimiter::resetLoginAttempts($username);
    
    $token = bin2hex(random_bytes(32));
    $tokenHash = hash('sha256', $token);
    $expiresAt = date('Y-m-d H:i:s', strtotime('+7 days'));
    $currentTime = date('Y-m-d H:i:s');
    
    $stmt = $db->prepare("
        INSERT INTO api_tokens (user_id, token_hash, last_ip, last_user_agent, last_used_at, expires_at)
        VALUES (:user_id, :token_hash, :last_ip, :last_user_agent, :last_used_at, :expires_at)
    ");
    
    $stmt->execute([
        'user_id' => $user['id'],
        'token_hash' => $tokenHash,
        'last_ip' => $clientIp,
        'last_user_agent' => $userAgent,
        'last_used_at' => $currentTime,
        'expires_at' => $expiresAt
    ]);
    
    AuditLogger::tokenCreated($user['id'], $tokenHash);
    AuditLogger::loginSuccess($user['id'], $user['username'], $clientIp, $userAgent);
    
    unset($user['password']);
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Login berhasil',
        'data' => [
            'token' => $token,
            'user' => [
                'id' => (int)$user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'username' => $user['username'],
                'foto_profile' => $user['foto_profile'],
                'jenis_kelamin' => $user['jenis_kelamin'],
                'no_hp' => $user['no_hp'],
                'jurusan' => $user['jurusan'],
                'role' => $user['role']
            ]
        ]
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    
} catch (PDOException $e) {
    AuditLogger::dbError($e->getMessage(), 'login_query');
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Terjadi kesalahan saat login'
    ], JSON_UNESCAPED_UNICODE);
    exit;
} catch (Exception $e) {
    AuditLogger::exception($e, ['action' => 'login']);
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Terjadi kesalahan saat login'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
