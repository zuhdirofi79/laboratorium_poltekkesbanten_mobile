import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../domain/lab_room.dart';

/// Admin Rooms API
/// 
/// Implements admin room management endpoints using ApiClient from core
/// Endpoints:
/// - GET /admin/master-data?search={query}
/// - POST /admin/rooms/add
/// - PUT /admin/rooms/edit?id={id}
/// - DELETE /admin/rooms/delete?id={id}
/// Does NOT handle token (handled by ApiClient interceptor)
/// Does NOT catch errors except to rethrow as Failure
class AdminRoomsApi {
  final ApiClient _apiClient;
  
  AdminRoomsApi(this._apiClient);
  
  /// GET /admin/master-data
  /// 
  /// Get list of lab rooms (with optional search)
  /// Backend: api/admin/master-data.php
  /// Requires authentication (handled by interceptor)
  Future<List<LabRoom>> getRooms({String? search}) async {
    try {
      Logger.info('Getting admin rooms (search: $search)');
      
      final queryParameters = search != null && search.isNotEmpty
          ? {'search': search}
          : null;
      
      final response = await _apiClient.get(
        '/admin/master-data',
        queryParameters: queryParameters,
        requiresAuth: true,
      );
      
      // Parse response according to contract
      // Response structure: { "success": true, "message": "...", "data": [...] }
      final data = response[ApiConfig.fieldData] as List<dynamic>?;
      
      if (data == null) {
        Logger.warning('Admin rooms response missing data field');
        return [];
      }
      
      final rooms = data
          .map((json) => LabRoom.fromJson(json as Map<String, dynamic>))
          .toList();
      
      Logger.info('Retrieved ${rooms.length} admin rooms');
      return rooms;
    } on Failure {
      // Re-throw Failure as-is (from ApiClient)
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting admin rooms', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to get admin rooms: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// POST /admin/rooms/add
  /// 
  /// Add new room
  /// Backend: api/admin/rooms/add.php
  /// Requires authentication (handled by interceptor)
  Future<void> addRoom({
    required String labName,
    required String department,
    required String campus,
  }) async {
    try {
      Logger.info('Adding admin room (name: $labName)');
      
      await _apiClient.post(
        '/admin/rooms/add',
        body: {
          'nama_ruang_lab': labName,
          'jurusan': department,
          'kampus': campus,
        },
        requiresAuth: true,
      );
      
      Logger.info('Admin room added successfully: $labName');
    } on Failure {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error adding admin room', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to add admin room: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// PUT /admin/rooms/edit?id={id}
  /// 
  /// Edit room
  /// Backend: api/admin/rooms/edit.php
  /// Requires authentication (handled by interceptor)
  /// Note: Backend uses query parameter ?id=
  Future<void> updateRoom({
    required int id,
    required String labName,
    required String department,
    required String campus,
  }) async {
    try {
      Logger.info('Updating admin room (id: $id)');
      
      final endpoint = '/admin/rooms/edit?id=$id';
      await _apiClient.put(
        endpoint,
        body: {
          'nama_ruang_lab': labName,
          'jurusan': department,
          'kampus': campus,
        },
        requiresAuth: true,
      );
      
      Logger.info('Admin room updated successfully: $id');
    } on Failure {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error updating admin room', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to update admin room: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// DELETE /admin/rooms/delete?id={id}
  /// 
  /// Delete room
  /// Backend: api/admin/rooms/delete.php
  /// Requires authentication (handled by interceptor)
  /// Note: Backend uses query parameter ?id=
  Future<void> deleteRoom(int id) async {
    try {
      Logger.info('Deleting admin room (id: $id)');
      
      final endpoint = '/admin/rooms/delete?id=$id';
      await _apiClient.delete(
        endpoint,
        requiresAuth: true,
      );
      
      Logger.info('Admin room deleted successfully: $id');
    } on Failure {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error deleting admin room', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to delete admin room: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
}
