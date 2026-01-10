import '../../../core/errors/failure.dart';
import '../domain/equipment_request_summary.dart';
import '../domain/equipment_request_detail.dart';

/// PLP Approval State
/// 
/// Represents all possible states for PLP approval flow
/// Used by UI layer to determine what to render
/// Pattern mirrors EquipmentState exactly
sealed class PlpApprovalState {
  const PlpApprovalState();
}

/// Initial State
/// 
/// Initial state before any load operation
class PlpApprovalInitial extends PlpApprovalState {
  const PlpApprovalInitial();
}

/// Loading State
/// 
/// Approval requests are being loaded
class PlpApprovalLoading extends PlpApprovalState {
  const PlpApprovalLoading();
}

/// List Loaded State
/// 
/// Pending requests list successfully loaded
class PlpApprovalListLoaded extends PlpApprovalState {
  final List<EquipmentRequestSummary> requests;
  
  const PlpApprovalListLoaded(this.requests);
}

/// Detail Loaded State
/// 
/// Request detail successfully loaded
class PlpApprovalDetailLoaded extends PlpApprovalState {
  final EquipmentRequestDetail detail;
  
  const PlpApprovalDetailLoaded(this.detail);
}

/// Action Success State
/// 
/// Approve/reject action completed successfully
/// UI should reload list after this state
class PlpApprovalActionSuccess extends PlpApprovalState {
  final String message;
  final int? requestId;
  
  const PlpApprovalActionSuccess({
    required this.message,
    this.requestId,
  });
}

/// Empty State
/// 
/// No pending requests found
class PlpApprovalEmpty extends PlpApprovalState {
  const PlpApprovalEmpty();
}

/// Error State
/// 
/// Failed to load or perform action
/// Contains Failure for UI error handling
class PlpApprovalError extends PlpApprovalState {
  final Failure failure;
  
  const PlpApprovalError(this.failure);
}
