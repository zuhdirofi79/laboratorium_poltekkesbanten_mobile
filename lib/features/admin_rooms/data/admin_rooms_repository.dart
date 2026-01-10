import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../domain/lab_room.dart';
import 'admin_rooms_api.dart';

/// Admin Rooms Repository
/// 
/// Coordinates between AdminRoomsApi and business logic
/// Maps ApiException → Failure
/// Never throws raw exceptions
/// Throws Failure (following AuthRepository pattern)
class AdminRoomsRepository {
  final AdminRoomsApi _adminRoomsApi;
  
  AdminRoomsRepository({
    required AdminRoomsApi adminRoomsApi,
  }) : _adminRoomsApi = adminRoomsApi;
  
  /// Get rooms list
  /// 
  /// Returns List<LabRoom> on success
  /// Throws Failure on error (to be caught by provider)
  /// 
  /// Failure mapping:
  /// - 401 → AuthFailure (token invalid/expired)
  /// - 403 → SecurityBlockedFailure (user/IP blocked)
  /// - 429 → RateLimitFailure (rate limited)
  /// - others → NetworkFailure / ServerFailure
  Future<List<LabRoom>> getRooms({String? search}) async {
    try {
      Logger.info('Getting admin rooms via repository (search: $search)');
      
      final rooms = await _adminRoomsApi.getRooms(search: search);
      
      Logger.info('Admin rooms retrieved successfully: ${rooms.length} items');
      return rooms;
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure getting admin rooms: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked getting admin rooms: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited getting admin rooms: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      Logger.error('Failure getting admin rooms: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting admin rooms', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Add room
  /// 
  /// Returns void on success
  /// Throws Failure on error
  Future<void> addRoom({
    required String labName,
    required String department,
    required String campus,
  }) async {
    try {
      Logger.info('Adding room via repository (name: $labName)');
      
      await _adminRoomsApi.addRoom(
        labName: labName,
        department: department,
        campus: campus,
      );
      
      Logger.info('Room added successfully: $labName');
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure adding room: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked adding room: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited adding room: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      Logger.error('Failure adding room: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error adding room', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Update room
  /// 
  /// Returns void on success
  /// Throws Failure on error
  Future<void> updateRoom({
    required int id,
    required String labName,
    required String department,
    required String campus,
  }) async {
    try {
      Logger.info('Updating room via repository (id: $id)');
      
      await _adminRoomsApi.updateRoom(
        id: id,
        labName: labName,
        department: department,
        campus: campus,
      );
      
      Logger.info('Room updated successfully: $id');
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure updating room: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked updating room: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited updating room: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      Logger.error('Failure updating room: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error updating room', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Delete room
  /// 
  /// Returns void on success
  /// Throws Failure on error
  Future<void> deleteRoom(int id) async {
    try {
      Logger.info('Deleting room via repository (id: $id)');
      
      await _adminRoomsApi.deleteRoom(id);
      
      Logger.info('Room deleted successfully: $id');
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure deleting room: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked deleting room: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited deleting room: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      Logger.error('Failure deleting room: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error deleting room', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
}
