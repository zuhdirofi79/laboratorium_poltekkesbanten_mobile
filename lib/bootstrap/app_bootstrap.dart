import '../core/errors/error_code.dart';
import '../core/errors/failure.dart';
import '../core/storage/token_storage.dart';
import '../core/utils/logger.dart';
import '../features/auth/data/auth_api.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/domain/auth_state.dart';
import '../core/network/api_client.dart';
import '../core/network/api_interceptor.dart';

/// App Bootstrap
/// 
/// Initializes app state on startup
/// Checks token existence and validates user session
/// Returns initial AuthState for UI layer
class AppBootstrap {
  final AuthRepository _authRepository;
  
  AppBootstrap(this._authRepository);
  
  /// Bootstrap app and return initial auth state
  /// 
  /// Flow:
  /// 1. Check if token exists
  /// 2. If exists, call /auth/me to validate
  /// 3. Return appropriate state:
  ///    - Authenticated (token valid, user retrieved)
  ///    - Unauthenticated (no token or token invalid)
  ///    - Blocked (reputation block)
  ///    - RateLimited (rate limit)
  ///    - AuthError (other errors)
  Future<AuthState> bootstrap() async {
    try {
      Logger.info('App bootstrap started');
      
      // Check if token exists
      if (!_authRepository.hasToken()) {
        Logger.info('No token found - unauthenticated');
        return const Unauthenticated();
      }
      
      Logger.info('Token found - validating with /auth/me');
      
      // Validate token by calling /auth/me
      try {
        final user = await _authRepository.getCurrentUser();
        Logger.info('Token valid - user authenticated: ${user.username}');
        return Authenticated(user);
      } on AuthFailure catch (e) {
        // Token invalid/expired - clear and return unauthenticated
        Logger.warning('Token invalid/expired: ${e.message}');
        await _authRepository.clearToken();
        return const Unauthenticated();
      } on SecurityBlockedFailure catch (e) {
        // User/IP blocked by reputation system
        Logger.warning('User blocked: ${e.message}');
        return Blocked(e);
      } on RateLimitFailure catch (e) {
        // Rate limited
        Logger.warning('Rate limited: ${e.message}, retry after: ${e.retryAfterSeconds}s');
        return RateLimited(e);
      } on Failure catch (e) {
        // Other failure
        Logger.error('Bootstrap error: ${e.message}');
        return AuthError(e);
      }
    } catch (e, stackTrace) {
      Logger.error('Unexpected error during bootstrap', e, stackTrace);
      return AuthError(
        ServerFailure(
          message: 'Bootstrap error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
    }
  }
  
  /// Factory method to create bootstrap with dependencies
  static Future<AppBootstrap> create() async {
    // Initialize storage
    final tokenStorage = await TokenStorage.getInstance();
    
    // Initialize network layer
    final interceptor = ApiInterceptor(tokenStorage);
    final apiClient = ApiClient(interceptor);
    
    // Initialize auth API
    final authApi = AuthApi(apiClient);
    
    // Initialize auth repository
    final authRepository = AuthRepository(
      authApi: authApi,
      tokenStorage: tokenStorage,
    );
    
    return AppBootstrap(authRepository);
  }
}
