import 'package:flutter/foundation.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/error_code.dart';
import '../../../core/utils/logger.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_interceptor.dart';
import '../data/admin_rooms_repository.dart';
import '../data/admin_rooms_api.dart';
import '../domain/lab_room.dart';
import 'admin_rooms_state.dart';

/// Admin Rooms Provider
/// 
/// Provides AdminRoomsState to UI layer
/// Depends ONLY on AdminRoomsRepository
/// Handles state changes and notifies listeners
/// NO navigation logic - UI handles navigation
/// Pattern mirrors AdminUsersProvider exactly
class AdminRoomsProvider with ChangeNotifier {
  AdminRoomsRepository? _repository;
  
  AdminRoomsState _state = const AdminRoomsInitial();
  
  AdminRoomsProvider._();
  
  /// Factory method to create provider with dependencies
  /// 
  /// Creates: TokenStorage → ApiInterceptor → ApiClient → AdminRoomsApi → AdminRoomsRepository
  /// NO global singletons - each provider gets its own instance
  static AdminRoomsProvider create() {
    final provider = AdminRoomsProvider._();
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
      
      // Initialize admin rooms API
      final adminRoomsApi = AdminRoomsApi(apiClient);
      
      // Initialize admin rooms repository
      _repository = AdminRoomsRepository(
        adminRoomsApi: adminRoomsApi,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize AdminRoomsProvider', e, stackTrace);
      _state = AdminRoomsError(
        ServerFailure(
          message: 'Failed to initialize admin rooms provider: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Current admin rooms state
  AdminRoomsState get state => _state;
  
  /// Check if loading
  bool get isLoading => _state is AdminRoomsLoading;
  
  /// Check if loaded
  bool get isLoaded => _state is AdminRoomsLoaded;
  
  /// Check if empty
  bool get isEmpty => _state is AdminRoomsEmpty;
  
  /// Check if action success
  bool get isActionSuccess => _state is AdminRoomsActionSuccess;
  
  /// Check if error
  bool get isError => _state is AdminRoomsError;
  
  /// Get rooms if loaded
  List<LabRoom>? get rooms {
    final state = _state;
    if (state is AdminRoomsLoaded) {
      return state.rooms;
    }
    return null;
  }
  
  /// Get current failure if error state
  Failure? get currentFailure {
    final state = _state;
    if (state is AdminRoomsError) {
      return state.failure;
    }
    return null;
  }
  
  /// Load rooms
  /// 
  /// Automatically:
  /// - sets Loading state
  /// - handles Empty vs Loaded
  /// - exposes Failure for UI
  /// NO navigation logic - UI handles based on state
  Future<void> loadRooms({String? search}) async {
    // Wait for initialization if needed
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = const AdminRoomsError(
        ServerFailure(
          message: 'Admin rooms repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const AdminRoomsLoading();
      notifyListeners();
      
      Logger.info('Loading admin rooms via provider (search: $search)');
      
      final rooms = await _repository!.getRooms(search: search);
      
      // Handle Empty vs Loaded
      if (rooms.isEmpty) {
        _state = const AdminRoomsEmpty();
        Logger.info('Admin rooms empty');
      } else {
        _state = AdminRoomsLoaded(rooms);
        Logger.info('Admin rooms loaded: ${rooms.length} items');
      }
      
      notifyListeners();
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure loading admin rooms: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked loading admin rooms: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited loading admin rooms: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } on Failure catch (e) {
      Logger.error('Failure loading admin rooms: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error loading admin rooms', e, stackTrace);
      _state = AdminRoomsError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Add room
  /// 
  /// Sets state to AdminRoomsActionSuccess on success
  /// Sets state to AdminRoomsError on failure
  /// NO navigation logic - UI handles based on state
  Future<void> addRoom({
    required String labName,
    required String department,
    required String campus,
  }) async {
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = const AdminRoomsError(
        ServerFailure(
          message: 'Admin rooms repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const AdminRoomsLoading();
      notifyListeners();
      
      Logger.info('Adding room via provider (name: $labName)');
      
      await _repository!.addRoom(
        labName: labName,
        department: department,
        campus: campus,
      );
      
      _state = const AdminRoomsActionSuccess(
        message: 'Ruangan berhasil ditambahkan',
      );
      Logger.info('Room added successfully: $labName');
      
      notifyListeners();
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure adding room: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked adding room: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited adding room: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } on Failure catch (e) {
      Logger.error('Failure adding room: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error adding room', e, stackTrace);
      _state = AdminRoomsError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Update room
  /// 
  /// Sets state to AdminRoomsActionSuccess on success
  /// Sets state to AdminRoomsError on failure
  /// NO navigation logic - UI handles based on state
  Future<void> updateRoom({
    required int id,
    required String labName,
    required String department,
    required String campus,
  }) async {
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = const AdminRoomsError(
        ServerFailure(
          message: 'Admin rooms repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const AdminRoomsLoading();
      notifyListeners();
      
      Logger.info('Updating room via provider (id: $id)');
      
      await _repository!.updateRoom(
        id: id,
        labName: labName,
        department: department,
        campus: campus,
      );
      
      _state = const AdminRoomsActionSuccess(
        message: 'Ruangan berhasil diupdate',
      );
      Logger.info('Room updated successfully: $id');
      
      notifyListeners();
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure updating room: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked updating room: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited updating room: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } on Failure catch (e) {
      Logger.error('Failure updating room: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error updating room', e, stackTrace);
      _state = AdminRoomsError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
  
  /// Delete room
  /// 
  /// Sets state to AdminRoomsActionSuccess on success
  /// Sets state to AdminRoomsError on failure
  /// NO navigation logic - UI handles based on state
  Future<void> deleteRoom(int id) async {
    if (_repository == null) {
      await _initialize();
    }
    
    if (_repository == null) {
      _state = const AdminRoomsError(
        ServerFailure(
          message: 'Admin rooms repository not initialized',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
      return;
    }

    try {
      _state = const AdminRoomsLoading();
      notifyListeners();
      
      Logger.info('Deleting room via provider (id: $id)');
      
      await _repository!.deleteRoom(id);
      
      _state = const AdminRoomsActionSuccess(
        message: 'Ruangan berhasil dihapus',
      );
      Logger.info('Room deleted successfully: $id');
      
      notifyListeners();
    } on AuthFailure catch (e) {
      Logger.warning('Auth failure deleting room: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } on SecurityBlockedFailure catch (e) {
      Logger.warning('Security blocked deleting room: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } on RateLimitFailure catch (e) {
      Logger.warning('Rate limited deleting room: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } on Failure catch (e) {
      Logger.error('Failure deleting room: ${e.message}');
      _state = AdminRoomsError(e);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Unexpected error deleting room', e, stackTrace);
      _state = AdminRoomsError(
        ServerFailure(
          message: 'Unexpected error: $e',
          errorCode: ErrorCode.unknown,
        ),
      );
      notifyListeners();
    }
  }
}
