import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/errors/failure.dart';
import 'auth_models.dart';

/// Auth API
/// 
/// Implements authentication endpoints from API_CONTRACT.md v1.0
/// All endpoints match contract exactly
class AuthApi {
  final ApiClient _apiClient;
  
  AuthApi(this._apiClient);
  
  /// POST /auth/login
  /// 
  /// Authenticate user and receive JWT token
  /// Contract: API_CONTRACT.md v1.0 - POST /auth/login
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.endpointLogin,
        body: request.toJson(),
        requiresAuth: false, // Public endpoint
      );
      
      // Parse response according to contract
      // Response structure: { "success": true, "message": "...", "data": {...} }
      final data = response[ApiConfig.fieldData] as Map<String, dynamic>;
      
      return LoginResponse.fromJson({
        ApiConfig.fieldData: data,
      });
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to parse login response: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// GET /auth/me
  /// 
  /// Get current authenticated user identity
  /// Contract: API_CONTRACT.md v1.0 - GET /auth/me
  /// This is the ONLY identity endpoint per contract
  Future<AuthenticatedUser> getCurrentUser() async {
    try {
      final response = await _apiClient.get(
        ApiConfig.endpointMe,
        requiresAuth: true,
      );
      
      // Parse response according to contract
      // Response structure: { "success": true, "message": "...", "data": {...} }
      final data = response[ApiConfig.fieldData] as Map<String, dynamic>;
      
      return AuthenticatedUser.fromJson(data);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to parse user response: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// POST /auth/logout
  /// 
  /// Invalidate current JWT token
  /// Contract: API_CONTRACT.md v1.0 - POST /auth/logout
  Future<void> logout() async {
    try {
      await _apiClient.post(
        ApiConfig.endpointLogout,
        body: {},
        requiresAuth: true,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to logout: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// POST /auth/change-password
  /// 
  /// Change authenticated user's password
  /// Contract: API_CONTRACT.md v1.0 - POST /auth/change-password
  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await _apiClient.post(
        ApiConfig.endpointChangePassword,
        body: request.toJson(),
        requiresAuth: true,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to change password: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
}
