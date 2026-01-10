import '../../../core/errors/error_code.dart';
import '../../../core/errors/failure.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/logger.dart';
import 'auth_api.dart';
import 'auth_models.dart';

/// Auth Repository
/// 
/// Coordinates between API and storage
/// Handles business logic for authentication flow
class AuthRepository {
  final AuthApi _authApi;
  final TokenStorage _tokenStorage;
  
  AuthRepository({
    required AuthApi authApi,
    required TokenStorage tokenStorage,
  })  : _authApi = authApi,
        _tokenStorage = tokenStorage;
  
  /// Login flow:
  /// 1. Call API
  /// 2. Save token
  /// 3. Return user
  /// 
  /// Contract: API_CONTRACT.md v1.0 - POST /auth/login
  Future<AuthenticatedUser> login(String username, String password) async {
    try {
      Logger.info('Login attempt for user: $username');
      
      final request = LoginRequest(
        username: username,
        password: password,
      );
      
      final response = await _authApi.login(request);
      
      // Save token (opaque JWT - no decoding)
      final tokenSaved = await _tokenStorage.saveToken(response.token.token);
      if (!tokenSaved) {
        Logger.warning('Failed to save token, but login succeeded');
      }
      
      Logger.info('Login successful for user: ${response.user.username}');
      return response.user;
    } on Failure {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error during login', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected login error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Get current user:
  /// 1. Call /auth/me
  /// 2. Return user
  /// 
  /// Contract: API_CONTRACT.md v1.0 - GET /auth/me
  /// This is the ONLY identity endpoint per contract
  Future<AuthenticatedUser> getCurrentUser() async {
    try {
      Logger.info('Getting current user');
      
      final user = await _authApi.getCurrentUser();
      
      Logger.info('Current user retrieved: ${user.username}');
      return user;
    } on AuthFailure {
      // Token invalid/expired - clear token
      Logger.warning('Auth failed getting user, clearing token');
      await _tokenStorage.clearToken();
      rethrow;
    } on Failure {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting current user', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Logout flow:
  /// 1. Call API (if token exists)
  /// 2. Clear token
  /// 
  /// Contract: API_CONTRACT.md v1.0 - POST /auth/logout
  Future<void> logout() async {
    try {
      Logger.info('Logout initiated');
      
      // Only call API if token exists
      if (_tokenStorage.hasToken()) {
        try {
          await _authApi.logout();
        } catch (e) {
          // Even if API call fails, clear local token
          Logger.warning('Logout API call failed, but clearing local token: $e');
        }
      }
      
      // Always clear local token
      await _tokenStorage.clearToken();
      
      Logger.info('Logout completed');
    } catch (e, stackTrace) {
      Logger.error('Unexpected error during logout', e, stackTrace);
      // Try to clear token anyway
      await _tokenStorage.clearToken();
      throw ServerFailure(
        message: 'Logout error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Change password
  /// 
  /// Contract: API_CONTRACT.md v1.0 - POST /auth/change-password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      Logger.info('Password change initiated');
      
      final request = ChangePasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      
      await _authApi.changePassword(request);
      
      Logger.info('Password changed successfully');
    } on Failure {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error changing password', e, stackTrace);
      throw ServerFailure(
        message: 'Password change error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Check if user has valid token
  bool hasToken() {
    return _tokenStorage.hasToken();
  }
  
  /// Get stored token (for debugging/logging only)
  /// Token is opaque - never decode
  String? getToken() {
    return _tokenStorage.getToken();
  }
  
  /// Clear token (called on 401 or explicit logout)
  Future<void> clearToken() async {
    await _tokenStorage.clearToken();
  }
}
