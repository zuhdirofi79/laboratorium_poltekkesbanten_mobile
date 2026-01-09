<?php
/**
 * Change Password Endpoint
 * 
 * Purpose: Change user password
 * 
 * Location: api/auth/change-password.php
 * 
 * Endpoint: POST /api/auth/change-password.php
 * 
 * Headers:
 * Authorization: Bearer {token}
 * 
 * Request Body (JSON):
 * {
 *   "old_password": "oldpass123",
 *   "new_password": "newpass123"
 * }
 * 
 * Response:
 * {
 *   "success": true,
 *   "message": "Password berhasil diubah"
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
    
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        ResponseHelper::error('Invalid JSON input', 400);
    }
    
    $oldPassword = $input['old_password'] ?? '';
    $newPassword = $input['new_password'] ?? '';
    
    // Validate input
    if (empty($oldPassword) || empty($newPassword)) {
        ResponseHelper::error('Old password and new password are required', 400);
    }
    
    // Validate new password length (minimum 6 characters)
    if (strlen($newPassword) < 6) {
        ResponseHelper::error('New password must be at least 6 characters', 400);
    }
    
    // Get database connection
    $db = Database::getInstance()->getConnection();
    
    // Get current user password
    $stmt = $db->prepare("SELECT password FROM users WHERE id = :user_id LIMIT 1");
    $stmt->execute(['user_id' => $user['id']]);
    $userData = $stmt->fetch();
    
    if (!$userData) {
        ResponseHelper::error('User not found', 404);
    }
    
    // Verify old password
    if (!password_verify($oldPassword, $userData['password'])) {
        ResponseHelper::error('Password lama salah', 400);
    }
    
    // Hash new password (bcrypt)
    $newPasswordHash = password_hash($newPassword, PASSWORD_BCRYPT);
    
    // Update password
    $stmt = $db->prepare("UPDATE users SET password = :password WHERE id = :user_id");
    $stmt->execute([
        'password' => $newPasswordHash,
        'user_id' => $user['id']
    ]);
    
    ResponseHelper::success(null, 'Password berhasil diubah');
    
} catch (Exception $e) {
    error_log("Change password error: " . $e->getMessage());
    ResponseHelper::error('Terjadi kesalahan saat mengubah password', 500);
}
