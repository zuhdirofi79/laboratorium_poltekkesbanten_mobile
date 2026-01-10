import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../domain/equipment_request_summary.dart';
import '../domain/equipment_request_detail.dart';
import 'plp_approval_api.dart';

/// PLP Approval Repository
/// 
/// Coordinates between PlpApprovalApi and business logic
/// Maps ApiException → Failure
/// Never throws raw exceptions
/// Throws Failure (following EquipmentRepository pattern)
class PlpApprovalRepository {
  final PlpApprovalApi _plpApprovalApi;
  
  PlpApprovalRepository({
    required PlpApprovalApi plpApprovalApi,
  }) : _plpApprovalApi = plpApprovalApi;
  
  /// Get pending equipment requests
  /// 
  /// Returns List<EquipmentRequestSummary> on success
  /// Throws Failure on error (to be caught by provider)
  /// 
  /// Failure mapping (SAME as EquipmentRepository):
  /// - 401 → AuthFailure (token invalid/expired)
  /// - 403 → SecurityBlockedFailure (user/IP blocked)
  /// - 429 → RateLimitFailure (rate limited)
  /// - others → NetworkFailure / ServerFailure
  Future<List<EquipmentRequestSummary>> getPendingRequests({String? status}) async {
    try {
      Logger.info('Getting pending equipment requests via repository (status: $status)');
      
      final requests = await _plpApprovalApi.getPendingRequests(status: status);
      
      Logger.info('Pending equipment requests retrieved successfully: ${requests.length} items');
      return requests;
    } on AuthFailure catch (e) {
      // 401 - token invalid/expired (cleared by interceptor)
      Logger.warning('Auth failure getting pending requests: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      // 403 - user/IP blocked
      Logger.warning('Security blocked getting pending requests: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      // 429 - rate limited
      Logger.warning('Rate limited getting pending requests: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      // Other failures (NetworkFailure, ServerFailure, etc.)
      Logger.error('Failure getting pending requests: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting pending requests', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Get equipment request detail
  /// 
  /// Returns EquipmentRequestDetail on success
  /// Throws Failure on error
  Future<EquipmentRequestDetail> getRequestDetail(int requestId) async {
    try {
      Logger.info('Getting equipment request detail via repository (id: $requestId)');
      
      final detail = await _plpApprovalApi.getRequestDetail(requestId);
      
      Logger.info('Equipment request detail retrieved successfully: ${detail.id}');
      return detail;
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure getting request detail: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked getting request detail: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited getting request detail: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      Logger.error('Failure getting request detail: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting request detail', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Approve equipment request
  /// 
  /// Returns void on success
  /// Throws Failure on error
  Future<void> approveRequest(int requestId) async {
    try {
      Logger.info('Approving equipment request via repository (id: $requestId)');
      
      await _plpApprovalApi.approveRequest(requestId);
      
      Logger.info('Equipment request approved successfully: $requestId');
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure approving request: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked approving request: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited approving request: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      Logger.error('Failure approving request: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error approving request', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
  
  /// Reject equipment request
  /// 
  /// Returns void on success
  /// Throws Failure on error
  Future<void> rejectRequest(int requestId, String reason) async {
    try {
      Logger.info('Rejecting equipment request via repository (id: $requestId, reason: $reason)');
      
      await _plpApprovalApi.rejectRequest(requestId, reason);
      
      Logger.info('Equipment request rejected successfully: $requestId');
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure rejecting request: ${e.message}');
      rethrow;
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked rejecting request: ${e.message}');
      rethrow;
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited rejecting request: ${e.message}, retry after: ${e.retryAfterSeconds}s');
      rethrow;
    } on Failure catch (e) {
      Logger.error('Failure rejecting request: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error rejecting request', e, stackTrace);
      throw ServerFailure(
        message: 'Unexpected error: $e',
        errorCode: ErrorCode.unknown,
      );
    }
  }
}
