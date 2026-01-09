<?php
/**
 * Create Equipment Request Endpoint (User)
 * 
 * Purpose: Create new equipment request
 * 
 * Location: api/user/equipment/request/create.php
 * 
 * Endpoint: POST /api/user/equipment/request/create.php
 * 
 * Headers:
 * Authorization: Bearer {token}
 * 
 * Request Body (JSON):
 * {
 *   "jenis": "Peralatan Laboratorium",
 *   "ruangan": "Lab Kimia Dasar dan Terapan",
 *   "penanggung_jawab": "Dosen Name",
 *   "tingkat": "1A",
 *   "waktu_mulai": "08:00:00",
 *   "waktu_selesai": "10:00:00",
 *   "tujuan": "Praktikum",
 *   "tgl_pinjaman": "2024-02-15",
 *   "items": [
 *     {
 *       "barang_id": 23,
 *       "barang_type": "inventaris",
 *       "stok_pinjam": 1
 *     }
 *   ]
 * }
 * 
 * Response:
 * {
 *   "success": true,
 *   "data": {
 *     "id": 25,
 *     "status": "Menunggu Konfirmasi",
 *     ...
 *   },
 *   "message": "Request berhasil dibuat"
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

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/response.php';
require_once __DIR__ . '/../../middleware/auth.php';

try {
    // Validate token and get user
    $user = AuthMiddleware::validateToken();
    
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        ResponseHelper::error('Invalid JSON input', 400);
    }
    
    // Validate required fields
    $required = ['jenis', 'ruangan', 'tingkat', 'waktu_mulai', 'waktu_selesai', 'tujuan', 'tgl_pinjaman', 'items'];
    foreach ($required as $field) {
        if (empty($input[$field])) {
            ResponseHelper::error("Field $field is required", 400);
        }
    }
    
    if (!is_array($input['items']) || empty($input['items'])) {
        ResponseHelper::error('Items array is required and must not be empty', 400);
    }
    
    // Get database connection
    $db = Database::getInstance()->getConnection();
    
    // Begin transaction
    $db->beginTransaction();
    
    try {
        // Insert peminjaman
        $stmt = $db->prepare("
            INSERT INTO peminjaman (
                jurusan, user_id, jenis, ruangan, penanggung_jawab,
                tingkat, waktu_mulai, waktu_selesai, tujuan,
                tgl_pinjaman, status, created_at
            ) VALUES (
                :jurusan, :user_id, :jenis, :ruangan, :penanggung_jawab,
                :tingkat, :waktu_mulai, :waktu_selesai, :tujuan,
                :tgl_pinjaman, 'Menunggu Konfirmasi', NOW()
            )
        ");
        
        $stmt->execute([
            'jurusan' => $user['jurusan'] ?? '',
            'user_id' => $user['id'],
            'jenis' => $input['jenis'],
            'ruangan' => $input['ruangan'],
            'penanggung_jawab' => $input['penanggung_jawab'] ?? null,
            'tingkat' => $input['tingkat'],
            'waktu_mulai' => $input['waktu_mulai'],
            'waktu_selesai' => $input['waktu_selesai'],
            'tujuan' => $input['tujuan'],
            'tgl_pinjaman' => $input['tgl_pinjaman']
        ]);
        
        $peminjamanId = $db->lastInsertId();
        
        // Insert peminjaman_detail for each item
        foreach ($input['items'] as $item) {
            if (empty($item['barang_id']) || empty($item['stok_pinjam'])) {
                continue;
            }
            
            $stmt = $db->prepare("
                INSERT INTO peminjaman_detail (
                    peminjaman_id, barang_id, stok_pinjam, status
                ) VALUES (
                    :peminjaman_id, :barang_id, :stok_pinjam, 'Menunggu Konfirmasi'
                )
            ");
            
            $stmt->execute([
                'peminjaman_id' => $peminjamanId,
                'barang_id' => $item['barang_id'],
                'stok_pinjam' => $item['stok_pinjam']
            ]);
        }
        
        // Commit transaction
        $db->commit();
        
        // Get created request
        $stmt = $db->prepare("
            SELECT id, jurusan, user_id, jenis, ruangan,
                   penanggung_jawab, tingkat, waktu_mulai,
                   waktu_selesai, tujuan, tgl_pinjaman,
                   tgl_pengembalian, status, created_at
            FROM peminjaman
            WHERE id = :id
        ");
        $stmt->execute(['id' => $peminjamanId]);
        $request = $stmt->fetch();
        
        ResponseHelper::success([
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
        ], 'Request berhasil dibuat');
        
    } catch (Exception $e) {
        // Rollback on error
        $db->rollBack();
        throw $e;
    }
    
} catch (Exception $e) {
    error_log("Create equipment request error: " . $e->getMessage());
    ResponseHelper::error('Terjadi kesalahan saat membuat request peralatan', 500);
}
