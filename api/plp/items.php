<?php
/**
 * Get Items List Endpoint (PLP)
 * 
 * Purpose: Get list of items (barang_inventaris, barangbhp_alat, barangbhp_bahan)
 * Filtered by user's jurusan
 * 
 * Location: api/plp/items.php
 * 
 * Endpoint: GET /api/plp/items.php?type=inventaris|alat|bahan
 * 
 * Headers:
 * Authorization: Bearer {token}
 * 
 * Query Parameters:
 * - type (optional): Filter by type (inventaris, alat, bahan). If not provided, returns all types
 * 
 * Response:
 * {
 *   "success": true,
 *   "data": [
 *     {
 *       "id": 1,
 *       "type": "inventaris",
 *       "nama": "Mikroskop",
 *       "stok": 10,
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
    // Require PLP role
    $user = AuthMiddleware::requireRole(['plp']);
    
    // Get type filter
    $type = $_GET['type'] ?? null;
    $userJurusan = strtolower($user['jurusan'] ?? '');
    
    // Get database connection
    $db = Database::getInstance()->getConnection();
    
    $items = [];
    
    // Get barang_inventaris
    if (!$type || $type === 'inventaris') {
        $sql = "SELECT 
                    id, jurusan, kode_barang, nama, tgl_masuk,
                    merk, type, no_seri, ruang, stok, satuan,
                    kondisi, updated_at
                FROM barang_inventaris
                WHERE LOWER(jurusan) = :jurusan
                AND (delete IS NULL OR delete = '')
                ORDER BY nama";
        
        $stmt = $db->prepare($sql);
        $stmt->execute(['jurusan' => $userJurusan]);
        $inventaris = $stmt->fetchAll();
        
        foreach ($inventaris as $item) {
            $items[] = [
                'id' => (int)$item['id'],
                'type' => 'inventaris',
                'jurusan' => $item['jurusan'],
                'kode_barang' => $item['kode_barang'],
                'nama' => $item['nama'],
                'tgl_masuk' => $item['tgl_masuk'],
                'merk' => $item['merk'],
                'type_item' => $item['type'],
                'no_seri' => $item['no_seri'],
                'ruang' => $item['ruang'],
                'stok' => (int)$item['stok'],
                'satuan' => $item['satuan'],
                'kondisi' => $item['kondisi'],
                'updated_at' => $item['updated_at']
            ];
        }
    }
    
    // Get barangbhp_alat
    if (!$type || $type === 'alat') {
        $sql = "SELECT 
                    id, jurusan, nama, stok, satuan, kondisi, updated_at
                FROM barangbhp_alat
                WHERE LOWER(jurusan) = :jurusan
                AND (delete IS NULL OR delete = '')
                ORDER BY nama";
        
        $stmt = $db->prepare($sql);
        $stmt->execute(['jurusan' => $userJurusan]);
        $alat = $stmt->fetchAll();
        
        foreach ($alat as $item) {
            $items[] = [
                'id' => (int)$item['id'],
                'type' => 'alat',
                'jurusan' => $item['jurusan'],
                'nama' => $item['nama'],
                'stok' => (int)$item['stok'],
                'satuan' => $item['satuan'],
                'kondisi' => $item['kondisi'],
                'updated_at' => $item['updated_at']
            ];
        }
    }
    
    // Get barangbhp_bahan
    if (!$type || $type === 'bahan') {
        $sql = "SELECT 
                    id, jurusan, nama, kimia, stok, satuan,
                    tgl_expired, updated_at
                FROM barangbhp_bahan
                WHERE LOWER(jurusan) = :jurusan
                AND (delete IS NULL OR delete = '')
                ORDER BY nama";
        
        $stmt = $db->prepare($sql);
        $stmt->execute(['jurusan' => $userJurusan]);
        $bahan = $stmt->fetchAll();
        
        foreach ($bahan as $item) {
            $items[] = [
                'id' => (int)$item['id'],
                'type' => 'bahan',
                'jurusan' => $item['jurusan'],
                'nama' => $item['nama'],
                'kimia' => $item['kimia'],
                'stok' => (int)$item['stok'],
                'satuan' => $item['satuan'],
                'tgl_expired' => $item['tgl_expired'],
                'updated_at' => $item['updated_at']
            ];
        }
    }
    
    ResponseHelper::success($items, 'Items retrieved successfully');
    
} catch (Exception $e) {
    error_log("Get items error: " . $e->getMessage());
    ResponseHelper::error('Terjadi kesalahan saat mengambil data items', 500);
}
