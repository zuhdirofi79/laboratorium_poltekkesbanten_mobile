import '../../../core/errors/failure.dart';
import '../domain/admin_user.dart';

/// Admin Users State
/// 
/// Represents all possible states for admin users management
/// Used by UI layer to determine what to render
/// Pattern mirrors EquipmentState and PlpApprovalState exactly
sealed class AdminUsersState {
  const AdminUsersState();
}

/// Initial State
/// 
/// Initial state before any load operation
class AdminUsersInitial extends AdminUsersState {
  const AdminUsersInitial();
}

/// Loading State
/// 
/// Users are being loaded or action is in progress
class AdminUsersLoading extends AdminUsersState {
  const AdminUsersLoading();
}

/// Loaded State
/// 
/// Users successfully loaded
class AdminUsersLoaded extends AdminUsersState {
  final List<AdminUser> users;
  
  const AdminUsersLoaded(this.users);
}

/// Empty State
/// 
/// No users found
class AdminUsersEmpty extends AdminUsersState {
  const AdminUsersEmpty();
}

/// Action Success State
/// 
/// CRUD action completed successfully
/// UI should reload list after this state
class AdminUsersActionSuccess extends AdminUsersState {
  final String message;
  
  const AdminUsersActionSuccess({required this.message});
}

/// Error State
/// 
/// Failed to load or perform action
/// Contains Failure for UI error handling
class AdminUsersError extends AdminUsersState {
  final Failure failure;
  
  const AdminUsersError(this.failure);
}
