import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../domain/praktikum_schedule.dart';
import 'schedule_api.dart';

/// Schedule Repository
/// 
/// Coordinates between ScheduleApi and business logic
/// Maps ApiException → Failure
/// Never throws raw exceptions
/// Throws Failure (following EquipmentRepository pattern)
class ScheduleRepository {
  final ScheduleApi _scheduleApi;
  
  ScheduleRepository({
    required ScheduleApi scheduleApi,
  }) : _scheduleApi = scheduleApi;
  
  /// Get user praktikum schedules
  /// 
  /// Returns List<PraktikumSchedule> on success
  /// Throws Failure on error (to be caught by provider)
  /// 
  /// Failure mapping (SAME as EquipmentRepository):
  /// - 401 → AuthFailure (token invalid/expired)
  /// - 403 → SecurityBlockedFailure (user/IP blocked)
  /// - 429 → RateLimitFailure (rate limited)
  /// - others → NetworkFailure / ServerFailure
  Future<List<PraktikumSchedule>> getUserSchedules() async {
    try {
      Logger.info('Getting user praktikum schedules via repository');
      
      final schedules = await _scheduleApi.getUserSchedules();
      
      Logger.info('Praktikum schedules retrieved successfully: ${schedules.length} items');
      return schedules;
    } on AuthFailure catch (e) {
      // 401 - token invalid/expired (cleared by interceptor)
      Logger.warning('Auth failure getting praktikum schedules: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      // 403 - user/IP blocked
      Logger.warning('Security blocked getting praktikum schedules: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      // 429 - rate limited
      Logger.warning('Rate limited getting praktikum schedules: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      // Other failures (NetworkFailure, ServerFailure, etc.)
      Logger.error('Failure getting praktikum schedules: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting praktikum schedules', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
}
