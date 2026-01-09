<?php
/**
 * Database Configuration
 * 
 * Purpose: Isolated database connection for API layer
 * Does NOT interfere with existing web system's database connection
 * 
 * Location: api/config/database.php
 */

class Database {
    private static $instance = null;
    private $connection;
    
    // Database credentials - UPDATE THESE with your actual values
    private const DB_HOST = 'localhost';
    private const DB_NAME = 'adminlab_polkes';
    private const DB_USER = 'your_db_username';  // UPDATE THIS
    private const DB_PASS = 'your_db_password';  // UPDATE THIS
    private const DB_CHARSET = 'utf8mb4';
    
    private function __construct() {
        try {
            $dsn = "mysql:host=" . self::DB_HOST . ";dbname=" . self::DB_NAME . ";charset=" . self::DB_CHARSET;
            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ];
            
            $this->connection = new PDO($dsn, self::DB_USER, self::DB_PASS, $options);
        } catch (PDOException $e) {
            // Log error but don't expose database details
            error_log("Database connection failed: " . $e->getMessage());
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Database connection error'
            ]);
            exit;
        }
    }
    
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    public function getConnection() {
        return $this->connection;
    }
    
    // Prevent cloning
    private function __clone() {}
    
    // Prevent unserialization
    public function __wakeup() {
        throw new Exception("Cannot unserialize singleton");
    }
}
