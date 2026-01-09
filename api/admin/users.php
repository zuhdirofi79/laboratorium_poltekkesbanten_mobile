<?php
/**
 * Get Users List Endpoint (Admin)
 * 
 * Purpose: Get list of all users with optional search
 * 
 * Location: api/admin/users.php
 * 
 * Endpoint: GET /api/admin/users.php?search=keyword
 * 
 * Headers:
 * Authorization: Bearer {token}
 * 
 * Query Parameters:
 * - search (optional): Search term for name, username, or email
 * 
 * Response:
 * {
 *   "success": true,
 *   "data": [
 *     {
 *       "id": 4,
 *       "name": "Admin Kampus",
 *       "email": "admin@example.com",
 *       "username": "99999",
 *       "role": "admin",
 *       ...
 *     }
 *   ]
 * }
 */

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/response.php';
require_once __DIR__ . '/../middleware/auth.php';

try {
    // Require admin role
    $user = AuthMiddleware::requireRole(['admin']);
    
    // Get search parameter
    $search = $_GET['search'] ?? '';
    
    // Get database connection
    $db = Database::getInstance()->getConnection();
    
    // Build query
    $sql = "SELECT 
                id, name, email, username, foto_profile, 
                jenis_kelamin, no_hp, jurusan, role, 
                email_verified_at, created_at, updated_at
            FROM users
            WHERE 1=1";
    
    $params = [];
    
    if (!empty($search)) {
        $sql .= " AND (name LIKE :search OR username LIKE :search OR email LIKE :search)";
        $params['search'] = '%' . $search . '%';
    }
    
    $sql .= " ORDER BY created_at DESC";
    
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $users = $stmt->fetchAll();
    
    // Format response
    $formattedUsers = array_map(function($user) {
        return [
            'id' => (int)$user['id'],
            'name' => $user['name'],
            'email' => $user['email'],
            'username' => $user['username'],
            'foto_profile' => $user['foto_profile'],
            'jenis_kelamin' => $user['jenis_kelamin'],
            'no_hp' => $user['no_hp'],
            'jurusan' => $user['jurusan'],
            'role' => $user['role'],
            'email_verified_at' => $user['email_verified_at'],
            'created_at' => $user['created_at'],
            'updated_at' => $user['updated_at']
        ];
    }, $users);
    
    ResponseHelper::success($formattedUsers, 'Users retrieved successfully');
    
} catch (Exception $e) {
    error_log("Get users error: " . $e->getMessage());
    ResponseHelper::error('Terjadi kesalahan saat mengambil data users', 500);
}
