import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../domain/equipment_request.dart';

/// Equipment API
/// 
/// Implements equipment endpoints using ApiClient from core
/// Endpoint: GET /user/equipment/requests
/// Does NOT handle token (handled by ApiClient interceptor)
/// Does NOT catch errors except to rethrow as Failure
class EquipmentApi {
  final ApiClient _apiClient;
  
  EquipmentApi(this._apiClient);
  
  /// GET /user/equipment/requests
  /// 
  /// Get current user's equipment requests
  /// Backend: api/user/equipment/requests.php
  /// Requires authentication (handled by interceptor)
  Future<List<EquipmentRequest>> getUserEquipmentRequests() async {
    try {
      Logger.info('Getting user equipment requests');
      
      final response = await _apiClient.get(
        '/user/equipment/requests',
        requiresAuth: true,
      );
      
      // Parse response according to contract
      // Response structure: { "success": true, "message": "...", "data": [...] }
      final data = response[ApiConfig.fieldData] as List<dynamic>?;
      
      if (data == null) {
        Logger.warning('Equipment requests response missing data field');
        return [];
      }
      
      final requests = data
          .map((json) => EquipmentRequest.fromJson(json as Map<String, dynamic>))
          .toList();
      
      Logger.info('Retrieved ${requests.length} equipment requests');
      return requests;
    } on Failure {
      // Re-throw Failure as-is (from ApiClient)
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting equipment requests', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to get equipment requests: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
}
