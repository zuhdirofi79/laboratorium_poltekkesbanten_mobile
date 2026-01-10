import 'package:flutter/foundation.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_interceptor.dart';
import '../data/equipment_repository.dart';
import '../data/equipment_api.dart';
import '../domain/equipment_request.dart';
import 'equipment_state.dart';

/// Equipment Provider
/// 
/// Provides EquipmentState to UI layer
/// Depends ONLY on EquipmentRepository
/// Handles state changes and notifies listeners
/// NO navigation logic - UI handles navigation
class EquipmentProvider with ChangeNotifier {
  EquipmentRepository? _repository;
  
  EquipmentState _state = const EquipmentInitial();
  
  EquipmentProvider._();
  
  /// Factory method to create provider with dependencies
  /// 
  /// Creates: TokenStorage → ApiInterceptor → ApiClient → EquipmentApi → EquipmentRepository
  /// NO global singletons - each provider gets its own instance
  static EquipmentProvider create() {
    final provider = EquipmentProvider._();
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
      
      // Initialize equipment API
      final equipmentApi = EquipmentApi(apiClient);
      
      // Initialize equipment repository
      _repository = EquipmentRepository(
        equipmentApi: equipmentApi,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize EquipmentProvider', e, stackTrace);
      _state = EquipmentError(
        ServerFailure(
          message: 'Failed to initialize equipment provider: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Current equipment state
  EquipmentState get state => _state;
  
  /// Check if loading
  bool get isLoading => _state is EquipmentLoading;
  
  /// Check if loaded
  bool get isLoaded => _state is EquipmentLoaded;
  
  /// Check if empty
  bool get isEmpty => _state is EquipmentEmpty;
  
  /// Check if error
  bool get isError => _state is EquipmentError;
  
  /// Get requests if loaded
  List<EquipmentRequest>? get requests {
    final state = _state;
    if (state is EquipmentLoaded) {
      return state.requests;
    }
    return null;
  }
  
  /// Get current failure if error state
  Failure? get currentFailure {
    final state = _state;
    if (state is EquipmentError) {
      return state.failure;
    }
    return null;
  }
  
  /// Load equipment requests
  /// 
  /// Automatically:
  /// - sets Loading state
  /// - handles Empty vs Loaded
  /// - exposes Failure for UI
  /// NO navigation logic - UI handles based on state
  Future<void> loadRequests() async {
    // Wait for initialization if needed
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = const EquipmentError(
        ServerFailure(
          message: 'Equipment repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const EquipmentLoading();
      notifyListeners();
      
      Logger.info('Loading equipment requests via provider');
      
      final requests = await _repository!.getUserEquipmentRequests();
      
      // Handle Empty vs Loaded
      if (requests.isEmpty) {
        _state = const EquipmentEmpty();
        Logger.info('Equipment requests empty');
      } else {
        _state = EquipmentLoaded(requests);
        Logger.info('Equipment requests loaded: ${requests.length} items');
      }
      
      notifyListeners();
    } on AuthFailure catch (e) {
      // 401 - token invalid/expired
      // AuthWrapper will handle redirect to Login
      Logger.warning('Auth failure loading equipment requests: ${e.message}');
      _state = EquipmentError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      // 403 - user/IP blocked
      // AuthWrapper will handle redirect to SecurityBlockedScreen
      Logger.warning('Security blocked loading equipment requests: ${e.message}');
      _state = EquipmentError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      // 429 - rate limited
      // AuthWrapper will handle redirect to RateLimitScreen
      Logger.warning('Rate limited loading equipment requests: ${e.message}');
      _state = EquipmentError(e);
      notifyListeners();
    } on Failure catch (e) {
      // Other failures (NetworkFailure, ServerFailure, etc.)
      Logger.error('Failure loading equipment requests: ${e.message}');
      _state = EquipmentError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error loading equipment requests', e, stackTrace);
      _state = EquipmentError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
}
