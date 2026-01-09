<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed. Only POST method is accepted.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../config/database.php';

try {
    $rawInput = file_get_contents('php://input');
    
    if (empty($rawInput)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Request body is required'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $input = json_decode($rawInput, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid JSON format: ' . json_last_error_msg()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    if (!is_array($input)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid request format. Expected JSON object.'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $username = isset($input['username']) ? trim($input['username']) : '';
    $password = isset($input['password']) ? $input['password'] : '';
    
    if (empty($username)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Username is required'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    if (empty($password)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Password is required'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
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
    
    if (!$user) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Username atau password salah'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    if (empty($user['password'])) {
        error_log("Login attempt for user ID {$user['id']} with empty password hash");
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Terjadi kesalahan saat login'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    if (!password_verify($password, $user['password'])) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Username atau password salah'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $token = bin2hex(random_bytes(32));
    $tokenHash = hash('sha256', $token);
    $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));
    
    $stmt = $db->prepare("
        INSERT INTO api_tokens (user_id, token, token_hash, expires_at)
        VALUES (:user_id, :token, :token_hash, :expires_at)
    ");
    
    $stmt->execute([
        'user_id' => $user['id'],
        'token' => $token,
        'token_hash' => $tokenHash,
        'expires_at' => $expiresAt
    ]);
    
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
    error_log("Login PDO error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Terjadi kesalahan saat login'
    ], JSON_UNESCAPED_UNICODE);
    exit;
} catch (Exception $e) {
    error_log("Login error: " . $e->getMessage() . " | File: " . $e->getFile() . " | Line: " . $e->getLine());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Terjadi kesalahan saat login'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
