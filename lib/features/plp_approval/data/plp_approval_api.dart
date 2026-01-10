import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../domain/equipment_request_summary.dart';
import '../domain/equipment_request_detail.dart';

/// PLP Approval API
/// 
/// Implements PLP approval endpoints using ApiClient from core
/// Endpoints:
/// - GET /plp/equipment/requests?status=Menunggu
/// - GET /plp/requests/detail.php?id={id}
/// - POST /plp/requests/approve.php?id={id}
/// - POST /plp/requests/reject.php?id={id}
/// Does NOT handle token (handled by ApiClient interceptor)
/// Does NOT catch errors except to rethrow as Failure
class PlpApprovalApi {
  final ApiClient _apiClient;
  
  PlpApprovalApi(this._apiClient);
  
  /// GET /plp/equipment/requests
  /// 
  /// Get pending equipment requests for approval
  /// Backend: api/plp/equipment/requests.php
  /// Query parameter: status=Menunggu (optional, defaults to all)
  /// Requires authentication (handled by interceptor)
  Future<List<EquipmentRequestSummary>> getPendingRequests({String? status}) async {
    try {
      Logger.info('Getting pending equipment requests (status: $status)');
      
      final queryParameters = status != null ? {'status': status} : null;
      
      final response = await _apiClient.get(
        '/plp/equipment/requests',
        queryParameters: queryParameters,
        requiresAuth: true,
      );
      
      // Parse response according to contract
      // Response structure: { "success": true, "message": "...", "data": [...] }
      final data = response[ApiConfig.fieldData] as List<dynamic>?;
      
      if (data == null) {
        Logger.warning('Pending requests response missing data field');
        return [];
      }
      
      final requests = data
          .map((json) => EquipmentRequestSummary.fromJson(json as Map<String, dynamic>))
          .toList();
      
      Logger.info('Retrieved ${requests.length} pending equipment requests');
      return requests;
    } on Failure {
      // Re-throw Failure as-is (from ApiClient)
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting pending requests', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to get pending requests: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// GET /plp/requests/detail.php?id={id}
  /// 
  /// Get equipment request detail with items
  /// Backend: api/plp/requests/detail.php
  /// Requires authentication (handled by interceptor)
  /// Note: Backend uses query parameter ?id= not path parameter
  Future<EquipmentRequestDetail> getRequestDetail(int requestId) async {
    try {
      Logger.info('Getting equipment request detail (id: $requestId)');
      
      final response = await _apiClient.get(
        '/plp/requests/detail.php',
        queryParameters: {'id': requestId.toString()},
        requiresAuth: true,
      );
      
      // Parse response according to contract
      // Response structure: { "success": true, "message": "...", "data": {...} }
      final data = response[ApiConfig.fieldData] as Map<String, dynamic>;
      
      final detail = EquipmentRequestDetail.fromJson(data);
      
      Logger.info('Retrieved equipment request detail: ${detail.id}');
      return detail;
    } on Failure {
      // Re-throw Failure as-is (from ApiClient)
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting request detail', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to get request detail: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// POST /plp/requests/approve.php?id={id}
  /// 
  /// Approve equipment request
  /// Backend: api/plp/requests/approve.php
  /// Requires authentication (handled by interceptor)
  /// Note: Backend uses query parameter ?id= - append to endpoint URL
  Future<void> approveRequest(int requestId) async {
    try {
      Logger.info('Approving equipment request (id: $requestId)');
      
      // Backend expects query parameter ?id=, append to endpoint URL
      final endpoint = '/plp/requests/approve.php?id=$requestId';
      await _apiClient.post(
        endpoint,
        body: {},
        requiresAuth: true,
      );
      
      Logger.info('Equipment request approved successfully: $requestId');
    } on Failure {
      // Re-throw Failure as-is (from ApiClient)
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error approving request', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to approve request: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// POST /plp/requests/reject.php?id={id}
  /// 
  /// Reject equipment request with reason
  /// Backend: api/plp/requests/reject.php
  /// Requires authentication (handled by interceptor)
  /// Note: Backend uses query parameter ?id= - append to endpoint URL
  Future<void> rejectRequest(int requestId, String reason) async {
    try {
      Logger.info('Rejecting equipment request (id: $requestId, reason: $reason)');
      
      // Backend expects query parameter ?id=, append to endpoint URL
      final endpoint = '/plp/requests/reject.php?id=$requestId';
      await _apiClient.post(
        endpoint,
        body: {'keterangan': reason},
        requiresAuth: true,
      );
      
      Logger.info('Equipment request rejected successfully: $requestId');
    } on Failure {
      // Re-throw Failure as-is (from ApiClient)
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error rejecting request', e, stackTrace);
      throw ServerFailure(
        message: 'Failed to reject request: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
}
