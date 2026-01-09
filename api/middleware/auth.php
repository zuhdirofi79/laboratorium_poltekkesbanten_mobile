<?php
/**
 * Authentication Middleware
 * 
 * Purpose: Validates Bearer token for protected endpoints
 * Does NOT use PHP sessions - completely stateless
 * 
 * Location: api/middleware/auth.php
 * 
 * Usage: require_once __DIR__ . '/../middleware/auth.php';
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/response.php';

class AuthMiddleware {
    /**
     * Validate token and return user data
     * 
     * @return array|null User data if valid, null if invalid
     */
    public static function validateToken() {
        // Get Authorization header
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;
        
        if (!$authHeader) {
            ResponseHelper::unauthorized('Authorization header missing');
        }
        
        // Extract token from "Bearer {token}"
        if (!preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            ResponseHelper::unauthorized('Invalid authorization format');
        }
        
        $token = $matches[1];
        
        if (empty($token)) {
            ResponseHelper::unauthorized('Token is required');
        }
        
        // Hash token to compare with stored hash
        $tokenHash = hash('sha256', $token);
        
        // Check token in database
        $db = Database::getInstance()->getConnection();
        
        $stmt = $db->prepare("
            SELECT 
                at.user_id,
                at.expires_at,
                u.id,
                u.name,
                u.email,
                u.username,
                u.foto_profile,
                u.jenis_kelamin,
                u.no_hp,
                u.jurusan,
                u.role
            FROM api_tokens at
            INNER JOIN users u ON at.user_id = u.id
            WHERE at.token_hash = :token_hash
            AND at.expires_at > NOW()
        ");
        
        $stmt->execute(['token_hash' => $tokenHash]);
        $result = $stmt->fetch();
        
        if (!$result) {
            ResponseHelper::unauthorized('Invalid or expired token');
        }
        
        // Return user data
        return [
            'id' => (int)$result['id'],
            'name' => $result['name'],
            'email' => $result['email'],
            'username' => $result['username'],
            'foto_profile' => $result['foto_profile'],
            'jenis_kelamin' => $result['jenis_kelamin'],
            'no_hp' => $result['no_hp'],
            'jurusan' => $result['jurusan'],
            'role' => $result['role']
        ];
    }
    
    /**
     * Check if user has required role
     * 
     * @param array $allowedRoles Array of allowed roles
     * @return array User data
     */
    public static function requireRole($allowedRoles = []) {
        $user = self::validateToken();
        
        if (!empty($allowedRoles) && !in_array($user['role'], $allowedRoles)) {
            ResponseHelper::forbidden('Access denied. Required role: ' . implode(', ', $allowedRoles));
        }
        
        return $user;
    }
}
