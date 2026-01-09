<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/response.php';
require_once __DIR__ . '/../config/security_helpers.php';
require_once __DIR__ . '/../config/audit_logger.php';

class AuthMiddleware {
    private static $cachedUser = null;
    
    private static function getCurrentEndpoint() {
        $endpoint = $_SERVER['REQUEST_URI'] ?? '/';
        $endpoint = parse_url($endpoint, PHP_URL_PATH);
        return substr($endpoint, 0, 255) ?: '/';
    }
    
    private static function getAuthorizationHeader() {
        $headers = getallheaders();
        
        if (is_array($headers)) {
            $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;
            if ($authHeader) {
                return $authHeader;
            }
        }
        
        if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            return $_SERVER['HTTP_AUTHORIZATION'];
        }
        
        if (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
            return $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
        }
        
        return null;
    }
    
    private static function revokeToken($db, $tokenHash, $reason) {
        try {
            $stmt = $db->prepare("
                UPDATE api_tokens
                SET revoked_at = NOW(),
                    revoked_reason = :reason
                WHERE token_hash = :token_hash
            ");
            $stmt->execute([
                'token_hash' => $tokenHash,
                'reason' => $reason
            ]);
            
            error_log("Token revoked: token_hash=" . substr($tokenHash, 0, 16) . "... reason=" . $reason);
        } catch (Exception $e) {
            error_log("Token revocation error: " . $e->getMessage());
        }
    }
    
    public static function validateToken() {
        $authHeader = self::getAuthorizationHeader();
        
        if (!$authHeader) {
            AuditLogger::unauthorized(null, 'missing_authorization_header');
            ResponseHelper::unauthorized('Authorization header missing');
        }
        
        if (!preg_match('/Bearer\s+(.*)$/i', trim($authHeader), $matches)) {
            AuditLogger::unauthorized(null, 'invalid_authorization_format');
            ResponseHelper::unauthorized('Invalid authorization format');
        }
        
        $token = trim($matches[1]);
        
        if (empty($token)) {
            AuditLogger::unauthorized(null, 'empty_token');
            ResponseHelper::unauthorized('Token is required');
        }
        
        if (strlen($token) !== 64 || !ctype_xdigit($token)) {
            AuditLogger::unauthorized(null, 'invalid_token_format');
            ResponseHelper::unauthorized('Invalid token format');
        }
        
        $tokenHash = hash('sha256', $token);
        
        try {
            $db = Database::getInstance()->getConnection();
            
            $db->beginTransaction();
            
            $stmt = $db->prepare("
                SELECT 
                    at.id AS token_id,
                    at.user_id AS token_user_id,
                    at.expires_at AS token_expires_at,
                    at.last_ip,
                    at.last_user_agent,
                    at.last_used_at,
                    at.revoked_at,
                    u.id AS user_id,
                    u.name AS user_name,
                    u.email AS user_email,
                    u.username AS user_username,
                    u.foto_profile AS user_foto_profile,
                    u.jenis_kelamin AS user_jenis_kelamin,
                    u.no_hp AS user_no_hp,
                    u.jurusan AS user_jurusan,
                    u.role AS user_role
                FROM api_tokens at
                INNER JOIN users u ON at.user_id = u.id
                WHERE at.token_hash = :token_hash
                AND at.expires_at > NOW()
                LIMIT 1
            FOR UPDATE
            ");
            
            $stmt->execute(['token_hash' => $tokenHash]);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$result) {
                $db->rollBack();
                AuditLogger::tokenExpired(null, $tokenHash);
                
                require_once __DIR__ . '/../config/alert_engine.php';
                AlertEngine::check('TOKEN_INVALID', [
                    'token_hash' => $tokenHash,
                    'endpoint' => self::getCurrentEndpoint(),
                    'status' => 'FAIL'
                ]);
                
                ResponseHelper::unauthorized('Invalid or expired token');
            }
            
            if ($result['revoked_at'] !== null) {
                $db->rollBack();
                AuditLogger::tokenRevoked($result['user_id'], $result['revoked_reason'] ?? 'revoked', $tokenHash);
                ResponseHelper::unauthorized('Session expired. Please login again.');
            }
            
            $currentIp = SecurityHelpers::getClientIp();
            $currentUserAgent = SecurityHelpers::getUserAgent();
            $lastIp = $result['last_ip'];
            $lastUserAgent = $result['last_user_agent'];
            
            $revoked = false;
            $revokeReason = null;
            
            if ($lastUserAgent !== null && $lastUserAgent !== '' && $currentUserAgent !== $lastUserAgent) {
                $revoked = true;
                $revokeReason = 'ua_mismatch';
                self::revokeToken($db, $tokenHash, $revokeReason);
                $db->commit();
                AuditLogger::tokenReplay($result['user_id'], $currentIp, $currentUserAgent, $revokeReason);
                
                require_once __DIR__ . '/../config/alert_engine.php';
                AlertEngine::check('TOKEN_MULTI_IP', [
                    'token_hash' => $tokenHash,
                    'user_id' => $result['user_id'],
                    'ip_address' => $currentIp,
                    'endpoint' => self::getCurrentEndpoint(),
                    'status' => 'FAIL',
                    'metadata' => ['reason' => $revokeReason]
                ]);
                
                ResponseHelper::unauthorized('Session expired. Please login again.');
            }
            
            if ($lastIp !== null && $lastIp !== '' && $lastIp !== '0.0.0.0') {
                if (!SecurityHelpers::isSameSubnet($currentIp, $lastIp)) {
                    $revoked = true;
                    $revokeReason = 'ip_mismatch';
                    self::revokeToken($db, $tokenHash, $revokeReason);
                    $db->commit();
                    AuditLogger::tokenReplay($result['user_id'], $currentIp, $currentUserAgent, $revokeReason);
                    
                    require_once __DIR__ . '/../config/alert_engine.php';
                    AlertEngine::check('TOKEN_MULTI_IP', [
                        'token_hash' => $tokenHash,
                        'user_id' => $result['user_id'],
                        'ip_address' => $currentIp,
                        'endpoint' => self::getCurrentEndpoint(),
                        'status' => 'FAIL',
                        'metadata' => ['reason' => $revokeReason, 'last_ip' => $lastIp]
                    ]);
                    
                    ResponseHelper::unauthorized('Session expired. Please login again.');
                }
            }
            
            if (!$revoked) {
                $currentTime = date('Y-m-d H:i:s');
                
                $stmt = $db->prepare("
                    UPDATE api_tokens
                    SET last_ip = :last_ip,
                        last_user_agent = :last_user_agent,
                        last_used_at = :last_used_at,
                        updated_at = NOW()
                    WHERE id = :token_id
                ");
                
                $stmt->execute([
                    'token_id' => $result['token_id'],
                    'last_ip' => $currentIp,
                    'last_user_agent' => $currentUserAgent,
                    'last_used_at' => $currentTime
                ]);
                
                $db->commit();
            }
            
            $user = [
                'id' => (int)$result['user_id'],
                'name' => $result['user_name'],
                'email' => $result['user_email'],
                'username' => $result['user_username'],
                'foto_profile' => $result['user_foto_profile'],
                'jenis_kelamin' => $result['user_jenis_kelamin'],
                'no_hp' => $result['user_no_hp'],
                'jurusan' => $result['user_jurusan'],
                'role' => $result['user_role']
            ];
            
            self::$cachedUser = $user;
            
            return $user;
            
        } catch (PDOException $e) {
            if (isset($db) && $db->inTransaction()) {
                $db->rollBack();
            }
            AuditLogger::dbError($e->getMessage(), 'token_validation');
            ResponseHelper::error('Authentication service error', 500);
        } catch (Exception $e) {
            if (isset($db) && $db->inTransaction()) {
                $db->rollBack();
            }
            AuditLogger::exception($e, ['action' => 'token_validation']);
            ResponseHelper::error('Authentication service error', 500);
        }
    }
    
    public static function requireRole($allowedRoles = []) {
        $user = self::validateToken();
        
        if (!empty($allowedRoles)) {
            if (!is_array($allowedRoles)) {
                $allowedRoles = [$allowedRoles];
            }
            
            if (!in_array($user['role'], $allowedRoles)) {
                AuditLogger::forbidden($user['id'], implode(', ', $allowedRoles));
                
                require_once __DIR__ . '/../config/alert_engine.php';
                AlertEngine::check('REPEATED_403', [
                    'user_id' => $user['id'],
                    'endpoint' => self::getCurrentEndpoint(),
                    'status' => 'FAIL',
                    'metadata' => ['required_role' => implode(', ', $allowedRoles), 'user_role' => $user['role']]
                ]);
                
                ResponseHelper::forbidden('Access denied. Required role: ' . implode(', ', $allowedRoles));
            }
        }
        
        return $user;
    }
    
    public static function user() {
        if (self::$cachedUser !== null) {
            return self::$cachedUser;
        }
        
        return self::validateToken();
    }
}
