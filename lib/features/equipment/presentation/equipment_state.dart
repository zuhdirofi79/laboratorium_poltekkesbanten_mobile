import '../../../core/errors/failure.dart';
import '../domain/equipment_request.dart';

/// Equipment State
/// 
/// Represents all possible states for equipment requests
/// Used by UI layer to determine what to render
sealed class EquipmentState {
  const EquipmentState();
}

/// Initial State
/// 
/// Initial state before any load operation
class EquipmentInitial extends EquipmentState {
  const EquipmentInitial();
}

/// Loading State
/// 
/// Equipment requests are being loaded
class EquipmentLoading extends EquipmentState {
  const EquipmentLoading();
}

/// Loaded State
/// 
/// Equipment requests successfully loaded
class EquipmentLoaded extends EquipmentState {
  final List<EquipmentRequest> requests;
  
  const EquipmentLoaded(this.requests);
}

/// Empty State
/// 
/// No equipment requests found
class EquipmentEmpty extends EquipmentState {
  const EquipmentEmpty();
}

/// Error State
/// 
/// Failed to load equipment requests
/// Contains Failure for UI error handling
class EquipmentError extends EquipmentState {
  final Failure failure;
  
  const EquipmentError(this.failure);
}
