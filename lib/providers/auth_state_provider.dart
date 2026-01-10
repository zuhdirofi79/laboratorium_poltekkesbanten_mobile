import 'package:flutter/foundation.dart';
import '../bootstrap/app_bootstrap.dart';
import '../features/auth/domain/auth_state.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/auth_api.dart';
import '../features/auth/data/auth_models.dart';
import '../core/errors/failure.dart';
import '../core/errors/error_code.dart';
import '../core/storage/token_storage.dart';
import '../core/network/api_client.dart';
import '../core/network/api_interceptor.dart';

/// Auth State Provider
/// 
/// Provides AuthState to UI layer
/// Wraps AppBootstrap and AuthRepository
/// Handles state changes and notifies listeners
class AuthStateProvider with ChangeNotifier {
  AuthState _authState = const AuthLoading();
  AppBootstrap? _appBootstrap;
  AuthRepository? _authRepository;

  AuthState get authState => _authState;
  
  /// Get current user if authenticated
  AuthenticatedUser? get currentUser {
    final state = _authState;
    if (state is Authenticated) {
      return state.user;
    }
    return null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _authState is Authenticated;

  /// Check if auth is loading
  bool get isLoading => _authState is AuthLoading;

  /// Check if user is blocked
  bool get isBlocked => _authState is Blocked;

  /// Check if rate limited
  bool get isRateLimited => _authState is RateLimited;

  /// Initialize app and get initial auth state
  /// This should be called once at app startup
  Future<void> initialize() async {
    try {
      _authState = const AuthLoading();
      notifyListeners();

      // Create bootstrap and initialize
      _appBootstrap = await AppBootstrap.create();
      final state = await _appBootstrap!.bootstrap();
      
      // Create repository for login/logout operations
      final tokenStorage = await TokenStorage.getInstance();
      final interceptor = ApiInterceptor(tokenStorage);
      final apiClient = ApiClient(interceptor);
      final authApi = AuthApi(apiClient);
      _authRepository = AuthRepository(
        authApi: authApi,
        tokenStorage: tokenStorage,
      );
      
      _authState = state;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error initializing auth state: $e');
      _authState = AuthError(
        ServerFailure(
          message: 'Failed to initialize app: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }

  /// Login user
  /// Returns true if successful, false otherwise
  /// State is automatically updated on success
  Future<bool> login(String username, String password) async {
    if (_authRepository == null) {
      _authState = AuthError(
        ServerFailure(
          message: 'Auth repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return false;
    }

    try {
      _authState = const AuthLoading();
      notifyListeners();

      final user = await _authRepository!.login(username, password);
      _authState = Authenticated(user);
      notifyListeners();
      return true;
    } on AuthFailure catch (e) {
      _authState = AuthError(e);
      notifyListeners();
      return false;
    } on SecurityBlockedFailure catch (e) {
      _authState = Blocked(e);
      notifyListeners();
      return false;
    } on RateLimitFailure catch (e) {
      _authState = RateLimited(e);
      notifyListeners();
      return false;
    } on Failure catch (e) {
      _authState = AuthError(e);
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      debugPrint('Unexpected error during login: $e');
      _authState = AuthError(
        ServerFailure(
          message: 'Unexpected login error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  /// Clears token and sets state to Unauthenticated
  Future<void> logout() async {
    if (_authRepository == null) {
      _authState = const Unauthenticated();
      notifyListeners();
      return;
    }

    try {
      _authState = const AuthLoading();
      notifyListeners();

      await _authRepository!.logout();
      _authState = const Unauthenticated();
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error during logout: $e');
      // Even if logout fails, clear local state
      _authState = const Unauthenticated();
      notifyListeners();
    }
  }

  /// Refresh current user
  /// Call /auth/me to update user data
  Future<bool> refreshUser() async {
    if (_authRepository == null) {
      return false;
    }

    try {
      _authState = const AuthLoading();
      notifyListeners();

      final user = await _authRepository!.getCurrentUser();
      _authState = Authenticated(user);
      notifyListeners();
      return true;
    } on AuthFailure catch (e) {
      // Token invalid - clear and go to unauthenticated
      _authState = const Unauthenticated();
      notifyListeners();
      return false;
    } on SecurityBlockedFailure catch (e) {
      _authState = Blocked(e);
      notifyListeners();
      return false;
    } on RateLimitFailure catch (e) {
      _authState = RateLimited(e);
      notifyListeners();
      return false;
    } on Failure catch (e) {
      _authState = AuthError(e);
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      debugPrint('Unexpected error refreshing user: $e');
      _authState = AuthError(
        ServerFailure(
          message: 'Failed to refresh user: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return false;
    }
  }

  /// Get current failure if state is error/blocked/rate limited
  Failure? get currentFailure {
    final state = _authState;
    if (state is AuthError) {
      return state.failure;
    }
    if (state is Blocked) {
      return state.failure;
    }
    if (state is RateLimited) {
      return state.failure;
    }
    return null;
  }
}
