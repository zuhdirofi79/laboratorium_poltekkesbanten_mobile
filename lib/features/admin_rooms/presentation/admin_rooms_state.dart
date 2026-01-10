import '../../../core/errors/failure.dart';
import '../domain/lab_room.dart';

/// Admin Rooms State
/// 
/// Represents all possible states for admin rooms management
/// Used by UI layer to determine what to render
/// Pattern mirrors EquipmentState and AdminUsersState exactly
sealed class AdminRoomsState {
  const AdminRoomsState();
}

/// Initial State
/// 
/// Initial state before any load operation
class AdminRoomsInitial extends AdminRoomsState {
  const AdminRoomsInitial();
}

/// Loading State
/// 
/// Rooms are being loaded or action is in progress
class AdminRoomsLoading extends AdminRoomsState {
  const AdminRoomsLoading();
}

/// Loaded State
/// 
/// Rooms successfully loaded
class AdminRoomsLoaded extends AdminRoomsState {
  final List<LabRoom> rooms;
  
  const AdminRoomsLoaded(this.rooms);
}

/// Empty State
/// 
/// No rooms found
class AdminRoomsEmpty extends AdminRoomsState {
  const AdminRoomsEmpty();
}

/// Action Success State
/// 
/// CRUD action completed successfully
/// UI should reload list after this state
class AdminRoomsActionSuccess extends AdminRoomsState {
  final String message;
  
  const AdminRoomsActionSuccess({required this.message});
}

/// Error State
/// 
/// Failed to load or perform action
/// Contains Failure for UI error handling
class AdminRoomsError extends AdminRoomsState {
  final Failure failure;
  
  const AdminRoomsError(this.failure);
}
