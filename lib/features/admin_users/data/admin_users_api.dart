import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../domain/admin_user.dart';

/// Admin Users API
/// 
/// Implements admin user management endpoints using ApiClient from core
/// Endpoints:
/// - GET /admin/users?search={query}
/// - GET /admin/manage-users?search={query}
/// - POST /admin/users/add
/// - PUT /admin/users/edit?id={id}
/// - DELETE /admin/users/delete?id={id}
/// Does NOT handle token (handled by ApiClient interceptor)
/// Does NOT catch errors except to rethrow as Failure
class AdminUsersApi {
  final ApiClient _apiClient;
  
  AdminUsersApi(this._apiClient);
  
  /// GET /admin/users
  /// 
  /// Get list of users (with optional search)
  /// Backend: api/admin/users.php
  /// Requires authentication (handled by interceptor)
  Future<List<AdminUser>> getUsers({String? search}) async {
    try {
      Logger.info('Getting admin users (search: $search)');
      
      final queryParameters = search != null && search.isNotEmpty
          ? {'search': search}
          : null;
      
      final response = await _apiClient.get(
        '/admin/users',
        queryParameters: queryParameters,
        requiresAuth: true,
      );
      
      // Parse response according to contract
      // Response structure: { "success": true, "message": "...", "data": [...] }
      final data = response[ApiConfig.fieldData] as List<dynamic>?;
      
      if (data == null) {
        Logger.warning('Admin users response missing data field');
        return [];
      }
      
      final users = data
          .map((json) => AdminUser.fromJson(json as Map<String, dynamic>))
          .toList();
      
      Logger.info('Retrieved ${users.length} admin users');
      return users;
    } on Failure {
      // Re-throw Failure as-is (from ApiClient)
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting admin users', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to get admin users: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// GET /admin/manage-users
  /// 
  /// Get list of users with roles (with optional search)
  /// Backend: api/admin/manage-users.php
  /// Requires authentication (handled by interceptor)
  Future<List<AdminUser>> getManageUsers({String? search}) async {
    try {
      Logger.info('Getting manage users (search: $search)');
      
      final queryParameters = search != null && search.isNotEmpty
          ? {'search': search}
          : null;
      
      final response = await _apiClient.get(
        '/admin/manage-users',
        queryParameters: queryParameters,
        requiresAuth: true,
      );
      
      // Parse response according to contract
      final data = response[ApiConfig.fieldData] as List<dynamic>?;
      
      if (data == null) {
        Logger.warning('Manage users response missing data field');
        return [];
      }
      
      final users = data
          .map((json) => AdminUser.fromJson(json as Map<String, dynamic>))
          .toList();
      
      Logger.info('Retrieved ${users.length} manage users');
      return users;
    } on Failure {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting manage users', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to get manage users: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// POST /admin/users/add
  /// 
  /// Add new user
  /// Backend: api/admin/users/add.php
  /// Requires authentication (handled by interceptor)
  Future<void> addUser({
    required String username,
    required String fullName,
    required String email,
    String? phone,
    required String password,
    required String role,
  }) async {
    try {
      Logger.info('Adding admin user (username: $username)');
      
      await _apiClient.post(
        '/admin/users/add',
        body: {
          'username': username,
          'nama': fullName,
          'email': email,
          if (phone != null && phone.isNotEmpty) 'telepon': phone,
          'password': password,
          'role': role,
        },
        requiresAuth: true,
      );
      
      Logger.info('Admin user added successfully: $username');
    } on Failure {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error adding admin user', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to add admin user: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// PUT /admin/users/edit?id={id}
  /// 
  /// Edit user
  /// Backend: api/admin/users/edit.php
  /// Requires authentication (handled by interceptor)
  /// Note: Backend uses query parameter ?id=
  Future<void> updateUser({
    required int id,
    required String username,
    required String fullName,
    required String email,
    String? phone,
    required String role,
  }) async {
    try {
      Logger.info('Updating admin user (id: $id)');
      
      final endpoint = '/admin/users/edit?id=$id';
      await _apiClient.put(
        endpoint,
        body: {
          'username': username,
          'nama': fullName,
          'email': email,
          if (phone != null && phone.isNotEmpty) 'telepon': phone,
          'role': role,
        },
        requiresAuth: true,
      );
      
      Logger.info('Admin user updated successfully: $id');
    } on Failure {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error updating admin user', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to update admin user: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// DELETE /admin/users/delete?id={id}
  /// 
  /// Delete user
  /// Backend: api/admin/users/delete.php
  /// Requires authentication (handled by interceptor)
  /// Note: Backend uses query parameter ?id=
  Future<void> deleteUser(int id) async {
    try {
      Logger.info('Deleting admin user (id: $id)');
      
      final endpoint = '/admin/users/delete?id=$id';
      await _apiClient.delete(
        endpoint,
        requiresAuth: true,
      );
      
      Logger.info('Admin user deleted successfully: $id');
    } on Failure {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error deleting admin user', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to delete admin user: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
}
