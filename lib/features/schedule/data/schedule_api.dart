import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../domain/praktikum_schedule.dart';

/// Schedule API
/// 
/// Implements schedule endpoints using ApiClient from core
/// Endpoint: GET /user/praktikum/schedule
/// Does NOT handle token (handled by ApiClient interceptor)
/// Does NOT catch errors except to rethrow as Failure
class ScheduleApi {
  final ApiClient _apiClient;
  
  ScheduleApi(this._apiClient);
  
  /// GET /user/praktikum/schedule
  /// 
  /// Get current user's praktikum schedules
  /// Backend: api/user/praktikum/schedule.php
  /// Requires authentication (handled by interceptor)
  Future<List<PraktikumSchedule>> getUserSchedules() async {
    try {
      Logger.info('Getting user praktikum schedules');
      
      final response = await _apiClient.get(
        '/user/praktikum/schedule',
        requiresAuth: true,
      );
      
      // Parse response according to contract
      // Response structure: { "success": true, "message": "...", "data": [...] }
      final data = response[ApiConfig.fieldData] as List<dynamic>?;
      
      if (data == null) {
        Logger.warning('Schedule response missing data field');
        return [];
      }
      
      final schedules = data
          .map((json) => PraktikumSchedule.fromJson(json as Map<String, dynamic>))
          .toList();
      
      Logger.info('Retrieved ${schedules.length} praktikum schedules');
      return schedules;
    } on Failure {
      // Re-throw Failure as-is (from ApiClient)
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting praktikum schedules', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to get praktikum schedules: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
}
