<?php
/**
 * Get User Equipment Requests Endpoint (User)
 * 
 * Purpose: Get list of user's own equipment requests
 * 
 * Location: api/user/equipment/requests.php
 * 
 * Endpoint: GET /api/user/equipment/requests.php
 * 
 * Headers:
 * Authorization: Bearer {token}
 * 
 * Response:
 * {
 *   "success": true,
 *   "data": [
 *     {
 *       "id": 20,
 *       "jenis": "Peralatan Laboratorium",
 *       "status": "Selesai",
 *       "tgl_pinjaman": "2024-02-11",
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

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/response.php';
require_once __DIR__ . '/../../middleware/auth.php';

try {
    // Validate token and get user
    $user = AuthMiddleware::validateToken();
    
    // Get database connection
    $db = Database::getInstance()->getConnection();
    
    // Get user's requests
    $stmt = $db->prepare("
        SELECT 
            id, jurusan, user_id, jenis, ruangan,
            penanggung_jawab, tingkat, waktu_mulai,
            waktu_selesai, tujuan, tgl_pinjaman,
            tgl_pengembalian, status, created_at
        FROM peminjaman
        WHERE user_id = :user_id
        ORDER BY created_at DESC
    ");
    
    $stmt->execute(['user_id' => $user['id']]);
    $requests = $stmt->fetchAll();
    
    // Format response
    $formattedRequests = array_map(function($request) {
        return [
            'id' => (int)$request['id'],
            'jurusan' => $request['jurusan'],
            'jenis' => $request['jenis'],
            'ruangan' => $request['ruangan'],
            'penanggung_jawab' => $request['penanggung_jawab'],
            'tingkat' => $request['tingkat'],
            'waktu_mulai' => $request['waktu_mulai'],
            'waktu_selesai' => $request['waktu_selesai'],
            'tujuan' => $request['tujuan'],
            'tgl_pinjaman' => $request['tgl_pinjaman'],
            'tgl_pengembalian' => $request['tgl_pengembalian'],
            'status' => $request['status'],
            'created_at' => $request['created_at']
        ];
    }, $requests);
    
    ResponseHelper::success($formattedRequests, 'Equipment requests retrieved successfully');
    
} catch (Exception $e) {
    error_log("Get user equipment requests error: " . $e->getMessage());
    ResponseHelper::error('Terjadi kesalahan saat mengambil data request peralatan', 500);
}
