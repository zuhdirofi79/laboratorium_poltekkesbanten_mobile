<?php
/**
 * Get Praktikum Schedule Endpoint (User)
 * 
 * Purpose: Get list of praktikum schedules for user
 * 
 * Location: api/user/praktikum/schedule.php
 * 
 * Endpoint: GET /api/user/praktikum/schedule.php
 * 
 * Headers:
 * Authorization: Bearer {token}
 * 
 * Response:
 * {
 *   "success": true,
 *   "data": [
 *     {
 *       "id": 16,
 *       "tgl": "2024-01-08",
 *       "kelas": "Biokimia",
 *       "ruang": "Lab Kimia",
 *       "hari": "Senin",
 *       "waktu_mulai": "08:50:00",
 *       "waktu_selesai": "11:40:00",
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
    
    // Get schedules (filter by jurusan if user has jurusan)
    $sql = "SELECT 
                id, semester_id, tgl, jurusan, penanggung_jawab,
                kelas, tingkat, ruang, hari, waktu_mulai,
                waktu_selesai, tujuan, created_at, updated_at
            FROM jadwal_praktikum
            WHERE 1=1";
    
    $params = [];
    
    if (!empty($user['jurusan'])) {
        $sql .= " AND LOWER(jurusan) = :jurusan";
        $params['jurusan'] = strtolower($user['jurusan']);
    }
    
    $sql .= " ORDER BY tgl DESC, waktu_mulai ASC";
    
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $schedules = $stmt->fetchAll();
    
    // Format response
    $formattedSchedules = array_map(function($schedule) {
        return [
            'id' => (int)$schedule['id'],
            'semester_id' => (int)$schedule['semester_id'],
            'tgl' => $schedule['tgl'],
            'jurusan' => $schedule['jurusan'],
            'penanggung_jawab' => $schedule['penanggung_jawab'],
            'kelas' => $schedule['kelas'],
            'tingkat' => $schedule['tingkat'],
            'ruang' => $schedule['ruang'],
            'hari' => $schedule['hari'],
            'waktu_mulai' => $schedule['waktu_mulai'],
            'waktu_selesai' => $schedule['waktu_selesai'],
            'tujuan' => $schedule['tujuan'],
            'created_at' => $schedule['created_at'],
            'updated_at' => $schedule['updated_at']
        ];
    }, $schedules);
    
    ResponseHelper::success($formattedSchedules, 'Schedule retrieved successfully');
    
} catch (Exception $e) {
    error_log("Get schedule error: " . $e->getMessage());
    ResponseHelper::error('Terjadi kesalahan saat mengambil jadwal praktikum', 500);
}
