import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../domain/equipment_request.dart';
import 'equipment_api.dart';

/// Equipment Repository
/// 
/// Coordinates between EquipmentApi and business logic
/// Maps ApiException → Failure
/// Never throws raw exceptions
/// Throws Failure (following AuthRepository pattern)
class EquipmentRepository {
  final EquipmentApi _equipmentApi;
  
  EquipmentRepository({
    required EquipmentApi equipmentApi,
  }) : _equipmentApi = equipmentApi;
  
  /// Get user equipment requests
  /// 
  /// Returns List<EquipmentRequest> on success
  /// Throws Failure on error (to be caught by provider)
  /// 
  /// Failure mapping:
  /// - 401 → AuthFailure (token invalid/expired)
  /// - 403 → SecurityBlockedFailure (user/IP blocked)
  /// - 429 → RateLimitFailure (rate limited)
  /// - others → NetworkFailure / ServerFailure
  Future<List<EquipmentRequest>> getUserEquipmentRequests() async {
    try {
      Logger.info('Getting user equipment requests via repository');
      
      final requests = await _equipmentApi.getUserEquipmentRequests();
      
      Logger.info('Equipment requests retrieved successfully: ${requests.length} items');
      return requests;
    } on AuthFailure catch (e) {
      // 401 - token invalid/expired (cleared by interceptor)
      Logger.warning('Auth failure getting equipment requests: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      // 403 - user/IP blocked
      Logger.warning('Security blocked getting equipment requests: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      // 429 - rate limited
      Logger.warning('Rate limited getting equipment requests: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      // Other failures (NetworkFailure, ServerFailure, etc.)
      Logger.error('Failure getting equipment requests: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting equipment requests', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
}
