/// API Configuration
/// 
/// Based on API_CONTRACT.md v1.0
/// Contains all API-related constants and configuration
class ApiConfig {
  // Base URL from contract
  static const String baseUrl = 'https://laboratorium.poltekkesbanten.ac.id/api';
  
  // API Version from contract
  static const String apiVersion = '1';
  
  // User Agent from contract requirements
  static const String userAgent = 'laboratorium-mobile-app';
  
  // Request timeout (30 seconds)
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Connect timeout (10 seconds)
  static const Duration connectTimeout = Duration(seconds: 10);
  
  // Header names
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String headerApiVersion = 'X-API-Version';
  static const String headerUserAgent = 'User-Agent';
  
  // Header values
  static const String contentTypeJson = 'application/json';
  static const String authorizationBearer = 'Bearer';
  
  // Endpoints (Auth only - per contract v1.0)
  static const String endpointLogin = '/auth/login';
  static const String endpointMe = '/auth/me';
  static const String endpointLogout = '/auth/logout';
  static const String endpointChangePassword = '/auth/change-password';
  
  // Response fields (from contract)
  static const String fieldSuccess = 'success';
  static const String fieldMessage = 'message';
  static const String fieldData = 'data';
  static const String fieldErrorCode = 'error_code';
  static const String fieldRetryAfter = 'retry_after';
  static const String fieldBlockUntil = 'block_until';
  
  // Login response fields
  static const String fieldToken = 'token';
  static const String fieldExpiresAt = 'expires_at';
  static const String fieldUser = 'user';
  
  // User fields
  static const String fieldUserId = 'user_id';
  static const String fieldUsername = 'username';
  static const String fieldFullName = 'full_name';
  static const String fieldEmail = 'email';
  static const String fieldPhoneNumber = 'phone_number';
  static const String fieldProfilePicture = 'profile_picture';
  static const String fieldGender = 'gender';
  static const String fieldDepartment = 'department';
  static const String fieldRole = 'role';
  
  // Private constructor - this is a utility class
  ApiConfig._();
}
