import 'package:flutter/foundation.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_interceptor.dart';
import '../data/plp_approval_repository.dart';
import '../data/plp_approval_api.dart';
import '../domain/equipment_request_summary.dart';
import '../domain/equipment_request_detail.dart';
import 'plp_approval_state.dart';

/// PLP Approval Provider
/// 
/// Provides PlpApprovalState to UI layer
/// Depends ONLY on PlpApprovalRepository
/// Handles state changes and notifies listeners
/// NO navigation logic - UI handles navigation
/// Pattern mirrors EquipmentProvider exactly
class PlpApprovalProvider with ChangeNotifier {
  PlpApprovalRepository? _repository;
  
  PlpApprovalState _state = const PlpApprovalInitial();
  
  PlpApprovalProvider._();
  
  /// Factory method to create provider with dependencies
  /// 
  /// Creates: TokenStorage → ApiInterceptor → ApiClient → PlpApprovalApi → PlpApprovalRepository
  /// NO global singletons - each provider gets its own instance
  static PlpApprovalProvider create() {
    final provider = PlpApprovalProvider._();
    provider._initialize();
    return provider;
  }
  
  Future<void> _initialize() async {
    try {
      // Initialize storage
      final tokenStorage = await TokenStorage.getInstance();
      
      // Initialize network layer
      final interceptor = ApiInterceptor(tokenStorage);
      final apiClient = ApiClient(interceptor);
      
      // Initialize PLP approval API
      final plpApprovalApi = PlpApprovalApi(apiClient);
      
      // Initialize PLP approval repository
      _repository = PlpApprovalRepository(
        plpApprovalApi: plpApprovalApi,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize PlpApprovalProvider', e, stackTrace);
      _state = PlpApprovalError(
        ServerFailure(
          message: 'Failed to initialize PLP approval provider: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Current approval state
  PlpApprovalState get state => _state;
  
  /// Check if loading
  bool get isLoading => _state is PlpApprovalLoading;
  
  /// Check if list loaded
  bool get isListLoaded => _state is PlpApprovalListLoaded;
  
  /// Check if detail loaded
  bool get isDetailLoaded => _state is PlpApprovalDetailLoaded;
  
  /// Check if action success
  bool get isActionSuccess => _state is PlpApprovalActionSuccess;
  
  /// Check if empty
  bool get isEmpty => _state is PlpApprovalEmpty;
  
  /// Check if error
  bool get isError => _state is PlpApprovalError;
  
  /// Get requests if list loaded
  List<EquipmentRequestSummary>? get requests {
    final state = _state;
    if (state is PlpApprovalListLoaded) {
      return state.requests;
    }
    return null;
  }
  
  /// Get detail if detail loaded
  EquipmentRequestDetail? get detail {
    final state = _state;
    if (state is PlpApprovalDetailLoaded) {
      return state.detail;
    }
    return null;
  }
  
  /// Get current failure if error state
  Failure? get currentFailure {
    final state = _state;
    if (state is PlpApprovalError) {
      return state.failure;
    }
    return null;
  }
  
  /// Load pending equipment requests
  /// 
  /// Automatically:
  /// - sets Loading state
  /// - handles Empty vs Loaded
  /// - exposes Failure for UI
  /// NO navigation logic - UI handles based on state
  Future<void> loadPendingRequests({String? status}) async {
    // Wait for initialization if needed
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = const PlpApprovalError(
        ServerFailure(
          message: 'PLP approval repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const PlpApprovalLoading();
      notifyListeners();
      
      Logger.info('Loading pending equipment requests via provider (status: $status)');
      
      final requests = await _repository!.getPendingRequests(status: status);
      
      // Handle Empty vs Loaded
      if (requests.isEmpty) {
        _state = const PlpApprovalEmpty();
        Logger.info('Pending equipment requests empty');
      } else {
        _state = PlpApprovalListLoaded(requests);
        Logger.info('Pending equipment requests loaded: ${requests.length} items');
      }
      
      notifyListeners();
    } on AuthFailure catch (e) {
      // 401 - token invalid/expired
      // AuthWrapper will handle redirect to Login
      Logger.warning('Auth failure loading pending requests: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      // 403 - user/IP blocked
      // AuthWrapper will handle redirect to SecurityBlockedScreen
      Logger.warning('Security blocked loading pending requests: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      // 429 - rate limited
      // AuthWrapper will handle redirect to RateLimitScreen
      Logger.warning('Rate limited loading pending requests: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } on Failure catch (e) {
      // Other failures (NetworkFailure, ServerFailure, etc.)
      Logger.error('Failure loading pending requests: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error loading pending requests', e, stackTrace);
      _state = PlpApprovalError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Load equipment request detail
  /// 
  /// Sets state to PlpApprovalDetailLoaded on success
  /// Sets state to PlpApprovalError on failure
  Future<void> loadRequestDetail(int requestId) async {
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = const PlpApprovalError(
        ServerFailure(
          message: 'PLP approval repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const PlpApprovalLoading();
      notifyListeners();
      
      Logger.info('Loading request detail via provider (id: $requestId)');
      
      final detail = await _repository!.getRequestDetail(requestId);
      
      _state = PlpApprovalDetailLoaded(detail);
      Logger.info('Request detail loaded successfully: ${detail.id}');
      
      notifyListeners();
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure loading request detail: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked loading request detail: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited loading request detail: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } on Failure catch (e) {
      Logger.error('Failure loading request detail: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error loading request detail', e, stackTrace);
      _state = PlpApprovalError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Approve equipment request
  /// 
  /// Sets state to PlpApprovalActionSuccess on success
  /// Sets state to PlpApprovalError on failure
  /// NO navigation logic - UI handles based on state
  Future<void> approveRequest(int requestId) async {
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = const PlpApprovalError(
        ServerFailure(
          message: 'PLP approval repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const PlpApprovalLoading();
      notifyListeners();
      
      Logger.info('Approving request via provider (id: $requestId)');
      
      await _repository!.approveRequest(requestId);
      
      _state = PlpApprovalActionSuccess(
        message: 'Request berhasil disetujui',
        requestId: requestId,
      );
      Logger.info('Request approved successfully: $requestId');
      
      notifyListeners();
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure approving request: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked approving request: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited approving request: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } on Failure catch (e) {
      Logger.error('Failure approving request: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error approving request', e, stackTrace);
      _state = PlpApprovalError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Reject equipment request
  /// 
  /// Sets state to PlpApprovalActionSuccess on success
  /// Sets state to PlpApprovalError on failure
  /// NO navigation logic - UI handles based on state
  Future<void> rejectRequest(int requestId, String reason) async {
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = const PlpApprovalError(
        ServerFailure(
          message: 'PLP approval repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const PlpApprovalLoading();
      notifyListeners();
      
      Logger.info('Rejecting request via provider (id: $requestId, reason: $reason)');
      
      await _repository!.rejectRequest(requestId, reason);
      
      _state = PlpApprovalActionSuccess(
        message: 'Request berhasil ditolak',
        requestId: requestId,
      );
      Logger.info('Request rejected successfully: $requestId');
      
      notifyListeners();
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure rejecting request: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked rejecting request: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited rejecting request: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } on Failure catch (e) {
      Logger.error('Failure rejecting request: ${e.message}');
      _state = PlpApprovalError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error rejecting request', e, stackTrace);
      _state = PlpApprovalError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
}
