<?php
/**
 * Login Endpoint
 * 
 * Purpose: Authenticate user and return API token
 * Does NOT use PHP sessions - returns token for stateless authentication
 * 
 * Location: api/auth/login.php
 * 
 * Endpoint: POST /api/auth/login.php
 * 
 * Request Body (JSON):
 * {
 *   "username": "99999",
 *   "password": "password123"
 * }
 * 
 * Response:
 * {
 *   "success": true,
 *   "data": {
 *     "token": "random_token_string",
 *     "user": {...}
 *   },
 *   "message": "Login berhasil"
 * }
 */

// Set CORS headers (adjust as needed)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Only allow POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/response.php';

try {
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        ResponseHelper::error('Invalid JSON input', 400);
    }
    
    $username = trim($input['username'] ?? '');
    $password = $input['password'] ?? '';
    
    // Validate input
    if (empty($username) || empty($password)) {
        ResponseHelper::error('Username and password are required', 400);
    }
    
    // Get database connection
    $db = Database::getInstance()->getConnection();
    
    // Find user by username
    $stmt = $db->prepare("
        SELECT 
            id, name, email, username, foto_profile, 
            jenis_kelamin, no_hp, jurusan, role, password
        FROM users 
        WHERE username = :username
        LIMIT 1
    ");
    
    $stmt->execute(['username' => $username]);
    $user = $stmt->fetch();
    
    // Verify user exists and password is correct
    if (!$user) {
        ResponseHelper::error('Username atau password salah', 401);
    }
    
    // Verify password (bcrypt hash from Laravel)
    if (!password_verify($password, $user['password'])) {
        ResponseHelper::error('Username atau password salah', 401);
    }
    
    // Generate secure token
    $token = bin2hex(random_bytes(32)); // 64 character hex string
    $tokenHash = hash('sha256', $token);
    
    // Token expires in 30 days
    $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));
    
    // Store token in database
    $stmt = $db->prepare("
        INSERT INTO api_tokens (user_id, token, token_hash, expires_at)
        VALUES (:user_id, :token, :token_hash, :expires_at)
    ");
    
    $stmt->execute([
        'user_id' => $user['id'],
        'token' => $token, // Store plain token for reference (optional, can be removed)
        'token_hash' => $tokenHash,
        'expires_at' => $expiresAt
    ]);
    
    // Remove sensitive data from response
    unset($user['password']);
    
    // Return success response
    ResponseHelper::success([
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
    ], 'Login berhasil');
    
} catch (Exception $e) {
    error_log("Login error: " . $e->getMessage());
    ResponseHelper::error('Terjadi kesalahan saat login', 500);
}
