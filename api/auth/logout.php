<?php
/**
 * Logout Endpoint
 * 
 * Purpose: Invalidate API token
 * 
 * Location: api/auth/logout.php
 * 
 * Endpoint: POST /api/auth/logout.php
 * 
 * Headers:
 * Authorization: Bearer {token}
 * 
 * Response:
 * {
 *   "success": true,
 *   "message": "Logout berhasil"
 * }
 */

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/response.php';
require_once __DIR__ . '/../middleware/auth.php';

try {
    // Validate token and get user
    $user = AuthMiddleware::validateToken();
    
    // Get token from header
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches);
    $token = $matches[1] ?? '';
    $tokenHash = hash('sha256', $token);
    
    // Delete token from database
    $db = Database::getInstance()->getConnection();
    $stmt = $db->prepare("DELETE FROM api_tokens WHERE token_hash = :token_hash");
    $stmt->execute(['token_hash' => $tokenHash]);
    
    ResponseHelper::success(null, 'Logout berhasil');
    
} catch (Exception $e) {
    error_log("Logout error: " . $e->getMessage());
    ResponseHelper::error('Terjadi kesalahan saat logout', 500);
}
