import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../domain/admin_user.dart';
import 'admin_users_api.dart';

/// Admin Users Repository
/// 
/// Coordinates between AdminUsersApi and business logic
/// Maps ApiException → Failure
/// Never throws raw exceptions
/// Throws Failure (following AuthRepository pattern)
class AdminUsersRepository {
  final AdminUsersApi _adminUsersApi;
  
  AdminUsersRepository({
    required AdminUsersApi adminUsersApi,
  }) : _adminUsersApi = adminUsersApi;
  
  /// Get users list
  /// 
  /// Returns List<AdminUser> on success
  /// Throws Failure on error (to be caught by provider)
  /// 
  /// Failure mapping:
  /// - 401 → AuthFailure (token invalid/expired)
  /// - 403 → SecurityBlockedFailure (user/IP blocked)
  /// - 429 → RateLimitFailure (rate limited)
  /// - others → NetworkFailure / ServerFailure
  Future<List<AdminUser>> getUsers({String? search}) async {
    try {
      Logger.info('Getting admin users via repository (search: $search)');
      
      final users = await _adminUsersApi.getUsers(search: search);
      
      Logger.info('Admin users retrieved successfully: ${users.length} items');
      return users;
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure getting admin users: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked getting admin users: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited getting admin users: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      Logger.error('Failure getting admin users: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting admin users', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Get manage users list (with roles)
  /// 
  /// Returns List<AdminUser> on success
  /// Throws Failure on error
  Future<List<AdminUser>> getManageUsers({String? search}) async {
    try {
      Logger.info('Getting manage users via repository (search: $search)');
      
      final users = await _adminUsersApi.getManageUsers(search: search);
      
      Logger.info('Manage users retrieved successfully: ${users.length} items');
      return users;
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure getting manage users: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked getting manage users: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited getting manage users: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      Logger.error('Failure getting manage users: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting manage users', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Add user
  /// 
  /// Returns void on success
  /// Throws Failure on error
  Future<void> addUser({
    required String username,
    required String fullName,
    required String email,
    String? phone,
    required String password,
    required String role,
  }) async {
    try {
      Logger.info('Adding user via repository (username: $username)');
      
      await _adminUsersApi.addUser(
        username: username,
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      
      Logger.info('User added successfully: $username');
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure adding user: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked adding user: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited adding user: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      Logger.error('Failure adding user: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error adding user', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Update user
  /// 
  /// Returns void on success
  /// Throws Failure on error
  Future<void> updateUser({
    required int id,
    required String username,
    required String fullName,
    required String email,
    String? phone,
    required String role,
  }) async {
    try {
      Logger.info('Updating user via repository (id: $id)');
      
      await _adminUsersApi.updateUser(
        id: id,
        username: username,
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
      );
      
      Logger.info('User updated successfully: $id');
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure updating user: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked updating user: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited updating user: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      Logger.error('Failure updating user: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error updating user', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Delete user
  /// 
  /// Returns void on success
  /// Throws Failure on error
  Future<void> deleteUser(int id) async {
    try {
      Logger.info('Deleting user via repository (id: $id)');
      
      await _adminUsersApi.deleteUser(id);
      
      Logger.info('User deleted successfully: $id');
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure deleting user: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked deleting user: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited deleting user: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      Logger.error('Failure deleting user: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error deleting user', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
}
