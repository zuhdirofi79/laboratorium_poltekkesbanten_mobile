import 'package:flutter/foundation.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_interceptor.dart';
import '../data/schedule_repository.dart';
import '../data/schedule_api.dart';
import '../domain/praktikum_schedule.dart';
import 'schedule_state.dart';

/// Schedule Provider
/// 
/// Provides ScheduleState to UI layer
/// Depends ONLY on ScheduleRepository
/// Handles state changes and notifies listeners
/// NO navigation logic - UI handles navigation
/// Pattern mirrors EquipmentProvider exactly
class ScheduleProvider with ChangeNotifier {
  ScheduleRepository? _repository;
  
  ScheduleState _state = const ScheduleInitial();
  
  ScheduleProvider._();
  
  /// Factory method to create provider with dependencies
  /// 
  /// Creates: TokenStorage → ApiInterceptor → ApiClient → ScheduleApi → ScheduleRepository
  /// NO global singletons - each provider gets its own instance
  static ScheduleProvider create() {
    final provider = ScheduleProvider._();
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
      
      // Initialize schedule API
      final scheduleApi = ScheduleApi(apiClient);
      
      // Initialize schedule repository
      _repository = ScheduleRepository(
        scheduleApi: scheduleApi,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize ScheduleProvider', e, stackTrace);
      _state = ScheduleError(
        ServerFailure(
          message: 'Failed to initialize schedule provider: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Current schedule state
  ScheduleState get state => _state;
  
  /// Check if loading
  bool get isLoading => _state is ScheduleLoading;
  
  /// Check if loaded
  bool get isLoaded => _state is ScheduleLoaded;
  
  /// Check if empty
  bool get isEmpty => _state is ScheduleEmpty;
  
  /// Check if error
  bool get isError => _state is ScheduleError;
  
  /// Get schedules if loaded
  List<PraktikumSchedule>? get schedules {
    final state = _state;
    if (state is ScheduleLoaded) {
      return state.schedules;
    }
    return null;
  }
  
  /// Get current failure if error state
  Failure? get currentFailure {
    final state = _state;
    if (state is ScheduleError) {
      return state.failure;
    }
    return null;
  }
  
  /// Load praktikum schedules
  /// 
  /// Automatically:
  /// - sets Loading state
  /// - handles Empty vs Loaded
  /// - exposes Failure for UI
  /// NO navigation logic - UI handles based on state
  Future<void> loadSchedules() async {
    // Wait for initialization if needed
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = ScheduleError(
        ServerFailure(
          message: 'Schedule repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const ScheduleLoading();
      notifyListeners();
      
      Logger.info('Loading praktikum schedules via provider');
      
      final schedules = await _repository!.getUserSchedules();
      
      // Handle Empty vs Loaded
      if (schedules.isEmpty) {
        _state = const ScheduleEmpty();
        Logger.info('Praktikum schedules empty');
      } else {
        _state = ScheduleLoaded(schedules);
        Logger.info('Praktikum schedules loaded: ${schedules.length} items');
      }
      
      notifyListeners();
    } on AuthFailure catch (e) {
      // 401 - token invalid/expired
      // AuthWrapper will handle redirect to Login
      Logger.warning('Auth failure loading praktikum schedules: ${e.message}');
      _state = ScheduleError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      // 403 - user/IP blocked
      // AuthWrapper will handle redirect to SecurityBlockedScreen
      Logger.warning('Security blocked loading praktikum schedules: ${e.message}');
      _state = ScheduleError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      // 429 - rate limited
      // AuthWrapper will handle redirect to RateLimitScreen
      Logger.warning('Rate limited loading praktikum schedules: ${e.message}');
      _state = ScheduleError(e);
      notifyListeners();
    } on Failure catch (e) {
      // Other failures (NetworkFailure, ServerFailure, etc.)
      Logger.error('Failure loading praktikum schedules: ${e.message}');
      _state = ScheduleError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error loading praktikum schedules', e, stackTrace);
      _state = ScheduleError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
}
