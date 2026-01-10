import 'package:flutter/foundation.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_interceptor.dart';
import '../data/admin_users_repository.dart';
import '../data/admin_users_api.dart';
import '../domain/admin_user.dart';
import 'admin_users_state.dart';

/// Admin Users Provider
/// 
/// Provides AdminUsersState to UI layer
/// Depends ONLY on AdminUsersRepository
/// Handles state changes and notifies listeners
/// NO navigation logic - UI handles navigation
/// Pattern mirrors PlpApprovalProvider exactly
class AdminUsersProvider with ChangeNotifier {
  AdminUsersRepository? _repository;
  
  AdminUsersState _state = const AdminUsersInitial();
  
  AdminUsersProvider._();
  
  /// Factory method to create provider with dependencies
  /// 
  /// Creates: TokenStorage → ApiInterceptor → ApiClient → AdminUsersApi → AdminUsersRepository
  /// NO global singletons - each provider gets its own instance
  static AdminUsersProvider create() {
    final provider = AdminUsersProvider._();
    provider._initialize();
    return provider;
  }
  
  Future<void> _initialize() async {
    try {
      // Initialize storage
      final tokenStorage = await TokenStorage.getInstance();
      
      // Initialize network layer
      final interceptor = ApiInterceptor(tokenStorage);
      final apiClient = ApiClient(interceptor);
      
      // Initialize admin users API
      final adminUsersApi = AdminUsersApi(apiClient);
      
      // Initialize admin users repository
      _repository = AdminUsersRepository(
        adminUsersApi: adminUsersApi,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize AdminUsersProvider', e, stackTrace);
      _state = AdminUsersError(
        ServerFailure(
          message: 'Failed to initialize admin users provider: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Current admin users state
  AdminUsersState get state => _state;
  
  /// Check if loading
  bool get isLoading => _state is AdminUsersLoading;
  
  /// Check if loaded
  bool get isLoaded => _state is AdminUsersLoaded;
  
  /// Check if empty
  bool get isEmpty => _state is AdminUsersEmpty;
  
  /// Check if action success
  bool get isActionSuccess => _state is AdminUsersActionSuccess;
  
  /// Check if error
  bool get isError => _state is AdminUsersError;
  
  /// Get users if loaded
  List<AdminUser>? get users {
    final state = _state;
    if (state is AdminUsersLoaded) {
      return state.users;
    }
    return null;
  }
  
  /// Get current failure if error state
  Failure? get currentFailure {
    final state = _state;
    if (state is AdminUsersError) {
      return state.failure;
    }
    return null;
  }
  
  /// Load users
  /// 
  /// Automatically:
  /// - sets Loading state
  /// - handles Empty vs Loaded
  /// - exposes Failure for UI
  /// NO navigation logic - UI handles based on state
  Future<void> loadUsers({String? search}) async {
    // Wait for initialization if needed
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = AdminUsersError(
        ServerFailure(
          message: 'Admin users repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const AdminUsersLoading();
      notifyListeners();
      
      Logger.info('Loading admin users via provider (search: $search)');
      
      final users = await _repository!.getUsers(search: search);
      
      // Handle Empty vs Loaded
      if (users.isEmpty) {
        _state = const AdminUsersEmpty();
        Logger.info('Admin users empty');
      } else {
        _state = AdminUsersLoaded(users);
        Logger.info('Admin users loaded: ${users.length} items');
      }
      
      notifyListeners();
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure loading admin users: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked loading admin users: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited loading admin users: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on Failure catch (e) {
      Logger.error('Failure loading admin users: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error loading admin users', e, stackTrace);
      _state = AdminUsersError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Load manage users (with roles)
  /// 
  /// Uses the /admin/manage-users endpoint instead of /admin/users
  /// Automatically:
  /// - sets Loading state
  /// - handles Empty vs Loaded
  /// - exposes Failure for UI
  /// NO navigation logic - UI handles based on state
  Future<void> loadManageUsers({String? search}) async {
    // Wait for initialization if needed
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = AdminUsersError(
        ServerFailure(
          message: 'Admin users repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const AdminUsersLoading();
      notifyListeners();
      
      Logger.info('Loading manage users via provider (search: $search)');
      
      final users = await _repository!.getManageUsers(search: search);
      
      // Handle Empty vs Loaded
      if (users.isEmpty) {
        _state = const AdminUsersEmpty();
        Logger.info('Manage users empty');
      } else {
        _state = AdminUsersLoaded(users);
        Logger.info('Manage users loaded: ${users.length} items');
      }
      
      notifyListeners();
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure loading manage users: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked loading manage users: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited loading manage users: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on Failure catch (e) {
      Logger.error('Failure loading manage users: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error loading manage users', e, stackTrace);
      _state = AdminUsersError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Add user
  /// 
  /// Sets state to AdminUsersActionSuccess on success
  /// Sets state to AdminUsersError on failure
  /// NO navigation logic - UI handles based on state
  Future<void> addUser({
    required String username,
    required String fullName,
    required String email,
    String? phone,
    required String password,
    required String role,
  }) async {
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = AdminUsersError(
        ServerFailure(
          message: 'Admin users repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const AdminUsersLoading();
      notifyListeners();
      
      Logger.info('Adding user via provider (username: $username)');
      
      await _repository!.addUser(
        username: username,
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      
      _state = AdminUsersActionSuccess(
        message: 'User berhasil ditambahkan',
      );
      Logger.info('User added successfully: $username');
      
      notifyListeners();
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure adding user: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked adding user: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited adding user: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on Failure catch (e) {
      Logger.error('Failure adding user: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error adding user', e, stackTrace);
      _state = AdminUsersError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Update user
  /// 
  /// Sets state to AdminUsersActionSuccess on success
  /// Sets state to AdminUsersError on failure
  /// NO navigation logic - UI handles based on state
  Future<void> updateUser({
    required int id,
    required String username,
    required String fullName,
    required String email,
    String? phone,
    required String role,
  }) async {
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = AdminUsersError(
        ServerFailure(
          message: 'Admin users repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const AdminUsersLoading();
      notifyListeners();
      
      Logger.info('Updating user via provider (id: $id)');
      
      await _repository!.updateUser(
        id: id,
        username: username,
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
      );
      
      _state = AdminUsersActionSuccess(
        message: 'User berhasil diupdate',
      );
      Logger.info('User updated successfully: $id');
      
      notifyListeners();
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure updating user: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked updating user: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited updating user: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on Failure catch (e) {
      Logger.error('Failure updating user: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error updating user', e, stackTrace);
      _state = AdminUsersError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Delete user
  /// 
  /// Sets state to AdminUsersActionSuccess on success
  /// Sets state to AdminUsersError on failure
  /// NO navigation logic - UI handles based on state
  Future<void> deleteUser(int id) async {
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = AdminUsersError(
        ServerFailure(
          message: 'Admin users repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const AdminUsersLoading();
      notifyListeners();
      
      Logger.info('Deleting user via provider (id: $id)');
      
      await _repository!.deleteUser(id);
      
      _state = AdminUsersActionSuccess(
        message: 'User berhasil dihapus',
      );
      Logger.info('User deleted successfully: $id');
      
      notifyListeners();
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure deleting user: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked deleting user: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited deleting user: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } on Failure catch (e) {
      Logger.error('Failure deleting user: ${e.message}');
      _state = AdminUsersError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error deleting user', e, stackTrace);
      _state = AdminUsersError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
}
